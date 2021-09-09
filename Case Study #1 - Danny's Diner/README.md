
## 📕 Table Of Contents
* 🛠️ [Problem Statement](#problem-statement)
* 📂 [Dataset](#dataset)
* 🧙‍♂️ [Case Study Questions](#case-study-questions)
* 🚀 [Solutions](#solutions)
  
---

## 🛠️ Problem Statement

Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

 <br /> 

---

## 📂 Dataset
Danny has shared with you 3 key datasets for this case study:

* ### **```sales```**

The sales table captures all ```customer_id``` level purchases with an corresponding ```order_date``` and ```product_id``` information for when and what menu items were ordered.

|customer_id|order_date|product_id|
|-----------|----------|----------|
|A          |2021-01-01|1         |
|A          |2021-01-01|2         |
|A          |2021-01-07|2         |
|A          |2021-01-10|3         |
|A          |2021-01-11|3         |
|A          |2021-01-11|3         |
|B          |2021-01-01|2         |
|B          |2021-01-02|2         |
|B          |2021-01-04|1         |
|B          |2021-01-11|1         |
|B          |2021-01-16|3         |
|B          |2021-02-01|3         |
|C          |2021-01-01|3         |
|C          |2021-01-01|3         |
|C          |2021-01-07|3         |

 <br /> 

* ### **```menu```**

The menu table maps the ```product_id``` to the actual ```product_name``` and price of each menu item.

|product_id |product_name|price     |
|-----------|------------|----------|
|1          |sushi       |10        |
|2          |curry       |15        |
|3          |ramen       |12        |

 <br /> 

* ### **```members```**

The final members table captures the ```join_date``` when a ```customer_id``` joined the beta version of the Danny’s Diner loyalty program.

|customer_id|join_date |
|-----------|----------|
|A          |1/7/2021  |
|B          |1/9/2021  |

 <br /> 

## 🧙‍♂️ Case Study Questions
<p align="center">

1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

 <br /> 

## 🚀 Solutions

### **Q1. What is the total amount each customer spent at the restaurant?**
```sql
SELECT customer_id, SUM(price) AS total_spent
FROM sales JOIN menu USING(product_id)
GROUP BY customer_id;
```

**Result:**
| customer_id | total_spent |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

**Answer:**
> * **Customer A** spent **$76**
> * **Customer B** spent **$74**
> * **Customer C** spent **$36**

---

### **Q2. How many days has each customer visited the restaurant?**
```sql
SELECT customer_id, COUNT(DISTINCT order_date) AS days_visited
FROM sales
GROUP BY customer_id;
```
**Result:**
|customer_id|days_visited|
|-----------|------------|
|A          |4           |
|B          |6           |
|C          |2           |

**Answer:**
> * **Customer A** has visited **4 days**
> * **Customer B** has visited **6 days**
> * **Customer C** has visited **2 days**

---

### **Q3. What was the first item from the menu purchased by each customer?**
```sql
SELECT *
FROM (SELECT customer_id, product_id, MIN(order_date) AS first_order_date
	from sales
    group by customer_id) as rank_table join menu using(product_id);
```

**Result:**
| customer_id | product_name | item_order |
| ----------- | ------------ | ---------- |
| A           | sushi        | 1          |
| B           | curry        | 1          |
| C           | ramen        | 1          |

**Answer:**
> First item purchased by:
> * **Customer A** is **sushi**
> * **Customer B** is **curry**
> * **Customer C** is **ramen**

---

### **Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?**
```sql
SELECT
  menu.product_name,
  COUNT(sales.product_id) AS order_count
FROM dannys_diner.sales
INNER JOIN dannys_diner.menu
  ON sales.product_id = menu.product_id
GROUP BY
  menu.product_name
ORDER BY order_count DESC
LIMIT 1;
```

**Result:**
|product_id|product_name|order_count|
|----------|------------|-----------|
|3         |ramen       |8          |

**Answer:**

> Most purchased item was **ramen**, which was ordered **8 times**

---

### **Q5. Which item was the most popular for each customer?**
> ⚠️ Access [**here**](#️-question-5-which-item-was-the-most-popular-for-each-customer) to view the limitations of this question
```sql
WITH cte_order_count AS (
  SELECT
    sales.customer_id,
    menu.product_name,
    COUNT(*) as order_count
  FROM dannys_diner.sales
  JOIN dannys_diner.menu
    ON sales.product_id = menu.product_id
  GROUP BY 
    customer_id,
    product_name
  ORDER BY
    customer_id,
    order_count DESC
),
cte_popular_rank AS (
  SELECT 
    *,
    RANK() OVER(PARTITION BY customer_id ORDER BY order_count DESC) AS rank
  FROM cte_order_count
)
SELECT * FROM cte_popular_rank
WHERE rank = 1;
```

**Result:**
| customer_id | product_name | order_count | rank |
| ----------- | ------------ | ----------- | ---- |
| A           | ramen        | 3           | 1    |
| B           | ramen        | 2           | 1    |
| B           | curry        | 2           | 1    |
| B           | sushi        | 2           | 1    |
| C           | ramen        | 3           | 1    |

**Answer:**
> Most popular item for:
> * **Customer A** was **Ramen** 
> * **Customer B** was a tie between **all three menu items**
> * **Customer C** was **ramen**

<br /> 

---

**Note:** Before answering **question 6-10**, I created a **```membership_validation```** table to validate only those customers joining in the membership program:
```sql
DROP TABLE IF EXISTS membership_validation;
CREATE TEMP TABLE membership_validation AS
SELECT
   sales.customer_id,
   sales.order_date,
   menu.product_name,
   menu.price,
   members.join_date,
   CASE WHEN sales.order_date >= members.join_date
     THEN 'X'
     ELSE ''
     END AS membership
FROM dannys_diner.sales
 INNER JOIN dannys_diner.menu
   ON sales.product_id = menu.product_id
 LEFT JOIN dannys_diner.members
   ON sales.customer_id = members.customer_id
-- using the WHERE clause on the join_date column to exclude customers who haven't joined the membership program (don't have a join date = not joining the program)
  WHERE join_date IS NOT NULL
  ORDER BY 
    customer_id,
    order_date;
```

---

### **Q6. Which item was purchased first by the customer after they became a member?**
> ⚠️ Access [**here**](#️-question-6-which-item-was-purchased-first-by-the-customer-after-they-became-a-member) to view the limitations of this question

**Note:** In this question, the orders made during the join date are counted within the first order as well</span>

```sql
WITH cte_first_after_mem AS (
  SELECT 
    customer_id,
    product_name,
    order_date,
    RANK() OVER(
    PARTITION BY customer_id
    ORDER BY order_date) AS purchase_order
  FROM membership_validation
  WHERE membership = 'X'
)
SELECT * FROM cte_first_after_mem
WHERE purchase_order = 1;
```

**Result:**
| customer_id | product_name | order_date               | purchase_order |
| ----------- | ------------ | ------------------------ | -------------- |
| A           | curry        | 2021-01-07T00:00:00.000Z | 1              |
| B           | sushi        | 2021-01-11T00:00:00.000Z | 1              |

**Answer:**
> First product ordered after becoming a member for:
> * **Customer A** is **curry** 
> * **Customer B** is **sushi**
> 
> (*Customer C is not included in the list since he/she didn't join the membership program*)

<br /> 

---

### **Q7. Which item was purchased just before the customer became a member?**
> ⚠️ Access [**here**](#️-question-7-which-item-was-purchased-just-before-the-customer-became-a-member) to view the limitations of this question

```sql
WITH cte_last_before_mem AS (
  SELECT 
    customer_id,
    product_name,
    order_date,
    RANK() OVER(
    PARTITION BY customer_id
    ORDER BY order_date DESC) AS purchase_order
  FROM membership_validation
  WHERE membership = ''
)
SELECT * FROM cte_last_before_mem
--since we used the ORDER BY DESC in the query above, the order 1 would mean the last date before the customer join in the membership
WHERE purchase_order = 1;
```

**Result:**
| customer_id | product_name | order_date               | purchase_order |
| ----------- | ------------ | ------------------------ | -------------- |
| A           | sushi        | 2021-01-01T00:00:00.000Z | 1              |
| A           | curry        | 2021-01-01T00:00:00.000Z | 1              |
| B           | sushi        | 2021-01-04T00:00:00.000Z | 1              |

**Answer:**
> Last item purchased before becoming a member for:
> * **Customer A** was either <ins>**curry**</ins> or <ins>**sushi**</ins>. <span style="color:red"> *Access [here]() to view limitations of this question*</span> 
> * **Customer B** was **sushi**

---

### **Q8. What is the total items and amount spent for each member before they became a member?**
```sql
WITH cte_spent_before_mem AS (
  SELECT 
    customer_id,
    product_name,
    price
  FROM membership_validation
  WHERE membership = ''
)
SELECT 
  customer_id,
  SUM(price) AS total_spent,
  COUNT(*) AS total_items
FROM cte_spent_before_mem
GROUP BY customer_id
ORDER BY customer_id;
```

**Result:**
| customer_id | total_spent | total_items |
| ----------- | ----------- | ----------- |
| A           | 25          | 2           |
| B           | 40          | 3           |

**Answer:**
* **Customer A** spent **$25** on **2 items** before becoming members
* **Customer B** spent **$40** on **3 items** before becoming members

---

### **Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?**
```sql
SELECT
  customer_id,
  SUM(
  CASE WHEN product_name = 'sushi'
  THEN (price * 20)
  ELSE (price * 10)
  END
  ) AS total_points
FROM membership_validation
GROUP BY customer_id
ORDER BY customer_id;
```

**Result:**
| customer_id | total_points |
| ----------- | ------------ |
| A           | 860          |
| B           | 940          |

**Answer:**
* **Customer A** has **860 pts**
* **Customer B** has **940 pts**

---

### **Q10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**

> ⚠️ Access [**here**](#️-question-10-in-the-first-week-after-a-customer-joins-the-program-including-their-join-date-they-earn-2x-points-on-all-items-not-just-sushi---how-many-points-do-customer-a-and-b-have-at-the-end-of-january) to view the limitations of this question

If we combine the condition from [**question 9**](#q9-if-each-1-spent-equates-to-10-points-and-sushi-has-a-2x-points-multiplier---how-many-points-would-each-customer-have) and the condition in this question, we will have 2 point calculation cases under:
- **Normal condition:** when **```product_name = 'sushi'```** = points X2, **```else```** = points X1
- **Conditions within the first week of membership:** when all menu items are awarded X2 points

I have created a timeline as illustration for wheareas we apply the conditions:
<p align="center">
<img src="https://github.com/ndleah/8-Week-SQL-Challenge/blob/main/IMG/timeline.png" width=100% height=100%>

### **Step 1:**

As transparent from the timeline, I could see that the first need to take is to seperate the timeframe that will apply **condition 1** (Normal condition) from **condition 2** (First week membership's condition). Thus, I will create a temp table for days validation within and without the first week:

> Note that I will use data from the **```membership_validation```** table from the previous question to exclude those customers did not join the membership program also
```sql
--create temp table for days validation within the first week membership
DROP TABLE IF EXISTS membership_first_week_validation;
CREATE TEMP TABLE membership_first_week_validation AS 
WITH cte_valid AS (
SELECT
  customer_id,
  order_date,
  product_name,
  price,
  /* since we use aggregate function for our condition clause, the query will require to have the GROUP BY clause which also include the order_date and product_name. 
  
  This can possibly combine those orders with same product name in the same date into 1, which can lead to errors in our final sum calculation. 
  
  Thus, I will count all the order_count group by order_date to avoid these mistakes */
  COUNT(*) AS order_count,
  CASE WHEN order_date BETWEEN join_date AND (join_date + 6)
  THEN 'X'
  ELSE ''
  END AS within_first_week
FROM membership_validation
GROUP BY 
  customer_id,
  order_date,
  product_name,
  price,
  join_date
 ORDER BY
  customer_id,
  order_date
)
SELECT * FROM cte_valid
--Since we only calculate total points of customers by the end of January, I set the order_date condition < '2021-02-01' to avoid all the unecessary sum orders calculation after January
WHERE order_date < '2021-02-01';
--inspect the table result
SELECT * FROM membership_first_week_validation;
```
**Result:**
| customer_id | order_date               | product_name | price | order_count | within_first_week |
| ----------- | ------------------------ | ------------ | ----- | ----------- | ----------------- |
| A           | 2021-01-01T00:00:00.000Z | curry        | 15    | 1           |                   |
| A           | 2021-01-01T00:00:00.000Z | sushi        | 10    | 1           |                   |
| A           | 2021-01-07T00:00:00.000Z | curry        | 15    | 1           | X                 |
| A           | 2021-01-10T00:00:00.000Z | ramen        | 12    | 1           | X                 |
| A           | 2021-01-11T00:00:00.000Z | ramen        | 12    | 2           | X                 |
| B           | 2021-01-01T00:00:00.000Z | curry        | 15    | 1           |                   |
| B           | 2021-01-02T00:00:00.000Z | curry        | 15    | 1           |                   |
| B           | 2021-01-04T00:00:00.000Z | sushi        | 10    | 1           |                   |
| B           | 2021-01-11T00:00:00.000Z | sushi        | 10    | 1           | X                 |
| B           | 2021-01-16T00:00:00.000Z | ramen        | 12    | 1           |                   |

After the table is generated, do you notice how the **```order_count```** from the **ramen order** made by **customer A** in ```'2021-01-11'``` is diplayed? If I didn't calculate the **```order_count```**, our calculation is possibly missing 1 order from ```'2021-01-11'```, so it is very crucial to also include this information when doing our calculation!

### **Step 2:**
Now that we have two sets of data to calculate different cases applying for condition 1 and 2, next step I will created 2 tables based on our previous **```first_week_validation```** table:
```sql
--create temp table for points calculation only in the first week of membership
DROP TABLE IF EXISTS membership_first_week_points;
CREATE TEMP TABLE membership_first_week_points AS 
WITH cte_first_week_count AS (
  SELECT * FROM membership_first_week_validation
  WHERE within_first_week = 'X'
)
SELECT
  customer_id,
  SUM(
  CASE WHEN within_first_week = 'X'
  THEN (price * order_count * 20)
  ELSE (price * order_count * 10)
  END
  ) AS total_points
FROM cte_first_week_count
GROUP BY customer_id;
--inspect table results
SELECT * FROM membership_first_week_points;
```

**Result:**
| customer_id | total_points |
| ----------- | ------------ |
| A           | 1020         |
| B           | 200          |

**Finding**:
> Total points within the first week of membership program of:
> * **Customer A** is **1020**
> * **Customer B** is **200**

```sql
--create temp table for points calculation excluded the first week membership (before membership + after the first week membership)
DROP TABLE IF EXISTS membership_non_first_week_points;
CREATE TEMP TABLE membership_non_first_week_points AS 
WITH cte_first_week_count AS (
  SELECT * FROM membership_first_week_validation
  WHERE within_first_week = ''
)
SELECT
  customer_id,
  SUM(
  CASE WHEN product_name = 'sushi'
  THEN (price * order_count * 20)
  ELSE (price * order_count * 10)
  END
  ) AS total_points
FROM cte_first_week_count
GROUP BY customer_id;
--inspect table results
SELECT * FROM membership_non_first_week_points;
```

**Result:**
| customer_id | total_points |
| ----------- | ------------ |
| A           | 350          |
| B           | 620          |

**Finding**:
> Total points exclude the first week of membership program of:
> * **Customer A** is **350**
> * **Customer B** is **620**

### **Step 3:**

Now that we have total points for both conditions, let's aggregate all the points value together to get the final result!

```sql
--perform table union to aggregate our point values from both point calculation tables, then use SUM aggregate function to get our result
WITH cte_union AS (
  SELECT * FROM membership_first_week_points
  UNION
  SELECT * FROM membership_non_first_week_points
)
SELECT
  customer_id,
  SUM(total_points)
FROM cte_union
GROUP BY customer_id
ORDER BY customer_id;
```

**Result:**
| customer_id | SUM          |
| ----------- | ------------ |
| A           | 1370         |
| B           | 820          |

**Answer:**
> By the end of January-21:
> * **Customer A** has **1370 points**
> * **Customer B** has **820 points**

 <br /> 


