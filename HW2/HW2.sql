/*
Brennan Duff
CSC 621
9/22/26
Assignment 2 Building a Small Relational Model in MySQL
*/
SELECT category, AVG(price) AS average_price
FROM pastries
GROUP BY category;

SELECT experience_level, COUNT(*) AS total_baristas
FROM baristas
GROUP BY experience_level;

SELECT city, COUNT(*) AS total_shops
FROM shops
GROUP BY city;

SELECT category, MAX(price) AS maximum_price
FROM pastries
GROUP BY category;

SELECT shopID, COUNT(*) AS pastry_count
FROM offers
GROUP BY shopID;

SELECT name, category, price
FROM pastries p
WHERE price = (
    SELECT MAX(price)
    FROM pastries
    WHERE category = p.category
);

SELECT DISTINCT o.shopID
FROM offers o
JOIN pastries p
    ON o.pastryID = p.pastryID
WHERE p.price > (
    SELECT AVG(price)
    FROM pastries
);

SELECT shopID, pastryID
FROM offers
WHERE date_added = (
    SELECT MIN(date_added)
    FROM offers
);

SELECT shopID
FROM offers
GROUP BY shopID
HAVING COUNT(*) = (
    SELECT MAX(pastry_count)
    FROM (
        SELECT shopID, COUNT(*) AS pastry_count
        FROM offers
        GROUP BY shopID
    ) AS shop_counts
);

SELECT name
FROM baristas
WHERE baristaID IN (
    SELECT baristaID
    FROM employs
    WHERE shopID IN (
        SELECT shopID
        FROM shops
        WHERE city = 'Seattle'
    )
);
