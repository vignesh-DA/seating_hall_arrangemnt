# Automated Examination Hall Seating Arrangement System

A complete **Spring Boot + JSP + MySQL** web application that automatically generates conflict-free examination hall seating arrangements from uploaded CSV files.

---

## Technology Stack

| Layer | Technology |
|---|---|
| Frontend | Java JSP, HTML5, CSS3, JavaScript (minimal), JSTL |
| Backend | Java 17, Spring Boot 3.2, Spring MVC, Spring Data JPA |
| Database | MySQL |
| File I/O | Java BufferedReader, FileWriter |
| Build | Maven |
| Server | Embedded Tomcat |
| Architecture | MVC |

---

## Prerequisites

1. **Java 17+** — `java -version`
2. **Maven 3.8+** — `mvn -version`
3. **MySQL 8.0+** — Running on `localhost:3306`

---

## Database Setup

Create the database (the app will create tables automatically via JPA):

```sql
CREATE DATABASE IF NOT EXISTS exam_seating
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

> Default credentials used: `root` / `root`  
> Change in `src/main/resources/application.properties` if needed.

---

## Build & Run

```bash
# Clone / navigate to project
cd seating-system

# Build
mvn clean package -DskipTests

# Run
mvn spring-boot:run
```

Open your browser at: **http://localhost:8080**

---

## CSV File Formats

### halls.csv
```
hall_name,rows,seats_per_row
Hall-A,5,10
Hall-B,4,8
Hall-C,6,12
```

### classA.csv / classB.csv / classC.csv
```
roll_no,name,branch
CSE001,Arun Kumar,CSE
ECE001,Meena Kumari,ECE
MECH001,Suresh Babu,MECH
```

> **Supported branches:** CSE, ECE, MECH, IT, CIVIL (and any custom branch name)

---

## Application Modules

### Module 1 — Input Management & Data Modeling
- **`Student.java`** — JPA entity (students table)
- **`Hall.java`** — JPA entity (halls table)
- **`CSVReaderService.java`** — Parses & validates CSV files using `BufferedReader`
  - Validates: empty fields, wrong format, duplicate roll numbers
  - Data structures: `ArrayList<Student>`, `HashMap<String,List<Student>>`, `HashSet<String>`

### Module 2 — Seating Arrangement Engine
- **`SeatingEngineService.java`** — O(N) algorithm:
  1. **Greedy Largest-Pool-First Sort** — sort branches by student count DESC
  2. **Round-Robin Interleaving** — CSE→ECE→MECH→CSE→ECE→MECH...
  3. **Fill Student[][] grid** — row by row, enforcing adjacency constraint, multi-hall overflow

### Module 3 — Constraint Validation
- **`ConflictValidatorService.java`**
  - Checks `grid[r][c].branch == grid[r][c+1].branch` → FAIL
  - Checks overflow (students > capacity)
  - Checks empty seat ratio > 20% → WARNING
  - Returns: PASS/FAIL + violation list

### Module 4 — Report Generation
- **`ReportService.java`** — Orchestrates all report generation
- **`CSVWriterService.java`** — Writes using `FileWriter`/`BufferedWriter`:
  - `Hall-X_seating.csv` — per hall seating grid
  - `violations.txt` — full constraint violation log
  - `summary.txt` — aggregate statistics

### Module 5 — Integration Controller
- **`MainController.java`** — Spring MVC `@Controller`

| Endpoint | Method | Description |
|---|---|---|
| `/` | GET | Dashboard |
| `/upload` | GET | Upload form |
| `/upload` | POST | Parse & store CSVs |
| `/generate` | GET | Generate form |
| `/generate` | POST | Run engine + validator + reporter |
| `/view` | GET | Display seating grid |
| `/reports` | GET | Reports page |
| `/download/seating?hall=X` | GET | Download seating CSV |
| `/download/violations` | GET | Download violations.txt |
| `/download/summary` | GET | Download summary.txt |

---

## Database Schema

```sql
CREATE TABLE students (
  id       BIGINT AUTO_INCREMENT PRIMARY KEY,
  roll_no  VARCHAR(20) UNIQUE NOT NULL,
  name     VARCHAR(100) NOT NULL,
  branch   VARCHAR(20) NOT NULL
);

CREATE TABLE halls (
  id           BIGINT AUTO_INCREMENT PRIMARY KEY,
  hall_name    VARCHAR(50) NOT NULL,
  rows         INT NOT NULL,
  seats_per_row INT NOT NULL
);

CREATE TABLE seat_allocations (
  id         BIGINT AUTO_INCREMENT PRIMARY KEY,
  seat_no    VARCHAR(20),
  hall       VARCHAR(50),
  student_id BIGINT,
  FOREIGN KEY (student_id) REFERENCES students(id)
);

CREATE TABLE violations (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  hall        VARCHAR(50),
  row         INT,
  seat        INT,
  branch      VARCHAR(20),
  description VARCHAR(255)
);
```

> Tables are auto-created by JPA (`spring.jpa.hibernate.ddl-auto=update`)

---

## Application Flow

```
Upload CSV Files
      ↓
CSVReaderService  →  Validate rows, detect duplicates  →  MySQL
      ↓
SeatingEngineService  →  Sort + Interleave + Fill grid
      ↓
ConflictValidatorService  →  PASS / FAIL + Violation list
      ↓
ReportService / CSVWriterService  →  Hall_seating.csv + violations.txt + summary.txt
      ↓
Display results  →  Seating grid view + Download buttons
```

---

## Frontend Pages

| Page | URL | Description |
|---|---|---|
| Dashboard | `/` | System overview, quick actions, pipeline status |
| Upload | `/upload` | Drag-drop CSV upload cards |
| Generate | `/generate` | Algorithm trigger, status display |
| Seating | `/view` | Color-coded hall grid, tab per hall |
| Reports | `/reports` | Download buttons for all files |
| Summary | `/summary` | Stats: students seated, violations, capacity % |

---

## Reports Output

After generation, three files appear in the `reports/` directory:

- **`Hall-A_seating.csv`** — Columns: Seat No, Roll No, Student Name, Branch
- **`violations.txt`** — Full violation log with hall/row/seat/branch details
- **`summary.txt`** — Aggregate stats: total students, halls used, capacity %, violation count

---

## Project Structure

```
seating-system/
├── pom.xml
├── README.md
└── src/main/
    ├── java/com/exam/seating/
    │   ├── SeatingApplication.java
    │   ├── model/          Student, Hall, SeatAllocation, Violation, SeatingResult
    │   ├── repository/     StudentRepository, HallRepository, SeatAllocationRepository, ViolationRepository
    │   ├── service/        CSVReaderService, SeatingEngineService, ConflictValidatorService, ReportService, CSVWriterService
    │   └── controller/     MainController
    ├── resources/
    │   └── application.properties
    └── webapp/
        ├── WEB-INF/views/  dashboard.jsp, upload.jsp, generate.jsp, seating.jsp, reports.jsp, summary.jsp
        └── static/
            ├── css/style.css
            └── js/app.js
```
