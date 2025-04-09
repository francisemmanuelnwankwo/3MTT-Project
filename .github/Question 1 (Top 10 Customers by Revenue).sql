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
