USE [Front];
GO

-- Единицы измерения 
SELECT 'INSERT INTO dim_ranges(external_id, group_id, short_name, description) VALUES ('
    + CAST(ID AS VARCHAR(MAX)) + ','
    + CAST(COALESCE(GroupID, 0) AS VARCHAR(MAX)) + ','''
    + REPLACE(COALESCE(ShortName, ''), '''', '''''') + ''','''
    + REPLACE(COALESCE(Description, ''), '''', '''''') + ''');' AS sql
FROM [dbo].[bm_classifierSizes];

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