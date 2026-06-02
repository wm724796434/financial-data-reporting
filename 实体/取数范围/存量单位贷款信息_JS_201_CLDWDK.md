# 存量单位贷款信息_JS_201_CLDWDK — 取数范围

> 来源程序: `bsp_sp_js_201_cldwdk.prc`
> 解析日期: 2026-05-28 19:57:05
> 语句总数: 21，关键取数语句: 2

```json
{
  "file": "源码解析/加工层存储/bsp_sp_js_201_cldwdk.prc",
  "entity": "存量单位贷款信息_JS_201_CLDWDK",
  "parse_date": "2026-05-28 19:57:05",
  "total_statements": 21,
  "key_extractions": 2,
  "data_extractions": [
    {
      "label": "存量贷款主数据（主SELECT - L_ACCT_LOAN）",
      "source_line": 98,
      "type": "SELECT",
      "source_tables": [
        {
          "table": "SMTMODS.L_ACCT_LOAN AS T",
          "alias": "T"
        },
        {
          "table": "L_CUST_C_TMP AS G",
          "alias": "G"
        },
        {
          "table": "JS_102_FTYKHX_MAPPING AS M",
          "alias": "M"
        },
        {
          "table": "SMTMODS.L_AGRE_LOAN_CONTRACT AS Q",
          "alias": "Q"
        },
        {
          "table": "SMTMODS.L_PUBL_RATE AS R",
          "alias": "R"
        },
        {
          "table": "DBFS_TMP AS TP7",
          "alias": "TP7"
        },
        {
          "table": "PBOCD_DATACORE.L_CODE_DICTIONARY AS D1",
          "alias": "D1"
        },
        {
          "table": "SMTMODS.L_CODE_DICTIONARY AS D2",
          "alias": "D2"
        },
        {
          "table": "SMTMODS.v_pub_idx_dk_zqdqrjj AS ZQ",
          "alias": "ZQ"
        },
        {
          "table": "smtmods.L_ACCT_LOAN AS T",
          "alias": "T"
        }
      ],
      "joins": [
        {
          "type": "INNER",
          "table": "L_CUST_C_TMP AS G",
          "alias": "G",
          "on_conditions": [
            "T.CUST_ID = G.CUST_ID",
            "G.CUST_TYP <> '3'",
            "G.DATA_DATE = IS_DATE"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "JS_102_FTYKHX_MAPPING AS M",
          "alias": "M",
          "on_conditions": [
            "T.CUST_ID = M.COD_CUST_ID"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "SMTMODS.L_AGRE_LOAN_CONTRACT AS Q",
          "alias": "Q",
          "on_conditions": [
            "T.ACCT_NUM = Q.CONTRACT_NUM",
            "T.DATA_DATE = Q.DATA_DATE"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "SMTMODS.L_PUBL_RATE AS R",
          "alias": "R",
          "on_conditions": [
            "R.DATA_DATE = IS_DATE",
            "R.BASIC_CCY = T.CURR_CD",
            "R.FORWARD_CCY = 'CNY'",
            "R.DATA_DATE = IS_DATE"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "DBFS_TMP AS TP7",
          "alias": "TP7",
          "on_conditions": [
            "T.LOAN_NUM = TP7.LOAN_NUM"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "PBOCD_DATACORE.L_CODE_DICTIONARY AS D1",
          "alias": "D1",
          "on_conditions": [
            "G.ID_TYPE = D1.L_CODE",
            "D1.CODE_CLMN_NAME = 'ID_TYPE'"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "SMTMODS.L_CODE_DICTIONARY AS D2",
          "alias": "D2",
          "on_conditions": [
            "G.CORP_HOLD_TYPE = D2.CODE",
            "D2.CODE_CLMN_NAME = 'CORP_HOLD_TYPE'"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "(SELECT T.LOAN_NUM, ROW_NUMBER() OVER (PARTITION BY T.CUST_ID ORDER BY T.DRAWDOWN_DT ASC NULLS LAST, LOAN_NUM NULLS LAST) AS RN FROM smtmods.L_ACCT_LOAN AS T WHERE t.data_date = IS_DATE) AS LA",
          "alias": "LA",
          "on_conditions": [
            "T.LOAN_NUM = LA.LOAN_NUM"
          ],
          "role": "过滤"
        },
        {
          "type": "INNER",
          "table": "SMTMODS.v_pub_idx_dk_zqdqrjj AS ZQ",
          "alias": "ZQ",
          "on_conditions": [
            "T.LOAN_NUM = ZQ.LOAN_NUM",
            "T.DATA_DATE = ZQ.DATA_DATE"
          ],
          "role": "过滤"
        }
      ],
      "business_where_conditions": [
        "t.data_date = IS_DATE",
        "T.LOAN_ACCT_BAL > 0",
        "SUBSTRING(T.ITEM_CD, 1, 4) IN ('1303', '1305', '1306')",
        "T.CANCEL_FLG = 'N'",
        "T.LOAN_STOCKEN_DATE IS NULL"
      ]
    },
    {
      "label": "最终输出（汇总SELECT - JS_201_CLDWDK → PBOCD_JS_201_CLDWDK）",
      "source_line": 431,
      "type": "SELECT",
      "source_tables": [
        {
          "table": "JS_201_CLDWDK AS T",
          "alias": "T"
        },
        {
          "table": "L_PUBL_ORG_BRA_TMP AS OB",
          "alias": "OB"
        },
        {
          "table": "PBOCD_JS_201_CLDWDK_SQ AS BU",
          "alias": "BU"
        },
        {
          "table": "PBOCD_JS_102_FTYKHX AS T4",
          "alias": "T4"
        }
      ],
      "joins": [
        {
          "type": "INNER",
          "table": "L_PUBL_ORG_BRA_TMP AS OB",
          "alias": "OB",
          "on_conditions": [
            "OB.ORG_NUM = T.ORG_NUM",
            "OB.DATA_DATE = IS_DATE"
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
          "table": "PBOCD_JS_102_FTYKHX AS T4",
          "alias": "T4",
          "on_conditions": [
            "T.CUST_ID = T4.CUST_ID",
            "T4.CJRQ = IS_DATE"
          ],
          "role": "过滤"
        }
      ],
      "business_where_conditions": [
        "T.DATA_DATE = IS_DATE"
      ]
    }
  ]
}
```
