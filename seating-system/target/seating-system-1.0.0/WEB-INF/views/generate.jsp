<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Generate Seating — Exam Seating System</title>
    <meta name="description" content="Generate conflict-free examination hall seating using greedy round-robin algorithm">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css">
    <style>
        /* Download panel shown after generation */
        .download-panel {
            background: linear-gradient(135deg, #0f172a 0%, #1e3a5f 100%);
            border-radius: var(--radius);
            padding: 2rem;
            margin-top: 1.5rem;
            color: #fff;
            box-shadow: var(--shadow-lg);
        }
        .download-panel h3 {
            font-size: 1.1rem;
            font-weight: 700;
            margin-bottom: 1.25rem;
            display: flex;
            align-items: center;
            gap: 8px;
            color: #fff;
        }
        .dl-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
        }
        .dl-tile {
            background: rgba(255,255,255,0.10);
            border: 1px solid rgba(255,255,255,0.18);
            border-radius: 12px;
            padding: 1.25rem;
            text-align: center;
            text-decoration: none;
            color: #fff;
            transition: background .2s, transform .2s;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 8px;
        }
        .dl-tile:hover {
            background: rgba(255,255,255,0.20);
            transform: translateY(-3px);
        }
        .dl-tile .dt-icon { font-size: 2rem; }
        .dl-tile .dt-name { font-size: .88rem; font-weight: 700; }
        .dl-tile .dt-desc { font-size: .72rem; opacity: .75; }
        .dl-tile .dt-btn  {
            margin-top: 8px;
            background: rgba(255,255,255,0.20);
            border: 1px solid rgba(255,255,255,0.35);
            border-radius: 6px;
            padding: 6px 14px;
            font-size: .78rem;
            font-weight: 700;
            color: #fff;
            cursor: pointer;
        }
        /* Result summary banner */
        .result-banner {
            background: linear-gradient(90deg, #10b981, #059669);
            color: #fff;
            border-radius: var(--radius);
            padding: 1.5rem 2rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 1rem;
            box-shadow: 0 4px 20px rgba(16,185,129,.3);
        }
        .result-banner.fail {
            background: linear-gradient(90deg, #ef4444, #dc2626);
            box-shadow: 0 4px 20px rgba(239,68,68,.3);
        }
        .rb-left { display: flex; align-items: center; gap: 1rem; }
        .rb-icon { font-size: 2.5rem; }
        .rb-title { font-size: 1.1rem; font-weight: 800; }
        .rb-sub   { font-size: .82rem; opacity: .9; margin-top: 2px; }
        .rb-stats {
            display: flex; gap: 1.5rem; flex-wrap: wrap;
        }
        .rb-stat { text-align: center; }
        .rb-stat .val { font-size: 1.4rem; font-weight: 800; line-height: 1; }
        .rb-stat .lbl { font-size: .7rem; opacity: .8; margin-top: 2px; }
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
        <a href="${pageContext.request.contextPath}/generate"class="nav-link active">Generate</a>
        <a href="${pageContext.request.contextPath}/view"    class="nav-link">View Seating</a>
        <a href="${pageContext.request.contextPath}/reports" class="nav-link">Reports</a>
        <a href="${pageContext.request.contextPath}/summary" class="nav-link">Summary</a>
    </div>
</nav>

<div class="layout">
    <aside class="sidebar">
        <a href="${pageContext.request.contextPath}/"         class="sidebar-item"><span class="icon">🏠</span> Dashboard</a>
        <a href="${pageContext.request.contextPath}/upload"   class="sidebar-item"><span class="icon">📤</span> Upload CSV</a>
        <a href="${pageContext.request.contextPath}/generate" class="sidebar-item active"><span class="icon">⚙️</span> Generate Seating</a>
        <a href="${pageContext.request.contextPath}/view"     class="sidebar-item"><span class="icon">🪑</span> View Hall Layout</a>
        <a href="${pageContext.request.contextPath}/reports"  class="sidebar-item"><span class="icon">📄</span> Reports</a>
        <a href="${pageContext.request.contextPath}/summary"  class="sidebar-item"><span class="icon">📊</span> Summary</a>
    </aside>

    <main class="main-content">
        <div class="page-header fade-in">
            <h2>⚙️ Generate Seating Arrangement</h2>
            <p>3-step O(N) algorithm: Greedy Sort → Round-Robin Interleave → Grid Fill → Validate → Download</p>
        </div>

        <!-- Error -->
        <c:if test="${not empty generateError}">
            <div class="alert alert-error fade-in">
                <span>❌</span>
                <div><strong>Error:</strong> ${generateError}</div>
            </div>
        </c:if>

        <!-- ============================================================
             SUCCESS — Result banner + Download panel (shown prominently)
             ============================================================ -->
        <c:if test="${generateSuccess}">

            <!-- Result banner -->
            <div class="result-banner ${validationStatus == 'PASS' ? '' : 'fail'} fade-in">
                <div class="rb-left">
                    <div class="rb-icon">${validationStatus == 'PASS' ? '✅' : '⚠️'}</div>
                    <div>
                        <div class="rb-title">Seating Generated — ${validationStatus}</div>
                        <div class="rb-sub">
                            ${validationStatus == 'PASS'
                                ? 'No adjacent same-branch violations found.'
                                : violationCount + ' violation(s) detected. Download violations report for details.'}
                        </div>
                    </div>
                </div>
                <div class="rb-stats">
                    <div class="rb-stat">
                        <div class="val">${totalStudents}</div>
                        <div class="lbl">Students Seated</div>
                    </div>
                    <div class="rb-stat">
                        <div class="val">${violationCount}</div>
                        <div class="lbl">Violations</div>
                    </div>
                </div>
            </div>

            <!-- ============================================================
                 DOWNLOAD PANEL — RIGHT HERE, prominently after generation
                 ============================================================ -->
            <div class="download-panel fade-in" style="animation-delay:.1s;">
                <h3>⬇️ Download Your Reports</h3>
                <div class="dl-grid">

                    <!-- Seating CSVs (one per hall) -->
                    <%
                        com.exam.seating.model.SeatingResult res =
                            (com.exam.seating.model.SeatingResult) session.getAttribute("seatingResult");
                        if (res != null && res.getHalls() != null) {
                            int idx = 0;
                            for (com.exam.seating.model.Hall h : res.getHalls()) {
                                // Only show halls that have at least one student
                                com.exam.seating.model.Student[][] grid = res.getHallGrids().get(h.getHallName());
                                boolean hasStudents = false;
                                if (grid != null) {
                                    outer:
                                    for (com.exam.seating.model.Student[] row : grid)
                                        for (com.exam.seating.model.Student s : row)
                                            if (s != null) { hasStudents = true; break outer; }
                                }
                                if (!hasStudents) continue;
                    %>
                    <a href="${pageContext.request.contextPath}/download/seating?hall=<%= h.getHallName() %>"
                       class="dl-tile" id="dl-seat-<%= idx %>">
                        <div class="dt-icon">📊</div>
                        <div class="dt-name"><%= h.getHallName() %> Seating</div>
                        <div class="dt-desc">Seat,Row,Col,RollNo,Name,Branch</div>
                        <div class="dt-btn">⬇ Download CSV</div>
                    </a>
                    <%
                                idx++;
                            }
                        }
                    %>

                    <!-- Violations report -->
                    <a href="${pageContext.request.contextPath}/download/violations"
                       class="dl-tile" id="dl-violations">
                        <div class="dt-icon">⚠️</div>
                        <div class="dt-name">Violations Report</div>
                        <div class="dt-desc">violations.txt — PASS/FAIL + conflict list</div>
                        <div class="dt-btn">⬇ Download TXT</div>
                    </a>

                    <!-- Summary report -->
                    <a href="${pageContext.request.contextPath}/download/summary"
                       class="dl-tile" id="dl-summary">
                        <div class="dt-icon">📋</div>
                        <div class="dt-name">Summary Report</div>
                        <div class="dt-desc">summary.txt — students, capacity, status</div>
                        <div class="dt-btn">⬇ Download TXT</div>
                    </a>
                </div>

                <!-- Extra navigation -->
                <div style="margin-top:1.25rem;display:flex;gap:.75rem;flex-wrap:wrap;">
                    <a href="${pageContext.request.contextPath}/view"
                       class="btn btn-outline"
                       style="background:rgba(255,255,255,.12);border-color:rgba(255,255,255,.35);color:#fff;"
                       id="btn-view-grid">
                        🪑 View Seating Grid
                    </a>
                    <a href="${pageContext.request.contextPath}/summary"
                       class="btn btn-outline"
                       style="background:rgba(255,255,255,.12);border-color:rgba(255,255,255,.35);color:#fff;"
                       id="btn-view-summary">
                        📊 Summary Stats
                    </a>
                </div>
            </div>
        </c:if>

        <!-- Pre-check stats -->
        <div class="card-grid fade-in" style="animation-delay:.1s;margin-top:1.5rem;margin-bottom:1.5rem;">
            <div class="stat-card">
                <div class="stat-icon blue">👨‍🎓</div>
                <div class="stat-info">
                    <div class="stat-value">${studentCount}</div>
                    <div class="stat-label">Students in Memory</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green">🏛️</div>
                <div class="stat-info">
                    <div class="stat-value">${hallCount}</div>
                    <div class="stat-label">Halls in Memory</div>
                </div>
            </div>
        </div>

        <!-- Warning if no data -->
        <c:if test="${studentCount == 0 || hallCount == 0}">
            <div class="alert alert-warning fade-in">
                <span>⚠️</span>
                <div>
                    <strong>No data uploaded yet!</strong>
                    <a href="${pageContext.request.contextPath}/upload"
                       style="color:var(--primary);font-weight:600;"> Upload CSV files first →</a>
                </div>
            </div>
        </c:if>

        <!-- Algorithm steps -->
        <div class="card fade-in" style="animation-delay:.15s; margin-bottom:1.5rem;">
            <h3 style="font-size:1rem;font-weight:700;margin-bottom:1.25rem;">🔬 Algorithm Steps (PPT-exact)</h3>
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:1rem;">
                <div style="text-align:center;padding:1rem;background:var(--primary-light);border-radius:var(--radius-sm);">
                    <div style="font-size:1.4rem;margin-bottom:6px;">📊</div>
                    <div style="font-weight:700;font-size:.85rem;color:var(--primary);">Step 1</div>
                    <div style="font-size:.78rem;color:var(--text-mid);margin-top:4px;">Greedy Sort</div>
                    <div style="font-size:.7rem;color:var(--text-light);margin-top:3px;">Largest pool first</div>
                </div>
                <div style="text-align:center;padding:1rem;background:#d1fae5;border-radius:var(--radius-sm);">
                    <div style="font-size:1.4rem;margin-bottom:6px;">🔄</div>
                    <div style="font-weight:700;font-size:.85rem;color:#059669;">Step 2</div>
                    <div style="font-size:.78rem;color:var(--text-mid);margin-top:4px;">Round-Robin</div>
                    <div style="font-size:.7rem;color:var(--text-light);margin-top:3px;">CSE→ECE→MECH→...</div>
                </div>
                <div style="text-align:center;padding:1rem;background:#fef3c7;border-radius:var(--radius-sm);">
                    <div style="font-size:1.4rem;margin-bottom:6px;">🪑</div>
                    <div style="font-weight:700;font-size:.85rem;color:#d97706;">Step 3</div>
                    <div style="font-size:.78rem;color:var(--text-mid);margin-top:4px;">Fill Grid</div>
                    <div style="font-size:.7rem;color:var(--text-light);margin-top:3px;">Student[][] O(N)</div>
                </div>
                <div style="text-align:center;padding:1rem;background:#fee2e2;border-radius:var(--radius-sm);">
                    <div style="font-size:1.4rem;margin-bottom:6px;">✅</div>
                    <div style="font-weight:700;font-size:.85rem;color:#dc2626;">Validate</div>
                    <div style="font-size:.78rem;color:var(--text-mid);margin-top:4px;">Conflict Check</div>
                    <div style="font-size:.7rem;color:var(--text-light);margin-top:3px;">Adjacent branch check</div>
                </div>
                <div style="text-align:center;padding:1rem;background:#ede9fe;border-radius:var(--radius-sm);">
                    <div style="font-size:1.4rem;margin-bottom:6px;">⬇️</div>
                    <div style="font-weight:700;font-size:.85rem;color:#7c3aed;">Download</div>
                    <div style="font-size:.78rem;color:var(--text-mid);margin-top:4px;">CSV + TXT Reports</div>
                    <div style="font-size:.7rem;color:var(--text-light);margin-top:3px;">Seating + Summary</div>
                </div>
            </div>
        </div>

        <!-- Generate Button -->
        <form action="${pageContext.request.contextPath}/generate"
              method="post"
              id="generateForm">
            <button type="submit"
                    class="generate-cta"
                    id="generateBtn"
                    ${studentCount == 0 || hallCount == 0 ? 'disabled style="opacity:.5;cursor:not-allowed;"' : ''}>
                <span class="gc-icon">🚀</span>
                <span>Generate Seating Arrangement</span>
                <span class="gc-sub">Greedy Sort + Round-Robin + Conflict Validation + Report Files</span>
            </button>
        </form>
    </main>
</div>

<footer class="footer">
    Automated Examination Hall Seating Arrangement System &mdash; Built with Spring Boot + JSP &mdash; No Database Required
</footer>

<script src="${pageContext.request.contextPath}/static/js/app.js"></script>
</body>
</html>
