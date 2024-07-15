/*ANALYSIS*/

-- 1. What is the gender breakdown of employees in the company?

SELECT gender,COUNT(*) AS count
FROM hr
WHERE age>=18 AND termdate IS NOT NULL
GROUP BY gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?

SELECT race,COUNT(*) AS count
FROM hr
WHERE age>=18 AND termdate IS NOT NULL
GROUP BY race
ORDER BY COUNT(*);

-- 3. What is the age distribution of employees in the company?

SELECT MAX(age) ,MIN(age)
FROM hr
WHERE age>=18 AND termdate IS NOT NULL;

SELECT 
	CASE 
    WHEN age>=18 AND age<=24 THEN '18-24'
    WHEN age>=25 AND age<=34 THEN '25-34'
    WHEN age>=35 AND age<=44 THEN '35-44'
    WHEN age>=44 AND age<=54 THEN '44-54'
    WHEN age>=54 AND age<=64 THEN '54-64'
	ELSE '65+'
    END AS age_group,
	COUNT(*) as count
FROM hr
WHERE age>=18 and termdate ='0000-00-00'
GROUP BY age_group
ORDER BY age_group;

-- 4. How many employees work at headquarters versus remote locations?

SELECT location,COUNT(*)
FROM hr
WHERE age>=18 and termdate ='0000-00-00'
GROUP BY location;

-- 5. What is the average length of employment for employees who have been terminated?

SELECT 
round(avg(datediff(termdate,hire_date))/365,0) AS avg_len_emp
FROM hr
WHERE termdate<=curdate() AND termdate<>'0000-00-00' AND age>=18;

-- 6. How does the gender distribution vary across departments and job titles?

SELECT department,gender,count(*) AS count
FROM hr
WHERE age>=18 AND termdate='0000-00-00'
GROUP BY department,gender
ORDER BY department;

-- 7. What is the distribution of job titles across the company?

SELECT jobtitle,COUNT(*) AS count
FROM hr
WHERE age>=18 AND termdate='0000-00-00'
GROUP BY jobtitle
ORDER BY jobtitle;

-- 8. Which department has the highest turnover rate?

SELECT department,
terminated_count,
total_count,
terminated_count/total_count AS termination_rate
FROM(
  SELECT department,COUNT(*) AS total_count,
  SUM(CASE WHEN termdate<>'0000-00-00'  AND termdate<=CURDATE() THEN 1 ELSE 0 END)AS terminated_count
  FROM hr
  WHERE age>=18
  GROUP BY department) AS SUBQ
  ORDER BY termination_rate DESC;

-- 9. What is the distribution of employees across locations by state?
   
   SELECT location_state,COUNT(*) AS count
   FROM hr
   WHERE age>=18 AND termdate<>'0000-00-00'
   GROUP BY location_state
   ORDER BY count DESC;
   
-- 10. How has the company's employee count changed over time based on hire and term dates?

    SELECT year,
    hires,
    termination,
    ROUND((hires-termination)/hires*100,2) AS net_change_percent
    FROM(
      SELECT year(hire_date) AS year,
      COUNT(*) AS hires,
      SUM(CASE WHEN termdate<>'0000-00-00' AND termdate<=curdate() THEN 1 ELSE 0 END) AS termination
      FROM hr
      WHERE age>=18
      GROUP BY year(hire_date)
        )AS subq
 ORDER BY year ASC;     
    
-- 11. What is the tenure distribution for each department?

SELECT department,ROUND(AVG(datediff(termdate,hire_date)/365),0) AS avg_tenure
FROM hr
WHERE termdate<>'0000-00-00' AND termdate<=CURDATE() AND age>=18
GROUP BY department;