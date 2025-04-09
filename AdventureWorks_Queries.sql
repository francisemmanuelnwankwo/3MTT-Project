--Question 1 (Top 10 Customers by Revenue)

SELECT TOP 10
    c.FirstName + ' ' + c.LastName AS FullName,
    a.CountryRegion AS Country,
    a.City,
    SUM(sod.OrderQty * sod.UnitPrice) AS Revenue
FROM SalesLT.SalesOrderHeader soh
JOIN SalesLT.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN SalesLT.Customer c ON soh.CustomerID = c.CustomerID
JOIN SalesLT.Address a ON soh.ShipToAddressID = a.AddressID
GROUP BY c.FirstName, c.LastName, a.CountryRegion, a.City
ORDER BY Revenue DESC;



--Question 2: Segment Customers by Total Revenue
WITH CustomerRevenue AS (
    SELECT 
        c.CustomerID,
        c.CompanyName,
        SUM(sod.OrderQty * sod.UnitPrice) AS TotalRevenue
    FROM SalesLT.SalesOrderHeader soh
    JOIN SalesLT.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN SalesLT.Customer c ON soh.CustomerID = c.CustomerID
    GROUP BY c.CustomerID, c.CompanyName
),
SegmentedRevenue AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY TotalRevenue DESC) AS SegmentRank
    FROM CustomerRevenue
)
SELECT 
    CustomerID,
    CompanyName,
    TotalRevenue,
    CASE SegmentRank
        WHEN 1 THEN 'Platinum'
        WHEN 2 THEN 'Gold'
        WHEN 3 THEN 'Silver'
        WHEN 4 THEN 'Bronze'
    END AS RevenueSegment
FROM SegmentedRevenue
ORDER BY TotalRevenue DESC;



--Question 3: Products and Categories on the Last Business Day
WITH LastOrder AS (
    SELECT MAX(OrderDate) AS LastOrderDate
    FROM SalesLT.SalesOrderHeader
)
SELECT 
    soh.CustomerID,
    p.ProductID,
    p.Name AS ProductName,
    pc.Name AS CategoryName,
    soh.OrderDate
FROM SalesLT.SalesOrderHeader soh
JOIN SalesLT.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN SalesLT.Product p ON sod.ProductID = p.ProductID
JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
JOIN LastOrder lo ON soh.OrderDate = lo.LastOrderDate
ORDER BY soh.CustomerID;


--Question 4: Create View
CREATE VIEW CustomerSegment AS
WITH CustomerRevenue AS (
    SELECT 
        c.CustomerID,
        c.CompanyName,
        SUM(sod.OrderQty * sod.UnitPrice) AS TotalRevenue
    FROM SalesLT.SalesOrderHeader soh
    JOIN SalesLT.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN SalesLT.Customer c ON soh.CustomerID = c.CustomerID
    GROUP BY c.CustomerID, c.CompanyName
),
SegmentedRevenue AS (
    SELECT *,
        NTILE(4) OVER (ORDER BY TotalRevenue DESC) AS SegmentRank
    FROM CustomerRevenue
)
SELECT 
    CustomerID,
    CompanyName,
    TotalRevenue,
    CASE SegmentRank
        WHEN 1 THEN 'Platinum'
        WHEN 2 THEN 'Gold'
        WHEN 3 THEN 'Silver'
        WHEN 4 THEN 'Bronze'
    END AS RevenueSegment
FROM SegmentedRevenue;
SELECT * FROM CustomerSegment;


--Question 5: Top 3 Selling Products in Each Category

WITH ProductRevenue AS (
    SELECT 
        p.ProductID,
        p.Name AS ProductName,
        pc.Name AS CategoryName,
        SUM(sod.OrderQty * sod.UnitPrice) AS TotalRevenue
    FROM SalesLT.SalesOrderDetail sod
    JOIN SalesLT.Product p ON sod.ProductID = p.ProductID
    JOIN SalesLT.ProductCategory pc ON p.ProductCategoryID = pc.ProductCategoryID
    GROUP BY p.ProductID, p.Name, pc.Name
),
RankedProducts AS (
    SELECT *,
        RANK() OVER (PARTITION BY CategoryName ORDER BY TotalRevenue DESC) AS RankNum
    FROM ProductRevenue
)
SELECT 
    ProductID,
    ProductName,
    CategoryName,
    TotalRevenue,
    RankNum
FROM RankedProducts
WHERE RankNum <= 3
ORDER BY CategoryName, RankNum;
