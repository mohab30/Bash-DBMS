# Bash-DBMS
A CLI-based DBMS that enables users to store and retrieve data from disk

---

# Simple Database Management System (DBMS) in Bash

## Project Description

This project is a **Command-Line Interface (CLI) based Database Management System (DBMS)** implemented entirely in Bash. It allows users to perform essential database operations such as creating databases, tables, and records, and supports basic operations like insert, update, delete, and retrieve. The project emphasizes simplicity, portability, and direct interaction with the filesystem.

---

## Features

- **Database Operations**:
  - Create, select, rename, drop, and list databases.

- **Table Operations**:
  - Create tables with metadata (fields, data types, and primary keys).
  - Insert data with validation (data types and primary key uniqueness).
  - Update and delete records based on primary keys.
  - Query data:
    - Display all fields.
    - Display specific fields.
    - Conditional filtering.

---

## Usage

1. Clone or download the repository.
2. Open a terminal and navigate to the project directory.
3. Run the script:
   ```bash
   ./dbms.sh
   ```
4. Follow the menu prompts to perform various operations.

---

## Directory Structure

- **DBMS Directory**: All databases and their tables are stored within a `DBMS` folder.
- **Metadata Files**: Tables have accompanying metadata files (e.g., `.tableName`) to define structure and constraints.

---

## Technical Highlights

- **Validation**:
  - Ensures correct data types (integer or string).
  - Verifies primary key uniqueness.
- **Dynamic Table Handling**:
  - Automatically adapts to the defined structure and columns.
- **Error Logging**:
  - Records errors in a log file `.error.log` for troubleshooting.

---

## Author

- **Mohab Ashraf**  
- **Fares Kataya**

---

## License

This project is open-source. Feel free to use and modify it as per your needs.

---

Would you like me to adjust or expand any section?
