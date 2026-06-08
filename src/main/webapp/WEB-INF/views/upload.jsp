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
            background: var(--surface);
            transition: all var(--transition);
            position: relative;
        }
        .upload-zone:hover, .upload-zone.dragover {
            border-color: var(--primary);
            background: var(--primary-light);
        }
        .upload-zone.has-file {
            border-color: var(--success);
            background: #f0fdf4;
        }
        .upload-zone input[type="file"] {
            position: absolute;
            inset: 0;
            opacity: 0;
            cursor: pointer;
            width: 100%;
            height: 100%;
            z-index: 2;
        }
        .uz-label {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            padding: 2.5rem 1.5rem;
            cursor: pointer;
            text-align: center;
            z-index: 1;
        }
        .uz-icon {
            font-size: 2.5rem;
            margin-bottom: 0.75rem;
            transition: transform 0.2s;
        }
        .upload-zone:hover .uz-icon {
            transform: scale(1.1);
        }
        .uz-text {
            font-size: 0.9rem;
            color: var(--text-dark);
            margin-bottom: 0.5rem;
        }
        .uz-browse {
            color: var(--primary);
            font-weight: 600;
            text-decoration: underline;
        }
        .uz-file-info {
            font-size: 0.78rem;
            color: var(--text-light);
            font-weight: 500;
        }
        .upload-zone.has-file .uz-file-info {
            color: var(--success);
            font-weight: 600;
        }

        .class-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
            gap: 1rem;
            margin-bottom: 1.25rem;
        }
        .class-card {
            border: 2px dashed var(--border);
            border-radius: var(--radius);
            background: var(--surface);
            position: relative;
            transition: all var(--transition);
        }
        .class-card:hover, .class-card.dragover {
            border-color: var(--primary);
            box-shadow: var(--shadow-sm);
        }
        .class-card.has-file {
            border-color: var(--success);
            background: #f0fdf4;
        }
        .class-card input[type="file"] {
            position: absolute;
            inset: 0;
            opacity: 0;
            cursor: pointer;
            width: 100%;
            height: 100%;
            z-index: 2;
        }
        .cc-label {
            display: flex;
            flex-direction: column;
            padding: 1.25rem;
            height: 100%;
            cursor: pointer;
            z-index: 1;
        }
        .cc-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.75rem;
        }
        .cc-title {
            font-weight: 700;
            font-size: 0.82rem;
            color: var(--text-mid);
        }
        .class-card.has-file .cc-title {
            color: var(--success);
        }
        .cc-body {
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
            flex-grow: 1;
        }
        .cc-icon {
            font-size: 1.75rem;
            margin-bottom: 0.5rem;
        }
        .cc-text {
            font-size: 0.8rem;
            font-weight: 600;
            color: var(--primary);
            margin-bottom: 0.25rem;
        }
        .class-card.has-file .cc-text {
            color: var(--success);
        }
        .cc-file-info {
            font-size: 0.7rem;
            color: var(--text-light);
            word-break: break-all;
        }
        .class-card.has-file .cc-file-info {
            color: var(--success);
            font-weight: 600;
        }
        
        .rm-btn {
            position: absolute;
            top: 10px;
            right: 10px;
            background: #fee2e2;
            border: none;
            border-radius: 50%;
            width: 22px;
            height: 22px;
            line-height: 22px;
            text-align: center;
            cursor: pointer;
            font-size: 0.75rem;
            color: #dc2626;
            z-index: 10;
            display: none;
            align-items: center;
            justify-content: center;
            transition: all var(--transition);
        }
        .class-card:hover .rm-btn {
            display: flex;
        }
        .rm-btn:hover {
            background: #fca5a5;
            transform: scale(1.1);
        }

        .add-btn {
            border: 2px dashed #94a3b8; border-radius: var(--radius);
            background: transparent; width: 100%; padding: 1rem;
            color: var(--text-mid); cursor: pointer; font-size: .875rem; font-weight: 600;
            display: flex; align-items: center; justify-content: center; gap: 8px;
            transition: all var(--transition);
        }
        .add-btn:hover {
            border-color: var(--primary); color: var(--primary);
            background: var(--primary-light);
        }
        .add-btn:disabled { opacity: .4; cursor: not-allowed; }
        .counter-badge {
            display: inline-block; background: var(--primary);
            color: #fff; border-radius: 20px; padding: 2px 10px;
            font-size: .75rem; font-weight: 700;
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

        <%-- Success (Unused since we redirect to generate directly now, but kept for fallback) --%>
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
                <div class="upload-zone" id="uz-halls">
                    <input type="file" id="hallsFile" name="hallsFile" accept=".csv" required onchange="handleFileChange(this, 'uz-halls')">
                    <label for="hallsFile" class="uz-label">
                        <div class="uz-icon">📁</div>
                        <div class="uz-text">Drag &amp; drop <strong>halls.csv</strong> here, or <span class="uz-browse">browse</span></div>
                        <div class="uz-file-info" id="uz-halls-info">No file chosen</div>
                    </label>
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
                        <input type="file" id="cf-0" name="classFiles" accept=".csv" required onchange="handleFileChange(this, 'cc-0')">
                        <label for="cf-0" class="cc-label">
                            <div class="cc-header">
                                <span class="cc-title" id="cc-title-0">Class 1 <span style="color:#dc2626">*</span></span>
                            </div>
                            <div class="cc-body">
                                <div class="cc-icon">📄</div>
                                <div class="cc-text" id="cc-text-0">Choose CSV</div>
                                <div class="cc-file-info" id="cc-info-0">No file chosen</div>
                            </div>
                        </label>
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
    let uid   = 1; // unique id counter

    function handleFileChange(input, containerId) {
        const container = document.getElementById(containerId);
        if (!container) return;

        if (input.files && input.files.length > 0) {
            const file = input.files[0];
            container.classList.add('has-file');
            
            // Check if it's halls zone or class card
            if (containerId === 'uz-halls') {
                document.getElementById('uz-halls-info').textContent = '✓ ' + file.name + ' (' + Math.round(file.size / 1024) + ' KB)';
            } else {
                // Find matching details elements
                const indexSuffix = containerId.replace('cc-', '');
                const textEl = document.getElementById('cc-text-' + indexSuffix);
                const infoEl = document.getElementById('cc-info-' + indexSuffix);
                if (textEl) textEl.textContent = 'File Selected';
                if (infoEl) infoEl.textContent = '✓ ' + file.name;
            }
        } else {
            container.classList.remove('has-file');
            if (containerId === 'uz-halls') {
                document.getElementById('uz-halls-info').textContent = 'No file chosen';
            } else {
                const indexSuffix = containerId.replace('cc-', '');
                const textEl = document.getElementById('cc-text-' + indexSuffix);
                const infoEl = document.getElementById('cc-info-' + indexSuffix);
                if (textEl) textEl.textContent = 'Choose CSV';
                if (infoEl) infoEl.textContent = 'No file chosen';
            }
        }
    }

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
            '<input type="file" id="cf-' + uid + '" name="classFiles" accept=".csv" onchange="handleFileChange(this, \'cc-' + uid + '\')">' +
            '<label for="cf-' + uid + '" class="cc-label">' +
            '    <div class="cc-header">' +
            '        <span class="cc-title" id="cc-title-' + uid + '">Class ' + count + '</span>' +
            '    </div>' +
            '    <div class="cc-body">' +
            '        <div class="cc-icon">📄</div>' +
            '        <div class="cc-text" id="cc-text-' + uid + '">Choose CSV</div>' +
            '        <div class="cc-file-info" id="cc-info-' + uid + '">No file chosen</div>' +
            '    </div>' +
            '</label>';
        grid.appendChild(div);
        refresh();
    }

    function removeCard(id) {
        const el = document.getElementById('cc-' + id);
        if (el) { el.remove(); count--; }
        // Re-number labels
        document.querySelectorAll('.class-card').forEach((c, i) => {
            const titleSpan = c.querySelector('.cc-title');
            if (titleSpan) titleSpan.textContent = 'Class ' + (i + 1) + (i === 0 ? ' *' : '');
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

    // Drag and Drop listeners
    ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
        document.addEventListener(eventName, e => {
            e.preventDefault();
            e.stopPropagation();
        }, false);
    });

    function setupDragAndDrop(containerId) {
        const zone = document.getElementById(containerId);
        if (!zone) return;

        ['dragenter', 'dragover'].forEach(eventName => {
            zone.addEventListener(eventName, () => zone.classList.add('dragover'), false);
        });

        ['dragleave', 'drop'].forEach(eventName => {
            zone.addEventListener(eventName, () => zone.classList.remove('dragover'), false);
        });
    }

    setupDragAndDrop('uz-halls');
    setupDragAndDrop('cc-0');
</script>
</body>
</html>
