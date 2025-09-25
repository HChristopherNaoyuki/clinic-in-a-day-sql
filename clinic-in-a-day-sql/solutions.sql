-- QUESTION 1: Database and Schema Creation
CREATE DATABASE ClinicInADay;
USE ClinicInADay;

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'clinic')
BEGIN
    EXEC('CREATE SCHEMA clinic');
END

-- QUESTION 1: Table Creation
CREATE TABLE clinic.PATIENT
(
    patient_id     VARCHAR(10) NOT NULL PRIMARY KEY,
    first_name     VARCHAR(100) NOT NULL,
    last_name      VARCHAR(100) NOT NULL,
    date_of_birth  DATE NOT NULL,
    phone          VARCHAR(15) NULL,
    email          VARCHAR(100) NULL,
    address        VARCHAR(200) NULL,
    CONSTRAINT CHK_Patient_DOB CHECK (date_of_birth <= CONVERT(date, GETDATE()))
);

CREATE TABLE clinic.DOCTOR
(
    doctor_id      VARCHAR(8) NOT NULL PRIMARY KEY,
    doctor_name    VARCHAR(100) NOT NULL,
    speciality     VARCHAR(50) NOT NULL,
    phone          VARCHAR(15) NULL,
    email          VARCHAR(100) NULL,
    CONSTRAINT UQ_Doctor_Email UNIQUE (email)
);

CREATE TABLE clinic.SERVICE
(
    service_id     VARCHAR(6) NOT NULL PRIMARY KEY,
    service_name   VARCHAR(100) NOT NULL,
    service_fee    MONEY NOT NULL CONSTRAINT DF_Service_Fee DEFAULT(0.00),
    description    VARCHAR(200) NULL
);

CREATE TABLE clinic.APPOINTMENT
(
    appointment_id       VARCHAR(12) NOT NULL PRIMARY KEY,
    patient_id           VARCHAR(10) NOT NULL,
    doctor_id            VARCHAR(8) NOT NULL,
    service_id           VARCHAR(6) NOT NULL,
    appointment_datetime DATETIME NOT NULL,
    duration_minutes     SMALLINT NOT NULL CHECK (duration_minutes > 0),
    status               VARCHAR(20) NOT NULL DEFAULT('Booked'),
    attended             BIT NULL,
    CONSTRAINT FK_Appointment_Patient FOREIGN KEY (patient_id) REFERENCES clinic.PATIENT(patient_id),
    CONSTRAINT FK_Appointment_Doctor FOREIGN KEY (doctor_id) REFERENCES clinic.DOCTOR(doctor_id),
    CONSTRAINT FK_Appointment_Service FOREIGN KEY (service_id) REFERENCES clinic.SERVICE(service_id),
    CONSTRAINT UQ_Appointment_Doctor_Start UNIQUE (doctor_id, appointment_datetime)
);

CREATE TABLE clinic.PAYMENT
(
    payment_id     VARCHAR(12) NOT NULL PRIMARY KEY,
    appointment_id VARCHAR(12) NOT NULL,
    payment_date   DATETIME NOT NULL DEFAULT (GETDATE()),
    amount         MONEY NOT NULL CHECK (amount >= 0),
    method         VARCHAR(20) NOT NULL,
    status         VARCHAR(20) NOT NULL DEFAULT('Completed'),
    CONSTRAINT FK_Payment_Appointment FOREIGN KEY (appointment_id) REFERENCES clinic.APPOINTMENT(appointment_id)
);

-- QUESTION 2: ALTER TABLE Examples
ALTER TABLE clinic.SERVICE
ADD prepayment_required BIT NOT NULL DEFAULT 0;

ALTER TABLE clinic.APPOINTMENT
ADD booking_source VARCHAR(20) NOT NULL DEFAULT('Online');

-- QUESTION 3: Index Creation
CREATE INDEX IDX_Appointment_Doctor_Date
ON clinic.APPOINTMENT (doctor_id, appointment_datetime);

-- QUESTION 4: Insert Data (20 Patients)
INSERT INTO clinic.PATIENT (patient_id, first_name, last_name, date_of_birth, phone, email, address) VALUES
('P000000001','Neo','Petlele','1995-03-12','0768978657','neo.petlele@example.com','12 Radar Drive, Durban'),
('P000000002','Derek','Moore','1990-01-22','0831593753','derek.moore@example.com','45 Main St, Pretoria'),
('P000000003','Pedro','Ntaba','1992-07-05','0823578963','pedro.ntaba@example.com','33 River Rd, Durban'),
('P000000004','Thabo','Joe','1988-11-30','0711346798','thabo.joe@example.com','99 Hill St, Johannesburg'),
('P000000005','Dominique','Woolridge','1993-04-19','0847139852','dominique.w@example.com','7 Oak Ave, Cape Town'),
('P000000006','Lindiwe','Mkhize','1985-05-10','0825551234','l.mkhize@example.com','21 Beach Rd, Durban'),
('P000000007','Sipho','Nkosi','1994-09-01','0791112222','sipho.nkosi@example.com','8 Market St, Pretoria'),
('P000000008','Anna','Smith','1978-12-01','0782223333','anna.smith@example.com','101 West Ave, Cape Town'),
('P000000009','John','Dlamini','1983-02-14','0793334444','john.dlamini@example.com','56 East Rd, Durban'),
('P000000010','Mary','Johnson','1996-06-18','0764445555','mary.j@example.com','14 North St, Sandton'),
('P000000011','Paul','Brown','1989-08-20','0735556666','paul.brown@example.com','88 Center Rd, Pretoria'),
('P000000012','Grace','Zulu','1997-03-03','0726667777','grace.zulu@example.com','29 Sunset Blvd, Durban'),
('P000000013','Kabelo','Molefe','1991-10-10','0717778888','kabelo.m@example.com','4 Hillcrest, Johannesburg'),
('P000000014','Sihle','Nukani','1992-12-12','0708889999','sihle.n@example.com','12 Rose Ln, Pretoria'),
('P000000015','Mia','Phillips','1995-02-02','0799990000','mia.p@example.com','77 Lake View, Cape Town'),
('P000000016','Bam','Mbombo','1990-05-05','0781234567','bam.m@example.com','2 Gordon St, Durban'),
('P000000017','Wendy','Grootboom','1986-09-09','0772345678','wendy.g@example.com','5 Willow Rd, Johannesburg'),
('P000000018','Henk','Cloete','1980-01-01','0763456789','henk.c@example.com','44 Oak Rd, Cape Town'),
('P000000019','Sibusiso','Dube','1993-07-07','0754567890','sibusiso.d@example.com','23 Park Lane, Pretoria'),
('P000000020','Ester','Ngubane','1998-04-25','0745678901','ester.n@example.com','66 River Rd, Durban');

-- QUESTION 4: Insert Data (5 Doctors)
INSERT INTO clinic.DOCTOR (doctor_id, doctor_name, speciality, phone, email) VALUES
('D00001','Dr. Thabo M','General Practitioner','0710000001','thabo.m@exampleclinic.com'),
('D00002','Dr. Yanga B','Paediatrics','0710000002','yanga.b@exampleclinic.com'),
('D00003','Dr. Sally S','Immunisation','0710000003','sally.s@exampleclinic.com'),
('D00004','Dr. Fred D','Internal Medicine','0710000004','fred.d@exampleclinic.com'),
('D00005','Dr. Tandy M','Family Medicine','0710000005','tandy.m@exampleclinic.com');

-- QUESTION 4: Insert Data (6 Services)
INSERT INTO clinic.SERVICE (service_id, service_name, service_fee, description, prepayment_required) VALUES
('S001','Consultation',150.00,'General consultation, 15 minutes',0),
('S002','Vaccination',120.00,'Routine vaccinations',0),
('S003','Rapid Test',200.00,'Rapid diagnostic test',0),
('S004','Minor Procedure',500.00,'Minor wound care or procedure',1),
('S005','Mental Health Consult',300.00,'Counselling session',0),
('S006','Health Screening',450.00,'Basic screening panel',0);

-- QUESTION 4: Insert Data (Appointments - sample, extend to 25+)
INSERT INTO clinic.APPOINTMENT (appointment_id, patient_id, doctor_id, service_id, appointment_datetime, duration_minutes, status, attended, booking_source) VALUES
('A0000000001','P000000001','D00001','S001','2024-10-20 09:00',30,'Completed',1,'Online'),
('A0000000002','P000000002','D00002','S001','2024-10-20 09:30',30,'Completed',1,'Walk-in'),
('A0000000003','P000000003','D00003','S002','2024-10-20 10:00',15,'No-Show',0,'Online');

-- QUESTION 4: Insert Data (Payments - at least 15)
INSERT INTO clinic.PAYMENT (payment_id, appointment_id, amount, method, status) VALUES
('PAY00001','A0000000001',150.00,'Cash','Completed'),
('PAY00002','A0000000002',150.00,'Card','Completed'),
('PAY00003','A0000000003',120.00,'EFT','Pending');

-- QUESTION 5: Example Analytics Query
SELECT 
    p.first_name, p.last_name, d.doctor_name, s.service_name, a.status, a.appointment_datetime
FROM 
    clinic.APPOINTMENT a
JOIN clinic.PATIENT p ON a.patient_id = p.patient_id
JOIN clinic.DOCTOR d ON a.doctor_id = d.doctor_id
JOIN clinic.SERVICE s ON a.service_id = s.service_id
WHERE a.status = 'Completed';
