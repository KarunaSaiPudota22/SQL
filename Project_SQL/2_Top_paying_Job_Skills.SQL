
With top_paying_jobs AS (

Select job_id,
    job_title,
    salary_year_avg,
    name as company_name
From job_postings_fact
    Left Join company_dim on job_postings_fact.company_id = company_dim.company_id
WHERE job_title_short =('Data Analyst')
    AND job_location = 'Anywhere'
    AND salary_year_avg is not null
ORDER BY salary_year_avg DESC
LIMIT 10
)

Select 
top_paying_jobs.*,
skills
job_id
From top_paying_jobs
Inner Join skills_job_dim on top_paying_jobs.job_id = skills_job_dim.job_id
Inner Join skills_dim on skills_job_dim.skill_id = skills_dim.skill_id
Order BY
salary_year_avg DESC;

