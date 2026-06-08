<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload CSV — Exam Seating System</title>
    <meta name="description" content="Upload hall configuration and student CSV files for seating arrangement generation">
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
        <a href="${pageContext.request.contextPath}/"        class="nav-link">Dashboard</a>
        <a href="${pageContext.request.contextPath}/upload"  class="nav-link active">Upload</a>
        <a href="${pageContext.request.contextPath}/generate"class="nav-link">Generate</a>
        <a href="${pageContext.request.contextPath}/view"    class="nav-link">View Seating</a>
        <a href="${pageContext.request.contextPath}/reports" class="nav-link">Reports</a>
        <a href="${pageContext.request.contextPath}/summary" class="nav-link">Summary</a>
    </div>
</nav>

<div class="layout">
    <aside class="sidebar">
        <a href="${pageContext.request.contextPath}/"         class="sidebar-item"><span class="icon">🏠</span> Dashboard</a>
        <a href="${pageContext.request.contextPath}/upload"   class="sidebar-item active"><span class="icon">📤</span> Upload CSV</a>
        <a href="${pageContext.request.contextPath}/generate" class="sidebar-item"><span class="icon">⚙️</span> Generate Seating</a>
        <a href="${pageContext.request.contextPath}/view"     class="sidebar-item"><span class="icon">🪑</span> View Hall Layout</a>
        <a href="${pageContext.request.contextPath}/reports"  class="sidebar-item"><span class="icon">📄</span> Reports</a>
        <a href="${pageContext.request.contextPath}/summary"  class="sidebar-item"><span class="icon">📊</span> Summary</a>
    </aside>

    <main class="main-content">
        <div class="page-header fade-in">
            <h2>📤 Upload CSV Files</h2>
            <p>Upload the hall configuration and student data files to start the seating process</p>
        </div>

        <!-- Flash messages -->
        <c:if test="${not empty uploadMessages}">
            <div class="alert alert-success fade-in" id="msg-success">
                <span>✅</span>
                <div>
                    <strong>Upload Successful!</strong>
                    <c:forEach var="msg" items="${uploadMessages}">
                        <div style="margin-top:4px;font-size:.82rem;">${msg}</div>
                    </c:forEach>
                </div>
            </div>
        </c:if>

        <c:if test="${not empty uploadErrors}">
            <div class="alert alert-error fade-in" id="msg-error">
                <span>❌</span>
                <div>
                    <strong>Errors detected during parsing:</strong>
                    <c:forEach var="err" items="${uploadErrors}">
                        <div style="margin-top:4px;font-size:.82rem;">${err}</div>
                    </c:forEach>
                </div>
            </div>
        </c:if>

        <!-- CSV format info -->
        <div class="alert alert-info fade-in" style="animation-delay:.05s;margin-bottom:1.5rem;">
            <span>ℹ️</span>
            <div>
                <strong>Expected CSV Formats:</strong>
                <div style="margin-top:6px;font-size:.82rem;display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:8px;">
                    <div><strong>halls.csv:</strong> hall_name, rows, seats_per_row</div>
                    <div><strong>classA/B/C.csv:</strong> roll_no, name, branch</div>
                </div>
            </div>
        </div>

        <!-- Upload Form -->
        <form action="${pageContext.request.contextPath}/upload"
              method="post"
              enctype="multipart/form-data"
              id="uploadForm">

            <div class="card fade-in" style="animation-delay:.1s; margin-bottom:1.5rem;">
                <h3 style="font-size:1rem;font-weight:700;margin-bottom:1.25rem;color:var(--text-dark);">
                    🏛️ Hall Configuration
                </h3>
                <div class="upload-grid" style="grid-template-columns:1fr;">
                    <div class="upload-card" id="hallCard">
                        <input type="file" name="hallsFile" accept=".csv" id="hallsFile" required>
                        <div class="uc-icon">🏛️</div>
                        <h4>halls.csv</h4>
                        <p>Hall name, rows, seats per row</p>
                        <div class="file-name" id="hallFileName">Click or drag to upload</div>
                    </div>
                </div>
            </div>

            <div class="card fade-in" style="animation-delay:.15s; margin-bottom:1.5rem;">
                <h3 style="font-size:1rem;font-weight:700;margin-bottom:1.25rem;color:var(--text-dark);">
                    👨‍🎓 Student Data Files
                </h3>
                <div class="upload-grid">
                    <div class="upload-card" id="classACard">
                        <input type="file" name="classAFile" accept=".csv" id="classAFile" required>
                        <div class="uc-icon">📋</div>
                        <h4>classA.csv</h4>
                        <p>Roll No, Name, Branch</p>
                        <div class="file-name" id="classAFileName">Click or drag to upload</div>
                    </div>
                    <div class="upload-card" id="classBCard">
                        <input type="file" name="classBFile" accept=".csv" id="classBFile" required>
                        <div class="uc-icon">📋</div>
                        <h4>classB.csv</h4>
                        <p>Roll No, Name, Branch</p>
                        <div class="file-name" id="classBFileName">Click or drag to upload</div>
                    </div>
                    <div class="upload-card" id="classCCard">
                        <input type="file" name="classCFile" accept=".csv" id="classCFile" required>
                        <div class="uc-icon">📋</div>
                        <h4>classC.csv</h4>
                        <p>Roll No, Name, Branch</p>
                        <div class="file-name" id="classCFileName">Click or drag to upload</div>
                    </div>
                </div>
            </div>

            <div class="fade-in" style="animation-delay:.2s;">
                <button type="submit" class="btn btn-primary btn-lg" id="uploadBtn">
                    📤 Upload & Parse Files
                </button>
            </div>
        </form>

        <!-- Sample CSV format reference -->
        <div class="card fade-in" style="animation-delay:.25s; margin-top:2rem;">
            <h3 style="font-size:.95rem;font-weight:700;margin-bottom:1rem;">📎 Sample CSV Formats</h3>
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:1.25rem;">
                <div>
                    <div style="font-size:.82rem;font-weight:600;color:var(--primary);margin-bottom:6px;">halls.csv</div>
                    <pre style="background:#f8fafc;border:1px solid var(--border);border-radius:8px;padding:12px;font-size:.78rem;overflow-x:auto;">hall_name,rows,seats_per_row
Hall-A,5,10
Hall-B,4,8
Hall-C,6,12</pre>
                </div>
                <div>
                    <div style="font-size:.82rem;font-weight:600;color:var(--primary);margin-bottom:6px;">classA.csv (CSE)</div>
                    <pre style="background:#f8fafc;border:1px solid var(--border);border-radius:8px;padding:12px;font-size:.78rem;overflow-x:auto;">roll_no,name,branch
CSE001,Arun Kumar,CSE
CSE002,Priya Nair,CSE
CSE003,Ravi Shankar,CSE</pre>
                </div>
                <div>
                    <div style="font-size:.82rem;font-weight:600;color:var(--primary);margin-bottom:6px;">classB.csv (ECE)</div>
                    <pre style="background:#f8fafc;border:1px solid var(--border);border-radius:8px;padding:12px;font-size:.78rem;overflow-x:auto;">roll_no,name,branch
ECE001,Meena Kumari,ECE
ECE002,Suresh Babu,ECE
ECE003,Deepa Raj,ECE</pre>
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
