# Clinic-in-a-Day SQL Challenge

## Table of Contents

1. [Overview](#overview)
2. [System Architecture](#system-architecture)
3. [Project Structure](#project-structure)
4. [Installation Guide](#installation-guide)
5. [Usage Manual](#usage-manual)
6. [Features](#features)
7. [Technology Stack](#technology-stack)
8. [Development Notes](#development-notes)
9. [Documentation](#documentation)
10. [Notes](#notes)
11. [Disclaimer](#disclaimer)

## Overview

The **Clinic-in-a-Day** project is a group assignment designed to demonstrate the ability to design, build, 
and implement a small database-driven system within one day. The system simulates a clinic’s operations during 
a health drive, focusing on managing patients, doctors, services, appointments, invoices, and payments.

This project tests foundational database concepts, SQL skills (DDL, DML, DQL), data integrity through constraints, 
and the ability to design and document a working system.

## System Architecture

* **Database**: Microsoft SQL Server 2012 or later.
* **Entities**: Patients, Doctors, Services, Appointments, Invoices, Payments.
* **Relationships**:

  * Patients and Doctors have many Appointments.
  * Each Appointment is linked to one Service.
  * Each Appointment may generate an Invoice.
  * Each Invoice may receive multiple Payments.
* **Constraints**: Primary keys, foreign keys, unique constraints, check constraints, and default values ensure referential integrity and data quality.

## Project Structure

```
clinic-in-a-day-sql/
├── Solution.sql
└── README.md
```

## Installation Guide

1. Install **Microsoft SQL Server** (2012 or later).
2. Clone this repository:

   ```bash
   git clone https://github.com/HChristopherNaoyuki/clinic-in-a-day-sql.git
   ```
3. Open SQL Server Management Studio (SSMS).
4. Run the script.

## Usage Manual

* After installation, the database can be queried using SQL Server Management Studio.
* Example queries include:

  * Listing completed appointments with patient and doctor details.
  * Viewing invoices with payment status.
  * Summarizing revenue by service.
  * Ranking doctors by number of completed appointments.

## Features

* **Normalized schema** with referential integrity.
* **Constraints** to ensure valid data (PK, FK, UNIQUE, CHECK, DEFAULT).
* **Seed data** for testing with varied and realistic scenarios, including no-shows, cancellations, unpaid and partially paid invoices.
* **Analytics queries** to demonstrate JOINs, aggregation, and reporting.

## Technology Stack

* **Database**: Microsoft SQL Server 2012+
* **Language**: SQL (DDL, DML, DQL)
* **Tools**: SQL Server Management Studio (SSMS)

## Development Notes

* Naming convention: `table_columnname` in lowercase with underscores.
* Surrogate primary keys (INT with IDENTITY) used for all entities.
* NVARCHAR chosen for textual fields to support multilingual data.
* DECIMAL used for monetary values to avoid floating-point errors.
* Example data includes 20 patients, 5 doctors, 6 services, 30 appointments, 26 invoices, and 18 payments.

## Documentation

* SQL scripts contain inline comments explaining design choices and logic.
* This README provides process documentation for system design and implementation.

## Notes

* The database is simplified for educational purposes.
* In production, further normalization may be needed (for example, invoice items for multiple services per invoice).
* The current model assumes one service per appointment.

## DISCLAIMER

UNDER NO CIRCUMSTANCES SHOULD IMAGES OR EMOJIS BE INCLUDED DIRECTLY 
IN THE README FILE. ALL VISUAL MEDIA, INCLUDING SCREENSHOTS AND IMAGES 
OF THE APPLICATION, MUST BE STORED IN A DEDICATED FOLDER WITHIN THE 
PROJECT DIRECTORY. THIS FOLDER SHOULD BE CLEARLY STRUCTURED AND NAMED 
ACCORDINGLY TO INDICATE THAT IT CONTAINS ALL VISUAL CONTENT RELATED TO 
THE APPLICATION (FOR EXAMPLE, A FOLDER NAMED IMAGES, SCREENSHOTS, OR MEDIA).

I AM NOT LIABLE OR RESPONSIBLE FOR ANY MALFUNCTIONS, DEFECTS, OR ISSUES 
THAT MAY OCCUR AS A RESULT OF COPYING, MODIFYING, OR USING THIS SOFTWARE. 
IF YOU ENCOUNTER ANY PROBLEMS OR ERRORS, PLEASE DO NOT ATTEMPT TO FIX THEM 
SILENTLY OR OUTSIDE THE PROJECT. INSTEAD, KINDLY SUBMIT A PULL REQUEST 
OR OPEN AN ISSUE ON THE CORRESPONDING GITHUB REPOSITORY, SO THAT IT CAN 
BE ADDRESSED APPROPRIATELY BY THE MAINTAINERS OR CONTRIBUTORS.

---
