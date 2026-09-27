SELECT *
FROM Zomato_Order_Data_Portfolio.customer_data_zomato;


SELECT * 
FROM Zomato_Order_Data_Portfolio.orders_data_zomato;

SELECT count(*) 
FROM Zomato_Order_Data_Portfolio.restaurants_data_zomato;


-- KPI

-- REVENUE ANALYSIS


-- Total Revenue of total orders when the order is delivered


SELECT ROUND(SUM(order_amount),2) as Total_Revenue
FROM Zomato_Order_Data_Portfolio.orders_data_zomato
WHERE order_status = "Delivered";

-- Total Revenue of total orders when the order is delivered


SELECT EXTRACT(month FROM order_timestamp) as Month_number,
	   ROUND(SUM(order_amount),2) as Total_Revenue
FROM Zomato_Order_Data_Portfolio.orders_data_zomato
WHERE order_status = "Delivered"
GROUP BY Month_Number
ORDER BY Month_Number; 


-- SAMPLE(Can be used to get or cut the date from a timestamp) 
-- SELECT DATE_TRUNC(month, '2017/08/25') AS DatePartInt;



-- ***************************************************************************

-- Which city contributes the highest revenue?

SELECT CustomerTable.city, ROUND(SUM(OrdersTable.order_amount), 2) as total_amount
FROM Zomato_Order_Data_Portfolio.customer_data_zomato as CustomerTable
JOIN Zomato_Order_Data_Portfolio.orders_data_zomato as OrdersTable
	ON CustomerTable.Customer_id = OrdersTable.customer_id
WHERE OrdersTable.order_status = "Delivered"
GROUP BY CustomerTable.city
ORDER BY total_amount DESC;

-- ***************************************************************************

-- Which payment mode generates most revenue?

SELECT payment_mode, SUM(order_amount) as Total_revenue
FROM Zomato_Order_Data_Portfolio.orders_data_zomato
WHERE order_status = "Delivered"
GROUP BY payment_mode
ORDER BY Total_revenue DESC LIMIT 1

-- ***************************************************************************

-- What is the average order value?

SELECT SUM(order_amount)/COUNT(DISTINCT order_id) as Average_Revenue
FROM Zomato_Order_Data_Portfolio.orders_data_zomato
WHERE order_status = "Delivered";

-- ***************************************************************************
-- CUSTOMER ANALYSIS
-- ***************************************************************************


-- What are the top 20 customers by revenue?

WITH TOPCUST AS(
	SELECT customer_id, ROUND(sum(order_amount), 2) as Total_amount 
    FROM Zomato_Order_Data_Portfolio.orders_data_zomato
    WHERE order_status = "Delivered"
    GROUP BY customer_id
)

SELECT customer_id, Total_amount, row_number() OVER() as MAIN_RANK FROM (

SELECT customer_id, TOPCUST.Total_amount, ROW_NUMBER() OVER(ORDER BY Total_amount DESC) as Ranked 
FROM TOPCUST)  b

WHERE Ranked <= 20


-- Can also get the name of customer using join method

-- JOIN TO GET THE CUSTOMERS NAME

-- SELECT Customers_Table.Customer_name, TP.Total_amount
-- FROM Zomato_Order_Data_Portfolio.customer_data_zomato as Customers_Table
-- JOIN TOPCUST as TP
-- 	ON Customers_Table.Customer_id = TP.customer_id
-- ORDER BY Total_amount DESC LIMIT 20

-- *******************************************************************************************************************************************

-- What percentage of total revenue comes from the top customer?


WITH TOPCUST AS(
	SELECT customer_id, ROUND(sum(order_amount), 2) as Total_amount 
    FROM Zomato_Order_Data_Portfolio.orders_data_zomato
    WHERE order_status = "Delivered"
    GROUP BY customer_id
)
,

TOP_20_Customer AS (
SELECT customer_id, Total_amount, row_number() OVER() as MAIN_RANK FROM (

SELECT customer_id, TOPCUST.Total_amount, ROW_NUMBER() OVER(ORDER BY Total_amount DESC) as Ranked 
FROM TOPCUST)  b

WHERE Ranked <= 20)


SELECT SUM(total_amount) * 100/(SELECT SUM(order_amount) from Zomato_Order_Data_Portfolio.orders_data_zomato WHERE order_status = "delivered") 
FROM TOP_20_Customer

Minimumdate
-- *******************************************************************************************************************************************


-- Number of customers logged in with an acquistion channel

SELECT Acquisition_channel, COUNT(DISTINCT Customer_id) as Unique_customer_name
FROM Zomato_Order_Data_Portfolio.customer_data_zomatoMinimumdate
GROUP BY 1
ORDER BY Unique_Customer_name DESC

-- *******************************************************************************************************************************************


-- How many repeat customers do we have?


-- SELECT customer_id, MIN(order_timestamp) as Minimumdate
-- FROM Zomato_Order_Data_Portfolio.orders_data_zomatoZomato_Order_Data_Portfolio.orders_data_zomato
-- GROUP BY customer_id


-- SELECT EXTRACT(MONTH from order_timestamp), COUNT(DISTINCT customer_id)
-- FROM Zomato_Order_Data_Portfolio.orders_data_zomato

-- *******************************************************************************************************************************************
-- RESTAURANT PERFORMANCE
-- *******************************************************************************************************************************************

-- Which restaurant perform high revenue?

WITH TOP_Rest as(
SELECT restaurant_id, ROUND(SUM(order_amount), 2) as ordr_amt
FROM Zomato_Order_Data_Portfolio.orders_data_zomato
WHERE order_status = "Delivered"
GROUP BY restaurant_id
ORDER BY ordr_amt DESC)

SELECT restaurant_id, ordr_amt, RNKED as MainRANK FROM(
SELECT restaurant_id, TOP_Rest.ordr_amt, ROW_NUMBER() OVER (ORDER BY ordr_amt DESC) as RNKED
FROM TOP_Rest) as Sample
WHERE RNKED <= 5

-- *******************************************************************************************************************************************

-- Which restaurant receive the most orders?


SELECT restaurant_id, COUNT(DISTINCT order_id) as Total_ID
FROM Zomato_Order_Data_Portfolio.orders_data_zomato
WHERE order_status = "Delivered"
GROUP BY restaurant_id
ORDER BY COUNT(DISTINCT order_id) DESC 

-- *******************************************************************************************************************************************

-- Which cuisines are most popular?



SELECT restaurantstable.cuisine, ROUND(SUM(order_amount), 2) as Total_Sales_amount
FROM Zomato_Order_Data_Portfolio.restaurants_data_zomato restaurantstable
JOIN Zomato_Order_Data_Portfolio.orders_data_zomato orderstable
	ON restaurantstable.restaurant_id = orderstable.restaurant_id
WHERE orderstable.order_status = "Delivered"
GROUP BY restaurantstable.cuisine
ORDER BY Total_Sales_amount DESC


-- *******************************************************************************************************************************************

-- Do high-rated restaurants generate more revenue?

SELECT restaurantstable.restaurant_name, restaurantstable.avg_rating, ROUND(SUM(order_amount), 2) AS total_revenue
FROM Zomato_Order_Data_Portfolio.restaurants_data_zomato restaurantstable
JOIN Zomato_Order_Data_Portfolio.orders_data_zomato orderstable
	ON restaurantstable.restaurant_id = orderstable.restaurant_id
WHERE orderstable.order_status = "Delivered"
GROUP BY restaurantstable.avg_rating,restaurantstable.restaurant_name
ORDER BY total_revenue DESC


-- *******************************************************************************************************************************************

-- Last 5 performing restaurants

WITH Restaurant_Performers_Revenue as (
SELECT restaurantstable.restaurant_name, restaurantstable.avg_rating, ROUND(SUM(order_amount), 2) AS total_revenue
FROM Zomato_Order_Data_Portfolio.restaurants_data_zomato restaurantstable
JOIN Zomato_Order_Data_Portfolio.orders_data_zomato orderstable
	ON restaurantstable.restaurant_id = orderstable.restaurant_id
WHERE orderstable.order_status = "Delivered"
GROUP BY restaurantstable.avg_rating,restaurantstable.restaurant_name
ORDER BY total_revenue )

SELECT restaurant_name, Rnk 
FROM (SELECT restaurant_name, total_revenue, RANK() OVER(ORDER BY total_revenue) as Rnk
FROM Restaurant_Performers_Revenue) sample
WHERE RNK <= 5

-- *******************************************************************************************************************************************



-- REVENUE ANALYSIS

-- *******************************************************************************************************************************************



-- What is the cancellation rate? and the refunded rate 


SELECT COUNT(DISTINCT CASE WHEN order_status = "Cancelled" THEN order_id END) / COUNT(DISTINCT order_id) * 100 as Cancelled_order,
	   COUNT(DISTINCT CASE WHEN order_status = "Refunded" THEN order_id END) / COUNT(DISTINCT order_id) * 100 as Refunded_Order
FROM Zomato_Order_Data_Portfolio.orders_data_zomato;

 
-- *******************************************************************************************************************************************



-- What is the refund rate?

-- SELECT COUNT(DISTINCT CASE WHEN order_status = "Refunded" THEN order_id END) / COUNT(DISTINCT order_id) * 100
-- FROM Zomato_Order_Data_Portfolio.orders_data_zomato;


-- *******************************************************************************************************************************************



-- How much revenue lost due to cancellations?

SELECT SUM(order_amount) as Total_Canceled_Order
FROM Zomato_Order_Data_Portfolio.orders_data_zomato
WHERE order_status = "Cancelled"

-- *******************************************************************************************************************************************

-- Which restaurant has the highest cancellation rate ?


SELECT restaurant_id, COUNT(DISTINCT CASE WHEN order_status = "Cancelled" THEN order_id END) / COUNT(DISTINCT order_id) * 100 as Cancelled_order
FROM Zomato_Order_Data_Portfolio.orders_data_zomato
GROUP BY restaurant_id
ORDER BY COUNT(DISTINCT CASE WHEN order_status = "Cancelled" THEN order_id END) / COUNT(DISTINCT order_id) * 100 DESC


-- *******************************************************************************************************************************************

-- Customer Churn Analysis

-- How many customers have churned?

-- Getting last transaction date
WITH Last_Transaction_Date as (
SELECT MAX(order_timestamp) as Max_txn
FROM Zomato_Order_Data_Portfolio.orders_data_zomato)
,
CUST_LAST_DATE as (
SELECT customer_id, MAX(order_timestamp) as Max_customer_txn
FROM Zomato_Order_Data_Portfolio.orders_data_zomato
GROUP BY customer_id)


SELECT COUNT(*) as Customer_Churn_90_days_more
FROM CUST_LAST_DATE c_last_date
CROSS JOIN Last_Transaction_Date last_date
WHERE DATEDIFF(last_date.Max_Txn, c_last_date.Max_Customer_txn) > 90


-- What is the Churn Rate?

WITH Last_Transaction_Date as (
SELECT MAX(order_timestamp) as Max_txn
FROM Zomato_Order_Data_Portfolio.orders_data_zomato)
,
CUST_LAST_DATE as (
SELECT customer_id, MAX(order_timestamp) as Max_customer_txn
FROM Zomato_Order_Data_Portfolio.orders_data_zomato
GROUP BY customer_id)
,
CHURN as (
SELECT *,
	CASE WHEN DATEDIFF(last_date.Max_Txn, c_last_date.Max_Customer_txn) > 90 THEN 1 ELSE 0 END as is_Churn 
FROM CUST_LAST_DATE c_last_date
CROSS JOIN Last_Transaction_Date last_date)

SELECT SUM(is_Churn)/ count(*) * 100
FROM CHURN


-- Which city has the highest churn?


WITH Last_Transaction_Date as (
SELECT MAX(order_timestamp) as Max_txn
FROM Zomato_Order_Data_Portfolio.orders_data_zomato)
,
City_LAST_DATE as (
SELECT orders.customer_id, City, MAX(order_timestamp) as Max_customer_txn
FROM Zomato_Order_Data_Portfolio.customer_data_zomato AS customer
JOIN Zomato_Order_Data_Portfolio.orders_data_zomato AS orders
	ON customer.Customer_id = orders.customer_id
GROUP BY City, customer_id)


SELECT city, COUNT(*)
FROM City_LAST_DATE AS ct_last
CROSS JOIN Last_Transaction_Date last_date
WHERE DATEDIFF(last_date.Max_txn, ct_last.Max_customer_txn) > 90
GROUP BY city
ORDER BY city DESC LIMIT 3


-- How much revenue is lost due to churn?

WITH Last_Transaction_Date as (
SELECT MAX(order_timestamp) as Max_txn
FROM Zomato_Order_Data_Portfolio.orders_data_zomato)
,
CUST_LAST_DATE as (
SELECT customer_id, MAX(order_timestamp) as Max_customer_txn
FROM Zomato_Order_Data_Portfolio.orders_data_zomato
GROUP BY customer_id)
,
CHURN as(
SELECT customer_id
FROM CUST_LAST_DATE as Cust_last_date
CROSS JOIN Last_Transaction_Date as Last_date
WHERE DATEDIFF(Cust_last_date.Max_customer_txn , Last_date.Max_txn) < 90)

SELECT SUM(order_amount)
FROM Zomato_Order_Data_Portfolio.orders_data_zomato
WHERE customer_id IN (SELECT * FROM CHURN)


-- Who are the high valued churn customers?

WITH Last_Transaction_Date as (
SELECT MAX(order_timestamp) as Max_txn
FROM Zomato_Order_Data_Portfolio.orders_data_zomato)
,
CUST_LAST_DATE as (
SELECT customer_id, MAX(order_timestamp) as Max_customer_txn
FROM Zomato_Order_Data_Portfolio.orders_data_zomato
GROUP BY customer_id)
,
CHURN as(
SELECT customer_id
FROM CUST_LAST_DATE as Cust_last_date
CROSS JOIN Last_Transaction_Date as Last_date
WHERE DATEDIFF(Cust_last_date.Max_customer_txn , Last_date.Max_txn) < 90)


SELECT customer_id, SUM(order_amount) as amt
FROM Zomato_Order_Data_Portfolio.orders_data_zomato	
WHERE customer_id in (SELECT * FROM CHURN)
GROUP BY customer_id
ORDER BY amt DESC
    
    

