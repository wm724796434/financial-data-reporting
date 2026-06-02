# 银行承兑汇票发生额信息_JS_205_YHCDFS — 字段取值

> 来源程序: `bsp_sp_js_205_yhcdfs.prc`

## 字段映射

| 序号 | 目标字段(alias) | 源表达式(expression) |
|------|----------------|---------------------|
| 1 | `(无)` | `T.USERNAME` |
| 2 | `ID` | `'01' AS ID` |
| 3 | `(无)` | `T.DATA_DATE` |
| 4 | `(无)` | `T.ORG_CODE` |
| 5 | `(无)` | `T.ORG_NUM` |
| 6 | `(无)` | `T.REG_REGION_CODE` |
| 7 | `(无)` | `T.DRAWER_NAME` |
| 8 | `(无)` | `T.DRAWER_ID_TYPE` |
| 9 | `(无)` | `T.DRAWER_ID_NO` |
| 10 | `(无)` | `T.DRAWER_INDUSTRY_TYPE` |
| 11 | `(无)` | `T.DRAWER_AREA_CODE` |
| 12 | `(无)` | `T.DRAWER_CON_ECO_ELEM` |
| 13 | `(无)` | `T.DRAWER_ENT_SCALE` |
| 14 | `(无)` | `T.RECE_NAME` |
| 15 | `(无)` | `T.RECE_ID_TYPE` |
| 16 | `(无)` | `T.RECE_ID_NO` |
| 17 | `(无)` | `T.BILL_NUM` |
| 18 | `(无)` | `T.BILL_MEDIUM` |
| 19 | `(无)` | `T.OPEN_DATE` |
| 20 | `(无)` | `T.BILL_DUE_DATE` |
| 21 | `(无)` | `T.BILL_CURR_CODE` |
| 22 | `(无)` | `T.BILL_AMT` |
| 23 | `(无)` | `T.BILL_AMT_RMB` |
| 24 | `(无)` | `T.FEE_AMT_RMB` |
| 25 | `(无)` | `T.MARGIN_RATIO` |
| 26 | `(无)` | `T.GUAR_TYPE` |
| 27 | `(无)` | `T.REPORT_ID` |
| 28 | `(无)` | `T.CJRQ` |
| 29 | `(无)` | `T.BIZ_LINE_ID` |
| 30 | `(无)` | `T.VERIFY_STATUS` |
| 31 | `(无)` | `T.BSCJRQ` |
| 32 | `(无)` | `T.FRNBJGH` |
| 33 | `(无)` | `T.NBJGH` |
| 34 | `(无)` | `COUNT(1)` |
| 35 | `DATA_DATE` | `VS_TEXT AS DATA_DATE` |
| 36 | `(无)` | `A.ORG_CODE` |
| 37 | `(无)` | `A.ORG_NUM` |
| 38 | `(无)` | `A.REG_REGION_CODE` |
| 39 | `(无)` | `A.DRAWER_NAME` |
| 40 | `(无)` | `A.DRAWER_ID_TYPE` |
| 41 | `(无)` | `A.DRAWER_ID_NO` |
| 42 | `(无)` | `A.DRAWER_INDUSTRY_TYPE` |
| 43 | `(无)` | `A.DRAWER_AREA_CODE` |
| 44 | `(无)` | `A.DRAWER_CON_ECO_ELEM` |
| 45 | `(无)` | `A.DRAWER_ENT_SCALE` |
| 46 | `(无)` | `A.RECE_NAME` |
| 47 | `(无)` | `A.RECE_ID_TYPE` |
| 48 | `(无)` | `A.RECE_ID_NO` |
| 49 | `(无)` | `A.BILL_NUM` |
| 50 | `(无)` | `A.BILL_MEDIUM` |
| 51 | `(无)` | `A.OPEN_DATE` |
| 52 | `(无)` | `A.BILL_DUE_DATE` |
| 53 | `TRANS_DATE` | `CASE WHEN ID = '01' THEN A.OPEN_DATE ELSE CASE WHEN SUBSTRING(REPLACE(A.BILL_DUE_DATE, '-'), 1, 6) = SUBSTRING(IS_DATE, 1, 6) THEN A.BILL_DUE_DATE ELSE TIME_TO_STR(STR_TO_DATE(LOAN.DATA_DATE, '%Y%m%d'...` |
| 54 | `(无)` | `A.BILL_CURR_CODE` |
| 55 | `TRANS_AMT` | `A.BILL_AMT AS TRANS_AMT` |
| 56 | `TRANS_AMT_RMB` | `A.BILL_AMT_RMB AS TRANS_AMT_RMB` |
| 57 | `(无)` | `A.FEE_AMT_RMB` |
| 58 | `(无)` | `COALESCE(A.MARGIN_RATIO, 0)` |
| 59 | `TRANS_TYPE` | `A.ID AS TRANS_TYPE` |
| 60 | `ADVANCES_AMT_RMB` | `COALESCE(C.DRAWDOWN_AMT * R.CCY_RATE, 0) AS ADVANCES_AMT_RMB` |
| 61 | `SERIAL_NO` | `SYS_GUID() AS SERIAL_NO` |
| 62 | `(无)` | `A.GUAR_TYPE` |
| 63 | `REPORT_ID` | `SYS_GUID() AS REPORT_ID` |
| 64 | `CJRQ` | `IS_DATE AS CJRQ` |
| 65 | `(无)` | `A.BIZ_LINE_ID` |
| 66 | `VERIFY_STATUS` | `'' AS VERIFY_STATUS` |
| 67 | `(无)` | `A.BSCJRQ` |
| 68 | `(无)` | `A.FRNBJGH` |
| 69 | `(无)` | `A.NBJGH` |
| 70 | `(无)` | `VS_TEXT` |
| 71 | `JRJGBM` | `'' AS JRJGBM` |
| 72 | `AREA_ID` | `'' AS AREA_ID` |
| 73 | `(无)` | `B.AFF_NAME` |
| 74 | `(无)` | `''` |
| 75 | `(无)` | `NVL2(D.CUST_ID, '100', SUBSTRB(TRIM(F.CORP_BUSINSESS_TYPE), 0, 3))` |
| 76 | `(无)` | `NVL2(D.CUST_ID, D.REGION_CD, F.REGION_CD)` |
| 77 | `(无)` | `CD4.PBOCD_CODE` |
| 78 | `(无)` | `NVL2(F.CUST_ID, DECODE(F.CORP_SCALE, 'B', 'CS01', 'M', 'CS02', 'S', 'CS03', 'T', 'CS04', 'CS05'), '')` |
| 79 | `(无)` | `B.RECE_NAME` |
| 80 | `(无)` | `'A01'` |
| 81 | `(无)` | `B.RECE_ID_NO` |
| 82 | `(无)` | `A.ACCT_NUM` |
| 83 | `BILL_MEDIUM` | `CASE WHEN B.IS_P_BILL = 'Y' THEN '01' ELSE '02' END AS BILL_MEDIUM` |
| 84 | `(无)` | `CAST(B.OPEN_DATE AS TEXT)` |
| 85 | `(无)` | `CAST(B.MATU_DATE AS TEXT)` |
| 86 | `(无)` | `TRIM(B.CURR_CD)` |
| 87 | `(无)` | `A.TRAN_AMT` |
| 88 | `(无)` | `A.TRAN_AMT * R.CCY_RATE` |
| 89 | `(无)` | `(A.TRAN_AMT * R.CCY_RATE) / 10000 * 5` |
| 90 | `(无)` | `COALESCE(A.SECURITY_RATE, 0) * 100` |
| 91 | `(无)` | `'01'` |
| 92 | `GURT_TYPE` | `CASE WHEN DBFS.CN >= 2 AND NOT DBW.BUSINESSCODE IS NULL THEN 'E01' WHEN H.MAIN_GUARANTY_TYP = '1' AND NOT DBW.BUSINESSCODE IS NULL THEN 'B01' WHEN DBFS.CN >= 2 THEN 'E' WHEN H.MAIN_GUARANTY_TYP = '1' ...` |
| 93 | `BIZ_LINE_ID` | `'' AS BIZ_LINE_ID` |
| 94 | `BSCJRQ` | `'' AS BSCJRQ` |
| 95 | `FRNBJGH` | `'' AS FRNBJGH` |
| 96 | `NBJGH` | `A.ORG_NUM AS NBJGH` |
| 97 | `(无)` | `'02'` |
| 98 | `(无)` | `COALESCE(OB.ID_NO, OB.UP_ID_NO)` |
| 99 | `(无)` | `OB.REGION_CD` |
| 100 | `(无)` | `DRAWER_NAME` |
| 101 | `(无)` | `DRAWER_ID_TYPE` |
| 102 | `(无)` | `DRAWER_ID_NO` |
| 103 | `(无)` | `DRAWER_INDUSTRY_TYPE` |
| 104 | `(无)` | `DRAWER_AREA_CODE` |
| 105 | `(无)` | `DRAWER_CON_ECO_ELEM` |
| 106 | `(无)` | `DRAWER_ENT_SCALE` |
| 107 | `(无)` | `RECE_NAME` |
| 108 | `(无)` | `RECE_ID_TYPE` |
| 109 | `(无)` | `RECE_ID_NO` |
| 110 | `(无)` | `BILL_NUM` |
| 111 | `(无)` | `BILL_MEDIUM` |
| 112 | `(无)` | `OPEN_DATE` |
| 113 | `(无)` | `BILL_DUE_DATE` |
| 114 | `(无)` | `TRANS_DATE` |
| 115 | `(无)` | `BILL_CURR_CODE` |
| 116 | `(无)` | `TRANS_AMT` |
| 117 | `(无)` | `TRANS_AMT_RMB` |
| 118 | `(无)` | `FEE_AMT_RMB` |
| 119 | `(无)` | `MARGIN_RATIO` |
| 120 | `(无)` | `TRANS_TYPE` |
| 121 | `(无)` | `ADVANCES_AMT_RMB` |
| 122 | `(无)` | `SERIAL_NO` |
| 123 | `(无)` | `GUAR_TYPE` |
| 124 | `(无)` | `SYS_GUID()` |
| 125 | `(无)` | `IS_DATE` |
| 126 | `BIZ_LINE_ID` | `CASE WHEN T.ORG_NUM LIKE '51%' THEN '99' WHEN T.ORG_NUM LIKE '52%' THEN '99' WHEN T.ORG_NUM LIKE '53%' THEN '99' WHEN T.ORG_NUM LIKE '54%' THEN '99' WHEN T.ORG_NUM LIKE '55%' THEN '99' WHEN T.ORG_NUM ...` |
| 127 | `FRNBJGH` | `CASE WHEN T.ORG_NUM LIKE '51%' THEN '510000' WHEN T.ORG_NUM LIKE '52%' THEN '520000' WHEN T.ORG_NUM LIKE '53%' THEN '530000' WHEN T.ORG_NUM LIKE '54%' THEN '540000' WHEN T.ORG_NUM LIKE '55%' THEN '550...` |
