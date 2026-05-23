# 代销理财余额

> 物理表名：`L_ACCT_FINANCING_BAL`  
> 所属系统：监管集市

## 1. 报表首页

| 项目 | 内容 |
| --- | --- |
| 报表ID | 1994254277826388932 |
| 排序号 | 188 |
| 物理表名 | `L_ACCT_FINANCING_BAL` |
| 中文名 | 代销理财余额 |
| 所属系统 | 监管集市 |
| 主题 | - |
| 频率 | 日 |
| 来源类型 | 接口 |
| 自动取数状态 | 已上线 |
| 发文号 | - |
| 生效日期 | - |
| 科目编码 | - |
| 科目名称 | - |
| 负责人 | - |
| 状态 | 正常 |
| 字段总数 | 77 |
| 字段类型分布 | `FIELD` = 77，`INDICATOR` = 0 |
| 引用码表数 | 0 |

## 2. 字段总表

| 序号 | 字段名 | 中文名 | 类型 | 数据类型 | 长度 | 主键 | 可空 | 码表 | 取值说明 | 校验规则 | 自动取数 | 备注索引 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `DATA_DATE` | 数据日期 | FIELD | VARCHAR(8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 2 | `LP_CD` | 法人代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 3 | `TXN_ACCT_NO` | 交易账号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 4 | `PROD_NO` | 产品编号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 5 | `BANK_ACCT_NO` | 银行账号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 6 | `CUST_NO` | 客户编号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 7 | `FIN_ACCT_NO` | 理财账号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 8 | `TA_CD` | TA代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 9 | `PUBR_NAME` | 发行商名称 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 10 | `CUST_TYPE_CD` | 客户类型代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 11 | `PROD_NAME` | 产品名称 | FIELD | VARCHAR(250) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 12 | `PROD_TYPE_CD` | 产品类型代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 13 | `PROD_ATTR_CD` | 产品属性代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 14 | `PROD_OPER_MODE_CD` | 产品运营方式代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 15 | `PROD_STATUS_CD` | 产品状态代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 16 | `SUBSCR_START_DT` | 认购开始日期 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 17 | `SUBSCR_END_DT` | 认购结束日期 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 18 | `PROD_FOUND_DT` | 产品成立日期 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 19 | `PROD_END_DT` | 产品结束日期 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 20 | `PROD_VAL_DT` | 产品起息日期 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 21 | `ACVMNT_COMP_BNCHMK` | 业绩比较基准 | FIELD | DECIMAL(208) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 22 | `BELONG_ORG_NO` | 归属机构编号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 23 | `OPEN_ACCT_ORG_NO` | 开户机构编号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 24 | `SIGN_STATUS_CD` | 签约状态代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 25 | `SIGN_DT` | 签约日期 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 26 | `CUST_MGR_NO` | 客户经理编号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 27 | `CUST_MGR_NAME` | 客户经理名称 | FIELD | VARCHAR(100) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 28 | `CURR_CD` | 币种代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 29 | `CURR_SHARE` | 当前份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 30 | `TXN_FRZ_SHARE` | 交易冻结份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 31 | `LONG_TERM_FRZ_SHARE` | 长期冻结份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 32 | `PROD_NET_VAL` | 产品净值 | FIELD | DECIMAL(208) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 33 | `CURR_PERIOD_BAL` | 当期余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 34 | `CT_DC_BAL` | 折本币余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 35 | `BEGIN_DAY_BAL` | 日初余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 36 | `MONTH_BEGIN_BAL` | 月初余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 37 | `QUAR_BEGIN_BAL` | 季初余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 38 | `BYEAR_BAL` | 年初余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 39 | `CT_DC_BEGIN_DAY_BAL` | 折本币日初余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 40 | `CT_DC_MONTH_BEGIN_BAL` | 折本币月初余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 41 | `CT_DC_QUAR_BEGIN_BAL` | 折本币季初余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 42 | `CT_DC_BYEAR_BAL` | 折本币年初余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 43 | `YEAR_CUM_BAL` | 年累计余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 44 | `QUAR_CUM_BAL` | 季累计余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 45 | `MONTHLY_ACCUM_BAL` | 月累计余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 46 | `CT_DC_YEAR_CUM_BAL` | 折本币年累计余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 47 | `CT_DC_BEGIN_DAY_YEAR_CUM_BAL` | 折本币日初年累计余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 48 | `CT_DC_MONTH_BEGIN_YEAR_CUM_BAL` | 折本币月初年累计余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 49 | `CT_DC_QUAR_BEGIN_YEAR_CUM_BAL` | 折本币季初年累计余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 50 | `CT_DC_BYEAR_YEAR_CUM_BAL` | 折本币年初年累计余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 51 | `CT_DC_QUAR_CUM_BAL` | 折本币季累计余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 52 | `CT_DC_BEGIN_DAY_QUAR_CUM_BAL` | 折本币日初季累计余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 53 | `CT_DC_QUAR_BEGIN_QUAR_CUM_BAL` | 折本币季初季累计余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 54 | `CT_DC_BYEAR_QUAR_CUM_BAL` | 折本币年初季累计余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 55 | `CT_DC_MONTHLY_ACCUM_BAL` | 折本币月累计余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 56 | `CT_DC_BEGIN_DAY_MONTHLY_ACCUM_BAL` | 折本币日初月累计余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 57 | `CT_DC_MONTH_BEGIN_MONTHLY_ACCUM_BAL` | 折本币月初月累计余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 58 | `CT_DC_BYEAR_MONTHLY_ACCUM_BAL` | 折本币年初月累计余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 59 | `BEGIN_DAY_SHARE` | 日初份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 60 | `MONTH_BEGIN_SHARE` | 月初份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 61 | `QUAR_BEGIN_SHARE` | 季初份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 62 | `BYEAR_SHARE` | 年初份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 63 | `YEAR_CUM_SHARE` | 年累计份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 64 | `QUAR_CUM_SHARE` | 季累计份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 65 | `MONTHLY_ACCUM_SHARE` | 月累计份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 66 | `BEGIN_DAY_YEAR_CUM_SHARE` | 日初年累计份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 67 | `MONTH_BEGIN_YEAR_CUM_SHARE` | 月初年累计份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 68 | `QUAR_BEGIN_YEAR_CUM_SHARE` | 季初年累计份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 69 | `BYEAR_YEAR_CUM_SHARE` | 年初年累计份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 70 | `BEGIN_DAY_QUAR_CUM_SHARE` | 日初季累计份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 71 | `QUAR_BEGIN_QUAR_CUM_SHARE` | 季初季累计份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 72 | `BYEAR_QUAR_CUM_SHARE` | 年初季累计份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 73 | `BEGIN_DAY_MONTHLY_ACCUM_SHARE` | 日初月累计份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 74 | `MONTH_BEGIN_MONTHLY_ACCUM_SHARE` | 月初月累计份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 75 | `BYEAR_MONTHLY_ACCUM_SHARE` | 年初月累计份额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 76 | `BUY_COST` | 买入成本 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 77 | `PROD_TEMPLET_NO` | 产品模板编号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |

## 3. 补充说明

- 当前报表字段说明较简洁，无需额外补充。

## 4. 码表摘要

- 当前报表未引用码表。

