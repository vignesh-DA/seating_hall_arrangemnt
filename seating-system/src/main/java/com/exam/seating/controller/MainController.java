package com.exam.seating.controller;

import com.exam.seating.model.Hall;
import com.exam.seating.model.SeatingResult;
import com.exam.seating.model.Student;
import com.exam.seating.service.*;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.PathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.io.*;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

/**
 * Module 5 — MainController
 *
 * Full pipeline — NO database:
 *   Upload CSV → parse (memory) → seating engine → validate → write files → download
 *
 * Endpoints:
 *   GET  /                       → dashboard
 *   GET  /upload                 → upload form
 *   POST /upload                 → parse CSVs into session
 *   GET  /generate               → generate page
 *   POST /generate               → run full pipeline
 *   GET  /view                   → seating grid
 *   GET  /reports                → reports page
 *   GET  /summary                → summary page
 *   GET  /download/seating       → download single hall seating CSV
 *   GET  /download/all           → download ALL reports as ZIP
 *   GET  /download/violations    → download violations.txt
 *   GET  /download/summary       → download summary.txt
 */
@Controller
public class MainController {

    @Autowired private CSVReaderService        csvReaderService;
    @Autowired private SeatingEngineService    seatingEngineService;
    @Autowired private ConflictValidatorService conflictValidatorService;
    @Autowired private ReportService           reportService;
    @Autowired private CSVWriterService        csvWriterService;

    private static final String S_STUDENTS = "uploadedStudents";
    private static final String S_HALLS    = "uploadedHalls";
    private static final String S_RESULT   = "seatingResult";

    // ==================================================================
    // GET / — Dashboard
    // ==================================================================
    @GetMapping("/")
    public String dashboard(HttpSession session, Model model) {
        List<?> students = (List<?>) session.getAttribute(S_STUDENTS);
        List<?> halls    = (List<?>) session.getAttribute(S_HALLS);
        model.addAttribute("studentCount", students != null ? students.size() : 0);
        model.addAttribute("hallCount",    halls    != null ? halls.size()    : 0);
        model.addAttribute("hasResult",    session.getAttribute(S_RESULT) != null);
        return "dashboard";
    }

    // ==================================================================
    // GET /upload
    // ==================================================================
    @GetMapping("/upload")
    public String uploadForm() { return "upload"; }

    // ==================================================================
    // POST /upload — Parse CSVs and store in HTTP session
    // ==================================================================
    @PostMapping("/upload")
    public String handleUpload(
            @RequestParam("hallsFile")  MultipartFile hallsFile,
            @RequestParam("classAFile") MultipartFile classAFile,
            @RequestParam("classBFile") MultipartFile classBFile,
            @RequestParam("classCFile") MultipartFile classCFile,
            HttpSession session,
            RedirectAttributes ra) {

        List<String> errors   = new ArrayList<>();
        List<String> messages = new ArrayList<>();

        ArrayList<Hall> halls = csvReaderService.parseHalls(hallsFile, errors);
        if (!halls.isEmpty())
            messages.add("✓ Halls parsed: " + halls.size() + " hall(s)");

        ArrayList<Student> all = new ArrayList<>();

        ArrayList<Student> a = csvReaderService.parseStudents(classAFile, errors);
        all.addAll(a);
        if (!a.isEmpty()) messages.add("✓ " + classAFile.getOriginalFilename() + ": " + a.size() + " student(s)");

        ArrayList<Student> b = csvReaderService.parseStudents(classBFile, errors);
        all.addAll(b);
        if (!b.isEmpty()) messages.add("✓ " + classBFile.getOriginalFilename() + ": " + b.size() + " student(s)");

        ArrayList<Student> c = csvReaderService.parseStudents(classCFile, errors);
        all.addAll(c);
        if (!c.isEmpty()) messages.add("✓ " + classCFile.getOriginalFilename() + ": " + c.size() + " student(s)");

        if (!all.isEmpty() && !halls.isEmpty()) {
            session.setAttribute(S_STUDENTS, all);
            session.setAttribute(S_HALLS,    halls);
            session.removeAttribute(S_RESULT);
            messages.add("✓ Total students loaded: " + all.size());
        } else {
            errors.add("Upload incomplete — need at least one hall and one student file.");
        }

        ra.addFlashAttribute("uploadMessages", messages);
        ra.addFlashAttribute("uploadErrors",   errors);
        return "redirect:/upload";
    }

    // ==================================================================
    // GET /generate
    // ==================================================================
    @GetMapping("/generate")
    public String generatePage(HttpSession session, Model model) {
        List<?> students = (List<?>) session.getAttribute(S_STUDENTS);
        List<?> halls    = (List<?>) session.getAttribute(S_HALLS);
        model.addAttribute("studentCount", students != null ? students.size() : 0);
        model.addAttribute("hallCount",    halls    != null ? halls.size()    : 0);
        // Pass result if already generated
        SeatingResult result = (SeatingResult) session.getAttribute(S_RESULT);
        if (result != null) model.addAttribute("result", result);
        return "generate";
    }

    // ==================================================================
    // POST /generate — Run full pipeline
    // ==================================================================
    @SuppressWarnings("unchecked")
    @PostMapping("/generate")
    public String runGenerate(HttpSession session, RedirectAttributes ra) {
        List<Student> students = (List<Student>) session.getAttribute(S_STUDENTS);
        List<Hall>    halls    = (List<Hall>)    session.getAttribute(S_HALLS);

        if (students == null || halls == null || students.isEmpty() || halls.isEmpty()) {
            ra.addFlashAttribute("generateError", "No data — please upload CSV files first.");
            return "redirect:/generate";
        }

        try {
            // 1. Generate seating (greedy sort + round-robin + grid fill)
            SeatingResult result = seatingEngineService.generateSeating(students, halls);

            // 2. Validate constraints
            conflictValidatorService.validate(result);

            // 3. Write report files to disk for download
            reportService.generateAllReports(result);

            // 4. Store result in session
            session.setAttribute(S_RESULT, result);

            ra.addFlashAttribute("generateSuccess",  true);
            ra.addFlashAttribute("validationStatus", result.getValidationStatus());
            ra.addFlashAttribute("violationCount",   result.getViolations().size());
            ra.addFlashAttribute("totalStudents",    result.getTotalStudents());

        } catch (IllegalArgumentException e) {
            ra.addFlashAttribute("generateError", e.getMessage());
        } catch (IOException e) {
            ra.addFlashAttribute("generateError", "Report write failed: " + e.getMessage());
        } catch (Exception e) {
            ra.addFlashAttribute("generateError", "Error: " + e.getMessage());
        }

        return "redirect:/generate";
    }

    // ==================================================================
    // GET /view
    // ==================================================================
    @GetMapping("/view")
    public String viewSeating(HttpSession session, Model model) {
        SeatingResult result = (SeatingResult) session.getAttribute(S_RESULT);
        if (result == null) { model.addAttribute("noData", true); }
        else { model.addAttribute("result", result); model.addAttribute("halls", result.getHalls()); }
        return "seating";
    }

    // ==================================================================
    // GET /reports
    // ==================================================================
    @GetMapping("/reports")
    public String reportsPage(HttpSession session, Model model) {
        SeatingResult result = (SeatingResult) session.getAttribute(S_RESULT);
        model.addAttribute("hasReports", result != null);
        if (result != null) model.addAttribute("result", result);
        return "reports";
    }

    // ==================================================================
    // GET /summary
    // ==================================================================
    @GetMapping("/summary")
    public String summaryPage(HttpSession session, Model model) {
        SeatingResult result = (SeatingResult) session.getAttribute(S_RESULT);
        List<?> students     = (List<?>) session.getAttribute(S_STUDENTS);
        List<?> halls        = (List<?>) session.getAttribute(S_HALLS);
        if (result != null) model.addAttribute("result", result);
        model.addAttribute("studentCount", students != null ? students.size() : 0);
        model.addAttribute("hallCount",    halls    != null ? halls.size()    : 0);
        return "summary";
    }

    // ==================================================================
    // GET /download/seating?hall=Hall-A — Single hall seating CSV
    // ==================================================================
    @GetMapping("/download/seating")
    public ResponseEntity<Resource> downloadSeating(
            @RequestParam(defaultValue = "") String hall,
            HttpSession session) throws IOException {

        SeatingResult result = (SeatingResult) session.getAttribute(S_RESULT);
        if (result == null) return ResponseEntity.notFound().build();

        if (hall.isEmpty() && !result.getHalls().isEmpty())
            hall = result.getHalls().get(0).getHallName();

        String fileName = hall.replace(" ", "_") + "_seating.csv";
        Path filePath   = csvWriterService.getReportPath(fileName);
        Resource res    = new PathResource(filePath);

        if (!res.exists()) return ResponseEntity.notFound().build();

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + fileName + "\"")
                .contentType(MediaType.parseMediaType("text/csv"))
                .body(res);
    }

    // ==================================================================
    // GET /download/all — Download ALL reports as a single ZIP
    // ==================================================================
    @GetMapping("/download/all")
    public ResponseEntity<byte[]> downloadAll(HttpSession session) throws IOException {
        SeatingResult result = (SeatingResult) session.getAttribute(S_RESULT);
        if (result == null) return ResponseEntity.notFound().build();

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        try (ZipOutputStream zos = new ZipOutputStream(baos)) {

            // Add each hall's seating CSV
            for (Hall hall : result.getHalls()) {
                String fileName = hall.getHallName().replace(" ", "_") + "_seating.csv";
                Path filePath   = csvWriterService.getReportPath(fileName);
                if (Files.exists(filePath)) {
                    zos.putNextEntry(new ZipEntry(fileName));
                    zos.write(Files.readAllBytes(filePath));
                    zos.closeEntry();
                }
            }

            // Add violations.txt
            Path vPath = csvWriterService.getReportPath("violations.txt");
            if (Files.exists(vPath)) {
                zos.putNextEntry(new ZipEntry("violations.txt"));
                zos.write(Files.readAllBytes(vPath));
                zos.closeEntry();
            }

            // Add summary.txt
            Path sPath = csvWriterService.getReportPath("summary.txt");
            if (Files.exists(sPath)) {
                zos.putNextEntry(new ZipEntry("summary.txt"));
                zos.write(Files.readAllBytes(sPath));
                zos.closeEntry();
            }
        }

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=\"seating_reports.zip\"")
                .contentType(MediaType.parseMediaType("application/zip"))
                .body(baos.toByteArray());
    }

    // ==================================================================
    // GET /download/violations
    // ==================================================================
    @GetMapping("/download/violations")
    public ResponseEntity<Resource> downloadViolations() throws IOException {
        Path filePath = csvWriterService.getReportPath("violations.txt");
        Resource res  = new PathResource(filePath);
        if (!res.exists()) return ResponseEntity.notFound().build();
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"violations.txt\"")
                .contentType(MediaType.TEXT_PLAIN)
                .body(res);
    }

    // ==================================================================
    // GET /download/summary
    // ==================================================================
    @GetMapping("/download/summary")
    public ResponseEntity<Resource> downloadSummary() throws IOException {
        Path filePath = csvWriterService.getReportPath("summary.txt");
        Resource res  = new PathResource(filePath);
        if (!res.exists()) return ResponseEntity.notFound().build();
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"summary.txt\"")
                .contentType(MediaType.TEXT_PLAIN)
                .body(res);
    }
}
