# 单位贷款发生额信息（JS_201_DWDKFS）

> **来源**：[JS_201_DWDKFS_单位贷款发生额信息-原文.md](../参考资料/发文原文/JS_201_DWDKFS_单位贷款发生额信息-原文.md)

## 业务分类

| 属性 | 值 |
|------|-----|
| 接口表 | `JS_201_DWDKFS` |
| 中文名 | 单位贷款发生额信息 |
| 章节 | 3.2.2.2 |
| 时间范围 | 报告期内发生、结清、收回、兑付、买卖等发生额数据，具体以官方报送范围为准。 |
| 报送粒度 | 以单笔交易流水为核心识别维度逐笔报送。 |

---

# 第一部分：发文原文要求（人行规范层）

> **用于回答"这个表要求报送什么"、"新增业务应该报到哪个表"等问题**

## 1. 官方报送范围

单位贷款发生额指金融机构报告期内发放、收回、发放又收回的非同业单位贷款（不含票据融资），包括报告期内核销、剥离、转让的贷款。贷款展期不视为新发放。以贷款合同下单笔借据为单位逐笔报送。

## 2. 纳入与排除口径

| 方向 | 内容 |
|------|------|
| ✅ 纳入 | 包括报告期内核销、剥离、转让的贷款 |
| ❌ 排除 | 不含票据融资 |

## 3. 关键业务要素（要求报送的内容维度）

报送机构及经办机构识别；交易主体/客户主体识别；合同、协议或资产唯一标识；金额、币种及折人民币计量；利率与计息要素；起止日期、到期日或实际终止日；地区、行业、部门及企业属性分类。

## 4. 字段清单

完整字段清单（共34个字段）及填报说明、码值表详见原文文件：
[JS_201_DWDKFS_单位贷款发生额信息-原文.md](../参考资料/发文原文/JS_201_DWDKFS_单位贷款发生额信息-原文.md)

---


# 第二部分：代码取数业务范围（实现层）

> **用于回答"这个表怎么取数"、"取了哪些业务"、"业务变更对金数有什么影响"等问题**

## 1. 数据生成程序

`bsp_sp_js_201_dwdkfs.prc`（加工层存储过程）

## 2. 监管集市表来源

| 表名 | 中文名 | 角色 |
|------|--------|------|
| `SMTMODS.L_ACCT_LOAN` | 贷款借据信息表 | **主表** |
| `SMTMODS.L_ACCT_WRITE_OFF` | 资产核销 | **核销判断** |
| `SMTMODS.L_AGRE_LOAN_CONTRACT` | 贷款合同信息表 | **合同信息** |
| `SMTMODS.L_CUST_ALL` | 全量客户信息表 | **客户信息** |
| `SMTMODS.L_PUBL_RATE` | 汇率表 | **汇率折算** |
| `SMTMODS.L_TRAN_LOAN_PAYM` | 贷款还款明细信息表 | **还款信息** |

## 3. 输出接口表

`JS_xxx` — 生成接口表 JS_201_DWDKFS 单位贷款发生额信息

## 4. 业务筛选条件

**程序用途**：生成接口表 JS_201_DWDKFS 单位贷款发生额信息

**SMTMODS 数据源表**：
- `SMTMODS.L_ACCT_LOAN`
- `SMTMODS.L_CUST_ALL`
- `SMTMODS.L_AGRE_LOAN_CONTRACT`
- `SMTMODS.L_PUBL_RATE`
- `SMTMODS.L_TRAN_LOAN_PAYM`
- `SMTMODS.L_ACCT_WRITE_OFF`

**时间筛选**：
```sql
WHERE T.DATA_DATE = IS_DATE  -- 数据日期等于跑批日期，取当前批次数据
```

**业务筛选条件**：
```sql
WHERE TABLE_NAME = 'JS_201_DWDKFS'
/*CASE WHEN C.ID_TYPE IN ('236','239','2X','24') AND LENGTH(C.ID_NO) = 18 AND C.ID_NO NOT LIKE  '00000%' AND C.ID_NO NOT LIKE '%000000' THEN 'A01'
CASE WHEN C.ID_TYPE IN ('236','239','2X','24') AND LENGTH(C.ID_NO) = 18 AND C.ID_NO NOT LIKE  '00000%' AND C.ID_NO NOT LIKE '%000000' THEN C.ID_NO
AND D1.CODE_CLMN_NAME = 'ID_TYPE' --证件类型
AND (B.CUST_TYPE = '11' OR SUBSTR(C.FINA_CODE, 1, 1) IN ('A', 'B'))
/*  CASE WHEN C.ID_TYPE IN ('236','239','2X','24') AND LENGTH(C.ID_NO) = 18 AND C.ID_NO NOT LIKE  '00000%' AND C.ID_NO NOT LIKE '%000000' THEN 'A01'
CASE WHEN C.ID_TYPE IN ('236','239','2X','24') AND LENGTH(C.ID_NO) = 18 AND C.ID_NO NOT LIKE  '00000%' AND C.ID_NO NOT LIKE '%000000' THEN C.ID_NO
AND D1.CODE_CLMN_NAME = 'ID_TYPE' --证件类型
```



## 5. 特殊处理规则

| 字段 | 规则 | 说明 |
|------|------|------|
| `...` | `/*CASE WHEN C.ID_TYPE IN ('236','239','2X','24') AND LENGTH(...` | 字段映射规则 |
| `...` | `CASE WHEN C.ID_TYPE IN ('236','239','2X','24') AND LENGTH(C....` | 字段映射规则 |
| `...` | `CASE WHEN D1.PBOCD_CODE = 'A02' THEN REPLACE(C.ID_NO,'-') EL...` | 借款人证件代码6 |
| `...` | `CASE WHEN C.CUST_TYP <> '5' THEN C.DEPT_TYPE ELSE 'A04' END ...` | 借款人国民经济部门7 |
| `...` | `CASE WHEN A.ACCT_TYP = '0901' THEN 'F052'` | 字段映射规则 |
| `...` | `CASE WHEN A.LOAN_KIND_CD = '91'   THEN` | 资产重组 |
| `...` | `/*  CASE WHEN C.ID_TYPE IN ('236','239','2X','24') AND LENGT...` | 字段映射规则 |
| `...` | `CASE WHEN C.ID_TYPE IN ('236','239','2X','24') AND LENGTH(C....` | 字段映射规则 |

## 6. 历史变更记录

| 编号 | 日期 | 修改人 | 提出人 | 原因 |
|------|------|--------|--------|------|
| JLBA202412270002 | 2025-04-27 | 周立鹏 | 李楠 | 剔除取上期/配置表 |

## 7. 涉及源码文件

| 角色 | 文件路径 |
|------|---------|
| 数据生成（主程序） | `源码/加工层存储/bsp_sp_js_201_dwdkfs.prc` |
| 数据生成（解析版） | `源码解析/加工层存储/bsp_sp_js_201_dwdkfs.prc` |

---

> **使用说明**：
> - 问"**要求报送什么**"→ 查**第一部分（发文原文要求）**
> - 问"**怎么取数/取了哪些业务/业务变更影响**"→ 查**第二部分（代码取数业务范围）**

*← [返回首页索引](../首页/index.md) · 原文：[JS_201_DWDKFS_单位贷款发生额信息-原文.md](../参考资料/发文原文/JS_201_DWDKFS_单位贷款发生额信息-原文.md)*