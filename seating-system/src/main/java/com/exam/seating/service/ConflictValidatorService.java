package com.exam.seating.service;

import com.exam.seating.model.Hall;
import com.exam.seating.model.SeatingResult;
import com.exam.seating.model.Student;
import com.exam.seating.model.Violation;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Module 3 — ConflictValidatorService
 *
 * Validates the seating grid for:
 *   1. Adjacent branch conflicts: grid[r][c].branch == grid[r][c+1].branch → FAIL
 *   2. Overflow: more students than total capacity
 *   3. Empty seat ratio > 20% → WARNING
 *
 * Purely in-memory — no database involved.
 * Populates validationStatus and violations list in the SeatingResult.
 */
@Service
public class ConflictValidatorService {

    public void validate(SeatingResult result) {
        List<String> violationMessages   = new ArrayList<>();
        List<Violation> violationObjects = new ArrayList<>();

        Map<String, Student[][]> hallGrids = result.getHallGrids();
        List<Hall> halls = result.getHalls();

        // -------------------------------------------------------
        // Check 1: Adjacent branch conflicts (row-wise)
        // -------------------------------------------------------
        for (Hall hall : halls) {
            Student[][] grid = hallGrids.get(hall.getHallName());
            if (grid == null) continue;

            for (int row = 0; row < hall.getRows(); row++) {
                for (int col = 0; col < hall.getSeatsPerRow() - 1; col++) {
                    Student cur  = grid[row][col];
                    Student next = grid[row][col + 1];

                    if (cur != null && next != null
                            && cur.getBranch().equals(next.getBranch())) {

                        String msg = "CONFLICT | Hall: " + hall.getHallName()
                                + " | Row " + (row + 1)
                                + " | Seats " + (col + 1) + " & " + (col + 2)
                                + " | Branch: " + cur.getBranch()
                                + " (" + cur.getRollNo() + " next to " + next.getRollNo() + ")";

                        violationMessages.add(msg);
                        violationObjects.add(
                                new Violation(hall.getHallName(), row + 1, col + 1, cur.getBranch(), msg));
                    }
                }
            }
        }

        // -------------------------------------------------------
        // Check 2: Overflow
        // -------------------------------------------------------
        if (result.getOverflow() > 0) {
            String msg = "OVERFLOW | " + result.getOverflow()
                    + " student(s) could not be seated — insufficient hall capacity.";
            violationMessages.add(msg);
            violationObjects.add(new Violation("ALL", 0, 0, "N/A", msg));
        }

        // -------------------------------------------------------
        // Check 3: Empty seat ratio > 20%
        // -------------------------------------------------------
        double emptyRatio = result.getEmptySeatRatio();
        if (emptyRatio > 0.20) {
            String msg = String.format(
                    "WARNING | Empty seat ratio %.1f%% exceeds 20%%. Consider using fewer or smaller halls.",
                    emptyRatio * 100);
            violationMessages.add(msg);
            violationObjects.add(new Violation("ALL", 0, 0, "N/A", msg));
        }

        result.setViolations(violationMessages);
        result.setViolationObjects(violationObjects);
        result.setValidationStatus(violationMessages.isEmpty() ? "PASS" : "FAIL");
    }
}
