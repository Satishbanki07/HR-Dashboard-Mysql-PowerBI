USE project;

SELECT * FROM hr;
ALTER TABLE hr
CHANGE COLUMN ï»¿id emp_id varchar(20) NULL;
 
 SELECT * FROM hr;
 DESCRIBE hr;
 SELECT birthdate from hr;
 
 SET sql_safe_updates=0;
 
 UPDATE hr
 SET birthdate=CASE
  WHEN birthdate LIKE "%/%" THEN date_format(str_to_date(birthdate,"%m/%d/%Y"),"%Y-%m-%d")
  WHEN birthdate LIKE "%-%" THEN date_format(str_to_date(birthdate,"%m-%d-%Y"),"%Y-%m-%d")
  ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN birthdate Date;

UPDATE hr
 SET hire_date=CASE
  WHEN hire_date LIKE "%/%" THEN date_format(str_to_date(hire_date,"%m/%d/%Y"),"%Y-%m-%d")
  WHEN hire_date LIKE "%-%" THEN date_format(str_to_date(hire_date,"%m-%d-%Y"),"%Y-%m-%d")
  ELSE NULL
END;

ALTER TABLE hr
MODIFY COLUMN hire_date date;

SELECT hire_date from hr;

UPDATE hr
SET termdate = IF(termdate IS NOT NULL AND termdate != '', date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC')), '0000-00-00')
WHERE true; 

SELECT termdate from hr;

SET sql_mode = 'ALLOW_INVALID_DATES';

ALTER TABLE hr
MODIFY COLUMN termdate date;

ALTER TABLE hr 
ADD COLUMN age INT;

UPDATE hr
SET age=timestampdiff(YEAR,birthdate,CURDATE());

SELECT age FROM hr;

SELECT max(age) as oldest,min(age) as youngest
FROM hr;

SELECT COUNT(*) FROM hr
WHERE age<18;

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




