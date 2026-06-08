<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports — Exam Seating System</title>
    <meta name="description" content="Download seating CSV, violations log, and summary report">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css">
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
        <a href="${pageContext.request.contextPath}/view"    class="nav-link">View Seating</a>
        <a href="${pageContext.request.contextPath}/reports" class="nav-link active">Reports</a>
        <a href="${pageContext.request.contextPath}/summary" class="nav-link">Summary</a>
    </div>
</nav>

<div class="layout">
    <aside class="sidebar">
        <a href="${pageContext.request.contextPath}/"         class="sidebar-item"><span class="icon">🏠</span> Dashboard</a>
        <a href="${pageContext.request.contextPath}/upload"   class="sidebar-item"><span class="icon">📤</span> Upload CSV</a>
        <a href="${pageContext.request.contextPath}/generate" class="sidebar-item"><span class="icon">⚙️</span> Generate Seating</a>
        <a href="${pageContext.request.contextPath}/view"     class="sidebar-item"><span class="icon">🪑</span> View Hall Layout</a>
        <a href="${pageContext.request.contextPath}/reports"  class="sidebar-item active"><span class="icon">📄</span> Reports</a>
        <a href="${pageContext.request.contextPath}/summary"  class="sidebar-item"><span class="icon">📊</span> Summary</a>
    </aside>

    <main class="main-content">
        <div class="page-header fade-in">
            <h2>📄 Reports &amp; Downloads</h2>
            <p>Download the generated seating reports in CSV and text format</p>
        </div>

        <c:choose>
            <c:when test="${!hasReports}">
                <div class="alert alert-warning fade-in">
                    <span>⚠️</span>
                    <div>
                        No reports available yet.
                        <a href="${pageContext.request.contextPath}/generate" style="color:var(--primary);font-weight:600;">
                            Generate seating first.
                        </a>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <!-- Validation Banner -->
                <div class="card fade-in" style="margin-bottom:1.5rem;display:flex;align-items:center;gap:1rem;flex-wrap:wrap;">
                    <div>
                        <span style="font-size:.82rem;color:var(--text-mid);font-weight:600;">VALIDATION:</span>
                        <span class="badge ${result.validationStatus == 'PASS' ? 'badge-pass' : 'badge-fail'}" style="margin-left:8px;">
                            ${result.validationStatus}
                        </span>
                    </div>
                    <div style="font-size:.82rem;color:var(--text-mid);">
                        Violations: <strong>${fn:length(result.violations)}</strong>
                        &nbsp;|&nbsp; Capacity Used: <strong>${result.capacityPercent}%</strong>
                    </div>
                </div>

                <!-- Download Cards -->
                <div class="download-grid fade-in" style="animation-delay:.1s;">

                    <!-- Seating CSV per hall -->
                    <c:forEach var="hall" items="${result.halls}" varStatus="status">
                        <div class="download-card" id="dc-seating-${status.index}">
                            <div class="dc-icon">📊</div>
                            <h4>${hall.hallName} Seating</h4>
                            <p>Complete seating arrangement CSV for ${hall.hallName} (${hall.rows}×${hall.seatsPerRow})</p>
                            <a href="${pageContext.request.contextPath}/download/seating?hall=${hall.hallName}"
                               class="btn btn-primary"
                               id="dl-btn-seating-${status.index}">
                                ⬇ Download CSV
                            </a>
                        </div>
                    </c:forEach>

                    <!-- Violations -->
                    <div class="download-card" id="dc-violations">
                        <div class="dc-icon">⚠️</div>
                        <h4>Violations Report</h4>
                        <p>List of all adjacency conflicts, overflow issues, and constraint violations</p>
                        <a href="${pageContext.request.contextPath}/download/violations"
                           class="btn btn-danger"
                           id="dl-btn-violations">
                            ⬇ Download violations.txt
                        </a>
                    </div>

                    <!-- Summary -->
                    <div class="download-card" id="dc-summary">
                        <div class="dc-icon">📋</div>
                        <h4>Summary Report</h4>
                        <p>Aggregate statistics: students seated, halls used, capacity %, violations count</p>
                        <a href="${pageContext.request.contextPath}/download/summary"
                           class="btn btn-success"
                           id="dl-btn-summary">
                            ⬇ Download summary.txt
                        </a>
                    </div>
                </div>

                <!-- Violations List Preview -->
                <c:if test="${not empty result.violations}">
                    <div class="card fade-in" style="margin-top:2rem;animation-delay:.2s;">
                        <h3 style="font-size:1rem;font-weight:700;margin-bottom:1rem;color:var(--danger);">
                            ⚠️ Violation Preview (${fn:length(result.violations)} found)
                        </h3>
                        <ul class="violation-list">
                            <c:forEach var="v" items="${result.violations}" end="9">
                                <li>${v}</li>
                            </c:forEach>
                        </ul>
                        <c:if test="${fn:length(result.violations) > 10}">
                            <p style="font-size:.82rem;color:var(--text-mid);margin-top:8px;">
                                ...and ${fn:length(result.violations) - 10} more. Download the full report above.
                            </p>
                        </c:if>
                    </div>
                </c:if>
                <c:if test="${empty result.violations}">
                    <div class="alert alert-success fade-in" style="margin-top:1rem;animation-delay:.2s;">
                        <span>✅</span>
                        <strong>No violations — all seats comply with branch separation constraints!</strong>
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
