# 关联方管理信息表

> 物理表名：`L_RELATION_STOCKHOLDER_ADD`  
> 所属系统：监管集市

## 1. 报表首页

| 项目 | 内容 |
| --- | --- |
| 报表ID | 1994254277826388928 |
| 排序号 | 184 |
| 物理表名 | `L_RELATION_STOCKHOLDER_ADD` |
| 中文名 | 关联方管理信息表 |
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
| 字段总数 | 36 |
| 字段类型分布 | `FIELD` = 36，`INDICATOR` = 0 |
| 引用码表数 | 0 |

## 2. 字段总表

| 序号 | 字段名 | 中文名 | 类型 | 数据类型 | 长度 | 主键 | 可空 | 码表 | 取值说明 | 校验规则 | 自动取数 | 备注索引 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `DATA_DATE` | - | FIELD | INT(11) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 2 | `RELATION_ID` | 关联方id | FIELD | VARCHAR(32) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 3 | `ORG_ID` | 机构ID | FIELD | VARCHAR(64) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 4 | `RELATION_NAME` | 关联方名称 | FIELD | VARCHAR(300) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 5 | `MAIN_TYPE` | 关联方类型 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | F5 |
| 6 | `DOCUMENT_TYPE` | 关联方证件类型 | FIELD | VARCHAR(100) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 7 | `DOCUMENT_NO` | 关联方证件号码 | FIELD | VARCHAR(100) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 8 | `BUSINESS_TYPE` | 行业类型 | FIELD | VARCHAR(100) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 9 | `REGISTER_ADDRESS` | 注册地址 | FIELD | VARCHAR(3000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 10 | `CONTROL_NAME` | 实际控制人名称 | FIELD | VARCHAR(300) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 11 | `BANK_COUNT` | 参股商业银行的数量 | FIELD | DECIMAL(100) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 12 | `BANK_NUM` | 控股商业银行的数量 | FIELD | DECIMAL(100) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 13 | `BAD_INFO` | 不良信息 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | F13 |
| 14 | `LIMIT_FLAG` | 是否限权 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | F14 |
| 15 | `MONEY_SOURCE` | 入股资金来源 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | F15 |
| 16 | `SOURCE_ACOUNT` | 入股资金账号 | FIELD | VARCHAR(3000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 17 | `STOCKHOLDER_NUM` | 股东持股数量 | FIELD | DECIMAL(100) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 18 | `STOCKHOLDER_SCALE` | 股东持股比例 | FIELD | VARCHAR(64) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 19 | `INCOME_DATE` | 入股日期 | FIELD | DATETIME | - | 否 | 允许 | - | - | - | 已上线 | - |
| 20 | `PLEDGE_RATIO` | 股东股权质押比例 | FIELD | VARCHAR(64) | - | 否 | 允许 | - | - | - | 已上线 | F20 |
| 21 | `SEND_FLAG` | 是否派驻董监事 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | F21 |
| 22 | `LAST_CHANGE` | 最近一次变动日期 | FIELD | DATETIME | - | 否 | 允许 | - | - | - | 已上线 | - |
| 23 | `COLLECT_DATE` | 采集日期 | FIELD | DATETIME | - | 否 | 允许 | - | - | - | 已上线 | - |
| 24 | `REVIEW_MAN` | 审核人 | FIELD | VARCHAR(64) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 25 | `USER_ID` | 用户ID | FIELD | VARCHAR(32) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 26 | `DEPT_ID` | 部门ID | FIELD | VARCHAR(32) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 27 | `VIEW_STATUS` | 显示状态 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 28 | `REVIEW_OPINION` | 审核意见 | FIELD | VARCHAR(3000) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 29 | `STATUS` | 状态;1启用0停用 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 30 | `CREATE_BY` | 创建人 | FIELD | VARCHAR(32) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 31 | `CREATE_TIME` | 创建时间 | FIELD | DATETIME | - | 否 | 允许 | - | - | - | 已上线 | - |
| 32 | `UPDATE_BY` | 更新人 | FIELD | VARCHAR(32) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 33 | `UPDATE_TIME` | 更新时间 | FIELD | DATETIME | - | 否 | 允许 | - | - | - | 已上线 | - |
| 34 | `RELA` | - | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 35 | `DOCTYP` | - | FIELD | VARCHAR(100) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 36 | `SHAREHD_OR_RELAT_PTY_DSPLY_ID` | 股东或关联方显示ID | FIELD | VARCHAR(100) | - | 否 | 允许 | - | - | - | 已上线 | - |

## 3. 补充说明

### F5 关联方类型

- 字段名：`MAIN_TYPE`
- 类型：FIELD
- 数据类型：VARCHAR(10)
- 研发备注：1-自然人（中国公民）2-自然人（非中国公民）3-境内非金融机构、境内银行业金融机构、境内非银行金融机构、境外银行4-金融产品5-纯国有企业、国有控股企业6-国有参股企业7-民营企业8-政府机关、事业单位9-社会团体0-中外合资企业、外商独资企业、境外机构11-其他
### F13 不良信息

- 字段名：`BAD_INFO`
- 类型：FIELD
- 数据类型：VARCHAR(10)
- 研发备注：1-被列为相关部门失信联合惩戒对象2-存在严重逃废银行债务行为3-提供虚假材料或者作不实声明4-对商业银行经营失败或重大违法违规行为负有重大责任5-拒绝或阻碍金融监管总局或其派出机构依法实施监管6-因违法违规行为被金融监管部门或政府有关部门查处造成恶劣影响7-其他可能对商业银行经营管理产生不利影响的情形0-不存在不良信息情况
### F14 是否限权

- 字段名：`LIMIT_FLAG`
- 类型：FIELD
- 数据类型：VARCHAR(10)
- 研发备注：1是0否
### F15 入股资金来源

- 字段名：`MONEY_SOURCE`
- 类型：FIELD
- 数据类型：VARCHAR(10)
- 研发备注：1-自有资金2-委托资金3-债务资金4-其他
### F20 股东股权质押比例

- 字段名：`PLEDGE_RATIO`
- 类型：FIELD
- 数据类型：VARCHAR(64)
- 研发备注：单位%
### F21 是否派驻董监事

- 字段名：`SEND_FLAG`
- 类型：FIELD
- 数据类型：VARCHAR(10)
- 研发备注：1是0否
## 4. 码表摘要

- 当前报表未引用码表。

