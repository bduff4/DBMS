/*
Brennan Duff
Database Management Systems
10/6/2026
Assignment 3, This assignment utilizes a relational database model designed to track global power generation infrastructure, operational management, and environmental impact
*/
SELECT power_plants.plantname,
       countries.countryname,
       operators.operatorname,
       fuel_types.fuelcategory,
       fuel_types.fuelname,
       power_plants.capacitymw,
       power_plants.commissionyear
FROM power_plants
JOIN countries
    ON power_plants.countrycode = countries.countrycode
JOIN operators
    ON power_plants.operatorid = operators.operatorid
JOIN fuel_types
    ON power_plants.fuelid = fuel_types.fuelid
ORDER BY power_plants.capacitymw DESC;

SELECT power_plants.plantname,
       power_plants.countrycode,
       generation_records.year,
       generation_records.generationgwh
FROM power_plants
JOIN generation_records
    ON power_plants.plantid = generation_records.plantid
WHERE generation_records.year = 2024
ORDER BY generation_records.generationgwh DESC;

SELECT power_plants.plantname,
       power_plants.countrycode,
       generation_records.year,
       generation_records.generationgwh,
       emission_metrics.co2emissionstonnes
FROM power_plants
JOIN generation_records
    ON power_plants.plantid = generation_records.plantid
JOIN emission_metrics
    ON generation_records.plantid = emission_metrics.plantid
    AND generation_records.year = emission_metrics.year
WHERE generation_records.year = 2024
ORDER BY emission_metrics.co2emissionstonnes ASC;

WITH total_generation AS (
    SELECT power_plants.operatorid,
           SUM(generation_records.generationgwh) AS totalgeneration
    FROM power_plants
    JOIN generation_records
        ON power_plants.plantid = generation_records.plantid
    GROUP BY power_plants.operatorid
)
SELECT operators.operatorname,
       operators.headquarterscountry,
       total_generation.totalgeneration
FROM total_generation
JOIN operators
    ON total_generation.operatorid = operators.operatorid
ORDER BY total_generation.totalgeneration DESC;

WITH country_generation AS (
    SELECT power_plants.countrycode,
           SUM(generation_records.generationgwh) AS totalgeneration
    FROM power_plants
    JOIN generation_records
        ON power_plants.plantid = generation_records.plantid
    GROUP BY power_plants.countrycode
),
country_emissions AS (
    SELECT power_plants.countrycode,
           SUM(emission_metrics.co2emissionstonnes) AS totalemissions
    FROM power_plants
    JOIN emission_metrics
        ON power_plants.plantid = emission_metrics.plantid
    GROUP BY power_plants.countrycode
)
SELECT countries.countryname,
       country_generation.totalgeneration,
       country_emissions.totalemissions
FROM countries
JOIN country_generation
    ON countries.countrycode = country_generation.countrycode
JOIN country_emissions
    ON countries.countrycode = country_emissions.countrycode
ORDER BY country_generation.totalgeneration DESC;


CREATE TABLE countries (
    countrycode VARCHAR(10),
    countryname VARCHAR(100),
    continent VARCHAR(50)
);

CREATE TABLE operators (
    operatorid INT,
    operatorname TEXT,
    headquarterscountry TEXT
);

CREATE TABLE fuel_types (
    fuelid INT,
    fuelcategory TEXT,
    fuelname TEXT
);

CREATE TABLE power_plants (
    plantid INT,
    plantname TEXT,
    countrycode VARCHAR(10),
    operatorid INT,
    fuelid INT,
    capacitymw DOUBLE,
    commissionyear YEAR
);

CREATE TABLE generation_records (
    plantid INT,
    year YEAR,
    generationgwh DOUBLE
);

CREATE TABLE emission_metrics (
    plantid INT,
    year YEAR,
    co2emissionstonnes DOUBLE
);




ALTER TABLE countries
ADD PRIMARY KEY (countrycode);

ALTER TABLE operators
ADD PRIMARY KEY (operatorid);

ALTER TABLE fuel_types
ADD PRIMARY KEY (fuelid);

ALTER TABLE power_plants
ADD PRIMARY KEY (plantid);

ALTER TABLE generation_records
ADD PRIMARY KEY (plantid, year);

ALTER TABLE emission_metrics
ADD PRIMARY KEY (plantid, year);




ALTER TABLE power_plants
ADD CONSTRAINT fk_power_plants_country
FOREIGN KEY (countrycode)
REFERENCES countries(countrycode);

ALTER TABLE power_plants
ADD CONSTRAINT fk_power_plants_operator
FOREIGN KEY (operatorid)
REFERENCES operators(operatorid);

ALTER TABLE power_plants
ADD CONSTRAINT fk_power_plants_fuel
FOREIGN KEY (fuelid)
REFERENCES fuel_types(fuelid);

ALTER TABLE generation_records
ADD CONSTRAINT fk_generation_records_plant
FOREIGN KEY (plantid)
REFERENCES power_plants(plantid);

ALTER TABLE emission_metrics
ADD CONSTRAINT fk_emission_metrics_plant
FOREIGN KEY (plantid)
REFERENCES power_plants(plantid);
