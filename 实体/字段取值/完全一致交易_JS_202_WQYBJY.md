# 完全一致交易_JS_202_WQYBJY — 字段取值

> 来源程序: `bsp_sp_js_202_wqybjy.prc`

## 字段映射

| 序号 | 目标字段(alias) | 源表达式(expression) |
|------|----------------|---------------------|
| 1 | `(无)` | `T.USERNAME` |
| 2 | `(无)` | `COUNT(1)` |
| 3 | `(无)` | `A.DATA_DATE` |
| 4 | `TX_DT` | `CAST(A.TX_DT AS TEXT) AS TX_DT` |
| 5 | `(无)` | `A.KEY_TRANS_NO` |
| 6 | `(无)` | `a.sub_trans_no` |
| 7 | `(无)` | `A.REFERENCE_NUM` |
| 8 | `(无)` | `a.CD_TYPE` |
| 9 | `(无)` | `A.CURRENCY` |
| 10 | `(无)` | `a.tran_code` |
| 11 | `(无)` | `a.tran_code_describe` |
| 12 | `(无)` | `a.us_age` |
| 13 | `(无)` | `a.summary` |
| 14 | `(无)` | `a.tran_sts` |
| 15 | `(无)` | `a.trans_flg` |
| 16 | `(无)` | `a.ORG_NUM` |
| 17 | `(无)` | `A.CUST_ID` |
| 18 | `(无)` | `A.ACCOUNT_CODE` |
| 19 | `(无)` | `A.OPPO_ACCT_NUM` |
| 20 | `(无)` | `A.OPPO_ACCT_NAM` |
| 21 | `(无)` | `A.TRANS_AMT` |
| 22 | `OPPO_ACCT_NAM1` | `REPLACE(REPLACE(A.OPPO_ACCT_NAM, '吉林银行代发工资专户-', ''), '吉林银行其他代发-', '') AS OPPO_ACCT_NAM1` |
| 23 | `(无)` | `*` |
| 24 | `ACCT_NUM1` | `SUBSTRING(A.ACCT_NUM, 1, STR_POSITION(A.ACCT_NUM, '_') - 1) AS ACCT_NUM1` |
| 25 | `(无)` | `A.ACCT_NUM` |
| 26 | `(无)` | `A.PASSBOOK_ACCT_NUM` |
| 27 | `(无)` | `A.ACCT_NAM` |
| 28 | `(无)` | `A.ORG_NUM` |
| 29 | `(无)` | `A.FIRST_ISWAGES_DT` |
| 30 | `(无)` | `b.cust_nam` |
| 31 | `(无)` | `b.tyshxydm` |
| 32 | `(无)` | `REPLACE(b.organizationcode, '-', '')` |
| 33 | `(无)` | `b.id_no` |
| 34 | `(无)` | `b.id_type` |
| 35 | `zjhm` | `CASE WHEN NOT b.tyshxydm IS NULL AND NOT SUBSTRING(b.tyshxydm, 1, 1) IN ('B', 'G') THEN b.tyshxydm WHEN LENGTH(b.id_no) = 18 THEN b.id_no WHEN NOT b.organizationcode IS NULL THEN REPLACE(b.organizatio...` |
| 36 | `zjlx` | `CASE WHEN NOT b.tyshxydm IS NULL AND NOT SUBSTRING(b.tyshxydm, 1, 1) IN ('B', 'G') THEN 'A01' WHEN LENGTH(b.id_no) = 18 THEN 'A01' WHEN NOT b.organizationcode IS NULL THEN 'A02' ELSE 'A03' END AS zjlx` |
| 37 | `(无)` | `T.data_date` |
| 38 | `(无)` | `T.tx_dt` |
| 39 | `(无)` | `T.key_trans_no` |
| 40 | `(无)` | `T.sub_trans_no` |
| 41 | `(无)` | `T.reference_num` |
| 42 | `(无)` | `T.cd_type` |
| 43 | `(无)` | `T.currency` |
| 44 | `(无)` | `T.tran_code` |
| 45 | `(无)` | `T.tran_code_describe` |
| 46 | `(无)` | `T.us_age` |
| 47 | `(无)` | `T.summary` |
| 48 | `(无)` | `T.tran_sts` |
| 49 | `(无)` | `T.trans_flg` |
| 50 | `(无)` | `T.org_num` |
| 51 | `(无)` | `T.cust_id` |
| 52 | `(无)` | `A.CUST_NAM` |
| 53 | `(无)` | `A.id_no` |
| 54 | `(无)` | `A.id_type` |
| 55 | `(无)` | `t.account_code` |
| 56 | `(无)` | `t.oppo_acct_num` |
| 57 | `(无)` | `t.oppo_acct_nam` |
| 58 | `oppo_cust_id` | `B.CUST_ID AS oppo_cust_id` |
| 59 | `oppo_cust_nam` | `COALESCE(B1.CUST_NAM, B.CUST_NAM) AS oppo_cust_nam` |
| 60 | `oppo_TYSHXYDM` | `COALESCE(B1.ID_NO, B.TYSHXYDM) AS oppo_TYSHXYDM` |
| 61 | `oppo_ORGANIZATIONCODE` | `COALESCE(B1.ORGANIZATIONCODE, B.ORGANIZATIONCODE) AS oppo_ORGANIZATIONCODE` |
| 62 | `oppo_ID_NO` | `B.ZJHM AS oppo_ID_NO` |
| 63 | `oppo_ID_TYPE` | `CASE WHEN NOT B1.ID_NO IS NULL THEN 'A01' ELSE B.ZJLX END AS oppo_ID_TYPE` |
| 64 | `(无)` | `t.trans_amt` |
| 65 | `(无)` | `t.sfgr` |
| 66 | `DATA_DATE` | `IS_DATE AS DATA_DATE` |
| 67 | `ORG_CODE` | `A.ORG_NUM AS ORG_CODE` |
| 68 | `CUST_ID_TYPE` | `CASE WHEN NOT A.OPPO_TYSHXYDM IS NULL THEN 'A01' WHEN LENGTH(a.oppo_id_no) = 18 THEN 'A01' WHEN NOT A.OPPO_ORGANIZATIONCODE IS NULL THEN 'A02' ELSE A.OPPO_ID_TYPE END AS CUST_ID_TYPE` |
| 69 | `CUST_ID_NO` | `CASE WHEN NOT A.OPPO_TYSHXYDM IS NULL THEN A.OPPO_TYSHXYDM WHEN LENGTH(a.oppo_id_no) = 18 THEN a.oppo_id_no WHEN NOT A.OPPO_ORGANIZATIONCODE IS NULL THEN A.OPPO_ORGANIZATIONCODE ELSE A.OPPO_ID_NO END ...` |
| 70 | `(无)` | `TIME_TO_STR(STR_TO_DATE(D.SIGN_DATE, '%Y%m%d'), '%Y-%m-%d')` |
| 71 | `STAFF_ID_TYPE` | `F.PBOCD_CODE AS STAFF_ID_TYPE` |
| 72 | `STAFF_ID_NO` | `A.ID_NO AS STAFF_ID_NO` |
| 73 | `TRANS_DATE` | `TIME_TO_STR(STR_TO_DATE(A.TX_DT, 'yyyymmdd'), '%Y-%m-%d') AS TRANS_DATE` |
| 74 | `REPORT_ID` | `SYS_GUID() AS REPORT_ID` |
| 75 | `CJRQ` | `IS_DATE AS CJRQ` |
| 76 | `NBJGH` | `A.ORG_NUM AS NBJGH` |
| 77 | `BIZ_LINE_ID` | `'99' AS BIZ_LINE_ID` |
| 78 | `VERIFY_STATUS` | `'' AS VERIFY_STATUS` |
| 79 | `BSCJRQ` | `'' AS BSCJRQ` |
| 80 | `FRNBJGH` | `CASE WHEN A.ORG_NUM LIKE '51%' THEN '510000' WHEN A.ORG_NUM LIKE '52%' THEN '520000' WHEN A.ORG_NUM LIKE '53%' THEN '530000' WHEN A.ORG_NUM LIKE '54%' THEN '540000' WHEN A.ORG_NUM LIKE '55%' THEN '550...` |
| 81 | `SERIAL_NUM` | `A.KEY_TRANS_NO \|\| A.REFERENCE_NUM AS SERIAL_NUM` |
| 82 | `(无)` | `A.OPPO_CUST_ID` |
| 83 | `(无)` | `A.OPPO_CUST_NAM` |
| 84 | `DATA_DATE` | `VS_TEXT AS DATA_DATE` |
| 85 | `(无)` | `COALESCE(OB.ID_NO, OB.UP_ID_NO)` |
| 86 | `(无)` | `CUST_ID_TYPE` |
| 87 | `(无)` | `A.CUST_ID_NO` |
| 88 | `(无)` | `A.TRANS_BGN_DATE` |
| 89 | `(无)` | `A.STAFF_ID_TYPE` |
| 90 | `(无)` | `A.STAFF_ID_NO` |
| 91 | `(无)` | `A.TRANS_DATE` |
| 92 | `(无)` | `A.NBJGH` |
| 93 | `SERIAL_NUM` | `MAX(SERIAL_NUM) AS SERIAL_NUM` |
| 94 | `(无)` | `MAX(A.OPPO_ACCT_NUM)` |
| 95 | `(无)` | `MAX(A.OPPO_ACCT_NAM)` |
| 96 | `(无)` | `MAX(A.ACCOUNT_CODE)` |
| 97 | `(无)` | `MAX(A.CUST_ID)` |
| 98 | `(无)` | `MAX(A.CUST_NAM)` |
