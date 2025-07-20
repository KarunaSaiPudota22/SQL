Select job_id,
       job_title,
       job_location,
       job_schedule_type,
       salary_year_avg,
       job_posted_date,
       name as company_name
From job_postings_fact
Left Join company_dim on job_postings_fact.company_id= company_dim.company_id
WHERE job_title_short('Data Analyst' ) AND 
      job_location= 'Anywhere' AND
      salary_year_avg is not null
ORDER BY salary_year_avg DESC
LIMIT 10;

       