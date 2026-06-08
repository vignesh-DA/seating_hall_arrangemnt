<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard — Exam Seating System</title>
    <meta name="description" content="Automated Examination Hall Seating Arrangement System — College Admin Dashboard">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css">
</head>
<body>

<!-- TOPBAR -->
<nav class="topbar">
    <a href="${pageContext.request.contextPath}/" class="topbar-brand">
        <div class="brand-icon">🎓</div>
        <div>
            <h1>ExamSeat Pro</h1>
            <span>Seating Arrangement System</span>
        </div>
    </a>
    <div class="topbar-nav">
        <a href="${pageContext.request.contextPath}/"        class="nav-link active">Dashboard</a>
        <a href="${pageContext.request.contextPath}/upload"  class="nav-link">Upload</a>
        <a href="${pageContext.request.contextPath}/generate"class="nav-link">Generate</a>
        <a href="${pageContext.request.contextPath}/view"    class="nav-link">View Seating</a>
        <a href="${pageContext.request.contextPath}/reports" class="nav-link">Reports</a>
        <a href="${pageContext.request.contextPath}/summary" class="nav-link">Summary</a>
    </div>
</nav>

<div class="layout">
    <!-- SIDEBAR -->
    <aside class="sidebar">
        <a href="${pageContext.request.contextPath}/"         class="sidebar-item active"><span class="icon">🏠</span> Dashboard</a>
        <a href="${pageContext.request.contextPath}/upload"   class="sidebar-item"><span class="icon">📤</span> Upload CSV</a>
        <a href="${pageContext.request.contextPath}/generate" class="sidebar-item"><span class="icon">⚙️</span> Generate Seating</a>
        <a href="${pageContext.request.contextPath}/view"     class="sidebar-item"><span class="icon">🪑</span> View Hall Layout</a>
        <a href="${pageContext.request.contextPath}/reports"  class="sidebar-item"><span class="icon">📄</span> Reports</a>
        <a href="${pageContext.request.contextPath}/summary"  class="sidebar-item"><span class="icon">📊</span> Summary</a>
    </aside>

    <!-- MAIN -->
    <main class="main-content">
        <div class="page-header fade-in">
            <h2>Dashboard</h2>
            <p>Welcome to the Automated Examination Hall Seating Arrangement System</p>
        </div>

        <!-- Pipeline flow indicator -->
        <div class="pipeline fade-in" style="animation-delay:.1s">
            <div class="pipeline-step ${studentCount > 0 ? 'done' : ''}">
                <div class="step-num">${studentCount > 0 ? '✓' : '1'}</div>
                <div class="step-label">Upload CSV</div>
            </div>
            <div class="pipeline-step">
                <div class="step-num">2</div>
                <div class="step-label">Generate Seating</div>
            </div>
            <div class="pipeline-step">
                <div class="step-num">3</div>
                <div class="step-label">Validate</div>
            </div>
            <div class="pipeline-step">
                <div class="step-num">4</div>
                <div class="step-label">Reports</div>
            </div>
            <div class="pipeline-step">
                <div class="step-num">5</div>
                <div class="step-label">Download</div>
            </div>
        </div>

        <!-- Stats Row -->
        <div class="card-grid fade-in" style="animation-delay:.15s; margin-bottom:1.5rem;">
            <div class="stat-card">
                <div class="stat-icon blue">👨‍🎓</div>
                <div class="stat-info">
                    <div class="stat-value">${studentCount}</div>
                    <div class="stat-label">Students Uploaded</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon green">🏛️</div>
                <div class="stat-info">
                    <div class="stat-value">${hallCount}</div>
                    <div class="stat-label">Halls Configured</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon orange">⏱️</div>
                <div class="stat-info">
                    <div class="stat-value">O(N)</div>
                    <div class="stat-label">Algorithm Complexity</div>
                </div>
            </div>
            <div class="stat-card">
                <div class="stat-icon red">🔒</div>
                <div class="stat-info">
                    <div class="stat-value">0</div>
                    <div class="stat-label">Manual Conflicts</div>
                </div>
            </div>
        </div>

        <!-- Quick Action Cards -->
        <h3 style="font-size:1rem;font-weight:700;margin-bottom:1rem;color:var(--text-mid);">QUICK ACTIONS</h3>
        <div class="card-grid fade-in" style="animation-delay:.2s;">
            <a href="${pageContext.request.contextPath}/upload" class="action-card" id="action-upload">
                <div class="ac-icon">📤</div>
                <h3>Upload CSV Files</h3>
                <p>Upload halls.csv and student class files to begin</p>
            </a>
            <a href="${pageContext.request.contextPath}/generate" class="action-card" id="action-generate"
               style="background:linear-gradient(135deg,#059669 0%,#10b981 100%);">
                <div class="ac-icon">⚙️</div>
                <h3>Generate Seating</h3>
                <p>Run the greedy round-robin seating algorithm</p>
            </a>
            <a href="${pageContext.request.contextPath}/view" class="action-card" id="action-view"
               style="background:linear-gradient(135deg,#7c3aed 0%,#a78bfa 100%);">
                <div class="ac-icon">🪑</div>
                <h3>View Hall Layout</h3>
                <p>Inspect the seating grid with branch color-coding</p>
            </a>
            <a href="${pageContext.request.contextPath}/reports" class="action-card" id="action-reports"
               style="background:linear-gradient(135deg,#d97706 0%,#f59e0b 100%);">
                <div class="ac-icon">📄</div>
                <h3>Download Reports</h3>
                <p>Get seating CSV, violations log, and summary</p>
            </a>
        </div>

        <!-- About section -->
        <div class="card fade-in" style="animation-delay:.3s; margin-top:1.5rem;">
            <h3 style="font-size:1rem;font-weight:700;margin-bottom:1rem;">How It Works</h3>
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:1rem;">
                <div>
                    <div style="font-weight:700;color:var(--primary);margin-bottom:4px;">① Greedy Sort</div>
                    <p style="font-size:.82rem;color:var(--text-mid);">Branches are sorted by student count (largest first) to minimize overflow.</p>
                </div>
                <div>
                    <div style="font-weight:700;color:var(--primary);margin-bottom:4px;">② Round-Robin</div>
                    <p style="font-size:.82rem;color:var(--text-mid);">CSE → ECE → MECH → CSE → ECE → MECH interleaving ensures separation.</p>
                </div>
                <div>
                    <div style="font-weight:700;color:var(--primary);margin-bottom:4px;">③ Grid Fill</div>
                    <p style="font-size:.82rem;color:var(--text-mid);">Students fill seats row by row with adjacency enforcement across multi-halls.</p>
                </div>
                <div>
                    <div style="font-weight:700;color:var(--primary);margin-bottom:4px;">④ Validate</div>
                    <p style="font-size:.82rem;color:var(--text-mid);">Conflict checker scans every adjacent pair and reports PASS/FAIL.</p>
                </div>
            </div>
        </div>
    </main>
</div>

<footer class="footer">
    Automated Examination Hall Seating Arrangement System &mdash; Built with Spring Boot + JSP + MySQL
</footer>

<script src="${pageContext.request.contextPath}/static/js/app.js"></script>
</body>
</html>
