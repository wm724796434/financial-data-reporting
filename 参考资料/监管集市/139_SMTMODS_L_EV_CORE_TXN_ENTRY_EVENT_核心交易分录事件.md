# 核心交易分录事件

> 物理表名：`L_EV_CORE_TXN_ENTRY_EVENT`  
> 所属系统：监管集市

## 1. 报表首页

| 项目 | 内容 |
| --- | --- |
| 报表ID | 1994254277826388615 |
| 排序号 | 139 |
| 物理表名 | `L_EV_CORE_TXN_ENTRY_EVENT` |
| 中文名 | 核心交易分录事件 |
| 所属系统 | 监管集市 |
| 主题 | 交易（TRAN） |
| 频率 | 日 |
| 来源类型 | 接口 |
| 自动取数状态 | 已上线 |
| 发文号 | - |
| 生效日期 | - |
| 科目编码 | - |
| 科目名称 | - |
| 负责人 | - |
| 状态 | 正常 |
| 字段总数 | 52 |
| 字段类型分布 | `FIELD` = 52，`INDICATOR` = 0 |
| 引用码表数 | 0 |

## 2. 字段总表

| 序号 | 字段名 | 中文名 | 类型 | 数据类型 | 长度 | 主键 | 可空 | 码表 | 取值说明 | 校验规则 | 自动取数 | 备注索引 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `event_no` | 事件编号 | FIELD | varchar(48) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 2 | `lp_org_no` | 法人机构编号 | FIELD | varchar(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 3 | `txn_uniq_ref_no` | 交易唯一参考号码 | FIELD | varchar(48) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 4 | `cont_uniq_ref_no` | 合同唯一参考号码 | FIELD | decimal(30,0) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 5 | `cont_mdl_happ_event_name` | 合同中发生事件名称 | FIELD | varchar(12) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 6 | `acct_brch_no` | 账户分行编号 | FIELD | varchar(12) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 7 | `subj_no` | 科目编号 | FIELD | varchar(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 8 | `acct_curr_cd` | 账户币种代码 | FIELD | varchar(9) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 9 | `debit_or_crdt_index` | 借方或贷方指标 | FIELD | varchar(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 10 | `acctn_entry_affair_cd` | 会计分录事务代码 | FIELD | varchar(9) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 11 | `entrs_pass_amt_label` | 条目通过金额标签 | FIELD | varchar(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 12 | `txn_amt` | 交易金额 | FIELD | varchar(20) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 13 | `corr_dcurr_exch_rate` | 对本币汇率 | FIELD | decimal(18,6) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 14 | `dcurr_amt` | 本币金额 | FIELD | varchar(20) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 15 | `cust_no` | 客户编号 | FIELD | varchar(27) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 16 | `acct_no` | 账户编号 | FIELD | varchar(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 17 | `cont_ref_no` | 合同参考号码 | FIELD | varchar(48) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 18 | `mis_cd_is_addit_to_txn_idnt` | MIS代码是否附加到交易标识 | FIELD | varchar(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 19 | `mis_txn_princ` | MIS交易负责人 | FIELD | varchar(27) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 20 | `txn_dt` | 交易日期 | FIELD | varchar(30) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 21 | `record_dt` | 入账日期 | FIELD | varchar(30) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 22 | `txn_init_start_dt` | 交易初始开始日期 | FIELD | varchar(30) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 23 | `txn_fin_period` | 交易金融周期 | FIELD | varchar(27) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 24 | `acctn_entry_duran_cd` | 会计分录期间代码 | FIELD | varchar(9) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 25 | `voch_status_cd` | 凭证状态码 | FIELD | varchar(120) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 26 | `bank_no` | 银行编号 | FIELD | varchar(36) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 27 | `gl_acct_type_cd` | 总账科目类型代码 | FIELD | varchar(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 28 | `subj_type_cd` | 科目类型代码 | FIELD | varchar(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 29 | `acctn_tran_acct` | 会计传递账户 | FIELD | varchar(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 30 | `txn_cont_module_cd` | 交易合约模块代码 | FIELD | varchar(6) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 31 | `cont_mdl_happ_event_no` | 合同中发生事件号码 | FIELD | decimal(30,0) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 32 | `indicate_entrs` | 指示条目 | FIELD | varchar(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 33 | `position_status_flag` | 位置状态标志 | FIELD | varchar(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 34 | `mis_update_flag` | MIS更新标志 | FIELD | varchar(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 35 | `txn_user_id` | 交易用户ID | FIELD | varchar(36) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 36 | `curr_ser_no` | 当前流水号 | FIELD | decimal(30,0) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 37 | `txn_exc_batch_seq_no` | 交易执行批次号 | FIELD | varchar(57) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 38 | `print_status_cd` | 打印状态代码 | FIELD | varchar(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 39 | `curr_not_fit` | 目前不适用 | FIELD | varchar(3) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 40 | `txn_authr_user_flag` | 交易授权者用户标志 | FIELD | varchar(36) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 41 | `prod_cd` | 产品代码 | FIELD | varchar(15) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 42 | `val_update_flag` | 值更新标志 | FIELD | varchar(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 43 | `txn_ext_ref_no` | 交易外部参考号码 | FIELD | varchar(105) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 44 | `acctn_entrs_dsply_idnt` | 会计条目显示标识 | FIELD | varchar(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 45 | `not_include_ic_card_bal` | 不包含IC卡余额 | FIELD | decimal(18,4) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 46 | `aml_excep` | 反洗钱异常 | FIELD | varchar(3) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 47 | `txn_desc` | 交易描述 | FIELD | varchar(120) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 48 | `biz_cd` | 业务代码 | FIELD | decimal(10,0) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 49 | `etl_timestamp` | ETL时间戳 | FIELD | datetime | - | 否 | 允许 | - | - | - | 已上线 | - |
| 50 | `src_table_name` | 源表名称 | FIELD | varchar(128) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 51 | `etl_task_no` | ETL任务编号 | FIELD | varchar(8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 52 | `etl_dt` | ETL数据日期 | FIELD | date | - | 否 | 允许 | - | - | - | 已上线 | - |

## 3. 补充说明

- 当前报表字段说明较简洁，无需额外补充。

## 4. 码表摘要

- 当前报表未引用码表。

