# 存量再贴现信息_JS_205_CLZTX — 字段取值

> 来源程序: `bsp_sp_js_205_clztx.prc`

## 字段映射

| 序号 | 目标字段(alias) | 源表达式(expression) |
|------|----------------|---------------------|
| 1 | `(无)` | `T.USERNAME` |
| 2 | `(无)` | `COUNT(1)` |
| 3 | `(无)` | `IS_DATE` |
| 4 | `JRJGBM` | `'' AS JRJGBM` |
| 5 | `(无)` | `A.ORG_NUM` |
| 6 | `AREA_ID` | `'' AS AREA_ID` |
| 7 | `(无)` | `A.BILL_NUM` |
| 8 | `BILL_TYPE` | `CASE WHEN TRIM(B.BILL_TYPE) = '1' THEN '01' WHEN B.BILL_TYPE = '2' THEN '02' END AS BILL_TYPE` |
| 9 | `BILL_MEDIUM` | `CASE WHEN B.IS_P_BILL = 'Y' THEN '01' ELSE '02' END AS BILL_MEDIUM` |
| 10 | `(无)` | `CAST(B.OPEN_DATE AS TEXT)` |
| 11 | `(无)` | `CAST(B.MATU_DATE AS TEXT)` |
| 12 | `DISCOUNT_DATE` | `CAST(F.DRAWDOWN_DT AS TEXT) AS DISCOUNT_DATE` |
| 13 | `REDISCOUNT_DUE_DATE` | `CAST(A.MATURE_DATE AS TEXT) AS REDISCOUNT_DUE_DATE` |
| 14 | `TRANS_DATE` | `CAST(A.START_DATE AS TEXT) AS TRANS_DATE` |
| 15 | `DRAWER_NAME` | `B.AFF_NAME AS DRAWER_NAME` |
| 16 | `(无)` | `''` |
| 17 | `(无)` | `NVL2(FR.FINA_ORG_NAME_FR, FR.FINA_ORG_NAME_FR, B.PAY_BANK_NAME)` |
| 18 | `(无)` | `'A01'` |
| 19 | `(无)` | `NVL2(FR.FINA_ORG_NAME_FR, FR.LEGAL_TYSHXYDM_FR, B.BILLS_COMMIT_ORG_ID_NO)` |
| 20 | `(无)` | `TRIM(B.CURR_CD)` |
| 21 | `(无)` | `A.BALANCE` |
| 22 | `(无)` | `A.BALANCE * R.CCY_RATE` |
| 23 | `REDISCOUNT_INT_RATE` | `COALESCE(A.REAL_INT_RAT, 0) * 100 AS REDISCOUNT_INT_RATE` |
| 24 | `REDISCOUNT_CURR_CODE` | `A.CURR_CD AS REDISCOUNT_CURR_CODE` |
| 25 | `REDISCOUNT_BAL` | `A.BALANCE - A.ACCRUAL AS REDISCOUNT_BAL` |
| 26 | `REDISCOUNT_BAL_RMB` | `(A.BALANCE - A.ACCRUAL) * Z.CCY_RATE AS REDISCOUNT_BAL_RMB` |
| 27 | `(无)` | `VS_TEXT` |
| 28 | `(无)` | `COALESCE(OB.ID_NO, OB.UP_ID_NO)` |
| 29 | `(无)` | `T.ORG_NUM` |
| 30 | `(无)` | `OB.REGION_CD` |
| 31 | `(无)` | `BILL_NUM` |
| 32 | `(无)` | `BILL_TYPE` |
| 33 | `(无)` | `BILL_MEDIUM` |
| 34 | `(无)` | `OPEN_DATE` |
| 35 | `(无)` | `BILL_DUE_DATE` |
| 36 | `(无)` | `DISCOUNT_DATE` |
| 37 | `(无)` | `REDISCOUNT_DUE_DATE` |
| 38 | `(无)` | `TRANS_DATE` |
| 39 | `(无)` | `DRAWER_NAME` |
| 40 | `(无)` | `DRAWER_ID_TYPE` |
| 41 | `(无)` | `DRAWER_ID_NO` |
| 42 | `(无)` | `ACCEPT_NAME` |
| 43 | `(无)` | `ACCEPT_ID_TYPE` |
| 44 | `(无)` | `TRIM(ACCEPT_ID_NO)` |
| 45 | `(无)` | `BILL_CURR_CODE` |
| 46 | `(无)` | `BILL_AMT` |
| 47 | `(无)` | `BILL_AMT_RMB` |
| 48 | `(无)` | `REDISCOUNT_INT_RATE` |
| 49 | `(无)` | `REDISCOUNT_CURR_CODE` |
| 50 | `(无)` | `REDISCOUNT_BAL` |
| 51 | `(无)` | `REDISCOUNT_BAL_RMB` |
| 52 | `(无)` | `SYS_GUID()` |
| 53 | `BIZ_LINE_ID` | `CASE WHEN T.ORG_NUM LIKE '51%' THEN '99' WHEN T.ORG_NUM LIKE '52%' THEN '99' WHEN T.ORG_NUM LIKE '53%' THEN '99' WHEN T.ORG_NUM LIKE '54%' THEN '99' WHEN T.ORG_NUM LIKE '55%' THEN '99' WHEN T.ORG_NUM ...` |
| 54 | `FRNBJGH` | `CASE WHEN T.ORG_NUM LIKE '51%' THEN '510000' WHEN T.ORG_NUM LIKE '52%' THEN '520000' WHEN T.ORG_NUM LIKE '53%' THEN '530000' WHEN T.ORG_NUM LIKE '54%' THEN '540000' WHEN T.ORG_NUM LIKE '55%' THEN '550...` |
