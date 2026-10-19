
--Step 2 : Load data from CSV files into our table

SELECT '=== LOADING company_dim TABLE ===' AS info;

INSERT INTO company_dim (company_id,name)
SELECT company_id, name
FROM read_csv('https://storage.googleapis.com/sql_de/company_dim.csv',
    AUTO_DETECT=true);

SELECT '=== LOADING skills_dim TABLE ===' AS info;

INSERT INTO skills_dim(skill_id, skills, type)
SELECT skill_id, skills, type
FROM read_csv('https://storage.googleapis.com/sql_de/skills_dim.csv',
    AUTO_DETECT=true);

SELECT '=== LOADING job_postings_fact TABLE ===' AS info;

INSERT INTO job_postings_fact(
    job_id,
    company_id,
    job_title_short,
    job_title,
    job_location,
    job_via,
    job_schedule_type,
    job_work_from_home,
    search_location,
    job_posted_date,
    job_no_degree_mention,
    job_health_insurance,
    job_country,
    salary_year_avg,
    salary_hour_avg
)
SELECT     
    job_id,
    company_id,
    job_title_short,
    job_title,
    job_location,
    job_via,
    job_schedule_type,
    job_work_from_home,
    search_location,
    job_posted_date,
    job_no_degree_mention,
    job_health_insurance,
    job_country,
    salary_year_avg,
    salary_hour_avg
FROM read_csv('https://storage.googleapis.com/sql_de/job_postings_fact.csv',
    AUTO_DETECT=true);

SELECT '=== LOADING skills_job_dim TABLE ===' AS info;

INSERT INTO skills_job_dim(skill_id,job_id)
SELECT skill_id,job_id
FROM read_csv('https://storage.googleapis.com/sql_de/skills_job_dim.csv',
    AUTO_DETECT=true);


-- DATA VALIDATION 
-- Table Name & Record Count
SELECT 'Company DIM' AS table_name,COUNT(*) AS record_count from company_dim
UNION ALL
SELECT 'Skills DIM' AS table_name,COUNT(*) AS record_count from skills_dim
UNION ALL 
SELECT 'Job Postings Fact' AS table_name,COUNT(*) AS record_count from job_postings_fact
UNION ALL
SELECT 'Skills Job DIM' AS table_name,COUNT(*) AS record_count from skills_job_dim;

-- Tables Samples

SELECT ' === Company Dimension Sample === ' AS info;
SELECT * FROM company_dim LIMIT 5;

SELECT ' === Skills Dimension Sample === ' AS info;
SELECT * FROM skills_dim LIMIT 5;

SELECT ' === Jobs Posting Fact Dimension Sample === ' AS info;
SELECT * FROM job_postings_fact LIMIT 5;

SELECT ' === Skills Job Dim Dimension Sample === ' AS info;
SELECT * FROM skills_job_dim LIMIT 5;


