# 代销保险余额

> 物理表名：`L_ACCT_INSURANCE_BAL`  
> 所属系统：监管集市

## 1. 报表首页

| 项目 | 内容 |
| --- | --- |
| 报表ID | 1994254277826388931 |
| 排序号 | 187 |
| 物理表名 | `L_ACCT_INSURANCE_BAL` |
| 中文名 | 代销保险余额 |
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
| 字段总数 | 66 |
| 字段类型分布 | `FIELD` = 66，`INDICATOR` = 0 |
| 引用码表数 | 0 |

## 2. 字段总表

| 序号 | 字段名 | 中文名 | 类型 | 数据类型 | 长度 | 主键 | 可空 | 码表 | 取值说明 | 校验规则 | 自动取数 | 备注索引 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `DATA_DATE` | 数据日期 | FIELD | VARCHAR(8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 2 | `LP_CD` | 法人代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 3 | `INSURE_NO` | 保单编号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 4 | `TA_CD` | TA代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 5 | `INSURE_CORP_NAME` | 保险公司名称 | FIELD | VARCHAR(250) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 6 | `PROD_NO` | 产品编号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 7 | `PROD_NAME` | 产品名称 | FIELD | VARCHAR(250) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 8 | `CUST_NO` | 客户编号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 9 | `CUST_TYPE_CD` | 客户类别代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 10 | `POLICY_HOLDER_NAME` | 投保人名称 | FIELD | VARCHAR(250) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 11 | `POLICY_HOLDER_DOCTYP_CD` | 投保人证件类型代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 12 | `POLICY_HOLDER_DOC_NO` | 投保人证件号码 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 13 | `POLICY_HOLDER_INSRNT_RELA_CD` | 投保人被保人关系代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 14 | `INSRNT_NAME` | 被保人名称 | FIELD | VARCHAR(250) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 15 | `INSRNT_DOCTYP_CD` | 被保人证件类型代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 16 | `INSRNT_DOC_NO` | 被保人证件号码 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 17 | `PROD_TYPE_CD` | 产品类型代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 18 | `PROD_SUB_TYPE_CD` | 产品子类型代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 19 | `PAY_YEARS` | 缴费年限 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 20 | `PROT_PERI_TYPE_CD` | 保障年期类型代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 21 | `PROT_PERI_CD` | 保障年期代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 22 | `PAY_MODE_CD` | 缴费方式代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 23 | `PAY_PERI_TYPE_CD` | 缴费年期类型代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 24 | `INSURE_STATUS_CD` | 保单状态代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 25 | `INSURE_MNY_AMT` | 保险金额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 26 | `INSURE_PREM_USE` | 保险费用 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 27 | `BANK_ACCT_NO` | 银行账号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 28 | `INSURE_SHARES_CNT` | 投保份数 | FIELD | DECIMAL(180) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 29 | `ACPTD_SER_NO` | 受理流水号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 30 | `ACPTD_DT` | 受理日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 31 | `INSURE_DT` | 投保日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 32 | `UNDERWRT_DT` | 承保日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 33 | `CONT_START_DT` | 合约开始日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 34 | `CONT_END_DT` | 合约结束日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 35 | `CURR_CD` | 币种代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 36 | `FIRST_TXN_DT` | 首次交易日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 37 | `RECNT_TXN_DT` | 最近交易日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 38 | `BELONG_ORG_NO` | 归属机构编号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 39 | `OPEN_ACCT_ORG_NO` | 开户机构编号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 40 | `CHNL_TYPE_CD` | 渠道类别代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 41 | `CUST_MGR_NO` | 客户经理编号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 42 | `OPERR_NO` | 操作员编号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 43 | `CURR_BAL` | 当前应缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 44 | `CT_DC_BAL` | 折本币应缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 45 | `BEGIN_DAY_BAL` | 日初应缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 46 | `MONTH_BEGIN_BAL` | 月初应缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 47 | `QUAR_BEGIN_BAL` | 季初应缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 48 | `BYEAR_BAL` | 年初应缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 49 | `CT_DC_BEGIN_DAY_BAL` | 折本币日初应缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 50 | `CT_DC_MONTH_BEGIN_BAL` | 折本币月初应缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 51 | `CT_DC_QUAR_BEGIN_BAL` | 折本币季初应缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 52 | `CT_DC_BYEAR_BAL` | 折本币年初应缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 53 | `YEAR_CUM_BAL` | 年累计应缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 54 | `QUAR_CUM_BAL` | 季累计应缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 55 | `MONTHLY_ACCUM_BAL` | 月累计应缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 56 | `CT_DC_YEAR_CUM_BAL` | 折本币年累计应缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 57 | `CT_DC_QUAR_CUM_BAL` | 折本币季累计应缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 58 | `CT_DC_MONTHLY_ACCUM_BAL` | 折本币月累计应缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 59 | `CURR_PAID_BAL` | 当前已缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 60 | `CLCURR_PAID_BAL` | 折本币已缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 61 | `YEAR_CUM_PAID_BAL` | 年累计已缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 62 | `QUAR_CUM_PAID_BAL` | 季累计已缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 63 | `MONTHLY_ACCUM_PAID_BAL` | 月累计已缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 64 | `CLCURR_YEAR_CUM_PAID_BAL` | 折本币年累计已缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 65 | `CLCURR_QUAR_CUM_PAID_BAL` | 折本币季累计已缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 66 | `CLCURR_MONTHLY_ACCUM_PAID_BAL` | 折本币月累计已缴余额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |

## 3. 补充说明

- 当前报表字段说明较简洁，无需额外补充。

## 4. 码表摘要

- 当前报表未引用码表。

