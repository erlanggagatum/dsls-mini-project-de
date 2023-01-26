-- Customer Analysis Customer Loyal: Bertahan di top 10 purchase tertinggi setiap bulan
SELECT ODR.*
	FROM (
	SELECT SUM(ods.Quantity * ods.UnitPrice) Sales, MONTH(ods.OrderDate) Month, ods.CustomerID, 
		ROW_NUMBER() OVER (PARTITION BY MONTH(ods.OrderDate) ORDER BY SUM(ods.Quantity * ods.UnitPrice) desc) as Rank
	FROM (
		SELECT o.OrderID, od.UnitPrice, od.Quantity, o.CustomerID, o.EmployeeID, o.OrderDate
		FROM [Order Details] od INNER JOIN Orders o on od.OrderID = o.OrderID
		WHERE YEAR(o.OrderDate) = 1997
		) ods
GROUP BY MONTH(ods.OrderDate), ods.CustomerID ) ODR
WHERE ODR.Rank <= 10

-- Product Analysis: Tren Jenis produk setiap bulan 1997 - 1998
SELECT c.CategoryName, os.Year, os.Month, SUM(OS.Quantity) Quantity
FROM
	(SELECT od.ProductID, SUM(od.Quantity) AS Quantity, YEAR(o.OrderDate) AS Year, MONTH(o.OrderDate) as Month
	FROM [Order Details] od INNER JOIN Orders o on od.OrderID = o.OrderID
	WHERE YEAR(o.OrderDate) = 1997 or YEAR(o.OrderDate) = 1998
	GROUP BY od.ProductID, YEAR(o.OrderDate), MONTH(o.OrderDate)) os 
	INNER JOIN Products p on p.ProductID = os.ProductID
	INNER JOIN Categories c on c.CategoryID = p.CategoryID
GROUP BY c.CategoryName, os.Year, os.Month
ORDER BY c.CategoryName, os.Year, os.Month

-- Employee Analysis: Title employee yang banyak menerima order
SELECT COUNT(o.EmployeeID) OrderNumber, e.Title
FROM Orders o INNER JOIN Employees e on o.EmployeeID = e.EmployeeID
WHERE YEAR(o.OrderDate) = 1997
GROUP BY e.Title