# Healthcare System Assessment

### Introduction
Healthcare systems rely on proper assessment to improve patient care, optimize operations, and enhance clinical outcomes. This is neccessary to provide personalized medicine, prevent adverse effects, and ensure the efficient allocation of resources.

---

### Project goal
The goal of this project was to conduct a comprehensive healthcare assessment and analyze clinical outcomes using available patient data. This will address critical areas within the healthcare system such as population health management, clinical research, and administrative efficiency. 

### Objectives

The project is structured around investigating several key areas using SQL:

- **Patient Care (Risk Factors)**: Focusing on identifying patients at risk based on specific clinical indicators such as blood sugar levels, cardiovascular risk factors, BMI, hyperlipidemia, medication interactions, and family history of hypertension. The aim is to enable early identification and intervention.

- **Population Demographics**: Analyzing the distribution of patients within the healthcare system based on age and gender, understanding departmental admissions, and examining the frequency of specific tests across demographic groups to inform resource allocation.

- **Clinical Research**: Investigating the prevalence of various diagnoses, their distribution across demographic groups, identifying commonly ordered lab tests, exploring the correlation between smoking status and health outcomes, identifying cohorts with chronic diseases, and analyzing the trends of specific diagnoses over time to support clinical understanding and research.

- **Healthcare Administration**: Focusing on operational aspects such as analyzing appointment times, identifying patients with multiple visits within a short period (readmissions), optimizing the scheduling of follow-up tests, and comparing patient lengths of stay across different departments to improve efficiency and patient flow.

### Data sources
- Hospital records dataset in a csv file containing patients' medical history.
- Lab result dataset in a csv file containing records of patient's lab results.
- Outpatient visit dataset in a csv file containing records of patients' with thier doctor check-ups.
- Appointment analysis dataset in a csv file containing records of patients' date and time of appointment.
- Patients Record dataset in a csv file containing records of patients' biodata.

### Tool used
- Excel -Formatted dataset to be loaded into the database.
- Postgresql - Created database, data cleaning and analysis.

### Data Cleaning
All csv files where formatted properly in Excel. The Database and tables where created in Postgresql. The data which was loaded into each table. The datasets were assessed thoroughly for duplicates and null values before analysis.

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
### Data Analysis and insights
Analysis was primarily performed in Postgresql and is included in the sql file. Insights generated from the analysis are shown below:

**1. Patient care**
- 17 patients had abnormal glucose levels.
- Majority (389) of the patients had low risk for CVDs.
- 90 patients had high risk of developing obesity.
- 18 pateints where at risk based on smoking while taking medications.
- Majority of patients had low risk for CVDs based on BMI and genetics.

**2. Population demodraphics**
- Adult females where the most patients while male childern where the least.
- Oncology department had the most patient admission (22) while Paediatrics department had the least (9).
- Adult females had the most fastinf blood sugar tests while Senior men had the least.
- Cardiology would need additional resources to manage high volume of tests.

**3. Clinical research**
- Diabetes was most prevalent among men and women.
- Chloride and Fasting blood sugar tests were the most commonly ordered lab tests.
- 83% of patients in the hospital were non-smokers while the remaining 16% were smokers.
- Fever was the main reason why patients visited the hospital.

**4. Healthcare Administration**
- 12pm was the most frequent appointment time through the day at the hospital.
- Cardiology was the department with the most number of admission days while Dermatology was the least.

### Recommendation
- Improve bed management and provide additional resources for cardiology and oncology department.
- Reduce unneccessary admission days.
- High rate of fever- related visits would require adequate public health monitoring.
- Early intervension, follow-up and health education would be needed for diabetic and obese patients.
- Incorporate telemedicine to monitor patient medication safety.

### Conclusion
This project has provided valuable insights into patient care, population demographics, clinical research trends, and administrative efficiency. Through a comprehensive data analysis in PostgreSQL, the project identified critical risk factors, highlighted resource-intensive departments, and revealed patterns in patient behavior and diagnosis. Continued monitoring, early interventions, and strategic resource allocation will be essential in improving overall healthcare delivery.
