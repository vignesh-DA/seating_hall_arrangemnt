package com.exam.seating.service;

import com.exam.seating.model.Hall;
import com.exam.seating.model.SeatingResult;
import com.exam.seating.model.Student;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.*;
import java.nio.file.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

/**
 * Module 4 — CSVWriterService
 *
 * Produces output files exactly matching the PPT spec:
 *
 *  Hall-X_seating.csv  →  Seat,Row,Col,RollNo,Name,Branch
 *  violations.txt      →  VALIDATION REPORT + PASS/FAIL
 *  summary.txt         →  ===== SUMMARY ===== block
 */
@Service
public class CSVWriterService {

    @Value("${app.report.dir:reports}")
    private String reportDir;

    /** Ensure the reports directory exists and return its absolute path. */
    public Path ensureReportDir() throws IOException {
        Path dir = Paths.get(reportDir).toAbsolutePath();
        Files.createDirectories(dir);
        return dir;
    }

    // ==================================================================
    // Hall-X_seating.csv
    // Format (PPT-exact): Seat,Row,Col,RollNo,Name,Branch
    //   Sequential seat number across the whole hall
    //   Empty seats shown as EMPTY row
    // ==================================================================
    public void writeSeatingCSV(SeatingResult result) throws IOException {
        Path dir = ensureReportDir();
        Map<String, Student[][]> hallGrids = result.getHallGrids();

        for (Hall hall : result.getHalls()) {
            String fileName = hall.getHallName().replace(" ", "_") + "_seating.csv";
            Path filePath = dir.resolve(fileName);

            try (BufferedWriter bw = Files.newBufferedWriter(filePath)) {
                bw.write("Seat,Row,Col,RollNo,Name,Branch");
                bw.newLine();

                Student[][] grid = hallGrids.get(hall.getHallName());
                if (grid == null) continue;

                int seatNum = 1;
                for (int row = 0; row < hall.getRows(); row++) {
                    for (int col = 0; col < hall.getSeatsPerRow(); col++) {
                        Student s = grid[row][col];
                        if (s != null) {
                            bw.write(seatNum + "," + (row + 1) + "," + (col + 1)
                                    + "," + s.getRollNo()
                                    + "," + escapeCsv(s.getName())
                                    + "," + s.getBranch());
                        } else {
                            bw.write(seatNum + "," + (row + 1) + "," + (col + 1)
                                    + ",EMPTY,,");
                        }
                        bw.newLine();
                        seatNum++;
                    }
                }
            }
        }
    }

    // ==================================================================
    // violations.txt — PPT-exact format
    // ==================================================================
    public void writeViolations(SeatingResult result) throws IOException {
        Path dir = ensureReportDir();
        Path filePath = dir.resolve("violations.txt");

        try (BufferedWriter bw = Files.newBufferedWriter(filePath)) {
            bw.write("VALIDATION REPORT");
            bw.newLine();
            bw.write("Generated : " + LocalDateTime.now()
                    .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")));
            bw.newLine();
            bw.write("-".repeat(50));
            bw.newLine();
            bw.newLine();

            List<String> violations = result.getViolations();

            if (violations == null || violations.isEmpty()) {
                bw.write("No adjacent same-branch violations found.");
                bw.newLine();
                bw.newLine();
                bw.write("PASS");
                bw.newLine();
            } else {
                // Separate actual conflicts from warnings
                long conflicts = violations.stream()
                        .filter(v -> v.startsWith("CONFLICT")).count();
                long overflow  = violations.stream()
                        .filter(v -> v.startsWith("OVERFLOW")).count();
                long warnings  = violations.stream()
                        .filter(v -> v.startsWith("WARNING")).count();

                if (conflicts > 0) {
                    bw.write("Adjacent branch violations detected (" + conflicts + "):");
                    bw.newLine();
                    bw.newLine();
                    int i = 1;
                    for (String v : violations) {
                        if (v.startsWith("CONFLICT")) {
                            bw.write(i++ + ". " + v);
                            bw.newLine();
                        }
                    }
                    bw.newLine();
                }
                if (overflow > 0) {
                    bw.write("Overflow issues:");
                    bw.newLine();
                    for (String v : violations) {
                        if (v.startsWith("OVERFLOW")) {
                            bw.write("  " + v);
                            bw.newLine();
                        }
                    }
                    bw.newLine();
                }
                if (warnings > 0) {
                    bw.write("Warnings:");
                    bw.newLine();
                    for (String v : violations) {
                        if (v.startsWith("WARNING")) {
                            bw.write("  " + v);
                            bw.newLine();
                        }
                    }
                    bw.newLine();
                }

                bw.write("FAIL");
                bw.newLine();
            }
        }
    }

    // ==================================================================
    // summary.txt — PPT-exact format
    // ==================================================================
    public void writeSummary(SeatingResult result) throws IOException {
        Path dir = ensureReportDir();
        Path filePath = dir.resolve("summary.txt");

        int seated     = result.getTotalStudents() - result.getOverflow();
        int violations = result.getViolations() != null
                ? (int) result.getViolations().stream()
                    .filter(v -> v.startsWith("CONFLICT")).count()
                : 0;

        // Compute halls actually used (halls with at least one student)
        long hallsUsed = result.getHalls().stream()
                .filter(h -> {
                    Student[][] g = result.getHallGrids().get(h.getHallName());
                    if (g == null) return false;
                    for (Student[] row : g)
                        for (Student s : row)
                            if (s != null) return true;
                    return false;
                }).count();

        String status = result.getOverflow() == 0 && violations == 0 ? "SUCCESS" : "PARTIAL";

        try (BufferedWriter bw = Files.newBufferedWriter(filePath)) {
            bw.write("===== SUMMARY =====");
            bw.newLine();
            bw.newLine();
            bw.write("Total Students   : " + result.getTotalStudents());
            bw.newLine();
            bw.write("Total Capacity   : " + result.getTotalCapacity());
            bw.newLine();
            bw.newLine();
            bw.write("Students Seated  : " + seated);
            bw.newLine();
            bw.newLine();
            bw.write("Violations Found : " + violations);
            bw.newLine();
            bw.newLine();
            bw.write("Halls Used       : " + hallsUsed);
            bw.newLine();
            bw.newLine();
            bw.write("Capacity Used    : " + result.getCapacityPercent() + "%");
            bw.newLine();
            bw.newLine();
            bw.write("STATUS           : " + status);
            bw.newLine();
            bw.newLine();
            bw.write("=".repeat(50));
            bw.newLine();
            bw.newLine();

            // Hall-wise breakdown
            bw.write("HALL-WISE BREAKDOWN");
            bw.newLine();
            bw.write("-".repeat(50));
            bw.newLine();
            for (Hall hall : result.getHalls()) {
                Student[][] grid = result.getHallGrids().get(hall.getHallName());
                int count = 0;
                if (grid != null)
                    for (Student[] row : grid)
                        for (Student s : row)
                            if (s != null) count++;
                double pct = hall.getCapacity() > 0
                        ? Math.round(((double) count / hall.getCapacity()) * 1000.0) / 10.0 : 0;
                bw.write(hall.getHallName() + " : "
                        + count + "/" + hall.getCapacity()
                        + " seats used (" + pct + "%)");
                bw.newLine();
            }
        }
    }

    /** Get the absolute path to a named report file. */
    public Path getReportPath(String fileName) {
        return Paths.get(reportDir).toAbsolutePath().resolve(fileName);
    }

    private String escapeCsv(String value) {
        if (value == null) return "";
        if (value.contains(",") || value.contains("\"") || value.contains("\n"))
            return "\"" + value.replace("\"", "\"\"") + "\"";
        return value;
    }
}
