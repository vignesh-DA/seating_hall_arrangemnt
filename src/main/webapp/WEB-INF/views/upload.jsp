<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload CSV Files — Exam Seating System</title>
    <meta name="description" content="Upload hall configuration and up to 20 student class CSV files">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/static/css/style.css">
    <style>
        .upload-zone {
            border: 2px dashed var(--border);
            border-radius: var(--radius);
            padding: 1.25rem;
            background: var(--bg-card);
            transition: border-color .2s, background .2s;
        }
        .upload-zone:hover { border-color: var(--primary); background: var(--primary-light); }
        .upload-zone label { font-weight: 600; font-size: .88rem; color: var(--text); display:block; margin-bottom:.4rem; }
        .upload-zone input[type=file] { width:100%; font-size:.82rem; }

        .class-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
            gap: .75rem;
            margin-bottom: .75rem;
        }
        .class-card {
            border: 1.5px dashed var(--border);
            border-radius: var(--radius-sm);
            padding: .9rem;
            background: var(--bg-card);
            position: relative;
            transition: border-color .2s;
        }
        .class-card:hover { border-color: var(--primary); }
        .class-card label {
            font-weight: 700; font-size: .8rem;
            color: var(--primary); display:block; margin-bottom:.4rem;
        }
        .class-card input[type=file] { width:100%; font-size:.78rem; }
        .rm-btn {
            position: absolute; top:7px; right:7px;
            background:#fee2e2; border:none; border-radius:50%;
            width:20px; height:20px; line-height:20px; text-align:center;
            cursor:pointer; font-size:.72rem; color:#dc2626;
            display:none;
        }
        .class-card:hover .rm-btn { display:block; }

        .add-btn {
            border: 2px dashed #94a3b8; border-radius: var(--radius-sm);
            background: transparent; width:100%; padding:.85rem;
            color: var(--text-mid); cursor:pointer; font-size:.85rem; font-weight:600;
            display:flex; align-items:center; justify-content:center; gap:8px;
            transition: border-color .2s, color .2s, background .2s;
        }
        .add-btn:hover {
            border-color: var(--primary); color:var(--primary);
            background:var(--primary-light);
        }
        .add-btn:disabled { opacity:.4; cursor:not-allowed; }
        .counter-badge {
            display:inline-block; background:var(--primary);
            color:#fff; border-radius:20px; padding:2px 10px;
            font-size:.75rem; font-weight:700;
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
            <p>Upload halls config + <strong>1 to 20 class files</strong>. Each class CSV adds students to the seating pool.</p>
        </div>

        <%-- Success --%>
        <c:if test="${not empty uploadMessages}">
            <div class="alert alert-success fade-in">
                <span>✅</span>
                <div>
                    <strong>Upload Successful!</strong>
                    <c:forEach var="msg" items="${uploadMessages}">
                        <div>${msg}</div>
                    </c:forEach>
                    <div style="margin-top:.5rem;">
                        <a href="${pageContext.request.contextPath}/generate"
                           style="color:var(--primary);font-weight:700;">→ Go to Generate Seating</a>
                    </div>
                </div>
            </div>
        </c:if>

        <%-- Errors --%>
        <c:if test="${not empty uploadErrors}">
            <div class="alert alert-error fade-in">
                <span>❌</span>
                <div>
                    <strong>Issues found:</strong>
                    <c:forEach var="err" items="${uploadErrors}">
                        <div>${err}</div>
                    </c:forEach>
                </div>
            </div>
        </c:if>

        <%-- Format info --%>
        <div class="alert fade-in" style="background:#eff6ff;border-color:#bfdbfe;color:#1e40af;margin-bottom:1.5rem;">
            <span>ℹ️</span>
            <div style="font-size:.82rem;">
                <strong>halls.csv:</strong> <code>hall_name, rows, seats_per_row</code>
                &emsp;|&emsp;
                <strong>Class CSV:</strong> <code>roll_no, name, branch</code>
            </div>
        </div>

        <form action="${pageContext.request.contextPath}/upload"
              method="post"
              enctype="multipart/form-data"
              id="uploadForm">

            <%-- Hall file --%>
            <div class="card fade-in" style="margin-bottom:1.25rem;">
                <h3 style="font-size:1rem;font-weight:700;margin-bottom:.9rem;">🏛️ Hall Configuration</h3>
                <div class="upload-zone">
                    <label for="hallsFile">halls.csv <span style="color:#dc2626">*</span></label>
                    <input type="file" id="hallsFile" name="hallsFile" accept=".csv" required>
                </div>
                <div style="font-size:.72rem;color:var(--text-light);margin-top:.35rem;">
                    Example: <code>Hall-A,5,10</code>
                </div>
            </div>

            <%-- Class files — dynamic 1 to 20 --%>
            <div class="card fade-in" style="animation-delay:.08s;margin-bottom:1.25rem;">
                <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:.75rem;flex-wrap:wrap;gap:.5rem;">
                    <h3 style="font-size:1rem;font-weight:700;margin:0;">👨‍🎓 Class Files</h3>
                    <div style="display:flex;align-items:center;gap:.5rem;font-size:.8rem;color:var(--text-mid);">
                        <span class="counter-badge" id="classCountBadge">1</span>
                        <span>of 20 max</span>
                    </div>
                </div>

                <div id="classGrid" class="class-grid">
                    <div class="class-card" id="cc-0">
                        <label for="cf-0">Class 1 <span style="color:#dc2626">*</span></label>
                        <input type="file" id="cf-0" name="classFiles" accept=".csv" required>
                    </div>
                </div>

                <button type="button" id="addBtn" class="add-btn" onclick="addCard()">
                    <span style="font-size:1.1rem;">➕</span>
                    Add Another Class
                    <span id="remainSpan" style="font-size:.75rem;opacity:.7;">(19 slots remaining)</span>
                </button>

                <div style="font-size:.72rem;color:var(--text-light);margin-top:.6rem;">
                    Supports any branch: CSE, ECE, MECH, IT, CIVIL, etc.
                    &emsp;Example: <code>CSE001,Arun Kumar,CSE</code>
                </div>
            </div>

            <%-- Submit --%>
            <button type="submit" id="submitBtn"
                    style="width:100%;padding:1rem;font-size:1rem;font-weight:700;
                           background:var(--primary);color:#fff;border:none;
                           border-radius:var(--radius);cursor:pointer;
                           transition:background .2s;box-shadow:var(--shadow);">
                📤 Upload &amp; Parse All Files
            </button>
        </form>

        <%-- Sample data hint --%>
        <div class="card fade-in" style="animation-delay:.15s;margin-top:1.25rem;background:#f8fafc;">
            <h4 style="font-size:.88rem;font-weight:700;margin-bottom:.6rem;">📁 Sample files in <code>sample-data/</code></h4>
            <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:.5rem;">
                <div style="background:#fff;border:1px solid var(--border);border-radius:6px;padding:.55rem;font-size:.75rem;">
                    📄 <strong>halls.csv</strong><br>Hall-A (3×4), Hall-B (2×4)
                </div>
                <div style="background:#fff;border:1px solid var(--border);border-radius:6px;padding:.55rem;font-size:.75rem;">
                    📄 <strong>classA.csv</strong><br>4 CSE students
                </div>
                <div style="background:#fff;border:1px solid var(--border);border-radius:6px;padding:.55rem;font-size:.75rem;">
                    📄 <strong>classB.csv</strong><br>3 ECE students
                </div>
                <div style="background:#fff;border:1px solid var(--border);border-radius:6px;padding:.55rem;font-size:.75rem;">
                    📄 <strong>classC.csv</strong><br>3 MECH students
                </div>
            </div>
        </div>

    </main>
</div>

<footer class="footer">
    Automated Examination Hall Seating Arrangement System — No Database Required
</footer>

<script src="${pageContext.request.contextPath}/static/js/app.js"></script>
<script>
    const MAX = 20;
    let count = 1;
    let uid   = 1; // unique id counter so removed cards leave no gaps in IDs

    function addCard() {
        if (count >= MAX) return;
        count++;
        uid++;
        const grid = document.getElementById('classGrid');
        const div  = document.createElement('div');
        div.className = 'class-card';
        div.id = 'cc-' + uid;
        div.innerHTML =
            '<button type="button" class="rm-btn" onclick="removeCard(\'' + uid + '\')" title="Remove">✕</button>' +
            '<label for="cf-' + uid + '">Class ' + count + '</label>' +
            '<input type="file" id="cf-' + uid + '" name="classFiles" accept=".csv">';
        grid.appendChild(div);
        refresh();
    }

    function removeCard(id) {
        const el = document.getElementById('cc-' + id);
        if (el) { el.remove(); count--; }
        // Re-number labels
        document.querySelectorAll('.class-card').forEach((c, i) => {
            const lbl = c.querySelector('label');
            if (lbl) lbl.firstChild.textContent = 'Class ' + (i + 1) + (i === 0 ? ' * ' : ' ');
        });
        refresh();
    }

    function refresh() {
        document.getElementById('classCountBadge').textContent = count;
        document.getElementById('remainSpan').textContent      = '(' + (MAX - count) + ' slots remaining)';
        const btn = document.getElementById('addBtn');
        btn.disabled      = count >= MAX;
        btn.style.opacity = count >= MAX ? '0.4' : '1';
    }
</script>
</body>
</html>
