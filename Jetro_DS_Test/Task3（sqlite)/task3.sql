---Q1- Create table 
--1. create the table BranchLocation
CREATE TABLE IF NOT EXISTS BranchLocation(
    Branch TEXT PRIMARY KEY ,
    LocationName TEXT NOT NULL,
	RegionName TEXT NOT NULL,
	ZIP INTEGER NOT NULL
);
INSERT INTO BranchLocation (Branch, LocationName, RegionName, ZIP)
SELECT DISTINCT Branch, LocationName, RegionName, ZIP FROM SQL_SAMPLE;

--2. creat the table product
CREATE TABLE IF NOT EXISTS Product(
    UPC TEXT PRIMARY KEY ,
	PrimaryUPC  TEXT NOT NULL,
	Item TEXT NOT NULL,
    GroupName TEXT NOT NULL,
	DepartmentName TEXT NOT NULL
);
INSERT INTO Product(UPC,PrimaryUPC,Item,GroupName,DepartmentName)
SELECT DISTINCT UPC,PrimaryUPC,Item,GroupName,DepartmentName FROM SQL_SAMPLE;

-- 3. creat the vendor information table 
CREATE TABLE IF NOT EXISTS Vendor(
    VendorCode TEXT PRIMARY KEY,
    Description TEXT NOT NULL
);

INSERT INTO Vendor(VendorCode, Description)
SELECT DISTINCT VendorCode, Description FROM SQL_SAMPLE;


-- 4. create the sales table 
CREATE TABLE IF NOT EXISTS Sales(
	Branch INTEGER NOT NULL,
	UPC TEXT NOT NULL,
	VendorCode TEXT NOT　NULL,
	YearlySales REAL NOT NULL,
	YearlyCost REAL NOT NULL,
	YearlyQuantitySold INTEGER NOT NULL,
	BuyerCode TEXT NOT NULL,
	DailyStocklevel INTEGER NOT NULL,
	DailyDate TEXT NOT NULL,
	FOREIGN KEY (Branch) REFERENCES BranchLocation(Branch),
    FOREIGN KEY (UPC) REFERENCES Product(UPC),
    FOREIGN KEY (VendorCode) REFERENCES Vendor(VendorCode)
);
INSERT INTO Sales(Branch,UPC,VendorCode,YearlySales,YearlyCost,YearlyQuantitySold,BuyerCode,DailyStocklevel,DailyDate)
SELECT Branch,UPC,VendorCode,YearlySales,YearlyCost,YearlyQuantitySold,BuyerCode,DailyStocklevel,DailyDate FROM SQL_SAMPLE;

--Q2 create index:
-- add a index for sales table
-- since BranchLocation, Product and Vendor all have PRIMARY key which will automatically have a implict index created. 
CREATE INDEX "index" ON "Sales" (
	"UPC",
	"Branch",
	"VendorCode",
	"BuyerCode"
);


--Q3: query:
--What are the top 3 selling products by Branch and Item #?
SELECT Sales.UPC, Branch, Item, SUM(YearlySales) as TotalSales
FROM Sales Left join Product ON Sales.UPC = Product.UPC
GROUP BY Branch, Item
ORDER BY TotalSales DESC
LIMIT 3;

--Calculate the 3-day moving average of DailyStocklevel by Branch and UPC

SELECT Branch, UPC, DailyDate,AVG(DailyStocklevel) OVER (PARTITION BY Branch, UPC ORDER BY DailyDate ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as MovingAverage
FROM Sales;

-- What is the lowest selling item for each group?
WITH MinSales AS (
    SELECT p.GroupName, MIN(s.YearlyQuantitySold) AS MinSold
    FROM Product p
    JOIN Sales s ON p.UPC = s.UPC
    GROUP BY p.GroupName
)
SELECT distinct p.GroupName,p.UPC, p.Item, s.YearlyQuantitySold
FROM Product p
JOIN Sales s ON p.UPC = s.UPC
JOIN MinSales ms ON p.GroupName = ms.GroupName AND s.YearlyQuantitySold = ms.MinSold
ORDER BY p.UPC;


--What is the best selling item for each branch by department?
WITH MaxSales AS (
    SELECT s.Branch, p.DepartmentName, MAX(s.YearlyQuantitySold) AS MaxSold
    FROM Sales s
    JOIN Product p ON s.UPC = p.UPC
    GROUP BY s.Branch, p.DepartmentName
)
SELECT distinct s.Branch, p.DepartmentName,p.UPC, p.Item, s.YearlyQuantitySold
FROM Sales s
JOIN Product p ON s.UPC = p.UPC
JOIN MaxSales ms ON s.Branch = ms.Branch AND p.DepartmentName = ms.DepartmentName AND s.YearlyQuantitySold = ms.MaxSold
ORDER BY s.Branch, p.DepartmentName;


--Q4: Other insight 
-- To discuss other insight, I fould it would be useful to analyze the consumer and business insight .
-- 1. The comsumer insight , for example, what are the top 3 buyers code based on sales and what is the top 3 items do they buy,
--Knowing about which buyers contribute the most to our revenue , the marketing team should maintain a good connection with them.
-- Knowing about which products they love the most, we can modify our supply strategy. 
	WITH RankedItems AS (
		SELECT 
			s.BuyerCode,
			s.UPC,
			p.Item,
			SUM(s.YearlySales) AS ItemSales,
			ROW_NUMBER() OVER(PARTITION BY s.BuyerCode ORDER BY SUM(s.YearlySales) DESC) AS item_rank
		FROM Sales s
		JOIN Product p ON s.UPC = p.UPC
		GROUP BY s.BuyerCode, p.Item
	)
	
	SELECT BuyerCode,UPC,Item,ItemSales FROM RankedItems WHERE item_rank <= 3 ORDER BY BuyerCode, item_rank;

-- 2. The supply-businees insight: Top 5 Vendors Based on Sales
-- Understanding which vendors' products are selling the best can be crucial for partnership and procurement strategies.
	SELECT v.Description, SUM(s.YearlySales) AS VendorTotalSales
	FROM Sales s
	JOIN Vendor v ON s.VendorCode = v.VendorCode
	GROUP BY v.VendorCode
	ORDER BY VendorTotalSales DESC
	LIMIT 5;

-- 	3. it would also be useful to know what are the top 5 items that provide the most profit margin. 
-- 	Understanding profitability can guide pricing and discounting strategies.
	SELECT p.Item,P.UPC, (SUM(s.YearlySales) - SUM(s.YearlyCost)) / SUM(s.YearlyQuantitySold) AS ProfitPerUnit
	FROM Sales s
	JOIN Product p ON s.UPC = p.UPC
	GROUP BY p.Item
	ORDER BY ProfitPerUnit DESC
	LIMIT 5;
	
-- 	4. From the inventory perspective, it would be useful to know what items are the lowest in stock aross all branch,
-- 	This can help with inventory management and ensuring that popular products are not out of stock.
	SELECT p.Item,p.UPC, SUM(s.DailyStocklevel) AS TotalStock
	FROM Sales s
	JOIN Product p ON s.UPC = p.UPC
	GROUP BY p.Item
	ORDER BY TotalStock ASC
	LIMIT 5;











