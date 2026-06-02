# 担保合同信息_JS_201_DBHTXX — 字段取值

> 来源程序: `bsp_sp_js_201_dbhtxx.prc`

## 字段映射

| 序号 | 目标字段(alias) | 源表达式(expression) |
|------|----------------|---------------------|
| 1 | `(无)` | `T.USERNAME` |
| 2 | `(无)` | `T.CUST_ID` |
| 3 | `BS` | `COUNT(1) AS BS` |
| 4 | `(无)` | `GR.GUAR_CONTRACT_NUM` |
| 5 | `COLL_VALUE` | `SUM(GI.COLL_MK_VAL) AS COLL_VALUE` |
| 6 | `(无)` | `D.ACCT_NUM` |
| 7 | `LOAN_ACCT_BAL_SUM` | `SUM(D.LOAN_ACCT_BAL) AS LOAN_ACCT_BAL_SUM` |
| 8 | `(无)` | `t4.DATE_SOURCESD` |
| 9 | `(无)` | `T4.GUAR_CONTRACT_NUM` |
| 10 | `(无)` | `T4.DEPT_TYPE` |
| 11 | `(无)` | `T4.ID_NO` |
| 12 | `(无)` | `T4.ID_TYPE` |
| 13 | `(无)` | `T4.CORP_SCALE` |
| 14 | `(无)` | `T4.INDUSTRY_TYPE` |
| 15 | `REG_AREA_CODE` | `CASE WHEN LENGTHB(T4.REG_AREA_CODE) = 6 THEN T4.REG_AREA_CODE END AS REG_AREA_CODE` |
| 16 | `(无)` | `T4.DATA_DATE` |
| 17 | `(无)` | `T4.GUARANTEE_NAME` |
| 18 | `(无)` | `t4.GUAR_CUST_ID` |
| 19 | `(无)` | `T.ACCT_NUM` |
| 20 | `LOAN_ACCT_BAL` | `SUM(COALESCE(LOAN_ACCT_BAL, 0)) AS LOAN_ACCT_BAL` |
| 21 | `(无)` | `T.DATE_SOURCESD` |
| 22 | `(无)` | `T.GUAR_CONTRACT_NUM` |
| 23 | `(无)` | `T1.CONTRACT_NUM` |
| 24 | `(无)` | `T.CURR_CD` |
| 25 | `(无)` | `T.GURA_CONTRACT_AMT` |
| 26 | `(无)` | `T3.COLL_VALUE` |
| 27 | `(无)` | `T.ORG_NUM` |
| 28 | `(无)` | `CAST(T.GUAR_CONTRACT_START_DT AS TEXT)` |
| 29 | `(无)` | `CAST(T.GUAR_CONTRACT_END_DT AS TEXT)` |
| 30 | `DZYL` | `ROUND((T3.DZYL * 100), 2) AS DZYL` |
| 31 | `(无)` | `T.GUAR_CONTRACT_STATUS` |
| 32 | `(无)` | `T.GUAR_TYP` |
| 33 | `(无)` | `T5.DEPT_TYPE` |
| 34 | `(无)` | `T5.GUAR_ID_NO` |
| 35 | `(无)` | `T5.GUAR_ID_TYPE` |
| 36 | `(无)` | `T5.CORP_SCALE` |
| 37 | `(无)` | `CASE WHEN T5.INDUSTRY_TYPE = '100' THEN '100' ELSE T5.INDUSTRY_TYPE END` |
| 38 | `(无)` | `T5.REGION_CD` |
| 39 | `RN` | `ROW_NUMBER() OVER (PARTITION BY T.GUAR_CONTRACT_NUM ORDER BY 1 DESC NULLS FIRST) AS RN` |
| 40 | `GUAR_CON_TYPE` | `CASE WHEN T.GUAR_CONTRACT_TYP = 'A' THEN '01' WHEN T.GUAR_CONTRACT_TYP = 'B' THEN '02' END AS GUAR_CON_TYPE` |
| 41 | `(无)` | `T4.CUST_ID` |
| 42 | `(无)` | `T8.CUST_NAM` |
| 43 | `(无)` | `T5.GUAR_CUST_ID` |
| 44 | `(无)` | `T5.GUAR_CUSTNAME` |
| 45 | `(无)` | `COUNT(1)` |
| 46 | `(无)` | `IS_DATE` |
| 47 | `(无)` | `''` |
| 48 | `DBHTBH` | `T.GUAR_CONTRACT_NUM AS DBHTBH` |
| 49 | `(无)` | `SUBSTRING(T.CONTRACT_NUM, 1, 100)` |
| 50 | `(无)` | `T.GUAR_CONTRACT_TYP` |
| 51 | `(无)` | `'02'` |
| 52 | `(无)` | `T.GUAR_CONTRACT_START_DT` |
| 53 | `(无)` | `T.GUAR_CONTRACT_END_DT` |
| 54 | `(无)` | `CASE WHEN T.RN = 1 THEN T.GUAR_CON_AMT ELSE 0.00 END` |
| 55 | `(无)` | `(CASE WHEN T.RN = 1 THEN T.GUAR_CON_AMT ELSE 0.00 END) * T2.CCY_RATE` |
| 56 | `(无)` | `T.COLLATERAL_RATIO` |
| 57 | `(无)` | `T.GUAR_ID_TYPE` |
| 58 | `(无)` | `SUBSTRING(T.GUAR_ID_NO, 1, 60)` |
| 59 | `(无)` | `TRIM(T.DEPT_TYPE)` |
| 60 | `(无)` | `T.INDUSTRY_TYPE` |
| 61 | `(无)` | `T.REG_AREA_CODE` |
| 62 | `(无)` | `T.ENT_SCALE` |
| 63 | `(无)` | `COALESCE(CASE WHEN T.ORG_NUM LIKE '51%' THEN '99' WHEN T.ORG_NUM LIKE '52%' THEN '99' WHEN T.ORG_NUM LIKE '53%' THEN '99' WHEN T.ORG_NUM LIKE '54%' THEN '99' WHEN T.ORG_NUM LIKE '55%' THEN '99' WHEN T...` |
| 64 | `(无)` | `T.CUST_NAME` |
| 65 | `(无)` | `T.GUAR_CUST_NAME` |
| 66 | `(无)` | `VS_TEXT` |
| 67 | `(无)` | `t.ORG_CODE` |
| 68 | `(无)` | `t.ORG_NUM` |
| 69 | `(无)` | `t.GUAR_CON_NUM` |
| 70 | `(无)` | `t.CONTRACT_CODE` |
| 71 | `(无)` | `t.GUAR_CON_TYPE` |
| 72 | `(无)` | `t.BUSINESS_TYPE` |
| 73 | `(无)` | `t.GUAR_CON_SIGN_DATE` |
| 74 | `(无)` | `t.GUAR_CON_DUE_DATE` |
| 75 | `(无)` | `t.CURR_CODE` |
| 76 | `(无)` | `t.GUAR_CON_AMT` |
| 77 | `(无)` | `t.GURA_CON_AMT_RMB` |
| 78 | `(无)` | `t.COLLATERAL_RATIO` |
| 79 | `(无)` | `T.GUAR_ID_NO` |
| 80 | `(无)` | `T.DEPT_TYPE` |
| 81 | `(无)` | `CASE WHEN T.DEPT_TYPE = 'D01' THEN 'CS05' ELSE T.ENT_SCALE END` |
| 82 | `(无)` | `t.CJRQ` |
| 83 | `(无)` | `t.NBJGH` |
| 84 | `(无)` | `T.BIZ_LINE_ID` |
| 85 | `FRNBJGH` | `CASE WHEN T.NBJGH LIKE '51%' THEN '510000' WHEN T.NBJGH LIKE '52%' THEN '520000' WHEN T.NBJGH LIKE '53%' THEN '530000' WHEN T.NBJGH LIKE '54%' THEN '540000' WHEN T.NBJGH LIKE '55%' THEN '550000' WHEN ...` |
| 86 | `(无)` | `t.cust_name` |
| 87 | `CUST_TYPE` | `'002' AS CUST_TYPE` |
| 88 | `GUARANTEE_NAME` | `t.CUSTNAME AS GUARANTEE_NAME` |
| 89 | `(无)` | `COALESCE(COALESCE(OB.ID_NO, OB.UP_ID_NO), COALESCE(OB2.ID_NO, OB2.UP_ID_NO))` |
| 90 | `(无)` | `COALESCE(T3.GUAR_ID_TYPE, COALESCE(T4.GUAR_ID_TYPE, t.GUAR_ID_TYPE))` |
| 91 | `(无)` | `t.GUAR_ID_NO` |
| 92 | `(无)` | `COALESCE(t.DEPT_TYPE, COALESCE(t3.DEPT_TYPE, t4.DEPT_TYPE))` |
| 93 | `(无)` | `COALESCE(t3.INDUSTRY_TYPE, COALESCE(t4.INDUSTRY_TYPE, t.INDUSTRY_TYPE))` |
| 94 | `(无)` | `COALESCE(t3.REG_AREA_CODE, COALESCE(t4.REG_AREA_CODE, t.REG_AREA_CODE))` |
| 95 | `(无)` | `COALESCE(t3.ENT_SCALE, COALESCE(t4.ENT_SCALE, t.ENT_SCALE))` |
| 96 | `(无)` | `T.FRNBJGH` |
| 97 | `(无)` | `t.GUARANTEE_NAME` |
