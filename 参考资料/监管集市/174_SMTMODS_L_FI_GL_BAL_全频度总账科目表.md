# 全频度总账科目表

> 物理表名：`L_FI_GL_BAL`  
> 所属系统：监管集市

## 1. 报表首页

| 项目 | 内容 |
| --- | --- |
| 报表ID | 1994254277826388650 |
| 排序号 | 174 |
| 物理表名 | `L_FI_GL_BAL` |
| 中文名 | 全频度总账科目表 |
| 所属系统 | 监管集市 |
| 主题 | 财务（FINA） |
| 频率 | 日，月，季，年 |
| 来源类型 | 接口 |
| 自动取数状态 | 已上线 |
| 发文号 | - |
| 生效日期 | - |
| 科目编码 | - |
| 科目名称 | - |
| 负责人 | - |
| 状态 | 正常 |
| 字段总数 | 31 |
| 字段类型分布 | `FIELD` = 31，`INDICATOR` = 0 |
| 引用码表数 | 0 |

## 2. 字段总表

| 序号 | 字段名 | 中文名 | 类型 | 数据类型 | 长度 | 主键 | 可空 | 码表 | 取值说明 | 校验规则 | 自动取数 | 备注索引 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `ETL_TIMESTAMP` | 时间戳 | FIELD | VARCHAR2 | 8 | 否 | 允许 | - | - | - | 已上线 | - |
| 2 | `ETL_DT` | 数据日期 | FIELD | VARCHAR2 | 8 | 否 | 允许 | - | - | - | 已上线 | - |
| 3 | `DATA_DT` | 数据日期 | FIELD | VARCHAR2 | 8 | 否 | 允许 | - | - | - | 已上线 | - |
| 4 | `LP_CD` | 法人代码 | FIELD | VARCHAR2 | 10 | 否 | 允许 | - | - | - | 已上线 | - |
| 5 | `SOB_NO` | 账套编号 | FIELD | VARCHAR2 | 60 | 否 | 允许 | - | - | - | 已上线 | - |
| 6 | `BIZ_DT` | 业务日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 7 | `CURR_CD` | 币种代码 | FIELD | VARCHAR2 | 10 | 否 | 允许 | - | - | - | 已上线 | - |
| 8 | `ORG_NO` | 机构编号 | FIELD | VARCHAR2 | 60 | 否 | 允许 | - | - | - | 已上线 | - |
| 9 | `SUBJ_NO` | 科目编号 | FIELD | VARCHAR2 | 60 | 否 | 允许 | - | - | - | 已上线 | - |
| 10 | `SRC_SYS_NO` | 来源系统编号 | FIELD | VARCHAR2 | 60 | 否 | 允许 | - | - | - | 已上线 | - |
| 11 | `FINAL_LVL_SUBJ_FLAG` | 末级科目标志 | FIELD | VARCHAR2 | 10 | 否 | 允许 | - | - | - | 已上线 | - |
| 12 | `SUBJ_TYPE_CD` | 科目类型代码 | FIELD | VARCHAR2 | 10 | 否 | 允许 | - | - | - | 已上线 | - |
| 13 | `SUBJ_LVL_CD` | 科目层级代码 | FIELD | VARCHAR2 | 10 | 否 | 允许 | - | - | - | 已上线 | - |
| 14 | `BAL_DIR_CD` | 余额方向代码 | FIELD | VARCHAR2 | 10 | 否 | 允许 | - | - | - | 已上线 | - |
| 15 | `BEGIN_DEBIT_BAL` | 上期借方余额 | FIELD | NUMBER(36,8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 16 | `BEGIN_CRDT_BAL` | 上期贷方余额 | FIELD | NUMBER(36,8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 17 | `CURR_PERIOD_DEBIT_AMT` | 本期借方发生额 | FIELD | NUMBER(36,8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 18 | `CURR_PERIOD_CRDT_AMT` | 本期贷方发生额 | FIELD | NUMBER(36,8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 19 | `FINAL_DEBIT_BAL` | 本期借方余额 | FIELD | NUMBER(36,8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 20 | `FINAL_CRDT_BAL` | 本期贷方余额 | FIELD | NUMBER(36,8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 21 | `DEBIT_MONTHLY_ACCUM_BAL` | 借方月累计余额 | FIELD | NUMBER(36,8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 22 | `CRDT_MONTHLY_ACCUM_BAL` | 贷方月累计余额 | FIELD | NUMBER(36,8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 23 | `DEBIT_QUAR_CUM_BAL` | 借方季累计余额 | FIELD | NUMBER(36,8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 24 | `CRDT_QUAR_CUM_BAL` | 贷方季累计余额 | FIELD | NUMBER(36,8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 25 | `DEBIT_YEAR_CUM_BAL` | 借方年累计余额 | FIELD | NUMBER(36,8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 26 | `CRDT_YEAR_CUM_BAL` | 贷方年累计余额 | FIELD | NUMBER(36,8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 27 | `CURR_PERIOD_BAL` | 当前余额 | FIELD | NUMBER(36,8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 28 | `FINAL_LVL_FLAG` | 是否末级编码 | FIELD | VARCHAR2 | 10 | 否 | 允许 | - | - | - | 已上线 | - |
| 29 | `FREQ_CD` | 频度代码 | FIELD | VARCHAR2 | 10 | 否 | 允许 | - | - | - | 已上线 | - |
| 30 | `CRDT_HALF_QUAR_CUM_BAL` | 贷方半年累计余额 | FIELD | NUMBER(36,8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 31 | `DEBIT_HALF_YEAR_CUM_BAL` | 借方半年累计余额 | FIELD | NUMBER(36,8) | - | 否 | 允许 | - | - | - | 已上线 | - |

## 3. 补充说明

- 当前报表字段说明较简洁，无需额外补充。

## 4. 码表摘要

- 当前报表未引用码表。

