USE [Front];
GO

-- Единицы измерения
SELECT 'INSERT INTO dim_ranges(external_id, name, factor) VALUES ('
    + CAST(id AS VARCHAR(MAX)) + ','''
    + [sizeid] + ''','
    + CAST(portionrate AS VARCHAR(MAX)) + ');' AS sql
FROM [size];

-- Категории
SELECT 'INSERT INTO dim_categories(external_id, name, parent_id) VALUES ('
    + CAST(id AS VARCHAR(MAX)) + ','''
    + REPLACE(description, '''', '''''') + ''','
    + CASE WHEN COALESCE(ParentID, 0) = 0 THEN 'NULL'
           ELSE CAST(ParentID AS VARCHAR(MAX)) END
    + ');' AS sql
FROM category;

-- Поставщики
SELECT 'INSERT INTO dim_vendors(external_id, name, parent_id, parent_name) VALUES ('
    + CAST(t1.id AS VARCHAR(MAX)) + ','''
    + REPLACE(t1.clientid, '''', '''''') + ''','
    + CAST(t1.clientgroup AS VARCHAR(MAX)) + ','''
    + REPLACE(t2.description, '''', '''''') + ''');' AS sql
FROM vendors t1
INNER JOIN vendorgroup t2 ON t1.clientgroup = t2.vendorgroupid;

-- Товары
SELECT 'INSERT INTO dim_products(external_id, name, category_id, vendor_id) VALUES ('
    + CAST(p.id AS VARCHAR(MAX)) + ','''
    + REPLACE(p.description, '''', '''''') + ''','
    + CASE WHEN p.subcategoryid IS NULL THEN 'NULL'
           ELSE CAST(p.subcategoryid AS VARCHAR(MAX)) END + ','
    + CASE WHEN p.vendorid IS NULL THEN 'NULL'
           ELSE CAST(p.vendorid AS VARCHAR(MAX)) END
    + ');' AS sql
FROM product p;

-- Сотрудники
SELECT 'INSERT INTO dim_personnel(external_id, last_name, first_name, middle_name, role, is_technical) VALUES ('
    + CAST(personid AS VARCHAR(MAX)) + ','''
    + REPLACE(COALESCE(lastname, ''), '''', '''''') + ''','''
    + REPLACE(COALESCE(firstname, ''), '''', '''''') + ''','''
    + REPLACE(COALESCE(middlename, ''), '''', '''''') + ''','
    + CAST(COALESCE(securityaccess, 0) AS VARCHAR(MAX)) + ','
    + CASE WHEN personid IN (904, 905, 906) THEN 'TRUE' ELSE 'FALSE' END
    + ');' AS sql
FROM personnel;

-- Склады
SELECT 'INSERT INTO dim_storages(external_id, name) VALUES ('
    + CAST(id AS VARCHAR(MAX)) + ','''
    + REPLACE(COALESCE(description, ''), '''', '''''') + ''');' AS sql
FROM storages;

-- Типы операций
SELECT 'INSERT INTO dim_operation_types(external_id, name, factor) VALUES ('
    + CAST(ID AS VARCHAR(MAX)) + ','''
    + REPLACE(Description, '''', '''''') + ''','
    + CAST(Factor AS VARCHAR(MAX)) + ');' AS sql
FROM bm_StorageOperationsType;

-- Факт закупки 
SELECT 'INSERT INTO fact_purchases(time_id, product_id, vendor_id, storage_id, operation_id, quantity, amount, taxed_amount, price, price_cost, rows_count) VALUES ('
    + CAST(CONVERT(INT, CONVERT(VARCHAR(8), j.Period, 112)) AS VARCHAR(MAX)) + ','
    + CAST(so.ProductID AS VARCHAR(MAX)) + ','
    + CAST(so.VendorID AS VARCHAR(MAX)) + ','
    + CAST(so.StorageID AS VARCHAR(MAX)) + ','
    + CAST(so.OperationID AS VARCHAR(MAX)) + ','
    + CAST(SUM(so.Count) AS VARCHAR(MAX)) + ','
    + CAST(SUM(so.Amount) AS VARCHAR(MAX)) + ','
    + CAST(SUM(so.TaxedAmount) AS VARCHAR(MAX)) + ','
    + CAST(AVG(so.Price) AS VARCHAR(MAX)) + ','
    + CAST(AVG(so.PriceCost) AS VARCHAR(MAX)) + ','
    + CAST(COUNT(*) AS VARCHAR(MAX)) + ');' AS sql
FROM bm_StorageOperations so
JOIN bm_JournalBarnetDocs j ON j.ID = so.DocumentID
WHERE so.OperationID = 1
GROUP BY CONVERT(VARCHAR(8), j.Period, 112),
         so.ProductID, so.VendorID, so.StorageID, so.OperationID;

-- Факт продажи 
SELECT 'INSERT INTO fact_sales(time_id, product_id, storage_id, quantity, amount, cost, discount, checks_count) VALUES ('
    + CAST(CONVERT(INT, CONVERT(VARCHAR(8), j.dater, 112)) AS VARCHAR(MAX)) + ','
    + CAST(p.id AS VARCHAR(MAX)) + ','
    + CAST(j.storeid AS VARCHAR(MAX)) + ','
    + CAST(SUM(j.quantity) AS VARCHAR(MAX)) + ','
    + CAST(SUM(j.amount) AS VARCHAR(MAX)) + ','
    + CAST(SUM(j.cost) AS VARCHAR(MAX)) + ','
    + CAST(SUM(j.discountamount) AS VARCHAR(MAX)) + ','
    + '0);' AS sql
FROM journal j
JOIN product p ON p.productid = j.id
WHERE j.transtype = 101
GROUP BY CONVERT(VARCHAR(8), j.dater, 112), p.id, j.storeid;

-- Факт активность персонала 
SELECT 'INSERT INTO fact_personnel_activity(time_id, person_id, logins, shift_days, checks, revenue) VALUES ('
    + CAST(CONVERT(INT, CONVERT(VARCHAR(8), j.dater, 112)) AS VARCHAR(MAX)) + ','
    + CAST(p.personid AS VARCHAR(MAX)) + ','
    + CAST(SUM(CASE WHEN j.transtype = 301 THEN 1 ELSE 0 END) AS VARCHAR(MAX)) + ','
    + CAST(COUNT(DISTINCT CASE WHEN j.transtype = 386 THEN CAST(j.dater AS DATE) END) AS VARCHAR(MAX)) + ','
    + '0,0);' AS sql
FROM journal j
JOIN personnel p ON p.personid = TRY_CAST(j.loginid AS INT)
WHERE j.transtype IN (301, 386, 387)
GROUP BY CONVERT(VARCHAR(8), j.dater, 112), p.personid;

-- Факт остатки 
SELECT 'INSERT INTO fact_stock_balance(time_id, product_id, storage_id, balance) VALUES ('
    + CAST(CONVERT(INT, CONVERT(VARCHAR(8),
          DATEADD(DAY, 1-DATEPART(WEEKDAY, j.Period), j.Period), 112)) AS VARCHAR(MAX)) + ','
    + CAST(so.ProductID AS VARCHAR(MAX)) + ','
    + CAST(so.StorageID AS VARCHAR(MAX)) + ','
    + CAST(SUM(so.Count) AS VARCHAR(MAX)) + ');' AS sql
FROM bm_StorageOperations so
JOIN bm_JournalBarnetDocs j ON j.ID = so.DocumentID
GROUP BY DATEADD(DAY, 1-DATEPART(WEEKDAY, j.Period), j.Period),
         so.ProductID, so.StorageID;