# 担保物信息_JS_201_DBWXX — 字段取值

> 来源程序: `bsp_sp_js_201_dbwxx.prc`

## 字段映射

| 序号 | 目标字段(alias) | 源表达式(expression) |
|------|----------------|---------------------|
| 1 | `(无)` | `T.USERNAME` |
| 2 | `(无)` | `T.CUST_ID` |
| 3 | `BS` | `COUNT(1) AS BS` |
| 4 | `(无)` | `T.ACCT_NUM` |
| 5 | `LOAN_ACCT_BAL` | `SUM(LOAN_ACCT_BAL) AS LOAN_ACCT_BAL` |
| 6 | `(无)` | `COUNT(1)` |
| 7 | `data_date` | `IS_DATE AS data_date` |
| 8 | `(无)` | `''` |
| 9 | `(无)` | `T.ORG_NUM` |
| 10 | `(无)` | `T.GUAR_CONTRACT_NUM` |
| 11 | `(无)` | `T.BUSINESSCODE` |
| 12 | `(无)` | `T.COLLATERAL_SERIAL_NUM` |
| 13 | `COLLATERAL_TYPE` | `T8.PBOCD_CODE AS COLLATERAL_TYPE` |
| 14 | `(无)` | `T.WARRANT_CODE` |
| 15 | `(无)` | `TRIM(T.FIRST_PRIOR_FLAG)` |
| 16 | `(无)` | `T.ASSESS_TYPE` |
| 17 | `ASSESS_METHOD` | `CASE WHEN T.ASSESS_METHOD = '01' THEN '01' WHEN T.ASSESS_METHOD = '02' THEN '02' WHEN T.ASSESS_METHOD = '03' THEN '03' WHEN T.ASSESS_METHOD = '04' THEN '04' WHEN T.ASSESS_METHOD = '05' THEN '09' END A...` |
| 18 | `(无)` | `(CASE WHEN T.RN = 1 THEN T.ASSESS_VALUE ELSE 0.00 END) * T5.CCY_RATE` |
| 19 | `(无)` | `TIME_TO_STR(STR_TO_DATE(T.ASSESS_BASE_DATE, '%Y-%m-%d'), '%Y-%m-%d')` |
| 20 | `(无)` | `CASE WHEN T.RN = 1 THEN T.COLLATERAL_VALUE ELSE 0.00 END` |
| 21 | `(无)` | `T.PRIORITY_COMPENSATION` |
| 22 | `(无)` | `'99'` |
| 23 | `(无)` | `COALESCE(CASE WHEN T.ORG_NUM LIKE '51%' THEN '99' WHEN T.ORG_NUM LIKE '52%' THEN '99' WHEN T.ORG_NUM LIKE '53%' THEN '99' WHEN T.ORG_NUM LIKE '54%' THEN '99' WHEN T.ORG_NUM LIKE '55%' THEN '99' WHEN T...` |
| 24 | `(无)` | `T.CUST_NAME` |
| 25 | `(无)` | `t.cust_id` |
| 26 | `(无)` | `VS_TEXT` |
| 27 | `(无)` | `T.ORG_CODE` |
| 28 | `(无)` | `T.GUAR_CON_NUM` |
| 29 | `(无)` | `T.CONTRACT_CODE` |
| 30 | `(无)` | `T.COLLATERAL_TYPE` |
| 31 | `(无)` | `COALESCE(T.FIRST_PRIOR_FLAG, '1')` |
| 32 | `(无)` | `T.assess_type` |
| 33 | `(无)` | `T.assess_method` |
| 34 | `(无)` | `T.ASSESS_VALUE` |
| 35 | `(无)` | `T.ASSESS_BASE_DATE` |
| 36 | `(无)` | `CASE WHEN t.collateral_type NOT LIKE 'A%' THEN NULL ELSE T.COLLATERAL_VALUE END` |
| 37 | `(无)` | `'0'` |
| 38 | `(无)` | `T.VALUATION_PERIOD` |
| 39 | `(无)` | `IS_DATE` |
| 40 | `(无)` | `T.BIZ_LINE_ID` |
| 41 | `FRNBJGH` | `CASE WHEN T.ORG_NUM LIKE '51%' THEN '510000' WHEN T.ORG_NUM LIKE '52%' THEN '520000' WHEN T.ORG_NUM LIKE '53%' THEN '530000' WHEN T.ORG_NUM LIKE '54%' THEN '540000' WHEN T.ORG_NUM LIKE '55%' THEN '550...` |
| 42 | `(无)` | `t.cust_name` |
| 43 | `CUST_TYPE` | `'002' AS CUST_TYPE` |
| 44 | `(无)` | `COALESCE(COALESCE(OB.ID_NO, OB.UP_ID_NO), COALESCE(OB2.ID_NO, OB2.UP_ID_NO))` |
| 45 | `(无)` | `t.WARRANT_CODE` |
| 46 | `(无)` | `t.assess_type` |
| 47 | `(无)` | `t.assess_method` |
| 48 | `(无)` | `T.FRNBJGH` |
