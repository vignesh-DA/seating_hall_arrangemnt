<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Seating — Exam Seating System</title>
    <meta name="description" content="View examination hall seating layout with branch color-coding">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css">
    <style>
        /* Tab styles for hall switching */
        .hall-tabs {
            display: flex; gap: 6px; margin-bottom: 1.25rem; flex-wrap: wrap;
        }
        .hall-tab {
            padding: 8px 18px;
            border: 2px solid var(--border);
            border-radius: 8px;
            background: var(--surface);
            cursor: pointer;
            font-size: .875rem;
            font-weight: 600;
            color: var(--text-mid);
            transition: all .2s;
        }
        .hall-tab.active, .hall-tab:hover {
            border-color: var(--primary);
            background: var(--primary-light);
            color: var(--primary);
        }
        .hall-panel { display: none; }
        .hall-panel.active { display: block; }

        /* Branch legend */
        .legend {
            display: flex; gap: 10px; flex-wrap: wrap;
            margin-bottom: 1rem;
        }
        .legend-item {
            display: flex; align-items: center; gap: 6px;
            font-size: .78rem; font-weight: 600;
        }
        .legend-dot {
            width: 12px; height: 12px; border-radius: 3px;
        }
    </style>
</head>
<body>

<nav class="topbar">
    <a href="${pageContext.request.contextPath}/" class="topbar-brand">
        <div class="brand-icon">🎓</div>
        <div><h1>ExamSeat Pro</h1><span>Seating Arrangement System</span></div>
    </a>
    <div class="topbar-nav">
        <a href="${pageContext.request.contextPath}/"        class="nav-link">Dashboard</a>
        <a href="${pageContext.request.contextPath}/upload"  class="nav-link">Upload</a>
        <a href="${pageContext.request.contextPath}/generate"class="nav-link">Generate</a>
        <a href="${pageContext.request.contextPath}/view"    class="nav-link active">View Seating</a>
        <a href="${pageContext.request.contextPath}/reports" class="nav-link">Reports</a>
        <a href="${pageContext.request.contextPath}/summary" class="nav-link">Summary</a>
    </div>
</nav>

<div class="layout">
    <aside class="sidebar">
        <a href="${pageContext.request.contextPath}/"         class="sidebar-item"><span class="icon">🏠</span> Dashboard</a>
        <a href="${pageContext.request.contextPath}/upload"   class="sidebar-item"><span class="icon">📤</span> Upload CSV</a>
        <a href="${pageContext.request.contextPath}/generate" class="sidebar-item"><span class="icon">⚙️</span> Generate Seating</a>
        <a href="${pageContext.request.contextPath}/view"     class="sidebar-item active"><span class="icon">🪑</span> View Hall Layout</a>
        <a href="${pageContext.request.contextPath}/reports"  class="sidebar-item"><span class="icon">📄</span> Reports</a>
        <a href="${pageContext.request.contextPath}/summary"  class="sidebar-item"><span class="icon">📊</span> Summary</a>
    </aside>

    <main class="main-content">
        <div class="page-header fade-in">
            <h2>🪑 Hall Seating Layout</h2>
            <p>Color-coded seating grid — each branch has a distinct color</p>
        </div>

        <c:choose>
            <c:when test="${noData}">
                <div class="alert alert-warning fade-in">
                    <span>⚠️</span>
                    <div>
                        No seating data available. 
                        <a href="${pageContext.request.contextPath}/generate" style="color:var(--primary);font-weight:600;">Generate seating first.</a>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <!-- Validation Status Badge -->
                <div class="card fade-in" style="margin-bottom:1.25rem;display:flex;align-items:center;gap:1rem;flex-wrap:wrap;">
                    <div>
                        <span style="font-size:.82rem;color:var(--text-mid);font-weight:600;">VALIDATION STATUS:</span>
                        <span class="badge ${result.validationStatus == 'PASS' ? 'badge-pass' : 'badge-fail'}"
                              style="margin-left:8px;">${result.validationStatus}</span>
                    </div>
                    <div style="font-size:.82rem;color:var(--text-mid);">
                        Students: <strong>${result.totalStudents}</strong> &nbsp;|&nbsp;
                        Capacity: <strong>${result.totalCapacity}</strong> &nbsp;|&nbsp;
                        Filled: <strong>${result.capacityPercent}%</strong> &nbsp;|&nbsp;
                        Violations: <strong>${fn:length(result.violations)}</strong>
                    </div>
                    <div style="margin-left:auto;display:flex;gap:8px;flex-wrap:wrap;">
                        <a href="${pageContext.request.contextPath}/reports" class="btn btn-primary" id="btn-goto-reports">📄 Reports</a>
                        <a href="${pageContext.request.contextPath}/download/violations" class="btn btn-outline" id="btn-dl-violations">⬇ Violations</a>
                    </div>
                </div>

                <!-- Branch Legend -->
                <div class="legend fade-in" style="animation-delay:.1s;">
                    <div class="legend-item">
                        <div class="legend-dot" style="background:#dbeafe;border:1px solid #93c5fd;"></div>CSE
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background:#d1fae5;border:1px solid #6ee7b7;"></div>ECE
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background:#fef3c7;border:1px solid #fde68a;"></div>MECH
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background:#ede9fe;border:1px solid #c4b5fd;"></div>IT
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background:#fce7f3;border:1px solid #f9a8d4;"></div>CIVIL
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background:#f1f5f9;border:1px solid #cbd5e1;"></div>OTHER
                    </div>
                    <div class="legend-item">
                        <div class="legend-dot" style="background:#fff;border:2px dashed #cbd5e1;"></div>EMPTY
                    </div>
                </div>

                <!-- Hall Tabs -->
                <div class="hall-tabs fade-in" style="animation-delay:.12s;" id="hallTabsContainer">
                    <c:forEach var="hall" items="${halls}" varStatus="status">
                        <button class="hall-tab" data-hall="${hall.hallName}" id="tab-${fn:replace(hall.hallName,' ','-')}">
                            🏛️ ${hall.hallName}
                            <span style="font-size:.7rem;font-weight:400;opacity:.7;">
                                (${hall.rows}×${hall.seatsPerRow})
                            </span>
                        </button>
                    </c:forEach>
                </div>

                <!-- Hall Panels -->
                <c:forEach var="hall" items="${halls}">
                    <div class="hall-panel fade-in" id="panel-${hall.hallName}">
                        <div class="hall-section">
                            <h3>🏛️ ${hall.hallName}
                                <span style="font-size:.78rem;font-weight:400;color:var(--text-mid);">
                                    — ${hall.rows} rows × ${hall.seatsPerRow} seats
                                </span>
                            </h3>

                            <div class="seating-wrapper">
                                <table class="seating-table">
                                    <thead>
                                        <tr>
                                            <th>Row</th>
                                            <c:forEach begin="1" end="${hall.seatsPerRow}" var="col">
                                                <th>Seat ${col}</th>
                                            </c:forEach>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <%-- Render seating grid using scriptlet for 2D array access --%>
                                        <%
                                            com.exam.seating.model.SeatingResult res =
                                                (com.exam.seating.model.SeatingResult) session.getAttribute("seatingResult");
                                            if (res != null) {
                                                java.util.List<com.exam.seating.model.Hall> hallList = res.getHalls();
                                                java.util.Map<String, com.exam.seating.model.Student[][]> grids = res.getHallGrids();

                                                // Get current hall name from loop (set by JSTL)
                                                String currentHall = (String) pageContext.getAttribute("hall") != null
                                                    ? ((com.exam.seating.model.Hall) pageContext.getAttribute("hall")).getHallName()
                                                    : "";

                                                com.exam.seating.model.Student[][] grid = grids.get(currentHall);
                                                if (grid != null) {
                                                    for (int r = 0; r < grid.length; r++) {
                                                        out.println("<tr>");
                                                        out.println("<td class='row-label'>Row " + (r+1) + "</td>");
                                                        for (int c = 0; c < grid[r].length; c++) {
                                                            com.exam.seating.model.Student s = grid[r][c];
                                                            if (s != null) {
                                                                String branch = s.getBranch();
                                                                String branchClass = "branch-OTHER";
                                                                if      ("CSE".equals(branch))  branchClass = "branch-CSE";
                                                                else if ("ECE".equals(branch))  branchClass = "branch-ECE";
                                                                else if ("MECH".equals(branch)) branchClass = "branch-MECH";
                                                                else if ("IT".equals(branch))   branchClass = "branch-IT";
                                                                else if ("CIVIL".equals(branch))branchClass = "branch-CIVIL";

                                                                out.println("<td>");
                                                                out.println("<div class='seat-cell'>");
                                                                out.println("<span class='roll'>" + s.getRollNo() + "</span>");
                                                                out.println("<span class='branch-tag " + branchClass + "'>" + branch + "</span>");
                                                                out.println("<span class='sname'>" + s.getName() + "</span>");
                                                                out.println("</div>");
                                                                out.println("</td>");
                                                            } else {
                                                                out.println("<td><span class='seat-empty'>— Empty —</span></td>");
                                                            }
                                                        }
                                                        out.println("</tr>");
                                                    }
                                                }
                                            }
                                        %>
                                    </tbody>
                                </table>
                            </div>

                            <!-- Per-hall download -->
                            <div style="margin-top:1rem;">
                                <a href="${pageContext.request.contextPath}/download/seating?hall=${hall.hallName}"
                                   class="btn btn-success"
                                   id="dl-seating-${fn:replace(hall.hallName,' ','-')}">
                                    ⬇ Download ${hall.hallName} Seating CSV
                                </a>
                            </div>
                        </div>
                    </div>
                </c:forEach>

                <!-- Violations Panel -->
                <c:if test="${not empty result.violations}">
                    <div class="card fade-in" style="margin-top:1.5rem;animation-delay:.2s;">
                        <h3 style="font-size:1rem;font-weight:700;margin-bottom:1rem;color:var(--danger);">
                            ⚠️ Violations (${fn:length(result.violations)})
                        </h3>
                        <ul class="violation-list">
                            <c:forEach var="v" items="${result.violations}">
                                <li>${v}</li>
                            </c:forEach>
                        </ul>
                    </div>
                </c:if>
                <c:if test="${empty result.violations}">
                    <div class="alert alert-success fade-in" style="margin-top:1rem;animation-delay:.2s;">
                        <span>✅</span>
                        <strong>No violations! All adjacency constraints satisfied.</strong>
                    </div>
                </c:if>
            </c:otherwise>
        </c:choose>
    </main>
</div>

<footer class="footer">
    Automated Examination Hall Seating Arrangement System &mdash; Built with Spring Boot + JSP + MySQL
</footer>

<script src="${pageContext.request.contextPath}/static/js/app.js"></script>
</body>
</html>
