
--Datasource: https://www.kaggle.com/datasets/osmi/mental-health-in-tech-survey (This dataset is from a 2014 survey that measures attitudes towards mental health and frequency of mental health disorders in the tech workplace)


--Joining personal information and work information tables
CREATE VIEW JobMentalHealth AS
SELECT Age, Gender, Country, state, family_history,
treatment, self_employed, work_interfere, remote_work,
tech_company, benefits, care_options, wellness_program, seek_help,
anonymity, leave, mental_health_consequence, phys_health_consequence, coworkers,
supervisor, mental_health_interview, phys_health_interview, mental_vs_physical, obs_consequence
FROM Tech_Mental_Health..Personal_information$ PI
JOIN Tech_Mental_Health..Work_information$ WI
ON PI.ID = WI.ID 

--Full table to reference
SELECT *
FROM [dbo].[JobMentalHealth]

--Percentage of how many employees say their mental health interferes with their work (Sometimes, Rarely, Often, Never, or NA)
SELECT work_interfere, COUNT(work_interfere) AS Number_of_People_Whose_Work_Interferes_with_Mental_Health, 
COUNT(work_interfere)*100/(SELECT COUNT(*) FROM [dbo].[JobMentalHealth]) AS Percentage_of_People_Whose_Work_Interferes_with_Mental_Health
FROM [dbo].[JobMentalHealth]
GROUP BY work_interfere

--Employees who have seeked mental health treatment and if their work provides mental health benefits
SELECT benefits, COUNT(treatment) AS Number_of_People_who_Have_Sought_Mental_Health_Treatment
FROM [dbo].[JobMentalHealth]
WHERE treatment='Yes'
GROUP BY benefits
ORDER BY Number_of_People_who_Have_Sought_Mental_Health_Treatment DESC
--Answer: People are almost twice more likely to seek mental health treatment if their employer provides mental health benefits. 
--Since 36% of employees reported that their mental health interferes with their work, it's important to provide mental health benefits so employees get treatment.

--How many employees feel like there will be consequences if they disclose physical vs mental health issues
SELECT phys_health_consequence, mental_health_consequence, COUNT(*) AS Number_of_Employees, 
COUNT(*)*100/(SELECT COUNT(*) FROM [dbo].[JobMentalHealth]) AS Percentage_of_Employees
FROM [dbo].[JobMentalHealth]
GROUP BY phys_health_consequence, mental_health_consequence
ORDER BY 3 DESC
--Fourth highest percentage is employees who think there will be no consequences disclosing phyiscal health issues but there would be consequences if they disclose mental health issues