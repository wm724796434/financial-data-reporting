# 存量银行承兑汇票信息_JS_205_CLYHCD — 字段取值

> 来源程序: `bsp_sp_js_205_clyhcd.prc`

## 字段映射

| 序号 | 目标字段(alias) | 源表达式(expression) |
|------|----------------|---------------------|
| 1 | `(无)` | `T.USERNAME` |
| 2 | `(无)` | `T4.CONTRACT_NUM` |
| 3 | `(无)` | `''` |
| 4 | `(无)` | `COUNT(1)` |
| 5 | `DATA_DATE` | `VS_TEXT AS DATA_DATE` |
| 6 | `JRJGBM` | `COALESCE(OB.ID_NO, OB.UP_ID_NO) AS JRJGBM` |
| 7 | `(无)` | `A.ORG_NUM` |
| 8 | `AREA_ID` | `OB.REGION_CD AS AREA_ID` |
| 9 | `(无)` | `B.AFF_NAME` |
| 10 | `(无)` | `'A01'` |
| 11 | `(无)` | `F1.ID_NO` |
| 12 | `(无)` | `NVL2(D.CUST_ID, '100', SUBSTRB(TRIM(F.CORP_BUSINSESS_TYPE), 0, 3))` |
| 13 | `(无)` | `NVL2(D.CUST_ID, D.REGION_CD, F.REGION_CD)` |
| 14 | `(无)` | `CD4.PBOCD_CODE` |
| 15 | `(无)` | `NVL2(F.CUST_ID, DECODE(F.CORP_SCALE, 'B', 'CS01', 'M', 'CS02', 'S', 'CS03', 'T', 'CS04', 'CS05'), '')` |
| 16 | `(无)` | `B.RECE_NAME` |
| 17 | `(无)` | `B.RECE_ID_NO` |
| 18 | `(无)` | `A.ACCT_NUM` |
| 19 | `BILL_MEDIUM` | `CASE WHEN B.IS_P_BILL = 'Y' THEN '01' ELSE '02' END AS BILL_MEDIUM` |
| 20 | `(无)` | `CAST(B.OPEN_DATE AS TEXT)` |
| 21 | `(无)` | `CAST(B.MATU_DATE AS TEXT)` |
| 22 | `(无)` | `TRIM(B.CURR_CD)` |
| 23 | `(无)` | `A.BALANCE` |
| 24 | `(无)` | `A.BALANCE * R.CCY_RATE` |
| 25 | `(无)` | `(A.BALANCE * R.CCY_RATE) / 10000 * 5` |
| 26 | `(无)` | `COALESCE(A.SECURITY_RATE, 0) * 100` |
| 27 | `GURT_TYPE` | `CASE WHEN DBFS.CN >= 2 AND NOT DBW.BUSINESSCODE IS NULL THEN 'E01' WHEN H.MAIN_GUARANTY_TYP = '1' AND NOT DBW.BUSINESSCODE IS NULL THEN 'B01' WHEN DBFS.CN >= 2 THEN 'E' WHEN H.MAIN_GUARANTY_TYP = '1' ...` |
| 28 | `REPORT_ID` | `SYS_GUID() AS REPORT_ID` |
| 29 | `CJRQ` | `IS_DATE AS CJRQ` |
| 30 | `BIZ_LINE_ID` | `CASE WHEN A.ORG_NUM LIKE '51%' THEN '99' WHEN A.ORG_NUM LIKE '52%' THEN '99' WHEN A.ORG_NUM LIKE '53%' THEN '99' WHEN A.ORG_NUM LIKE '54%' THEN '99' WHEN A.ORG_NUM LIKE '55%' THEN '99' WHEN A.ORG_NUM ...` |
| 31 | `FRNBJGH` | `CASE WHEN A.ORG_NUM LIKE '51%' THEN '510000' WHEN A.ORG_NUM LIKE '52%' THEN '520000' WHEN A.ORG_NUM LIKE '53%' THEN '530000' WHEN A.ORG_NUM LIKE '54%' THEN '540000' WHEN A.ORG_NUM LIKE '55%' THEN '550...` |
| 32 | `NBJGH` | `A.ORG_NUM AS NBJGH` |
