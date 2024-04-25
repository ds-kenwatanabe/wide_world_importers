-- Create fact table
CREATE TABLE SalesFact (
    SalesFactID INT IDENTITY(1,1) PRIMARY KEY,
	OrderID INT,
	OrderLineID INT,
	PurchaseOrderID INT,
	StockItemID INT,
	PersonID INT,
	PersonFullName TEXT,
	IsSalesPerson BIT,
    CustomerID INT,
	CustomerCategoryID INT,
    TotalSales FLOAT,
	OrderDate DATE
    -- Add any other measures as needed
	FOREIGN KEY (OrderID) REFERENCES Sales.Orders(OrderID),
	FOREIGN KEY (OrderlineID) REFERENCES Sales.OrderLines(OrderLineID),
	FOREIGN KEY (PurchaseOrderID) REFERENCES Purchasing.PurchaseOrders(PurchaseOrderID),
    FOREIGN KEY (StockItemID) REFERENCES Warehouse.StockItems(StockItemID),
	FOREIGN KEY (PersonID) REFERENCES Application.People(PersonID),
    FOREIGN KEY (CustomerID) REFERENCES Sales.Customers(CustomerID),
	FOREIGN KEY (CustomerCategoryID) REFERENCES Sales.CustomerCategories(CustomerCategoryID)
);

-- Calculate total sales CTE
WITH TotalSalesCTE AS (
    SELECT
        SO.OrderID,
        SOL.OrderLineID,
        SOL.UnitPrice * SOL.Quantity AS "TotalSales"
    FROM Sales.OrderLines AS SOL
	JOIN Sales.Orders AS SO ON SO.OrderID = SOL.OrderID
)
-- Insert data into the fact table
INSERT INTO SalesFact (OrderID,
	OrderLineID,
	PurchaseOrderID,
    StockItemID,
	PersonID,
	PersonFullName,
	IsSalesPerson,
    CustomerID,
	CustomerCategoryID,
    TotalSales,
	OrderDate)
SELECT 
    SO.OrderID,
	SOL.OrderLineID,
	PO.PurchaseOrderID,
    SI.StockItemID,
	PE.PersonID,
	PE.FullName,
	PE.IsSalesperson,
    CU.CustomerID,
	CCAT.CustomerCategoryID,
    TSCTE.TotalSales,
	SO.OrderDate
FROM Sales.Orders AS SO
JOIN Sales.OrderLines AS SOL ON SOL.OrderID = SO.OrderID
JOIN Purchasing.PurchaseOrders AS PO ON PO.PurchaseOrderID = SO.OrderID
JOIN Warehouse.StockItems AS SI ON SI.StockItemID = SOL.StockItemID
JOIN Application.People AS PE ON PE.PersonID = SO.SalespersonPersonID
JOIN Sales.Customers AS CU ON CU.CustomerID = SO.CustomerID
JOIN Sales.CustomerCategories AS CCAT ON CCAT.CustomerCategoryID = CU.CustomerCategoryID
JOIN TotalSalesCTE AS TSCTE ON TSCTE.OrderID = SOL.OrderID;