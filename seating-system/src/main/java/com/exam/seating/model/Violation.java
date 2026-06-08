package com.exam.seating.model;

/**
 * Represents a single seat violation (adjacency conflict, overflow, etc.)
 * Plain Java object — no database required.
 */
public class Violation {

    private String hall;
    private int    row;
    private int    seat;
    private String branch;
    private String description;

    public Violation() {}

    public Violation(String hall, int row, int seat, String branch, String description) {
        this.hall        = hall;
        this.row         = row;
        this.seat        = seat;
        this.branch      = branch;
        this.description = description;
    }

    public String getHall()        { return hall; }
    public void   setHall(String hall)  { this.hall = hall; }

    public int    getRow()         { return row; }
    public void   setRow(int row)  { this.row = row; }

    public int    getSeat()        { return seat; }
    public void   setSeat(int seat){ this.seat = seat; }

    public String getBranch()      { return branch; }
    public void   setBranch(String branch) { this.branch = branch; }

    public String getDescription() { return description; }
    public void   setDescription(String description) { this.description = description; }

    @Override
    public String toString() { return description; }
}
