create database titan_financial_analysis;

use titan_financial_analysis;

 --  Balance Sheet table creation --
CREATE TABLE balance_sheet (
    Narration VARCHAR(100),
    FY2017 DECIMAL(12,2),
    FY2018 DECIMAL(12,2),
    FY2019 DECIMAL(12,2),
    FY2020 DECIMAL(12,2),
    FY2021 DECIMAL(12,2),
    FY2022 DECIMAL(12,2),
    FY2023 DECIMAL(12,2),
    FY2024 DECIMAL(12,2),
    FY2025 DECIMAL(12,2),
    FY2026 DECIMAL(12,2)
);

## creating cash flow table ## 
CREATE TABLE cash_flow (
    Narration VARCHAR(100),
    FY2017 DECIMAL(12,2),
    FY2018 DECIMAL(12,2),
    FY2019 DECIMAL(12,2),
    FY2020 DECIMAL(12,2),
    FY2021 DECIMAL(12,2),
    FY2022 DECIMAL(12,2),
    FY2023 DECIMAL(12,2),
    FY2024 DECIMAL(12,2),
    FY2025 DECIMAL(12,2),
    FY2026 DECIMAL(12,2)
);

Drop table profit_loss;

## creating p/l table ##
 CREATE TABLE profit_loss (
    Year VARCHAR(10),
    Revenue DECIMAL(12,2),
    Expenses DECIMAL(12,2),
    Operating_Profit DECIMAL(12,2),
    Other_Income DECIMAL(12,2),
    Depreciation DECIMAL(12,2),
    Interest DECIMAL(12,2),
    PBT DECIMAL(12,2),
    Net_Profit DECIMAL(12,2),
    EPS DECIMAL(10,2),
    EBITDA DECIMAL(12,2),
    Net_Profit_Margin DECIMAL(8,2),
    YoY_Revenue_Growth DECIMAL(8,2)
);

-- Verify all 3 tables have data
SELECT COUNT(*) AS PL_Rows 
FROM profit_loss;
SELECT COUNT(*) AS BS_Rows
 FROM balance_sheet;
SELECT COUNT(*) AS CF_Rows
 FROM cash_flow;
 
 -- Check P&L data
SELECT Year, Revenue, Net_Profit FROM profit_loss;

-- Check Balance Sheet data
SELECT Narration FROM balance_sheet;

-- Check P&L data
SELECT Year, Revenue, Net_Profit FROM profit_loss;

INSERT INTO profit_loss VALUES (
    'FY2017', 13260.83, 12096.93, 1163.90, -42.38, 
    110.53, 37.74, 973.25, 711.47, 8.01, 
    1274.43, 5.37, NULL
);

SELECT Narration FROM balance_sheet;

INSERT INTO balance_sheet VALUES (
    'Return on Capital Emp',
    NULL,
    0.2455, 0.2636, 0.2426, 0.1310,
    0.2101, 0.2512, 0.2272, 0.1915, 0.2028
);

select * from profit_loss;

-- Query 1: Revenue Trend Analysis
SELECT 
    Year,
    Revenue,
    Net_Profit,
    YoY_Revenue_Growth
FROM profit_loss
ORDER BY Year;

-- Query 2: Net Profit Trend Analysis
SELECT 
    Year,
    Revenue,
    Net_Profit,
    Net_Profit_Margin
FROM profit_loss
ORDER BY Year;

-- Query 3: Best and Worst Performing Years
SELECT 
    Year,
    Revenue,
    Net_Profit,
    Net_Profit_Margin,
    YoY_Revenue_Growth
FROM profit_loss
ORDER BY Revenue DESC;

-- Query 3B: Best and Worst Growth Years
SELECT 
    Year,
    Revenue,
    YoY_Revenue_Growth
FROM profit_loss
WHERE YoY_Revenue_Growth IS NOT NULL
ORDER BY YoY_Revenue_Growth DESC;

-- Query 4: EBITDA Trend Analysis
SELECT 
    Year,
    Revenue,
    EBITDA,
    ROUND(EBITDA / Revenue * 100, 2) AS EBITDA_Margin
FROM profit_loss
ORDER BY Year;

-- See EBITDA Margin ranked highest to lowest
SELECT 
    Year,
    EBITDA,
    ROUND(EBITDA / Revenue * 100, 2) AS EBITDA_Margin
FROM profit_loss
ORDER BY EBITDA_Margin DESC;

-- Query 5: Working Capital Trend
SELECT 
    Narration,
    FY2017, FY2018, FY2019, FY2020,
    FY2021, FY2022, FY2023, FY2024,
    FY2025, FY2026
FROM balance_sheet
WHERE Narration IN (
    'Working Capital',
    'Debtors',
    'Inventory'
);

-- Query 6: Debt Trend Analysis
SELECT 
    Narration,
    FY2017, FY2018, FY2019, FY2020,
    FY2021, FY2022, FY2023, FY2024,
    FY2025, FY2026
FROM balance_sheet
WHERE Narration IN (
    'Borrowings',
    'Equity Share Capital',
    'Reserves'
);

-- Query 6: Debt Trend Analysis
SELECT 
    Narration,
    FY2017, FY2018, FY2019, FY2020,
    FY2021, FY2022, FY2023, FY2024,
    FY2025, FY2026
FROM balance_sheet
WHERE Narration IN (
    'Borrowings',
    'Equity Share Capital',
    'Reserves'
);

-- Query 6B: Debt vs Reserves comparison
SELECT 
    Narration,
    FY2017,
    FY2026,
    ROUND((FY2026 - FY2017) / FY2017 * 100, 2) AS Growth_Pct
FROM balance_sheet
WHERE Narration IN ('Borrowings', 'Reserves')
ORDER BY Narration;

-- Query 7: Cash Flow Analysis
SELECT 
    Narration,
    FY2017, FY2018, FY2019, FY2020,
    FY2021, FY2022, FY2023, FY2024,
    FY2025, FY2026
FROM cash_flow
ORDER BY Narration;

-- Query 8: ROE Trend Analysis
SELECT 
    Narration,
    FY2017, FY2018, FY2019, FY2020,
    FY2021, FY2022, FY2023, FY2024,
    FY2025, FY2026
FROM balance_sheet
WHERE Narration IN (
    'Return on Equity',
    'Return on Capital Emp'
);

-- Query 9: Efficiency Analysis
SELECT 
    Narration,
    FY2017, FY2018, FY2019, FY2020,
    FY2021, FY2022, FY2023, FY2024,
    FY2025, FY2026
FROM balance_sheet
WHERE Narration IN (
    'Debtor Days',
    'Inventory Turnover',
    'Debtors',
    'Inventory'
);

-- Query 10: Combined Financial Health Scorecard
SELECT 
    p.Year,
    p.Revenue,
    p.Net_Profit,
    p.Net_Profit_Margin,
    p.EBITDA,
    p.YoY_Revenue_Growth,
    p.EPS
FROM profit_loss p
ORDER BY p.Year;

SELECT COUNT(*) FROM profit_loss;
SELECT * FROM profit_loss;


-- Create a Financial Summary View
CREATE VIEW titan_financial_summary AS
SELECT 
    Year,
    Revenue,
    Net_Profit,
    Net_Profit_Margin,
    EBITDA,
    EPS,
    YoY_Revenue_Growth
FROM profit_loss
ORDER BY Year;

select * from  titan_financial_summary;
-- Final verification
SELECT * FROM profit_loss ORDER BY Year;
SELECT * FROM balance_sheet;
SELECT * FROM cash_flow;
SELECT * FROM titan_financial_summary;