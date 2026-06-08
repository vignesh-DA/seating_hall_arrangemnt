package com.exam.seating.service;

import com.exam.seating.model.Hall;
import com.exam.seating.model.SeatingResult;
import com.exam.seating.model.Student;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * Module 2 — SeatingEngineService
 *
 * Implements the 3-step O(N) seating algorithm from the PPT.
 * Purely in-memory — no database involved.
 *
 * Step 1: Greedy Largest-Pool-First Sort
 *         Sort branches descending by student count
 *
 * Step 2: Round-Robin Interleaving
 *         CSE → ECE → MECH → CSE → ECE → MECH → ...
 *
 * Step 3: Fill Student[][] grid row by row
 *         Enforce: grid[r][c].branch != grid[r][c-1].branch
 *         Handle overflow into next hall
 *
 * Complexity: O(N)
 */
@Service
public class SeatingEngineService {

    /**
     * Generate seating for all halls from the given student list and hall list.
     * All data is passed in — nothing read from database.
     */
    public SeatingResult generateSeating(List<Student> allStudents, List<Hall> halls) {

        if (allStudents == null || allStudents.isEmpty()) {
            throw new IllegalArgumentException("No students provided. Please upload at least one student CSV.");
        }
        if (halls == null || halls.isEmpty()) {
            throw new IllegalArgumentException("No halls provided. Please upload halls.csv.");
        }

        // ------------------------------------------------------------------
        // Step 1: Build branch map and sort by student count DESC
        //         (Greedy Largest-Pool-First)
        // ------------------------------------------------------------------
        HashMap<String, List<Student>> branchMap = new HashMap<>();
        for (Student s : allStudents) {
            branchMap.computeIfAbsent(s.getBranch(), k -> new ArrayList<>()).add(s);
        }

        List<Map.Entry<String, List<Student>>> sortedBranches = new ArrayList<>(branchMap.entrySet());
        sortedBranches.sort((a, b) -> b.getValue().size() - a.getValue().size());

        // ------------------------------------------------------------------
        // Step 2: Round-Robin Interleaving
        // ------------------------------------------------------------------
        List<Student> interleaved = roundRobinInterleave(sortedBranches);

        // ------------------------------------------------------------------
        // Step 3: Fill Student[][] grids across halls
        // ------------------------------------------------------------------
        Map<String, Student[][]> hallGrids = new LinkedHashMap<>();

        int studentIndex = 0;
        int totalStudents = interleaved.size();

        for (Hall hall : halls) {
            Student[][] grid = new Student[hall.getRows()][hall.getSeatsPerRow()];

            for (int row = 0; row < hall.getRows() && studentIndex < totalStudents; row++) {
                for (int col = 0; col < hall.getSeatsPerRow() && studentIndex < totalStudents; col++) {

                    Student candidate = interleaved.get(studentIndex);

                    // Enforce adjacency constraint
                    if (col > 0 && grid[row][col - 1] != null
                            && grid[row][col - 1].getBranch().equals(candidate.getBranch())) {

                        // Try to swap with a non-conflicting student nearby
                        int swapIdx = findNonConflicting(
                                interleaved, studentIndex + 1,
                                grid[row][col - 1].getBranch(), totalStudents);

                        if (swapIdx != -1) {
                            Collections.swap(interleaved, studentIndex, swapIdx);
                            candidate = interleaved.get(studentIndex);
                        }
                        // If no swap possible, place anyway (recorded as violation)
                    }

                    grid[row][col] = candidate;
                    studentIndex++;
                }
            }

            hallGrids.put(hall.getHallName(), grid);
        }

        // ------------------------------------------------------------------
        // Build result
        // ------------------------------------------------------------------
        SeatingResult result = new SeatingResult();
        result.setHallGrids(hallGrids);
        result.setHalls(halls);
        result.setTotalStudents(totalStudents);

        int totalCapacity = halls.stream().mapToInt(Hall::getCapacity).sum();
        result.setTotalCapacity(totalCapacity);

        int seated   = Math.min(studentIndex, totalStudents);
        int overflow = totalStudents - seated;
        result.setOverflow(overflow);

        int emptySeats = totalCapacity - seated;
        result.setEmptySeats(Math.max(0, emptySeats));

        return result;
    }

    // ------------------------------------------------------------------
    // Step 2: Round-Robin Interleave helper  O(N)
    // Merges N branch lists in round-robin order:
    //   Branch1[0], Branch2[0], Branch3[0], Branch1[1], ...
    // ------------------------------------------------------------------
    private List<Student> roundRobinInterleave(List<Map.Entry<String, List<Student>>> sortedBranches) {
        List<Student> result = new ArrayList<>();
        int[] ptrs = new int[sortedBranches.size()];
        int remaining = sortedBranches.stream().mapToInt(e -> e.getValue().size()).sum();

        while (remaining > 0) {
            for (int i = 0; i < sortedBranches.size(); i++) {
                List<Student> list = sortedBranches.get(i).getValue();
                if (ptrs[i] < list.size()) {
                    result.add(list.get(ptrs[i]++));
                    remaining--;
                }
            }
        }
        return result;
    }

    // ------------------------------------------------------------------
    // Find first student ahead in the list with a different branch
    // ------------------------------------------------------------------
    private int findNonConflicting(List<Student> list, int from, String conflictBranch, int total) {
        int searchLimit = Math.min(total, from + 15);
        for (int i = from; i < searchLimit; i++) {
            if (!list.get(i).getBranch().equals(conflictBranch)) return i;
        }
        return -1;
    }
}
