# 小额企业信息（JS_102_XDQYXX）

> **说明**：该报表无金融基础数据系统原文参考，数据来源于源码实现。

## 业务分类

| 属性 | 值 |
|------|-----|
| 接口表 | `JS_102_XDQYXX` |
| 中文名 | 小额企业信息 |
| 所属大类 | 客户信息类 |

---

# 第一部分：发文原文要求（人行规范层）

该报表在金融基础数据采集规范 V2.1 原文中未收录。

---

# 第二部分：代码取数业务范围（实现层）

> **用于回答"这个表实际怎么取数"、"取了哪些业务"、"业务变更对金数有什么影响"等问题**

## 1. 数据生成程序

`bsp_sp_js_102_xdqyxx.prc`（加工层存储过程）

## 2. 监管集市表来源

| 表名 | 中文名 | 角色 |
|------|--------|------|
| `SMTMODS.L_CUST_ALL` | 全量客户信息表 | **主表**—取客户机构号、证件类型、证件代码 |
| `SMTMODS.L_CUST_C_FINREPINFO` | 贷款客户财务报表资料 | **财务数据**—取会计报表类型及各项财务指标 |

## 3. 输出接口表

`PBOCD_JS_102_XDQYXX` — 信贷企业基础信息表（40个字段）

## 4. 业务筛选条件

### 4.1 数据来源

从 `SMTMODS.L_CUST_ALL` 取客户基本信息（机构号、证件信息），从 `SMTMODS.L_CUST_C_FINREPINFO` 取财务指标数据。

### 4.2 财务指标映射

采用编码映射方式，通过 ID_CODE 映射各财务指标：

| 指标 | ID_CODE | 来源 |
|------|---------|------|
| 货币资金 | 9100 | L_CUST_C_FINREPINFO |
| 应收票据及应收账款 | 9102, 9103 | L_CUST_C_FINREPINFO |
| 存货 | 9108 | L_CUST_C_FINREPINFO |
| 流动资产合计 | 9111 | L_CUST_C_FINREPINFO |
| 固定资产 | 9117 | L_CUST_C_FINREPINFO |
| 在建工程 | 9118 | L_CUST_C_FINREPINFO |
| 短期借款 | 9131 | L_CUST_C_FINREPINFO |
| 应付票据及应付账款 | 9133, 9134 | L_CUST_C_FINREPINFO |
| 流动负债合计 | 9143 | L_CUST_C_FINREPINFO |
| 长期借款 | 9144 | L_CUST_C_FINREPINFO |
| 营业收入 | 9146 | L_CUST_C_FINREPINFO |
| 营业成本 | 9147 | L_CUST_C_FINREPINFO |
| 营业税金及附加 | 9150 | L_CUST_C_FINREPINFO |
| 销售（营业）费用 | 9151 | L_CUST_C_FINREPINFO |
| 管理费用 | 9152 | L_CUST_C_FINREPINFO |
| 财务费用 | 9153 | L_CUST_C_FINREPINFO |
| 营业利润 | 9158 | L_CUST_C_FINREPINFO |
| 利润总额 | 9160 | L_CUST_C_FINREPINFO |
| 所得税 | 9161 | L_CUST_C_FINREPINFO |
| 净利润 | 9162 | L_CUST_C_FINREPINFO |

### 4.3 证件类型映射

```sql
DECODE(B.ID_TYPE, '236', 'A01', '21', 'A02', 'A03') AS CUST_ID_TYPE
```

### 4.4 会计报表版本与类型

- 会计报表版本：固定为 `2`（2007版会计报表）
- 会计报表类型：`DECODE(REPORT_SUB_TYP, '9', '1', REPORT_SUB_TYP)`

## 5. 特殊处理规则

### 5.1 机构代码映射

根据 ORG_NUM 前缀映射金融机构统一社会信用代码：

| 机构号前缀 | 统一社会信用代码 |
|-----------|----------------|
| 51%~60% | 各分行对应代码 |
| 其他 | 9122010170255776XN（总行） |

## 6. 涉及源码文件

| 角色 | 文件路径 |
|------|---------|
| 数据生成（主程序） | `源码/加工层存储/bsp_sp_js_102_xdqyxx.prc` |
| 数据生成（解析版） | `源码解析/加工层存储/bsp_sp_js_102_xdqyxx.prc` |
