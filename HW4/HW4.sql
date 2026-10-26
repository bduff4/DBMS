/*
Brennan Duff
CSC 621
10/26
Assignment 4: Track global space missions, launch operations, rocket specifications, and payload deployment. The domain captures information across multiple normalized entities.
*/
SELECT
    missions.missionname,
    rockets.rocketname,
    organizations.orgname,
    launch_sites.sitename,
    missions.destination,
    missions.launchyear,
    missions.outcome
FROM missions
JOIN rockets
    ON missions.rocketid = rockets.rocketid
JOIN organizations
    ON rockets.orgid = organizations.orgid
JOIN launch_sites
    ON missions.siteid = launch_sites.siteid
ORDER BY missions.launchyear DESC, missions.missionname ASC;

SELECT
    missions.missionname,
    rockets.rocketname,
    payloads.payloadname,
    payloads.payloadtype,
    payloads.masskg
FROM payloads
JOIN missions
    ON payloads.missionid = missions.missionid
JOIN rockets
    ON missions.rocketid = rockets.rocketid
WHERE missions.launchyear = 2024
ORDER BY payloads.masskg DESC;

SELECT
    launch_sites.sitename,
    missions.missionname,
    rockets.rocketname,
    missions.launchyear
FROM launch_sites
LEFT JOIN missions
    ON launch_sites.siteid = missions.siteid
    AND missions.launchyear = 2024
LEFT JOIN rockets
    ON missions.rocketid = rockets.rocketid
ORDER BY launch_sites.sitename ASC;

WITH organization_payload_mass AS (
    SELECT
        organizations.orgid,
        COALESCE(SUM(payloads.masskg), 0) AS total_payload_mass
    FROM organizations
    LEFT JOIN rockets
        ON organizations.orgid = rockets.orgid
    LEFT JOIN missions
        ON rockets.rocketid = missions.rocketid
    LEFT JOIN payloads
        ON missions.missionid = payloads.missionid
    GROUP BY organizations.orgid
)
SELECT
    organizations.orgname,
    countries.countryname AS headquarters_country,
    organizations.orgtype,
    organization_payload_mass.total_payload_mass
FROM organizations
JOIN countries
    ON organizations.headquarterscountry = countries.countrycode
JOIN organization_payload_mass
    ON organizations.orgid = organization_payload_mass.orgid
ORDER BY organization_payload_mass.total_payload_mass DESC;

WITH mission_totals_by_country AS (
    SELECT
        launch_sites.countrycode,
        COUNT(missions.missionid) AS total_missions
    FROM launch_sites
    LEFT JOIN missions
        ON launch_sites.siteid = missions.siteid
    GROUP BY launch_sites.countrycode
),
payload_mass_by_country AS (
    SELECT
        launch_sites.countrycode,
        SUM(payloads.masskg) AS total_payload_mass
    FROM launch_sites
    JOIN missions
        ON launch_sites.siteid = missions.siteid
    JOIN payloads
        ON missions.missionid = payloads.missionid
    GROUP BY launch_sites.countrycode
)
SELECT
    countries.countryname,
    COALESCE(mission_totals_by_country.total_missions, 0) AS total_missions,
    COALESCE(payload_mass_by_country.total_payload_mass, 0) AS total_payload_mass
FROM countries
LEFT JOIN mission_totals_by_country
    ON countries.countrycode = mission_totals_by_country.countrycode
LEFT JOIN payload_mass_by_country
    ON countries.countrycode = payload_mass_by_country.countrycode
ORDER BY total_payload_mass DESC;



CREATE TABLE countries (
    countrycode CHAR(3) PRIMARY KEY,
    countryname VARCHAR(100),
    continent VARCHAR(50)
);

CREATE TABLE organizations (
    orgid INT PRIMARY KEY,
    orgname VARCHAR(150),
    headquarterscountry CHAR(3),
    orgtype VARCHAR(50),
    FOREIGN KEY (headquarterscountry)
        REFERENCES countries(countrycode)
);

CREATE TABLE launch_sites (
    siteid INT PRIMARY KEY,
    sitename VARCHAR(150),
    countrycode CHAR(3),
    status VARCHAR(30),
    FOREIGN KEY (countrycode)
        REFERENCES countries(countrycode)
);

CREATE TABLE rockets (
    rocketid INT PRIMARY KEY,
    rocketname VARCHAR(100),
    orgid INT,
    payloadcapacitykg INT,
    operationalstatus VARCHAR(30),
    FOREIGN KEY (orgid)
        REFERENCES organizations(orgid)
);

CREATE TABLE missions (
    missionid INT PRIMARY KEY,
    missionname VARCHAR(100),
    rocketid INT,
    siteid INT,
    destination VARCHAR(50),
    launchyear INT,
    outcome VARCHAR(30),
    FOREIGN KEY (rocketid)
        REFERENCES rockets(rocketid),
    FOREIGN KEY (siteid)
        REFERENCES launch_sites(siteid)
);

CREATE TABLE payloads (
    payloadid INT PRIMARY KEY,
    missionid INT,
    payloadname VARCHAR(150),
    payloadtype VARCHAR(50),
    masskg DOUBLE,
    FOREIGN KEY (missionid)
        REFERENCES missions(missionid)
);