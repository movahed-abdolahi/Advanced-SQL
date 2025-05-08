/* 
Movahed Abdolahi
Sales analysis
*/


/* 
List of employees along with their titles and immediate managers
*/

SELECT 
  e.employeeId as 'Employee ID',
  e.firstName as 'First Name',
  e.lastName as 'Last Name',
  e.title as 'Title',
  m.firstName || ' ' || m.lastName as 'Manager'
FROM employee e
JOIN employee m
  ON e.managerId = m.employeeId


/* 
List of employees without any sales
*/

SELECT
  *
FROM employee e
LEFT JOIN sales s
  ON e.employeeId = s.employeeId
WHERE title = 'Sales Person' AND salesAmount IS NULL
ORDER BY
  e.employeeId ASC


/* 
List of sales and all customers even if some of the data has been removed
*/

SELECT
  c.customerId,
  c.firstName,
  c.lastName,
  c.email,
  sum(s.salesAmount) as sales
FROM  sales s
FULL OUTER JOIN customer c
  ON s.customerId = c.customerId
GROUP BY
  c.customerId,
  c.firstName,
  c.lastName,
  c.email
ORDER BY
  firstName ASC


/* 
Report of total number of cars sold by each employee
*/

SELECT
  e.employeeId,
  e.firstName,
  e.lastName,
  count(*) as 'total cars'
FROM sales s
INNER JOIN employee e 
  ON s.employeeId = e.employeeId
GROUP BY  
  e.employeeId,
  e.firstName,
  e.lastName
ORDER BY
  count(*) DESC


/* 
Report of lease and most expensive car sold by each employee in 2023
*/

SELECT
  e.employeeId,
  e.firstName,
  e.lastName,
  min(salesAmount) as least_expensive,
  max(salesAmount) as most_expensive
FROM sales s
INNER JOIN employee e 
  ON s.employeeId = e.employeeId
WHERE s.soldDate >= '2023-01-01' AND s.soldDate <= '2023-12-31'
GROUP BY
  e.employeeId,
  e.firstName,
  e.lastName


/* 
List of employees who have made more than five sales in 2023
*/

SELECT
  e.employeeId,
  e.firstName,
  e.lastName,
  count(*) as total_cars_sold
FROM sales s 
INNER JOIN employee e 
  ON s.employeeId = e.employeeId
WHERE s.soldDate >= '2023-01-01' AND s.soldDate <= '2023-12-31'
GROUP BY
  e.employeeId,
  e.firstName,
  e.lastName
HAVING count(*) > 5


/* 
Total sales per year
*/

WITH yearly_new AS (
SELECT
  strftime('%Y', soldDate) as year,
  salesAmount
FROM sales
)
SELECT
  year,
  round(sum(salesAmount), 2) AS totalsales
FROM yearly_new
GROUP BY year
ORDER BY year

-- OR

SELECT
  strftime('%Y', soldDate) as year,
  format("$%.2f", sum(salesAmount)) as totalsales
FROM sales
GROUP BY year 


/* 
Total sales per employee for each month of 2021
*/

SELECT
  e.firstName,
  e.lastName,
  CASE
    WHEN strftime('%m', s.soldDate) = '01' THEN s.salesAmount
  END AS 'jan_sales',
  CASE
    WHEN strftime('%m', s.soldDate) = '02' THEN s.salesAmount
  END AS 'feb_sales',
  CASE
    WHEN strftime('%m', s.soldDate) = '03' THEN s.salesAmount
  END AS 'mar_sales',
  CASE
    WHEN strftime('%m', s.soldDate) = '04' THEN s.salesAmount
  END AS 'apr_sales',
  CASE
    WHEN strftime('%m', s.soldDate) = '05' THEN s.salesAmount
  END AS 'may_sales',
  CASE
    WHEN strftime('%m', s.soldDate) = '06' THEN s.salesAmount
  END AS 'jun_sales',
  CASE
    WHEN strftime('%m', s.soldDate) = '07' THEN s.salesAmount
  END AS 'jul_sales',
  CASE
    WHEN strftime('%m', s.soldDate) = '08' THEN s.salesAmount
  END AS 'aug_sales',
  CASE
    WHEN strftime('%m', s.soldDate) = '09' THEN s.salesAmount
  END AS 'sep_sales',
  CASE
    WHEN strftime('%m', s.soldDate) = '10' THEN s.salesAmount
  END AS 'oct_sales',
  CASE
    WHEN strftime('%m', s.soldDate) = '11' THEN s.salesAmount
  END AS 'nov_sales',
  CASE
    WHEN strftime('%m', s.soldDate) = '12' THEN s.salesAmount
  END AS 'dec_sales'
FROM sales s 
INNER JOIN employee e 
  ON s.employeeId = e.employeeId
WHERE s.soldDate >= '2021-01-01' AND s.soldDate < '2022-01-01'
GROUP BY
  e.firstName,
  e.lastName


/* 
List of sales for electric cars
*/

SELECT
  inv.salesId,
  inv.customerId,
  m.model,
  inv.year,
  m.EngineType,
  inv.salesAmount,
  strftime('%Y-%m-%d', inv.soldDate) AS sold_date
FROM (SELECT
  *
FROM sales s
JOIN inventory i
  ON s.inventoryId = i.inventoryId) as inv 
JOIN model m 
  ON inv.modelId = m.modelId
WHERE EngineType = 'Electric'


/* 
List of sales person and ranking most cars sold by them
*/

SELECT
  firstName,
  lastName,
  model,
  rank() OVER (PARTITION by esi.employeeId ORDER BY count(model) DESC) AS rank
FROM (
SELECT
  *
FROM (
SELECT
  salesId,
  s.employeeId,
  inventoryId,
  firstName,
  lastName,
  salesAmount,
  soldDate
FROM sales s 
JOIN employee e
  ON s.employeeId = e.employeeId) as ems
JOIN inventory inv
  ON ems.inventoryId = inv.inventoryId) as esi 
JOIN model mod 
  ON esi.modelId = mod.modelId
GROUP BY
  firstName,
  lastName,
  model


/* 
total sales per month and an annual running total
*/

WITH cte_sales AS (
SELECT
  strftime('%Y', soldDate) as year,
  strftime('%m', soldDate) as month,
  sum(salesAmount) as total_month_sales
FROM sales
GROUP BY
  year,
  month
)
SELECT
    year,
    month,
    total_month_sales,
    sum(total_month_sales) OVER(PARTITION BY year ORDER BY year, month) as annual_rolling
FROM cte_sales
ORDER BY 
  year,
  month


/* 
A report showing number of cars sold this month along with last month
*/

WITH cte_sales AS (
SELECT
  strftime('%Y-%m', soldDate) AS date,
  count(*) as cars_sold
FROM sales
GROUP BY strftime('%Y-%m', soldDate)
ORDER BY strftime('%Y-%m', soldDate)
)
SELECT
  date,
  cars_sold as current_month_sales,
  LAG(cars_sold, 1, 0) OVER(ORDER BY date) AS last_month_sales
FROM cte_sales

