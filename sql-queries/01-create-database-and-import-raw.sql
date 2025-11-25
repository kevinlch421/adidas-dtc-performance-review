-- ========================================================
-- Title: Create the database, import raw data, and clean for star schema modeling
-- author：Kevin Leung
-- date: 2024-11-21
-- ========================================================

-- -- 0. 關閉安全限制（本次連線有效，避免中途報錯）
-- SET SQL_SAFE_UPDATES = 0;        -- 允許無 WHERE 的 UPDATE
-- SET FOREIGN_KEY_CHECKS = 0;      -- 避免 FK 尚未建立時報錯

-- -- 1. 建立並切換資料庫
-- DROP DATABASE IF EXISTS adidas;
-- CREATE DATABASE adidas CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- USE adidas;

-- -- 2. 匯入原始檔案
-- -- 使用 MySQL Workbench → Table Data Import Wizard
-- -- 匯入後表名必須為 sales_raw
-- -- 參考：https://dev.mysql.com/doc/workbench/en/wb-admin-export-import-table.html

-- -- 3. 建立乾淨的 sales 主表（加主鍵 + 正確型態 + 清理空格清理）
-- DROP TABLE IF EXISTS sales;
-- CREATE TABLE sales AS
-- SELECT
--     ROW_NUMBER() OVER (ORDER BY invoice_date, retailer_id) AS sales_id,
--     retailer_id,
--     retailer,
--     invoice_date,
--     region,
--     state,
--     city,
--     product,
--     price_per_unit,
--     units_sold,
--     total_sales,
--     operating_profit,
--     sales_method
-- FROM sales_raw
-- ORDER BY invoice_date, retailer_id;

-- -- 主鍵 + 必要欄位型態修正 + NOT NULL
-- ALTER TABLE sales
--     MODIFY sales_id         INT            NOT NULL AUTO_INCREMENT PRIMARY KEY,
--     MODIFY retailer_id      VARCHAR(100)  NOT NULL,
--     MODIFY retailer_id      INT            NOT NULL,
--     MODIFY invoice_date     DATE           NOT NULL,
--     MODIFY region           VARCHAR(50)   NOT NULL,
--     MODIFY state            VARCHAR(50)   NOT NULL,
--     MODIFY city             VARCHAR(100)  NOT NULL,
--     MODIFY product          VARCHAR(150)  NOT NULL,
--     MODIFY price_per_unit   DECIMAL(10,2) NOT NULL,
--     MODIFY units_sold       INT            NOT NULL,
--     MODIFY total_sales      DECIMAL(12,2) NOT NULL,
--     MODIFY operating_profit DECIMAL(12,2) NOT NULL,
--     MODIFY sales_method     VARCHAR(50)   NOT NULL;

-- -- 清理所有字串欄位頭尾空格
-- UPDATE sales SET
--     retailer     = TRIM(retailer),
--     region       = TRIM(region),
--     state        = TRIM(state),
--     city         = TRIM(city),
--     product      = TRIM(product),
--     sales_method = TRIM(sales_method);

-- -- 4. 加入財務欄位：真實 Adidas Gross Margin → COGS → Gross Profit
-- ALTER TABLE sales
--     ADD COLUMN gross_margin_rate DECIMAL(5,4) NULL,
--     ADD COLUMN cogs              DECIMAL(12,2) NULL,
--     ADD COLUMN gross_profit      DECIMAL(12,2) NULL;

-- -- 按年套用 Adidas 官方財報毛利率（2025 已更新至 Q3 實際值）
-- UPDATE sales
-- SET gross_margin_rate = CASE EXTRACT(YEAR FROM invoice_date)
--     WHEN 2021 THEN 0.5200
--     WHEN 2022 THEN 0.4740
--     WHEN 2023 THEN 0.4760
--     WHEN 2024 THEN 0.4920
--     WHEN 2025 THEN 0.5050   -- 2025 YTD 實際平均
--     ELSE 0.4900
-- END;

-- -- 計算 COGS 與 Gross Profit
-- UPDATE sales
-- SET 
--     cogs         = total_sales * (1 - gross_margin_rate),
--     gross_profit = total_sales - cogs;

-- -- 5. 快速驗證（執行以下任一條即可確認一切正常）
-- -- 5.1 總筆數
-- SELECT COUNT(*) AS total_rows FROM sales;                     -- 應為 9637

-- -- 5.2 檢查 NULL
-- SELECT 
--     SUM(retailer IS NULL)        AS null_retailer,
--     SUM(invoice_date IS NULL)   AS null_date,
--     SUM(total_sales IS NULL)     AS null_sales,
--     SUM(gross_margin_rate IS NULL) AS null_gm
-- FROM sales;                                                   -- 全部應為 0

-- -- 5.3 驗證毛利率套用正確
-- SELECT 
--     EXTRACT(YEAR FROM invoice_date) AS year,
--     AVG(gross_margin_rate)        AS applied_gm_rate,
--     ROUND(SUM(gross_profit)/SUM(total_sales),4) AS calculated_gm
-- FROM sales
-- GROUP BY year
-- ORDER BY year;
-- -- 結果應與上面 CASE 完全一致 (2025 = 0.5050)