# 客户联系信息

> 物理表名：`L_CUST_CONTACT`  
> 所属系统：监管集市

## 1. 报表首页

| 项目 | 内容 |
| --- | --- |
| 报表ID | 1994254277826388479 |
| 排序号 | 3 |
| 物理表名 | `L_CUST_CONTACT` |
| 中文名 | 客户联系信息 |
| 所属系统 | 监管集市 |
| 主题 | 客户（CUST） |
| 频率 | 日 |
| 来源类型 | 接口 |
| 自动取数状态 | 已上线 |
| 发文号 | - |
| 生效日期 | - |
| 科目编码 | - |
| 科目名称 | - |
| 负责人 | - |
| 状态 | 正常 |
| 字段总数 | 27 |
| 字段类型分布 | `FIELD` = 27，`INDICATOR` = 0 |
| 引用码表数 | 2 |

## 2. 字段总表

| 序号 | 字段名 | 中文名 | 类型 | 数据类型 | 长度 | 主键 | 可空 | 码表 | 取值说明 | 校验规则 | 自动取数 | 备注索引 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `DATA_DATE` | 数据日期 | FIELD | INT | - | 是 | 允许 | - | - | - | 已上线 | - |
| 2 | `CUST_ID` | 客户号 | FIELD | VARCHAR2(30) | - | 是 | 允许 | - | - | - | 已上线 | - |
| 3 | `CUST_ADDE_DESC` | 通讯地址 | FIELD | VARCHAR2(400) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 4 | `CUST_ADDE_DESC_CODE` | 通讯地址邮政编码 | FIELD | CHAR(6) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 5 | `BORROWER_REGISTER_ADDR` | 注册地址 | FIELD | VARCHAR2(400) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 6 | `BORROWER_EMAIL` | EMAIL地址 | FIELD | VARCHAR2(30) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 7 | `CUST_TELEPHONE_NO` | 联系电话 | FIELD | VARCHAR2(50) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 8 | `FAX_NO` | 传真 | FIELD | VARCHAR2(35) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 9 | `HAND_PHONE_NO` | 手机号码 | FIELD | VARCHAR2(16) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 10 | `CORP_ADDRESS` | 单位地址 | FIELD | VARCHAR2(400) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 11 | `CORP_POST_NO` | 单位地址邮政编码 | FIELD | CHAR(6) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 12 | `CORP_PHONE_NO` | 单位电话 | FIELD | VARCHAR2(50) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 13 | `INHABITANCY_ADDRESS` | 居住地址 | FIELD | VARCHAR2(400) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 14 | `INHABITANCY_POST_NO` | 居住地址邮政编码 | FIELD | CHAR(6) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 15 | `REGISTER_ADDRESS` | 户籍地址 | FIELD | VARCHAR2(400) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 16 | `DEPARTMENTD` | 归属部门 | FIELD | VARCHAR2(100) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 17 | `DATE_SOURCESD` | 数据来源 | FIELD | VARCHAR2(100) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 18 | `FINANCIAL_DEP_CONTACT_DESC1` | 财务部联系电话 | FIELD | VARCHAR2(35) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 19 | `REGISTER_AREA` | 户籍所在地行政区划 | FIELD | VARCHAR2(6) | - | 否 | 允许 | `C0120` 行政区划代码_2007 | 行政区划代码_2007 | - | 已上线 | - |
| 20 | `CORP_AREA` | 单位所在地行政区划 | FIELD | VARCHAR2(6) | - | 否 | 允许 | `C0120` 行政区划代码_2007 | 行政区划代码_2007 | - | 已上线 | - |
| 21 | `INHABITANCY_AREA` | 居住地行政区划 | FIELD | VARCHAR2(6) | - | 否 | 允许 | `C0120` 行政区划代码_2007 | 行政区划代码_2007 | - | 已上线 | - |
| 22 | `CUST_ADDE_AREA` | 通讯地行政区划 | FIELD | VARCHAR2(6) | - | 否 | 允许 | `C0120` 行政区划代码_2007 | 行政区划代码_2007 | - | 已上线 | - |
| 23 | `UNIT_NATURE` | 单位性质 | FIELD | CHAR(1) | - | 否 | 允许 | `C0182` | C0182 | - | 已上线 | - |
| 24 | `UNIT_NATURE_ADD` | 单位性质说明 | FIELD | VARCHAR2(50) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 25 | `INHABITANCY_PHONE_NO` | 居住电话 | FIELD | varchar(80) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 26 | `INHABITANCY_ADDRESS_EN` | 居住地址英文 | FIELD | VARCHAR2(400) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 27 | `BORROWER_REGISTER_ADDR_EN` | 注册地址地址英文 | FIELD | VARCHAR2(400) | - | 否 | 允许 | - | - | - | 已上线 | - |

## 3. 补充说明

- 当前报表字段说明较简洁，无需额外补充。

## 4. 码表摘要

| 码表编码 | 码表名称 | 使用字段数 | 说明 | 是否展开明细 |
| --- | --- | --- | --- | --- |
| `C0120` | 行政区划代码_2007 | 4 | - | 否 |
| `C0182` | - | 1 | - | 是 |

### C0182

- 使用字段：`UNIT_NATURE`
- 码表说明：-
- 码值数量：0

> 未查询到该码表的码值明细。

