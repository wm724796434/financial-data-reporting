# JS_201_HDAYLDKFS — 字段取值

> 来源程序: `bsp_sp_js_201_hdayldkfs.prc`

## 字段映射

| 序号 | 目标字段(alias) | 源表达式(expression) |
|------|----------------|---------------------|
| 1 | `(无)` | `T1.data_date` |
| 2 | `(无)` | `T1.acct_num` |
| 3 | `(无)` | `T1.loan_num` |
| 4 | `(无)` | `T1.book_type` |
| 5 | `(无)` | `T1.acct_typ` |
| 6 | `(无)` | `T1.cust_id` |
| 7 | `(无)` | `T1.curr_cd` |
| 8 | `(无)` | `T.acct_sts` |
| 9 | `(无)` | `T.org_num` |
| 10 | `(无)` | `T.drawdown_dt` |
| 11 | `(无)` | `T.FINISH_DT` |
| 12 | `(无)` | `T1.drawdown_amt` |
| 13 | `(无)` | `T1.fund_use_loc_cd` |
| 14 | `(无)` | `T1.loan_purpose_cd` |
| 15 | `(无)` | `T.loan_acct_bal` |
| 16 | `(无)` | `T.INT_ADJEST_AMT` |
| 17 | `(无)` | `T1.item_cd` |
| 18 | `(无)` | `T1.discount_interest` |
| 19 | `(无)` | `T.loan_stocken_date` |
| 20 | `(无)` | `T.cancel_flg` |
| 21 | `(无)` | `T1.real_int_rat` |
| 22 | `(无)` | `T1.draft_rng` |
| 23 | `(无)` | `T1.indust_stg_type` |
| 24 | `(无)` | `T1.high_tech_mnft` |
| 25 | `(无)` | `T1.high_tech_srve` |
| 26 | `(无)` | `T1.pant_dens_indu` |
| 27 | `(无)` | `T1.PENSION_INDUSTRY` |
| 28 | `(无)` | `'直转'` |
| 29 | `DATA_DATE` | `VS_TEXT AS DATA_DATE` |
| 30 | `(无)` | `FIELD_TYPE` |
| 31 | `(无)` | `SUM(BALANCE_SUM)` |
| 32 | `(无)` | `SUM(INT_RATE_WA)` |
| 33 | `(无)` | `SUM(GET_LOAN_NUM)` |
| 34 | `REPORT_ID` | `SYS_GUID() AS REPORT_ID` |
| 35 | `CJRQ` | `IS_DATE AS CJRQ` |
| 36 | `(无)` | `NBJGH \|\| '0000'` |
| 37 | `BIZ_LINE_ID` | `'99' AS BIZ_LINE_ID` |
| 38 | `VERIFY_STATUS` | `NULL AS VERIFY_STATUS` |
| 39 | `BSCJRQ` | `IS_DATE AS BSCJRQ` |
| 40 | `(无)` | `'T99'` |
| 41 | `(无)` | `COALESCE(OB.ID_NO, OB.UP_ID_NO)` |
| 42 | `(无)` | `T.ORG_NUM` |
| 43 | `(无)` | `CASE WHEN NOT SUBSTRING(T.ITEM_CD, 1, 6) IN ('130101', '130104') THEN T.ACCT_NUM ELSE '0' END` |
| 44 | `(无)` | `CASE WHEN NOT SUBSTRING(T.ITEM_CD, 1, 6) IN ('130101', '130104') THEN T.LOAN_NUM ELSE '0' END` |
| 45 | `(无)` | `CASE WHEN SUBSTRING(T.ITEM_CD, 1, 6) IN ('130101', '130104') THEN T.ACCT_NUM \|\| T.DRAFT_RNG ELSE '0' END` |
| 46 | `(无)` | `'1'` |
| 47 | `(无)` | `'EC' \|\| SUBSTRING(D.PENSION_INDUSTRY, 1, 2)` |
| 48 | `(无)` | `CASE WHEN NOT F.LOAN_NUM IS NULL THEN '1' ELSE '0' END` |
| 49 | `(无)` | `CASE WHEN T.ACCT_TYP LIKE '01%' OR C.CUST_TYP = '3' THEN 'C02' WHEN SUBSTRING(T.ITEM_CD, 1, 4) IN ('1303', '1305', '1306') THEN 'C01' WHEN SUBSTRING(T.ITEM_CD, 1, 6) IN ('130101', '130104') THEN 'C03'...` |
| 50 | `NBJGH` | `T.ORG_NUM AS NBJGH` |
| 51 | `FRNBJGH` | `CASE WHEN T.ORG_NUM LIKE '51%' THEN '510000' WHEN T.ORG_NUM LIKE '52%' THEN '520000' WHEN T.ORG_NUM LIKE '53%' THEN '530000' WHEN T.ORG_NUM LIKE '54%' THEN '540000' WHEN T.ORG_NUM LIKE '55%' THEN '550...` |
| 52 | `(无)` | `T.CUST_ID` |
| 53 | `(无)` | `A2.CUST_NAM` |
| 54 | `(无)` | `T.LOAN_ACCT_BAL` |
| 55 | `(无)` | `T.CURR_CD` |
| 56 | `(无)` | `T.LOAN_ACCT_BAL * U.CCY_RATE` |
| 57 | `(无)` | `T.DRAWDOWN_AMT` |
| 58 | `(无)` | `T.DISCOUNT_INTEREST` |
