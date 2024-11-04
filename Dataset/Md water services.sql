USE md_water_services;

/*Start by retrieving the first few records from each table. How many tables are there in our database? 
What are the names of these tables? Once you've identified the tables, write a SELECT statement to retrieve the first 
five records from each table. As you look at the data, take note of the columns and their respective data types in each table. 
What information does each table contain?*/
SHOW tables;

/*So let's have a look at one of these tables, Let's use location so we can use that killer query, 
SELECT * but remember to limit it and tell it which table we are looking at.*/
SELECT 
    *
FROM
    location
LIMIT 5;

-- Ok, so let's look at the visits table.
SELECT 
    *
FROM
    visits
LIMIT 5;

-- Ok, so let's look at the water_source table to see what a 'source' is. Normally "_id" columns are related to another table.
SELECT 
    *
FROM
    water_source
LIMIT 10;

/*Now that you're familiar with the structure of the tables, let's dive deeper. We need to understand the types of water sources we're
dealing with. Can you figure out which table contains this information?*/

SELECT DISTINCT
			type_of_water_source
FROM
	water_source;

/* 3. Unpack the visits to water sources:
We have a table in our database that logs the visits made to different water sources. Can you identify this table?
Write an SQL query that retrieves all records from this table where the time_in_queue is more than some crazy time, say 500 min. How
would it feel to queue 8 hours for water?*/
SELECT
	*
FROM
	visits
WHERE
	time_in_queue > 500
LIMIT 10;

/* I am wondering what type of water sources take this long to queue for. We will have to find that information in another table that lists
the types of water sources. If I remember correctly, the table has type_of_water_source, and a source_id column. So let's write
down a couple of these source_id values from our results, and search for them in the other table.
AkKi00881224
SoRu37635224
SoRu36096224
If we just select the first couple of records of the visits table without a WHERE filter, we can see that some of these rows also have 0
mins queue time. So let's write down one or two of these too*/
SELECT * 
FROM 
	water_source
WHERE 
	source_id = 'AkKi00881224';
    
SELECT * 
FROM 
	water_source
WHERE 
	source_id = 'SoRu37635224';
    
SELECT * 
FROM 
	water_source
WHERE 
	source_id = 'SoRu36096224';
    
SELECT 
    *
FROM
    visits
LIMIT 10;

/* I chose these two:
AkRu05234224
HaZa21742224
Ok, so now back to the water_source table. Let's check the records for those source_ids. You can probably remember there is a cool
and a "not so cool" way to do it.*/
SELECT * 
FROM 
	water_source
WHERE 
	source_id = 'AkRu05234224';
    
SELECT * 
FROM 
	water_source
WHERE 
	source_id = 'HaZa21742224';

/* 4. Assess the quality of water sources:
The quality of our water sources is the whole point of this survey. We have a table that contains a quality score for each visit made
about a water source that was assigned by a Field surveyor. They assigned a score to each source from 1, being terrible, to 10 for a
good, clean water source in a home. Shared taps are not rated as high, and the score also depends on how long the queue times are.
Look through the table record to find the table.*/
SELECT * 
FROM 
	water_quality
LIMIT 10;

SELECT 
    *
FROM
    visits
WHERE visit_count > 1;

/* So please write a query to find records where the subject_quality_score is 10 -- only looking for home taps -- and where the source
was visited a second time. What will this tell us?*/
SELECT *
FROM water_source
WHERE type_of_water_source = 'tap_in_home';

SELECT *
FROM water_quality
WHERE subjective_quality_score = 10 AND visit_count > 1;


SELECT * 
FROM 
	well_pollution
LIMIT 10;

-- So, write a query that checks if the results is Clean but the biological column is > 0.01.
SELECT * 
FROM 
	well_pollution
WHERE results = 'Clean'
AND biological > 0.01;

-- First, let's look at the descriptions. We need to identify the records that mistakenly have the word Clean in the description. However, it
-- is important to remember that not all of our field surveyors used the description to set the results – some checked the actual data.

SELECT * 
FROM 
	well_pollution_copy
WHERE description LIKE 'Clean%'
AND biological > 0.01;

/* Ok, so here is how I did it:
−− Case 1a: Update descriptions that mistakenly mention
`Clean Bacteria: E. coli` to `Bacteria: E. coli`
−− Case 1b: Update the descriptions that mistakenly mention
`Clean Bacteria: Giardia Lamblia` to `Bacteria: Giardia Lamblia
−− Case 2: Update the `result` to `Contaminated: Biological` where
`biological` is greater than 0.01 plus current results is `Clean`
*/
CREATE TABLE well_pollution_copy AS
SELECT * FROM well_pollution;

UPDATE
	well_pollution_copy
SET 
	description = 'Bacteria: E. coli'
WHERE
	description = 'Clean Bacteria: E. coli';
    
SET SQL_SAFE_UPDATE_MODE = 0;

UPDATE
well_pollution_copy
SET
description = 'Bacteria
: Giardia Lamblia'
WHERE
description = 'Clean Bacteria: Giardia Lamblia';

UPDATE
well_pollution_copy
SET
results = 'Contaminated
: Biological'
WHERE
biological > 0.01 AND results = 'Clean';

SELECT
*
FROM
well_pollution_copy
WHERE
description LIKE "Clean_%"
OR (results = "Clean" AND biological > 0.01);

-- Then if we're sure it works as intended, we can change the table back to the well_pollution and delete the well_pollution_copy
-- table.
UPDATE
well_pollution_copy
SET
description = 'Bacteria: E. coli'
WHERE
description = 'Clean Bacteria: E. coli';
UPDATE
well_pollution_copy
SET
description = 'Bacteria: Giardia Lamblia'
WHERE
description = 'Clean Bacteria: Giardia Lamblia';
UPDATE
well_pollution_copy
SET
results = 'Contaminated: Biological'
WHERE
biological > 0.01 AND results = 'Clean';
DROP TABLE
md_water_services.well_pollution_copy;





    

