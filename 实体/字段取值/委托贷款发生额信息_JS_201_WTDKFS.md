# 委托贷款发生额信息_JS_201_WTDKFS — 字段取值

> 来源程序: `bsp_sp_js_201_wtdkfs.prc`

## 字段映射

| 序号 | 目标字段(alias) | 源表达式(expression) |
|------|----------------|---------------------|
| 1 | `(无)` | `T.USERNAME` |
| 2 | `(无)` | `COUNT(1)` |
| 3 | `(无)` | `T.LOAN_NUM` |
| 4 | `(无)` | `T.DRAWDOWN_AMT` |
| 5 | `(无)` | `T.ACCT_NUM` |
| 6 | `(无)` | `T.ORG_NUM` |
| 7 | `(无)` | `T.CURR_CD` |
| 8 | `(无)` | `'1'` |
| 9 | `(无)` | `T.DATA_DATE` |
| 10 | `(无)` | `CAST(T.DRAWDOWN_DT AS TEXT)` |
| 11 | `(无)` | `M.PAY_AMT` |
| 12 | `(无)` | `'0'` |
| 13 | `SERIAL_NO` | `M.TX_NO AS SERIAL_NO` |
| 14 | `(无)` | `T.CUST_ID` |
| 15 | `(无)` | `NVL2(LP.CUST_ID, 'D01', CASE WHEN LC.CUST_TYP = '3' THEN 'D01' ELSE H.DEPT_TYPE END)` |
| 16 | `(无)` | `CASE WHEN LC.CUST_TYP = '3' THEN (SELECT PBOCD_CODE FROM L_CODE_DICTIONARY AS D4 WHERE TRIM(LC.Legal_Card_TYPE) = D4.L_CODE AND D4.CODE_CLMN_NAME = 'ID_TYPE') WHEN NOT LP.CUST_ID IS NULL THEN CD2.PBOC...` |
| 17 | `(无)` | `CASE WHEN LC.CUST_TYP = '3' THEN LC.Legal_Card_No WHEN NOT LP.CUST_ID IS NULL THEN LP.ID_NO WHEN NOT LC.CUST_ID IS NULL AND CD1.PBOCD_CODE = 'A02' THEN REPLACE(LC.ID_NO, '-') WHEN NOT LC.CUST_ID IS NU...` |
| 18 | `(无)` | `NVL2(LP.CUST_ID, '100', CASE WHEN LC.CUST_TYP = 3 THEN '100' ELSE SUBSTRB(TRIM(LC.CORP_BUSINSESS_TYPE), 0, 3) END)` |
| 19 | `(无)` | `NVL2(LP.CUST_ID, LP.REGION_CD, LC.REGION_CD)` |
| 20 | `(无)` | `CASE WHEN LC.CUST_TYP = '3' THEN '' ELSE CD3.PBOCD_CODE END` |
| 21 | `(无)` | `NVL2(LC.CUST_ID, CASE WHEN LC.CUST_TYP = '3' THEN NULL ELSE DECODE(LC.CORP_SCALE, 'B', 'CS01', 'M', 'CS02', 'S', 'CS03', 'T', 'CS04', 'CS05') END, '')` |
| 22 | `(无)` | `COALESCE(LP.CUST_NAM, LC.CUST_NAM)` |
| 23 | `(无)` | `T1.TRUSTOR_ID` |
| 24 | `(无)` | `NVL2(LP.CUST_ID, 'D01', H.DEPT_TYPE)` |
| 25 | `(无)` | `NVL2(LP.CUST_ID, CD2.PBOCD_CODE, CD1.PBOCD_CODE)` |
| 26 | `(无)` | `NVL2(LP.CUST_ID, LP.ID_NO, CASE WHEN CD1.PBOCD_CODE = 'A02' THEN REPLACE(LC.ID_NO, '-') ELSE LC.ID_NO END)` |
| 27 | `(无)` | `cd3.pbocd_code` |
| 28 | `(无)` | `NVL2(LC.CUST_ID, DECODE(LC.CORP_SCALE, 'B', 'CS01', 'M', 'CS02', 'S', 'CS03', 'T', 'CS04', 'CS05'), '')` |
| 29 | `DATA_DATE` | `IS_DATE AS DATA_DATE` |
| 30 | `(无)` | `''` |
| 31 | `ORG_NUM` | `T.JGBH AS ORG_NUM` |
| 32 | `(无)` | `T1.DEPT_TYPE` |
| 33 | `(无)` | `T1.CUST_ID_TYPE` |
| 34 | `(无)` | `T1.CUST_ID_NO` |
| 35 | `(无)` | `T1.INDUSTRY_TYPE` |
| 36 | `REG_AREA_CODE` | `T1.REG_REGION_CODE AS REG_AREA_CODE` |
| 37 | `(无)` | `T1.CORP_HOLD_TYPE` |
| 38 | `(无)` | `T1.ENT_SCALE` |
| 39 | `LOAN_NUM` | `T.JJBH AS LOAN_NUM` |
| 40 | `CONTRACT_CODE` | `T3.ACCT_NUM AS CONTRACT_CODE` |
| 41 | `LOAN_GRANT_DATE` | `CASE WHEN T.FLAG = '4' THEN COALESCE(TIME_TO_STR(STR_TO_DATE(T.FKRQ, '%Y%m%d'), '%Y-%m-%d'), CAST(T3.DRAWDOWN_DT AS TEXT)) ELSE CAST(T3.DRAWDOWN_DT AS TEXT) END AS LOAN_GRANT_DATE` |
| 42 | `LOAN_DUE_DATE` | `CAST(T3.MATURITY_DT AS TEXT) AS LOAN_DUE_DATE` |
| 43 | `LOAN_PURPOSE_CD` | `SUBSTRB(T3.LOAN_PURPOSE_CD, 1, 4) AS LOAN_PURPOSE_CD` |
| 44 | `CURR_CODE` | `T3.CURR_CD AS CURR_CODE` |
| 45 | `BALANCE` | `T.JJYE AS BALANCE` |
| 46 | `BALANCE_RMB` | `T.JJYE AS BALANCE_RMB` |
| 47 | `INT_RATE_TYPE` | `CASE WHEN T3.INT_RATE_TYP = 'F' THEN 'RF01' ELSE 'RF02' END AS INT_RATE_TYPE` |
| 48 | `INT_RATE` | `T3.REAL_INT_RAT AS INT_RATE` |
| 49 | `FEE_AMT_RMB` | `T4.FEE_AMT AS FEE_AMT_RMB` |
| 50 | `GUAR_TYPE` | `TP7.GUAR_TYPE AS GUAR_TYPE` |
| 51 | `(无)` | `T2.DEPT_TYPE` |
| 52 | `(无)` | `T2.CUST_ID_TYPE` |
| 53 | `(无)` | `T2.CUST_ID_NO` |
| 54 | `(无)` | `T2.INDUSTRY_TYPE` |
| 55 | `(无)` | `T2.REG_REGION_CODE` |
| 56 | `(无)` | `T2.CORP_HOLD_TYPE` |
| 57 | `(无)` | `T2.ENT_SCALE` |
| 58 | `TRANS_TYPE` | `T.FLAG AS TRANS_TYPE` |
| 59 | `REPORT_ID` | `SYS_GUID() AS REPORT_ID` |
| 60 | `CJRQ` | `IS_DATE AS CJRQ` |
| 61 | `NBJGH` | `T.JGBH AS NBJGH` |
| 62 | `BIZ_LINE_ID` | `CASE WHEN T3.ORG_NUM LIKE '51%' THEN '99' WHEN t3.ORG_NUM LIKE '52%' THEN '99' WHEN t3.ORG_NUM LIKE '53%' THEN '99' WHEN t3.ORG_NUM LIKE '54%' THEN '99' WHEN t3.ORG_NUM LIKE '55%' THEN '99' WHEN t3.OR...` |
| 63 | `VERIFY_STATUS` | `'' AS VERIFY_STATUS` |
| 64 | `BSCJRQ` | `'' AS BSCJRQ` |
| 65 | `USEOFUNDS` | `T3.USEOFUNDS AS USEOFUNDS` |
| 66 | `SERIAL_NO` | `T.SERIAL_NO AS SERIAL_NO` |
| 67 | `FRNBJGH` | `CASE WHEN T3.ORG_NUM LIKE '51%' THEN '510000' WHEN T3.ORG_NUM LIKE '52%' THEN '520000' WHEN T3.ORG_NUM LIKE '53%' THEN '530000' WHEN T3.ORG_NUM LIKE '54%' THEN '540000' WHEN T3.ORG_NUM LIKE '55%' THEN...` |
| 68 | `(无)` | `T3.CUST_ID` |
| 69 | `(无)` | `T1.CUST_NAME` |
| 70 | `(无)` | `T2.TRUSTOR_CUST_NAME` |
| 71 | `(无)` | `VS_TEXT` |
| 72 | `(无)` | `COALESCE(OB.ID_NO, OB.UP_ID_NO)` |
| 73 | `(无)` | `OB.REGION_CD` |
| 74 | `(无)` | `T.DEPT_TYPE` |
| 75 | `(无)` | `T.CUST_ID_TYPE` |
| 76 | `(无)` | `T.CUST_ID_NO` |
| 77 | `(无)` | `T.INDUSTRY_TYPE` |
| 78 | `(无)` | `T.REG_AREA_CODE` |
| 79 | `(无)` | `T.ENT_CON_ECO_ELEM` |
| 80 | `(无)` | `T.ENT_SCALE` |
| 81 | `(无)` | `T.CONTRACT_CODE` |
| 82 | `(无)` | `T.ENTRUST_LOAN_GRANT_DATE` |
| 83 | `(无)` | `T.ENTRUST_LOAN_DUE_DATE` |
| 84 | `(无)` | `COALESCE(T.LOAN_PURPOSE_CD, CASE WHEN SUBSTRING(T.CUST_ID_TYPE, 1, 1) = 'B' AND T.CUST_ID_TYPE IN ('B06', 'B07', 'B09', 'B11', 'B12') THEN '2000' WHEN SUBSTRING(T.CUST_ID_TYPE, 1, 1) = 'B' AND NOT T.C...` |
| 85 | `(无)` | `T.CURR_CODE` |
| 86 | `(无)` | `T.TRANS_AMT` |
| 87 | `(无)` | `T.TRANS_AMT_RMB` |
| 88 | `(无)` | `T.INT_RATE_TYPE` |
| 89 | `(无)` | `T.INT_RATE` |
| 90 | `(无)` | `T.FEE_AMT_RMB` |
| 91 | `(无)` | `T.GUAR_TYPE` |
| 92 | `(无)` | `T.TRUSTOR_DEPT_TYPE` |
| 93 | `(无)` | `T.TRUSTOR_ID_TYPE` |
| 94 | `(无)` | `T.TRUSTOR_ID_NO` |
| 95 | `(无)` | `T.TRUSTOR_BUSINSESS_TYPE` |
| 96 | `(无)` | `T.TRUSTOR_REG_AREA_CODE` |
| 97 | `(无)` | `T.TRUSTOR_CTRL_ECO_ELEM` |
| 98 | `(无)` | `T.TRUSTOR_ENT_SCALE` |
| 99 | `(无)` | `T.TRANS_TYPE` |
| 100 | `(无)` | `T.REPORT_ID` |
| 101 | `(无)` | `T.CJRQ` |
| 102 | `(无)` | `T.NBJGH` |
| 103 | `(无)` | `T.BIZ_LINE_ID` |
| 104 | `(无)` | `T.BSCJRQ` |
| 105 | `(无)` | `T.USEOFUNDS` |
| 106 | `(无)` | `T.SERIAL_NO` |
| 107 | `(无)` | `T.FRNBJGH` |
| 108 | `(无)` | `T.CUST_NAME` |
| 109 | `(无)` | `T.TRUSTOR_CUST_NAME` |
