# JS_102_TYKHXX_ALL — 取数范围

> 来源程序: `bsp_sp_js_102_tykhxx_all.prc`

## 数据源表（FROM）


## 关联条件（JOIN）


## 筛选条件（WHERE）

1. `CJRQ = VS_LAST_TEXT`
2. `A.CJRQ = VS_LAST_TEXT`
3. `EXISTS(SELECT 1 FROM JS_102_TYKHXX_TMP1 AS B WHERE A.CUST_ID_NO = B.CUST_ID_NO AND A.FRNBJGH = B.FRNBJGH)`
4. `RN = 1`
