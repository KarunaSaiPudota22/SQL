Select 
	skills_dim.skills,
	Round(Avg(salary_year_avg)) as avg_salary
From job_postings_fact
Inner Join skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
Inner Join skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
Where job_title_short= 'Data Analyst' AND
salary_year_avg IS NOT NULL
AND job_work_from_home='True'
Group by skills_dim.skills
Order by avg_salary Desc
Limit 30