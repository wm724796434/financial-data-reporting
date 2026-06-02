# 金融机构（分支机构）基础信息_JS_101_JRJGFZ — 字段取值

> 来源程序: `bsp_sp_js_101_jrjgfz.prc`

## 字段映射

| 序号 | 目标字段(alias) | 源表达式(expression) |
|------|----------------|---------------------|
| 1 | `(无)` | `T.USERNAME` |
| 2 | `(无)` | `VS_TEXT` |
| 3 | `(无)` | `A.ORG_NAM` |
| 4 | `(无)` | `COALESCE(A.ID_NO, B.ID_NO)` |
| 5 | `(无)` | `COALESCE(A.ACCOUNTBANK, B.ACCOUNTBANK)` |
| 6 | `(无)` | `A.ORG_NUM` |
| 7 | `(无)` | `CASE WHEN A.ORG_TYP = '0' THEN '01' WHEN A.ORG_TYP = '2' THEN '02' WHEN A.ORG_TYP IN ('3', '1', '4') THEN '03' ELSE '99' END` |
| 8 | `(无)` | `B.ORG_NAM` |
| 9 | `(无)` | `B.ACCOUNTBANK` |
| 10 | `(无)` | `B.ORG_NUM` |
| 11 | `(无)` | `A.ORG_ADD` |
| 12 | `(无)` | `A.REGION_CD` |
| 13 | `(无)` | `CAST(A.BEGAN_TIME AS TEXT)` |
| 14 | `(无)` | `COALESCE(A.BUSI_STATE, '99')` |
| 15 | `(无)` | `A.FIN_LIN_NUM` |
| 16 | `(无)` | `COALESCE(A.BANK_CD, B.BANK_CD)` |
| 17 | `REPORT_ID` | `SYS_GUID() AS REPORT_ID` |
| 18 | `CJRQ` | `IS_DATE AS CJRQ` |
| 19 | `NBJGH` | `A.ORG_NUM AS NBJGH` |
| 20 | `BIZ_LINE_ID` | `'99' AS BIZ_LINE_ID` |
| 21 | `VERIFY_STATUS` | `'' AS VERIFY_STATUS` |
| 22 | `BSCJRQ` | `'' AS BSCJRQ` |
| 23 | `FRNBJGH` | `CASE WHEN A.ORG_NUM LIKE '51%' THEN '510000' WHEN A.ORG_NUM LIKE '52%' THEN '520000' WHEN A.ORG_NUM LIKE '53%' THEN '530000' WHEN A.ORG_NUM LIKE '54%' THEN '540000' WHEN A.ORG_NUM LIKE '55%' THEN '550...` |
