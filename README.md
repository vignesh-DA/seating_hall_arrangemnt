# ExamSeat Pro — Automated Examination Hall Seating Arrangement System

A production-level **Spring Boot + JSP** web application that automatically generates conflict-free examination hall seating arrangements directly from uploaded CSV files. 

This system is completely **database-free** and operates entirely in-memory to provide rapid, state-free allocations, making it extremely lightweight and perfectly suited for serverless/containerized hosting environments.

---

## 🚀 Key Features

* **In-Memory Pipeline**: Zero database dependencies. Upload -> Seating Engine -> Constraint Validation -> Instant Downloads.
* **Smart Seating Engine**: 
  1. *Greedy Largest-Pool-First Sort*: Groups branches by count.
  2. *Round-Robin Interleaving*: Generates a mixed pool of students (e.g., CSE → ECE → MECH).
  3. *Conflict Prevention*: Places students row-by-row while enforcing that adjacent seats must not contain students of the same branch.
* **Pre-Check Validator**: Identifies adjacent same-branch violations, seating overflows, and high empty-seat ratios.
* **Instant Export Package**: Download individual hall seating grids, summary txt reports, violation logs, or all reports bundled together in a single ZIP.
* **Interactive UI**: Fully polished desktop view featuring color-coded seat grids, active tabs, and drag-and-drop file uploaders.

---

## 🛠️ Technology Stack

| Layer | Technology |
|---|---|
| **Frontend** | Java JSP, JSTL, HTML5, Vanilla CSS3, Javascript |
| **Backend** | Java 17, Spring Boot 3.2, Spring MVC |
| **Build & Run** | Maven 3.9+, Embedded Tomcat |
| **Packaging** | Executable WAR (Executable Container-Ready) |
| **Deployment** | Docker (Multi-stage build) |

---

## 📁 CSV File Formats

### 1. Halls Configuration (`halls.csv`)
Defines the dimensions of each examination hall.
```csv
hall_name,rows,seats_per_row
Hall-A,3,4
Hall-B,2,4
```

### 2. Class CSVs (`classA.csv`, `classB.csv`, etc.)
Add students to the seating pool. Up to 20 class files can be uploaded concurrently.
```csv
roll_no,name,branch
192424311,Shahid,CSE
192425245,Neeha,ECE
192425301,Arun,MECH
```
*Note: Any custom branch names (like EEE, IT, CIVIL) are supported natively.*

---

## 💻 Local Development

### Prerequisites
* **Java 17 or higher**
* **Maven 3.8+**

### Compile and Run
1. Open your terminal in the project root directory.
2. Build the project:
   ```bash
   mvn clean package -DskipTests
   ```
3. Run the Spring Boot application:
   ```bash
   mvn spring-boot:run
   ```
4. Access the dashboard: [http://localhost:8080](http://localhost:8080)

---

## 🐳 Container Deployment

This repository includes a multi-stage `Dockerfile` optimized for minimal size and rapid startup.

### Local Docker Build
```bash
# Build the Docker image
docker build -t seating-system .

# Run the container (binds to host port 8080)
docker run -p 8080:8080 seating-system
```

### Cloud Deployments (Railway, Koyeb, Render)
This project is configured to bind to the dynamic port variable (`$PORT`) provided by cloud providers:
* **Koyeb (Recommended - Stays Awake 24/7)**: Link your GitHub repository, choose the **Docker** runtime, and set the container port to `8080`.
* **Railway**: Link your GitHub repository. Railway automatically builds and deploys the container from the `Dockerfile`.
* **Render**: Link your GitHub repository, set the runtime environment to **Docker**, and choose the Free tier.

---

## 📑 Application Architecture Flow

```
   [ Upload CSV Files ] 
            ↓ (Redirects to Generate page)
   [ Seating Engine ] 
     ├─ Step 1: Largest-Pool-First Sort
     ├─ Step 2: Round-Robin Interleave
     └─ Step 3: Fill Hall Grids Row-by-Row
            ↓
   [ Constraint Validator ] (Checks adjacent branches & overflows)
            ↓
   [ Report Writer ] (Outputs CSV/TXT files on disk)
            ↓
   [ Interactive View / Downloads ] (Visual layouts & ZIP download)
```

---

## 🗂️ Project Structure

```
.
├── pom.xml                 # Maven configuration (WAR packaging)
├── Dockerfile              # Multi-stage JDK 17 build container
├── README.md               # Documentation
├── sample-data/            # Sample CSV files for testing
│   ├── halls.csv
│   └── classA/B/C.csv
└── src/main/
    ├── java/com/exam/seating/
    │   ├── SeatingApplication.java
    │   ├── model/          # Hall, Student, SeatingResult, Violation
    │   ├── service/        # CSVReader, SeatingEngine, ConflictValidator, Report, CSVWriter
    │   └── controller/     # MainController (all endpoints)
    ├── resources/
    │   └── application.properties
    └── webapp/
        ├── WEB-INF/views/  # dashboard.jsp, upload.jsp, generate.jsp, seating.jsp, reports.jsp, summary.jsp
        └── static/
            ├── css/style.css
            └── js/app.js
```
