# 单位贷款发生额信息_JS_201_DWDKFS — 字段取值

> 来源程序: `bsp_sp_js_201_dwdkfs.prc`
> 解析日期: 2026-05-28 19:50:31

```json
{
  "file": "源码解析/加工层存储/bsp_sp_js_201_dwdkfs.prc",
  "entity": "单位贷款发生额信息_JS_201_DWDKFS",
  "parse_date": "2026-05-28 19:50:31",
  "data_extractions": [
    {
      "label": "放款数据（贷款发放 - INSERT INTO 主SELECT）",
      "source_line": 105,
      "type": "SELECT",
      "field_count": 38,
      "field_mappings": [
        {
          "expression": "IS_DATE AS DATA_DATE",
          "alias": "DATA_DATE"
        },
        {
          "expression": "''",
          "alias": null
        },
        {
          "expression": "A.ORG_NUM AS ORG_NUM",
          "alias": "ORG_NUM"
        },
        {
          "expression": "''",
          "alias": null
        },
        {
          "expression": "D1.PBOCD_CODE AS CUST_ID_TYPE",
          "alias": "CUST_ID_TYPE"
        },
        {
          "expression": "CASE WHEN D1.PBOCD_CODE = 'A02' THEN REPLACE(C.ID_NO, '-') ELSE C.ID_NO END AS CUST_ID_NO",
          "alias": "CUST_ID_NO"
        },
        {
          "expression": "CASE WHEN C.CUST_TYP <> '5' THEN C.DEPT_TYPE ELSE 'A04' END AS DEPT_TYPE",
          "alias": "DEPT_TYPE"
        },
        {
          "expression": "SUBSTRB(TRIM(C.CORP_BUSINSESS_TYPE), 0, 3) AS INDUSTRY_TYPE",
          "alias": "INDUSTRY_TYPE"
        },
        {
          "expression": "COALESCE(REPLACE(C.REGION_CD, '待治理', ''), C.ORG_AREA)",
          "alias": null
        },
        {
          "expression": "DECODE(C.CORP_HOLD_TYPE, 'A01', 'A0102', 'A02', 'A0101', 'B01', 'A0202', 'B02', 'A0201', 'C01', 'B0102', 'C02', 'B0101', 'D01', 'B0202', 'D02', 'B0201', 'E01', 'B0302', 'E02', 'B0301') AS ENT_CON_ECO_ELEM",
          "alias": "ENT_CON_ECO_ELEM"
        },
        {
          "expression": "CASE WHEN SUBSTRING(C.CUST_TYP, 1, 1) IN ('1', '0') OR C.CUST_TYP = '9101' THEN CASE WHEN C.CORP_SCALE = 'B' THEN 'CS01' WHEN C.CORP_SCALE = 'M' THEN 'CS02' WHEN C.CORP_SCALE = 'S' THEN 'CS03' WHEN C.CORP_SCALE = 'T' THEN 'CS04' ELSE 'CS05' END ELSE 'CS05' END AS ENT_SCALE",
          "alias": "ENT_SCALE"
        },
        {
          "expression": "A.LOAN_NUM AS LOAN_NUM",
          "alias": "LOAN_NUM"
        },
        {
          "expression": "A.ACCT_NUM AS CONTRACT_CODE",
          "alias": "CONTRACT_CODE"
        },
        {
          "expression": "CASE WHEN A.LOAN_NUM IN ('01260120001203330801', '01260120001203330802', '01260120001203330803', '02100119001190853001') THEN 'F12' WHEN (A.ITEM_CD LIKE '1305%' AND A.CURR_CD <> 'CNY') THEN 'F081' WHEN (A.ITEM_CD LIKE '1305%' AND A.CURR_CD = 'CNY') THEN 'F082' WHEN (A.ACCT_TYP = '0202' AND A.USEOFUNDS LIKE '%并购%') THEN 'F12' WHEN (A.ACCT_TYP = '0202' AND A.loan_business_typ = '1') OR (A.ACCT_TYP LIKE '0202%' AND Q.PROD_NAME IN ('商业房开发贷款', '法人商用房按揭贷款(企业名)')) OR (A.ACCT_TYP = '0202' AND Q.PROD_NAME IN ('银团贷款(牵头行)', '银团贷款(参与行)', '票据置换')) THEN 'F023' WHEN A.ACCT_TYP LIKE '0101%' THEN 'F0211' WHEN A.ACCT_TYP = '010301' THEN 'F0212' WHEN A.ACCT_TYP IN ('010402', '010403', '010404') THEN 'F02131' WHEN A.ACCT_TYP IN ('010401', '010405', '010499') THEN 'F02132' WHEN A.ACCT_TYP = '010399' THEN 'F0219' WHEN A.ACCT_TYP = '0202' OR A.ACCT_TYP LIKE '0102%' OR (A.ACCT_TYP = '070101' AND A.ONLENDING_USAGE = 'A') THEN 'F022' WHEN A.ACCT_TYP LIKE '0201%' OR (A.ACCT_TYP = '070101' AND A.ONLENDING_USAGE = 'B') THEN 'F023' WHEN A.ACCT_TYP = '0801' THEN 'F041' WHEN A.ACCT_TYP = '05' THEN 'F09' WHEN A.ACCT_TYP = '0203' OR (A.ACCT_TYP = '070101' AND A.ONLENDING_USAGE = 'C') THEN 'F12' WHEN SUBSTRING(A.ITEM_CD, 1, 4) IN ('1306') THEN CASE WHEN A.ACCT_TYP = '0901' THEN 'F052' WHEN A.ACCT_TYP = '0903' THEN 'F051' WHEN A.ACCT_TYP = '0904' THEN 'F053' WHEN A.ACCT_TYP = '0999' THEN 'F059' END END AS PRODUCT_TYPE",
          "alias": "PRODUCT_TYPE"
        },
        {
          "expression": "CASE WHEN B.INLANDORRSHORE_FLG = 'Y' THEN SUBSTRING(A.LOAN_PURPOSE_CD, 1, 4) WHEN B.INLANDORRSHORE_FLG = 'N' THEN '2000' END AS LOAN_PURPOSE_CD",
          "alias": "LOAN_PURPOSE_CD"
        },
        {
          "expression": "CASE WHEN A.LOAN_BUY_INT = 'N' THEN CAST(A.DRAWDOWN_DT AS TEXT) WHEN A.LOAN_BUY_INT = 'Y' THEN CAST(A.IN_DRAWDOWN_DT AS TEXT) END AS LOAN_GRANT_DATE",
          "alias": "LOAN_GRANT_DATE"
        },
        {
          "expression": "CAST(A.MATURITY_DT AS TEXT) AS LOAN_DUE_DATE",
          "alias": "LOAN_DUE_DATE"
        },
        {
          "expression": "CAST(A.FINISH_DT AS TEXT) AS DEFER_END_DATE",
          "alias": "DEFER_END_DATE"
        },
        {
          "expression": "A.CURR_CD AS CURR_CODE",
          "alias": "CURR_CODE"
        },
        {
          "expression": "A.DRAWDOWN_AMT AS TRANS_AMT",
          "alias": "TRANS_AMT"
        },
        {
          "expression": "CASE WHEN A.CURR_CD = 'CNY' THEN COALESCE(A.DRAWDOWN_AMT, 0) ELSE COALESCE(A.DRAWDOWN_AMT, 0) * U.CCY_RATE END AS TRANS_AMT_RMB",
          "alias": "TRANS_AMT_RMB"
        },
        {
          "expression": "CASE WHEN A.INT_RATE_TYP = 'F' THEN 'RF01' WHEN A.INT_RATE_TYP LIKE 'L%' THEN 'RF02' END AS INT_RATE_TYPE",
          "alias": "INT_RATE_TYPE"
        },
        {
          "expression": "A.DRAWDOWN_REAL_INT_RAT AS INT_RATE",
          "alias": "INT_RATE"
        },
        {
          "expression": "CASE WHEN A.PRICING_BASE_TYPE = 'A01' THEN 'TR01' WHEN A.PRICING_BASE_TYPE = 'A0201' THEN 'TR02' WHEN A.PRICING_BASE_TYPE = 'A0202' THEN 'TR03' WHEN A.PRICING_BASE_TYPE = 'A0203' THEN 'TR04' WHEN A.PRICING_BASE_TYPE = 'C' THEN 'TR05' WHEN A.PRICING_BASE_TYPE = 'D' THEN 'TR06' WHEN A.PRICING_BASE_TYPE = 'B01' THEN 'TR07' WHEN A.PRICING_BASE_TYPE = 'B02' THEN 'TR08' WHEN A.PRICING_BASE_TYPE = 'E' THEN 'TR09' ELSE 'TR99' END AS PRI_BENCH_MARK",
          "alias": "PRI_BENCH_MARK"
        },
        {
          "expression": "CASE WHEN A.INT_RATE_TYP = 'F' THEN NULL ELSE A.BASE_INT_RAT END AS BASE_INT_RAT",
          "alias": "BASE_INT_RAT"
        },
        {
          "expression": "CASE WHEN A.COMP_INT_TYP = '110' THEN 'A0101' WHEN A.COMP_INT_TYP = '120' THEN 'A0102' WHEN A.COMP_INT_TYP = '210' THEN 'A0201' WHEN A.COMP_INT_TYP = '220' THEN 'A0202' WHEN A.COMP_INT_TYP = '300' THEN 'B' WHEN A.COMP_INT_TYP = '500' THEN 'C' WHEN A.COMP_INT_TYP = '400' THEN 'Z' END AS FINA_SUPPORT_FLG",
          "alias": "FINA_SUPPORT_FLG"
        },
        {
          "expression": "CASE WHEN A.INT_RATE_TYP = 'F' AND A.EXTENDTERM_FLG = 'Y' THEN CAST(A.ACTUAL_MATURITY_DT AS TEXT) WHEN A.INT_RATE_TYP = 'F' THEN CAST(A.MATURITY_DT AS TEXT) WHEN A.NEXT_REPRICING_DT < A.DRAWDOWN_DT THEN CAST(A.DRAWDOWN_DT AS TEXT) WHEN A.NEXT_REPRICING_DT > A.ACTUAL_MATURITY_DT THEN CAST(A.ACTUAL_MATURITY_DT AS TEXT) ELSE COALESCE(CAST(A.NEXT_REPRICING_DT AS TEXT), CAST(A.ACTUAL_MATURITY_DT AS TEXT)) END AS INT_REPRICE_DATE",
          "alias": "INT_REPRICE_DATE"
        },
        {
          "expression": "TP7.GUAR_TYPE AS GUAR_TYPE",
          "alias": "GUAR_TYPE"
        },
        {
          "expression": "CASE WHEN LA.RN = 1 THEN '1' WHEN LA.RN >= 2 THEN '0' END AS FIRST_LOAN_FLG",
          "alias": "FIRST_LOAN_FLG"
        },
        {
          "expression": "CASE WHEN A.LOAN_BUY_INT = 'Y' THEN 'LF04' WHEN A.LOAN_KIND_CD = '91' THEN 'LF05' ELSE 'LF01' END AS LOAN_STATUS",
          "alias": "LOAN_STATUS"
        },
        {
          "expression": "NULL AS ASS_SEC_PRO_TYPE",
          "alias": "ASS_SEC_PRO_TYPE"
        },
        {
          "expression": "CASE WHEN A.LOAN_KIND_CD = '91' THEN CASE WHEN A.RENEW_FLG = 'Y' THEN '01' WHEN A.REPAY_FLG = 'Y' THEN '02' WHEN A.RESCHED_FLG = 'Y' THEN '09' END END AS LOAN_TYPE",
          "alias": "LOAN_TYPE"
        },
        {
          "expression": "'1' AS TRANS_TYPE",
          "alias": "TRANS_TYPE"
        },
        {
          "expression": "'1' AS SERIAL_NO",
          "alias": "SERIAL_NO"
        },
        {
          "expression": "REGEXP_REPLACE(REGEXP_REPLACE(A.USEOFUNDS, '[!?^？！ |]'), CHR(9)) AS USEOFUNDS",
          "alias": "USEOFUNDS"
        },
        {
          "expression": "COALESCE(CASE WHEN A.ORG_NUM LIKE '51%' THEN '99' WHEN A.ORG_NUM LIKE '52%' THEN '99' WHEN A.ORG_NUM LIKE '53%' THEN '99' WHEN A.ORG_NUM LIKE '54%' THEN '99' WHEN A.ORG_NUM LIKE '55%' THEN '99' WHEN A.ORG_NUM LIKE '56%' THEN '99' WHEN A.ORG_NUM LIKE '57%' THEN '99' WHEN A.ORG_NUM LIKE '58%' THEN '99' WHEN A.ORG_NUM LIKE '59%' THEN '99' WHEN A.ORG_NUM LIKE '60%' THEN '99' WHEN A.DEPARTMENTD = '公司金融' THEN 'E' WHEN A.DEPARTMENTD = '普惠金融' THEN 'S' WHEN A.DEPARTMENTD = '个人信贷' THEN 'P' WHEN A.DEPARTMENTD = '德惠长银' THEN 'E' END, '99') AS BIZ_LINE_ID",
          "alias": "BIZ_LINE_ID"
        },
        {
          "expression": "C.CUST_NAM",
          "alias": null
        },
        {
          "expression": "A.cust_id",
          "alias": null
        }
      ]
    },
    {
      "label": "还款数据（贷款收回 - 子SELECT）",
      "source_line": 478,
      "type": "SELECT",
      "field_count": 38,
      "field_mappings": [
        {
          "expression": "IS_DATE AS DATA_DATE",
          "alias": "DATA_DATE"
        },
        {
          "expression": "''",
          "alias": null
        },
        {
          "expression": "D.ORG_NUM AS ORG_NUM",
          "alias": "ORG_NUM"
        },
        {
          "expression": "''",
          "alias": null
        },
        {
          "expression": "D1.PBOCD_CODE AS CUST_ID_TYPE",
          "alias": "CUST_ID_TYPE"
        },
        {
          "expression": "CASE WHEN D1.PBOCD_CODE = 'A02' THEN REPLACE(C.ID_NO, '-') ELSE C.ID_NO END AS CUST_ID_NO",
          "alias": "CUST_ID_NO"
        },
        {
          "expression": "CASE WHEN C.CUST_TYP <> '5' THEN C.DEPT_TYPE ELSE 'A04' END AS DEPT_TYPE",
          "alias": "DEPT_TYPE"
        },
        {
          "expression": "SUBSTRING(C.CORP_BUSINSESS_TYPE, 1, 3) AS INDUSTRY_TYPE",
          "alias": "INDUSTRY_TYPE"
        },
        {
          "expression": "COALESCE(REPLACE(C.REGION_CD, '待治理', ''), C.ORG_AREA) AS REG_AREA_CODE",
          "alias": "REG_AREA_CODE"
        },
        {
          "expression": "DECODE(C.CORP_HOLD_TYPE, 'A01', 'A0102', 'A02', 'A0101', 'B01', 'A0202', 'B02', 'A0201', 'C01', 'B0102', 'C02', 'B0101', 'D01', 'B0202', 'D02', 'B0201', 'E01', 'B0302', 'E02', 'B0301') AS ENT_CON_ECO_ELEM",
          "alias": "ENT_CON_ECO_ELEM"
        },
        {
          "expression": "CASE WHEN SUBSTRING(C.CUST_TYP, 1, 1) IN ('1', '0') OR C.CUST_TYP = '9101' THEN CASE WHEN C.CORP_SCALE = 'B' THEN 'CS01' WHEN C.CORP_SCALE = 'M' THEN 'CS02' WHEN C.CORP_SCALE = 'S' THEN 'CS03' WHEN C.CORP_SCALE = 'T' THEN 'CS04' ELSE 'CS05' END END AS ENT_SCALE",
          "alias": "ENT_SCALE"
        },
        {
          "expression": "A.LOAN_NUM AS LOAN_NUM",
          "alias": "LOAN_NUM"
        },
        {
          "expression": "A.ACCT_NUM AS CONTRACT_CODE",
          "alias": "CONTRACT_CODE"
        },
        {
          "expression": "CASE WHEN D.LOAN_NUM IN ('01260120001203330801', '01260120001203330802', '01260120001203330803', '02100119001190853001') THEN 'F12' WHEN (D.ITEM_CD LIKE '1305%' AND D.CURR_CD <> 'CNY') THEN 'F081' WHEN (D.ITEM_CD LIKE '1305%' AND D.CURR_CD = 'CNY') THEN 'F082' WHEN (D.ACCT_TYP = '0202' AND D.USEOFUNDS LIKE '%并购%') THEN 'F12' WHEN (D.ACCT_TYP = '0202' AND D.loan_business_typ = '1') OR (D.ACCT_TYP LIKE '0202%' AND Q.PROD_NAME IN ('商业房开发贷款', '法人商用房按揭贷款(企业名)')) OR (D.ACCT_TYP = '0202' AND Q.PROD_NAME IN ('银团贷款(牵头行)', '银团贷款(参与行)', '票据置换')) THEN 'F023' WHEN D.ACCT_TYP LIKE '0101%' THEN 'F0211' WHEN D.ACCT_TYP = '010301' THEN 'F0212' WHEN D.ACCT_TYP IN ('010402', '010403', '010404') THEN 'F02131' WHEN D.ACCT_TYP IN ('010401', '010405', '010499') THEN 'F02132' WHEN D.ACCT_TYP = '010399' THEN 'F0219' WHEN D.ACCT_TYP = '0202' OR D.ACCT_TYP LIKE '0102%' OR (D.ACCT_TYP = '070101' AND D.ONLENDING_USAGE = 'A') THEN 'F022' WHEN D.ACCT_TYP LIKE '0201%' OR (D.ACCT_TYP = '070101' AND D.ONLENDING_USAGE = 'B') THEN 'F023' WHEN D.ACCT_TYP = '0801' THEN 'F041' WHEN D.ACCT_TYP = '05' THEN 'F09' WHEN D.ACCT_TYP = '0203' OR (D.ACCT_TYP = '070101' AND D.ONLENDING_USAGE = 'C') THEN 'F12' WHEN SUBSTRING(D.ITEM_CD, 1, 4) IN ('1306') THEN CASE WHEN D.ACCT_TYP = '0901' THEN 'F052' WHEN D.ACCT_TYP = '0903' THEN 'F051' WHEN D.ACCT_TYP = '0904' THEN 'F053' WHEN D.ACCT_TYP = '0999' THEN 'F059' END END AS PRODUCT_TYPE",
          "alias": "PRODUCT_TYPE"
        },
        {
          "expression": "CASE WHEN B.INLANDORRSHORE_FLG = 'Y' THEN SUBSTRING(D.LOAN_PURPOSE_CD, 1, 4) WHEN B.INLANDORRSHORE_FLG = 'N' THEN '2000' END AS LOAN_PURPOSE_CD",
          "alias": "LOAN_PURPOSE_CD"
        },
        {
          "expression": "CASE WHEN D.LOAN_BUY_INT = 'N' THEN CAST(D.DRAWDOWN_DT AS TEXT) WHEN D.LOAN_BUY_INT = 'Y' THEN CAST(D.IN_DRAWDOWN_DT AS TEXT) END AS LOAN_GRANT_DATE",
          "alias": "LOAN_GRANT_DATE"
        },
        {
          "expression": "CAST(D.MATURITY_DT AS TEXT) AS LOAN_DUE_DATE",
          "alias": "LOAN_DUE_DATE"
        },
        {
          "expression": "CASE WHEN A.RN = 1 THEN CAST(D.FINISH_DT AS TEXT) ELSE '' END AS LOAN_ACTUAL_DUE_DATE",
          "alias": "LOAN_ACTUAL_DUE_DATE"
        },
        {
          "expression": "D.CURR_CD AS CURR_CODE",
          "alias": "CURR_CODE"
        },
        {
          "expression": "ABS(A.PAY_AMT) AS TRANS_AMT",
          "alias": "TRANS_AMT"
        },
        {
          "expression": "CASE WHEN D.CURR_CD = 'CNY' THEN ABS(COALESCE(A.PAY_AMT, 0)) ELSE ABS(COALESCE(A.PAY_AMT, 0)) * U.CCY_RATE END AS TRANS_AMT_RMB",
          "alias": "TRANS_AMT_RMB"
        },
        {
          "expression": "CASE WHEN D.INT_RATE_TYP = 'F' THEN 'RF01' WHEN D.INT_RATE_TYP LIKE 'L%' THEN 'RF02' END AS INT_RATE_TYPE",
          "alias": "INT_RATE_TYPE"
        },
        {
          "expression": "CASE WHEN NOT A.REPAY_REAL_INT_RAT IS NULL AND A.REPAY_REAL_INT_RAT <> 0 THEN A.REPAY_REAL_INT_RAT ELSE D.REAL_INT_RAT END AS INT_RATE",
          "alias": "INT_RATE"
        },
        {
          "expression": "CASE WHEN D.PRICING_BASE_TYPE = 'A01' THEN 'TR01' WHEN D.PRICING_BASE_TYPE = 'A0201' THEN 'TR02' WHEN D.PRICING_BASE_TYPE = 'A0202' THEN 'TR03' WHEN D.PRICING_BASE_TYPE = 'A0203' THEN 'TR04' WHEN D.PRICING_BASE_TYPE = 'C' THEN 'TR05' WHEN D.PRICING_BASE_TYPE = 'D' THEN 'TR06' WHEN D.PRICING_BASE_TYPE = 'B01' THEN 'TR07' WHEN D.PRICING_BASE_TYPE = 'B02' THEN 'TR08' WHEN D.PRICING_BASE_TYPE = 'E' THEN 'TR09' ELSE 'TR99' END AS PRI_BENCH_MARK",
          "alias": "PRI_BENCH_MARK"
        },
        {
          "expression": "CASE WHEN D.INT_RATE_TYP = 'F' THEN NULL ELSE D.BASE_INT_RAT END AS BASE_INT_RAT",
          "alias": "BASE_INT_RAT"
        },
        {
          "expression": "CASE WHEN D.COMP_INT_TYP = '110' THEN 'A0101' WHEN D.COMP_INT_TYP = '120' THEN 'A0102' WHEN D.COMP_INT_TYP = '210' THEN 'A0201' WHEN D.COMP_INT_TYP = '220' THEN 'A0202' WHEN D.COMP_INT_TYP = '300' THEN 'B' WHEN D.COMP_INT_TYP = '500' THEN 'C' WHEN D.COMP_INT_TYP = '400' THEN 'Z' END AS FINA_SUPPORT_FLG",
          "alias": "FINA_SUPPORT_FLG"
        },
        {
          "expression": "CASE WHEN D.INT_RATE_TYP = 'F' AND D.EXTENDTERM_FLG = 'Y' THEN CAST(D.ACTUAL_MATURITY_DT AS TEXT) WHEN D.INT_RATE_TYP = 'F' THEN CAST(D.MATURITY_DT AS TEXT) WHEN D.NEXT_REPRICING_DT < D.DRAWDOWN_DT THEN CAST(D.DRAWDOWN_DT AS TEXT) WHEN D.NEXT_REPRICING_DT > D.ACTUAL_MATURITY_DT THEN CAST(D.ACTUAL_MATURITY_DT AS TEXT) ELSE COALESCE(CAST(D.NEXT_REPRICING_DT AS TEXT), CAST(D.ACTUAL_MATURITY_DT AS TEXT)) END AS INT_REPRICE_DATE",
          "alias": "INT_REPRICE_DATE"
        },
        {
          "expression": "TP7.GUAR_TYPE AS GUAR_TYPE",
          "alias": "GUAR_TYPE"
        },
        {
          "expression": "CASE WHEN LA.RN = 1 THEN '1' WHEN LA.RN >= 2 THEN '0' END AS FIRST_LOAN_FLG",
          "alias": "FIRST_LOAN_FLG"
        },
        {
          "expression": "CASE WHEN A.PAY_TYPE IN ('01', '02', '03', '07', '09') THEN 'LF01' WHEN A.PAY_TYPE = '08' THEN 'LF02' WHEN A.PAY_TYPE = '05' THEN 'LF03' WHEN A.PAY_TYPE = '11' THEN 'LF04' WHEN A.PAY_TYPE IN ('04', '12') THEN 'LF05' WHEN A.PAY_TYPE = '06' THEN 'LF06' WHEN A.ABS_TRANS_FLG = 'Y' THEN 'LF07' WHEN A.PAY_TYPE = '10' THEN 'LF08' ELSE 'LF99' END AS LOAN_STATUS",
          "alias": "LOAN_STATUS"
        },
        {
          "expression": "NULL AS ASS_SEC_PRO_TYPE",
          "alias": "ASS_SEC_PRO_TYPE"
        },
        {
          "expression": "CASE WHEN A.PAY_TYPE IN ('04', '12') THEN CASE WHEN A.RENEW_FLG = 'Y' THEN '01' WHEN A.PAY_TYPE = '12' THEN '02' WHEN A.PAY_TYPE = '04' THEN '09' END END AS LOAN_TYPE",
          "alias": "LOAN_TYPE"
        },
        {
          "expression": "CASE WHEN A.PAY_AMT < 0 THEN '1' ELSE '0' END AS TRANS_TYPE",
          "alias": "TRANS_TYPE"
        },
        {
          "expression": "A.TX_NO AS SERIAL_NO",
          "alias": "SERIAL_NO"
        },
        {
          "expression": "REGEXP_REPLACE(REGEXP_REPLACE(D.USEOFUNDS, '[!?^？！ |]'), CHR(9)) AS USEOFUNDS",
          "alias": "USEOFUNDS"
        },
        {
          "expression": "COALESCE(CASE WHEN D.ORG_NUM LIKE '5100%' THEN '99' WHEN D.DEPARTMENTD = '公司金融' THEN 'E' WHEN D.DEPARTMENTD = '普惠金融' THEN 'S' WHEN D.DEPARTMENTD = '个人信贷' THEN 'P' WHEN D.DEPARTMENTD = '德惠长银' THEN 'E' END, '99') AS BIZ_LINE_ID",
          "alias": "BIZ_LINE_ID"
        },
        {
          "expression": "D.CUST_ID",
          "alias": null
        },
        {
          "expression": "C.CUST_NAM",
          "alias": null
        }
      ]
    },
    {
      "label": "line 856",
      "source_line": 856,
      "type": "SELECT",
      "field_count": 2,
      "field_mappings": [
        {
          "expression": "T.SERIAL_NO",
          "alias": null
        },
        {
          "expression": "COUNT(1)",
          "alias": null
        }
      ]
    },
    {
      "label": "中间表汇总（从JS_201_DWDKFS取数）",
      "source_line": 917,
      "type": "SELECT",
      "field_count": 44,
      "field_mappings": [
        {
          "expression": "VS_TEXT AS DATA_DATE",
          "alias": "DATA_DATE"
        },
        {
          "expression": "T.ORG_CODE",
          "alias": null
        },
        {
          "expression": "T.ORG_NUM",
          "alias": null
        },
        {
          "expression": "T.ORG_AREA_COD",
          "alias": null
        },
        {
          "expression": "T.CUST_ID_TYPE",
          "alias": null
        },
        {
          "expression": "T.CUST_ID_NO",
          "alias": null
        },
        {
          "expression": "T.DEPT_TYPE",
          "alias": null
        },
        {
          "expression": "T.INDUSTRY_TYPE",
          "alias": null
        },
        {
          "expression": "T.REG_AREA_CODE AS REG_AREA_CODE",
          "alias": "REG_AREA_CODE"
        },
        {
          "expression": "T.ENT_CON_ECO_ELEM",
          "alias": null
        },
        {
          "expression": "T.ENT_SCALE",
          "alias": null
        },
        {
          "expression": "T.LOAN_NUM",
          "alias": null
        },
        {
          "expression": "T.CONTRACT_CODE",
          "alias": null
        },
        {
          "expression": "T.PRODUCT_TYPE",
          "alias": null
        },
        {
          "expression": "T.LOAN_PURPOSE_CD",
          "alias": null
        },
        {
          "expression": "T.LOAN_GRANT_DATE",
          "alias": null
        },
        {
          "expression": "T.LOAN_DUE_DATE",
          "alias": null
        },
        {
          "expression": "CASE WHEN DATE_TRUNC('MM', STR_TO_DATE(T.LOAN_GRANT_DATE, '%Y-%m-%d')) = DATE_TRUNC('MM', STR_TO_DATE(LOAN_ACTUAL_DUE_DATE, '%Y-%m-%d')) AND T.TRANS_TYPE = '1' AND DATE_TRUNC('MM', STR_TO_DATE(LOAN_ACTUAL_DUE_DATE, '%Y-%m-%d')) = DATE_TRUNC('MM', STR_TO_DATE(IS_DATE, '%Y%m%d')) THEN '' ELSE T.LOAN_ACTUAL_DUE_DATE END",
          "alias": null
        },
        {
          "expression": "T.CURR_CODE",
          "alias": null
        },
        {
          "expression": "T.TRANS_AMT",
          "alias": null
        },
        {
          "expression": "T.TRANS_AMT_RMB",
          "alias": null
        },
        {
          "expression": "T.INT_RATE_TYPE",
          "alias": null
        },
        {
          "expression": "T.INT_RATE",
          "alias": null
        },
        {
          "expression": "T.PRI_BENCH_MARK",
          "alias": null
        },
        {
          "expression": "T.BASE_INT_RAT",
          "alias": null
        },
        {
          "expression": "T.FINA_SUPPORT_FLG",
          "alias": null
        },
        {
          "expression": "T.INT_REPRICE_DATE",
          "alias": null
        },
        {
          "expression": "T.GUAR_TYPE",
          "alias": null
        },
        {
          "expression": "T.FIRST_LOAN_FLG",
          "alias": null
        },
        {
          "expression": "CASE WHEN T.LOAN_STATUS = 'LF05' THEN 'LF01' ELSE T.LOAN_STATUS END",
          "alias": null
        },
        {
          "expression": "ASS_SEC_PRO_TYPE",
          "alias": null
        },
        {
          "expression": "CASE WHEN T.LOAN_STATUS = 'LF05' THEN NULL ELSE LOAN_TYPE END",
          "alias": null
        },
        {
          "expression": "T.TRANS_TYPE",
          "alias": null
        },
        {
          "expression": "T.SERIAL_NO",
          "alias": null
        },
        {
          "expression": "T.USEOFUNDS AS USEOFUNDS",
          "alias": "USEOFUNDS"
        },
        {
          "expression": "SYS_GUID() AS REPORT_ID",
          "alias": "REPORT_ID"
        },
        {
          "expression": "VS_TEXT8 AS CJRQ",
          "alias": "CJRQ"
        },
        {
          "expression": "T.ORG_NUM AS NBJGH",
          "alias": "NBJGH"
        },
        {
          "expression": "T.BIZ_LINE_ID",
          "alias": null
        },
        {
          "expression": "NULL AS VERIFY_STATUS",
          "alias": "VERIFY_STATUS"
        },
        {
          "expression": "NULL AS BSCJRQ",
          "alias": "BSCJRQ"
        },
        {
          "expression": "CASE WHEN T.ORG_NUM LIKE '51%' THEN '510000' WHEN T.ORG_NUM LIKE '52%' THEN '520000' WHEN T.ORG_NUM LIKE '53%' THEN '530000' WHEN T.ORG_NUM LIKE '54%' THEN '540000' WHEN T.ORG_NUM LIKE '55%' THEN '550000' WHEN T.ORG_NUM LIKE '56%' THEN '560000' WHEN T.ORG_NUM LIKE '57%' THEN '570000' WHEN T.ORG_NUM LIKE '58%' THEN '580000' WHEN T.ORG_NUM LIKE '59%' THEN '590000' WHEN T.ORG_NUM LIKE '60%' THEN '600000' ELSE '990000' END AS FRNBJGH",
          "alias": "FRNBJGH"
        },
        {
          "expression": "T.CUST_NAME",
          "alias": null
        },
        {
          "expression": "T.CUST_ID",
          "alias": null
        }
      ]
    },
    {
      "label": "最终INSERT（写入PBOCD_JS_201_DWDKFS）",
      "source_line": 1012,
      "type": "INSERT",
      "field_count": 44,
      "field_mappings": [
        {
          "expression": "VS_TEXT",
          "alias": null
        },
        {
          "expression": "COALESCE(OB.ID_NO, OB.UP_ID_NO)",
          "alias": null
        },
        {
          "expression": "T.ORG_NUM",
          "alias": null
        },
        {
          "expression": "OB.REGION_CD",
          "alias": null
        },
        {
          "expression": "T.CUST_ID_TYPE",
          "alias": null
        },
        {
          "expression": "T.CUST_ID_NO",
          "alias": null
        },
        {
          "expression": "COALESCE(T3.DEPT_TYPE, T.DEPT_TYPE)",
          "alias": null
        },
        {
          "expression": "T.INDUSTRY_TYPE",
          "alias": null
        },
        {
          "expression": "T.REG_AREA_CODE AS REG_AREA_CODE",
          "alias": "REG_AREA_CODE"
        },
        {
          "expression": "COALESCE(T.ENT_CON_ECO_ELEM, BU.ENT_CON_ECO_ELEM)",
          "alias": null
        },
        {
          "expression": "T.ENT_SCALE",
          "alias": null
        },
        {
          "expression": "T.LOAN_NUM",
          "alias": null
        },
        {
          "expression": "T.CONTRACT_CODE",
          "alias": null
        },
        {
          "expression": "CASE WHEN T.TRANS_TYPE = '1' AND NOT BQ.PRODUCT_TYPE IS NULL THEN BQ.PRODUCT_TYPE WHEN T.TRANS_TYPE = '0' AND SUBSTRING(T.LOAN_GRANT_DATE, 1, 7) <> SUBSTRING(VS_TEXT, 1, 7) THEN BU.PRODUCT_TYPE ELSE T.PRODUCT_TYPE END AS PRODUCT_TYPE",
          "alias": "PRODUCT_TYPE"
        },
        {
          "expression": "T.LOAN_PURPOSE_CD",
          "alias": null
        },
        {
          "expression": "T.LOAN_GRANT_DATE",
          "alias": null
        },
        {
          "expression": "T.LOAN_DUE_DATE",
          "alias": null
        },
        {
          "expression": "T.LOAN_ACTUAL_DUE_DATE",
          "alias": null
        },
        {
          "expression": "T.CURR_CODE",
          "alias": null
        },
        {
          "expression": "T.TRANS_AMT",
          "alias": null
        },
        {
          "expression": "T.TRANS_AMT_RMB",
          "alias": null
        },
        {
          "expression": "T.INT_RATE_TYPE",
          "alias": null
        },
        {
          "expression": "T.INT_RATE",
          "alias": null
        },
        {
          "expression": "T.PRI_BENCH_MARK",
          "alias": null
        },
        {
          "expression": "CASE WHEN T.INT_RATE_TYPE = 'RF01' THEN NULL ELSE T.BASE_INT_RAT END",
          "alias": null
        },
        {
          "expression": "T.FINA_SUPPORT_FLG",
          "alias": null
        },
        {
          "expression": "T.INT_REPRICE_DATE",
          "alias": null
        },
        {
          "expression": "CASE WHEN TRANS_TYPE = '0' THEN COALESCE(BU.GUAR_TYPE, T.GUAR_TYPE) ELSE T.GUAR_TYPE END",
          "alias": null
        },
        {
          "expression": "T.FIRST_LOAN_FLG",
          "alias": null
        },
        {
          "expression": "T.LOAN_STATUS",
          "alias": null
        },
        {
          "expression": "ASS_SEC_PRO_TYPE",
          "alias": null
        },
        {
          "expression": "LOAN_TYPE",
          "alias": null
        },
        {
          "expression": "TRANS_TYPE",
          "alias": null
        },
        {
          "expression": "T.SERIAL_NO",
          "alias": null
        },
        {
          "expression": "T.USEOFUNDS AS USEOFUNDS",
          "alias": "USEOFUNDS"
        },
        {
          "expression": "SYS_GUID() AS REPORT_ID",
          "alias": "REPORT_ID"
        },
        {
          "expression": "VS_TEXT8 AS CJRQ",
          "alias": "CJRQ"
        },
        {
          "expression": "T.ORG_NUM AS NBJGH",
          "alias": "NBJGH"
        },
        {
          "expression": "T.BIZ_LINE_ID",
          "alias": null
        },
        {
          "expression": "NULL AS VERIFY_STATUS",
          "alias": "VERIFY_STATUS"
        },
        {
          "expression": "NULL AS BSCJRQ",
          "alias": "BSCJRQ"
        },
        {
          "expression": "T.FRNBJGH",
          "alias": null
        },
        {
          "expression": "T.CUST_NAME",
          "alias": null
        },
        {
          "expression": "T.CUST_ID",
          "alias": null
        }
      ]
    }
  ]
}
```
