# 抵质押物详细信息

> 物理表名：`L_AGRE_GUARANTY_INFO`  
> 所属系统：监管集市

## 1. 报表首页

| 项目 | 内容 |
| --- | --- |
| 报表ID | 1994254277826388517 |
| 排序号 | 41 |
| 物理表名 | `L_AGRE_GUARANTY_INFO` |
| 中文名 | 抵质押物详细信息 |
| 所属系统 | 监管集市 |
| 主题 | 协议（AGRE） |
| 频率 | 日 |
| 来源类型 | 接口 |
| 自动取数状态 | 已上线 |
| 发文号 | - |
| 生效日期 | - |
| 科目编码 | - |
| 科目名称 | - |
| 负责人 | - |
| 状态 | 正常 |
| 字段总数 | 73 |
| 字段类型分布 | `FIELD` = 73，`INDICATOR` = 0 |
| 引用码表数 | 0 |

## 2. 字段总表

| 序号 | 字段名 | 中文名 | 类型 | 数据类型 | 长度 | 主键 | 可空 | 码表 | 取值说明 | 校验规则 | 自动取数 | 备注索引 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `DATA_DATE` | 数据日期 | FIELD | INT | - | 是 | 允许 | - | - | - | 已上线 | - |
| 2 | `GUARANTEE_SERIAL_NUM` | 押品编号 | FIELD | VARCHAR2(30) | - | 是 | 允许 | - | - | - | 已上线 | - |
| 3 | `GUARANTOR_CUST_ID` | 出质人客户号 | FIELD | VARCHAR2(30) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 4 | `ORG_NUM` | 机构号 | FIELD | VARCHAR2(12) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 5 | `COLL_STATUS` | 押品状态 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 6 | `COLL_TYP` | 押品类型 | FIELD | CHAR(5) | - | 否 | 允许 | - | G0004 | - | 已上线 | - |
| 7 | `COLL_NAME` | 押品名称 | FIELD | VARCHAR2(400) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 8 | `COLL_CCY` | 币种 | FIELD | CHAR(3) | - | 否 | 允许 | - | A0001 | - | 已上线 | - |
| 9 | `COLL_ORG_VAL` | 押品原始价值 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 10 | `COLL_MK_VAL` | 押品市场价值 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 11 | `MORTGAGE_RATIO` | 审批抵质押率 | FIELD | NUMBER(18,6) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 12 | `COLL_OWNER_TYP` | 押品权属人类型 | FIELD | CHAR(1) | - | 否 | 允许 | - | C0061 | - | 已上线 | - |
| 13 | `COLL_CARD_TYP` | 产权证类型 | FIELD | CHAR(4) | - | 否 | 允许 | - | A0124 | - | 已上线 | - |
| 14 | `COLL_CARD_NO` | 产权证号码 | FIELD | VARCHAR2(200) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 15 | `COLL_CARD_TYP_2` | 产权证类型2 | FIELD | CHAR(4) | - | 否 | 允许 | - | A0124 | - | 已上线 | - |
| 16 | `COLL_CARD_NO_2` | 产权证号码2 | FIELD | VARCHAR2(200) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 17 | `FIRST_ASSESS_DT` | 首次评估日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 18 | `NEWLY_ASSESS_DT` | 最新评估日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 19 | `ASSESS_MATURITY_DT` | 评估到期日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 20 | `ASSESS_ORG_NAM` | 评估机构名称 | FIELD | VARCHAR2(80) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 21 | `REGISTER_ORG_CODE` | 登记机关号码 | FIELD | VARCHAR2(30) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 22 | `REGISTER_DT` | 登记日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 23 | `COLL_START_DT` | 押品生效日 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 24 | `COLL_END_DT` | 押品到期日 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 25 | `COLL_EXPIRY_DT` | 押品失效日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 26 | `OBJECT_RECEIVE_DT` | 实物收取日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 27 | `DEP_CURR` | 存单币种 | FIELD | CHAR(3) | - | 否 | 允许 | - | A0001 | - | 已上线 | - |
| 28 | `DEP_AMT` | 存单金额 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 29 | `DEP_MATURITY` | 存单到期日 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 30 | `COLL_BILL_ACCT` | 质押票证账号 | FIELD | VARCHAR2(80) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 31 | `COLL_BILL_TYPE` | 质押票证类型 | FIELD | VARCHAR2(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 32 | `COLL_BILL_NUM` | 质押票证号码 | FIELD | VARCHAR2(300) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 33 | `BILL_BANK_CODE` | 质押票证签发机构 | FIELD | VARCHAR2(30) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 34 | `COLL_BILL_AMOUNT` | 质押票证金额 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 35 | `COLL_BILL_OPEN_DT` | 质押票证开立日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 36 | `INSURE_NUM` | 保险单号 | FIELD | VARCHAR2(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 37 | `CHECK_DATE` | 核保日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 38 | `CHECK_NAME1` | 核保人一姓名 | FIELD | VARCHAR2(100) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 39 | `CHECK_NAME2` | 核保人二姓名 | FIELD | VARCHAR2(100) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 40 | `WARRANT_CODE` | 权证登记号码 | FIELD | VARCHAR2(300) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 41 | `WARRANT_NAME` | 权证名称 | FIELD | VARCHAR2(200) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 42 | `WARRANT_MATU_DATE` | 权证有效到期日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 43 | `REG_DUE_DATE` | 登记有效终止日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 44 | `ACCOUNT_FLG` | 是否纳入表外核算 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 45 | `ACCOUNT_BEG_DATE` | 表外核算开始日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 46 | `USED_PRICE` | 已抵押价值 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 47 | `COLL_VAL` | 抵押物价值 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 48 | `IS_RECOLL_FLG` | 押品是否可再质（抵）押融资 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 49 | `CUS_RISK_LEV` | 担保品客户风险评级分类 | FIELD | CHAR(5) | - | 否 | 允许 | - | C0072 | - | 已上线 | - |
| 50 | `DIR_PUR_FLG` | 定向收购标志 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 51 | `QUALIFY_ASSET_FLG` | 合格缓释品标志 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 52 | `COLL_TYPE_NAME` | 押品分类名称 | FIELD | VARCHAR2(300) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 53 | `MORTGAGE_RATIO_EAST` | 质或抵押率 | FIELD | NUMBER(18,6) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 54 | `ASSESS_ORG_TYPE` | 评估机构类型 | FIELD | CHAR(1) | - | 否 | 允许 | - | C0121 | - | 已上线 | - |
| 55 | `PAY_CUST_ID` | 偿付方客户号 | FIELD | VARCHAR2(40) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 56 | `IS_BANK` | 偿付方是否我行 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 57 | `COLL_PRO_TYPE` | 押品项目类别 | FIELD | VARCHAR2(7) | - | 否 | 允许 | - | A0188 | - | 已上线 | - |
| 58 | `value_cycle` | 估值周期 | FIELD | VARCHAR2(2) | - | 否 | 允许 | - | A0196 | - | 已上线 | - |
| 59 | `ASSESS_WAY` | 评估方法 | FIELD | VARCHAR2(2) | - | 否 | 允许 | - | A0197 | - | 已上线 | - |
| 60 | `DEPARTMENTD` | 归属部门 | FIELD | VARCHAR2(100) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 61 | `DATE_SOURCESD` | 数据来源 | FIELD | VARCHAR2(100) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 62 | `MOTGA_PROPT_ID_TYPE` | 抵押物识别号类型 | FIELD | CHAR(1) | - | 否 | 允许 | - | C0122 | - | 已上线 | - |
| 63 | `PLE_CERT_ID` | 抵押物唯一识别号 | FIELD | VARCHAR2(40) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 64 | `AGRO_RELA_MAT_FLG` | 是否涉农质物 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0010 | - | 已上线 | - |
| 65 | `PPTY_AREA` | 房产面积 | FIELD | NUMBER(20,4) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 66 | `COLL_STATUS_SUB` | 押品状态细类 | FIELD | CHAR(1) | - | 否 | 允许 | - | A0241 | - | 已上线 | - |
| 67 | `COLL_STATUS_SUB_DESC` | 押品状态细类说明 | FIELD | VARCHAR2(20) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 68 | `COLL_PRO_TYPE_DESC` | 押品项目类别说明 | FIELD | VARCHAR2(50) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 69 | `JZ_HOUSE_LAND_NUM` | 居住用房房产证（不动产权证号） | FIELD | varchar2(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 70 | `JZ_BUSINESS_HOUSE_NUM` | 住用房表房地产买卖合同编号 | FIELD | varchar2(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 71 | `SY_HOUSE_LAND_NUM` | 商业用房、工业用房房产证（不动产权证号） | FIELD | varchar2(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 72 | `SY_BUSINESS_HOUSE_NUM` | 商业用房、工业用房表房地产买卖合同编号 | FIELD | varchar2(1000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 73 | `YPDZYL` | 押品抵质押率 | FIELD | decimal(20,10) | - | 否 | 允许 | - | - | - | 已上线 | - |

## 3. 补充说明

- 当前报表字段说明较简洁，无需额外补充。

## 4. 码表摘要

- 当前报表未引用码表。

