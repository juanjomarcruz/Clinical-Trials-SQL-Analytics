-- 1. How many new clinical trials were registered each year?

WITH trials_per_year AS (

SELECT EXTRACT(YEAR FROM study_first_submitted_date) AS year,
       COUNT(DISTINCT(nct_id)) AS registered_studies
FROM studies
GROUP BY EXTRACT(YEAR FROM study_first_submitted_date)
ORDER BY year

), trials_per_year_ly AS( --Here we create another CTE to generate the column "ny_registered_studies".

SELECT year,
       registered_studies,
	   LAG(registered_studies) OVER(
       ORDER BY year
	   ) AS ny_registered_studies
FROM trials_per_year
WHERE year BETWEEN 2005 AND 2024

)

-- Finally, we calculate the difference in percentage year-to-year.

SELECT year,
       registered_studies,
	   ROUND((registered_studies - ny_registered_studies)*100.0/ny_registered_studies,2) AS difference
FROM trials_per_year_ly;



/* The sharp increase in registered clinical trials in 2005 was mainly due to the International Committee
of Medical Journal Editors’ new requirement that all clinical trials be registered in a public database
(like ClinicalTrials.gov) as a condition for publication. This policy drove a sudden wave of retrospective
and new registrations that year. */

/* Taking into account this event, I will filter the table to consider data from between 2005 and 2024. I will
exclude 2025 cause the year is not yet finished */


-- 2. What are the most common study phases (Phase 1–4) and how has their distribution changed by year?


SELECT phase,
       COUNT( DISTINCT nct_id ) AS study_count
FROM studies
WHERE phase != 'NA'
GROUP BY phase
ORDER BY phase;

CREATE TEMP TABLE n_phase_studies_per_year AS (

SELECT EXTRACT(YEAR FROM study_first_submitted_date) AS year,
       phase,
	   COUNT(DISTINCT nct_id) AS study_count
FROM studies
GROUP BY EXTRACT(YEAR FROM study_first_submitted_date), phase
ORDER BY EXTRACT(YEAR FROM study_first_submitted_date), phase

)

-- Evolution of total early_phase_I studies throught the years (2005 - 2024):

SELECT year,
       study_count
FROM n_phase_studies_per_year
WHERE phase = 'EARLY_PHASE1' AND year BETWEEN 2005 AND 2024;

-- Evolution of total phase_I studies throught the years (2005 - 2024):

SELECT year,
       study_count
FROM n_phase_studies_per_year
WHERE phase = 'PHASE1' AND year BETWEEN 2005 AND 2024;

-- Evolution of total phase_I/phase_II studies throught the years (2005 - 2024):

SELECT year,
       study_count
FROM n_phase_studies_per_year
WHERE phase = 'PHASE1/PHASE2' AND year BETWEEN 2005 AND 2024;

-- Evolution of phase_II studies throught the years (2005 - 2024):

SELECT year,
       study_count
FROM n_phase_studies_per_year
WHERE phase = 'PHASE2' AND year BETWEEN 2005 AND 2024;

-- Evolution of total phase_II/phase_III studies throught the years (2005 - 2024):

SELECT year,
       study_count
FROM n_phase_studies_per_year
WHERE phase = 'PHASE2/PHASE3' AND year BETWEEN 2005 AND 2024;

-- Evolution of total phase_III studies throught the years (2005 - 2024):

SELECT year,
       study_count
FROM n_phase_studies_per_year
WHERE phase = 'PHASE3' AND year BETWEEN 2005 AND 2024;

-- Evolution of total phase_IV studies throught the years (2005 - 2024):

SELECT year,
       study_count
FROM n_phase_studies_per_year
WHERE phase = 'PHASE4' AND year BETWEEN 2005 AND 2024;


-- 3. What is the average planned enrollment per phase and study type?

SELECT study_type,
       phase,
	   FLOOR(AVG(enrollment)) AS avg_enrollment,
	   FLOOR(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY enrollment)) AS median_enrollment
FROM studies
WHERE study_type = 'INTERVENTIONAL' --OBSERVATIONAL and EXPANDED_ACCESS studies do not have phases.
GROUP BY study_type, phase
ORDER BY study_type, phase;

SELECT study_type,
	   FLOOR(AVG(enrollment)) AS avg_enrollment,
	   FLOOR(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY enrollment)) AS median_enrollment
FROM studies
WHERE study_type IN ('INTERVENTIONAL','OBSERVATIONAL')
GROUP BY study_type
ORDER BY study_type;

-- 4. What proportion of studies are currently active, completed, or terminated?

WITH total_studies AS (

SELECT COUNT(DISTINCT nct_id) AS count
FROM studies

)

SELECT overall_status,
	   ROUND((COUNT (DISTINCT nct_id))*100.0/(SELECT count FROM total_studies),0) AS study_percentage
FROM studies
GROUP BY overall_status
ORDER BY(COUNT (DISTINCT nct_id))*100.0/(SELECT count FROM total_studies) DESC;

/*Another way:

WITH total_studies AS (

SELECT COUNT(DISTINCT nct_id) AS total_studies
FROM studies

)

SELECT overall_status,
	   ROUND((COUNT (DISTINCT nct_id))*100.0/t.total_studies,0) AS study_percentage
FROM studies
CROSS JOIN total_studies AS t
GROUP BY overall_status, total_studies
ORDER BY(COUNT (DISTINCT nct_id))*100.0/t.total_studies DESC; */


-- 5. How many studies are sponsored by industry vs. NIH vs. academic institutions?

SELECT agency_class,
       COUNT(DISTINCT nct_id) AS study_count
FROM sponsors
GROUP BY agency_class;


SELECT  agency_class,
        COUNT(DISTINCT nct_id) AS study_count
FROM sponsors
WHERE agency_class IN ('INDUSTRY','NIH')  -- Academic institutions are not an agency_class.
GROUP BY agency_class;

-- 6. Which sponsors have the highest number of registered studies?

-- Top 10 overall leading sponsors:

SELECT s.name AS sponsor_name,
	   s.agency_class AS sponsor_class,
	   s.lead_or_collaborator,
       COUNT(DISTINCT st.nct_id) AS study_count
FROM sponsors AS s
INNER JOIN studies AS st
ON s.nct_id = st.nct_id
WHERE s.lead_or_collaborator = 'lead'
GROUP BY s.name, s.agency_class, s.lead_or_collaborator
ORDER BY study_count DESC
LIMIT 10;

-- Top 10 overall collaborating sponsors:

SELECT s.name AS sponsor_name,
	   s.agency_class AS sponsor_class,
	   s.lead_or_collaborator,
       COUNT(DISTINCT st.nct_id) AS study_count
FROM sponsors AS s
INNER JOIN studies AS st
ON s.nct_id = st.nct_id
WHERE s.lead_or_collaborator = 'collaborator'
GROUP BY s.name, s.agency_class, s.lead_or_collaborator
ORDER BY study_count DESC
LIMIT 10;

-- Top 10 industry leading sponsors:

SELECT s.name AS sponsor_name,
	   s.agency_class AS sponsor_class,
	   s.lead_or_collaborator,
       COUNT(DISTINCT st.nct_id) AS study_count
FROM sponsors AS s
INNER JOIN studies AS st
ON s.nct_id = st.nct_id
WHERE s.lead_or_collaborator = 'lead' AND s.agency_class = 'INDUSTRY'
GROUP BY s.name, s.agency_class, s.lead_or_collaborator
ORDER BY study_count DESC
LIMIT 10;

-- Top 10 industry collaboratoring sponsors:

SELECT s.name AS sponsor_name,
	   s.agency_class AS sponsor_class,
	   s.lead_or_collaborator,
       COUNT(DISTINCT st.nct_id) AS study_count
FROM sponsors AS s
INNER JOIN studies AS st
ON s.nct_id = st.nct_id
WHERE s.lead_or_collaborator = 'collaborator' AND s.agency_class = 'INDUSTRY'
GROUP BY s.name, s.agency_class, s.lead_or_collaborator
ORDER BY study_count DESC
LIMIT 10;

-- Top 10 NIH leading sponsors:

SELECT s.name AS sponsor_name,
	   s.agency_class AS sponsor_class,
	   s.lead_or_collaborator,
       COUNT(DISTINCT st.nct_id) AS study_count
FROM sponsors AS s
INNER JOIN studies AS st
ON s.nct_id = st.nct_id
WHERE s.lead_or_collaborator = 'lead' AND s.agency_class = 'NIH'
GROUP BY s.name, s.agency_class, s.lead_or_collaborator
ORDER BY study_count DESC
LIMIT 10;

-- Top 10 NIH collaborating sponsors:

SELECT s.name AS sponsor_name,
	   s.agency_class AS sponsor_class,
	   s.lead_or_collaborator,
       COUNT(DISTINCT st.nct_id) AS study_count
FROM sponsors AS s
INNER JOIN studies AS st
ON s.nct_id = st.nct_id
WHERE s.lead_or_collaborator = 'collaborator' AND s.agency_class = 'NIH'
GROUP BY s.name, s.agency_class, s.lead_or_collaborator
ORDER BY study_count DESC
LIMIT 10;

-- Top 10 universities leading sponsors:

SELECT s.name AS sponsor_name,
	   s.agency_class AS sponsor_class,
	   s.lead_or_collaborator,
       COUNT(DISTINCT st.nct_id) AS study_count
FROM sponsors AS s
INNER JOIN studies AS st
ON s.nct_id = st.nct_id
WHERE s.lead_or_collaborator = 'lead' AND s.name ILIKE '%university%'
GROUP BY s.name, s.agency_class, s.lead_or_collaborator
ORDER BY study_count DESC
LIMIT 10;

-- Top 10 universities collaborating sponsors:

SELECT s.name AS sponsor_name,
	   s.agency_class AS sponsor_class,
	   s.lead_or_collaborator,
       COUNT(DISTINCT st.nct_id) AS study_count
FROM sponsors AS s
INNER JOIN studies AS st
ON s.nct_id = st.nct_id
WHERE s.lead_or_collaborator = 'collaborator' AND s.name ILIKE '%university%'
GROUP BY s.name, s.agency_class, s.lead_or_collaborator
ORDER BY study_count DESC
LIMIT 10;

-- Top 10 networks leading sponsors:

SELECT s.name AS sponsor_name,
	   s.agency_class AS sponsor_class,
	   s.lead_or_collaborator,
       COUNT(DISTINCT st.nct_id) AS study_count
FROM sponsors AS s
INNER JOIN studies AS st
ON s.nct_id = st.nct_id
WHERE s.lead_or_collaborator = 'lead' AND s.agency_class = 'NETWORK'
GROUP BY s.name, s.agency_class, s.lead_or_collaborator
ORDER BY study_count DESC
LIMIT 10;

-- Top 10 networks collaborating sponsors:

SELECT s.name AS sponsor_name,
	   s.agency_class AS sponsor_class,
	   s.lead_or_collaborator,
       COUNT(DISTINCT st.nct_id) AS study_count
FROM sponsors AS s
INNER JOIN studies AS st
ON s.nct_id = st.nct_id
WHERE s.lead_or_collaborator = 'collaborator' AND s.agency_class = 'NETWORK'
GROUP BY s.name, s.agency_class, s.lead_or_collaborator
ORDER BY study_count DESC
LIMIT 10;

--  7. How often do studies involve both industry and academic collaborators?


--  8. For each sponsor type, what’s the median study duration?

SELECT s.agency_class AS sponsor_class,
	   st.phase,
       ROUND(AVG((st.completion_date - st.start_date)/365),1) AS avg_duration_years,
       PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ((st.completion_date - st.start_date)/365)) AS median_duration_years
FROM sponsors AS s
INNER JOIN studies AS st
ON s.nct_id = st.nct_id
GROUP BY s.agency_class, st.phase
ORDER BY s.agency_class, st.phase, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ((st.completion_date - st.start_date)/365)) ASC;

-- 9. Which countries host the largest number of clinical trial sites?

SELECT country,
       COUNT(DISTINCT name) AS facilities_count,
	   ROUND(COUNT(DISTINCT name)*100.0/(SELECT COUNT(DISTINCT name) FROM facilities),1) AS facilities_percentage
FROM facilities
GROUP BY country
ORDER BY COUNT(DISTINCT id) DESC
LIMIT 15; -- Top 15

-- 10. How many studies are multinational vs. single-country?

WITH countries_per_study AS (

SELECT nct_id,
       COUNT(DISTINCT "name") AS country_count
FROM countries
GROUP BY nct_id
ORDER BY COUNT(DISTINCT "name") DESC

)

SELECT CASE 
           WHEN country_count = 1 THEN 'single_country'
		   ELSE 'multinational'
		   END AS category,
		   COUNT(*) AS study_count,
		   ROUND(
		   COUNT(*) * 100.0 / (SELECT COUNT(DISTINCT(nct_id)) FROM studies),0) AS study_percentage
FROM countries_per_study
GROUP BY CASE 
           WHEN country_count = 1 THEN 'single_country'
		   ELSE 'multinational' END;

-- 11. Which sponsors conduct the broadest geographic footprint of trials? 

SELECT sp.name AS sponsor,
       COUNT(DISTINCT c.name) AS country_count,
	   COUNT(DISTINCT sp.nct_id) AS study_count
FROM sponsors AS sp
INNER JOIN countries AS c
ON sp.nct_id = c.nct_id
GROUP BY sp.name
HAVING COUNT(DISTINCT c.name) > 1
ORDER BY  country_count DESC, study_count DESC;

-- Now let's take into account just those studies with 1 single sponsor.

WITH single_sponsor_studies AS (

SELECT nct_id,
       COUNT(DISTINCT name) AS sponsor_count
FROM sponsors
GROUP BY nct_id
HAVING COUNT(DISTINCT name) = 1

)

SELECT sp.name AS sponsor,
       COUNT(DISTINCT c.name) AS country_count,
	   COUNT(DISTINCT ss.nct_id) AS study_count
FROM single_sponsor_studies AS ss
INNER JOIN sponsors AS sp
ON ss.nct_id = sp.nct_id
INNER JOIN countries AS c
ON sp.nct_id = c.nct_id
GROUP BY sp.name
HAVING COUNT(DISTINCT c.name) > 1
ORDER BY  country_count DESC, study_count DESC;

-- 12. What are the top 5 most common cities for trial sites within the US and EU?
-- It is not possible to differentiate between European and US countries since the continent is not collected in the database.

SELECT city,
       COUNT (DISTINCT nct_id) AS study_count
FROM facilities
GROUP BY city
ORDER BY COUNT (DISTINCT nct_id) DESC
LIMIT 5;

-- 13. What proportion of studies use randomization vs. non-randomized allocation?

SELECT allocation,
       COUNT (DISTINCT nct_id) AS study_count,
	   ROUND(COUNT (DISTINCT nct_id)*100.0 / (SELECT  COUNT (DISTINCT nct_id) FROM designs),2) AS pct_studies
FROM designs
GROUP BY allocation
ORDER BY allocation;

-- 14. What are the most common primary purposes (treatment, prevention, diagnostic)?

SELECT primary_purpose,
       COUNT (DISTINCT nct_id) AS study_count,
	   ROUND(COUNT (DISTINCT nct_id)*100.0 / (SELECT  COUNT (DISTINCT nct_id) FROM designs),2) AS pct_studies
FROM designs
GROUP BY primary_purpose
ORDER BY COUNT (DISTINCT nct_id) DESC;

-- 15. How frequently are masking/blinding techniques applied? 

WITH study_count_per_masking AS (
SELECT masking,
       COUNT (DISTINCT nct_id) AS study_count,
	   ROUND(COUNT (DISTINCT nct_id)*100.0 / (SELECT  COUNT (DISTINCT nct_id) FROM designs),2) AS pct_studies
FROM designs
GROUP BY masking
)

SELECT SUM(study_count) AS total_studies,
	   SUM(pct_studies) AS total_pct_studies
FROM study_count_per_masking
WHERE masking <> 'NONE'
      AND masking IS NOT NULL;

-- 16. What is the average number of arms or groups per study phase?

SELECT phase,
       ROUND(AVG(number_of_arms),1) AS avg_number_of_arms
FROM studies
GROUP BY phase
ORDER BY phase;

-- 17. What are the most frequent types of interventions (drug, device, behavioral, etc.)?

SELECT intervention_type,
       COUNT (DISTINCT nct_id) AS study_count,
	   ROUND(COUNT (DISTINCT nct_id)*100.0 / (SELECT  COUNT (DISTINCT nct_id) FROM interventions),2) AS pct_studies
FROM interventions
GROUP BY intervention_type
ORDER BY COUNT (DISTINCT nct_id) DESC;

-- 18. What is the average and median age range of eligible participants per phase?

/*
SELECT s.phase,
       ROUND(AVG(e.maximum_age - e.minimum_age),1) AS avg_age_range
FROM eligibilities AS e
INNER JOIN studies AS s
ON e.nct_id = s.nct_id
GROUP BY phase
ORDER BY phase;

The above query does not work because age fields at table eligibilities are not numeric but text (Ex. "70 years")
Therefore, we need to remove the text component and then convert to numeric:
*/

WITH cleaned AS (
    SELECT 
        s.phase,
        
        -- Convertimos minimum_age a años
        CASE
            WHEN e.minimum_age ~ '^[0-9]+' THEN
                CASE
                    WHEN e.minimum_age ILIKE '%year%' THEN split_part(e.minimum_age, ' ', 1)::numeric
                    WHEN e.minimum_age ILIKE '%month%' THEN split_part(e.minimum_age, ' ', 1)::numeric / 12
                    WHEN e.minimum_age ILIKE '%week%' THEN split_part(e.minimum_age, ' ', 1)::numeric / 52
                    WHEN e.minimum_age ILIKE '%day%' THEN split_part(e.minimum_age, ' ', 1)::numeric / 365
                    ELSE NULL
                END
            ELSE NULL
        END AS min_age_years,
        
        -- Convertimos maximum_age a años
        CASE
            WHEN e.maximum_age ~ '^[0-9]+' THEN
                CASE
                    WHEN e.maximum_age ILIKE '%year%' THEN split_part(e.maximum_age, ' ', 1)::numeric
                    WHEN e.maximum_age ILIKE '%month%' THEN split_part(e.maximum_age, ' ', 1)::numeric / 12
                    WHEN e.maximum_age ILIKE '%week%' THEN split_part(e.maximum_age, ' ', 1)::numeric / 52
                    WHEN e.maximum_age ILIKE '%day%' THEN split_part(e.maximum_age, ' ', 1)::numeric / 365
                    ELSE NULL
                END
            ELSE NULL
        END AS max_age_years
        
    FROM eligibilities e
    JOIN studies s ON e.nct_id = s.nct_id
)

SELECT
    phase,
    ROUND(AVG(max_age_years - min_age_years), 1) AS avg_age_range_years
FROM cleaned
WHERE min_age_years IS NOT NULL
  AND max_age_years IS NOT NULL
GROUP BY phase
ORDER BY phase;

-- 19. What proportion of studies include only male, only female, or both genders?

SELECT gender,
       COUNT(DISTINCT nct_id) AS study_count,
	   ROUND(COUNT (DISTINCT nct_id)*100.0 / (SELECT  COUNT (DISTINCT nct_id) FROM eligibilities),2) AS pct_studies
FROM eligibilities
GROUP BY gender
ORDER BY COUNT(DISTINCT nct_id) DESC;

-- 20. What fraction of trials allow healthy volunteers vs. patient-only populations?

SELECT healthy_volunteers,
       COUNT(DISTINCT nct_id) AS study_count,
	   ROUND(COUNT (DISTINCT nct_id)*100.0 / (SELECT  COUNT (DISTINCT nct_id) FROM eligibilities),2) AS pct_studies
FROM eligibilities
GROUP BY healthy_volunteers
ORDER BY COUNT(DISTINCT nct_id) DESC;








