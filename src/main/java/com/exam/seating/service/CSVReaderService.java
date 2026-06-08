package com.exam.seating.service;

import com.exam.seating.model.Hall;
import com.exam.seating.model.Student;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.*;

/**
 * Module 1 — CSVReaderService
 *
 * Parses uploaded CSV files using Java BufferedReader.
 * Validates rows for empty fields, wrong format, duplicate roll numbers.
 * Returns in-memory lists — NO database involved.
 *
 * Data structures used:
 *   ArrayList<Student>
 *   HashMap<String, List<Student>>
 *   HashSet<String>   (duplicate detection)
 */
@Service
public class CSVReaderService {

    /**
     * Parse a student CSV file.
     * Expected format: roll_no,name,branch
     *
     * @param file    uploaded CSV MultipartFile
     * @param errors  accumulator for validation error messages
     * @return        ArrayList of valid Student objects
     */
    public ArrayList<Student> parseStudents(MultipartFile file, List<String> errors) {
        ArrayList<Student> students = new ArrayList<>();
        HashSet<String> seenRollNos = new HashSet<>();

        if (file == null || file.isEmpty()) {
            errors.add("File '" + (file != null ? file.getOriginalFilename() : "unknown") + "' is empty or missing.");
            return students;
        }

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(file.getInputStream()))) {

            String line;
            int lineNum = 0;

            while ((line = reader.readLine()) != null) {
                lineNum++;
                line = line.trim();

                // Skip header row
                if (lineNum == 1 && line.toLowerCase().replaceAll("\"", "").startsWith("roll")) {
                    continue;
                }

                // Skip blank lines
                if (line.isEmpty()) continue;

                String[] cols = line.split(",", -1);

                // Validate column count
                if (cols.length < 3) {
                    errors.add("[" + file.getOriginalFilename() + "] Line " + lineNum
                            + ": Wrong format — need roll_no,name,branch → got: " + line);
                    continue;
                }

                String rollNo = cols[0].trim().replaceAll("\"", "");
                String name   = cols[1].trim().replaceAll("\"", "");
                String branch = cols[2].trim().replaceAll("\"", "").toUpperCase();

                // Validate empty fields
                if (rollNo.isEmpty() || name.isEmpty() || branch.isEmpty()) {
                    errors.add("[" + file.getOriginalFilename() + "] Line " + lineNum
                            + ": Empty field detected → " + line);
                    continue;
                }

                // Detect duplicate roll numbers
                if (seenRollNos.contains(rollNo.toUpperCase())) {
                    errors.add("[" + file.getOriginalFilename() + "] Line " + lineNum
                            + ": Duplicate roll number → " + rollNo);
                    continue;
                }
                seenRollNos.add(rollNo.toUpperCase());

                students.add(new Student(rollNo.toUpperCase(), name, branch));
            }

        } catch (Exception e) {
            errors.add("Error reading " + file.getOriginalFilename() + ": " + e.getMessage());
        }

        return students;
    }

    /**
     * Parse halls CSV file.
     * Expected format: hall_name,rows,seats_per_row
     */
    public ArrayList<Hall> parseHalls(MultipartFile file, List<String> errors) {
        ArrayList<Hall> halls = new ArrayList<>();

        if (file == null || file.isEmpty()) {
            errors.add("Halls file is empty or missing.");
            return halls;
        }

        try (BufferedReader reader = new BufferedReader(
                new InputStreamReader(file.getInputStream()))) {

            String line;
            int lineNum = 0;

            while ((line = reader.readLine()) != null) {
                lineNum++;
                line = line.trim();

                // Skip header
                if (lineNum == 1 && line.toLowerCase().replaceAll("\"", "").startsWith("hall")) {
                    continue;
                }

                if (line.isEmpty()) continue;

                String[] cols = line.split(",", -1);

                if (cols.length < 3) {
                    errors.add("[halls.csv] Line " + lineNum
                            + ": Wrong format — need hall_name,rows,seats_per_row");
                    continue;
                }

                String hallName = cols[0].trim().replaceAll("\"", "");
                String rowsStr  = cols[1].trim().replaceAll("\"", "");
                String seatsStr = cols[2].trim().replaceAll("\"", "");

                if (hallName.isEmpty() || rowsStr.isEmpty() || seatsStr.isEmpty()) {
                    errors.add("[halls.csv] Line " + lineNum + ": Empty field detected.");
                    continue;
                }

                try {
                    int rows  = Integer.parseInt(rowsStr);
                    int seats = Integer.parseInt(seatsStr);
                    if (rows <= 0 || seats <= 0) {
                        errors.add("[halls.csv] Line " + lineNum + ": rows and seats_per_row must be > 0.");
                        continue;
                    }
                    halls.add(new Hall(hallName, rows, seats));
                } catch (NumberFormatException e) {
                    errors.add("[halls.csv] Line " + lineNum + ": rows/seats must be integers → " + line);
                }
            }

        } catch (Exception e) {
            errors.add("Error reading halls.csv: " + e.getMessage());
        }

        return halls;
    }

    /**
     * Build a branch map from the student list.
     * Returns HashMap<branchName, List<Student>>
     */
    public HashMap<String, List<Student>> buildBranchMap(List<Student> students) {
        HashMap<String, List<Student>> map = new HashMap<>();
        for (Student s : students) {
            map.computeIfAbsent(s.getBranch(), k -> new ArrayList<>()).add(s);
        }
        return map;
    }
}
