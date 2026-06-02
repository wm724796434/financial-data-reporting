# 再贴现发生额信息_JS_205_ZTXFS — 字段取值

> 来源程序: `bsp_sp_js_205_ztxfs.prc`

## 字段映射

| 序号 | 目标字段(alias) | 源表达式(expression) |
|------|----------------|---------------------|
| 1 | `(无)` | `T.USERNAME` |
| 2 | `ID` | `1 AS ID` |
| 3 | `(无)` | `T.data_date` |
| 4 | `(无)` | `T.org_code` |
| 5 | `(无)` | `T.org_num` |
| 6 | `(无)` | `T.reg_region_code` |
| 7 | `(无)` | `T.bill_num` |
| 8 | `(无)` | `T.bill_type` |
| 9 | `(无)` | `T.bill_medium` |
| 10 | `(无)` | `T.open_date` |
| 11 | `(无)` | `T.bill_due_date` |
| 12 | `(无)` | `T.discount_date` |
| 13 | `(无)` | `T.rediscount_due_date` |
| 14 | `(无)` | `T.trans_date` |
| 15 | `(无)` | `T.drawer_name` |
| 16 | `(无)` | `T.drawer_id_type` |
| 17 | `(无)` | `T.drawer_id_no` |
| 18 | `(无)` | `T.accept_name` |
| 19 | `(无)` | `T.accept_id_type` |
| 20 | `(无)` | `T.accept_id_no` |
| 21 | `(无)` | `T.bill_curr_code` |
| 22 | `(无)` | `T.bill_amt` |
| 23 | `(无)` | `T.bill_amt_rmb` |
| 24 | `(无)` | `T.rediscount_int_rate` |
| 25 | `(无)` | `T.rediscount_curr_code` |
| 26 | `(无)` | `T.rediscount_bal` |
| 27 | `(无)` | `T.rediscount_bal_rmb` |
| 28 | `(无)` | `T.report_id` |
| 29 | `(无)` | `T.cjrq` |
| 30 | `(无)` | `T.biz_line_id` |
| 31 | `(无)` | `T.verify_status` |
| 32 | `(无)` | `T.bscjrq` |
| 33 | `(无)` | `T.frnbjgh` |
| 34 | `(无)` | `T.nbjgh` |
| 35 | `DATA_DATE` | `VS_TEXT AS DATA_DATE` |
| 36 | `(无)` | `ORG_CODE` |
| 37 | `(无)` | `ORG_NUM` |
| 38 | `(无)` | `REG_REGION_CODE` |
| 39 | `(无)` | `BILL_NUM` |
| 40 | `(无)` | `BILL_TYPE` |
| 41 | `(无)` | `BILL_MEDIUM` |
| 42 | `(无)` | `OPEN_DATE` |
| 43 | `(无)` | `BILL_DUE_DATE` |
| 44 | `(无)` | `DISCOUNT_DATE` |
| 45 | `(无)` | `REDISCOUNT_DUE_DATE` |
| 46 | `(无)` | `TRANS_DATE` |
| 47 | `(无)` | `DRAWER_NAME` |
| 48 | `(无)` | `DRAWER_ID_TYPE` |
| 49 | `(无)` | `DRAWER_ID_NO` |
| 50 | `(无)` | `ACCEPT_NAME` |
| 51 | `(无)` | `ACCEPT_ID_TYPE` |
| 52 | `(无)` | `ACCEPT_ID_NO` |
| 53 | `(无)` | `BILL_CURR_CODE` |
| 54 | `(无)` | `BILL_AMT` |
| 55 | `(无)` | `BILL_AMT_RMB` |
| 56 | `(无)` | `REDISCOUNT_INT_RATE` |
| 57 | `(无)` | `REDISCOUNT_CURR_CODE` |
| 58 | `DISCOUNT_AMT` | `CASE WHEN ID = '1' THEN REDISCOUNT_BAL ELSE BILL_AMT END AS DISCOUNT_AMT` |
| 59 | `REDISCOUNT_BAL_RMB` | `CASE WHEN ID = '1' THEN REDISCOUNT_BAL_RMB ELSE BILL_AMT_RMB END AS REDISCOUNT_BAL_RMB` |
| 60 | `TRANS_TYPE` | `ID AS TRANS_TYPE` |
| 61 | `SERIAL_NO` | `SYS_GUID() AS SERIAL_NO` |
| 62 | `CJRQ` | `IS_DATE AS CJRQ` |
| 63 | `(无)` | `VS_TEXT` |
| 64 | `(无)` | `COALESCE(OB.ID_NO, OB.UP_ID_NO)` |
| 65 | `(无)` | `T.ORG_NUM` |
| 66 | `(无)` | `OB.REGION_CD` |
| 67 | `(无)` | `REDISCOUNT_AMT` |
| 68 | `(无)` | `REDISCOUNT_AMT_RMB` |
| 69 | `(无)` | `TRANS_TYPE` |
| 70 | `(无)` | `SERIAL_NO` |
| 71 | `report_id` | `SYS_GUID() AS report_id` |
| 72 | `(无)` | `IS_DATE` |
| 73 | `biz_line_id` | `CASE WHEN T.ORG_NUM LIKE '51%' THEN '99' WHEN T.ORG_NUM LIKE '52%' THEN '99' WHEN T.ORG_NUM LIKE '53%' THEN '99' WHEN T.ORG_NUM LIKE '54%' THEN '99' WHEN T.ORG_NUM LIKE '55%' THEN '99' WHEN T.ORG_NUM ...` |
| 74 | `(无)` | `verify_status` |
| 75 | `(无)` | `bscjrq` |
| 76 | `FRNBJGH` | `CASE WHEN T.ORG_NUM LIKE '51%' THEN '510000' WHEN T.ORG_NUM LIKE '52%' THEN '520000' WHEN T.ORG_NUM LIKE '53%' THEN '530000' WHEN T.ORG_NUM LIKE '54%' THEN '540000' WHEN T.ORG_NUM LIKE '55%' THEN '550...` |
| 77 | `nbjgh` | `T.ORG_NUM AS nbjgh` |
