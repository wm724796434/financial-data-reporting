# 家庭成员表

> 物理表名：`L_CUST_FAMILY_MAJOR`  
> 所属系统：监管集市

## 1. 报表首页

| 项目 | 内容 |
| --- | --- |
| 报表ID | 1994254277826388929 |
| 排序号 | 185 |
| 物理表名 | `L_CUST_FAMILY_MAJOR` |
| 中文名 | 家庭成员表 |
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
| 字段总数 | 47 |
| 字段类型分布 | `FIELD` = 47，`INDICATOR` = 0 |
| 引用码表数 | 0 |

## 2. 字段总表

| 序号 | 字段名 | 中文名 | 类型 | 数据类型 | 长度 | 主键 | 可空 | 码表 | 取值说明 | 校验规则 | 自动取数 | 备注索引 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | `FAMILY_MEM_NO` | 家庭成员编号 | FIELD | VARCHAR(32) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 2 | `CUST_NO` | 客户编号 | FIELD | VARCHAR(60) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 3 | `LP_ORG_NO` | 法人机构编号 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 4 | `MEM_AND_CUST_RELA_TYPE_CD` | 成员与客户关系类型代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 5 | `MEM_NAME` | 成员姓名 | FIELD | VARCHAR(500) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 6 | `MEM_DOCTYP_CD` | 成员证件类型代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 7 | `MEM_DOC_NO` | 成员证件号码 | FIELD | VARCHAR(80) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 8 | `MEM_DOC_EFFECT_DAY_PERIOD` | 成员证件生效日期 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 9 | `MEM_CERT_EXP_DAY_PERIOD` | 成员证件到期日期 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 10 | `MEM_LIC_AUTH` | 成员发证机关 | FIELD | VARCHAR(500) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 11 | `MEM_NATION_CD` | 成员国籍代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 12 | `MEM_ETHNIC_CD` | 成员民族代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 13 | `MEM_GENDER_CD` | 成员性别代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 14 | `MEM_AGE` | 成员年龄 | FIELD | DECIMAL(300) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 15 | `MEM_CAREER_CD` | 成员职业代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 16 | `MEM_TITLE_CD` | 成员职称代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 17 | `MEM_POS_CD` | 成员职务代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 18 | `MEM_BIRTH_DT` | 成员出生日期 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 19 | `MEM_MOBILE_NO_CD` | 成员手机号码 | FIELD | VARCHAR(40) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 20 | `MEM_FIXLINE_TEL` | 成员固定电话 | FIELD | VARCHAR(40) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 21 | `MEM_HIGHST_DEG_CD` | 成员最高学历代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 22 | `MEM_MAX_ACADEM_DEG_CD` | 成员最高学位代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 23 | `MEM_EMAIL` | 成员电子邮箱 | FIELD | VARCHAR(500) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 24 | `MEM_RESDN_ADDR` | 成员户籍地址 | FIELD | VARCHAR(500) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 25 | `MEM_DWLG_ADDR` | 成员居住住址 | FIELD | VARCHAR(500) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 26 | `MEM_CORP_ADDR` | 成员公司地址 | FIELD | VARCHAR(500) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 27 | `MEM_JOIN_WORK_YEAR` | 成员参加工作年份 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 28 | `MEM_TH_CORP_WORK_DURAN` | 成员本单位工作时长 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 29 | `MEM_MONTHLY_INCOME_AMT` | 成员月收入金额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 30 | `MEM_ANL_INCOME_AMT` | 成员年收入金额 | FIELD | DECIMAL(302) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 31 | `MEM_EMPLYER` | 成员工作单位 | FIELD | VARCHAR(300) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 32 | `MEM_EMPLYER_TEL` | 成员工作单位电话 | FIELD | VARCHAR(40) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 33 | `MEM_EMPLYER_INDS_CD` | 成员工作单位所属行业代码 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 34 | `EFFECT_FLAG` | 有效标志 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 35 | `REM` | 备注 | FIELD | VARCHAR(300) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 36 | `FINAL_UPDATE_SYS` | 最后更新系统 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 37 | `FINAL_UPDATE_ORG` | 最后更新机构 | FIELD | VARCHAR(30) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 38 | `FINAL_UPDATE_TELR` | 最后更新柜员 | FIELD | VARCHAR(30) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 39 | `FINAL_UPDATE_DT` | 最后更新日期 | FIELD | VARCHAR(10) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 40 | `FINAL_UPDATE_TM` | 最后更新时间 | FIELD | VARCHAR(100) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 41 | `ETL_TIMESTAMP` | ETL时间戳 | FIELD | DATETIME | - | 否 | 允许 | - | - | - | 已上线 | - |
| 42 | `SRC_TABLE_NAME` | 源表名称 | FIELD | VARCHAR(128) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 43 | `ETL_TASK_NO` | ETL任务编号 | FIELD | VARCHAR(16) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 44 | `CREATE_DT` | 创建日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 45 | `UPDATE_DT` | 更新日期 | FIELD | DATE | - | 否 | 允许 | - | - | - | 已上线 | - |
| 46 | `DATA_DATE` | ETL数据日期 | FIELD | VARCHAR(8) | - | 否 | 允许 | - | - | - | 已上线 | - |
| 47 | `ID_MARK` | 增删标志 | FIELD | VARCHAR(1) | - | 否 | 允许 | - | - | - | 已上线 | - |

## 3. 补充说明

- 当前报表字段说明较简洁，无需额外补充。

## 4. 码表摘要

- 当前报表未引用码表。

