# JS_201_HDASZDKFS — 字段取值

> 来源程序: `bsp_sp_js_201_hdaszdkfs.prc`

## 字段映射

| 序号 | 目标字段(alias) | 源表达式(expression) |
|------|----------------|---------------------|
| 1 | `(无)` | `A1.LOAN_NUM` |
| 2 | `(无)` | `A1.ACCT_NUM` |
| 3 | `(无)` | `A1.DRAFT_RNG` |
| 4 | `(无)` | `A1.ACCT_TYP` |
| 5 | `(无)` | `A.LOAN_ACCT_BAL` |
| 6 | `(无)` | `A.DRAWDOWN_AMT` |
| 7 | `(无)` | `A.DISCOUNT_INTEREST` |
| 8 | `(无)` | `A1.CUST_ID` |
| 9 | `(无)` | `A.ORG_NUM` |
| 10 | `(无)` | `A1.DATA_DATE` |
| 11 | `(无)` | `A1.CURR_CD` |
| 12 | `(无)` | `A1.REAL_INT_RAT` |
| 13 | `(无)` | `A1.DIGITAL_ECONOMY_INDUSTRY` |
| 14 | `DATA_DATE` | `VS_TEXT AS DATA_DATE` |
| 15 | `(无)` | `FIELD_TYPE` |
| 16 | `(无)` | `SUM(BALANCE_SUM)` |
| 17 | `(无)` | `SUM(INT_RATE_WA)` |
| 18 | `(无)` | `SUM(GET_LOAN_NUM)` |
| 19 | `REPORT_ID` | `SYS_GUID() AS REPORT_ID` |
| 20 | `CJRQ` | `IS_DATE AS CJRQ` |
| 21 | `(无)` | `NBJGH \|\| '0000'` |
| 22 | `BIZ_LINE_ID` | `'99' AS BIZ_LINE_ID` |
| 23 | `VERIFY_STATUS` | `NULL AS VERIFY_STATUS` |
| 24 | `BSCJRQ` | `IS_DATE AS BSCJRQ` |
| 25 | `(无)` | `'T99'` |
| 26 | `(无)` | `COALESCE(OB.ID_NO, OB.UP_ID_NO)` |
| 27 | `(无)` | `T.ORG_NUM` |
| 28 | `(无)` | `CASE WHEN T.ACCT_TYP NOT LIKE '0301%' THEN T.ACCT_NUM ELSE '0' END` |
| 29 | `(无)` | `CASE WHEN T.ACCT_TYP NOT LIKE '0301%' THEN T.LOAN_NUM ELSE '0' END` |
| 30 | `(无)` | `CASE WHEN T.ACCT_TYP LIKE '0301%' THEN T.ACCT_NUM \|\| T.DRAFT_RNG ELSE '0' END` |
| 31 | `(无)` | `'1'` |
| 32 | `(无)` | `CASE WHEN SUBSTRING(T.FLAG, 1, 2) IN ('01', '02', '03', '04') THEN '1' ELSE '0' END` |
| 33 | `(无)` | `CASE WHEN SUBSTRING(T.FLAG, 1, 2) = '01' THEN 'DE01' WHEN SUBSTRING(T.FLAG, 1, 2) = '02' THEN 'DE02' WHEN SUBSTRING(T.FLAG, 1, 2) = '03' THEN 'DE03' WHEN SUBSTRING(T.FLAG, 1, 2) = '04' THEN 'DE04' END` |
| 34 | `(无)` | `'0'` |
| 35 | `(无)` | `CASE WHEN T.ACCT_TYP NOT LIKE '0301%' THEN 'C01' ELSE 'C03' END` |
| 36 | `NBJGH` | `T.ORG_NUM AS NBJGH` |
| 37 | `FRNBJGH` | `CASE WHEN T.ORG_NUM LIKE '51%' THEN '510000' WHEN T.ORG_NUM LIKE '52%' THEN '520000' WHEN T.ORG_NUM LIKE '53%' THEN '530000' WHEN T.ORG_NUM LIKE '54%' THEN '540000' WHEN T.ORG_NUM LIKE '55%' THEN '550...` |
| 38 | `(无)` | `T.CUST_ID` |
| 39 | `(无)` | `A2.CUST_NAM` |
| 40 | `(无)` | `T.LOAN_ACCT_BAL` |
| 41 | `(无)` | `T.CURR_CD` |
| 42 | `(无)` | `T.LOAN_ACCT_BAL * U.CCY_RATE` |
| 43 | `(无)` | `T.DRAWDOWN_AMT` |
| 44 | `(无)` | `T.DISCOUNT_INTEREST` |
