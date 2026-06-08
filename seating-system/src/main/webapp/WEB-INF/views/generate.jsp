<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Generate Seating — Exam Seating System</title>
    <meta name="description" content="Generate conflict-free examination hall seating using greedy round-robin algorithm">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css">
    <style>
        .download-panel {
            background: linear-gradient(135deg, #0f172a 0%, #1e3a5f 100%);
            border-radius: var(--radius);
            padding: 2rem;
            margin-top: 1.5rem;
            color: #fff;
            box-shadow: var(--shadow-lg);
        }
        .download-panel h3 {
            font-size: 1.1rem; font-weight: 700;
            margin-bottom: 1.25rem;
            display: flex; align-items: center; gap: 8px; color: #fff;
        }
        .dl-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(190px, 1fr));
            gap: 1rem;
        }
        .dl-tile {
            background: rgba(255,255,255,0.10);
            border: 1px solid rgba(255,255,255,0.18);
            border-radius: 12px; padding: 1.25rem;
            text-align: center; text-decoration: none; color: #fff;
            transition: background .2s, transform .2s;
            display: flex; flex-direction: column; align-items: center; gap: 8px;
        }
        .dl-tile:hover { background: rgba(255,255,255,0.22); transform: translateY(-3px); }
        .dl-tile .dt-icon { font-size: 2rem; }
        .dl-tile .dt-name { font-size: .9rem; font-weight: 700; }
        .dl-tile .dt-desc { font-size: .72rem; opacity: .75; }
        .dl-tile .dt-btn {
            margin-top: 8px; background: rgba(255,255,255,0.2);
            border: 1px solid rgba(255,255,255,0.35); border-radius: 6px;
            padding: 7px 16px; font-size: .8rem; font-weight: 700; color: #fff; width: 100%;
        }
        .dl-tile-zip {
            background: linear-gradient(135deg, rgba(16,185,129,0.3), rgba(5,150,105,0.4));
            border: 2px solid rgba(16,185,129,0.5);
        }
        .result-banner {
            border-radius: var(--radius); padding: 1.5rem 2rem;
            display: flex; align-items: center;
            justify-content: space-between; flex-wrap: wrap; gap: 1rem;
        }
        .rb-pass { background: linear-gradient(90deg,#10b981,#059669); box-shadow:0 4px 20px rgba(16,185,129,.3); }
        .rb-fail { background: linear-gradient(90deg,#f59e0b,#d97706); box-shadow:0 4px 20px rgba(245,158,11,.3); }
        .rb-left { display:flex; align-items:center; gap:1rem; color:#fff; }
        .rb-icon { font-size:2.5rem; }
        .rb-title { font-size:1.1rem; font-weight:800; color:#fff; }
        .rb-sub   { font-size:.82rem; opacity:.9; margin-top:2px; color:#fff; }
        .rb-stats { display:flex; gap:1.5rem; flex-wrap:wrap; }
        .rb-stat  { text-align:center; color:#fff; }
        .rb-stat .val { font-size:1.4rem; font-weight:800; line-height:1; }
        .rb-stat .lbl { font-size:.7rem; opacity:.8; margin-top:2px; }
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
            <p>Greedy Sort → Round-Robin → Grid Fill → Validate → Download</p>
        </div>

        <%-- Error from POST redirect --%>
        <c:if test="${not empty generateError}">
            <div class="alert alert-error fade-in">
                <span>❌</span>
                <div><strong>Error:</strong> ${generateError}</div>
            </div>
        </c:if>

        <%-- ================================================================
             RESULT PANEL — shown whenever a result exists in session
             (persists across page refreshes, not just on flash attribute)
             ================================================================ --%>
        <c:if test="${result != null}">
            <div class="result-banner ${result.validationStatus == 'PASS' ? 'rb-pass' : 'rb-fail'} fade-in">
                <div class="rb-left">
                    <div class="rb-icon">
                        <c:choose>
                            <c:when test="${result.validationStatus == 'PASS'}">✅</c:when>
                            <c:otherwise>⚠️</c:otherwise>
                        </c:choose>
                    </div>
                    <div>
                        <div class="rb-title">Seating Generated — ${result.validationStatus}</div>
                        <div class="rb-sub">
                            <c:choose>
                                <c:when test="${result.validationStatus == 'PASS'}">
                                    No adjacent same-branch violations found.
                                </c:when>
                                <c:otherwise>
                                    ${fn:length(result.violations)} violation(s) found. Download violations report for details.
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                <div class="rb-stats">
                    <div class="rb-stat">
                        <div class="val">${result.totalStudents}</div>
                        <div class="lbl">Students Seated</div>
                    </div>
                    <div class="rb-stat">
                        <div class="val">${fn:length(result.violations)}</div>
                        <div class="lbl">Violations</div>
                    </div>
                    <div class="rb-stat">
                        <div class="val">${result.capacityPercent}%</div>
                        <div class="lbl">Capacity Used</div>
                    </div>
                </div>
            </div>

            <%-- ============================================================
                 DOWNLOAD PANEL — right here, immediately after generation
                 ============================================================ --%>
            <div class="download-panel fade-in" style="animation-delay:.1s;">
                <h3>⬇️ Download Your Reports</h3>
                <div class="dl-grid">

                    <%-- One download tile per hall (only halls with students) --%>
                    <c:forEach var="hall" items="${result.halls}" varStatus="st">
                        <a href="${pageContext.request.contextPath}/download/seating?hall=${hall.hallName}"
                           class="dl-tile"
                           id="dl-hall-${st.index}">
                            <div class="dt-icon">📊</div>
                            <div class="dt-name">${hall.hallName} Seating</div>
                            <div class="dt-desc">Seat, Row, Col, RollNo, Name, Branch</div>
                            <div class="dt-btn">⬇ Download CSV</div>
                        </a>
                    </c:forEach>

                    <%-- Violations --%>
                    <a href="${pageContext.request.contextPath}/download/violations"
                       class="dl-tile" id="dl-violations">
                        <div class="dt-icon">
                            <c:choose>
                                <c:when test="${result.validationStatus == 'PASS'}">✅</c:when>
                                <c:otherwise>⚠️</c:otherwise>
                            </c:choose>
                        </div>
                        <div class="dt-name">Violations Report</div>
                        <div class="dt-desc">violations.txt — PASS / FAIL + conflict list</div>
                        <div class="dt-btn">⬇ Download TXT</div>
                    </a>

                    <%-- Summary --%>
                    <a href="${pageContext.request.contextPath}/download/summary"
                       class="dl-tile" id="dl-summary">
                        <div class="dt-icon">📋</div>
                        <div class="dt-name">Summary Report</div>
                        <div class="dt-desc">summary.txt — students, capacity, status</div>
                        <div class="dt-btn">⬇ Download TXT</div>
                    </a>

                    <%-- ZIP — all files at once --%>
                    <a href="${pageContext.request.contextPath}/download/all"
                       class="dl-tile dl-tile-zip" id="dl-all">
                        <div class="dt-icon">🗜️</div>
                        <div class="dt-name">Download ALL</div>
                        <div class="dt-desc">seating_reports.zip — everything in one click</div>
                        <div class="dt-btn">⬇ Download ZIP</div>
                    </a>
                </div>

                <div style="margin-top:1.25rem;display:flex;gap:.75rem;flex-wrap:wrap;">
                    <a href="${pageContext.request.contextPath}/view"
                       style="background:rgba(255,255,255,.12);border:1px solid rgba(255,255,255,.35);
                              color:#fff;padding:9px 18px;border-radius:8px;text-decoration:none;
                              font-size:.875rem;font-weight:600;" id="btn-view-grid">
                        🪑 View Seating Grid
                    </a>
                    <a href="${pageContext.request.contextPath}/summary"
                       style="background:rgba(255,255,255,.12);border:1px solid rgba(255,255,255,.35);
                              color:#fff;padding:9px 18px;border-radius:8px;text-decoration:none;
                              font-size:.875rem;font-weight:600;" id="btn-summary">
                        📊 Summary Stats
                    </a>
                </div>
            </div>
        </c:if>

        <%-- Pre-check stats --%>
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

        <c:if test="${studentCount == 0 || hallCount == 0}">
            <div class="alert alert-warning fade-in">
                <span>⚠️</span>
                <div>
                    <strong>No data uploaded yet.</strong>
                    <a href="${pageContext.request.contextPath}/upload"
                       style="color:var(--primary);font-weight:600;"> Upload CSV files first →</a>
                </div>
            </div>
        </c:if>

        <%-- Algorithm Steps --%>
        <div class="card fade-in" style="animation-delay:.15s;margin-bottom:1.5rem;">
            <h3 style="font-size:1rem;font-weight:700;margin-bottom:1.25rem;">🔬 Algorithm (PPT-exact, O(N))</h3>
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:1rem;">
                <div style="text-align:center;padding:.9rem;background:var(--primary-light);border-radius:var(--radius-sm);">
                    <div style="font-size:1.3rem;margin-bottom:5px;">📊</div>
                    <div style="font-weight:700;font-size:.82rem;color:var(--primary);">Step 1</div>
                    <div style="font-size:.75rem;color:var(--text-mid);margin-top:3px;">Greedy Sort</div>
                    <div style="font-size:.68rem;color:var(--text-light);margin-top:2px;">Largest pool first</div>
                </div>
                <div style="text-align:center;padding:.9rem;background:#d1fae5;border-radius:var(--radius-sm);">
                    <div style="font-size:1.3rem;margin-bottom:5px;">🔄</div>
                    <div style="font-weight:700;font-size:.82rem;color:#059669;">Step 2</div>
                    <div style="font-size:.75rem;color:var(--text-mid);margin-top:3px;">Round-Robin</div>
                    <div style="font-size:.68rem;color:var(--text-light);margin-top:2px;">CSE→ECE→MECH→...</div>
                </div>
                <div style="text-align:center;padding:.9rem;background:#fef3c7;border-radius:var(--radius-sm);">
                    <div style="font-size:1.3rem;margin-bottom:5px;">🪑</div>
                    <div style="font-weight:700;font-size:.82rem;color:#d97706;">Step 3</div>
                    <div style="font-size:.75rem;color:var(--text-mid);margin-top:3px;">Fill Grid</div>
                    <div style="font-size:.68rem;color:var(--text-light);margin-top:2px;">Student[][] O(N)</div>
                </div>
                <div style="text-align:center;padding:.9rem;background:#fee2e2;border-radius:var(--radius-sm);">
                    <div style="font-size:1.3rem;margin-bottom:5px;">✅</div>
                    <div style="font-weight:700;font-size:.82rem;color:#dc2626;">Validate</div>
                    <div style="font-size:.75rem;color:var(--text-mid);margin-top:3px;">Conflict Check</div>
                    <div style="font-size:.68rem;color:var(--text-light);margin-top:2px;">Adjacent branch</div>
                </div>
                <div style="text-align:center;padding:.9rem;background:#ede9fe;border-radius:var(--radius-sm);">
                    <div style="font-size:1.3rem;margin-bottom:5px;">⬇️</div>
                    <div style="font-weight:700;font-size:.82rem;color:#7c3aed;">Download</div>
                    <div style="font-size:.75rem;color:var(--text-mid);margin-top:3px;">CSV + ZIP</div>
                    <div style="font-size:.68rem;color:var(--text-light);margin-top:2px;">Instant download</div>
                </div>
            </div>
        </div>

        <%-- Generate Button --%>
        <form action="${pageContext.request.contextPath}/generate" method="post" id="generateForm">
            <button type="submit" class="generate-cta" id="generateBtn"
                    ${studentCount == 0 || hallCount == 0 ? 'disabled style="opacity:.5;cursor:not-allowed;"' : ''}>
                <span class="gc-icon">🚀</span>
                <span>Generate Seating Arrangement</span>
                <span class="gc-sub">Click to run the full pipeline and get your download files</span>
            </button>
        </form>

    </main>
</div>

<footer class="footer">
    Automated Examination Hall Seating Arrangement System &mdash; No Database Required
</footer>
<script src="${pageContext.request.contextPath}/static/js/app.js"></script>
</body>
</html>
