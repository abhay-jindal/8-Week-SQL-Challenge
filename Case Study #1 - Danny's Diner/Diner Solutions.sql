
/* 1. What is the total amount each customer spent at the restaurant? */
select customer_id, sum(price) as spent_money
from sales join menu using(product_id)
group by customer_id;

/* 2. How many days has each customer visited the restaurant? */
select customer_id, count(distinct order_date) as days_visited
from sales
group by customer_id;

/* 3. What was the first item from the menu purchased by each customer? */ 
select *
from (select customer_id, product_id, min(order_date) as first_order_date
	from sales
    group by customer_id) as rank_table join menu using(product_id);

/* 4. What is the most purchased item on the menu and how many times was it purchased by all customers? */
select product_id, sum_price, count_pro
from (select *, rank() over (order by sum_price desc) as rank_pro
	from (select product_id, sum(price) as sum_price, count(product_id) as count_pro
		from sales join menu using(product_id)
		group by product_id) as inner_table) as outer_table
where rank_pro=1;

/* 5. Which item was the most popular for each customer? */ 
select customer_id, product_id, product_name 
from (select customer_id,product_id, count(product_id), dense_rank() over(partition by customer_id order by count(product_id) desc) rank_count
	from sales
	group by customer_id,product_id
	order by customer_id) as inner_table
join menu using(product_id)
where rank_count=1;

/* 6. Which item was purchased first by the customer after they became a member? */
select * from  (select customer_id, product_id, product_name, order_date, dense_rank() over(
												partition by customer_id
                                                order by order_date) as ranking
from sales join menu using(product_id)
join members using(customer_id)
where order_date>=join_date) t1
where ranking=1;

/* 7. Which item was purchased just before the customer became a member? */
select * from  (select customer_id, product_id, product_name, order_date, dense_rank() over(
												partition by customer_id
                                                order by order_date desc) as ranking
from sales join menu using(product_id)
join members using(customer_id)
where order_date<join_date) as t1
where ranking=1;

/* 8. What is the total items and amount spent for each member before they became a member? */
SELECT customer_id, SUM(price)
FROM(
	SELECT customer_id, product_id, order_date, join_date
	FROM sales JOIN members 
	using(customer_id)
	WHERE order_date < join_date) as inner_table 
JOIN menu using(product_id)
GROUP BY customer_id;

/* 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have? */
select customer_id, sum(
	case
		when product_name='sushi' then 2*price*10
        else price*10
        end) as points
from sales join menu using(product_id)
group by customer_id;

/* 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
		not just sushi - how many points do customer A and B have at the end of January? */
select customer_id, sum(case
							when (order_date<join_date) then price*20
							else price*20
                        end) as points
from members join sales using(customer_id)
join menu using(product_id)
where order_date<= '2021-01-31' 
group by customer_id;

-- In case any query is incorrect or can be optimized further, do create an issue corresponding to it! --

