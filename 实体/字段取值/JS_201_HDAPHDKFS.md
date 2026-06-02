# JS_201_HDAPHDKFS — 字段取值

> 来源程序: `bsp_sp_js_201_hdaphdkfs.prc`

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
| 27 | `(无)` | `T1.UNDERTAK_GUAR_TYPE` |
| 28 | `(无)` | `'直转'` |
| 29 | `(无)` | `T.CUST_ID` |
| 30 | `(无)` | `T.OPERATE_CUST_TYPE` |
| 31 | `(无)` | `A.ACCT_NUM` |
| 32 | `(无)` | `A.LOAN_NUM` |
| 33 | `FLAG` | `'1XW' AS FLAG` |
| 34 | `FLAG` | `CASE WHEN B.OPERATE_CUST_TYPE = 'A' THEN '2GTJY' WHEN B.OPERATE_CUST_TYPE = 'B' THEN '3XWJY' END AS FLAG` |
| 35 | `FLAG` | `'4NHJY' AS FLAG` |
| 36 | `DATA_DATE` | `VS_TEXT AS DATA_DATE` |
| 37 | `(无)` | `FIELD_TYPE` |
| 38 | `(无)` | `SUM(BALANCE_SUM)` |
| 39 | `(无)` | `SUM(INT_RATE_WA)` |
| 40 | `(无)` | `SUM(GET_LOAN_NUM)` |
| 41 | `REPORT_ID` | `SYS_GUID() AS REPORT_ID` |
| 42 | `CJRQ` | `IS_DATE AS CJRQ` |
| 43 | `(无)` | `NBJGH \|\| '0000'` |
| 44 | `BIZ_LINE_ID` | `'99' AS BIZ_LINE_ID` |
| 45 | `VERIFY_STATUS` | `NULL AS VERIFY_STATUS` |
| 46 | `BSCJRQ` | `IS_DATE AS BSCJRQ` |
| 47 | `(无)` | `COALESCE(OB.ID_NO, OB.UP_ID_NO)` |
| 48 | `(无)` | `T.ORG_NUM` |
| 49 | `(无)` | `CASE WHEN NOT SUBSTRING(t.ITEM_CD, 1, 6) IN ('130101', '130104') THEN T.ACCT_NUM ELSE '0' END` |
| 50 | `(无)` | `CASE WHEN NOT SUBSTRING(t.ITEM_CD, 1, 6) IN ('130101', '130104') THEN T.LOAN_NUM ELSE '0' END` |
| 51 | `(无)` | `CASE WHEN SUBSTRING(t.ITEM_CD, 1, 6) IN ('130101', '130104') THEN CASE WHEN IS_DATE < '20240331' THEN T.ACCT_NUM ELSE T.ACCT_NUM \|\| T.DRAFT_RNG END ELSE '0' END` |
| 52 | `(无)` | `'1'` |
| 53 | `(无)` | `CASE WHEN NOT XW.LOAN_NUM IS NULL THEN '1' ELSE '0' END` |
| 54 | `(无)` | `CASE WHEN NOT GTJY.LOAN_NUM IS NULL THEN '1' ELSE '0' END` |
| 55 | `(无)` | `CASE WHEN NOT XWJY.LOAN_NUM IS NULL THEN '1' ELSE '0' END` |
| 56 | `(无)` | `CASE WHEN NOT NHJY.LOAN_NUM IS NULL THEN '1' ELSE '0' END` |
| 57 | `(无)` | `CASE WHEN NOT CYDB.LOAN_NUM IS NULL THEN '1' ELSE '0' END` |
| 58 | `(无)` | `'0'` |
| 59 | `POVERTY_LOAN_FLG` | `NULL AS POVERTY_LOAN_FLG` |
| 60 | `(无)` | `CASE WHEN T.ACCT_TYP LIKE '01%' OR C1.CUST_TYP = '3' THEN 'C02' WHEN SUBSTRING(T.ITEM_CD, 1, 4) IN ('1303', '1305', '1306') AND NOT GTJY.LOAN_NUM IS NULL THEN 'C02' WHEN SUBSTRING(T.ITEM_CD, 1, 4) IN ...` |
| 61 | `NBJGH` | `T.ORG_NUM AS NBJGH` |
| 62 | `FRNBJGH` | `CASE WHEN T.ORG_NUM LIKE '51%' THEN '510000' WHEN T.ORG_NUM LIKE '52%' THEN '520000' WHEN T.ORG_NUM LIKE '53%' THEN '530000' WHEN T.ORG_NUM LIKE '54%' THEN '540000' WHEN T.ORG_NUM LIKE '55%' THEN '550...` |
| 63 | `(无)` | `A2.CUST_NAM` |
| 64 | `(无)` | `T.LOAN_ACCT_BAL` |
| 65 | `(无)` | `T.CURR_CD` |
| 66 | `(无)` | `T.LOAN_ACCT_BAL * U.CCY_RATE` |
| 67 | `(无)` | `T.DRAWDOWN_AMT` |
| 68 | `(无)` | `T.DISCOUNT_INTEREST` |
| 69 | `FIELD_TYPE` | `'T99' AS FIELD_TYPE` |
