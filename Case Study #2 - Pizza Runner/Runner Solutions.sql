
    /* 1. How many pizzas were ordered? */
  select count(pizza_id) as total_orders from customer_orders;
  
  /* 2. How many unique customer orders were made? */
  select count(distinct order_id) as unique_orders from customer_orders;
  
  /* 3. How many successful orders were delivered by each runner? */
  select runner_id, count(*) as successfull_orders
  from runner_orders
  where cancellation="" or cancellation is Null 
  group by runner_id;
  
  /* 4. How many of each type of pizza was delivered? */
  select pizza_id, count(pizza_id) as count_pizza_ordered
  from runner_orders join customer_orders using(order_id)
  where cancellation="" or cancellation is Null
  group by pizza_id;
  
/* 5. How many Vegetarian and Meatlovers were ordered by each customer? */
select customer_id, count(case 
							when pizza_name='Meatlovers' then 1
							else null
							end) as meat_lovers,
					count(case 
							when pizza_name='Vegetarian' then 1
							else null
							end) as vegetarian_lovers
from customer_orders join pizza_names using(pizza_id)
group by customer_id;
  
/* 6. What was the maximum number of pizzas delivered in a single order? */
select order_id, count(pizza_id) as pizza_count
from runner_orders join customer_orders using(order_id)
where cancellation="" or cancellation is Null
group by order_id
order by pizza_count desc
limit 1;

/* 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes? */
SELECT customer_id, changes, COUNT(*) AS counts
FROM 
	(SELECT customer_id, 
	CASE WHEN exclusions <> '' OR extras <> '' THEN 'Yes'
	ELSE 'No' 
	END changes
	FROM customer_orders JOIN runner_orders
	USING(order_id)
	WHERE cancellation = '')
GROUP BY customer_id, changes;
