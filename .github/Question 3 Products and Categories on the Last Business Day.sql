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
