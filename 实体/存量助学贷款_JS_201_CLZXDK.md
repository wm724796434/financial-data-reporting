# 存量助学贷款（JS_201_CLZXDK）

> **说明**：该报表无金融基础数据系统原文参考，数据来源于源码实现。

## 业务分类

| 属性 | 值 |
|------|-----|
| 接口表 | `JS_201_CLZXDK` |
| 中文名 | 存量助学贷款 |
| 所属大类 | 贷款类 |

---

# 第一部分：发文原文要求（人行规范层）

该报表在金融基础数据采集规范 V2.1 原文中未收录。该程序为存量专项贷款（JS_201_CLZXYP/CLZXEP）中的助学贷款数据部分。

---

# 第二部分：代码取数业务范围（实现层）

> **用于回答"这个表实际怎么取数"、"取了哪些业务"、"业务变更对金数有什么影响"等问题**

## 1. 数据生成程序

`bsp_sp_js_201_clzxdk.prc`（加工层存储过程）

## 2. 监管集市表来源

| 表名 | 中文名 | 角色 |
|------|--------|------|
| `SMTMODS.L_ACCT_LOAN` | 贷款借据信息表 | **主表**—借据数据及票据融资筛选 |
| `SMTMODS.L_ACCT_POVERTY_RELIF` | 精准扶贫贷款补充信息 | **精准扶贫**—扶贫贷款标识及分类 |
| `SMTMODS.L_AGRE_LOAN_CONTRACT` | 贷款合同信息表 | **绿色贷款**—绿色贷款类型标识 |
| `SMTMODS.L_CUST_ALL` | 全量客户信息表 | 客户基本信息 |
| `SMTMODS.L_CUST_C` | 对公客户补充信息表 | 对公客户信息 |
| `SMTMODS.L_CUST_P` | 对私客户补充信息表 | 个人客户信息（经营性客户类型） |
| `SMTMODS.L_ACCT_LOAN_FARMING` | 涉农贷款补充信息 | 涉农贷款分类 |
| `SMTMODS.L_PUBL_RATE` | 汇率表 | 汇率折算 |
| `SMTMODS.M_INDEX_SNDK_MAPPING` | 涉农贷款分类映射表 | 对公转个人涉农分类映射 |

## 3. 输出接口表

`JS_201_CLZXDK` — 存量专项贷款（含精准扶贫、绿色贷款、涉农贷款、创业担保、票据融资）

## 4. 业务筛选条件

### 4.1 基础数据来源

从存量单位贷款（`PBOCD_JS_201_CLDWDK`）和存量个人贷款（`PBOCD_JS_201_CLGRDK`）取借据信息做全量基础数据：

```sql
INSERT INTO JS_201_CLZXDK_TMP01
  SELECT DISTINCT T.LOAN_NUM, T.CONTRACT_CODE
    FROM PBOCD_JS_201_CLDWDK T WHERE T.DATA_DATE = ...
  UNION ALL
  SELECT DISTINCT T.LOAN_NUM, T.CONTRACT_CODE
    FROM PBOCD_JS_201_CLGRDK T WHERE T.DATA_DATE = ...
```

### 4.2 个人客户过滤

经营类客户类型过滤条件：

```sql
WHERE P.OPERATE_CUST_TYPE IN ('A', 'B')  -- A: 个体工商户, B: 小微企业主
```

对私客户中`CUST_TYP = '3'`（个体工商户）也纳入处理。

### 4.3 绿色贷款筛选条件

```sql
WHERE A.GREEN_LOAN_TYPE IS NOT NULL  -- 绿色贷款类型不为空
```

### 4.4 票据融资筛选

科目条件：
```sql
WHERE T.ITEM_CD IN ('130101', '130104')  -- 票据融资科目
  AND T.CANCEL_FLG = 'N'       -- 去除核销
  AND T.LOAN_ACCT_BAL > 0      -- 余额大于0
  AND T.LOAN_STOCKEN_DATE IS NULL  -- 资产未转让
```

### 4.5 创业担保筛选

```sql
WHERE T.UNDERTAK_GUAR_TYPE <> '#' AND T.UNDERTAK_GUAR_TYPE IS NOT NULL
```

### 4.6 精准扶贫

扶贫贷款数据插入`JZFPDK`表，包含贷款发放金额、余额、利率、五级分类等27个字段。

## 5. 特殊处理规则

### 5.1 经营性客户分类

个人客户维度同时从`L_CUST_P`（OPERATE_CUST_TYPE）和`L_CUST_C`（CUST_TYP='3'）两处获取个体工商户标识，合并去重。

### 5.2 涉农贷款分类映射

对公客户的涉农贷款分类（SNDKFL）通过`M_INDEX_SNDK_MAPPING`映射表转为个人涉农贷款分类，用于区分对公/个人客户维度。

## 6. 历史变更记录

| 编号 | 日期 | 修改人 | 修改原因 |
|------|------|--------|---------|
| JLBA202502130004 | 2025-03-27 | 周立鹏 | 制度升级2025 |

## 7. 涉及源码文件

| 角色 | 文件路径 |
|------|---------|
| 数据生成（主程序） | `源码/加工层存储/bsp_sp_js_201_clzxdk.prc` |
| 数据生成（解析版） | `源码解析/加工层存储/bsp_sp_js_201_clzxdk.prc` |
