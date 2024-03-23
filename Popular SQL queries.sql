-- Créer la table CARS

CREATE TABLE cars
             (
                          model_id SERIAL PRIMARY KEY,
                          model_name VARCHAR(100),
                          color      VARCHAR(100),
                          brand      VARCHAR(100)
             );

-- Insérer des lignes en dupliquant certaines d'entre elles

INSERT INTO cars
            (
                        model_name,
                        color,
                        brand
            )
            VALUES
            (
                        'Civic',
                        'Blue',
                        'Honda'
            )
            ,
            (
                        'Accord',
                        'Red',
                        'Honda'
            )
            ,
            (
                        'CR-V',
                        'Black',
                        'Honda'
            )
            ,
            (
                        'Civic',
                        'Blue',
                        'Honda'
            )
            ,
            (
                        'F-150',
                        'White',
                        'Ford'
            )
            ,
            (
                        'Mustang',
                        'Red',
                        'Ford'
            )
            ,
            (
                        'Focus',
                        'Blue',
                        'Ford'
            )
            ,
            (
                        'CR-V',
                        'Black',
                        'Honda'
            )
            ,
            (
                        'Civic',
                        'Blue',
                        'Honda'
            )
            ,
            (
                        'Mustang',
                        'Red',
                        'Ford'
            );

--- Checking the dataSELECT *
FROM   cars;

---- Q1: Removing duplicate car details
-- Solution 1: creating a new table, using the DISCTINCTCREATE TABLE new_cars AS
SELECT DISTINCT model_name,
                color,
                brand
FROM            cars;SELECT *
FROM   cars;SELECT *
FROM   new_cars;


-- Solution 2: removing duplicates using HAVING and GROUP BYCREATE TABLE without_duplic_record_cars AS
SELECT   model_name,
         color,
         brand
FROM     cars
GROUP BY model_name,
         color,
         brand
HAVING   Count(*) = 1;SELECT *
FROM   without_duplic_record_cars;


-- Solution 3: removing duplicates using with Clause
WITH cte AS
(
         SELECT   model_name,
                  color,
                  brand,
                  Row_number() OVER(partition BY model_name, color, brand ORDER BY model_id) AS rang
         FROM     cars )
create TABLE using_with_cars_no_duplicates AS
SELECT model_name,
       color,
       brand
FROM   cte;


WITH cte AS
(
         SELECT   model_name,
                  color,
                  brand,
                  Row_number() OVER( partition BY model_name, color, brand ORDER BY model_id) AS rang
         FROM     cars)
SELECT *
FROM   cte;

---- Removing duplicates using subqueries
SELECT *
FROM   cars
WHERE  (
              model_name, color, brand ) IN
       (
                SELECT   model_name,
                         color,
                         brand
                FROM     cars
                GROUP BY model_name,
                         color,
                         brand
                HAVING   Count(*) = 1);

---- Identifying Duplicate rows with Self-joins
SELECT c1.model_name,
       c1.color,
       c1.brand
FROM   cars c1
JOIN   cars c2
ON     c1.model_name = c2.model_name
AND    c1.color = c2.color
AND    c1.brand = c2.brand
WHERE  c1.model_id <> c2.model_id;

--- Copying the table carsCREATE TABLE copy_cars AS
SELECT *
FROM   cars;SELECT *
FROM   copy_cars;

----
WITH cars_cte AS
(
         SELECT   model_name,
                  color,
                  brand,
                  Row_number() OVER( partition BY model_name, color, brand ORDER BY model_id) AS rang
         FROM     cars)
DELETE
FROM   copy_cars
WHERE  (
              model_name, color, brand ) IN
       (
              SELECT model_name,
                     color,
                     brand
              FROM   cars_cte
              WHERE  rang > 1)SELECT *
FROM   copy_carsSELECT *
FROM   cars;SELECT DISTINCT model_name,
                color,
                brand
FROM            cars;SELECT   model_name,
         color,
         brand
FROM     cars
GROUP BY model_name,
         color,
         brand
HAVING   Count(*) = 1;

--- Moving duplicates using subquery
SELECT model_name,
       color,
       brand
FROM  (
                SELECT   model_name,
                         color,
                         brand,
                         Row_number() OVER( partition BY model_name, color, brand ORDER BY model_id) AS rang
                FROM     cars) X
WHERE  X.rang = 1;

--- Moving duplicates using WITH CLAUSE
WITH cte_cars AS
(
         SELECT   model_id,
                  model_name,
                  color,
                  brand,
                  Row_number() OVER( partition BY model_name, color, brand ORDER BY model_id) AS rang
         FROM     cars
)
SELECT   *
FROM     cte_cars
WHERE    rang = 1
ORDER BY model_id;

--- Or by deleting from the table the duplicates

DELETE FROM cars
WHERE  model_id IN (SELECT model_id
                    FROM   (SELECT model_id,
                                   model_name,
                                   color,
                                   brand,
                                   Row_number()
                                     OVER(
                                       partition BY model_name, color, brand
                                       ORDER BY model_id) AS rang
                            FROM   cars)x
                    WHERE  x.rang > 1)

SELECT *
FROM   cars; 


---- Q2: Displaying the highest and the lowest salary corresponding to each department

select * from employee;

-- Finding the highest & the lowest salary of each department; giving results for each employee
SELECT x.emp_name,
       x.dept_name,
       x.salary,
       x.highest_salary,
       x.lowest_salary,
       CASE
         WHEN x.salary = x.highest_salary THEN
         'This employee has the highest salary of his department'
         WHEN x.salary = x.lowest_salary THEN
         'This employee has the lowest salary of his department'
       END AS salary_status
FROM   (SELECT *,
               Max(salary)
                 OVER(
                   partition BY dept_name order by salary desc) AS highest_salary,
               Min(salary)
                 OVER(
                   partition BY dept_name order by salary desc) AS lowest_salary
        FROM   employee) x; 



------ Q3: Finding the actuel distance from the given cars_travel tabme, find he actual distance travalled by each car correponding to each day

--- Creating the tables

CREATE TABLE cars_travel (
    cars VARCHAR(40),
    days VARCHAR(10),
    cumulative_distance INTEGER
);



--- Inserting data into the tale
INSERT INTO cars_travel (cars, days, cumulative_distance) VALUES
('Toyota Camry', 'Day 1', 50),
('Toyota Camry', 'Day 2', 120),
('Toyota Camry', 'Day 3', 200),
('Toyota Camry', 'Day 4', 280),
('Toyota Camry', 'Day 5', 360),
('Honda Accord', 'Day 1', 70),
('Honda Accord', 'Day 2', 140),
('Honda Accord', 'Day 3', 210),
('Honda Accord', 'Day 4', 290),
('Honda Accord', 'Day 5', 380),
('Ford Fusion', 'Day 1', 60),
('Ford Fusion', 'Day 2', 130),
('Ford Fusion', 'Day 3', 190),
('Ford Fusion', 'Day 4', 260),
('Ford Fusion', 'Day 5', 340);

-- Revsolving the statement

SELECT * FROM cars_travel;


SELECT *,
       Sum(cumulative_distance)
         OVER(
           partition BY days
           ORDER BY cumulative_distance) AS distance_travelled
FROM   cars_travel; 


SELECT *,
       (SELECT Sum(cumulative_distance)
        FROM   cars_travel AS inner_ct
        WHERE  inner_ct.days <= outer_ct.days) AS cumulative_distance
FROM   (SELECT DISTINCT days
        FROM   cars_travel order by days) AS outer_ct 
ORDER  BY days; 


--- Computing the actuel distance travelled ever single day

SELECT *,
       cumulative_distance - Lag(cumulative_distance, 1, 0)
                               OVER (
                                 partition BY cars
                                 ORDER BY days) AS distance
FROM   cars_travel; 



--- Q4: Give us the gien output

-- So let's create that table

CREATE TABLE geographic_data (
    source VARCHAR(20),
    destination VARCHAR(20),
    distance INTEGER
);


-- Inserting data into the table
-- Inserting values with some duplicates and switching between source and destination columns
INSERT INTO geographic_data (source, destination, distance)
VALUES
    ('New York', 'Los Angeles', 2800),
    ('Los Angeles', 'New York', 2800),
    ('Chicago', 'Houston', 1000),
    ('Houston', 'Chicago', 1000),
    ('San Francisco', 'Seattle', 800),
    ('Seattle', 'San Francisco', 800),
    ('Miami', 'Atlanta', 600),
    ('Atlanta', 'Miami', 600),
    ('Boston', 'Washington', 400),
    ('Washington', 'Boston', 400),
    ('New York', 'Los Angeles', 2800), -- Duplicate with switched columns
    ('Los Angeles', 'New York', 2800); -- Duplicate with switched columns


select * from geographic_data;


-- select distinct t1.source, t1.destination from geographic_data t1
-- join 
-- (select distinct destination, source from geographic_data) as t2
-- ON t1.source = t2.source AND t1.destination = t2.destination;


-- Query to select unique source-destination pairs while removing duplicates
SELECT DISTINCT Least(source, destination)    AS source,
                Greatest(source, destination) AS destination,
                distance FROM   geographic_data
ORDER  BY distance DESC; 
 
 
/**** This query still gives us duplicate pairs of (source, destinationà ***/

-- WITH cte
--      AS (SELECT *,
--                 Row_number()
--                   OVER() AS rang
--          FROM   geographic_data)
-- SELECT t1.source,
--        t1.destination,
--        t1.distance
-- FROM   cte t1
--        JOIN cte t2
--          ON t1.rang < t2.rang AND t1.source = t2.destination
--             AND t1.destination = t2.source; 


--- Alternative ---

WITH cte AS (
    SELECT
        LEAST(source, destination) AS min_location,
        GREATEST(source, destination) AS max_location,
        distance,
        ROW_NUMBER() OVER (PARTITION BY LEAST(source, destination), GREATEST(source, destination) ORDER BY source, destination) AS row_num
    FROM
        geographic_data
)
SELECT
    min_location AS source,
    max_location AS destination,
    distance
FROM
    cte
WHERE
    row_num = 1
ORDER BY
	distance DESC;



-- Q5: Ungrouping the following data 

-- Création de la table "items"
CREATE TABLE items (
    id SERIAL PRIMARY KEY,
    item_name VARCHAR(50),
    total_count INTEGER
);


-- Insertion de quelques valeurs dans la table
INSERT INTO items (item_name, total_count) VALUES
    ('Chaise', 2),
    ('Table', 5),
    ('Lampe', 3),
    ('Ordinateur portable', 1),
    ('Smartphone', 2);


-- Checkign the data
select * from items;

-- Création d'une nouvelle table "duplicated_items" pour stocker les lignes dupliquées
CREATE TABLE duplicated_items AS
SELECT i.id, item_name
FROM items i
CROSS JOIN generate_series(1, total_count) AS s(id);


select *, generate_series(1, total_count) from items

-- Sélection des lignes dupliquées
SELECT * FROM duplicated_items;

-- Method2: création d'une procédure stockée 

-- Création de la table pour stocker les lignes dupliquées
CREATE TABLE duplicated_items_new (
    id INTEGER,
    item_name VARCHAR(50),
    total_count INTEGER
);

-- Création de la procédure stockée
CREATE OR REPLACE FUNCTION duplicate_items()
RETURNS VOID AS
$$
DECLARE
    item_row RECORD;
BEGIN
    -- Parcours des lignes de la table d'origine
    FOR item_row IN SELECT * FROM items LOOP
        -- Insérer chaque ligne autant de fois que spécifié par "total_count"
        FOR i IN 1..item_row.total_count LOOP
            INSERT INTO duplicated_items_new VALUES (item_row.id, item_row.item_name, item_row.total_count);
        END LOOP;
    END LOOP;
END;
$$
LANGUAGE plpgsql;

-- Exécution de la procédure stockée pour dupliquer les lignes
CALL duplicate_items();

-- Sélection des lignes dupliquées
SELECT * FROM duplicated_items_new;


-- Another solution: using the recursive function

select * from items;


with recursive cte as(
	select id, item_name, total_count, 1 AS level
	from items
	union all
	select cte.id, cte.item_name, cte.total_count -1, level+1 AS level
	from cte 
	join items t on t.item_name = cte.item_name and t.id = cte.id
	where cte.total_count > 1
)
select id, item_name, level
from cte order by id, level;


-- Q6: we have a table called Leagues containing team_codes & team_names and we need to write queries so that every 
-- team plays with others once

-- Création de la table Leagues
CREATE TABLE MLB_league (
    team_code VARCHAR(10),
    team_name VARCHAR(40)
);

INSERT INTO MLB_league (team_code, team_name)
VALUES
    ('NYY', 'New York Yankees'),
    ('LAD', 'Los Angeles Dodgers'),
    ('BOS', 'Boston Red Sox'),
    ('CHC', 'Chicago Cubs'),
    ('SFG', 'San Francisco Giants'),
    ('STL', 'St. Louis Cardinals'),
    ('HOU', 'Houston Astros'),
    ('ATL', 'Atlanta Braves'),
    ('PHI', 'Philadelphia Phillies'),
    ('WSN', 'Washington Nationals');


-- Checking the data 
select * from MLB_league;

-- Playing with the teams 2 times time
SELECT t1.team_name AS team,
       t2.team_name AS opponent, 
	   row_number() over(partition by t1.team_name) AS rang
FROM   mlb_league t1
       JOIN mlb_league t2
         ON t1.team_code <> t2.team_code
ORDER  BY t1.team_code; 


--- Query fetching, each team playing with other teams only once


SELECT
        LEAST(t1.team_name, t2.team_name) AS team,
        GREATEST(t1.team_name, t2.team_name) AS opponent,
        ROW_NUMBER() OVER (PARTITION BY LEAST(t1.team_name, t2.team_name), GREATEST(t1.team_name, t2.team_name) ORDER BY t1.team_name, t2.team_name) AS row_num
    FROM   mlb_league t1
       JOIN mlb_league t2
         ON t1.team_code <> t2.team_code
ORDER  BY t1.team_code; 
        
-- Playing one time with each team 
SELECT t1.team_name AS team, t2.team_name AS opponent
FROM mlb_league t1
JOIN mlb_league t2 ON t1.team_code < t2.team_code;
-- Remark: the < prevents duplicate pair (team1, team2) and (team2, team1)


--- Playing 2 times with each team
SELECT t1.team_name AS team, t2.team_name AS opponent
FROM mlb_league t1
JOIN mlb_league t2 ON t1.team_code <> t2.team_code;


-- Q7: Pivoting the Rows into colms
-- Create Sales_Data table
CREATE TABLE Sales_Data (
    SalesDate DATE,
    CustomerID INT,
    Amount DECIMAL(10, 2)
);

-- Insert data into Sales_Data table
INSERT INTO Sales_Data (SalesDate, CustomerID, Amount)
VALUES 
    ('2021-01-01', 1, 100.00),
    ('2021-01-02', 2, 150.00),
    ('2021-01-03', 3, 200.00),
    ('2021-01-04', 4, 120.00),
    ('2021-01-05', 5, 180.00),
    ('2021-01-06', 6, 220.00),
    ('2021-01-07', 7, 130.00),
    ('2021-01-08', 8, 170.00),
    ('2021-01-09', 9, 250.00),
    ('2021-01-10', 10, 300.00),
    ('2021-01-11', 1, 110.00),
    ('2021-01-12', 2, 160.00),
    ('2021-01-13', 3, 210.00),
    ('2021-01-14', 4, 130.00),
    ('2021-01-15', 5, 190.00),
    ('2021-01-16', 6, 230.00),
    ('2021-01-17', 7, 140.00),
    ('2021-01-18', 8, 180.00),
    ('2021-01-19', 9, 260.00),
    ('2021-01-20', 10, 310.00);

select * from Sales_Data;


select * from emp_details
