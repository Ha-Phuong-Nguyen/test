--tao bang DimProduct
CREATE TABLE DimProduct
( Product_id INT NOT NULL,
ProductName nvarchar(50) NULL,
ProductPrice INT NULL,
ProductStatus nvarchar(30) NULL,
ProductCategoryid INT NULL)

TRUNCATE TABLE DimProduct
INSERT INTO DimProduct
SELECT DISTINCT [Product Card Id], [Product Name], CONVERT(numeric, [Product Price]), [Product Status], [Product Category Id] FROM [dbo].[DataCoSupplyChainDataset]
ORDER BY [Product Card Id]

--tao bang DimProductCat
CREATE TABLE DimProductCategory
(CategoryId INT NOT NULL, 
CategoryName nvarchar(50) NULL)

INSERT INTO DimProductCategory
SELECT DISTINCT CONVERT(INT,[Category Id]), [Category Name] FROM [dbo].[DataCoSupplyChainDataset]

--SELECT * FROM [dbo].[DimProduct] A
--INNER JOIN [dbo].[DimProductCategory] B ON A.ProductCategoryid=B.CategoryId

--tao bang DimGeography
CREATE TABLE DimGeography
(CityKey BIGINT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
City varchar(50) NULL,
State varchar(50) NULL,
Country varchar(50) NULL,
Region varchar(50) NULL,
Region varchar(50) NULL)

INSERT INTO DimGeography (City,State, Country, Region,Region)
SELECT DISTINCT  [Order City],  [Order State], [Order Country], [Order Region], Region
FROM [dbo].[DataCoSupplyChainDataset]
ORDER BY [Region], [Order Region], [Order Country], [Order State], [Order City]

--tao bang DimDepartment
DROP TABLE  DimDepartment
CREATE TABLE DimDepartment
(DepartmentId INT NOT NULL,
DepartmentName nvarchar(50) NULL)

TRUNCATE TABLE DimDepartment
INSERT INTO DimDepartment(DepartmentId, DepartmentName)
SELECT DISTINCT CONVERT(INT,[Department Id]), [Department Name] FROM [dbo].[DataCoSupplyChainDataset]

--tao bang DimCustomer
DROP TABLE DimCustomer
CREATE TABLE DimCustomer
(CustomerID nvarchar(50) NOT NULL PRIMARY KEY,
FirstName nvarchar(50) NULL,
Lastname nvarchar(50) NULL,
[Type] varchar(50) NULL,
ZipCode INT NULL,
CustomerStreet varchar(50) NULL,
CustomerCity varchar(50) NULL,
CustomerState varchar(50) NULL,
CustomerCountry varchar(50) NULL)

INSERT INTO DimCustomer
SELECT DISTINCT [Customer Id], [Customer Fname], [Customer Lname], [Customer Segment], [Customer Zipcode], [Customer Street] ,[Customer City], [Customer State], [Customer Country] FROM [dbo].[DataCoSupplyChainDataset]

--select [Order Id], [Days for shipment (scheduled)], [Days for shipping (real)], [Delivery Status], Late_delivery_risk, [Shipping Mode], [order date (DateOrders)] from [dbo].[DataCoSupplyChainDataset]
--ORDER BY [Order Id]

--SELECT * FROM [dbo].[DataCoSupplyChainDataset]
--WHERE [Order Id]='10'

--SELECT DISTINCT [Order Id], [Days for shipment (scheduled)], [Days for shipping (real)], [Delivery Status], Late_delivery_risk, [Shipping Mode] FROM [dbo].[DataCoSupplyChainDataset]

--tao bang DimDelivery
CREATE TABLE DimDelivery
(OrderID BIGINT NOT NULL,
ScheduledShippingDays INT NULL,
RealShippingDays INT NULL,
DeliveryStatus varchar(50) NULL,
LateRisk INT NULL, 
ShipMode varchar(50) NULL )
--DISTINCT vì trong cùng 1 đơn order khách hàng order các sp khác nhau tạo thành các record khác nhau
INSERT INTO DimDelivery
SELECT DISTINCT [order date (DateOrders)] , [Order Id], [Days for shipment (scheduled)], [Days for shipping (real)], [Delivery Status], Late_delivery_risk, [Shipping Mode] FROM [dbo].[DataCoSupplyChainDataset]


--tao bang DimOrder
DROP TABLE DimOrder
CREATE TABLE DimOrder
(OrderID BIGINT NOT NULL,
OrderStatus nvarchar(50) NULL,
TransactionType nvarchar(50) NULL,
OrderCity nvarchar(50) NULL,
OrderState nvarchar(50) NULL,
OrderCountry nvarchar(50) NULL,
OrderRegion nvarchar(50) NULL,
Region nvarchar(50) NULL)

INSERT INTO DimOrder
SELECT DISTINCT [Order Id], [Order Status], [Type], [Order City], [Order State], [Order Country], [Order Region], Region  FROM [dbo].[DataCoSupplyChainDataset]

--tao bang DimDate
SET DATEFIRST  7, -- 1 = Monday, 7 = Sunday
    DATEFORMAT mdy, 
    LANGUAGE   US_ENGLISH



DECLARE @StartDate  date =(SELECT MIN([order date (DateOrders)]) FROM [dbo].[DataCoSupplyChainDataset]), @years int = 4;
;WITH seq(n) AS 
(
  SELECT n = value FROM GENERATE_SERIES(0, 
    DATEDIFF(DAY, @STARTDATE, DATEADD(YEAR, @years, @StartDate))-1)
)
SELECT n FROM seq
ORDER BY n;

DECLARE @StartDate  date = (SELECT MIN([order date (DateOrders)]) FROM [dbo].[DataCoSupplyChainDataset]);

DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 4, @StartDate));

;WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(d) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
)
SELECT d FROM d
ORDER BY d
OPTION (MAXRECURSION 0);


DECLARE @StartDate  date =(SELECT MIN([order date (DateOrders)]) FROM [dbo].[DataCoSupplyChainDataset]);

DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 4, @StartDate));

;WITH seq(n) AS 
(
  SELECT 0 UNION ALL SELECT n + 1 FROM seq
  WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
),
d(d) AS 
(
  SELECT DATEADD(DAY, n, @StartDate) FROM seq
),
src AS
(
  SELECT
    TheDate         = CONVERT(date, d),
    TheDay          = DATEPART(DAY,       d),
    TheDayName      = DATENAME(WEEKDAY,   d),
    TheWeek         = DATEPART(WEEK,      d),
    TheISOWeek      = DATEPART(ISO_WEEK,  d),
    TheDayOfWeek    = DATEPART(WEEKDAY,   d),
    TheMonth        = DATEPART(MONTH,     d),
    TheMonthName    = DATENAME(MONTH,     d),
    TheQuarter      = DATEPART(Quarter,   d),
    TheYear         = DATEPART(YEAR,      d),
    TheFirstOfMonth = DATEFROMPARTS(YEAR(d), MONTH(d), 1),
    TheLastOfYear   = DATEFROMPARTS(YEAR(d), 12, 31),
    TheDayOfYear    = DATEPART(DAYOFYEAR, d)
  FROM d
)
SELECT CONVERT(varchar(12),TheDate,112) DateKey , LEFT(CONVERT(varchar(12),TheDate,112),6) MonthKey, TheDate, TheDayOfWeek, TheDayName,TheDay AS TheDayOfMonth , TheMonthName,TheDayOfYear, TheWeek, TheQuarter, TheYear INTO [dbo].[DimDate]  FROM src
  ORDER BY TheDate
  OPTION (MAXRECURSION 0);

 --tao bang fact
 DROP TABLE FactOrder
 CREATE TABLE FactOrder
 (RecordKey BIGINT NOT NULL IDENTITY(1,1) PRIMARY KEY,
 OrderKey BIGINT NOT NULL,
 OrderDate DATE NOT NULL,
 OrderDateKey varchar(12) NOT NULL,
 OrderProductQuantity INT NOT NULL,
 OrderStatus nvarchar(50) NOT NULL,
 ShipDate DATE NOT NULL,
 ShipDateKey nvarchar(12) NOT NULL,
 ProductKey INT NULL,
 ProductPrice DECIMAL(6,2) NULL,
 ProductDiscountRate DECIMAL(6,5) NULL,
 TotalProductDiscount DECIMAL(6,2) NULL,
 SalesAmount DECIMAL(6,2) NULL,
 Profit DECIMAL(6,2) NULL,
 ProfitRate DECIMAL(6,5) NULL,
 CustomerKey nvarchar(50) NOT NULL,
 DepartmentKey nvarchar(50) NOT NULL)


 INSERT INTO FactOrder --(OrderKey,OrderDate, OrderDateKey, OrderProductQuantity, ShipDate, ShipDateKey, ProductKey, ProductPrice,ProductDiscountRate, TotalProductDiscount,SalesAmount,Profit,ProfitRate, CustomerKey)
 SELECT DISTINCT [Order Id], CONVERT(nvarchar(50), [order date (DateOrders)],23), CONVERT(varchar(12),[order date (DateOrders)],112), [Order Item Quantity], [Order Status], CONVERT(nvarchar(50), [shipping date (DateOrders)],23) , CONVERT(varchar(12),[shipping date (DateOrders)],112), [Product Card Id], [Product Price], [Order Item Discount Rate], [Order Item Discount], Sales, [Benefit per order], [Order Item Profit Ratio], [Customer Id], [Department Id] FROM [dbo].[DataCoSupplyChainDataset]

 

 --phan tich
SELECT distinct A.OrderKey,OrderStatus, ScheduledShippingDays, RealShippingDays , DATEDIFF(DAY,ScheduledShippingDays, RealShippingDays) AS Variance_shippingleadtime, ShipMode, DeliveryStatus, Type FROM [dbo].[FactOrder] A 
INNER JOIN [dbo].[DimDelivery] B ON A.OrderKey=B.OrderKey 
INNER JOIN [dbo].[DimCustomer] C ON A.CustomerKey=C.CustomerKey
WHERE RealShippingDays>ScheduledShippingDays

SELECT A.OrderKey,ScheduledShippingDays, RealShippingDays , DATEDIFF(DAY,ScheduledShippingDays, RealShippingDays) AS Variance_shippingleadtime, ShipMode, DeliveryStatus, Type FROM [dbo].[FactOrder] A 
INNER JOIN [dbo].[DimDelivery] B ON A.OrderKey=B.OrderKey 
INNER JOIN [dbo].[DimCustomer] C ON A.CustomerKey=C.CustomerKey
WHERE RealShippingDays>ScheduledShippingDays

SELECT DISTINCT DeliveryStatus FROM [dbo].[FactOrder] A 
INNER JOIN [dbo].[DimDelivery] B ON A.OrderKey=B.OrderKey 

--tinh ti le late delivery theo shipping mode: FirstClass, SecondClass,.... trong tung thang để đánh giá chế độ nào đang có tỉ lệ giao hàng muộn cao nhất
--1. tính số đơn hàng được ship theo từng tháng theo các chế độ giao hàng khác nhau
DROP TABLE IF EXISTS #table1
SELECT * INTO #table1 FROM(
SELECT COUNT(DISTINCT(A.ORDERKEY)) CountOfOrderKey, MonthKey, ShipMode FROM [dbo].[FactOrder] A
INNER JOIN [dbo].[DimDate] B ON A.ShipDateKey=B.DateKey
INNER JOIN [dbo].[DimDelivery] C ON A.OrderKey=C.OrderKey
GROUP BY MonthKey, ShipMode) A

--2. tính số đơn hàng bị ship muộn theo từng tháng của các chế độ giao hàng khác nhau
DROP TABLE IF EXISTS #table2
SELECT * INTO #table2 FROM 
(SELECT COUNT(DISTINCT(A.ORDERKEY)) AS LateCount, MonthKey, ShipMode FROM [dbo].[FactOrder] A
INNER JOIN [dbo].[DimDate] B ON A.ShipDateKey=B.DateKey
INNER JOIN [dbo].[DimDelivery] C ON A.OrderKey=C.OrderKey
WHERE DeliveryStatus = 'lATE DELIVERY'
GROUP BY MonthKey, ShipMode) B

--3. join 2 bảng tạm với nhau, tính % và sắp xếp các chế độ giao hàng theo thứ tự có % đơn hàng giao muộn nhiều trong từng tháng
DROP TABLE IF EXISTS #table3
SELECT * INTO #table3 FROM (
SELECT A.MonthKey, A.ShipMode, CountOfOrderKey, LateCount, LateCount* 100.0/CountOfOrderKey  AS LateRate, 
ROW_NUMBER() OVER (PARTITION BY A.MonthKey ORDER BY LateCount* 100.0/CountOfOrderKey DESC) AS OrderOfLateRate FROM #table1 A
INNER JOIN #table2 B ON A.MonthKey=B.MonthKey AND A.ShipMode=B.ShipMode
GROUP BY a.MonthKey, a.ShipMode, CountOfOrderKey, LateCount) A

-- tính % đơn hàng được chọn theo từng shipmode
--tính số order mỗi tháng
DROP TABLE IF EXISTS #TABLE4
SELECT * INTO #TABLE4 FROM (
SELECT COUNT(DISTINCT(a.ORDERKEY)) MonthOrderCount, MONTHKEY FROM [dbo].[FactOrder] A
INNER JOIN [dbo].[DimDate] B ON A.ShipDateKey=B.DateKey
GROUP BY MonthKey) A

--tính tỉ lệ đơn hàng mỗi shipmode đảm nhiệm hàng tháng, hiện tỉ lệ late của từng shipmode theo bảng #table2 
--lấy số lượng đơn hàng tính của từng shipmode ở bảng #table1 chia cho tổng số đơn hàng hàng tháng của tất cả các shipmode ở bảng #TABLE4
SELECT A.MonthKey, ShipMode, CountOfOrderKey, CountOfOrderKey*100.0/MonthOrderCount ShipmodeRate, LateCount, LateRate FROM #table3 A 
INNER JOIN #table4 B ON A.MonthKey =B.MonthKey 
ORDER BY MONTHKEY ASC, CountOfOrderKey*100.0/MonthOrderCount DESC, LateRate DESC

--innerjoin with DimOrder to find out the region with highest late ship rate

--tính số đơn hàng mỗi Region giao hàng tháng theo từng shipmode
DROP TABLE IF EXISTS #TMP1
SELECT * INTO #TMP1 FROM 
(SELECT MonthKey,[OrderRegion] ,[ShipMode], COUNT(DISTINCT(A.ORDERKEY)) RegionCountOfOrder FROM [dbo].[FactOrder] A
INNER JOIN [dbo].[DimOrder] B ON A.ORDERKEY=B.ORDERKEY
INNER JOIN [dbo].[DimDate] C ON A.SHIPDATEKEY=C.DATEKEY
INNER JOIN [dbo].[DimDelivery] D ON A.ORDERKEY=D.ORDERKEY
GROUP BY MonthKey, [OrderRegion], [ShipMode]) A
SELECT * FROM #TMP1
ORDER BY MonthKey, [OrderRegion]
--tính số đơn hàng mỗi Region giao hàng tháng
DROP TABLE IF EXISTS #TMP3
SELECT * INTO #TMP3 FROM 
(SELECT MonthKey,[OrderRegion] , COUNT(DISTINCT(A.ORDERKEY)) TotalRegionCountOfOrder FROM [dbo].[FactOrder] A
INNER JOIN [dbo].[DimOrder] B ON A.ORDERKEY=B.ORDERKEY
INNER JOIN [dbo].[DimDate] C ON A.SHIPDATEKEY=C.DATEKEY
GROUP BY MonthKey, [OrderRegion]) A

--Tính số đơn hàng giao muộn tại mỗi Region
DROP TABLE IF EXISTS #TMP2
SELECT * INTO #TMP2 FROM 
(SELECT MonthKey,[OrderRegion] ,[ShipMode], COUNT(DISTINCT(A.ORDERKEY)) RegionLateCountOfOrder FROM [dbo].[FactOrder] A
INNER JOIN [dbo].[DimOrder] B ON A.ORDERKEY=B.ORDERKEY
INNER JOIN [dbo].[DimDate] C ON A.SHIPDATEKEY=C.DATEKEY
INNER JOIN [dbo].[DimDelivery] D ON A.ORDERKEY=D.ORDERKEY
WHERE DeliveryStatus ='late delivery'
GROUP BY MonthKey, [OrderRegion], [ShipMode]) A

--tính rate đơn hàng giao muộn tại mỗi Region, tính rate đơn hàng tại mỗi Region
SELECT A.MonthKey, A.[OrderRegion], A.[ShipMode], RegionCountOfOrder, RegionCountOfOrder*100.0/CountOfOrderKey RegionCountRate,RegionLateCountOfOrder, RegionLateCountOfOrder*100.0/RegionCountOfOrder RegionLateCountRate  FROM #TMP2 A 
INNER JOIN #TMP1 B ON A.MonthKey=B.MonthKey AND A.[OrderRegion]=B.[OrderRegion] AND A.[ShipMode]=B.[ShipMode]
INNER JOIN #table1 C ON A.MonthKey=C.MonthKey AND A.[ShipMode]=C.[ShipMode]
INNER JOIN #TMP3 D ON A.MonthKey=D.MonthKey AND A.[OrderRegion]=D.[OrderRegion]
ORDER BY RegionCountOfOrder*100.0/CountOfOrderKey DESC, RegionLateCountOfOrder*100.0/RegionCountOfOrder DESC, a.shipmode ASC

--THEO NĂM
--tinh ti le late delivery theo shipping mode: FirstClass, SecondClass,.... trong tung thang để đánh giá chế độ nào đang có tỉ lệ giao hàng muộn cao nhất
--1. tính số đơn hàng được ship theo từng tháng theo các chế độ giao hàng khác nhau
DROP TABLE IF EXISTS #table1
SELECT * INTO #table1 FROM(
SELECT COUNT(DISTINCT(A.ORDERKEY)) CountOfOrderKey, TheYear, ShipMode FROM [dbo].[FactOrder] A
INNER JOIN [dbo].[DimDate] B ON A.ShipDateKey=B.DateKey
INNER JOIN [dbo].[DimDelivery] C ON A.OrderKey=C.OrderKey
GROUP BY TheYear, ShipMode) A

--2. tính số đơn hàng bị ship muộn theo từng tháng của các chế độ giao hàng khác nhau
DROP TABLE IF EXISTS #table2
SELECT * INTO #table2 FROM 
(SELECT COUNT(DISTINCT(A.ORDERKEY)) AS LateCount, TheYear, ShipMode FROM [dbo].[FactOrder] A
INNER JOIN [dbo].[DimDate] B ON A.ShipDateKey=B.DateKey
INNER JOIN [dbo].[DimDelivery] C ON A.OrderKey=C.OrderKey
WHERE DeliveryStatus = 'lATE DELIVERY'
GROUP BY TheYear, ShipMode) B

--3. join 2 bảng tạm với nhau, tính % và sắp xếp các chế độ giao hàng theo thứ tự có % đơn hàng giao muộn nhiều trong từng tháng
DROP TABLE IF EXISTS #table3
SELECT * INTO #table3 FROM (
SELECT A.TheYear, A.ShipMode, CountOfOrderKey, LateCount, LateCount* 100.0/CountOfOrderKey  AS LateRate, 
ROW_NUMBER() OVER (PARTITION BY A.TheYear ORDER BY LateCount* 100.0/CountOfOrderKey DESC) AS OrderOfLateRate FROM #table1 A
INNER JOIN #table2 B ON A.TheYear=B.TheYear AND A.ShipMode=B.ShipMode
GROUP BY a.TheYear, a.ShipMode, CountOfOrderKey, LateCount) A

-- tính % đơn hàng được chọn theo từng shipmode
--tính số order mỗi tháng
DROP TABLE IF EXISTS #TABLE4
SELECT * INTO #TABLE4 FROM (
SELECT COUNT(DISTINCT(a.ORDERKEY)) YearOrderCount, TheYear FROM [dbo].[FactOrder] A
INNER JOIN [dbo].[DimDate] B ON A.ShipDateKey=B.DateKey
GROUP BY TheYear) A

--tính tỉ lệ đơn hàng mỗi shipmode đảm nhiệm hàng tháng, hiện tỉ lệ late của từng shipmode theo bảng #table2 
--lấy số lượng đơn hàng tính của từng shipmode ở bảng #table1 chia cho tổng số đơn hàng hàng tháng của tất cả các shipmode ở bảng #TABLE4
SELECT A.TheYear, ShipMode, CountOfOrderKey, CountOfOrderKey*100.0/YearOrderCount ShipmodeRate, LateCount, LateRate FROM #table3 A 
INNER JOIN #table4 B ON A.TheYear =B.TheYear 
ORDER BY TheYear ASC, CountOfOrderKey*100.0/YearOrderCount DESC, LateRate DESC



--tính số đơn hàng mỗi Region giao theo từng shipmode
DROP TABLE IF EXISTS #TMP1
SELECT * INTO #TMP1 FROM 
(SELECT [OrderRegion] ,[ShipMode], COUNT(DISTINCT(A.ORDERKEY)) RegionCountOfOrder FROM [dbo].[FactOrder] A
INNER JOIN [dbo].[DimOrder] B ON A.ORDERKEY=B.ORDERKEY
INNER JOIN [dbo].[DimDelivery] D ON A.ORDERKEY=D.ORDERKEY
WHERE [ShipMode] IN ('Standard class', 'second class')
GROUP BY  [OrderRegion], [ShipMode]
--ORDER BY COUNT(DISTINCT(A.ORDERKEY)) DESC
) A

--tính số đơn hàng mỗi Region giao hàng tháng
DROP TABLE IF EXISTS #TMP3
SELECT * INTO #TMP3 FROM 
(SELECT [OrderRegion] , COUNT(DISTINCT(A.ORDERKEY)) TotalRegionCountOfOrder FROM [dbo].[FactOrder] A
INNER JOIN [dbo].[DimOrder] B ON A.ORDERKEY=B.ORDERKEY
GROUP BY  [OrderRegion]) A


--Tính số đơn hàng giao muộn tại mỗi Region
DROP TABLE IF EXISTS #TMP2
SELECT * INTO #TMP2 FROM 
(SELECT [OrderRegion] ,[ShipMode], COUNT(DISTINCT(A.ORDERKEY)) RegionLateCountOfOrder FROM [dbo].[FactOrder] A
INNER JOIN [dbo].[DimOrder] B ON A.ORDERKEY=B.ORDERKEY
INNER JOIN [dbo].[DimDelivery] D ON A.ORDERKEY=D.ORDERKEY
WHERE DeliveryStatus ='late delivery' AND [ShipMode] IN ('Standard class', 'second class')
GROUP BY [OrderRegion], [ShipMode]) A

--tính rate đơn hàng giao muộn tại mỗi Region, tính rate đơn hàng tại mỗi Region
SELECT A.[OrderRegion], A.[ShipMode], RegionCountOfOrder,TotalRegionCountOfOrder, RegionCountOfOrder*100.0/TotalRegionCountOfOrder RegionCountRate,RegionLateCountOfOrder, RegionLateCountOfOrder*100.0/RegionCountOfOrder RegionLateCountRate  FROM #TMP2 A 
INNER JOIN #TMP1 B ON  A.[OrderRegion]=B.[OrderRegion] AND A.[ShipMode]=B.[ShipMode]
INNER JOIN #TMP3 D ON  A.[OrderRegion]=D.[OrderRegion]
ORDER BY A.[ShipMode] DESC, RegionCountOfOrder DESC,RegionCountOfOrder*100.0/TotalRegionCountOfOrder DESC, RegionLateCountOfOrder*100.0/RegionCountOfOrder DESC
