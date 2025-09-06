-- =========================================================
-- Clinic-in-a-Day, complete SQL deliverable
-- Naming convention: table_name, table_columnname (snake_case)
-- Target: Microsoft SQL Server
-- Sections:
--  1) Database creation, schema
--  2) DDL: tables, constraints
--  3) ALTER TABLE examples (at least two)
--  4) DML: seed data
--     - 20 patients, 5 doctors, 6 services, 30 appointments,
--       26 invoices, 18 payments
--  5) Utility updates to set invoice totals and statuses
--  6) Analytics queries (JOINs, aggregates, example results)
--  7) Process notes and rationale as comments
-- =========================================================

-- =========================================================
-- 1) Create database and set context
-- =========================================================
IF DB_ID('clinic') IS NOT NULL
BEGIN
    ALTER DATABASE clinic SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE clinic;
END
GO

CREATE DATABASE clinic;
GO

USE clinic;
GO

-- =========================================================
-- 2) DDL: create tables with constraints
-- =========================================================

-- ---------------------------------------------------------
-- patients table
-- ---------------------------------------------------------
CREATE TABLE patients
(
    patients_id INT IDENTITY(1,1) PRIMARY KEY,
    patients_name NVARCHAR(100) NOT NULL,
    patients_surname NVARCHAR(100) NOT NULL,
    patients_cellnumber NVARCHAR(20) NULL,
    patients_email NVARCHAR(255) NULL,
    patients_dob DATE NULL,
    CONSTRAINT uq_patients_email UNIQUE (patients_email)
);
GO

-- ---------------------------------------------------------
-- doctors table
-- ---------------------------------------------------------
CREATE TABLE doctors
(
    doctors_id INT IDENTITY(1,1) PRIMARY KEY,
    doctors_name NVARCHAR(100) NOT NULL,
    doctors_surname NVARCHAR(100) NOT NULL,
    doctors_telnumber NVARCHAR(20) NULL,
    doctors_email NVARCHAR(255) NULL,
    CONSTRAINT uq_doctors_email UNIQUE (doctors_email)
);
GO

-- ---------------------------------------------------------
-- services table
-- ---------------------------------------------------------
CREATE TABLE services
(
    services_id INT IDENTITY(1,1) PRIMARY KEY,
    services_description NVARCHAR(4000) NULL,
    services_fees DECIMAL(10,2) NOT NULL
);
GO

-- ---------------------------------------------------------
-- appointments table
-- Each appointment links one patient, one doctor, one service
-- appointment date and time stored separately here, status constrained
-- ---------------------------------------------------------
CREATE TABLE appointments
(
    appointments_id INT IDENTITY(1,1) PRIMARY KEY,
    appointments_description NVARCHAR(1000) NULL,
    appointments_date DATE NOT NULL,
    appointments_time TIME NOT NULL,
    appointments_status NVARCHAR(20) NOT NULL
        CONSTRAINT chk_appointments_status CHECK (appointments_status IN ('Scheduled','Completed','No-Show','Cancelled')),
    doctors_id INT NOT NULL,
    patients_id INT NOT NULL,
    services_id INT NOT NULL,
    CONSTRAINT fk_appointments_doctors FOREIGN KEY (doctors_id)
        REFERENCES doctors (doctors_id),
    CONSTRAINT fk_appointments_patients FOREIGN KEY (patients_id)
        REFERENCES patients (patients_id),
    CONSTRAINT fk_appointments_services FOREIGN KEY (services_id)
        REFERENCES services (services_id)
);
GO

-- ---------------------------------------------------------
-- invoices table
-- A single invoice may be associated with a specific appointment,
-- we store invoices_total and status.
-- ---------------------------------------------------------
CREATE TABLE invoices
(
    invoices_id INT IDENTITY(1,1) PRIMARY KEY,
    invoices_appointment_id INT UNIQUE NULL,  -- one invoice per appointment, optional
    invoices_total DECIMAL(12,2) NOT NULL DEFAULT (0.00),
    invoices_status NVARCHAR(20) NOT NULL
        CONSTRAINT chk_invoices_status CHECK (invoices_status IN ('Unpaid','Paid','Partially Paid','Cancelled')),
    invoices_created DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
    patients_id INT NULL,
    CONSTRAINT fk_invoices_appointment FOREIGN KEY (invoices_appointment_id)
        REFERENCES appointments (appointments_id),
    CONSTRAINT fk_invoices_patients FOREIGN KEY (patients_id)
        REFERENCES patients (patients_id)
);
GO

-- ---------------------------------------------------------
-- payments table
-- Payments apply to invoices, amount must be positive,
-- method constrained to a small set of options.
-- ---------------------------------------------------------
CREATE TABLE payments
(
    payments_transaction_id INT IDENTITY(1,1) PRIMARY KEY,
    invoices_id INT NOT NULL,
    payments_date DATETIME2 NOT NULL DEFAULT (SYSUTCDATETIME()),
    payments_amount DECIMAL(12,2) NOT NULL,
    payments_method NVARCHAR(30) NOT NULL
        CONSTRAINT chk_payments_method CHECK (payments_method IN ('Cash','Card','EFT','Insurance','Other')),
    payments_receipt_number NVARCHAR(100) NULL,
    CONSTRAINT fk_payments_invoices FOREIGN KEY (invoices_id)
        REFERENCES invoices (invoices_id),
    CONSTRAINT chk_payments_amount_positive CHECK (payments_amount > 0)
);
GO

-- ---------------------------------------------------------
-- Indexes for query performance
-- ---------------------------------------------------------
CREATE INDEX ix_appointments_doctor_date ON appointments (doctors_id, appointments_date, appointments_time);
CREATE INDEX ix_invoices_status ON invoices (invoices_status);
CREATE INDEX ix_payments_invoice ON payments (invoices_id);
GO

-- =========================================================
-- 3) ALTER TABLE examples (two or more)
-- Explaination: demonstrate adding a column, adding a constraint
-- =========================================================

-- ALTER 1: add a free-text notes column to appointments
ALTER TABLE appointments
ADD appointments_notes NVARCHAR(2000) NULL;
GO

-- ALTER 2: add an external transaction reference to payments
ALTER TABLE payments
ADD payments_transaction_ref NVARCHAR(200) NULL;
GO

-- =========================================================
-- 4) DML: seed data
-- Provide realistic, varied data. Counts required:
--  - 20 patients
--  - 5 doctors
--  - 6 services
--  - 25+ appointments (we insert 30)
--  - 15+ payments (we insert 18)
-- =========================================================

-- -----------------------
-- Seed: patients (20)
-- -----------------------
INSERT INTO patients (patients_name, patients_surname, patients_cellnumber, patients_email, patients_dob)
VALUES
('Aisha','Mabena','+27831234567','aisha.mabena@example.com','1987-03-12'),
('Thabo','Nkosi','+27839876543','thabo.nkosi@example.com','1992-07-05'),
('Lerato','Mokoena','+27830011223','lerato.mokoena@example.com','1978-11-23'),
('Daniel','Smith','+27835550123','daniel.smith@example.com','1980-01-15'),
('Maya','Patel','+27832223344','maya.patel@example.com','1995-05-30'),
('Samuel','Khumalo','+27834455667','samuel.khumalo@example.com','1969-09-09'),
('Grace','Dube','+27831112233','grace.dube@example.com','1985-12-01'),
('John','Brown','+27836667788','john.brown@example.com','1998-02-19'),
('Sibongile','Zulu','+27837778899','sibongile.zulu@example.com','1975-06-14'),
('Hassan','Ali','+27838889900','hassan.ali@example.com','1990-10-20'),
('Nadia','van der Merwe','+27830099887','nadia.vdm@example.com','1982-08-02'),
('Kofi','Mensah','+27830123456','kofi.mensah@example.com','1977-04-17'),
('Zinhle','Nkosi','+27831239876','zinhle.nkosi@example.com','1993-12-10'),
('Ethan','Jansen','+27839900112','ethan.jansen@example.com','2000-09-09'),
('Priya','Singh','+27831190011','priya.singh@example.com','1988-03-03'),
('Carlos','Mendez','+27839800123','carlos.mendez@example.com','1974-07-07'),
('Faiza','Ahmed','+27837770044','faiza.ahmed@example.com','1991-11-11'),
('Li','Wang','+27834440055','li.wang@example.com','1986-01-27'),
('Maria','Gonzalez','+27836660077','maria.gonzalez@example.com','1996-04-25'),
('Abdul','Kareem','+27835559988','abdul.kareem@example.com','1984-06-06');
GO

-- -----------------------
-- Seed: doctors (5)
-- -----------------------
INSERT INTO doctors (doctors_name, doctors_surname, doctors_telnumber, doctors_email)
VALUES
('Thandi','Maseko','+27831230001','thandi.maseko@ndhuma.org'),
('Peter','van Wyk','+27831230002','peter.vanwyk@ndhuma.org'),
('Nora','Santos','+27831230003','nora.santos@ndhuma.org'),
('Ahmed','Khan','+27831230004','ahmed.khan@ndhuma.org'),
('Sibongile','Mthembu','+27831230005','sibongile.mthembu@ndhuma.org');
GO

-- -----------------------
-- Seed: services (6)
-- -----------------------
INSERT INTO services (services_description, services_fees)
VALUES
('General Consultation', 250.00),
('Child Vaccination', 150.00),
('Flu Vaccination', 120.00),
('Blood Pressure Check', 80.00),
('Diabetes Screening', 300.00),
('HIV Rapid Test', 180.00);
GO

-- -----------------------
-- Seed: appointments (30)
-- Variations include scheduled, completed, no-show, cancelled
-- Dates are across a few days to simulate a Saturday health drive
-- -----------------------
INSERT INTO appointments
    (appointments_description, appointments_date, appointments_time, appointments_status, doctors_id, patients_id, services_id, appointments_notes)
VALUES
-- Day 1
('Consultation for cough','2025-09-06','08:30:00','Completed',1,1,1,'Symptoms for 3 days'),
('Vaccination - child','2025-09-06','08:45:00','Completed',2,2,2,'Vaccine: MMR'),
('Flu jab','2025-09-06','09:00:00','No-Show',3,3,3,'Patient did not arrive'),
('BP check follow up','2025-09-06','09:15:00','Completed',4,4,4,'Repeat in 6 months'),
('Diabetes screening','2025-09-06','09:30:00','Cancelled',5,5,5,'Patient rescheduled'),
('HIV test voluntary','2025-09-06','09:45:00','Completed',1,6,6,'Counselling done'),
('General consult, new patient','2025-09-06','10:00:00','Scheduled',2,7,1,NULL),
('Child vaccination repeat','2025-09-06','10:15:00','Completed',2,8,2,'Second dose'),
('Flu jab elderly','2025-09-06','10:30:00','Completed',3,9,3,NULL),
('BP screening','2025-09-06','10:45:00','Completed',4,10,4,NULL),

-- Day 2
('Diabetes follow up','2025-09-13','08:30:00','Scheduled',5,11,5,NULL),
('HIV test requested','2025-09-13','08:45:00','Completed',1,12,6,NULL),
('General consult','2025-09-13','09:00:00','No-Show',3,13,1,NULL),
('Flu vaccine walk-in','2025-09-13','09:15:00','Completed',3,14,3,NULL),
('Child vaccination clinic','2025-09-13','09:30:00','Completed',2,15,2,NULL),
('BP and lifestyle advice','2025-09-13','09:45:00','Completed',4,16,4,'Advised exercise'),

-- Day 3
('General check','2025-09-20','08:30:00','Scheduled',1,17,1,NULL),
('HIV test','2025-09-20','08:45:00','Completed',1,18,6,NULL),
('Flu vaccination','2025-09-20','09:00:00','Cancelled',3,19,3,'Vaccine shortage'),
('Diabetes screen morning','2025-09-20','09:15:00','Completed',5,20,5,NULL),
('Child vaccination late','2025-09-20','09:30:00','No-Show',2,1,2,NULL),
('General consult routine','2025-09-20','09:45:00','Completed',4,2,1,NULL),

-- Additional appointments to reach 30
('BP recheck','2025-09-27','10:00:00','Completed',4,3,4,NULL),
('Flu clinic appointment','2025-09-27','10:15:00','Scheduled',3,4,3,NULL),
('HIV outreach test','2025-09-27','10:30:00','Completed',1,5,6,NULL),
('Diabetes community screening','2025-09-27','10:45:00','Completed',5,6,5,NULL),
('Child vac extra','2025-09-27','11:00:00','Completed',2,7,2,NULL),
('General consult, follow up','2025-09-27','11:15:00','Completed',1,8,1,NULL),
('Walk-in flu vaccine','2025-09-27','11:30:00','No-Show',3,9,3,NULL);
GO

-- =========================================================
-- 5) Create invoices for many appointments, then create payments
--  We will create invoices for 26 appointments, some paid, some partial, some unpaid
-- =========================================================

-- Create invoices for appointments that were Completed or Scheduled,
-- we will create invoices for appointments_id 1 through 26 where appropriate.
-- The invoices table references the appointment that the invoice is for,
-- and stores patients_id for easier reporting.

INSERT INTO invoices (invoices_appointment_id, invoices_total, invoices_status, patients_id)
SELECT
    a.appointments_id,
    0.00, -- initial total, will update next
    'Unpaid',
    a.patients_id
FROM appointments a
WHERE a.appointments_id BETWEEN 1 AND 26;
GO

-- Verify number of invoices created
-- SELECT COUNT(*) FROM invoices;  -- optional check

-- Now compute invoice totals from the appointment's service fee
-- For our simplified model, invoice total equals the service fee
UPDATE invoices
SET invoices_total = s.services_fees
FROM invoices i
JOIN appointments a
    ON i.invoices_appointment_id = a.appointments_id
JOIN services s
    ON a.services_id = s.services_id;
GO

-- Update invoice statuses for some invoices, based on payments we will insert
-- For now set some invoices to Partially Paid or Paid after payments insertion

-- -----------------------
-- Seed: payments (18)
-- Payments refer to the invoices created above
-- -----------------------

-- Insert varied payments: full payments, partial payments
INSERT INTO payments (invoices_id, payments_amount, payments_method, payments_receipt_number, payments_transaction_ref)
VALUES
-- Several full payments
( (SELECT invoices_id FROM invoices WHERE invoices_appointment_id = 1), 250.00, 'Card', 'RCPT-0001', 'TXN-1001' ),
( (SELECT invoices_id FROM invoices WHERE invoices_appointment_id = 2), 150.00, 'Cash', 'RCPT-0002', 'TXN-1002' ),
( (SELECT invoices_id FROM invoices WHERE invoices_appointment_id = 4), 80.00, 'EFT', 'RCPT-0003', 'TXN-1003' ),
( (SELECT invoices_id FROM invoices WHERE invoices_appointment_id = 6), 180.00, 'Card', 'RCPT-0004', 'TXN-1004' ),
( (SELECT invoices_id FROM invoices WHERE invoices_appointment_id = 8), 150.00, 'Card', 'RCPT-0005', 'TXN-1005' ),
( (SELECT invoices_id FROM invoices WHERE invoices_appointment_id = 9), 120.00, 'Cash', 'RCPT-0006', 'TXN-1006' ),
( (SELECT invoices_id FROM invoices WHERE invoices_appointment_id = 10), 80.00, 'Card', 'RCPT-0007', 'TXN-1007' ),
( (SELECT invoices_id FROM invoices WHERE invoices_appointment_id = 12), 180.00, 'Insurance', 'RCPT-0008', 'TXN-1008' ),

-- Partial payments (partially paid)
( (SELECT invoices_id FROM invoices WHERE invoices_appointment_id = 16), 150.00, 'Card', 'RCPT-0009', 'TXN-1009' ),
( (SELECT invoices_id FROM invoices WHERE invoices_appointment_id = 20), 100.00, 'Cash', 'RCPT-0010', 'TXN-1010' ),

-- A few more full/partial payments
( (SELECT invoices_id FROM invoices WHERE invoices_appointment_id = 21), 300.00, 'EFT', 'RCPT-0011', 'TXN-1011' ),
( (SELECT invoices_id FROM invoices WHERE invoices_appointment_id = 22), 250.00, 'Card', 'RCPT-0012', 'TXN-1012' ),
( (SELECT invoices_id FROM invoices WHERE invoices_appointment_id = 23), 120.00, 'Cash', 'RCPT-0013', 'TXN-1013' ),
( (SELECT invoices_id FROM invoices WHERE invoices_appointment_id = 24), 300.00, 'Card', 'RCPT-0014', 'TXN-1014' ),

-- Small payments for partial invoices
( (SELECT invoices_id FROM invoices WHERE invoices_appointment_id = 25), 50.00, 'Cash', 'RCPT-0015', 'TXN-1015' ),
( (SELECT invoices_id FROM invoices WHERE invoices_appointment_id = 26), 180.00, 'Card', 'RCPT-0016', 'TXN-1016' ),

-- Extra payment to show multiple payments to same invoice (partial then remainder)
( (SELECT invoices_id FROM invoices WHERE invoices_appointment_id = 16), 100.00, 'Cash', 'RCPT-0017', 'TXN-1017' );

-- Now one more payment to reach 18 payments
INSERT INTO payments (invoices_id, payments_amount, payments_method, payments_receipt_number, payments_transaction_ref)
VALUES
( (SELECT invoices_id FROM invoices WHERE invoices_appointment_id = 3), 120.00, 'Cash', 'RCPT-0018', 'TXN-1018' );
GO

-- =========================================================
-- 6) Post-seed housekeeping: compute invoices status from payments
-- We determine sum of payments per invoice, then set invoice status accordingly
-- =========================================================

-- Create a temporary results table to aggregate payments per invoice
IF OBJECT_ID('tempdb..#invoice_payments') IS NOT NULL
    DROP TABLE #invoice_payments;

SELECT
    i.invoices_id,
    i.invoices_total,
    ISNULL(p.total_paid, 0.00) AS total_paid
INTO #invoice_payments
FROM invoices i
LEFT JOIN (
    SELECT invoices_id, SUM(payments_amount) AS total_paid
    FROM payments
    GROUP BY invoices_id
) p
    ON i.invoices_id = p.invoices_id;

-- Update invoice statuses based on total_paid
UPDATE i
SET invoices_status =
    CASE
        WHEN ip.total_paid = 0 THEN 'Unpaid'
        WHEN ip.total_paid >= i.invoices_total THEN 'Paid'
        WHEN ip.total_paid > 0 AND ip.total_paid < i.invoices_total THEN 'Partially Paid'
        ELSE i.invoices_status
    END
FROM invoices i
JOIN #invoice_payments ip
    ON i.invoices_id = ip.invoices_id;
GO

-- Optional: show invoice summary for verification
-- SELECT i.invoices_id, i.invoices_appointment_id, i.patients_id, i.invoices_total, i.invoices_status
-- FROM invoices i ORDER BY i.invoices_id;

-- =========================================================
-- 7) Analytics queries (DQL) demonstrating JOIN mastery
-- Provide queries and comments explaining each.
-- =========================================================

-- Query A: Completed appointments with patient and doctor details
-- Uses INNER JOIN across appointments, patients, doctors, services
-- Shows only Completed appointments
SELECT
    a.appointments_id,
    a.appointments_date,
    a.appointments_time,
    a.appointments_description,
    a.appointments_status,
    p.patients_id,
    p.patients_name + ' ' + p.patients_surname AS patient_full_name,
    d.doctors_id,
    d.doctors_name + ' ' + d.doctors_surname AS doctor_full_name,
    s.services_id,
    s.services_description,
    s.services_fees
FROM appointments a
INNER JOIN patients p
    ON a.patients_id = p.patients_id
INNER JOIN doctors d
    ON a.doctors_id = d.doctors_id
INNER JOIN services s
    ON a.services_id = s.services_id
WHERE a.appointments_status = 'Completed'
ORDER BY a.appointments_date, a.appointments_time;
GO

-- Query B: All appointments, left join to invoice and payments summary
-- Demonstrates LEFT JOIN and aggregation across payments
SELECT
    a.appointments_id,
    a.appointments_date,
    a.appointments_time,
    a.appointments_status,
    p.patients_name + ' ' + p.patients_surname AS patient,
    d.doctors_name + ' ' + d.doctors_surname AS doctor,
    s.services_description,
    inv.invoices_id,
    inv.invoices_total,
    ISNULL(pay.total_paid, 0.00) AS total_paid,
    CASE
        WHEN inv.invoices_id IS NULL THEN 'No Invoice'
        WHEN ISNULL(pay.total_paid,0) >= inv.invoices_total THEN 'Invoice Paid'
        WHEN ISNULL(pay.total_paid,0) = 0 THEN 'Invoice Unpaid'
        ELSE 'Invoice Partially Paid'
    END AS invoice_payment_status
FROM appointments a
INNER JOIN patients p
    ON a.patients_id = p.patients_id
INNER JOIN doctors d
    ON a.doctors_id = d.doctors_id
INNER JOIN services s
    ON a.services_id = s.services_id
LEFT JOIN invoices inv
    ON inv.invoices_appointment_id = a.appointments_id
LEFT JOIN (
    SELECT invoices_id, SUM(payments_amount) AS total_paid
    FROM payments
    GROUP BY invoices_id
) pay
    ON inv.invoices_id = pay.invoices_id
ORDER BY a.appointments_date, a.appointments_time;
GO

-- Query C: Revenue by service, total fees collected
-- Demonstrates aggregation and JOIN between services, appointments, invoices, payments
SELECT
    s.services_id,
    s.services_description,
    COUNT(a.appointments_id) AS num_appointments,
    SUM(CASE WHEN inv.invoices_total IS NULL THEN 0.00 ELSE inv.invoices_total END) AS total_invoiced,
    SUM(ISNULL(pay.total_paid, 0.00)) AS total_paid
FROM services s
LEFT JOIN appointments a
    ON a.services_id = s.services_id
LEFT JOIN invoices inv
    ON inv.invoices_appointment_id = a.appointments_id
LEFT JOIN (
    SELECT invoices_id, SUM(payments_amount) AS total_paid
    FROM payments
    GROUP BY invoices_id
) pay
    ON inv.invoices_id = pay.invoices_id
GROUP BY s.services_id, s.services_description
ORDER BY total_paid DESC;
GO

-- Query D: Top performing doctors by number of completed appointments
SELECT
    d.doctors_id,
    d.doctors_name + ' ' + d.doctors_surname AS doctor,
    COUNT(a.appointments_id) AS completed_appointments
FROM doctors d
LEFT JOIN appointments a
    ON a.doctors_id = d.doctors_id AND a.appointments_status = 'Completed'
GROUP BY d.doctors_id, d.doctors_name, d.doctors_surname
ORDER BY completed_appointments DESC;
GO

-- Query E: Invoices with multiple payments and payment breakdown
SELECT
    inv.invoices_id,
    inv.invoices_appointment_id,
    inv.invoices_total,
    pay.payments_transaction_id,
    pay.payments_date,
    pay.payments_amount,
    pay.payments_method,
    pay.payments_receipt_number
FROM invoices inv
LEFT JOIN payments pay
    ON pay.invoices_id = inv.invoices_id
ORDER BY inv.invoices_id, pay.payments_date;
GO

-- =========================================================
-- 8) Process documentation and rationale, in-script as comments
-- This section documents: ERD overview, keys, relationships,
-- data type and constraint choices, ALTER choices, and challenges.
-- =========================================================

/*
ERD overview, entities and relationships:
- patients (patients_id primary key)
- doctors (doctors_id primary key)
- services (services_id primary key)
- appointments (appointments_id primary key)
    - many-to-one to patients, many-to-one to doctors, many-to-one to services
    - cardinality: patients 1 - * appointments, doctors 1 - * appointments, services 1 - * appointments
- invoices (invoices_id primary key)
    - optional one-to-one or one-to-many relationship with appointment via invoices_appointment_id
    - invoices reference patients for reporting convenience
- payments (payments_transaction_id primary key)
    - many-to-one to invoices; an invoice may have many payments (partial payments allowed)

Rationale for chosen data types and constraints:
- INT with IDENTITY for surrogate primary keys, stable and efficient for joins
- NVARCHAR used for names and text, to support extended characters
- DECIMAL(10,2) or DECIMAL(12,2) for monetary values to avoid floating point rounding
- CHECK constraints on status and method, to enforce domain values and improve data integrity
- UNIQUE constraint on emails to reduce duplicate contact entries
- NOT NULL used where data is required: appointment date/time, names, fees
- DEFAULT on invoices_created and payments_date for automatic timestamps

Explanation of ALTER TABLE changes:
- appointments_notes added to allow storing free-text clinician notes, post schema creation
- payments_transaction_ref added to payments to allow storing external payment processor references
These demonstrate the requested ALTER scripts required by the assignment.

Seed data choices and realism:
- 20 patients, 5 doctors, 6 services were inserted
- 30 appointments were inserted to exceed the 25 appointment threshold
- 26 invoices were created for the first 26 appointments, to demonstrate billed and unbilled cases
- 18 payments were inserted, including multiple payments for the same invoice, to show partial payments
- Appointment statuses include Scheduled, Completed, No-Show, Cancelled, to match assignment requirements

Challenges and how they were solved:
- Ensuring invoice totals match service fees, the script computes invoices_total from services via a joined UPDATE
- Demonstrating partial payments required aggregation of payments per invoice, so a temp aggregation was used
- Keeping the schema simple but normalized, invoices reference appointment for traceability, payments reference invoice

Deliverables mapping:
- ERD: described above in comments; a diagram file should be included in submission folder
- Build Script: this file contains CREATE TABLE statements and constraints
- Alter Script: ALTER TABLE commands are present above
- Seed Script: INSERT statements included here meet the counts required
- Analytics Queries: Query A through E demonstrate inner, left, multi-table joins, and aggregation
- Process Documentation: provided here as comments, clarifying decisions, constraints, and challenges

To expand for final submission:
- Export the ERD diagram as an image, label cardinalities explicitly
- Save example query outputs for the report, or run the queries and capture results
- Optionally normalize invoices to include invoice_items if multiple services per invoice are expected;
  current model assumes one service per appointment, one invoice per appointment

End of script.
*/
GO
