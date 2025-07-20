Select 
	skills_dim.skills,
	Count(skills_job_dim.skill_id) as demand_count
From job_postings_fact
Inner Join skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
Inner Join skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
Where job_title_short= 'Data Analyst' AND
job_work_from_home='True'
Group by skills_dim.skills
Order by demand_count Desc
Limit 5