package com.exam.seating.model;

/**
 * Plain Java object representing an exam hall.
 * No database annotations — purely in-memory.
 */
public class Hall {

    private String hallName;
    private int    rows;
    private int    seatsPerRow;

    public Hall() {}

    public Hall(String hallName, int rows, int seatsPerRow) {
        this.hallName    = hallName;
        this.rows        = rows;
        this.seatsPerRow = seatsPerRow;
    }

    /** Total seat capacity of this hall */
    public int getCapacity() { return rows * seatsPerRow; }

    public String getHallName()    { return hallName; }
    public void   setHallName(String hallName)  { this.hallName = hallName; }

    public int  getRows()          { return rows; }
    public void setRows(int rows)  { this.rows = rows; }

    public int  getSeatsPerRow()   { return seatsPerRow; }
    public void setSeatsPerRow(int seatsPerRow) { this.seatsPerRow = seatsPerRow; }

    @Override
    public String toString() {
        return hallName + " [" + rows + "x" + seatsPerRow + " cap=" + getCapacity() + "]";
    }
}
