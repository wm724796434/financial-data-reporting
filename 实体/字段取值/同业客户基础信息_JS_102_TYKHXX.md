# 同业客户基础信息_JS_102_TYKHXX — 字段取值

> 来源程序: `bsp_sp_js_102_tykhxx.prc`

## 字段映射

| 序号 | 目标字段(alias) | 源表达式(expression) |
|------|----------------|---------------------|
| 1 | `(无)` | `T.USERNAME` |
| 2 | `(无)` | `A.CUST_ID` |
| 3 | `(无)` | `COUNT(1)` |
| 4 | `(无)` | `DATA_DATE` |
| 5 | `(无)` | `ORG_CODE` |
| 6 | `(无)` | `CUST_NAME` |
| 7 | `(无)` | `CUST_ID_NO` |
| 8 | `(无)` | `CUST_ORG_ID` |
| 9 | `(无)` | `BASIC_ACCOUNT` |
| 10 | `(无)` | `BASIC_ACCOUNT_BANK` |
| 11 | `(无)` | `REG_REGION_CODE` |
| 12 | `(无)` | `CUST_TYPE` |
| 13 | `(无)` | `OPEN_DATE` |
| 14 | `(无)` | `RELATED_FLG` |
| 15 | `(无)` | `CUST_NO` |
| 16 | `(无)` | `REG_ADDRESS` |
| 17 | `(无)` | `CTRL_ECO_ELEM` |
| 18 | `(无)` | `CREDIT_RATE_NUM` |
| 19 | `(无)` | `CREDIT_RATING` |
| 20 | `(无)` | `CJRQ` |
| 21 | `(无)` | `NBJGH` |
| 22 | `(无)` | `DEPT_TYPE` |
| 23 | `(无)` | `FRNBJGH` |
| 24 | `(无)` | `ORG_NUM` |
| 25 | `(无)` | `CUST_ID` |
| 26 | `(无)` | `VS_TEXT` |
| 27 | `JRJGBM` | `CASE WHEN A.FRNBJGH = '510000' THEN '912202016601010854' WHEN A.FRNBJGH = '520000' THEN '91321000564261222Q' WHEN A.FRNBJGH = '530000' THEN '91220201584622304Y' WHEN A.FRNBJGH = '540000' THEN '9122010...` |
| 28 | `(无)` | `NVL2(BK.CUST_ID_NO, BK.CUST_NAME, A.CUST_NAME)` |
| 29 | `(无)` | `A.CUST_ID_NO` |
| 30 | `(无)` | `NVL2(BK.CUST_ID_NO, BK.CUST_ORG_ID, A.CUST_ORG_ID)` |
| 31 | `(无)` | `NVL2(BK.CUST_ID_NO, BK.BASIC_ACCOUNT, A.BASIC_ACCOUNT)` |
| 32 | `(无)` | `NVL2(BK.CUST_ID_NO, BK.BASIC_ACCOUNT_BANK, A.BASIC_ACCOUNT_BANK)` |
| 33 | `(无)` | `NVL2(BK.CUST_ID_NO, BK.REG_REGION_CODE, A.REG_REGION_CODE)` |
| 34 | `(无)` | `NVL2(BK.CUST_ID_NO, BK.CUST_TYPE, A.CUST_TYPE)` |
| 35 | `(无)` | `NVL2(BK.CUST_ID_NO, BK.OPEN_DATE, A.OPEN_DATE)` |
| 36 | `(无)` | `NVL2(BK.CUST_ID_NO, BK.RELATED_FLG, A.RELATED_FLG)` |
| 37 | `(无)` | `NVL2(BK.CUST_ID_NO, BK.CUST_NO, A.CUST_NO)` |
| 38 | `(无)` | `NVL2(BK.CUST_ID_NO, BK.REG_ADDRESS, A.REG_ADDRESS)` |
| 39 | `(无)` | `NVL2(BK.CUST_ID_NO, BK.CTRL_ECO_ELEM, A.CTRL_ECO_ELEM)` |
| 40 | `(无)` | `NVL2(BK.CUST_ID_NO, BK.CREDIT_RATE_NUM, A.CREDIT_RATE_NUM)` |
| 41 | `(无)` | `NVL2(BK.CUST_ID_NO, BK.CREDIT_RATING, A.CREDIT_RATING)` |
| 42 | `(无)` | `A.REPORT_ID` |
| 43 | `(无)` | `A.CJRQ` |
| 44 | `(无)` | `NVL2(BK.CUST_ID_NO, BK.NBJGH, A.NBJGH)` |
| 45 | `(无)` | `'99'` |
| 46 | `(无)` | `NVL2(BK.CUST_ID_NO, BK.DEPT_TYPE, A.DEPT_TYPE)` |
| 47 | `(无)` | `A.FRNBJGH` |
| 48 | `(无)` | `NVL2(BK.CUST_ID_NO, BK.ORG_NUM, A.ORG_NUM)` |
| 49 | `(无)` | `NVL2(BK.CUST_ID_NO, BK.CUST_ID, A.CUST_ID)` |
| 50 | `(无)` | `NVL2(BK.CUST_ID_NO, BK.CUST_ID_NO, A.CUST_ID_NO)` |
| 51 | `(无)` | `IS_DATE` |
| 52 | `(无)` | `BIZ_LINE_ID` |
| 53 | `(无)` | `CUST_NAME_SOURCE` |
| 54 | `(无)` | `CUST_ID_NO_SOURCE` |
