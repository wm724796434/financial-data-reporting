# 存量单位贷款信息_JS_201_CLDWDK — 字段取值

> 来源程序: `bsp_sp_js_201_cldwdk.prc`
> 解析日期: 2026-05-28 19:57:05

```json
{
  "file": "源码解析/加工层存储/bsp_sp_js_201_cldwdk.prc",
  "entity": "存量单位贷款信息_JS_201_CLDWDK",
  "parse_date": "2026-05-28 19:57:05",
  "data_extractions": [
    {
      "label": "存量贷款主数据（主SELECT - L_ACCT_LOAN）",
      "source_line": 98,
      "type": "SELECT",
      "field_count": 36,
      "field_mappings": [
        {
          "expression": "IS_DATE AS data_date",
          "alias": "data_date"
        },
        {
          "expression": "''",
          "alias": null
        },
        {
          "expression": "T.ORG_NUM AS ORG_NUM",
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
          "expression": "CASE WHEN D1.PBOCD_CODE = 'A02' THEN REPLACE(G.ID_NO, '-') ELSE G.ID_NO END AS CUST_ID_NO",
          "alias": "CUST_ID_NO"
        },
        {
          "expression": "CASE WHEN G.CUST_TYP <> '5' THEN G.DEPT_TYPE ELSE 'A04' END AS DEPT_TYPE",
          "alias": "DEPT_TYPE"
        },
        {
          "expression": "SUBSTRB(TRIM(G.CORP_BUSINSESS_TYPE), 0, 3)",
          "alias": null
        },
        {
          "expression": "COALESCE(REPLACE(G.REGION_CD, '待治理', ''), G.ORG_AREA) AS REG_AREA_CODE",
          "alias": "REG_AREA_CODE"
        },
        {
          "expression": "DECODE(G.CORP_HOLD_TYPE, 'A01', 'A0102', 'A02', 'A0101', 'B01', 'A0202', 'B02', 'A0201', 'C01', 'B0102', 'C02', 'B0101', 'D01', 'B0202', 'D02', 'B0201', 'E01', 'B0302', 'E02', 'B0301')",
          "alias": null
        },
        {
          "expression": "CASE WHEN SUBSTRING(G.CUST_TYP, 1, 1) IN ('0', '1') OR G.CUST_TYP = '9101' THEN CASE WHEN G.CORP_SCALE = 'B' THEN 'CS01' WHEN G.CORP_SCALE = 'M' THEN 'CS02' WHEN G.CORP_SCALE = 'S' THEN 'CS03' WHEN G.CORP_SCALE = 'T' THEN 'CS04' ELSE 'CS05' END ELSE 'CS05' END",
          "alias": null
        },
        {
          "expression": "T.LOAN_NUM AS LOAN_NUM",
          "alias": "LOAN_NUM"
        },
        {
          "expression": "T.ACCT_NUM AS CONTRACT_CODE",
          "alias": "CONTRACT_CODE"
        },
        {
          "expression": "CASE WHEN T.LOAN_NUM IN ('01260120001203330801', '01260120001203330802', '01260120001203330803', '02100119001190853001') THEN 'F12' WHEN (T.ITEM_CD LIKE '1305%' AND T.CURR_CD <> 'CNY') THEN 'F081' WHEN (T.ITEM_CD LIKE '1305%' AND T.CURR_CD = 'CNY') THEN 'F082' WHEN (T.ACCT_TYP = '0202' AND T.USEOFUNDS LIKE '%并购%') THEN 'F12' WHEN (T.ACCT_TYP = '0202' AND T.loan_business_typ = '1') OR (T.ACCT_TYP LIKE '0202%' AND Q.PROD_NAME IN ('商业房开发贷款', '法人商用房按揭贷款(企业名)')) OR (T.ACCT_TYP = '0202' AND Q.PROD_NAME IN ('银团贷款(牵头行)', '银团贷款(参与行)', '票据置换')) THEN 'F023' WHEN T.ACCT_TYP LIKE '0101%' THEN 'F0211' WHEN T.ACCT_TYP = '010301' THEN 'F0212' WHEN T.ACCT_TYP IN ('010402', '010403', '010404') THEN 'F02131' WHEN T.ACCT_TYP IN ('010401', '010405', '010499') THEN 'F02132' WHEN T.ACCT_TYP = '010399' THEN 'F0219' WHEN T.ACCT_TYP = '0202' OR T.ACCT_TYP LIKE '0102%' OR (T.ACCT_TYP = '070101' AND T.ONLENDING_USAGE = 'A') THEN 'F022' WHEN T.ACCT_TYP LIKE '0201%' OR (T.ACCT_TYP = '070101' AND T.ONLENDING_USAGE = 'B') THEN 'F023' WHEN T.ACCT_TYP = '0801' THEN 'F041' WHEN T.ACCT_TYP = '05' THEN 'F09' WHEN T.ACCT_TYP = '0203' OR (T.ACCT_TYP = '070101' AND T.ONLENDING_USAGE = 'C') THEN 'F12' WHEN SUBSTRING(T.ITEM_CD, 1, 4) IN ('1306') THEN CASE WHEN T.ACCT_TYP = '0901' THEN 'F052' WHEN T.ACCT_TYP = '0903' THEN 'F051' WHEN T.ACCT_TYP = '0904' THEN 'F053' WHEN T.ACCT_TYP = '0999' THEN 'F059' END END AS PRODUCT_TYPE",
          "alias": "PRODUCT_TYPE"
        },
        {
          "expression": "SUBSTRB(T.LOAN_PURPOSE_CD, 1, 4) AS LOAN_PURPOSE_CD",
          "alias": "LOAN_PURPOSE_CD"
        },
        {
          "expression": "CAST(T.DRAWDOWN_DT AS TEXT) AS LOAN_GRANT_DATE",
          "alias": "LOAN_GRANT_DATE"
        },
        {
          "expression": "CAST(T.MATURITY_DT AS TEXT) AS LOAN_DUE_DATE",
          "alias": "LOAN_DUE_DATE"
        },
        {
          "expression": "CASE WHEN ZQ.EXTENDTERM_FLG = 'Y' THEN CAST(ZQ.ACTUAL_MATURITY_DT AS TEXT) END AS DEFER_END_DATE",
          "alias": "DEFER_END_DATE"
        },
        {
          "expression": "T.CURR_CD AS CURR_CODE",
          "alias": "CURR_CODE"
        },
        {
          "expression": "T.LOAN_ACCT_BAL AS BALANCE",
          "alias": "BALANCE"
        },
        {
          "expression": "T.LOAN_ACCT_BAL * R.CCY_RATE AS BALANCE_RMB",
          "alias": "BALANCE_RMB"
        },
        {
          "expression": "CASE WHEN T.INT_RATE_TYP = 'F' THEN 'RF01' ELSE 'RF02' END AS INT_RATE_TYPE",
          "alias": "INT_RATE_TYPE"
        },
        {
          "expression": "T.REAL_INT_RAT AS INT_RATE",
          "alias": "INT_RATE"
        },
        {
          "expression": "CASE WHEN T.PRICING_BASE_TYPE = 'A01' THEN 'TR01' WHEN T.PRICING_BASE_TYPE = 'A0201' THEN 'TR02' WHEN T.PRICING_BASE_TYPE = 'A0202' THEN 'TR03' WHEN T.PRICING_BASE_TYPE = 'A0203' THEN 'TR04' WHEN T.PRICING_BASE_TYPE = 'C' THEN 'TR05' WHEN T.PRICING_BASE_TYPE = 'D' THEN 'TR06' WHEN T.PRICING_BASE_TYPE = 'B01' THEN 'TR07' WHEN T.PRICING_BASE_TYPE = 'B02' THEN 'TR08' WHEN T.PRICING_BASE_TYPE = 'E' THEN 'TR09' ELSE 'TR99' END AS PRI_BENCH_MARK",
          "alias": "PRI_BENCH_MARK"
        },
        {
          "expression": "CASE WHEN T.INT_RATE_TYP = 'F' THEN NULL ELSE T.BASE_INT_RAT END AS BASE_INT_RAT",
          "alias": "BASE_INT_RAT"
        },
        {
          "expression": "CASE WHEN T.COMP_INT_TYP = '110' THEN 'A0101' WHEN T.COMP_INT_TYP = '120' THEN 'A0102' WHEN T.COMP_INT_TYP = '210' THEN 'A0201' WHEN T.COMP_INT_TYP = '220' THEN 'A0202' WHEN T.COMP_INT_TYP = '300' THEN 'B' WHEN T.COMP_INT_TYP = '500' THEN 'C' WHEN T.COMP_INT_TYP = '400' THEN 'Z' END AS TFINA_SUPPORT_FLG",
          "alias": "TFINA_SUPPORT_FLG"
        },
        {
          "expression": "CASE WHEN T.INT_RATE_TYP = 'F' AND T.EXTENDTERM_FLG = 'Y' THEN CAST(T.ACTUAL_MATURITY_DT AS TEXT) WHEN T.INT_RATE_TYP = 'F' THEN CAST(T.MATURITY_DT AS TEXT) WHEN T.NEXT_REPRICING_DT < T.DRAWDOWN_DT THEN CAST(T.DRAWDOWN_DT AS TEXT) WHEN T.NEXT_REPRICING_DT > T.ACTUAL_MATURITY_DT THEN CAST(T.ACTUAL_MATURITY_DT AS TEXT) ELSE COALESCE(CAST(T.NEXT_REPRICING_DT AS TEXT), CAST(T.ACTUAL_MATURITY_DT AS TEXT)) END AS INT_REPRICE_DATE",
          "alias": "INT_REPRICE_DATE"
        },
        {
          "expression": "TP7.GUAR_TYPE AS GUARANTY_TYP",
          "alias": "GUARANTY_TYP"
        },
        {
          "expression": "CASE WHEN LA.RN = 1 THEN '1' WHEN LA.RN >= 2 THEN '0' END AS FIRST_LOAN_FLG",
          "alias": "FIRST_LOAN_FLG"
        },
        {
          "expression": "CASE WHEN T.LOAN_GRADE_CD = '1' THEN 'FQ01' WHEN T.LOAN_GRADE_CD = '2' THEN 'FQ02' WHEN T.LOAN_GRADE_CD = '3' THEN 'FQ03' WHEN T.LOAN_GRADE_CD = '4' THEN 'FQ04' WHEN T.LOAN_GRADE_CD = '5' THEN 'FQ05' END AS LOAN_CLASSIFY",
          "alias": "LOAN_CLASSIFY"
        },
        {
          "expression": "CASE WHEN T.OD_FLG = 'Y' THEN 'LS03' WHEN T.EXTENDTERM_FLG = 'Y' THEN 'LS02' ELSE 'LS01' END AS LOAN_STATUS",
          "alias": "LOAN_STATUS"
        },
        {
          "expression": "CASE WHEN NOT T.P_OD_DT IS NULL AND NOT T.I_OD_DT IS NULL AND CAST(T.P_OD_DT AS TEXT) <> '99991231' AND CAST(T.I_OD_DT AS TEXT) <> '99991231' AND T.OD_FLG = 'Y' THEN '03' WHEN NOT T.P_OD_DT IS NULL AND CAST(T.P_OD_DT AS TEXT) <> '99991231' AND T.OD_FLG = 'Y' THEN '01' WHEN NOT T.I_OD_DT IS NULL AND CAST(T.I_OD_DT AS TEXT) <> '99991231' AND T.OD_FLG = 'Y' THEN '02' END AS OD_TYPE",
          "alias": "OD_TYPE"
        },
        {
          "expression": "REGEXP_REPLACE(REGEXP_REPLACE(T.USEOFUNDS, '[!?^？！ |]'), CHR(9)) AS USEOFUNDS",
          "alias": "USEOFUNDS"
        },
        {
          "expression": "COALESCE(CASE WHEN T.DEPARTMENTD = '公司金融' THEN 'E' WHEN T.DEPARTMENTD = '普惠金融' THEN 'S' WHEN T.DEPARTMENTD = '个人信贷' THEN 'P' WHEN T.DEPARTMENTD = '德惠长银' THEN 'E' END, '99')",
          "alias": null
        },
        {
          "expression": "T.CUST_ID",
          "alias": null
        },
        {
          "expression": "G.CUST_NAM",
          "alias": null
        }
      ]
    },
    {
      "label": "最终输出（汇总SELECT - JS_201_CLDWDK → PBOCD_JS_201_CLDWDK）",
      "source_line": 431,
      "type": "SELECT",
      "field_count": 42,
      "field_mappings": [
        {
          "expression": "VS_TEXT AS DATA_DATE",
          "alias": "DATA_DATE"
        },
        {
          "expression": "COALESCE(OB.ID_NO, OB.UP_ID_NO)",
          "alias": null
        },
        {
          "expression": "T.ORG_NUM AS ORG_NUM",
          "alias": "ORG_NUM"
        },
        {
          "expression": "OB.REGION_CD",
          "alias": null
        },
        {
          "expression": "T.CUST_ID_TYPE AS CUST_ID_TYPE",
          "alias": "CUST_ID_TYPE"
        },
        {
          "expression": "T.CUST_ID_NO AS CUST_ID_NO",
          "alias": "CUST_ID_NO"
        },
        {
          "expression": "COALESCE(T4.DEPT_TYPE, T.DEPT_TYPE)",
          "alias": null
        },
        {
          "expression": "T.INDUSTRY_TYPE",
          "alias": null
        },
        {
          "expression": "T.REG_AREA_CODE",
          "alias": null
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
          "expression": "T.DEFER_END_DATE",
          "alias": null
        },
        {
          "expression": "T.CURR_CODE",
          "alias": null
        },
        {
          "expression": "T.BALANCE",
          "alias": null
        },
        {
          "expression": "T.BALANCE_RMB",
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
          "expression": "t.FINA_SUPPORT_FLG",
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
          "expression": "T.LOAN_CLASSIFY",
          "alias": null
        },
        {
          "expression": "T.LOAN_STATUS",
          "alias": null
        },
        {
          "expression": "T.OD_TYPE",
          "alias": null
        },
        {
          "expression": "T.USEOFUNDS",
          "alias": null
        },
        {
          "expression": "SYS_GUID()",
          "alias": null
        },
        {
          "expression": "IS_DATE",
          "alias": null
        },
        {
          "expression": "T.ORG_NUM",
          "alias": null
        },
        {
          "expression": "CASE WHEN T.ORG_NUM LIKE '51%' THEN '99' WHEN T.ORG_NUM LIKE '52%' THEN '99' WHEN T.ORG_NUM LIKE '53%' THEN '99' WHEN T.ORG_NUM LIKE '54%' THEN '99' WHEN T.ORG_NUM LIKE '55%' THEN '99' WHEN T.ORG_NUM LIKE '56%' THEN '99' WHEN T.ORG_NUM LIKE '57%' THEN '99' WHEN T.ORG_NUM LIKE '58%' THEN '99' WHEN T.ORG_NUM LIKE '59%' THEN '99' WHEN T.ORG_NUM LIKE '60%' THEN '99' WHEN T.CURR_CODE <> 'CNY' THEN 'G' ELSE T.BIZ_LINE_ID END AS BIZ_LINE_ID",
          "alias": "BIZ_LINE_ID"
        },
        {
          "expression": "''",
          "alias": null
        },
        {
          "expression": "''",
          "alias": null
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
    }
  ]
}
```
