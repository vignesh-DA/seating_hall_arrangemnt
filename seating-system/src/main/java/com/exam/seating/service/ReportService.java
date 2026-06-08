package com.exam.seating.service;

import com.exam.seating.model.SeatingResult;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.io.IOException;

/**
 * Module 4 — ReportService
 *
 * Orchestrates the generation of all report files by delegating
 * to CSVWriterService. Acts as the facade for the reporting module.
 */
@Service
public class ReportService {

    @Autowired
    private CSVWriterService csvWriterService;

    /**
     * Generate all three report files from the seating result.
     * Throws IOException if any file write fails.
     */
    public void generateAllReports(SeatingResult result) throws IOException {
        csvWriterService.writeSeatingCSV(result);
        csvWriterService.writeViolations(result);
        csvWriterService.writeSummary(result);
    }
}
