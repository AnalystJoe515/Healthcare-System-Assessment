--Data preparation

--Creating appointment data table
CREATE TABLE public."Appointment_data_analysis"
(visit_id INT PRIMARY KEY,
patient_id INT,
department_name	VARCHAR(20),
patient_name VARCHAR(20),
appointment_date DATE,
arrival_time TIME,
appointment_time TIME,
admission_time TIME
);

--Creating hosp records table
CREATE TABLE public."Hospital_data_records"
(patient_id	INT PRIMARY KEY,
patient_name VARCHAR(20),
bmi	INT,
family_history_of_hypertension	CHAR(5) NOT NULL,
department_name	VARCHAR(20),
Days_in_the_hospital INT
);

--Creating lab results table
CREATE TABLE public."Lab_results"
(result_id int PRIMARY KEY,
visit_id INT,
test_name VARCHAR(100),
test_date DATE,
result_value FLOAT
);

--Creating Outpatients visits table 
CREATE TABLE public."Outpatient_visit"
(visit_id INT PRIMARY KEY ,
patient_id INT,
visit_date	DATE,
doctor_name VARCHAR(100),
reason_for_visit VARCHAR(100),
diagnosis VARCHAR(100),
medication_prescribed VARCHAR(100),
smoker_status CHAR(1)
);

--Creating patients data table
CREATE TABLE public."Patients_data_table"
(patient_id	INT PRIMARY KEY,
patient_name VARCHAR(20),
date_of_birth DATE,
gender CHAR(6),
address VARCHAR(30)
);

--QUERIES
SELECT * FROM public."Lab_results"
SELECT * FROM public."Hospital_data_records"
SELECT * FROM public."Appointment_data_analysis"
SELECT * FROM public."Outpatient_visit"
SELECT * FROM public."Patients_data_table"

--Data Exploration and wrangling

--Checking for null and duplicate values
SELECT DISTINCT	visit_id, patient_id, visit_date, doctor_name, reason_for_visit, diagnosis, medication_prescribed, smoker_status 
FROM public."Outpatient_visit";

SELECT DISTINCT patient_id, patient_name, date_of_birth, gender, address 
FROM public."Patients_data_table";

SELECT DISTINCT result_id 
FROM public."Lab_results";

SELECT DISTINCT patient_name
FROM public."Hospital_data_records";

SELECT * FROM public."Appointment_data_analysis"
WHERE patient_name IS NULL;

SELECT patient_name, count(*) 
FROM public."Patients_data_table"
GROUP BY patient_name
HAVING count(*) >1;

--Patient Care (Risk Factors)

/* 1. Investigate the lab dataset to examine patients’ blood sugar levels. 
Typically, fasting Blood sugar levels fall between 70 and 100 mg/dL. The goal is to identify patients whose lab results are outside this normal range to implement early interventions */

CREATE VIEW Abnormal_FBSL AS
SELECT p.patient_id, p.patient_name, lr.result_value
FROM public."Patients_data_table" AS p
INNER JOIN public."Outpatient_visit" AS ov
ON p.patient_id = ov.patient_id
INNER JOIN public."Lab_results" AS lr
ON ov.visit_id = lr.visit_id
WHERE lr.test_name = 'Fasting Blood Sugar' 
AND (CAST(lr.result_value AS NUMERIC) < 70 OR CAST(lr.result_value AS NUMERIC) > 100);

-- 2. The Hospital management wants to prevent cardiovascular disease and they need to assess how many patients are considered High, Medium, and Low Risk based on hypertension and diabetes diagnosis, smoker status
CREATE VIEW CVD_risk_assessment AS
SELECT 
CASE 
    WHEN Smoker_status = 'Y' AND Diagnosis IN ('Hypertension', 'Diabetes') THEN 'HIGH RISK'
    WHEN Smoker_status = 'N' AND Diagnosis IN ('Hypertension', 'Diabetes') THEN 'MEDIUM RISK'
    ELSE 'LOW RISK'
END AS CVD_Risk,
COUNT(*) AS Patient_count
FROM public."Outpatient_visit"
GROUP BY 
CASE 
    WHEN Smoker_status = 'Y' AND Diagnosis IN ('Hypertension', 'Diabetes') THEN 'HIGH RISK'
    WHEN Smoker_status = 'N' AND Diagnosis IN ('Hypertension', 'Diabetes') THEN 'MEDIUM RISK'
    ELSE 'LOW RISK'
END;

--3 Identify individuals at high risk of developing obesity within a population based on bmi and hyperlipidemia dignosis
CREATE VIEW Obesity_risk AS 
SELECT p.patient_id, p.patient_name,
CASE 
    WHEN diagnosis = 'Hyperlipidemia' AND bmi > 30 THEN 'HIGH RISK'
    WHEN diagnosis = 'Hyerlipidemia' AND (bmi > 25 AND bmi < 30) THEN 'MEDIUM RISK'
    ELSE 'LOW RISK'
END AS Risk_category
FROM public."Patients_data_table" as p
INNER JOIN public."Outpatient_visit" as ov
ON p.patient_id = ov.patient_id
INNER JOIN public."Hospital_data_records" as hr
ON ov.patient_id = hr.patient_id;


--4 Flag patients who are at risk due to interaction between their medication and smoking status
CREATE VIEW Medic_and_smoking_concern AS 
SELECT
patient_id,
diagnosis,
medication_prescribed,
smoker_status,
CASE
WHEN smoker_status = 'Y' AND medication_prescribed IN ('Insulin', 'Metformin', 'Lisinopril')
THEN 'Potential Safety Concern: Smoking and Medication Interactions'
ELSE 'No Safety Concern Identified'
END AS safety_concern
FROM public."Outpatient_visit";

--5 Classify patients into high, medium or low risk based on their BMI and family risk of hypertension
CREATE VIEW Hypertension_risk AS

SELECT 
CASE 
    WHEN family_history_of_hypertension = 'Yes' AND bmi > 30 THEN 'HIGH RISK'
    WHEN family_history_of_hypertension = 'Yes' AND (bmi > 25 AND bmi < 30) THEN 'MEDIUM RISK'
    ELSE 'LOW RISK'
END AS Risk_category,
COUNT(*) AS Patient_count
FROM public."Hospital_data_records"
GROUP BY 
CASE 
    WHEN family_history_of_hypertension = 'Yes' AND bmi > 30 THEN 'HIGH RISK'
    WHEN family_history_of_hypertension = 'Yes' AND (bmi > 25 AND bmi < 30) THEN 'MEDIUM RISK'
    ELSE 'LOW RISK'
END;

--Population Demographics

-- 1. What is the distribution of patients in our healthcare system based on their age groups and genders
CREATE VIEW Patient_distribution AS 
SELECT Gender,
CASE
    WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE_OF_BIRTH)) <= 17 THEN 'Pediatric'
    WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE_OF_BIRTH)) <= 64 THEN 'Adult'
    ELSE 'Senior'
END AS Age_group,
COUNT(*) AS Patient_count
FROM public."Patients_data_table"
GROUP BY Gender,
CASE
    WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE_OF_BIRTH)) <= 17 THEN 'Pediatric'
    WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE_OF_BIRTH)) <= 64 THEN 'Adult'
    ELSE 'Senior'
END
ORDER BY gender DESC;

--2. How many patients have been admitted in each department so far?
CREATE VIEW Dept_admission AS 
SELECT department_name,
COUNT(*) AS Patient_count
FROM public."Hospital_data_records"
GROUP BY department_name
ORDER BY Patient_count DESC;

--3. Detailed information of patients who have visited the hospital
CREATE VIEW Patient_info AS

SELECT p.Patient_name, ov.doctor_name, ov.visit_date, ov.reason_for_visit, ov.diagnosis, 
lr.test_name, lr.result_value,  ov.medication_prescribed, hr.days_in_the_hospital
FROM public."Hospital_data_records" as hr
INNER JOIN public."Patients_data_table" as p ON hr.patient_id = p.patient_id
INNER JOIN public."Outpatient_visit" as ov ON p.patient_id = ov.patient_id
INNER JOIN public."Lab_results" as lr ON ov.visit_id = lr.visit_id
ORDER BY patient_name ASC;

--4. How does the frequency of fasting blood sugar testing vary between gender and age group?
CREATE VIEW FBSL_freq AS 
SELECT Gender,
CASE
    WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE_OF_BIRTH)) <= 17 THEN 'Pediatric'
    WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE_OF_BIRTH)) <= 64 THEN 'Adult'
    ELSE 'Senior'
END AS Age_group,
COUNT(*) AS Test_count
FROM public."Patients_data_table" as p
INNER JOIN public."Outpatient_visit" as ov ON p.patient_id = ov.patient_id
INNER JOIN public."Lab_results" as lr ON ov.visit_id = lr.visit_id
WHERE test_name = 'Fasting Blood Sugar'
GROUP BY Gender,
CASE
    WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE_OF_BIRTH)) <= 17 THEN 'Pediatric'
    WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, DATE_OF_BIRTH)) <= 64 THEN 'Adult'
    ELSE 'Senior'
END
ORDER BY test_count;

-- 5. Which department should receive additional resources (e.g., staff, equipment) to manage a high volume of test screenings
CREATE VIEW Dept_resource AS 
SELECT hr.department_name,
COUNT(test_name) AS test_count
FROM public."Hospital_data_records" as hr
INNER JOIN public."Outpatient_visit" as ov ON hr.patient_id = ov.patient_id
INNER JOIN public."Lab_results" as lr ON ov.visit_id = lr.visit_id
GROUP BY department_name
ORDER BY test_count DESC;

--Clinical research (Present diseases and demographic characteristics of diseases)

--1. Which diagnoses are most prevalent among patients, and how do they vary across the different demographic groups, including gender and age
CREATE VIEW Demo_Freq_diagnosis AS 
SELECT p.Gender, ov.diagnosis,
CASE
    WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.DATE_OF_BIRTH)) <= 17 THEN 'Pediatric'
    WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.DATE_OF_BIRTH)) <= 64 THEN 'Adult'
    ELSE 'Senior'
END AS Age_group,
COUNT(*) AS Patient_count
FROM public."Patients_data_table" AS p
INNER JOIN public."Outpatient_visit" AS ov
ON p.patient_id = ov.patient_id
GROUP BY p.Gender, ov.diagnosis,
CASE
    WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.DATE_OF_BIRTH)) <= 17 THEN 'Pediatric'
    WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, p.DATE_OF_BIRTH)) <= 64 THEN 'Adult'
    ELSE 'Senior'
END
ORDER BY gender DESC;

--2. What are the most commonly ordered lab tests
CREATE VIEW Freq_labtest AS
SELECT test_name, COUNT(test_name) AS test_count
FROM public."Lab_results"
GROUP BY test_name
ORDER BY test_count DESC;

--3. Are there significant differences in diagnosis between smokers and non-smokers?
CREATE VIEW SMOKING_diagnosis AS 
SELECT Smoker_status,
COUNT(diagnosis) AS Diagnosis_count
FROM public."Outpatient_visit"
GROUP BY Smoker_status
ORDER BY Diagnosis_count DESC;

--4. Identify a cohort of patients with chronic diseases, including hypertension, hyperlipidemia, and diabetes.
CREATE VIEW Chronic_disease AS 
SELECT p.patient_id, p.patient_name, ov.diagnosis
FROM public."Patients_data_table" as p
INNER JOIN public."Outpatient_visit" as ov ON p.patient_id = ov.patient_id
WHERE diagnosis IN ('Hypertension', 'Hyperlipidemia', 'Diabetes'); 

--5. Investigate the most frequent reasons for patients visit to the hospital
CREATE VIEW Freq_visit AS
SELECT reason_for_visit,
COUNT(*) AS Reason_count
FROM public."Outpatient_visit"
GROUP BY reason_for_visit
ORDER BY Reason_count DESC;

--Healthcare Admin (reason for visit; appointment date and reminders)

--1. What are the most common appointment times throughout the day, and how does the distribution of appointment times vary across different hours?
CREATE VIEW Appointment_record AS
SELECT DATE_PART('hour', Appointment_time) AS Hour, COUNT(*) AS Appointment_count
FROM public."Appointment_data_analysis"
GROUP BY DATE_PART('hour', Appointment_time)
ORDER BY Appointment_count DESC;

--2. The hospital administration is interested in finding out information about the patients who had multiple visits within 30 days of their previous medical visit. Write a query to identify those patients, the date of the initial visit, the reason for the initial visit, the readmission date, the reason for readmission, and the number of days between the initial visit and readmission.
CREATE VIEW Patient_visit AS
SELECT ov_initial.patient_id, 
       ov_initial.visit_date AS initial_visit, 
       ov_readmit.visit_date AS readmit_visit, 
       ov_initial.reason_for_visit AS initial_reason, 
       ov_readmit.reason_for_visit AS readmit_reason,
       EXTRACT(DAY FROM AGE(ov_readmit.visit_date, ov_initial.visit_date)) AS days_between
FROM public."Outpatient_visit" AS ov_initial
JOIN public."Outpatient_visit" AS ov_readmit
ON ov_initial.patient_id = ov_readmit.patient_id
WHERE ov_readmit.visit_date > ov_initial.visit_date
AND ov_readmit.visit_date <= ov_initial.visit_date + INTERVAL '30 days';

--3. Compare the average number of days the patients are spending in each department of the hospital
CREATE VIEW avg_days_hosp AS
SELECT department_name,
AVG(days_in_the_hospital) AS Average_num_days
FROM public."Hospital_data_records"
GROUP BY department_name
ORDER BY Average_num_days DESC;