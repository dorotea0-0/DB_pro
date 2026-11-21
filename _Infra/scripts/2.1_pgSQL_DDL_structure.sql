DO $$
BEGIN

-- Единицы измерения
CREATE SEQUENCE IF NOT EXISTS seq_dim_ranges;

CREATE TABLE IF NOT EXISTS dim_ranges (
    id bigint PRIMARY KEY DEFAULT nextval('public.seq_dim_ranges'),
    external_id bigint,
    group_id bigint,
    short_name text,
    description text,
    date_add timestamp default now()
);

COMMENT ON TABLE dim_ranges IS 'Единицы измерения из bm_classifierSizes';
COMMENT ON COLUMN dim_ranges.id IS 'Внутренний ключ';
COMMENT ON COLUMN dim_ranges.external_id IS 'ID из bm_classifierSizes';
COMMENT ON COLUMN dim_ranges.group_id IS 'GroupID из bm_classifierSizes';
COMMENT ON COLUMN dim_ranges.short_name IS 'ShortName из bm_classifierSizes';
COMMENT ON COLUMN dim_ranges.description IS 'Description из bm_classifierSizes';
COMMENT ON COLUMN dim_ranges.date_add IS 'Дата добавления записи';

-- Категории товаров
CREATE SEQUENCE IF NOT EXISTS seq_dim_categories;

CREATE TABLE IF NOT EXISTS dim_categories (
    id bigint PRIMARY KEY DEFAULT nextval('public.seq_dim_categories'),
    external_id bigint,
    name text,
    parent_id bigint,
    date_add timestamp default now()
);

COMMENT ON TABLE dim_categories IS 'Категории товаров из category';
COMMENT ON COLUMN dim_categories.id IS 'Внутренний ключ';
COMMENT ON COLUMN dim_categories.external_id IS 'ID из category';
COMMENT ON COLUMN dim_categories.name IS 'Название категории (description)';
COMMENT ON COLUMN dim_categories.parent_id IS 'ID родительской категории (ParentID)';
COMMENT ON COLUMN dim_categories.date_add IS 'Дата добавления записи';

-- Поставщики
CREATE SEQUENCE IF NOT EXISTS seq_dim_vendors;

CREATE TABLE IF NOT EXISTS dim_vendors (
    id bigint PRIMARY KEY DEFAULT nextval('public.seq_dim_vendors'),
    external_id bigint,
    name text,
    parent_id bigint,
    parent_name text,
    date_add timestamp default now()
);

COMMENT ON TABLE dim_vendors IS 'Поставщики из vendors с группой из vendorgroup';
COMMENT ON COLUMN dim_vendors.id IS 'Внутренний ключ';
COMMENT ON COLUMN dim_vendors.external_id IS 'ID из vendors';
COMMENT ON COLUMN dim_vendors.name IS 'Краткое наименование (clientid)';
COMMENT ON COLUMN dim_vendors.parent_id IS 'ID группы поставщика (clientgroup)';
COMMENT ON COLUMN dim_vendors.parent_name IS 'Название группы (vendorgroup.description)';
COMMENT ON COLUMN dim_vendors.date_add IS 'Дата добавления записи';

-- Товары
CREATE SEQUENCE IF NOT EXISTS seq_dim_products;

CREATE TABLE IF NOT EXISTS dim_products (
    id bigint PRIMARY KEY DEFAULT nextval('public.seq_dim_products'),
    external_id bigint,
    name text,
    category_id bigint,
    vendor_id bigint,
    date_add timestamp default now()
);

COMMENT ON TABLE dim_products IS 'Товары из product';
COMMENT ON COLUMN dim_products.id IS 'Внутренний ключ';
COMMENT ON COLUMN dim_products.external_id IS 'ID из product';
COMMENT ON COLUMN dim_products.name IS 'Название товара (description)';
COMMENT ON COLUMN dim_products.category_id IS 'ID категории (subcategoryid)';
COMMENT ON COLUMN dim_products.vendor_id IS 'ID поставщика (vendorid)';
COMMENT ON COLUMN dim_products.date_add IS 'Дата добавления записи';

-- Сотрудники
CREATE SEQUENCE IF NOT EXISTS seq_dim_personnel;

CREATE TABLE IF NOT EXISTS dim_personnel (
    id bigint PRIMARY KEY DEFAULT nextval('public.seq_dim_personnel'),
    external_id bigint,
    last_name text,
    first_name text,
    middle_name text,
    role INT,
    is_technical boolean DEFAULT FALSE,
    date_add timestamp default now()
);

COMMENT ON TABLE dim_personnel IS 'Сотрудники из personnel';
COMMENT ON COLUMN dim_personnel.id IS 'Внутренний ключ';
COMMENT ON COLUMN dim_personnel.external_id IS 'personid из personnel';
COMMENT ON COLUMN dim_personnel.last_name IS 'Фамилия (lastname)';
COMMENT ON COLUMN dim_personnel.first_name IS 'Имя (firstname)';
COMMENT ON COLUMN dim_personnel.middle_name IS 'Отчество (middlename)';
COMMENT ON COLUMN dim_personnel.role IS 'Роль / уровень доступа (securityaccess)';
COMMENT ON COLUMN dim_personnel.is_technical IS 'Признак технической записи (904, 905, 906)';
COMMENT ON COLUMN dim_personnel.date_add IS 'Дата добавления записи';

-- Склады
CREATE SEQUENCE IF NOT EXISTS seq_dim_storages;

CREATE TABLE IF NOT EXISTS dim_storages (
    id bigint PRIMARY KEY DEFAULT nextval('public.seq_dim_storages'),
    external_id bigint,
    name text,
    date_add timestamp default now()
);

COMMENT ON TABLE dim_storages IS 'Склады из storages';
COMMENT ON COLUMN dim_storages.id IS 'Внутренний ключ';
COMMENT ON COLUMN dim_storages.external_id IS 'ID из storages';
COMMENT ON COLUMN dim_storages.name IS 'Название склада (description)';
COMMENT ON COLUMN dim_storages.date_add IS 'Дата добавления записи';

-- Типы складских операций
CREATE SEQUENCE IF NOT EXISTS seq_dim_operation_types;

CREATE TABLE IF NOT EXISTS dim_operation_types (
    id bigint PRIMARY KEY DEFAULT nextval('public.seq_dim_operation_types'),
    external_id bigint,
    name text,
    factor INT,
    date_add timestamp default now()
);

COMMENT ON TABLE dim_operation_types IS 'Типы складских операций из bm_StorageOperationsType';
COMMENT ON COLUMN dim_operation_types.id IS 'Внутренний ключ';
COMMENT ON COLUMN dim_operation_types.external_id IS 'ID из bm_StorageOperationsType';
COMMENT ON COLUMN dim_operation_types.name IS 'Название типа (Description)';
COMMENT ON COLUMN dim_operation_types.factor IS 'Знак движения (Factor)';
COMMENT ON COLUMN dim_operation_types.date_add IS 'Дата добавления записи';

END $$;