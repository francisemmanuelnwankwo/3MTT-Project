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
