-- Tulis query untuk mendapatkan jumlah customer tiap bulan yang melakukan order pada tahun 1997.
SELECT Month(OrderDate) month, COUNT(DISTINCT CustomerID) Customer_Count4
FROM Orders
WHERE Year(OrderDate) = 1997
GROUP BY Month(OrderDate)

-- Tulis query untuk mendapatkan nama employee yang termasuk Sales Representative.
SELECT CONCAT(FirstName, ' ', LastName) Employee
FROM Employees
WHERE Title = 'Sales Representative'

-- Tulis query untuk mendapatkan top 5 nama produk yang quantitynya paling banyak diorder pada bulan Januari 1997.
SELECT TOP 5 SUM(od.Quantity) QTY_SUM, p.ProductName
FROM ([Order Details] od INNER JOIN Products p on od.ProductID = p.ProductID) INNER JOIN Orders o on o.OrderID = od.OrderID 
WHERE YEAR(o.OrderDate) = 1997 and MONTH(o.OrderDate) = 1
GROUP BY p.ProductName
ORDER BY SUM(od.Quantity) DESC

-- Tulis query untuk mendapatkan nama company yang melakukan order Chai pada bulan Juni 1997.
SELECT DISTINCT c.CompanyName
FROM [Order Details] od INNER JOIN (Orders o INNER JOIN Customers c on o.CustomerID = c.CustomerID) on od.OrderID = o.OrderID
WHERE YEAR(o.OrderDate) = 1997 and MONTH(o.OrderDate) = 6

-- Tulis query untuk mendapatkan jumlah OrderID yang pernah melakukan sales (unit_price dikali quantity) <=100, 100<x<=250, 250<x<=500, dan >500.
SELECT count(sc.SalesCategory) as SalesCategoryCount, sc.SalesCategory
FROM (
SELECT *, (UnitPrice * Quantity) Sales,
	CASE
		WHEN (UnitPrice * Quantity) <=100 THEN '<=100'
		WHEN (UnitPrice * Quantity) BETWEEN 100 and 251  THEN '100<x<=250'
		WHEN (UnitPrice * Quantity) BETWEEN 250 and 501 THEN '250<x<=500'
		ELSE '>500'
	END as SalesCategory
FROM [Order Details]) sc
GROUP BY sc.SalesCategory

-- Tulis query untuk mendapatkan Company name yang melakukan sales di atas 500 pada tahun 1997.
SELECT c.CompanyName, SUM(s.Sales) SalesSum
FROM 
	(SELECT SUM(UnitPrice * Quantity) Sales, o.OrderID
	FROM [Order Details] od INNER JOIN Orders o on od.OrderID = o.OrderID
	WHERE YEAR(o.OrderDate) = 1997
	GROUP BY o.OrderID) s 
	INNER JOIN (Orders o 
	INNER JOIN Customers c on c.CustomerID = o.CustomerID) on s.OrderID = o.OrderID
GROUP BY c.CompanyName
HAVING SUM(s.Sales) > 500

-- Tulis query untuk mendapatkan nama produk yang merupakan Top 5 sales tertinggi tiap bulan di tahun 1997.
SELECT RS.*, p.ProductName
FROM
(SELECT 
	*,
    ROW_NUMBER() OVER (PARTITION BY ps.month Order by Sales DESC) AS Rank
FROM (
SELECT SUM(Quantity * UnitPrice) as Sales, YEAR(o.OrderDate) year,  MONTH(o.OrderDate) month, od.ProductID 
FROM 
	[Order Details] od INNER JOIN Orders o on od.OrderID = o.OrderID
WHERE YEAR(OrderDate) = 1997
GROUP BY od.ProductID, YEAR(o.OrderDate), MONTH(o.OrderDate)) ps) RS
INNER JOIN Products p on RS.ProductID = p.ProductID 
WHERE RS.Rank <= 5

-- Buatlah view untuk melihat Order Details yang berisi OrderID, ProductID, ProductName, UnitPrice, Quantity, Discount, Harga setelah diskon.
CREATE VIEW OrderDetailsView
AS
SELECT od.*, od.UnitPrice * od.Quantity * (1-od.Discount) as FinalPrice, p.ProductName
FROM [Order Details] od INNER JOIN Products p on od.ProductID = p.ProductID
GO

SELECT * FROM OrderDetailsView

-- Buatlah procedure Invoice untuk memanggil CustomerID, CustomerName, OrderID, OrderDate, RequiredDate, ShippedDate jika terdapat inputan CustomerID tertentu.
CREATE PROCEDURE Invoice @id NVARCHAR(30)
AS
SELECT c.CustomerID, c.ContactName as CustomerName, o.OrderID, o.OrderDate, o.RequiredDate, o.ShippedDate
FROM Orders o INNER JOIN Customers c on o.CustomerID = c.CustomerID
WHERE c.CustomerID = @id;

EXEC Invoice 'ALFKI';

SELECT c.CustomerID, c.ContactName as CustomerName, o.OrderID, o.OrderDate, o.RequiredDate, o.ShippedDate
FROM Orders o INNER JOIN Customers c on o.CustomerID = c.CustomerID
WHERE c.CustomerID = 'ALFKI'