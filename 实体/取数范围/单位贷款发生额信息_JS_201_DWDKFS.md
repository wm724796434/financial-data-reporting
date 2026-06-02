# 单位贷款发生额信息_JS_201_DWDKFS — 取数范围

> 来源程序: `bsp_sp_js_201_dwdkfs.prc`
> 解析日期: 2026-05-28 19:50:31
> 语句总数: 19，关键取数语句: 5

```json
{
  "file": "源码解析/加工层存储/bsp_sp_js_201_dwdkfs.prc",
  "entity": "单位贷款发生额信息_JS_201_DWDKFS",
  "parse_date": "2026-05-28 19:50:31",
  "total_statements": 19,
  "key_extractions": 5,
  "data_extractions": [
    {
      "label": "放款数据（贷款发放 - INSERT INTO 主SELECT）",
      "source_line": 105,
      "type": "SELECT",
      "source_tables": [
        {
          "table": "SMTMODS.L_ACCT_LOAN AS A",
          "alias": "A"
        },
        {
          "table": "SMTMODS.L_CUST_ALL AS B",
          "alias": "B"
        },
        {
          "table": "PBOCD_DATACORE.L_CUST_C_TMP AS C",
          "alias": "C"
        },
        {
          "table": "PBOCD_DATACORE.L_CODE_DICTIONARY AS D1",
          "alias": "D1"
        },
        {
          "table": "JS_102_FTYKHX_MAPPING AS M",
          "alias": "M"
        },
        {
          "table": "L_PUBL_ORG_BRA_TMP AS D",
          "alias": "D"
        },
        {
          "table": "SMTMODS.L_AGRE_LOAN_CONTRACT AS Q",
          "alias": "Q"
        },
        {
          "table": "DBFS_TMP AS TP7",
          "alias": "TP7"
        },
        {
          "table": "M_DICT_REMAPPING AS E",
          "alias": "E"
        },
        {
          "table": "SMTMODS.L_PUBL_RATE AS U",
          "alias": "U"
        },
        {
          "table": "SMTMODS.L_ACCT_LOAN AS T",
          "alias": "T"
        },
        {
          "table": "SMTMODS.L_ACCT_LOAN AS A2",
          "alias": "A2"
        }
      ],
      "joins": [
        {
          "type": "INNER",
          "table": "SMTMODS.L_CUST_ALL AS B",
          "alias": "B",
          "on_conditions": [
            "A.CUST_ID = B.CUST_ID",
            "B.DATA_DATE = IS_DATE"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "PBOCD_DATACORE.L_CUST_C_TMP AS C",
          "alias": "C",
          "on_conditions": [
            "A.CUST_ID = C.CUST_ID",
            "C.DATA_DATE = IS_DATE"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "PBOCD_DATACORE.L_CODE_DICTIONARY AS D1",
          "alias": "D1",
          "on_conditions": [
            "C.ID_TYPE = D1.L_CODE",
            "D1.CODE_CLMN_NAME = 'ID_TYPE'"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "JS_102_FTYKHX_MAPPING AS M",
          "alias": "M",
          "on_conditions": [
            "A.CUST_ID = M.COD_CUST_ID"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "L_PUBL_ORG_BRA_TMP AS D",
          "alias": "D",
          "on_conditions": [
            "A.ORG_NUM = D.ORG_NUM",
            "D.DATA_DATE = IS_DATE"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "SMTMODS.L_AGRE_LOAN_CONTRACT AS Q",
          "alias": "Q",
          "on_conditions": [
            "A.ACCT_NUM = Q.CONTRACT_NUM",
            "A.DATA_DATE = Q.DATA_DATE"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "DBFS_TMP AS TP7",
          "alias": "TP7",
          "on_conditions": [
            "A.LOAN_NUM = TP7.LOAN_NUM"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "M_DICT_REMAPPING AS E",
          "alias": "E",
          "on_conditions": [
            "C.NATION_CD = E.ORI_VALUES",
            "E.DICT_CODE = 'COUNTRY_CODE_3_TO_NUM'"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "SMTMODS.L_PUBL_RATE AS U",
          "alias": "U",
          "on_conditions": [
            "U.CCY_DATE = STR_TO_DATE(CAST(A.DRAWDOWN_DT AS TEXT), '%Y%m%d')",
            "U.BASIC_CCY = A.CURR_CD",
            "U.FORWARD_CCY = 'CNY'"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "(SELECT T.LOAN_NUM, ROW_NUMBER() OVER (PARTITION BY T.CUST_ID ORDER BY T.DRAWDOWN_DT ASC NULLS LAST, LOAN_NUM NULLS LAST) AS RN FROM SMTMODS.L_ACCT_LOAN AS T WHERE t.data_date = IS_DATE) AS LA",
          "alias": "LA",
          "on_conditions": [
            "A.LOAN_NUM = LA.LOAN_NUM"
          ],
          "role": "过滤"
        }
      ],
      "business_where_conditions": [
        "A.DATA_DATE = IS_DATE",
        "DATE_TRUNC('MM', A.DRAWDOWN_DT) = DATE_TRUNC('MM', STR_TO_DATE(IS_DATE, 'yyyymmdd'))",
        "SUBSTRING(A.ITEM_CD, 1, 4) IN ('1303', '1305', '7120', '1306')",
        "A.CANCEL_FLG = 'N'",
        "D.NATION_CD = 'CHN'",
        "SUBSTRING(A.ACCT_TYP, 1, 2) IN ('02', '04', '05', '08', '09') OR A.ACCT_TYP = '070101'",
        "B.CUST_TYPE = '11' OR SUBSTRING(C.FINA_CODE, 1, 1) IN ('A', 'B')",
        "C.CUST_TYP <> '3'",
        "A.LOAN_STOCKEN_DATE IS NULL",
        "NOT EXISTS(SELECT 1 FROM SMTMODS.L_ACCT_LOAN AS A2 WHERE A2.DATA_DATE = IS_DATE AND SUBSTRING(A2.ITEM_CD, 1, 4) IN ('1306') AND SUBSTRING(CAST(A2.DRAWDOWN_DT AS TEXT), 1, 6) = SUBSTRING(IS_DATE, 1, 6) AND A2.DRAWDOWN_DT = A2.FINISH_DT AND A2.LOAN_ACCT_BAL = 0 AND A.LOAN_NUM = A2.LOAN_NUM)"
      ]
    },
    {
      "label": "还款数据（贷款收回 - 子SELECT）",
      "source_line": 478,
      "type": "SELECT",
      "source_tables": [
        {
          "table": "SMTMODS.L_ACCT_LOAN AS D",
          "alias": "D"
        },
        {
          "table": "JS_102_FTYKHX_MAPPING AS M",
          "alias": "M"
        },
        {
          "table": "SMTMODS.L_CUST_ALL AS B",
          "alias": "B"
        },
        {
          "table": "PBOCD_DATACORE.L_CUST_C_TMP AS C",
          "alias": "C"
        },
        {
          "table": "L_PUBL_ORG_BRA_TMP AS E",
          "alias": "E"
        },
        {
          "table": "PBOCD_DATACORE.L_CODE_DICTIONARY AS D1",
          "alias": "D1"
        },
        {
          "table": "SMTMODS.L_AGRE_LOAN_CONTRACT AS Q",
          "alias": "Q"
        },
        {
          "table": "M_DICT_REMAPPING AS G",
          "alias": "G"
        },
        {
          "table": "SMTMODS.L_PUBL_RATE AS U",
          "alias": "U"
        },
        {
          "table": "DBFS_TMP AS TP7",
          "alias": "TP7"
        },
        {
          "table": "SMTMODS.L_TRAN_LOAN_PAYM AS X",
          "alias": "X"
        },
        {
          "table": "SMTMODS.L_ACCT_LOAN AS T",
          "alias": "T"
        },
        {
          "table": "SMTMODS.L_ACCT_LOAN AS A2",
          "alias": "A2"
        },
        {
          "table": "SMTMODS.L_ACCT_WRITE_OFF AS XX",
          "alias": "XX"
        }
      ],
      "joins": [
        {
          "type": "INNER",
          "table": "SMTMODS.L_ACCT_LOAN AS D",
          "alias": "D",
          "on_conditions": [
            "A.LOAN_NUM = D.LOAN_NUM",
            "D.DATA_DATE = IS_DATE"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "JS_102_FTYKHX_MAPPING AS M",
          "alias": "M",
          "on_conditions": [
            "D.CUST_ID = M.COD_CUST_ID"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "SMTMODS.L_CUST_ALL AS B",
          "alias": "B",
          "on_conditions": [
            "D.CUST_ID = B.CUST_ID",
            "B.DATA_DATE = IS_DATE"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "PBOCD_DATACORE.L_CUST_C_TMP AS C",
          "alias": "C",
          "on_conditions": [
            "D.CUST_ID = C.CUST_ID",
            "C.DATA_DATE = IS_DATE"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "L_PUBL_ORG_BRA_TMP AS E",
          "alias": "E",
          "on_conditions": [
            "A.ORG_NUM = E.ORG_NUM",
            "E.DATA_DATE = IS_DATE"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "PBOCD_DATACORE.L_CODE_DICTIONARY AS D1",
          "alias": "D1",
          "on_conditions": [
            "C.ID_TYPE = D1.L_CODE",
            "D1.CODE_CLMN_NAME = 'ID_TYPE'"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "SMTMODS.L_AGRE_LOAN_CONTRACT AS Q",
          "alias": "Q",
          "on_conditions": [
            "D.ACCT_NUM = Q.CONTRACT_NUM",
            "D.DATA_DATE = Q.DATA_DATE"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "M_DICT_REMAPPING AS G",
          "alias": "G",
          "on_conditions": [
            "B.NATION_CD = G.ORI_VALUES",
            "G.DICT_CODE = 'COUNTRY_CODE_3_TO_NUM'"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "SMTMODS.L_PUBL_RATE AS U",
          "alias": "U",
          "on_conditions": [
            "U.CCY_DATE = STR_TO_DATE(CAST(A.REPAY_DT AS TEXT), '%Y%m%d')",
            "U.BASIC_CCY = D.CURR_CD",
            "U.FORWARD_CCY = 'CNY'"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "(SELECT T.LOAN_NUM, ROW_NUMBER() OVER (PARTITION BY T.CUST_ID ORDER BY T.DRAWDOWN_DT ASC NULLS LAST, LOAN_NUM NULLS LAST) AS RN FROM SMTMODS.L_ACCT_LOAN AS T WHERE t.data_date = IS_DATE) AS LA",
          "alias": "LA",
          "on_conditions": [
            "A.LOAN_NUM = LA.LOAN_NUM"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "DBFS_TMP AS TP7",
          "alias": "TP7",
          "on_conditions": [
            "A.LOAN_NUM = TP7.LOAN_NUM"
          ],
          "role": "过滤"
        }
      ],
      "business_where_conditions": [
        "SUBSTRING(D.ITEM_CD, 1, 4) IN ('1303', '1305', '7120', '1306')",
        "D.CANCEL_FLG = 'N' OR (D.CANCEL_FLG = 'Y' AND EXISTS(SELECT 1 FROM SMTMODS.L_ACCT_WRITE_OFF AS XX WHERE XX.DATA_DATE = IS_DATE AND SUBSTRING(CAST(XX.WRITE_OFF_DATE AS TEXT), 1, 6) = SUBSTRING(IS_DATE, 1, 6) AND D.LOAN_NUM = XX.LOAN_NUM))",
        "D.LOAN_STOCKEN_DATE IS NULL",
        "E.NATION_CD = 'CHN'",
        "SUBSTRING(D.ACCT_TYP, 1, 2) IN ('02', '04', '05', '08', '09') OR D.ACCT_TYP = '070101'",
        "B.CUST_TYPE = '11' OR SUBSTRING(C.FINA_CODE, 1, 1) IN ('A', 'B')",
        "C.CUST_TYP <> '3'",
        "NOT EXISTS(SELECT 1 FROM SMTMODS.L_ACCT_LOAN AS A2 WHERE A2.DATA_DATE = IS_DATE AND SUBSTRING(A2.ITEM_CD, 1, 4) IN ('1306') AND SUBSTRING(CAST(A2.DRAWDOWN_DT AS TEXT), 1, 6) = SUBSTRING(IS_DATE, 1, 6) AND A2.DRAWDOWN_DT = A2.FINISH_DT AND A2.LOAN_ACCT_BAL = 0 AND D.LOAN_NUM = A2.LOAN_NUM)"
      ]
    },
    {
      "label": "line 856",
      "source_line": 856,
      "type": "SELECT",
      "source_tables": [
        {
          "table": "JS_201_DWDKFS AS T",
          "alias": "T"
        }
      ],
      "joins": [],
      "business_where_conditions": []
    },
    {
      "label": "中间表汇总（从JS_201_DWDKFS取数）",
      "source_line": 917,
      "type": "SELECT",
      "source_tables": [
        {
          "table": "JS_201_DWDKFS AS T",
          "alias": "T"
        },
        {
          "table": "JS_201_DWDKFS_TEMP02 AS T2",
          "alias": "T2"
        },
        {
          "table": "TMP_DWDKFS_TS AS TT",
          "alias": "TT"
        }
      ],
      "joins": [
        {
          "type": "INNER",
          "table": "JS_201_DWDKFS_TEMP02 AS T2",
          "alias": "T2",
          "on_conditions": [
            "T.SERIAL_NO = T2.SERIAL_NO"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "TMP_DWDKFS_TS AS TT",
          "alias": "TT",
          "on_conditions": [
            "T.LOAN_NUM = TT.JJBH",
            "TT.STATUS = '债转股'"
          ],
          "role": "过滤"
        }
      ],
      "business_where_conditions": [
        "T.DATA_DATE = IS_DATE"
      ]
    },
    {
      "label": "最终INSERT（写入PBOCD_JS_201_DWDKFS）",
      "source_line": 1012,
      "type": "INSERT",
      "source_tables": [
        {
          "table": "PBOCD_JS_201_DWDKFS",
          "alias": "PBOCD_JS_201_DWDKFS"
        },
        {
          "table": "PBOCD_JS_201_DWDKFS_TMP AS T",
          "alias": "T"
        },
        {
          "table": "L_PUBL_ORG_BRA_TMP AS OB",
          "alias": "OB"
        },
        {
          "table": "PBOCD_JS_201_CLDWDK AS BQ",
          "alias": "BQ"
        },
        {
          "table": "PBOCD_JS_201_CLDWDK_SQ AS BU",
          "alias": "BU"
        },
        {
          "table": "PBOCD_JS_102_FTYKHX AS T3",
          "alias": "T3"
        }
      ],
      "joins": [
        {
          "type": "INNER",
          "table": "L_PUBL_ORG_BRA_TMP AS OB",
          "alias": "OB",
          "on_conditions": [
            "OB.ORG_NUM = T.NBJGH",
            "OB.DATA_DATE = IS_DATE"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "PBOCD_JS_201_CLDWDK AS BQ",
          "alias": "BQ",
          "on_conditions": [
            "T.LOAN_NUM = BQ.LOAN_NUM",
            "BQ.CJRQ = IS_DATE"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "PBOCD_JS_201_CLDWDK_SQ AS BU",
          "alias": "BU",
          "on_conditions": [
            "T.LOAN_NUM = BU.LOAN_NUM",
            "BU.CJRQ = VS_LAST_TEXT"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "PBOCD_JS_102_FTYKHX AS T3",
          "alias": "T3",
          "on_conditions": [
            "T.CUST_ID = T3.CUST_ID",
            "T.FRNBJGH = T3.FRNBJGH",
            "T3.CJRQ = IS_DATE"
          ],
          "role": "过滤"
        }
      ],
      "business_where_conditions": []
    }
  ]
}
```
