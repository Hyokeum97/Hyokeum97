/*want to use aggregate funtion, but don't want to make the result that sumed with/gruped
by the standard -> have to use WINDOW FUNTION -> OVER()
*/


SELECT p.FirstName, p.LastName, E.JobTitle, EPH.Rate, 
AVG(rate) OVER() AS AverageRate, 
MaximumRate = MAX(EPH.Rate)OVER(),
DiffFromAvgRate = EPH.Rate - AVG(EPH.Rate) OVER(),
PercentofMaxRate = EPH.Rate/MAX(EPH.Rate) OVER()
FROM AdventureWorks2022.Person.Person p
JOIN AdventureWorks2022.HumanResources.Employee E ON p.BusinessEntityID = E.BusinessEntityID
JOIN AdventureWorks2022.HumanResources.EmployeePayHistory EPH ON p.BusinessEntityID = EPH.BusinessEntityID
ORDER BY 
EPH.Rate desc


/*want to use group funtion and over duntion at the same time-> pratition by.
FIRST_VALUE(column that I want to make as a standard) OVER(PARTITION BY(column that I want to make
as an group) ORDER BY (column that I want to make as a standard) */

SELECT SalesOrderID,
SalesOrderDetailID,
LineTotal,
Ranking = ROW_NUMBER()OVER(PARTITION BY SalesOrderID ORDER BY LineTotal DESC),
HighestTotal= FIRST_VALUE(LineTotal) OVER(PARTITION BY SalesOrderID ORDER BY LineTotal DESC),
LowestTotal= FIRST_VALUE(LineTotal) OVER(PARTITION BY SalesOrderID ORDER BY LineTotal)
FROM
AdventureWorks2022.Sales.SalesOrderDetail
ORDER BY
SalesOrderID, LineTotal DESC


SELECT 
BusinessEntityID AS EmployeeID, 
JobTitle, 
HireDate, 
VacationHours,
FirstHireVacationHours = FIRST_VALUE(VacationHours) OVER(PARTITION BY JobTitle ORDER BY HireDate DESC)
FROM AdventureWorks2022.HumanResources.Employee
ORDER BY JobTitle, HireDate ASC

SELECT pp.ProductID, pp.Name AS ProductName, pplp.ListPrice, pplp.ModifiedDate
FROM AdventureWorks2022.Production.Product pp
JOIN AdventureWorks2022.Production.ProductListPriceHistory PPLP
ON pp.ProductID = pplp.ProductID


--Using subqueries to filter/describe the  detailed data

SELECT
PurchaseOrderID,
VendorID,
OrderDate,
TaxAmt,
Freight,
TotalDue,
GETDATE()redsddsddsasd
FROM
(
SELECT 
PurchaseOrderID,
VendorID,
OrderDate,
TaxAmt,
Freight,
TotalDue,
ROW_NUMBER() OVER(PARTITION BY VendorID ORDER BY TotalDue DESC) as expensiveid
FROM AdventureWorks2022.Purchasing.PurchaseOrderHeader
) A

WHERE expensiveid <=3

--Scalar subqueries
SELECT AVG(ListPrice)
FROM AdventureWorks2022.Production.Product

SELECT
ProductID, Name,StandardCost,ListPrice,AvgListprice = (SELECT AVG(ListPrice) FROM AdventureWorks2022.Production.Product)
FROM
AdventureWorks2022.Production.Product
--Subqueies requires aliases if it used in FROM queries, but the others, does not require like scalar subqueries
--Main use of scalar subqueries = when I want to use aggregate funtions in where clauses.
--if there is no scalar subqueies, I have to use whole subqueries to write aggregate funtion in WHERE clause

SELECT
BusinessEntityID,JobTitle,
VacationHours, 
MaxVacationHours = (SELECT MAX(VacationHours) FROM AdventureWorks2022.HumanResources.Employee),
MAXVationHoursProportion = ROUND(CAST(VacationHours as FLO AT)/(SELECT MAX(CAST(VacationHours as FLOAT)) FROM AdventureWorks2022.HumanResources.Employee),3)
FROM AdventureWorks2022.HumanResources.Employee
WHERE ROUND(CAST(VacationHours as FLOAT)/(SELECT MAX(CAST(VacationHours as FLOAT)) FROM AdventureWorks2022.HumanResources.Employee),3)>=0.8

--Correlated Subqueries?
SELECT SalesOrderID,OrderDate,SubTotal,TaxAmt,Freight,TotalDue
FROM AdventureWorks2022.Sales.SalesOrderHeader

SELECT COUNT(*)
FROM AdventureWorks2022.Sales.SalesOrderDetail
WHERE SalesOrderID = 43659

SELECT 
SalesOrderID,
OrderDate,
SubTotal,
TaxAmt,
Freight,
TotalDue,
bla = 
	(	
		SELECT COUNT(*)
		FROM AdventureWorks2022.Sales.SalesOrderDetail a
		WHERE a.SalesOrderID = b.SalesOrderID
			AND a.OrderQty > 1
	)
FROM AdventureWorks2022.Sales.SalesOrderHeader b



SELECT 
	b.PurchaseOrderID, 
	b.VendorID, 
	b.OrderDate, 
	b.TotalDue,
	NonRejectedItems = 
	(
	SELECT COUNT(*)
	FROM AdventureWorks2022.Purchasing.PurchaseOrderDetail a
	WHERE a.PurchaseOrderID = b.PurchaseOrderID 
		and a.RejectedQty = 0
	),
	MostExpensiveItem = 
	(
	SELECT MAX(a.UnitPrice)
	FROM AdventureWorks2022.Purchasing.PurchaseOrderDetail a
	WHERE a.PurchaseOrderID = b.PurchaseOrderID 
	)
FROM AdventureWorks2022.Purchasing.PurchaseOrderHeader b



SELECT RejectedQty
	FROM AdventureWorks2022.Purchasing.PurchaseOrderDetail a
	WHERE RejectedQty <> 0



--EXISTS queries

SELECT a.PurchaseOrderID,a.OrderDate,a.SubTotal,a.TaxAmt
FROM AdventureWorks2022.Purchasing.PurchaseOrderHeader a
WHERE EXISTS
(
SELECT 1--b.PurchaseOrderID,b.OrderQty
FROM AdventureWorks2022.Purchasing.PurchaseOrderDetail b
WHERE a.PurchaseOrderID = b.PurchaseOrderID
	AND OrderQty>500
)
ORDER BY PurchaseOrderID



SELECT
       A.PurchaseOrderID
      ,A.OrderDate
      ,A.SubTotal
	  ,A.TaxAmt

FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader A

WHERE EXISTS (
	SELECT
	1
	FROM AdventureWorks2019.Purchasing.PurchaseOrderDetail B
	WHERE A.PurchaseOrderID = B.PurchaseOrderID
		AND B.OrderQty > 500
)

ORDER BY 1


--Pivot funtion syntax example

SELECT
[Accessories],
[Bikes],
[Clothing],
[Components]

FROM
(
SELECT
	   ProductCategoryName = D.Name,
	   A.LineTotal

FROM AdventureWorks2019.Sales.SalesOrderDetail A
	JOIN AdventureWorks2019.Production.Product B
		ON A.ProductID = B.ProductID
	JOIN AdventureWorks2019.Production.ProductSubcategory C
		ON B.ProductSubcategoryID = C.ProductSubcategoryID
	JOIN AdventureWorks2019.Production.ProductCategory D
		ON C.ProductCategoryID = D.ProductCategoryID
) E

PIVOT(
SUM(LineTotal)
FOR ProductCategoryName IN([Accessories],[Bikes],[Clothing],[Components])
) F

ORDER BY 1


--CTE
WITH Temtable1 as
(
)
SELECT
A.OrderMonth,
A.TotalSales,
B.TotalPurchases

FROM (
	SELECT
	OrderMonth,
	TotalSales = SUM(TotalDue)
	FROM (
		SELECT 
		   OrderDate
		  ,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
		  ,TotalDue
		  ,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
		FROM AdventureWorks2019.Sales.SalesOrderHeader
		) S
	WHERE OrderRank > 10
	GROUP BY OrderMonth
) A

JOIN (
	SELECT
	OrderMonth,
	TotalPurchases = SUM(TotalDue)
	FROM (
		SELECT 
		   OrderDate
		  ,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
		  ,TotalDue
		  ,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
		FROM AdventureWorks2019.Purchasing.PurchaseOrderHeader
		) P
	WHERE OrderRank > 10
	GROUP BY OrderMonth
) B	ON A.OrderMonth = B.OrderMonth

ORDER BY 1


--SQL CTE recursion
WITH NumberSeries AS
(
SELECT 1 AS MyNumber

UNION ALL

SELECT
MyNumber+1
FROM NumberSeries
WHERE MyNumber <100
)
SELECT
MyNumber
FROM NumberSeries


--CREATE TABLE

CREATE TABLE #Sales
(
       OrderDate DATE
	  ,OrderMonth DATE
      ,TotalDue MONEY
	  ,OrderRank INT
)

INSERT INTO #Sales
(
       OrderDate
	  ,OrderMonth
      ,TotalDue
	  ,OrderRank
)
SELECT 
       OrderDate
	  ,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
      ,TotalDue
	  ,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)

FROM AdventureWorks2022.Sales.SalesOrderHeader

SELECT *
FROM #Top10Sales

CREATE TABLE #Top10Sales
(
OrderMonth DATE,
Top10Total MONEY
)

INSERT INTO #Top10Sales

SELECT
OrderMonth,
Top10Total = SUM(TotalDue)

FROM #Sales
WHERE OrderRank <= 10
GROUP BY OrderMonth



SELECT
A.OrderMonth,
A.Top10Total,
PrevTop10Total = B.Top10Total

FROM #Top10Sales A
	LEFT JOIN #Top10Sales B
		ON A.OrderMonth = DATEADD(MONTH,1,B.OrderMonth)

ORDER BY 1

SELECT * FROM #Sales WHERE OrderRank <= 10

DROP TABLE #Sales
DROP TABLE #Top10Sales


CREATE VIEW Sales.vw_Top10MonthOverMonth AS 

 WITH Sales AS
(
SELECT
OrderDate
,OrderMonth = DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1)
,TotalDue
,OrderRank = ROW_NUMBER() OVER(PARTITION BY DATEFROMPARTS(YEAR(OrderDate),MONTH(OrderDate),1) ORDER BY TotalDue DESC)
FROM AdventureWorks2022.Sales.SalesOrderHeader
)
 
,Top10Sales AS
(
SELECT
OrderMonth,
Top10Total = SUM(TotalDue)
FROM Sales
WHERE OrderRank <= 10
GROUP BY OrderMonth
)
 
SELECT
A.OrderMonth,
A.Top10Total,
PrevTop10Total = B.Top10Total
 
FROM Top10Sales A
LEFT JOIN Top10Sales B
ON A.OrderMonth = DATEADD(MONTH,1,B.OrderMonth)
 


USE AdventureWorks2022
GO

--UDF

CREATE FUNCTION dbo.ufnCurrentDate()
RETURNS DATE
AS
BEGIN
	RETURN CAST(GETDATE()as DATE)
END


--TVF creation 

CREATE Production.ufn_ProductsByPriceRange (@UserMin MONEY,@UserMax MONEY)

RETURNS TABLE

AS

RETURN
(
SELECT ProductID, Name, ListPrice
FROM Production.Product
WHERE ListPrice BETWEEN @UserMin AND @UserMax
)

--Stoored Proocedure
CREATE PROCEDURE dbo.OrdersAboveThreshold (@Threshold ,@StartYear DATE, @EndYear DATE)

AS

BEGIN

(SELECT *
FROM 
WHERE 

END

-----------------------------------------------------------------------------------------
CREATE PROCEDURE dbo.OrdersAboveThreshold(@Threshold MONEY, @StartYear INT, @EndYear INT)

AS

BEGIN
	SELECT 
		A.SalesOrderID,
		A.OrderDate,
		A.TotalDue

	FROM  AdventureWorks2022.Sales.SalesOrderHeader A
		JOIN AdventureWorks2022.dbo.Calendar B
			ON A.OrderDate = B.DateValue

	WHERE A.TotalDue >= @Threshold
		AND B.YearNumber BETWEEN @StartYear AND @EndYear
END


--Execute the procedure:

EXEC dbo.OrdersAboveThreshold 10000, 2011, 2013
