# 折溢摊损益分析表

> 物理表名：`L_TRAN_EV_OVRFLWG_PRFT_LOSS`  
> 所属系统：监管集市

## 1. 报表首页

| 项目 | 内容 |
| --- | --- |
| 报表ID | 1994254277826388930 |
| 排序号 | 186 |
| 物理表名 | `L_TRAN_EV_OVRFLWG_PRFT_LOSS` |
| 中文名 | 折溢摊损益分析表 |
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
| 字段总数 | 68 |
| 字段类型分布 | `FIELD` = 68，`INDICATOR` = 0 |
| 引用码表数 | 0 |

## 2. 字段总表

| 序号 | 字段名 | 中文名 | 类型 | 数据类型 | 长度 | 主键 | 可空 | 码表 | 取值说明 | 校验规则 | 自动取数 | 备注索引 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `INTFC_NO` | 接口编号 | FIELD | VARCHAR(32) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 2 | `MKT_SUM` | 市场合计 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 3 | `MKT_SUBTOTAL` | 市场小计 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 4 | `MKT_3` | 市场3 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 5 | `MKT_FOUR` | 市场4 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 6 | `DNMNT` | 面额 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 7 | `OVRFLWG_CLEAN_PRC` | 折溢摊净价 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 8 | `OVRFLWG_CLEAN_PRC_YIELD` | 折溢摊净价收益率 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 9 | `OVRFLWG_PRC_CORR_DURAN` | 折溢摊价格修正久期 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 10 | `PEND_PERIOD` | 待偿期 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 11 | `RATIO` | 比例 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 12 | `OVRFLWG_CLEAN_PRC_MKT_VAL` | 折溢摊净价市值 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 13 | `OVRFLWG_FULL_PRC_MKT_VAL` | 折溢摊全价市值 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 14 | `OPTION_PREM` | 期权费 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 15 | `ACCRUED_INT` | 应计利息 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 16 | `PAR_VAL_INTC_AMT` | 票面利息收入金额 | FIELD | DECIMAL(222) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 17 | `OVRFLWG` | 折溢摊 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 18 | `TRADE_PRC_DIFF` | 买卖价差 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 19 | `AL_IMPLEM_PRFT_LOSS` | 已实现损益 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 20 | `FLOT_PRFT_LOSS` | 浮动盈亏 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 21 | `FEE_SUM` | 费用总计 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 22 | `CAP_COST` | 资金成本 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 23 | `REMAIN_PRIN_AMT` | 剩余本金金额 | FIELD | DECIMAL(222) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 24 | `AVG_BAL_COST` | 平均余额成本 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 25 | `AL_IMPLEM_YIELD` | 已实现收益率 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 26 | `FLOT_YIELD` | 浮动收益率 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 27 | `TOTAL_YIELD` | 总收益率 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 28 | `ACTL_RATE` | 实际利率 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 29 | `ACTL_DAILY_RATE` | 实际日利率 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 30 | `FULL_PRC_DAILY_RATE` | 全价日利率 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 31 | `END_DAY_MKT_PRC` | 结束日市价 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 32 | `END_DAY_MKT_PRC_TYPE` | 结束日市价类型 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 33 | `START_BEF_DAY_MKT_PRC` | 起始前一日市价 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 34 | `START_BEF_DAY_MKT_PRC_TYPE` | 起始前一日市价类型 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 35 | `END_BEF_DAY_MKT_PRC` | 结束前一日市价 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 36 | `END_BEF_DAY_MKT_PRC_TYPE` | 结束前一日市价类型 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 37 | `TXN_PORTF` | 交易投组 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 38 | `PREP_TXN` | 模拟交易 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 39 | `BOND_RAT` | 债券评级 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 40 | `MAIN_RAT` | 主体评级 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 41 | `INT_RATING` | 内部评级 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 42 | `BOND_NAME` | 债券名称 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 43 | `BOND_CD` | 债券代码 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 44 | `SPPI_TEST_RESLT` | SPPI测试结果 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 45 | `FINAL_INVEST_TYPE` | 最终投向类型 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 46 | `RISK_WGT` | 风险权重 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 47 | `RISK_AST_AMT` | 风险资产金额 | FIELD | DECIMAL(222) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 48 | `INVEST_CHNL` | 投资渠道 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 49 | `UNDRLY_AST_TYPE` | 底层资产类型 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 50 | `UNDRLY_AST_BOND_CD` | 底层资产债券代码 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 51 | `CUST_MGR` | 客户经理 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 52 | `FINAL_INVEST_INDUS_BELONG` | 最终投向行业归属 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 53 | `BIZ_SCLS` | 业务小类 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 54 | `GUAR_MODE` | 担保方式 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 55 | `FIVE_TIER_CLS` | 五级分类 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 56 | `BRKEVN_FLAG` | 保本标志 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 57 | `DEBT_REDEM_TYPE` | 债基赎回类型 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 58 | `SPEC_AIM_CARR_CD` | 特定目的载体代码 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 59 | `FINAL_DEBTOR_CUST_TYPE` | 最终债务人客户类型 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 60 | `SPEC_AIM_CARR_TYPE` | 特定目的载体类型 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 61 | `ISSUER_RGN_CD` | 发行人地区码 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 62 | `ISSUER_CD` | 发行人代码 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 63 | `CRDT_TYPE` | 授信类型 | FIELD | VARCHAR(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 64 | `ETL_TIMESTAMP` | ETL时间戳 | FIELD | DATETIME | - | 否 | 允许 | - | - | - | 已上线 | - |
| 65 | `SRC_TABLE_NAME` | 源表名称 | FIELD | VARCHAR(128) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 66 | `ETL_TASK_NO` | ETL任务编号 | FIELD | VARCHAR(8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 67 | `ETL_DT` | ETL数据日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 68 | `INQUIRY_ETL_DT` | 查询数据日期 | FIELD | VARCHAR(8) | - | 否 | 允许 | - | - | - | 已上线 | - |

## 3. 补充说明

- 当前报表字段说明较简洁，无需额外补充。

## 4. 码表摘要

- 当前报表未引用码表。

