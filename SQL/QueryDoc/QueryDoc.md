# Raw Database
SELECT *
FROM sales;

![RAW DB](./images/raw_db.png)

# Processed Database
SELECT *
FROM sales2;

![CLEANED DB](./images/cleaned_db.png)


# 1. Total Sales
SELECT CONCAT('₹', CAST(ROUND(SUM(Sales)/10000000, 2) AS CHAR), ' Crores') AS `Total Sales`
FROM sales2;

![KPI #1](./images/total_sales.png)

# 2. Average sale per Product
SELECT CONCAT('₹', CAST(ROUND(AVG(Sales), 2) AS CHAR)) AS `Average Sales`
FROM sales2;

![KPI #2](./images/avg_sales.png)

# 3. Total number of Products sold
SELECT COUNT(Item_ID) AS `Total items sold`
FROM sales2;

![KPI #3](./images/count.png)

# 4. Average Customer Rating for each Product
SELECT ROUND(AVG(Rating), 2) AS `Average Rating`
FROM sales2;

![KPI #4](./images/rating.png)

# 5. KPI Metrics Variation by Product status (Discount/Non-discount)
SELECT Item_status, 
			ROUND(SUM(Sales), 2) AS `Total Sales`,
            ROUND(AVG(Sales), 1) AS `Average Sale`,
            COUNT(Item_ID) AS `Total items sold`,
            ROUND(AVG(Rating), 2) AS `Average Rating`
FROM sales2
GROUP BY Item_status
ORDER BY 2 DESC;

![GRAN 1](./images/gran1.png)

# 6. KPI Metrics Variation by Category
SELECT Category,
			ROUND(SUM(Sales), 2) AS `Total Sales`,
            ROUND(AVG(Sales), 1) AS `Average Sale`,
            COUNT(Item_ID) AS `Total items sold`,
            ROUND(AVG(Rating), 2) AS `Average Rating`
FROM sales2
GROUP BY Category
ORDER BY 2 DESC;

![GRAN 2](./images/gran2.png)

# 7. Total Sales by Location, segmented by Product Status
WITH KPI_cte AS
(
SELECT Location_Type, Item_status,
			ROUND(SUM(Sales), 2) AS `Total Sales`,
            ROUND(AVG(Sales), 1) AS `Average Sale`,
            COUNT(Item_ID) AS `Total items sold`,
            ROUND(AVG(Rating), 2) AS `Average Rating`
FROM sales2
GROUP BY Location_Type, Item_status
ORDER BY 1 DESC
)
SELECT 
  Location_Type,
  SUM(CASE WHEN Item_status = 'Discounted' THEN `Total Sales` ELSE 0 END) AS 'Discounted',
  SUM(CASE WHEN Item_status = 'Non-Discounted' THEN `Total Sales` ELSE 0 END) AS 'Non-Discounted'
FROM KPI_cte
GROUP BY Location_Type;

![GRAN 3](./images/gran3.png)

# 8. KPI Metrics Variation by Location
SELECT Location_type, 
			ROUND(SUM(Sales), 2) AS `Total Sales`,
            ROUND(AVG(Sales), 1) AS `Average Sale`,
            COUNT(Item_ID) AS `Total items sold`,
            ROUND(AVG(Rating), 2) AS `Average Rating`
FROM sales2
GROUP BY Location_type
ORDER BY 2 DESC;

![GRAN 4](./images/gran4.png)

# 9. Total Sales by Warehouse Establishment Year
SELECT Year_est, ROUND(SUM(Sales), 2) AS `Total Sales`
FROM sales2
GROUP BY Year_est
ORDER BY 1;

![GRAN 5](./images/gran5.png)

# 10. KPI Metric Variation by Warehouse Establishment Year
SELECT Year_est,
		ROUND(SUM(Sales), 2) AS `Total Sales`,
        ROUND(AVG(Sales), 2) AS `Average Sales`,
        ROUND(COUNT(Item_ID), 2) AS `Total items sold`,
        ROUND(AVG(Rating), 2) AS `Average Rating`
FROM sales2
GROUP BY Year_est
ORDER BY 2;

![GRAN 6](./images/gran6.png)

# 11. Percentage of Sales by Warehouse size
SELECT Warehouse_size,
		CONCAT('₹', CAST(SUM(Sales)/10000000 AS DECIMAL(10,2)), ' Crores') AS `Total Sales`,
		CONCAT(CAST((SUM(Sales)*100.0/SUM(SUM(Sales)) OVER()) AS DECIMAL(10,2)), '%') AS `Sales Percentage`
FROM sales2
GROUP BY Warehouse_size
ORDER BY 3 DESC;

![CHART 1](./images/chart1.png)

# 12. Percentage of Sales by Location Type
SELECT Location_type,
		CONCAT('₹', CAST(SUM(Sales)/10000000 AS DECIMAL(10,2)), ' Crores') AS `Total Sales`,
		CONCAT(CAST((SUM(Sales)*100.0/SUM(SUM(Sales)) OVER()) AS DECIMAL(10,2)), '%') AS `Sales Percentage`
FROM sales2
GROUP BY Location_type
ORDER BY 3 DESC;

![CHART 2](./images/chart2.png)

# 13. KPI Metric Variation by Warehouse Type
SELECT Warehouse_type,
		CONCAT('₹', CAST(SUM(Sales)/10000000 AS DECIMAL(10,2)), ' Crores') AS `Total Sales`,
        CONCAT('₹', ROUND(AVG(Sales), 2)) AS `Average Sales`,
        ROUND(COUNT(Item_ID), 2) AS `Total items sold`,
        ROUND(AVG(Rating), 2) AS `Average Rating`
FROM sales2
GROUP BY Warehouse_type
ORDER BY 2 DESC;

![CHART 3](./images/chart3.png)