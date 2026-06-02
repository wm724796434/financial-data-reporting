# JS_201_HDAKJDKFS — 字段取值

> 来源程序: `bsp_sp_js_201_hdakjdkfs.prc`

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
| 16 | `(无)` | `T1.item_cd` |
| 17 | `(无)` | `T1.discount_interest` |
| 18 | `(无)` | `T.loan_stocken_date` |
| 19 | `(无)` | `T.cancel_flg` |
| 20 | `(无)` | `T1.real_int_rat` |
| 21 | `(无)` | `T1.draft_rng` |
| 22 | `(无)` | `T1.indust_stg_type` |
| 23 | `(无)` | `T1.high_tech_mnft` |
| 24 | `(无)` | `T1.high_tech_srve` |
| 25 | `(无)` | `T1.pant_dens_indu` |
| 26 | `(无)` | `'直转'` |
| 27 | `DATA_DATE` | `VS_TEXT AS DATA_DATE` |
| 28 | `(无)` | `FIELD_TYPE` |
| 29 | `(无)` | `SUM(BALANCE_SUM)` |
| 30 | `(无)` | `SUM(INT_RATE_WA)` |
| 31 | `(无)` | `SUM(GET_LOAN_NUM)` |
| 32 | `REPORT_ID` | `SYS_GUID() AS REPORT_ID` |
| 33 | `CJRQ` | `IS_DATE AS CJRQ` |
| 34 | `(无)` | `NBJGH \|\| '0000'` |
| 35 | `BIZ_LINE_ID` | `'99' AS BIZ_LINE_ID` |
| 36 | `VERIFY_STATUS` | `NULL AS VERIFY_STATUS` |
| 37 | `BSCJRQ` | `IS_DATE AS BSCJRQ` |
| 38 | `(无)` | `'T13'` |
| 39 | `(无)` | `COALESCE(OB.ID_NO, OB.UP_ID_NO)` |
| 40 | `(无)` | `T.ORG_NUM` |
| 41 | `(无)` | `CASE WHEN B.BILL_NUM IS NULL THEN T.ACCT_NUM ELSE '0' END` |
| 42 | `(无)` | `CASE WHEN B.BILL_NUM IS NULL THEN T.LOAN_NUM ELSE '0' END` |
| 43 | `(无)` | `CASE WHEN NOT B.BILL_NUM IS NULL THEN T.ACCT_NUM \|\| T.DRAFT_RNG ELSE '0' END` |
| 44 | `(无)` | `NULL` |
| 45 | `(无)` | `CASE WHEN (t.ITEM_CD NOT LIKE '130102%' AND t.ITEM_CD NOT LIKE '130105%' AND ((COALESCE(C.HIGH_TECH_MNFT, '0') <> '0' AND T.ITEM_CD NOT LIKE '1301%') OR (SUBSTRING(T.HIGH_TECH_MNFT, 1, 2) IN ('01', '0...` |
| 46 | `(无)` | `CASE WHEN t.ITEM_CD NOT LIKE '130102%' AND t.ITEM_CD NOT LIKE '130105%' AND NOT t.ACCT_TYP IN ('C01', 'D01', 'E01', 'E02') AND T.FUND_USE_LOC_CD = 'I' AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE...` |
| 47 | `(无)` | `CASE WHEN CAST(T.DRAWDOWN_DT AS TEXT) = SUBSTRING(IS_DATE, 1, 6) AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%') AND T.ACCT_TYP NOT LIKE '90%' AND ((COALESCE(C.HIGH_TECH_SRVE, '0') <> '0' A...` |
| 48 | `(无)` | `CASE WHEN CAST(T.DRAWDOWN_DT AS TEXT) = SUBSTRING(IS_DATE, 1, 6) AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%') AND T.ACCT_TYP NOT LIKE '90%' AND SUBSTRING(M2.HYDL, 1, 3) = 'HTS' THEN M2.H...` |
| 49 | `(无)` | `CASE WHEN CAST(T.DRAWDOWN_DT AS TEXT) = SUBSTRING(IS_DATE, 1, 6) AND T.ACCT_TYP NOT LIKE '90%' AND ((T.INDUST_STG_TYPE = '1' AND (T.LOAN_PURPOSE_CD IN (SELECT DISTINCT LOAN_PURPOSE_CD FROM SMTMODS.INT...` |
| 50 | `(无)` | `CASE WHEN CAST(T.DRAWDOWN_DT AS TEXT) = SUBSTRING(IS_DATE, 1, 6) AND T.ACCT_TYP NOT LIKE '90%' AND ((T.INDUST_STG_TYPE = '1' AND (T.LOAN_PURPOSE_CD IN (SELECT DISTINCT LOAN_PURPOSE_CD FROM SMTMODS.INT...` |
| 51 | `(无)` | `CASE WHEN ((T.FUND_USE_LOC_CD = 'I' AND T.ACCT_TYP NOT LIKE '0301%' AND T.ACCT_TYP NOT LIKE '90%' AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%') AND LENGTHB(T.ACCT_NUM) < 36 AND T.ACCT_TYP...` |
| 52 | `(无)` | `CASE WHEN ((T.FUND_USE_LOC_CD = 'I' AND T.ACCT_TYP NOT LIKE '0301%' AND T.ACCT_TYP NOT LIKE '90%' AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%') AND LENGTHB(T.ACCT_NUM) < 36 AND T.ACCT_TYP...` |
| 53 | `(无)` | `'1'` |
| 54 | `(无)` | `CASE WHEN B.BILL_NUM IS NULL THEN 'C01' ELSE 'C03' END` |
| 55 | `NBJGH` | `T.ORG_NUM AS NBJGH` |
| 56 | `FRNBJGH` | `CASE WHEN T.ORG_NUM LIKE '51%' THEN '510000' WHEN T.ORG_NUM LIKE '52%' THEN '520000' WHEN T.ORG_NUM LIKE '53%' THEN '530000' WHEN T.ORG_NUM LIKE '54%' THEN '540000' WHEN T.ORG_NUM LIKE '55%' THEN '550...` |
| 57 | `(无)` | `T.CUST_ID` |
| 58 | `(无)` | `A2.CUST_NAM` |
| 59 | `(无)` | `T.LOAN_ACCT_BAL` |
| 60 | `(无)` | `T.CURR_CD` |
| 61 | `(无)` | `T.LOAN_ACCT_BAL * U.CCY_RATE` |
| 62 | `(无)` | `T.DRAWDOWN_AMT` |
| 63 | `(无)` | `T.DISCOUNT_INTEREST` |
