# Healthcare System Assessment

### Introduction
Healthcare systems rely on proper assessment to improve patient care, optimize operations, and enhance clinical outcomes. This is neccessary to provide personalized medicine, prevent adverse effects, and ensure the efficient allocation of resources.

### Project goal
The goal of this project was to conduct a comprehensive healthcare assessment and analyze clinical outcomes using available patient data. This will address critical areas within the healthcare system such as population health management, clinical research, and administrative efficiency. 

### Objectives

The project is structured around investigating several key areas using SQL:

- **Patient Care (Risk Factors)**: Focusing on identifying patients at risk based on specific clinical indicators such as blood sugar levels, cardiovascular risk factors, BMI, hyperlipidemia, medication interactions, and family history of hypertension. The aim is to enable early identification and intervention.

- **Population Demographics**: Analyzing the distribution of patients within the healthcare system based on age and gender, understanding departmental admissions, and examining the frequency of specific tests across demographic groups to inform resource allocation.

- **Clinical Research**: Investigating the prevalence of various diagnoses, their distribution across demographic groups, identifying commonly ordered lab tests, exploring the correlation between smoking status and health outcomes, identifying cohorts with chronic diseases, and analyzing the trends of specific diagnoses over time to support clinical understanding and research.

- **Healthcare Administration**: Focusing on operational aspects such as analyzing appointment times, identifying patients with multiple visits within a short period (readmissions), optimizing the scheduling of follow-up tests, and comparing patient lengths of stay across different departments to improve efficiency and patient flow.

### Data sources
- Hospital records dataset in a csv file containing patients' medical history
- Lab result dataset in a csv file containing records of patient's lab results
- Outpatient visit dataset in a csv file containing records of patients' with thier doctor check-ups
- Appointment analysis dataset in a csv file containing records of patients' date and time of appointment
- Patients Record dataset in a csv file containing records of patients' biodata

### Tool used
- Excel -Formatted dataset to be loaded into the database
- Postgresql - Created database, data cleaning and analysis

### Data Cleaning
The datasets were assessed thoroughly for duplicates and null values before analysis. 
	``` sql
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
	```
