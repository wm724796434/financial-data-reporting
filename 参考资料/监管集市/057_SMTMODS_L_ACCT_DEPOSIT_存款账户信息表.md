# 存款账户信息表

> 物理表名：`L_ACCT_DEPOSIT`  
> 所属系统：监管集市

## 1. 报表首页

| 项目 | 内容 |
| --- | --- |
| 报表ID | 1994254277826388533 |
| 排序号 | 57 |
| 物理表名 | `L_ACCT_DEPOSIT` |
| 中文名 | 存款账户信息表 |
| 所属系统 | 监管集市 |
| 主题 | 账户（ACCT） |
| 频率 | 日 |
| 来源类型 | 接口 |
| 自动取数状态 | 已上线 |
| 发文号 | - |
| 生效日期 | - |
| 科目编码 | - |
| 科目名称 | - |
| 负责人 | - |
| 状态 | 正常 |
| 字段总数 | 121 |
| 字段类型分布 | `FIELD` = 121，`INDICATOR` = 0 |
| 引用码表数 | 0 |

## 2. 字段总表

| 序号 | 字段名 | 中文名 | 类型 | 数据类型 | 长度 | 主键 | 可空 | 码表 | 取值说明 | 校验规则 | 自动取数 | 备注索引 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `DATA_DATE` | 数据日期 | FIELD | INTEGER | - | 是 | 不允许 | - | - | - | 已上线 | - |
| 2 | `ACCT_NUM` | 账号 | FIELD | VARCHAR2(200) | - | 是 | 不允许 | - | - | - | 已上线 | - |
| 3 | `PRIMARY_ACCT_NUM` | 主账号 | FIELD | VARCHAR2(80) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 4 | `ORG_NUM` | 机构号 | FIELD | VARCHAR2(12) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 5 | `CUST_ID` | 客户号 | FIELD | VARCHAR2(30) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 6 | `DEPOSIT_NUM` | 存单号 | FIELD | VARCHAR2(50) | - | 是 | 不允许 | - | - | - | 已上线 | - |
| 7 | `CURR_CD` | 账户币种 | FIELD | CHAR(3) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 8 | `ACCT_TYPE` | 账户类型 | FIELD | VARCHAR2(6) | - | 否 | 允许 | - | A0001 | - | 已上线 | - |
| 9 | `ST_INT_DT` | 起息日期 | FIELD | DATE | - | 否 | 允许 | - | A0002 | - | 已上线 | - |
| 10 | `ACCT_BALANCE` | 账户余额 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 11 | `MATUR_DATE` | 到期日 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 12 | `INT_RATE_TYP` | 利率类型 | FIELD | VARCHAR2(2) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 13 | `INT_RATE` | 利率 | FIELD | NUMBER(18,6) | - | 否 | 允许 | - | A0003 | - | 已上线 | - |
| 14 | `ACCT_OPDATE_INT_RATE` | 业务发生时点实际利率 | FIELD | NUMBER(18,6) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 15 | `BASE_RATE` | 基准利率 | FIELD | NUMBER(18,6) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 16 | `ACCT_OPDATE_BASE_RATE` | 业务发生时点基准利率 | FIELD | NUMBER(18,6) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 17 | `NEXT_INT_REVI_DATE` | 下一利率重定价日 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 18 | `ACCU_INT_FLG` | 计息标志 | FIELD | CHAR(1) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 19 | `ACCT_STS` | 账户状态 | FIELD | VARCHAR2(5) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 20 | `PBOC_ACCT_NATURE_CD` | 人行账户属性 | FIELD | VARCHAR2(6) | - | 否 | 允许 | - | A0012 | - | 已上线 | - |
| 21 | `ACCT_OPDATE` | 开户日期 | FIELD | DATE | - | 否 | 允许 | - | A0011 | - | 已上线 | - |
| 22 | `OPEN_ACCT_AMT` | 开户金额 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 23 | `ACCT_CLDATE` | 销户日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 24 | `AMT` | 业务发生金额 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 25 | `LIMIT_TYPE` | 限额类型 | FIELD | CHAR(2) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 26 | `ACCOUNT_LIMIT` | 账户限额 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | A0024 | - | 已上线 | - |
| 27 | `GL_ITEM_CODE` | 科目号 | FIELD | VARCHAR2(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 28 | `LAST_TX_DATE` | 上次动户日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 29 | `TERM_TYPE` | 期限类型 | FIELD | CHAR(1) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 30 | `ACTUAL_TERM` | 实际期限 | FIELD | NUMBER(10) | - | 否 | 允许 | - | A0031 | - | 已上线 | - |
| 31 | `OPEN_TELLER` | 开户柜员号 | FIELD | VARCHAR2(30) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 32 | `ACCOUNT_CATA_FLG` | 钞汇标志 | FIELD | CHAR(1) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 33 | `SP_ACCT_TYPE` | 专项存款类型 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0032 | - | 已上线 | - |
| 34 | `ENTRUST_ACCT_TYPE` | 委托贷款基金细类 | FIELD | CHAR(4) | - | 否 | 允许 | - | A0074 | - | 已上线 | - |
| 35 | `STABLE_RISK_TYPE` | 存款稳定性分类 | FIELD | CHAR(3) | - | 否 | 允许 | - | A0037 | - | 已上线 | - |
| 36 | `BUS_REL` | 是否具有业务关系 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0079 | - | 已上线 | - |
| 37 | `PLEDGE_ASSETS_TYPE` | 担保品风险分类 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 38 | `PLEDGE_ASSETS_VAL` | 担保品市场价值 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | A0080 | - | 已上线 | - |
| 39 | `IS_INLINE_OPTIONS` | 是否内嵌提前到期期权 | FIELD | CHAR(1) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 40 | `ADVANCE_DRAW_FLG` | 是否可提前支取 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 41 | `CALL_DEPOSIT_DATE` | 通知取款日期 | FIELD | DATE | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 42 | `CALL_DEPOSIT_AMT` | 通知取款金额 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 43 | `IS_ONLINE_ABLE` | 是否网上支付账户 | FIELD | CHAR(1) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 44 | `ONLINE_LIMIT` | 网上支付限额 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 45 | `AGREEMENT_TYPE` | 协议存款人类别 | FIELD | CHAR(1) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 46 | `CREDIT_OVER_DEPOSIT_FLG` | 是否信用卡溢缴款 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0091 | - | 已上线 | - |
| 47 | `CAP_VERI_ACC_TYP` | 验资临时户种类 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 48 | `ACCT_TYPE_SAFE` | SAFE账户性质 | FIELD | CHAR(4) | - | 否 | 允许 | - | A0141 | - | 已上线 | - |
| 49 | `INTEREST_ACCURAL` | 应付利息 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | A0099 | - | 已上线 | - |
| 50 | `PRICING_BASE_TYPE` | 定价基础类型 | FIELD | VARCHAR2(5) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 51 | `C_DEPOSIT_TYPE` | 单位存款类型 | FIELD | CHAR(1) | - | 否 | 允许 | - | G0039 | - | 已上线 | - |
| 52 | `ACCT_SAFE_BAL` | 被存款保险制度覆盖的金额 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | A0110 | - | 已上线 | - |
| 53 | `BUS_REL_BAL` | 有业务关系存款金额 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 54 | `PRIMARY_ACCT_FLG` | 是否报送主账户信息 | FIELD | CHAR(1) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 55 | `SETTLEMENT_ACCT_FLG` | 是否结算账户 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 56 | `AGENT_ID` | 代理人代码 | FIELD | VARCHAR2(200) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 57 | `DEMAND_DEPOSIT_TYPE` | 个人活期存款账户类型 | FIELD | CHAR(1) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 58 | `OPEN_CHANNEL` | 开户渠道 | FIELD | VARCHAR2(2) | - | 否 | 允许 | - | A0121 | - | 已上线 | - |
| 59 | `EXAM_RESULT` | 核实结果 | FIELD | VARCHAR2(2) | - | 否 | 允许 | - | A0130 | - | 已上线 | - |
| 60 | `NO_RESULT_RESON` | 无法核实原因 | FIELD | VARCHAR2(2) | - | 否 | 允许 | - | A0127 | - | 已上线 | - |
| 61 | `DISPOSAL_METHOD` | 处置方法 | FIELD | VARCHAR2(2) | - | 否 | 允许 | - | A0128 | - | 已上线 | - |
| 62 | `PENDING_ACCOUNT` | 待核准账户标志 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0129 | - | 已上线 | - |
| 63 | `FTZ_ACCT_TYPE` | 自贸区账户类型 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 64 | `POC_INDEX_CODE` | 资产负债指标代码 | FIELD | VARCHAR2(20) | - | 否 | 允许 | - | A0081 | - | 已上线 | - |
| 65 | `ACCT_NAM` | 账户名称 | FIELD | VARCHAR2(200) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 66 | `IS_FOREIGN_LTD` | 外汇贷转存专户标志 | FIELD | CHAR(1) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 67 | `ONLINE_SIGN_PHONENO` | 网银签约手机号 | FIELD | VARCHAR2(20) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 68 | `BUSI_MAINTAIN_CHANNELS` | 业务维持渠道 | FIELD | VARCHAR2(3) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 69 | `ACC_FLAG` | 银行卡收单账户标识 | FIELD | VARCHAR2(1) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 70 | `OPENING_TYPE` | 开户标识 | FIELD | VARCHAR2(2) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 71 | `BANK_TEL` | 手机银行号码 | FIELD | VARCHAR2(16) | - | 否 | 允许 | - | A0153 | - | 已上线 | - |
| 72 | `INNER_ACCOUNT_TAG` | 银行内部账户标识 | FIELD | VARCHAR2(1) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 73 | `NONCOUNTER_CHANNEL_OPENED` | 开通的非柜面交易渠道 | FIELD | VARCHAR2(30) | - | 否 | 允许 | - | - | - | 已上线 | F73 |
| 74 | `JOINT_ACC_TYPE` | 联名账户类型 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 75 | `PBA_FLG` | 是否报送个人银行账户 | FIELD | CHAR(1) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 76 | `IS_GUAR_CAP` | 是否保本理财 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0155 | - | 已上线 | - |
| 77 | `STABLE_DEP_TYPE` | 稳定存款分类 | FIELD | VARCHAR2(3) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 78 | `TRANS_ACC_FLG` | 交易性存款账户标志 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 79 | `ACCT_TYPE_SAFE_ADD` | SAFE账户性质补充 | FIELD | CHAR(4) | - | 否 | 允许 | - | A0170 | - | 已上线 | - |
| 80 | `O_ACCT_NUM` | 外部账号 | FIELD | VARCHAR2(80) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 81 | `OTH_ACCT_TYPE` | 其他账户属性 | FIELD | VARCHAR2(30) | - | 否 | 允许 | - | A0181 | - | 已上线 | - |
| 82 | `NEXT_RATE_DATE` | 下一付息日 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 83 | `RESERVE_DEPO_TYPE` | 缴存准备金方式 | FIELD | VARCHAR2(4) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 84 | `CREDIT_OVER_DEPOSIT_TYPE` | 信用卡溢缴款类型 | FIELD | CHAR(1) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 85 | `LOWEST_YIELD_RATE` | 保底收益率 | FIELD | NUMBER(18,6) | - | 否 | 允许 | - | A0190 | - | 已上线 | - |
| 86 | `HIGHEST_YIELD_RATE` | 最高收益率 | FIELD | NUMBER(18,6) | - | 否 | 允许 | - | A0207 | - | 已上线 | - |
| 87 | `REMOTE_DEP_FLG` | 异地存款标志 | FIELD | CHAR(1) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 88 | `TIME_DEMAND_DEP_RATE` | 定活两便利率 | FIELD | NUMBER(18,6) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 89 | `DEPARTMENTD` | 归属部门 | FIELD | VARCHAR2(100) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 90 | `DATE_SOURCESD` | 数据来源 | FIELD | VARCHAR2(100) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 91 | `ACCT_STATE_DESC` | 账户状态说明 | FIELD | VARCHAR2(30) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 92 | `ACCOUNT_CATA_DESC` | 钞汇类别说明 | FIELD | VARCHAR2(12) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 93 | `INTEREST_ACCURAL_ITEM` | 应付利息科目 | FIELD | VARCHAR2(20) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 94 | `INTEREST_ACCURED` | 应计利息 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 95 | `IF_THIRD` | 是否第三方存管账户 | FIELD | CHAR(1) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 96 | `DEP_FLO_INT_RATE` | 定期存入浮动利率 | FIELD | NUMBER(18,6) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 97 | `PROD_FLO_INT_RATE` | 定期产品级浮动利率 | FIELD | NUMBER(18,6) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 98 | `INTEREST_ACCURED_ITEM` | - | FIELD | VARCHAR2(20) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 99 | `PASSBOOK_ACCT_NUM` | - | FIELD | VARCHAR2(80) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 100 | `SLEEP_ACCT_FLAG` | - | FIELD | CHAR(1) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 101 | `FIRST_ISWAGES_DT` | 首次代发工资日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 102 | `PBOC_BASE_RATE` | - | FIELD | NUMBER(18,6) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 103 | `SIG_INT_RATE` | - | FIELD | NUMBER(18,6) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 104 | `SRJE` | 收入金额 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 105 | `TQZQFX` | 提前支取罚息 | FIELD | NUMBER(20,2) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 106 | `XWQQBS` | 行为性期权标识 | FIELD | VARCHAR2(1) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 107 | `ZHZJKZQK` | 账户资金控制情况 | FIELD | VARCHAR2(2) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 108 | `JBYG_ID` | 经办员工ID | FIELD | VARCHAR2(32) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 109 | `SCYG_ID` | 审查员工ID | FIELD | VARCHAR2(32) | - | 否 | 允许 | - | T0145 | - | 已上线 | - |
| 110 | `SPYG_ID` | 审批员工ID | FIELD | VARCHAR2(32) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 111 | `GHYG_ID` | 管户员工ID | FIELD | VARCHAR2(32) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 112 | `JXFS` | 计息方式 | FIELD | VARCHAR2(2) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 113 | `TX` | 条线 | FIELD | VARCHAR2(100) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 114 | `XZLX` | 限制类型 | FIELD | VARCHAR2(100) | - | 否 | 允许 | - | T0149 | - | 已上线 | - |
| 115 | `ACCT_OPTIME` | 开户时间 | FIELD | VARCHAR2(8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 116 | `ACCT_CLTIME` | 销户时间 | FIELD | VARCHAR2(8) | - | 否 | 允许 | - | T0157 | - | 已上线 | - |
| 117 | `FST_CRE_AMT` | 最早入账金额 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 118 | `ACC_RESTRAINT_TYP` | 账户限制类型 | FIELD | VARCHAR2(100) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 119 | `ACC_RESTRAINT_TYP_DESC` | 账户限制类型描述 | FIELD | VARCHAR2(500) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 120 | `BANK_ACCOUNT_REGNO` | 银行开户登记证号 | FIELD | VARCHAR2(200) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 121 | `ISSUE_DATE` | 发证日期 | FIELD | VARCHAR2(10) | - | 否 | 允许 | - | - | - | 已上线 | - |

## 3. 补充说明

### F73 开通的非柜面交易渠道

- 字段名：`NONCOUNTER_CHANNEL_OPENED`
- 类型：FIELD
- 数据类型：VARCHAR2(30)
- 研发备注：01 网银<br>02 手机银行<br>03 ATM转账或取现<br>04 POS<br>05 其他
## 4. 码表摘要

- 当前报表未引用码表。

