-- ========================================================
-- Title: Create Star Schema Data Model for Adidas US Sales Dataset
-- Date：2025-11-21 
-- Author：Kevin Leung
-- 執行前請先執行「data-import-to-mysql」script，確保 sales 表已存在且乾淨
-- ========================================================

-- -- ========================================================
-- -- 6. 建立 Dimension Tables（維度表） – 共 6 張
-- -- ========================================================

-- -- 6a. dim_date – 完整日期維度（2020-01-01 到 2026-12-31，共 2557 天）
-- --     用途：時間序列分析、YoY、QoQ、月度趨勢等
-- DROP TABLE IF EXISTS dim_date;

-- CREATE TABLE dim_date (
--     `date_id`      INT PRIMARY KEY,                     -- 代理鍵，加速 JOIN
--     `date`         DATE NOT NULL UNIQUE,                -- 實際日期
--     `year`         INT NOT NULL,                        -- 2021, 2022...
--     `quarter`      TINYINT NOT NULL,                    -- 1~4
--     `month`        TINYINT NOT NULL,                    -- 1~12
--     `year_quarter` VARCHAR(7) NOT NULL,                 -- 2025-Q4（Tableau/PowerBI 常用）
--     `year_month`   VARCHAR(7) NOT NULL                  -- 2025-01（排序友好）
-- );

-- INSERT INTO dim_date 
-- SELECT
--     ROW_NUMBER() OVER (ORDER BY all_dates.date) AS date_id,
--     all_dates.date,
--     YEAR(all_dates.date) AS `year`,
--     QUARTER(all_dates.date) AS `quarter`,
--     MONTH(all_dates.date) AS `month`,
--     CONCAT(YEAR(all_dates.date), '-Q', QUARTER(all_dates.date)) AS `year_quarter`,
--     CONCAT(YEAR(all_dates.date), '-', LPAD(MONTH(all_dates.date), 2, '0')) AS `year_month`
-- FROM (
--     SELECT '2020-01-01' + INTERVAL (a.a + b.a*10 + c.a*100 + d.a*1000) DAY AS date
--     FROM 
--       (SELECT 0 a UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) a
--     CROSS JOIN
--       (SELECT 0 a UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) b
--     CROSS JOIN
--       (SELECT  (SELECT 0 a UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9) c
--     CROSS JOIN
--       (SELECT 0 a UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL SELECT 5 UNION ALL SELECT 6) d
--     WHERE '2020-01-01' + INTERVAL (a.a + b.a*10 + c.a*100 + d.a*1000) DAY <= '2026-12-31'
-- ) all_dates;

-- -- 驗證：應返回 2557 筆
-- SELECT COUNT(*) FROM dim_date;

-- -- 6b. dim_retailer – 零售商維度（已修復 Foot Locker 雙 ID 問題）
-- --     原始資料集有 1128299 與 1197831 都是 Foot Locker → 強制合併
-- UPDATE sales 
-- SET retailer_id = 1128299 
-- WHERE retailer_id = 1197831;

-- DROP TABLE IF EXISTS dim_retailer;
-- CREATE TABLE dim_retailer (
--     retailer_id   INT PRIMARY KEY,                      -- 原始 retailer_id（已清理）
--     retailer_name VARCHAR(100) NOT NULL,               -- 標準化名稱
--     retailer_type VARCHAR(50)                         -- Mass Merchant / Sporting Goods / Other
-- );

-- INSERT INTO dim_retailer
-- SELECT 
--     retailer_id,
--     MIN(retailer) AS retailer_name,                   -- 取最常見名稱（去空格後相同）
--     CASE 
--         WHEN MIN(retailer) REGEXP 'Walmart|Amazon|Kohl' THEN 'Mass Merchant'
--         WHEN MIN(retailer) REGEXP 'Foot Locker|Dick|DICK' THEN 'Sporting Goods'
--         ELSE 'Department/Other'
--     END AS retailer_type
-- FROM sales
-- GROUP BY retailer_id
-- ORDER BY retailer_id;

-- -- 驗證：應只有 6 間零售商
-- SELECT * FROM dim_retailer;

-- -- 6c. dim_product – 產品維度（正確分類
-- --     修正重點：Women 優先於 Men、Street → Sportstyle 優先
-- DROP TABLE IF EXISTS dim_product;

-- CREATE TABLE dim_product (
--     product_id INT PRIMARY KEY AUTO_INCREMENT,
--     product    VARCHAR(150) NOT NULL UNIQUE,
--     division   VARCHAR(50),      -- Footwear / Apparel / Accessories
--     category   VARCHAR(50),      -- Sportstyle / Performance / Lifestyle
--     gender     VARCHAR(20)       -- Women / Men / Kids / Unisex
-- );

-- INSERT INTO dim_product (product, division, category, gender)
-- SELECT DISTINCT
--     product,
--     CASE 
--         WHEN product LIKE '%Footwear%' THEN 'Footwear'
--         WHEN product LIKE '%Apparel%'   THEN 'Apparel'
--         ELSE 'Accessories'
--     END AS division,
--     CASE
--         WHEN product LIKE '%Street%'                         THEN 'Sportstyle'      -- 最高優先
--         WHEN product LIKE '%Athletic%' OR product LIKE '%Running%' 
--           OR product LIKE '%Basketball%' OR product LIKE '%Training%' THEN 'Performance'
--         ELSE 'Lifestyle'
--     END AS category,
--     CASE
--         WHEN product LIKE '%Women%'             THEN 'Women'   -- Women 必須先判斷！
--         WHEN product LIKE '%Men%'               THEN 'Men'
--         WHEN product LIKE '%Kid%' OR product LIKE '%Children%' THEN 'Kids'
--         ELSE 'Unisex'
--     END AS gender
-- FROM sales
-- ORDER BY product;

-- -- 驗證：Women 產品應全部顯示 Women，Street 應為 Sportstyle
-- SELECT * FROM dim_product;

-- -- 6d. dim_geography – 地理維度（地區 → 州 → 城市）
-- DROP TABLE IF EXISTS dim_geography;
-- CREATE TABLE dim_geography (
--     geo_id INT PRIMARY KEY AUTO_INCREMENT,
--     region VARCHAR(50),
--     state  VARCHAR(50),
--     city   VARCHAR(100)
-- );

-- INSERT INTO dim_geography (region, state, city)
-- SELECT DISTINCT region, state, city FROM sales ORDER BY region, state, city;

-- -- 6e. dim_channel – 渠道維度（DTC vs Wholesale）
-- DROP TABLE IF EXISTS dim_channel;
-- CREATE TABLE dim_channel (
--     channel_id   INT PRIMARY KEY AUTO_INCREMENT,
--     sales_method VARCHAR(50),
--     channel_type VARCHAR(20),   -- DTC / Wholesale
--     sub_channel  VARCHAR(30)   -- Brick & Mortar / E-commerce / Outlet / Marketplace
-- );

-- INSERT INTO dim_channel (sales_method, channel_type, sub_channel) VALUES
-- ('In-store', 'DTC', 'Brick & Mortar'),
-- ('Online',   'DTC', 'E-commerce'),
-- ('Outlet',   'DTC', 'Outlet'),
-- ('West Gear',      'Wholesale', 'Wholesale'),
-- ('Kohl''s',        'Wholesale', 'Wholesale'),
-- ('Sports Direct',   'Wholesale', 'Wholesale'),
-- ('Amazon',         'Wholesale', 'Marketplace'),
-- ('Walmart',        'Wholesale', 'Wholesale');

-- -- 6f. dim_finance – 真實 Adidas 毛利率維度（支援未來季度更新）
-- DROP TABLE IF EXISTS dim_finance;

-- CREATE TABLE dim_finance (
--     finance_key       INT PRIMARY KEY AUTO_INCREMENT,
--     year              INT NOT NULL,
--     quarter           TINYINT NULL,                              -- NULL = 全年平均
--     gross_margin_rate   DECIMAL(5,4) NOT NULL,                   -- 0.5050 = 50.50%
--     source            VARCHAR(100) DEFAULT 'Adidas IR + yfinance',
--     last_update        DATE DEFAULT (CURRENT_DATE),
--     CONSTRAINT uk_year_quarter UNIQUE (year, quarter)
-- );

-- INSERT INTO dim_finance (year, quarter, gross_margin_rate) VALUES
-- (2021, NULL, 0.5200),
-- (2022, NULL, 0.4740),
-- (2023, NULL, 0.4760),
-- (2024, NULL, 0.4920),
-- (2025, NULL, 0.5050);   -- 2025 最新 YTD 平均（截至 Q3）

-- -- ========================================================
-- -- 7. 建立 fact_sales – 星形模型核心事實表
-- -- ========================================================

-- DROP TABLE IF EXISTS fact_sales;
-- CREATE TABLE fact_sales (
--     sales_id           INT PRIMARY KEY,
--     date_id            INT,
--     retailer_id         INT,
--     product_id          INT,
--     geo_id             INT,
--     channel_id          INT,
--     price_per_unit      DECIMAL(10,2),
--     units_sold         INT,
--     total_sales         DECIMAL(12,2),
--     cogs               DECIMAL(12,2),
--     gross_profit       DECIMAL(12,2),
--     operating_profit    DECIMAL(12,2),
--     gross_margin_rate   DECIMAL(5,4),
--     CONSTRAINT fk_date     FOREIGN KEY (date_id)     REFERENCES dim_date(`date_id`),
--     CONSTRAINT fk_retailer FOREIGN KEY (retailer_id) REFERENCES dim_retailer(retailer_id),
--     CONSTRAINT fk_product  FOREIGN KEY (product_id)  REFERENCES dim_product(product_id),
--     CONSTRAINT fk_geo      FOREIGN KEY (geo_id)      REFERENCES dim_geography(geo_id),
--     CONSTRAINT fk_channel  FOREIGN KEY (channel_id)  REFERENCES dim_channel(channel_id)
-- );

-- -- 載入所有交易資料到 fact_sales
-- INSERT INTO fact_sales
-- SELECT
--     s.sales_id,
--     dd.date_id,
--     s.retailer_id,
--     dp.product_id,
--     dg.geo_id,
--     dc.channel_id,
--     s.price_per_unit,
--     s.units_sold,
--     s.total_sales,
--     s.cogs,
--     s.gross_profit,
--     s.operating_profit,
--     s.gross_margin_rate
-- FROM sales s
-- JOIN dim_date      dd ON DATE(s.invoice_date) = dd.`date`
-- JOIN dim_retailer  dr ON s.retailer_id = dr.retailer_id
-- JOIN dim_product   dp ON s.product = dp.product
-- JOIN dim_geography dg ON s.region = dg.region AND s.state = dg.state AND s.city = dg.city
-- JOIN dim_channel   dc ON s.sales_method = dc.sales_method;

-- -- 建立索引大幅提升查詢速度（尤其是 Tableau / Power BI 拖表時）
-- CREATE INDEX idx_date      ON fact_sales(date_id);
-- CREATE INDEX idx_retailer ON fact_sales(retailer_id);
-- CREATE INDEX idx_product   ON fact_sales(product_id);
-- CREATE INDEX idx_geo       ON fact_sales(geo_id);
-- CREATE INDEX idx_channel   ON fact_sales(channel_id);

-- -- 恢復安全設定
-- SET SQL_SAFE_UPDATES = 1;
-- SET FOREIGN_KEY_CHECKS = 1;

-- -- ========================================================
-- -- 最終驗證 – 全部綠燈即代表 100% 成功
-- -- ========================================================
-- SELECT 'Adidas Star Schema 建置完成！' AS status;

-- SELECT 
--     (SELECT COUNT(*) FROM dim_date)      AS dim_date_rows,        -- 2557
--     (SELECT COUNT(*) FROM dim_retailer)  AS dim_retailer_rows,    -- 6
--     (SELECT COUNT(*) FROM dim_product)   AS dim_product_rows,          -- ~30+
--     (SELECT COUNT(*) FROM dim_geography) AS dim_geography_rows,
--     (SELECT COUNT(*) FROM dim_channel)   AS dim_channel_rows,
--     (SELECT COUNT(*) FROM dim_finance)   AS dim_finance_rows,
--     (SELECT COUNT(*) FROM fact_sales)    AS fact_sales_rows;       -- 9637