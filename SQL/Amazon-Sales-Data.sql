## Checking for duplicate values
WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY `Item Identifier`, `Warehouse Identifier`) AS row_num
FROM sales
)
SELECT *
FROM duplicate_cte
WHERE row_num>1;

## Creating a duplicate table before making further changes. This serves as an essential step
# in a real world scenario where data is automatically pulled from several sources
# and we don't want to make any changes to the raw data
CREATE TABLE sales2
LIKE sales;
INSERT sales2
SELECT *
FROM sales;

SELECT COUNT(`Item Identifier`)
FROM sales2;


## MySQL could not read csv file properly, so the file had to be converted to
# JSON and then imported. As a result, we have to convert certain columns from
# text to int or double.
SELECT *
FROM sales2
WHERE `Item Weight` = '' OR `Item Weight` IS NULL
   OR `Item Weight` NOT REGEXP '^-?[0-9]+(\.[0-9]+)?$';

ALTER TABLE sales2
MODIFY COLUMN `Item Engagement Rate` DOUBLE,
MODIFY COLUMN `Item Weight` DOUBLE,
MODIFY COLUMN Sales DOUBLE,
MODIFY COLUMN Rating DOUBLE;

## Changing Names of some columns to avoid repeated use of backticks
ALTER TABLE sales2 RENAME COLUMN `Item Status` TO Item_status;
ALTER TABLE sales2 RENAME COLUMN `Item Identifier` TO Item_ID;
ALTER TABLE sales2 RENAME COLUMN `Item Category` TO Category;
ALTER TABLE sales2 RENAME COLUMN `Warehouse Establishment Year` TO Year_est;
ALTER TABLE sales2 RENAME COLUMN `Warehouse Identifier` TO Warehouse_ID;
ALTER TABLE sales2 RENAME COLUMN `Warehouse Location` TO Location_type;
ALTER TABLE sales2 RENAME COLUMN `Warehouse Size` TO Warehouse_size;
ALTER TABLE sales2 RENAME COLUMN `Warehouse Type` TO Warehouse_type;
ALTER TABLE sales2 RENAME COLUMN `Item Engagement Rate` TO Item_engage_rate;
ALTER TABLE sales2 RENAME COLUMN `Item Weight` TO Item_wt;

SELECT DISTINCT Item_status
FROM sales2;

UPDATE sales2
SET Item_status = CASE
	WHEN Item_status IN ('no sale') THEN 'Non-Discounted'
    WHEN Item_status = 'Disc' THEN 'Discounted'
	WHEN Item_status = 'discounted' THEN 'Discounted'
    ELSE Item_status
END;


## KPI REQUIREMENTS:


# 1. Total Sales
SELECT CONCAT('₹', CAST(ROUND(SUM(Sales)/10000000, 2) AS CHAR), ' Crores') AS `Total Sales`
FROM sales2;

# 2. Average sale per Product
SELECT CONCAT('₹', CAST(ROUND(AVG(Sales), 2) AS CHAR)) AS `Average Sales`
FROM sales2;

# 3. Total number of Products sold
SELECT COUNT(Item_ID) AS `Total items sold`
FROM sales2;

# 4. Average Customer Rating for each Product
SELECT ROUND(AVG(Rating), 2) AS `Average Rating`
FROM sales2;


## GRANULAR REQUIREMENTS:
# (Note: Exact figures for the total and average sales will be retained in this section
   #for accurate business calculations)


# 1. KPI Metrics Variation by Product status (Discount/Non-discount)
SELECT Item_status, 
			ROUND(SUM(Sales), 2) AS `Total Sales`,
            ROUND(AVG(Sales), 1) AS `Average Sale`,
            COUNT(Item_ID) AS `Total items sold`,
            ROUND(AVG(Rating), 2) AS `Average Rating`
FROM sales2
GROUP BY Item_status
ORDER BY 2 DESC;

# 2. KPI Metrics Variation by Category
SELECT Category,
			ROUND(SUM(Sales), 2) AS `Total Sales`,
            ROUND(AVG(Sales), 1) AS `Average Sale`,
            COUNT(Item_ID) AS `Total items sold`,
            ROUND(AVG(Rating), 2) AS `Average Rating`
FROM sales2
GROUP BY Category
ORDER BY 2 DESC;

# 3. Total Sales by Location, segmented by Product Status
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

# 4. KPI Metrics Variation by Location
SELECT Location_type, 
			ROUND(SUM(Sales), 2) AS `Total Sales`,
            ROUND(AVG(Sales), 1) AS `Average Sale`,
            COUNT(Item_ID) AS `Total items sold`,
            ROUND(AVG(Rating), 2) AS `Average Rating`
FROM sales2
GROUP BY Location_type
ORDER BY 2 DESC;

# 5. Total Sales by Warehouse Establishment Year
SELECT Year_est, ROUND(SUM(Sales), 2) AS `Total Sales`
FROM sales2
GROUP BY Year_est
ORDER BY 1;

# 6. KPI Metric Variation by Warehouse Establishment Year
SELECT Year_est,
		ROUND(SUM(Sales), 2) AS `Total Sales`,
        ROUND(AVG(Sales), 2) AS `Average Sales`,
        ROUND(COUNT(Item_ID), 2) AS `Total items sold`,
        ROUND(AVG(Rating), 2) AS `Average Rating`
FROM sales2
GROUP BY Year_est
ORDER BY 2;


## CHART REQUIREMENTS:


# 1. Percentage of Sales by Warehouse size
SELECT Warehouse_size,
		CONCAT('₹', CAST(SUM(Sales)/10000000 AS DECIMAL(10,2)), ' Crores') AS `Total Sales`,
		CONCAT(CAST((SUM(Sales)*100.0/SUM(SUM(Sales)) OVER()) AS DECIMAL(10,2)), '%') AS `Sales Percentage`
FROM sales2
GROUP BY Warehouse_size
ORDER BY 3 DESC;

# 2. Percentage of Sales by Location
SELECT Location_type,
		CONCAT('₹', CAST(SUM(Sales)/10000000 AS DECIMAL(10,2)), ' Crores') AS `Total Sales`,
		CONCAT(CAST((SUM(Sales)*100.0/SUM(SUM(Sales)) OVER()) AS DECIMAL(10,2)), '%') AS `Sales Percentage`
FROM sales2
GROUP BY Location_type
ORDER BY 3 DESC;

# 3. KPI Metric Variation by Warehouse Type
SELECT Warehouse_type,
		CONCAT('₹', CAST(SUM(Sales)/10000000 AS DECIMAL(10,2)), ' Crores') AS `Total Sales`,
        CONCAT('₹', ROUND(AVG(Sales), 2)) AS `Average Sales`,
        ROUND(COUNT(Item_ID), 2) AS `Total items sold`,
        ROUND(AVG(Rating), 2) AS `Average Rating`
FROM sales2
GROUP BY Warehouse_type
ORDER BY 2 DESC;


## Lastly, we should create an internal pipeline that pulls data and
# automatically populates the sales table (for all future product sales) in two stages:

# 1. At purchase time -> Insert product details (from Product_Tracker DB).
# 2. At dispatch time -> Update the same row with warehouse details (from Warehouse_Inventory DB).

DELIMITER //
CREATE TRIGGER add_purchase_to_sales
AFTER INSERT ON Product_Tracker
FOR EACH ROW
BEGIN
    INSERT INTO Amazon_Sales.sales2 (
		Item_status,
        Item_ID,
        Category,
        Item_engage_rate,
        Item_wt,
        Sales,
        Rating
    )
    VALUES (
        NEW.Item_status,
        NEW.Item_ID,
        NEW.Category,
        NEW.Item_engage_rate,
        NEW.Item_wt,
        NEW.Sales,
        NEW.Rating
    );
END;
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER update_sales_with_warehouse_on_dispatch
AFTER UPDATE ON Warehouse_Inventory
FOR EACH ROW
BEGIN
    # Only run if dispatch_status just changed to 'Dispatched' in Warehouse_Inventory
    IF NEW.dispatch_status = 'Dispatched' AND OLD.dispatch_status <> 'Dispatched' THEN
        UPDATE Amazon_Sales.sales2
        SET
            Year_est = NEW.Year_est,
            Warehouse_ID = NEW.Warehouse_ID,
            Location_type = NEW.Location_type,
            Warehouse_size = NEW.Warehouse_size,
            Warehouse_type = NEW.Warehouse_type
        WHERE Item_ID = NEW.Item_ID;
    END IF;
END;
//
DELIMITER ;