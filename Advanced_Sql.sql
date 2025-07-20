Create Database Project_SQL;

-- Create company_dim table with primary key
CREATE TABLE public.company_dim
(
    company_id INT PRIMARY KEY,
    name TEXT,
    link TEXT,
    link_google TEXT,
    thumbnail TEXT
);

-- Create skills_dim table with primary key
CREATE TABLE public.skills_dim
(
    skill_id INT PRIMARY KEY,
    skills TEXT,
    type TEXT
);

-- Create job_postings_fact table with primary key
CREATE TABLE public.job_postings_fact
(
    job_id INT PRIMARY KEY,
    company_id INT,
    job_title_short VARCHAR(255),
    job_title TEXT,
    job_location TEXT,
    job_via TEXT,
    job_schedule_type TEXT,
    job_work_from_home BOOLEAN,
    search_location TEXT,
    job_posted_date TIMESTAMP,
    job_no_degree_mention BOOLEAN,
    job_health_insurance BOOLEAN,
    job_country TEXT,
    salary_rate TEXT,
    salary_year_avg NUMERIC,
    salary_hour_avg NUMERIC,
    FOREIGN KEY (company_id) REFERENCES public.company_dim (company_id)
);

-- Create skills_job_dim table with a composite primary key and foreign keys
CREATE TABLE public.skills_job_dim
(
    job_id INT,
    skill_id INT,
    PRIMARY KEY (job_id, skill_id),
    FOREIGN KEY (job_id) REFERENCES public.job_postings_fact (job_id),
    FOREIGN KEY (skill_id) REFERENCES public.skills_dim (skill_id)
);

-- Set ownership of the tables to the postgres user
ALTER TABLE public.company_dim OWNER to postgres;
ALTER TABLE public.skills_dim OWNER to postgres;
ALTER TABLE public.job_postings_fact OWNER to postgres;
ALTER TABLE public.skills_job_dim OWNER to postgres;

-- Create indexes on foreign key columns for better performance
CREATE INDEX idx_company_id ON public.job_postings_fact (company_id);
CREATE INDEX idx_skill_id ON public.skills_job_dim (skill_id);
CREATE INDEX idx_job_id ON public.skills_job_dim (job_id);

copy company_dim
FROM 'D:\csv_files\company_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

copy skills_dim
FROM 'd:\csv_files\skills_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

copy job_postings_fact
FROM 'D:\csv_files\job_postings_fact.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

copy skills_job_dim
FROM 'D:\csv_files\skills_job_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

SELECT job_posted_date
From job_postings_fact
LIMIT 10;

SELECT 
Count(job_id) AS count_job_postings,
    EXTRACT(MONTH FROM job_posted_date) AS Month_number
FROM job_postings_fact
where job_title_short='Data Analyst'
GROUP BY Month_number
ORDER BY count_job_postings DESC;

-- Jobs posted in January

--CREATE TABLE January_Jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 1;

CREATE TABLE February_Jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 2;

CREATE TABLE March_Jobs AS
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

SELECT 
    COUNT(job_id) AS count_job_postings,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS job_location_Category
FROM job_postings_fact
WHERE job_title_short IN ('Data Analyst')
GROUP BY job_location_Category;

-- Jobs posted in January
Select *
From (
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) As January_Jobs;

With January_Jobs As (Select *
From job_postings_fact
Where EXTRACT(MONTH FROM job_posted_date) = 1)

Select *
From January_Jobs

Select 
company_id,
name As companyname
From company_dim
where company_id IN (
Select company_id
From job_postings_fact
Where job_no_degree_mention = true
Order by company_id)

With company_job_count as (
Select company_id,
Count(*) as count_job_postings
From job_postings_fact
Group by company_id
)

Select 
company_dim.name as companyname,
company_job_count.count_job_postings 
From company_dim
left join company_job_count on company_dim.company_id = company_job_count.company_id


WITH Remote_jobs AS (
    SELECT skill_id, COUNT(*) AS Skills_to_job
    FROM skills_job_dim AS Skills_to_job
    INNER JOIN job_postings_fact AS job_postings ON job_postings.job_id = Skills_to_job.job_id
    WHERE job_postings.job_work_from_home = true And job_title_short='Data Analyst'
    GROUP BY skill_id
)
SELECT 
    skills_dim.skill_id AS skill_id,
    skills_dim.skills AS skillname,
    Remote_jobs.Skills_to_job
FROM Remote_jobs
INNER JOIN skills_dim ON skills_dim.skill_id = Remote_jobs.skill_id
Order by Skills_to_job DESC
limit 10;
Select 
quarter_1_jobs.job_title_short,
quarter_1_jobs.job_location,
quarter_1_jobs.job_via,
quarter_1_jobs.job_posted_date::DATE,
quarter_1_jobs.salary_year_avg
From
(
    Select *
    From January_Jobs
    Union ALL
    Select *
    From February_Jobs
    UNION all
    Select *
    From March_Jobs
) AS quarter_1_jobs
Where salary_year_avg > 70000 And
 job_title_short='Machine Learning Engineer'
 Order By salary_year_avg DESC;