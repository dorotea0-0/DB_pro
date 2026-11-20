-- Единицы измерения
CREATE SEQUENCE seq_dim_ranges;
CREATE TABLE dim_ranges (
    id bigint PRIMARY KEY DEFAULT nextval('public.seq_dim_ranges'),
    external_id bigint,
    name text,
    factor float,
    date_add timestamp default now()
);

-- Категории
CREATE SEQUENCE seq_dim_categories;
CREATE TABLE dim_categories (
    id bigint PRIMARY KEY DEFAULT nextval('public.seq_dim_categories'),
    external_id bigint,
    name text,
    parent_id bigint,
    date_add timestamp default now()
);

-- Поставщики
CREATE SEQUENCE seq_dim_vendors;
CREATE TABLE dim_vendors (
    id bigint PRIMARY KEY DEFAULT nextval('public.seq_dim_vendors'),
    external_id bigint,
    name text,
    parent_id bigint,
    parent_name text,
    date_add timestamp default now()
);

-- Товары
CREATE SEQUENCE seq_dim_products;
CREATE TABLE dim_products (
    id bigint PRIMARY KEY DEFAULT nextval('public.seq_dim_products'),
    external_id bigint,
    name text,
    category_id bigint,
    vendor_id bigint,
    date_add timestamp default now()
);

-- Сотрудники
CREATE SEQUENCE seq_dim_personnel;
CREATE TABLE dim_personnel (
    id bigint PRIMARY KEY DEFAULT nextval('public.seq_dim_personnel'),
    external_id bigint,
    last_name text,
    first_name text,
    middle_name text,
    role INT,
    is_technical boolean DEFAULT FALSE,
    date_add timestamp default now()
);

-- Склады
CREATE SEQUENCE seq_dim_storages;
CREATE TABLE dim_storages (
    id bigint PRIMARY KEY DEFAULT nextval('public.seq_dim_storages'),
    external_id bigint,
    name text,
    date_add timestamp default now()
);

-- Типы операций
CREATE SEQUENCE seq_dim_operation_types;
CREATE TABLE dim_operation_types (
    id bigint PRIMARY KEY DEFAULT nextval('public.seq_dim_operation_types'),
    external_id bigint,
    name text,
    factor INT,
    date_add timestamp default now()
);

-- Факт: закупки
CREATE SEQUENCE seq_fact_purchases;
CREATE TABLE fact_purchases (
    id bigint PRIMARY KEY DEFAULT nextval('public.seq_fact_purchases'),
    time_id INT,
    product_id bigint,
    vendor_id bigint,
    storage_id bigint,
    operation_id bigint,
    quantity NUMERIC(18,4),
    amount NUMERIC(18,2),
    taxed_amount NUMERIC(18,2),
    price NUMERIC(18,2),
    price_cost NUMERIC(18,2),
    rows_count INT,
    date_add timestamp default now()
);

-- Факт: продажи
CREATE SEQUENCE seq_fact_sales;
CREATE TABLE fact_sales (
    id bigint PRIMARY KEY DEFAULT nextval('public.seq_fact_sales'),
    time_id INT,
    product_id bigint,
    storage_id bigint,
    quantity NUMERIC(18,4),
    amount NUMERIC(18,2),
    cost NUMERIC(18,2),
    discount NUMERIC(18,2),
    checks_count INT,
    date_add timestamp default now()
);

-- Факт: активность персонала
CREATE SEQUENCE seq_fact_personnel;
CREATE TABLE fact_personnel_activity (
    id bigint PRIMARY KEY DEFAULT nextval('public.seq_fact_personnel'),
    time_id INT,
    person_id bigint,
    logins INT,
    shift_days INT,
    checks INT,
    revenue NUMERIC(18,2),
    date_add timestamp default now()
);

-- Факт: остатки
CREATE SEQUENCE seq_fact_stock;
CREATE TABLE fact_stock_balance (
    id bigint PRIMARY KEY DEFAULT nextval('public.seq_fact_stock'),
    time_id INT,
    product_id bigint,
    storage_id bigint,
    balance NUMERIC(18,4),
    date_add timestamp default now()
);