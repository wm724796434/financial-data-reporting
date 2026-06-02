# 存贷款客户核对_JS_201_HDACLHLDK — 字段取值

> 来源程序: `bsp_sp_js_201_hdaclhldk.prc`

## 字段映射

| 序号 | 目标字段(alias) | 源表达式(expression) |
|------|----------------|---------------------|
| 1 | `DATA_DATE` | `VS_TEXT AS DATA_DATE` |
| 2 | `(无)` | `COALESCE(OB.ID_NO, OB.UP_ID_NO)` |
| 3 | `(无)` | `T.ORG_NUM` |
| 4 | `(无)` | `T.LOAN_NUM` |
| 5 | `(无)` | `T.ACCT_NUM` |
| 6 | `(无)` | `'2'` |
| 7 | `(无)` | `'L02'` |
| 8 | `(无)` | `'9122010170255776XN'` |
| 9 | `(无)` | `'吉林银行股份有限公司'` |
| 10 | `(无)` | `100 - (C.CONTRI_RATIO * 100)` |
| 11 | `REPORT_ID` | `SYS_GUID() AS REPORT_ID` |
| 12 | `CJRQ` | `IS_DATE AS CJRQ` |
| 13 | `NBJGH` | `T.ORG_NUM AS NBJGH` |
| 14 | `BIZ_LINE_ID` | `'99' AS BIZ_LINE_ID` |
| 15 | `VERIFY_STATUS` | `NULL AS VERIFY_STATUS` |
| 16 | `BSCJRQ` | `IS_DATE AS BSCJRQ` |
| 17 | `FRNBJGH` | `CASE WHEN T.ORG_NUM LIKE '51%' THEN '510000' WHEN T.ORG_NUM LIKE '52%' THEN '520000' WHEN T.ORG_NUM LIKE '53%' THEN '530000' WHEN T.ORG_NUM LIKE '54%' THEN '540000' WHEN T.ORG_NUM LIKE '55%' THEN '550...` |
| 18 | `(无)` | `T.CUST_ID` |
| 19 | `(无)` | `P.CUST_NAM` |
| 20 | `(无)` | `T.LOAN_ACCT_BAL` |
| 21 | `(无)` | `T.DATA_DATE` |
| 22 | `(无)` | `T.ORG_CODE` |
| 23 | `(无)` | `T.INT_LOAN_ID` |
| 24 | `(无)` | `T.CONTRACT_CODE` |
| 25 | `(无)` | `T.INT_LOAN_PRTFUN` |
| 26 | `(无)` | `T.INT_LOAN_CHA` |
| 27 | `(无)` | `T.INT_LOAN_IDND` |
| 28 | `(无)` | `T.INT_LOAN_PRTID` |
| 29 | `(无)` | `T.INT_LOAN_CONTR` |
| 30 | `(无)` | `T.REPORT_ID` |
| 31 | `(无)` | `T.CJRQ` |
| 32 | `(无)` | `T.NBJGH` |
| 33 | `(无)` | `T.BIZ_LINE_ID` |
| 34 | `(无)` | `T.VERIFY_STATUS` |
| 35 | `(无)` | `T.BSCJRQ` |
| 36 | `(无)` | `T.FRNBJGH` |
| 37 | `(无)` | `T.CUST_NAME` |
