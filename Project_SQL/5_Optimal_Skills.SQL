With skills_demand AS(
Select 
    skills_dim.skill_id,
    skills_dim.skills,
    Count(skills_job_dim.skill_id) as demand_count
From job_postings_fact
Inner Join skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
Inner Join skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
Where job_title_short= 'Data Analyst' AND
job_work_from_home='True' AND
salary_year_avg IS NOT NULL
Group by skills_dim.skill_id
), average_salary AS (
    Select
    skills_dim.skill_id, 
    skills_dim.skills,
    Round(Avg(salary_year_avg)) as avg_salary
From job_postings_fact
Inner Join skills_job_dim on job_postings_fact.job_id = skills_job_dim.job_id
Inner Join skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
Where job_title_short= 'Data Analyst' AND
salary_year_avg IS NOT NULL
AND job_work_from_home='True'
Group by skills_dim.skill_id

)

Select skills_demand.skill_id,
       skills_demand.skills,
       skills_demand.demand_count,
       average_salary.avg_salary
From skills_demand
Inner Join average_salary on skills_demand.skill_id = average_salary.skill_id
Where demand_count > 10
Order BY
avg_salary DESC,
demand_count DESC
Limit 100