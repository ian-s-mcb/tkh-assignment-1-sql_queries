/*
 Apex Global Warehouse Assignment

 Author: Ian S. McBride
 Date: 2026-01-30
*/

-- 1. - Quick Stock Check
--
-- Question: Management wants a quick look at our inventory. Show the
-- product_name, category, and actual_price for the first 10 products.
--
-- Explanation: yields the first 10 products in the table by putting output
-- limit.
SELECT product_name, category, actual_price
FROM `tlab-1-sql.warehouse_analysis.amazon_products`
LIMIT 10;

-- 2. - Identifying High-Value Items
--
-- Question: Find all products where the actual_price is greater than 5,000.
-- Show the name and the price.
--
-- Explanation: only outputs products that meet a greater than or equal criteria
SELECT product_name, actual_price
FROM `tlab-1-sql.warehouse_analysis.amazon_products`
WHERE actual_price >= 5000;

-- 3. The Discount Impact
--
-- Question: Calculate the total amount saved (Actual Price - Discounted Price)
--for each product. Call this new column total_savings.
--
-- Explanation: outputs a computed column by subtracting two regular columns and
-- then sorts the outputs by the computed column in descending order
SELECT product_name, (actual_price - discounted_price) total_savings
FROM `tlab-1-sql.warehouse_analysis.amazon_products`
ORDER BY total_savings DESC;

-- 4. Inventory Diversity
--
-- Question: How many unique products do we have in each category? Show the
-- category and the count.
--
-- Explanation: groups products by category, counts up how many products are
-- in each category, and outputs that product count along with the category name
SELECT category, COUNT(*) number_of_products
FROM `tlab-1-sql.warehouse_analysis.amazon_products`
GROUP BY category;

-- 5. Customer Favorites
--
-- Question: We need a list of highly-rated products. Find products that have a
-- rating higher than 4.5 and more than 10,000 rating_count.
--
-- Explanation: uses a WITH statement to safe cast the rating from a string to
-- float, then selects the casted value from the WITH statement and uses it with
-- a WHERE expression that applies two boolean conditions using the greater than
-- operator. The reason for cast is because strings cannot be compared with a
-- greater than operator. A safe cast is used avoid the casting from throwing an
-- error if a value cannot converted properly.
WITH rating_cast AS (
  SELECT product_name, SAFE_CAST(rating AS FLOAT64) AS rating_dec, rating_count
  FROM `tlab-1-sql.warehouse_analysis.amazon_products`
)
SELECT product_name, rating_dec, rating_count
FROM rating_cast
WHERE rating_dec > 4.5 AND rating_count > 10000;

--  6. Discount Strategy Analysis
--
-- Question: What is the average discount_percentage for products in the
-- 'Electronics' category?
--
-- Explanation: computes the average discount percentage for products that meet
-- a string expression, which checks whether the category contains electronics
-- in a case-insensitive fashion.
SELECT AVG(discount_percentage) AS avg_discount_percentage
FROM `tlab-1-sql.warehouse_analysis.amazon_products`
WHERE LOWER(category) LIKE '%electronic%';

-- 7. Cleaning Up the Ratings
--
-- Question: Some ratings are missing or corrupted (like the '|' character). Use
-- a CASE statement to show the product_name and a new column that turns any
-- rating of '|' into 0.0, otherwise keep the original rating.
--
-- Explanation: outputs ratings unchanged if they aren't the bad value ('|'),
-- otherwise changes the value to '0.0'. This accomplished with CASE statement
-- that works just like if-then-else branching.
SELECT
  product_name,
  CASE 
    WHEN rating <> '|' THEN rating
    ELSE '0.0'
    END AS rating_clean
FROM `tlab-1-sql.warehouse_analysis.amazon_products`;

-- 8. Pricing Brackets
--
-- Question: Create a column called price_bracket where:
--   * actual_price < 500 is 'Budget'
--   * actual_price between 500 and 2000 is 'Mid-Range'
--   * actual_price > 2000 is 'Premium'
--
-- Explanation: uses a case statement to first check if the actual price is in
-- the lowest range, then mid range, and if neither is the case, it's assumed
-- that the price is premium.
SELECT
  product_name, actual_price,
  CASE
    WHEN actual_price < 500 THEN 'Budget'
    WHEN actual_price < 2000 THEN 'Mid-Range'
    ELSE 'Premium'
    END AS price_bracket
FROM `tlab-1-sql.warehouse_analysis.amazon_products`;

-- 9. Missing Data Audit
--
-- Question: Identify any products where the rating_count is missing. This is
-- crucial for our data integrity report.
--
-- Explanation: outputs products where the rating count column is null, meaning
-- it doesn't have a value.
SELECT product_name, rating_count
FROM `tlab-1-sql.warehouse_analysis.amazon_products`
WHERE rating_count IS NULL;


-- 10. Competitive Categories
--
-- Question: Which categories have an average rating above 4.0? Only show
-- categories that have more than 5 products.
--
-- Explanation: casts ratings as float using a with statement and safe cast,
-- then groups the products by category, then computes the average rating and
-- number of products in each category, and finally outputs the category product
-- count if two boolean conditions are met using a HAVING statement. The
-- conditions are that the average rating and product count must be larger
-- than 4 and 5, respectfully.
WITH rating_cast AS (
  SELECT category, SAFE_CAST(rating AS FLOAT64) AS rating_dec
  FROM `tlab-1-sql.warehouse_analysis.amazon_products`
)
SELECT category, AVG(rating_dec) AS avg_rating, COUNT(*) AS product_count
FROM rating_cast
GROUP BY category
HAVING avg_rating > 4 AND product_count > 5;
