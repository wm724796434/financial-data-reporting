# 存款客户核对_JS_202_HDACLHLCK — 字段取值

> 来源程序: `bsp_sp_js_202_hdaclhlck.prc`

## 字段映射

| 序号 | 目标字段(alias) | 源表达式(expression) |
|------|----------------|---------------------|
| 1 | `(无)` | `T.USERNAME` |
| 2 | `DATA_DATE` | `VS_TEXT AS DATA_DATE` |
| 3 | `(无)` | `COALESCE(OB.ID_NO, OB.UP_ID_NO)` |
| 4 | `(无)` | `T.ORG_NUM` |
| 5 | `(无)` | `T1.O_ACCT_NUM` |
| 6 | `(无)` | `DECODE(SUBSTRING(T.TYPE_ID, 1, 8), '62313118', 'D01', '62313113', 'D03')` |
| 7 | `(无)` | `DECODE(SUBSTRING(T.TYPE_ID, 1, 8), '62313118', '9122010170255776XN', '62313113', '91220102MA176CR29P')` |
| 8 | `REPORT_ID` | `SYS_GUID() AS REPORT_ID` |
| 9 | `CJRQ` | `IS_DATE AS CJRQ` |
| 10 | `NBJGH` | `T.ORG_NUM AS NBJGH` |
| 11 | `BIZ_LINE_ID` | `'99' AS BIZ_LINE_ID` |
| 12 | `VERIFY_STATUS` | `NULL AS VERIFY_STATUS` |
| 13 | `BSCJRQ` | `IS_DATE AS BSCJRQ` |
| 14 | `FRNBJGH` | `CASE WHEN T.ORG_NUM LIKE '51%' THEN '510000' WHEN T.ORG_NUM LIKE '52%' THEN '520000' WHEN T.ORG_NUM LIKE '53%' THEN '530000' WHEN T.ORG_NUM LIKE '54%' THEN '540000' WHEN T.ORG_NUM LIKE '55%' THEN '550...` |
| 15 | `(无)` | `T.CUST_ID` |
| 16 | `(无)` | `P.CUST_NAM` |
| 17 | `(无)` | `T1.ACCT_BALANCE` |
