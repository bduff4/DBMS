-- 1: Get the average price of foods at each restaurant
select r.name as restaurant_name, avg(f.price) as avg_price -- select name, calculate average prices-  
from restaurants r -- -from restaurants table
join serves s on r.restID = s.restID -- join with serves to match restaurants with food served
join foods f on s.foodID = f.foodID -- join with foods to get prices
group by r.name; -- group by restaurant name to get average

-- 2: Get the maximum food price at each restaurant
select r.name as restaurant_name, max(f.price) as max_price -- select name, get maximum prices-
from restaurants r -- -from restaurants table 
join serves s on r.restID = s.restID -- join with serves to match restaurants with food served
join foods f on s.foodID = f.foodID -- join with foods to get prices
group by r.name; -- group by restaurant name to get maximum

-- 3: Get the count of different food types served at each restaurant
select r.name as restaurant_name, count(distinct f.type) as food_type_count -- select name, count food types-
from restaurants r -- -from restaurants table
join serves s on r.restID = s.restID -- join with serves to match restaurants with food served
join foods f on s.foodID = f.foodID -- join with foods to get food types
group by r.name; -- group by restaurant name to get food types

-- 4: Get the average price of foods served by each chef
select c.name as chef_name, avg(f.price) as avg_price -- select name, calculate average prices-
from chefs c -- -from chefs table
join works w on c.chefID = w.chefID -- join with works to find where chefs work
join serves s on w.restID = s.restID -- join with serves to match restaurants with food served
join foods f on s.foodID = f.foodID -- join with foods to get prices
group by c.name; -- group by chef to get average 

-- 5: Find the restaurant with the highest average food price
select r.name as restaurant_name, avg(f.price) as avg_price  -- select name, calculate average prices-
from restaurants r -- -from restaurants table
join serves s on r.restID = s.restID -- join with serves to match restaurants with food served
join foods f on s.foodID = f.foodID -- join with foods to get prices
group by r.name -- group by restaurant name to get average
having avg(f.price) = ( -- subquery to only show max of average values
	select max(avg_price) -- get max of average
    from ( 
		select avg(f2.price) as avg_price -- calc avg in subquery
        from restaurants r2 -- etc
        join serves s2 on r2.restID = s2.restID -- etc
		join foods f2 on s2.foodID = f2.foodID -- etc
        group by r2.name -- group by second use of restaruant table
        ) as subquery
	);

