<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload CSV Files — Exam Seating System</title>
    <meta name="description" content="Upload hall configuration and student class CSV files">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css">
    <style>
        .upload-zone {
            border: 2px dashed var(--border);
            border-radius: var(--radius);
            padding: 1.5rem;
            background: var(--bg-card);
            transition: border-color .2s, background .2s;
            margin-bottom: 1rem;
        }
        .upload-zone:hover { border-color: var(--primary); background: var(--primary-light); }
        .upload-zone label { font-weight: 600; font-size: .9rem; color: var(--text); display:block; margin-bottom: .5rem; }
        .upload-zone input[type=file] { width:100%; font-size:.85rem; color:var(--text-mid); }

        /* Class files dynamic grid */
        .class-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(260px, 1fr));
            gap: .85rem;
            margin-bottom: 1rem;
        }
        .class-file-card {
            border: 1.5px dashed var(--border);
            border-radius: var(--radius-sm);
            padding: 1rem;
            background: var(--bg-card);
            position: relative;
            transition: border-color .2s;
        }
        .class-file-card:hover { border-color: var(--primary); }
        .class-file-card label {
            font-weight: 600; font-size: .82rem;
            color: var(--primary); display: block; margin-bottom: .5rem;
        }
        .class-file-card input[type=file] { width:100%; font-size:.8rem; }
        .remove-btn {
            position: absolute; top: 8px; right: 8px;
            background: #fee2e2; border: none; border-radius: 50%;
            width: 22px; height: 22px; cursor: pointer;
            font-size: .75rem; color: #dc2626; line-height: 22px; text-align: center;
            display: none;
        }
        .class-file-card:hover .remove-btn { display: block; }

        .add-class-btn {
            border: 2px dashed #94a3b8; border-radius: var(--radius-sm);
            background: transparent; color: var(--text-mid);
            padding: 1rem; width: 100%; cursor: pointer;
            font-size: .85rem; font-weight: 600;
            transition: border-color .2s, color .2s, background .2s;
            display: flex; align-items: center; justify-content: center; gap: 8px;
        }
        .add-class-btn:hover {
            border-color: var(--primary); color: var(--primary);
            background: var(--primary-light);
        }
        .class-counter {
            font-size: .8rem; color: var(--text-light); margin-bottom: .75rem;
        }
        .class-counter strong { color: var(--primary); }
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
            <p>Upload hall configuration + up to <strong>20 class files</strong>. Each class CSV becomes part of the seating pool.</p>
        </div>

        <%-- Success messages --%>
        <c:if test="${not empty uploadMessages}">
            <div class="alert alert-success fade-in">
                <span>✅</span>
                <div>
                    <strong>Upload Successful!</strong>
                    <c:forEach var="msg" items="${uploadMessages}">
                        <div>${msg}</div>
                    </c:forEach>
                </div>
            </div>
        </c:if>

        <%-- Errors --%>
        <c:if test="${not empty uploadErrors}">
            <div class="alert alert-error fade-in">
                <span>❌</span>
                <div>
                    <strong>Upload Issues:</strong>
                    <c:forEach var="err" items="${uploadErrors}">
                        <div>${err}</div>
                    </c:forEach>
                </div>
            </div>
        </c:if>

        <%-- CSV format info --%>
        <div class="alert" style="background:#eff6ff;border-color:#bfdbfe;color:#1e40af;margin-bottom:1.5rem;" >
            <span>ℹ️</span>
            <div>
                <strong>Expected CSV Formats:</strong><br>
                <code>halls.csv:</code> hall_name, rows, seats_per_row<br>
                <code>class CSV:</code> roll_no, name, branch
            </div>
        </div>

        <form action="${pageContext.request.contextPath}/upload"
              method="post"
              enctype="multipart/form-data"
              id="uploadForm">

            <%-- ---- Hall configuration ---- --%>
            <div class="card fade-in" style="margin-bottom:1.5rem;">
                <h3 style="font-size:1rem;font-weight:700;margin-bottom:1rem;">🏛️ Hall Configuration</h3>
                <div class="upload-zone">
                    <label for="hallsFile">halls.csv <span style="color:#dc2626;">*</span></label>
                    <input type="file" id="hallsFile" name="hallsFile" accept=".csv" required>
                </div>
                <div style="font-size:.75rem;color:var(--text-light);margin-top:.25rem;">
                    Format: <code>hall_name,rows,seats_per_row</code> &nbsp;|&nbsp;
                    Example: <code>Hall-A,5,10</code>
                </div>
            </div>

            <%-- ---- Class files (dynamic, 1–20) ---- --%>
            <div class="card fade-in" style="animation-delay:.1s;margin-bottom:1.5rem;">
                <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:.75rem;">
                    <h3 style="font-size:1rem;font-weight:700;margin:0;">👨‍🎓 Class Files</h3>
                    <span class="class-counter">
                        <strong id="classCount">1</strong> / 20 classes added
                    </span>
                </div>

                <div id="classGrid" class="class-grid">
                    <%-- First class card (cannot be removed) --%>
                    <div class="class-file-card" id="classCard-0">
                        <label for="classFile-0">Class 1 <span style="color:#dc2626;">*</span></label>
                        <input type="file" id="classFile-0" name="classFiles" accept=".csv" required>
                    </div>
                </div>

                <%-- Add class button --%>
                <button type="button" id="addClassBtn" class="add-class-btn" onclick="addClassCard()">
                    <span style="font-size:1.2rem;">➕</span>
                    Add Another Class File <span id="remainingCount">(19 remaining)</span>
                </button>

                <div style="font-size:.75rem;color:var(--text-light);margin-top:.75rem;">
                    Format: <code>roll_no,name,branch</code> &nbsp;|&nbsp;
                    Example: <code>CSE001,Arun Kumar,CSE</code> &nbsp;|&nbsp;
                    Supports any branch name (CSE, ECE, MECH, IT, CIVIL, etc.)
                </div>
            </div>

            <%-- Submit --%>
            <button type="submit" class="btn btn-primary" id="uploadSubmitBtn"
                    style="width:100%;padding:1rem;font-size:1rem;font-weight:700;border-radius:var(--radius);">
                📤 Upload & Parse All Files
            </button>
        </form>

        <%-- Sample data hint --%>
        <div class="card fade-in" style="animation-delay:.2s;margin-top:1.5rem;background:#f8fafc;">
            <h4 style="font-size:.9rem;font-weight:700;margin-bottom:.75rem;">📁 Sample Data Available</h4>
            <p style="font-size:.82rem;color:var(--text-mid);">
                Ready-to-use sample files are in
                <code>e:\Project\java\seating-system\sample-data\</code>
            </p>
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:.5rem;margin-top:.75rem;">
                <div style="background:#fff;border:1px solid var(--border);border-radius:6px;padding:.6rem;font-size:.78rem;">
                    📄 <strong>halls.csv</strong><br>Hall-A (3×4), Hall-B (2×4)
                </div>
                <div style="background:#fff;border:1px solid var(--border);border-radius:6px;padding:.6rem;font-size:.78rem;">
                    📄 <strong>classA.csv</strong><br>4 CSE students
                </div>
                <div style="background:#fff;border:1px solid var(--border);border-radius:6px;padding:.6rem;font-size:.78rem;">
                    📄 <strong>classB.csv</strong><br>3 ECE students
                </div>
                <div style="background:#fff;border:1px solid var(--border);border-radius:6px;padding:.6rem;font-size:.78rem;">
                    📄 <strong>classC.csv</strong><br>3 MECH students
                </div>
            </div>
        </div>

    </main>
</div>

<footer class="footer">
    Automated Examination Hall Seating Arrangement System &mdash; No Database Required
</footer>

<script src="${pageContext.request.contextPath}/static/js/app.js"></script>
<script>
    const MAX_CLASSES = 20;
    let classCount = 1;

    function addClassCard() {
        if (classCount >= MAX_CLASSES) return;

        classCount++;
        const grid = document.getElementById('classGrid');
        const idx  = classCount - 1;

        const card = document.createElement('div');
        card.className = 'class-file-card';
        card.id = 'classCard-' + idx;
        card.innerHTML = `
            <button type="button" class="remove-btn" onclick="removeClassCard(${idx})" title="Remove">✕</button>
            <label for="classFile-${idx}">Class ${classCount}</label>
            <input type="file" id="classFile-${idx}" name="classFiles" accept=".csv">
        `;
        grid.appendChild(card);
        updateCounter();
    }

    function removeClassCard(idx) {
        const card = document.getElementById('classCard-' + idx);
        if (card) card.remove();
        classCount--;
        // Re-number remaining labels
        const cards = document.querySelectorAll('.class-file-card');
        cards.forEach((c, i) => {
            const label = c.querySelector('label');
            if (label) label.textContent = 'Class ' + (i + 1) + (i === 0 ? ' *' : '');
        });
        updateCounter();
    }

    function updateCounter() {
        document.getElementById('classCount').textContent    = classCount;
        document.getElementById('remainingCount').textContent = '(' + (MAX_CLASSES - classCount) + ' remaining)';
        document.getElementById('addClassBtn').disabled = classCount >= MAX_CLASSES;
        document.getElementById('addClassBtn').style.opacity = classCount >= MAX_CLASSES ? '0.4' : '1';
    }
</script>
</body>
</html>
