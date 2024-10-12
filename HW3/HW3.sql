-- List names and sellers of products that are no longer available (quantity=0)
SELECT p.name AS product_name, m.name AS seller_name
FROM products p
JOIN sell s ON p.pid = s.pid  -- Joining products with sell table based on product ID
JOIN merchants m ON s.mid = m.mid  -- Joining with merchants to get seller information
WHERE s.quantity_available = 0;  -- Only products with quantity available as 0

-- List names and descriptions of products that are not sold.
SELECT p.name, p.description
FROM products p
LEFT JOIN sell s ON p.pid = s.pid  -- Left join to find products not linked in sell table
WHERE s.pid IS NULL;  -- Filtering products with no corresponding entry in the sell table

-- How many customers bought SATA drives but not any routers?
SELECT COUNT(DISTINCT c.cid) AS customer_count
FROM customers c
JOIN place pl ON c.cid = pl.cid  -- Joining customers with their orders
JOIN contain co ON pl.oid = co.oid  -- Linking orders with the products they contain
JOIN products p1 ON co.pid = p1.pid  -- Joining to get the product information
WHERE p1.description LIKE '%SATA%'  -- Filtering for SATA drives
AND NOT EXISTS (
    -- Subquery checking that the same order does not contain any Router
    SELECT 1
    FROM contain co2
    JOIN products p2 ON co2.pid = p2.pid
    WHERE co2.oid = pl.oid AND p2.name = 'Router'
);

-- HP has a 20% sale on all its Networking products. FAILED 
UPDATE sell
SET price = price * 1.2
WHERE pid IN (
    SELECT subquery.pid
    FROM (
        SELECT DISTINCT s.pid
        FROM sell s
        JOIN products p ON s.pid = p.pid
        JOIN merchants m ON s.mid = m.mid
        WHERE m.name = 'HP' AND p.category = 'Networking'
    ) AS subquery
);


-- What did Uriel Whitney order from Acer? (make sure to at least retrieve product names and prices).
SELECT DISTINCT p.name AS product_name, s.price
FROM customers c
JOIN place pl ON c.cid = pl.cid   -- Join customers with their orders
JOIN contain co ON pl.oid = co.oid -- Join orders with the products contained in those orders
JOIN products p ON co.pid = p.pid  -- Join products to get product details
JOIN sell s ON p.pid = s.pid       -- Join sell to get the price of the products
JOIN merchants m ON s.mid = m.mid   -- Join merchants to get seller information
WHERE c.cid = 1 AND m.name = 'Acer'; -- Filter for orders made by Uriel Whitney from Acer



-- List the annual total sales for each company (sort the results along the company and the year attributes).
SELECT m.name AS company, 
       EXTRACT(YEAR FROM pl.order_date) AS year, 
       SUM(s.price) AS total_sales -- Sum the price from the sell table
FROM merchants m
JOIN sell s ON m.mid = s.mid        -- Join merchants with the products they sell
JOIN contain co ON s.pid = co.pid   -- Join sell with contain to relate products to orders
JOIN place pl ON co.oid = pl.oid     -- Join contain with place to get order details
GROUP BY m.name, EXTRACT(YEAR FROM pl.order_date) -- Group by company and year
ORDER BY m.name, year;               -- Sort results by company and year

-- Which company had the highest annual revenue and in what year?
SELECT m.name AS company, 
       EXTRACT(YEAR FROM pl.order_date) AS year, 
       SUM(s.price) AS total_sales -- Sum the price from the sell table
FROM merchants m
JOIN sell s ON m.mid = s.mid        -- Join merchants with the products they sell
JOIN contain co ON s.pid = co.pid   -- Join sell with contain to relate products to orders
JOIN place pl ON co.oid = pl.oid     -- Join contain with place to get order details
GROUP BY m.name, EXTRACT(YEAR FROM pl.order_date) -- Group by company and year
ORDER BY total_sales DESC;               -- Sort results by total sales



-- Finding the shipping method with the lowest average shipping cost
SELECT shipping_method, AVG(shipping_cost) AS avg_shipping_cost
FROM orders
GROUP BY shipping_method  -- Grouping by each shipping method
ORDER BY avg_shipping_cost ASC  -- Sorting by average shipping cost in ascending order
LIMIT 1;  -- Limiting the result to the cheapest shipping method


-- What is the best sold ($) category for each company?
SELECT m.name AS company, 
       p.category, 
       SUM(s.price) AS total_sales -- Sum the price from the sell table
FROM merchants m
JOIN sell s ON m.mid = s.mid        -- Join merchants with the products they sell
JOIN contain co ON s.pid = co.pid   -- Join sell with contain to relate products to orders
JOIN products p ON s.pid = p.pid     -- Join to get product details including category
GROUP BY m.name, p.category          -- Group by company and product category
ORDER BY m.name, total_sales DESC;   -- Sort results by company name and total sales in descending order



-- For each company find out which customers have spent the most and the least amounts.
WITH customer_spending AS (
    SELECT c.cid AS customer_id,
           m.name AS company,
           SUM(s.price) AS total_spent -- Sum the price from the sell table for each customer
    FROM customers c
    JOIN place pl ON c.cid = pl.cid      -- Join customers with their orders
    JOIN contain co ON pl.oid = co.oid   -- Join orders with the products contained in those orders
    JOIN sell s ON co.pid = s.pid        -- Join to get product sales prices
    JOIN products p ON s.pid = p.pid      -- Join to get product details
    JOIN merchants m ON s.mid = m.mid      -- Join to get company information
    GROUP BY c.cid, m.name                -- Group by customer and company
)
SELECT company, 
       MIN(total_spent) AS least_spent, 
       MAX(total_spent) AS most_spent
FROM customer_spending
GROUP BY company;                         -- Group by company to get the min and max spending per company
