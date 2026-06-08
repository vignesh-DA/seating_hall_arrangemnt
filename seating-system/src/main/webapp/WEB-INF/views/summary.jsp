<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Summary — Exam Seating System</title>
    <meta name="description" content="Seating arrangement summary: students seated, violations, halls used, capacity percentage">
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
        <a href="${pageContext.request.contextPath}/reports" class="nav-link">Reports</a>
        <a href="${pageContext.request.contextPath}/summary" class="nav-link active">Summary</a>
    </div>
</nav>

<div class="layout">
    <aside class="sidebar">
        <a href="${pageContext.request.contextPath}/"         class="sidebar-item"><span class="icon">🏠</span> Dashboard</a>
        <a href="${pageContext.request.contextPath}/upload"   class="sidebar-item"><span class="icon">📤</span> Upload CSV</a>
        <a href="${pageContext.request.contextPath}/generate" class="sidebar-item"><span class="icon">⚙️</span> Generate Seating</a>
        <a href="${pageContext.request.contextPath}/view"     class="sidebar-item"><span class="icon">🪑</span> View Hall Layout</a>
        <a href="${pageContext.request.contextPath}/reports"  class="sidebar-item"><span class="icon">📄</span> Reports</a>
        <a href="${pageContext.request.contextPath}/summary"  class="sidebar-item active"><span class="icon">📊</span> Summary</a>
    </aside>

    <main class="main-content">
        <div class="page-header fade-in">
            <h2>📊 Summary Statistics</h2>
            <p>Complete overview of the seating arrangement results</p>
        </div>

        <c:choose>
            <c:when test="${result == null}">
                <div class="alert alert-warning fade-in">
                    <span>⚠️</span>
                    <div>
                        No data available.
                        <a href="${pageContext.request.contextPath}/generate" style="color:var(--primary);font-weight:600;">
                            Generate seating first.
                        </a>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <!-- Summary Grid -->
                <div class="summary-grid fade-in" style="animation-delay:.05s;">
                    <div class="summary-item">
                        <div class="si-val">${result.totalStudents}</div>
                        <div class="si-lbl">Total Students</div>
                    </div>
                    <div class="summary-item">
                        <div class="si-val">${result.totalCapacity}</div>
                        <div class="si-lbl">Total Capacity</div>
                    </div>
                    <div class="summary-item">
                        <div class="si-val">${result.totalStudents - result.overflow}</div>
                        <div class="si-lbl">Students Seated</div>
                    </div>
                    <div class="summary-item">
                        <div class="si-val" style="color:${result.overflow > 0 ? 'var(--danger)' : 'var(--success)'};">
                            ${result.overflow}
                        </div>
                        <div class="si-lbl">Overflow (Unseated)</div>
                    </div>
                    <div class="summary-item">
                        <div class="si-val">${result.emptySeats}</div>
                        <div class="si-lbl">Empty Seats</div>
                    </div>
                    <div class="summary-item">
                        <div class="si-val">${fn:length(result.halls)}</div>
                        <div class="si-lbl">Halls Used</div>
                    </div>
                    <div class="summary-item">
                        <div class="si-val">${result.capacityPercent}%</div>
                        <div class="si-lbl">Capacity Used</div>
                    </div>
                    <div class="summary-item">
                        <div class="si-val ${fn:length(result.violations) > 0 ? '' : ''}"
                             style="color:${fn:length(result.violations) > 0 ? 'var(--danger)' : 'var(--success)'};">
                            ${fn:length(result.violations)}
                        </div>
                        <div class="si-lbl">Violations</div>
                    </div>
                </div>

                <!-- Validation Status Card -->
                <div class="card fade-in" style="animation-delay:.1s;margin-bottom:1.5rem;text-align:center;padding:2rem;">
                    <div style="font-size:3rem;margin-bottom:12px;">
                        ${result.validationStatus == 'PASS' ? '✅' : '❌'}
                    </div>
                    <div style="font-size:1.5rem;font-weight:800;color:${result.validationStatus == 'PASS' ? 'var(--success)' : 'var(--danger)'};">
                        Validation ${result.validationStatus}
                    </div>
                    <div style="font-size:.88rem;color:var(--text-mid);margin-top:8px;">
                        ${result.validationStatus == 'PASS'
                            ? 'All adjacency constraints satisfied. No same-branch students are seated next to each other.'
                            : 'Some adjacency constraints were violated. Download the violations report for details.'}
                    </div>
                </div>

                <!-- Capacity Progress Bar -->
                <div class="card fade-in" style="animation-delay:.15s;margin-bottom:1.5rem;">
                    <h3 style="font-size:1rem;font-weight:700;margin-bottom:1rem;">Capacity Utilization</h3>
                    <div style="display:flex;justify-content:space-between;margin-bottom:6px;font-size:.82rem;">
                        <span>${result.totalStudents - result.overflow} students seated</span>
                        <span>${result.capacityPercent}%</span>
                    </div>
                    <div class="progress-bar-wrap">
                        <div class="progress-bar-fill" style="width:${result.capacityPercent}%;"></div>
                    </div>
                </div>

                <!-- Hall-wise breakdown -->
                <div class="card fade-in" style="animation-delay:.2s;margin-bottom:1.5rem;">
                    <h3 style="font-size:1rem;font-weight:700;margin-bottom:1rem;">🏛️ Hall-wise Breakdown</h3>
                    <c:forEach var="hall" items="${result.halls}" varStatus="status">
                        <div style="margin-bottom:14px;">
                            <div style="display:flex;justify-content:space-between;margin-bottom:4px;">
                                <span style="font-size:.88rem;font-weight:600;">${hall.hallName}</span>
                                <span style="font-size:.82rem;color:var(--text-mid);">
                                    ${hall.rows} rows × ${hall.seatsPerRow} seats = ${hall.capacity} capacity
                                </span>
                            </div>
                            <div class="progress-bar-wrap">
                                <div class="progress-bar-fill"
                                     style="width:${result.capacityPercent}%;background:hsl(${210 + status.index * 40},80%,50%);"></div>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <!-- Download actions -->
                <div style="display:flex;gap:1rem;flex-wrap:wrap;" class="fade-in" style="animation-delay:.25s;">
                    <a href="${pageContext.request.contextPath}/download/summary"    class="btn btn-primary"  id="dl-sum">⬇ Download Summary</a>
                    <a href="${pageContext.request.contextPath}/download/violations" class="btn btn-danger"   id="dl-vio">⬇ Download Violations</a>
                    <a href="${pageContext.request.contextPath}/view"                class="btn btn-outline"  id="go-view">🪑 View Seating Grid</a>
                </div>
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
