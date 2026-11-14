
USE [Front];
GO

-- 1.1 Знаки количества и суммы по типам операций.
-- приход положительный, расход отрицательный.
SELECT OperationID,
       MIN(Count) AS [мин Count], MAX(Count) AS [макс Count],
       MIN(Amount) AS [мин Amount], MAX(Amount) AS [макс Amount]
FROM bm_StorageOperations
GROUP BY OperationID;

-- 1.2 Целостность связи движение - шапка документа.
-- ни одно движение не висит без шапки, дату берем из шапки.
SELECT COUNT(*) AS [всего],
       SUM(CASE WHEN j.ID IS NULL THEN 1 ELSE 0 END) AS [без шапки]
FROM bm_StorageOperations so
LEFT JOIN bm_JournalBarnetDocs j ON j.ID = so.DocumentID;

-- 1.3 Какие типы операций реально есть в данных.
-- закупка это в точности тип 1, инвентаризаций и перемещений нет.
SELECT OperationID, COUNT(*) AS [строк]
FROM bm_StorageOperations
GROUP BY OperationID;

-- 1.4 Закупки по месяцам за 2023 год .
-- шаг месяц работает, суммы и НДС извлекаются.
SELECT CONVERT(char(7), j.Period, 120) AS [месяц],
       COUNT(*) AS [строк],
       SUM(so.Count) AS [количество],
       SUM(so.Amount) AS [сумма],
       SUM(so.TaxedAmount) AS [НДС]
FROM bm_StorageOperations so
JOIN bm_JournalBarnetDocs j ON j.ID = so.DocumentID
WHERE so.OperationID = 1 AND j.Period >= '20230101'
GROUP BY CONVERT(char(7), j.Period, 120)
ORDER BY [месяц];

-- 2.1 Продажи, возвраты и чеки по месяцам за 2023 год.
-- продажи извлекаются по типу 101, чек собирается по receiptn, возвратов в данных нет.
SELECT CONVERT(char(7), dater, 120) AS [месяц],
       SUM(CASE WHEN transtype = 101 THEN amount ELSE 0 END) AS [продажи],
       SUM(CASE WHEN transtype = 102 THEN amount ELSE 0 END) AS [возвраты],
       COUNT(DISTINCT CASE WHEN transtype = 501 THEN receiptn END) AS [чеков]
FROM journal
WHERE transtype IN (101, 102, 501) AND dater >= '20230101'
GROUP BY CONVERT(char(7), dater, 120)
ORDER BY [месяц];

-- 2.2 Топ товаров по выручке за всю историю.
--связь journal.id с product.productid по артикулу работает, топ совпадает с группой A будущего ABC-анализа
SELECT TOP 10 id AS [артикул], description AS [товар],
       SUM(quantity) AS [количество], SUM(amount) AS [сумма]
FROM journal
WHERE transtype = 101
GROUP BY id, description
ORDER BY [сумма] DESC;

-- 3.1 Закупки по поставщикам и месяцам.
-- мост bm_StorageOperations.VendorID настоящий, имена подтягиваются, видна концентрация
SELECT CONVERT(char(7), j.Period, 120) AS [месяц],
       v.clientid AS [поставщик],
       COUNT(*) AS [строк],
       SUM(so.Amount) AS [сумма закупки]
FROM bm_StorageOperations so
JOIN bm_JournalBarnetDocs j ON j.ID = so.DocumentID
JOIN vendors v ON v.id = so.VendorID
WHERE so.OperationID = 1 AND j.Period >= '20230101'
GROUP BY CONVERT(char(7), j.Period, 120), v.clientid
ORDER BY [месяц], [сумма закупки] DESC;

-- 3.2 Где лежит наименование поставщика и заполнен ли ContractID.
-- lastname пустой, наименование в clientid (полное в firstname), ContractID везде 0, связь с договорами структурная
SELECT TOP 10 so.ID, so.VendorID, v.lastname, v.clientid, so.ContractID
FROM bm_StorageOperations so
LEFT JOIN vendors v ON v.id = so.VendorID
WHERE so.VendorID > 0
ORDER BY so.ID DESC;

-- 4.1 Кто реально продает в кассовой ленте.
-- разреза по людям нет, все продажи под технической записью 906.
SELECT loginid, COUNT(*) AS [строк], MIN(dater) AS [с], MAX(dater) AS [по]
FROM journal
WHERE transtype IN (101, 501)
GROUP BY loginid
ORDER BY [строк] DESC;

-- 4.2 Состав лога сессий.
-- лог служебный (администратор 897 и система 0), людей в нем нет.
SELECT PersonID, COUNT(*) AS [событий]
FROM bm_JournalSessions
GROUP BY PersonID
ORDER BY [событий] DESC;

-- 4.3 Заполненность таблиц активности персонала.
-- смены, кассовые операции и рабочие часы анализа не дадут.
SELECT COUNT(*) AS [bm_ShiftsOperations] FROM bm_ShiftsOperations;
SELECT COUNT(*) AS [bm_CashOperations] FROM bm_CashOperations;
SELECT COUNT(*) AS [bm_WorkHours] FROM bm_WorkHours;

-- 4.4 Итоговый разрез по персоналу в доступном виде нагрузки точки по кварталам и полугодиям 
SELECT YEAR(dater) AS [год],
       DATEPART(QUARTER, dater) AS [квартал],
       CASE WHEN MONTH(dater) <= 6 THEN 1 ELSE 2 END AS [полугодие],
       COUNT(DISTINCT CASE WHEN transtype = 501 THEN receiptn END) AS [чеков],
       SUM(CASE WHEN transtype = 101 THEN amount ELSE 0 END) AS [выручка]
FROM journal
WHERE transtype IN (101, 501)
GROUP BY YEAR(dater), DATEPART(QUARTER, dater),
         CASE WHEN MONTH(dater) <= 6 THEN 1 ELSE 2 END
ORDER BY [год], [квартал];

-- 5.1 Есть ли готовые срезы остатков.
-- в таблицах onhand и storagesonhand нет в данных, остаток только вычисляем.
SELECT COUNT(*) AS [onhand] FROM onhand;
SELECT COUNT(*) AS [storagesonhand] FROM storagesonhand;

-- 5.2 Накопительный остаток по товару за всю историю (метод расчета).
--для товаров с закупками остатки положительные и осмысленные.
SELECT TOP 30 so.ProductID, pr.description AS [товар],
       SUM(so.Count) AS [остаток]
FROM bm_StorageOperations so
LEFT JOIN product pr ON pr.id = so.ProductID
GROUP BY so.ProductID, pr.description
ORDER BY [остаток] DESC;

-- 5.3 Недельная динамика остатка на примере полуфабриката 7650.
--ингредиент расходуется под блюда, но не приходуется (операций производства в базе нет), остаток уходит в минус
SELECT YEAR(j.Period) AS [год], DATEPART(ISO_WEEK, j.Period) AS [неделя],
       SUM(so.Count) AS [движение за неделю],
       SUM(SUM(so.Count)) OVER (ORDER BY YEAR(j.Period), DATEPART(ISO_WEEK, j.Period)) AS [остаток]
FROM bm_StorageOperations so
JOIN bm_JournalBarnetDocs j ON j.ID = so.DocumentID
WHERE so.ProductID = 7650
GROUP BY YEAR(j.Period), DATEPART(ISO_WEEK, j.Period)
ORDER BY [год], [неделя];
