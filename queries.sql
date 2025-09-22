-- ============================================================
-- 🕵️ Advanced SQL Retrieval Project – The Jaxpax Case Files
-- Author: Joel Mathew
-- Dataset: Jaxpax (Retail Unit Simulator)
-- Tables: Customers, Orders, Products, Employees, Suppliers
-- ============================================================
-- Each query represents a "case" solved through SQL investigation.
-- Explanations are included as detective-style notes.
-- ============================================================


-- ============================================================
-- Case 1: The Missing Supplier Email
-- ------------------------------------------------------------
-- Question:
--   Who supplied the fabric used in the Canoe Pack?
-- Observation:
--   Fabric and Supplier tables had no direct relationship.
-- Deduction:
--   Product acted as the missing link between them.
-- Evidence:
--   Query retrieves supplier email + fabric description.
-- ============================================================
SELECT fa.FabDesc, su.SupEmailAddr
FROM Fabric AS fa
INNER JOIN Product AS pr ON fa.fabcode = pr.prodFabCode
INNER JOIN Supplier AS su ON fa.FabSupplier = su.SupID
WHERE pr.ProdDesc = 'Canoe Pack';


-- ============================================================
-- Case 2: The Price Puzzle
-- ------------------------------------------------------------
-- Task:
--   Summarize product prices across the catalog:
--   - Average price
--   - Total value
--   - Min (most affordable)
--   - Max (most expensive)
--   - Count of products
-- ============================================================
SELECT AVG(prodprice) AS average_price,
       SUM(prodprice) AS total_value,
       MIN(prodprice) AS Affordable_Value,
       MAX(prodprice) AS Expensive_product_Value,
       COUNT(prodprice) AS Total_product_count
FROM Product;


-- ============================================================
-- Case 3: Orders Under the Lens
-- ------------------------------------------------------------
-- Question:
--   What is the average product price and total items per order?
-- Deduction:
--   GROUP BY order number was essential – otherwise results
--   would aggregate across all orders.
-- ============================================================
SELECT OrdNum, AVG(price) AS Average_price, COUNT(price) AS Total_Order
FROM Orderitem
GROUP BY OrdNum;


-- ============================================================
-- Case 4: The Top Shipper
-- ------------------------------------------------------------
-- Task:
--   Identify the shipper who handled the highest volume of orders.
-- Connection:
--   Shipper table holds company names and IDs.
--   Orders table references ShipID as a foreign key.
-- Conclusion:
--   United States Postale emerged as the busiest shipper (6 orders).
-- ============================================================
SELECT Sh.ShipCompany, COUNT(O.OrdNum) AS Total_orders
FROM Shipper AS Sh
INNER JOIN Orders O ON Sh.shipID = O.shipID
GROUP BY ShipCompany;


-- ============================================================
-- Case 5: Orders Greater Than Two
-- ------------------------------------------------------------
-- Question:
--   Which orders contain more than 2 products?
-- Detective’s Note:
--   HAVING was necessary instead of WHERE since the filter
--   applies after aggregation.
-- ============================================================
SELECT OrdNum, COUNT(price) AS Total_Order
FROM Orderitem
GROUP BY OrdNum
HAVING Total_Order > 2;


-- ============================================================
-- Case 6: Minnesota’s Exclusive Orders
-- ------------------------------------------------------------
-- Task:
--   Find orders with more than one product,
--   but only if supplied by Minnesota-based suppliers.
-- Reasoning:
--   No direct link between OrderItem and Supplier.
--   Required chain of joins: OrderItem → Product → Fabric → Supplier.
-- ============================================================
SELECT oi.OrdNum, COUNT(oi.prodID) AS TotalProducts
FROM Orderitem oi
JOIN Product p ON oi.prodID = p.prodID
JOIN Fabric f ON f.fabcode = p.prodFabCode
JOIN Supplier s ON f.FabSupplier = s.SupID
WHERE s.supstate = 'MN'
GROUP BY oi.OrdNum
HAVING COUNT(oi.prodID) > 1;


-- ============================================================
-- Case 7: Above Average Products
-- ------------------------------------------------------------
-- Task:
--   List products with prices above the overall average.
-- Method:
--   Subquery calculates the average; outer query compares against it.
-- ============================================================
SELECT ProdDesc, prodprice
FROM Product
WHERE prodprice > (
    SELECT AVG(prodprice) 
    FROM Product
);


-- ============================================================
-- Case 8: The Discount Mystery
-- ------------------------------------------------------------
-- Task:
--   Show each order’s product ID, discount level, 
--   and amounts before and after discount.
-- Discount rules:
--   - b = 5% off
--   - c = 10% off
--   - d = 20% off
--   - others = no discount
-- ============================================================
SELECT OrdNum,
       prodID,
       DiscountLevel,
       (quantity * price) AS Due_amount,
       CASE DiscountLevel
            WHEN 'b' THEN (quantity * price) * 0.95
            WHEN 'c' THEN (quantity * price) * 0.90
            WHEN 'd' THEN (quantity * price) * 0.80
            ELSE (quantity * price)
       END AS Due_after_discount
FROM Orderitem;


-- ============================================================
-- Bonus Cases: ProductLine Database
-- ============================================================

-- Case 9: Products from Both Divisions
-- ------------------------------------------------------------
-- Task:
--   Retrieve all products from East and West divisions.
-- Note:
--   UNION removes duplicate records automatically.
-- ============================================================
SELECT prodID, ProdDesc
FROM ProductEast
UNION
SELECT prodID, ProdDesc
FROM ProductWest;


-- Case 10: Common Products Across Divisions
-- ------------------------------------------------------------
-- Task:
--   Identify products manufactured in both divisions.
-- Method:
--   INTERSECT returns only matching rows.
-- ============================================================
SELECT prodID, ProdDesc
FROM ProductEast
INTERSECT
SELECT prodID, ProdDesc
FROM ProductWest;
