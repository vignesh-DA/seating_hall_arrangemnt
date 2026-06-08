package com.exam.seating.model;

import java.util.List;
import java.util.Map;

/**
 * Data Transfer Object carrying the complete seating result.
 * Passed between service layer → controller → JSP views.
 * Stored in HTTP session for download/view endpoints.
 * No database involvement.
 */
public class SeatingResult {

    /** hallName → 2D grid (null = empty seat) */
    private Map<String, Student[][]> hallGrids;

    /** Ordered list of halls */
    private List<Hall> halls;

    /** Total students in the uploaded CSV files */
    private int totalStudents;

    /** Total seat capacity across all halls */
    private int totalCapacity;

    /** Students that could not be seated (overflow) */
    private int overflow;

    /** Empty seats after seating */
    private int emptySeats;

    /** "PASS" or "FAIL" */
    private String validationStatus;

    /** Human-readable violation messages */
    private List<String> violations;

    /** Structured violation objects (for report writing) */
    private List<Violation> violationObjects;

    public SeatingResult() {}

    // ---- Computed metrics ----

    public double getCapacityPercent() {
        if (totalCapacity == 0) return 0;
        return Math.round(((double) totalStudents / totalCapacity) * 1000.0) / 10.0;
    }

    public double getEmptySeatRatio() {
        if (totalCapacity == 0) return 0;
        return (double) emptySeats / totalCapacity;
    }

    // ---- Getters & Setters ----

    public Map<String, Student[][]> getHallGrids()              { return hallGrids; }
    public void setHallGrids(Map<String, Student[][]> hallGrids){ this.hallGrids = hallGrids; }

    public List<Hall> getHalls()               { return halls; }
    public void setHalls(List<Hall> halls)     { this.halls = halls; }

    public int getTotalStudents()              { return totalStudents; }
    public void setTotalStudents(int v)        { this.totalStudents = v; }

    public int getTotalCapacity()              { return totalCapacity; }
    public void setTotalCapacity(int v)        { this.totalCapacity = v; }

    public int getOverflow()                   { return overflow; }
    public void setOverflow(int v)             { this.overflow = v; }

    public int getEmptySeats()                 { return emptySeats; }
    public void setEmptySeats(int v)           { this.emptySeats = v; }

    public String getValidationStatus()        { return validationStatus; }
    public void setValidationStatus(String v)  { this.validationStatus = v; }

    public List<String> getViolations()            { return violations; }
    public void setViolations(List<String> v)      { this.violations = v; }

    public List<Violation> getViolationObjects()         { return violationObjects; }
    public void setViolationObjects(List<Violation> v)   { this.violationObjects = v; }
}
