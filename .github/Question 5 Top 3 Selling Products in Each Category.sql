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
