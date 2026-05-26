# 个人贷款发生额信息（JS_201_GRDKFS）

> **来源**：[JS_201_GRDKFS_个人贷款发生额信息-原文.md](../参考资料/发文原文/JS_201_GRDKFS_个人贷款发生额信息-原文.md)

## 业务分类

| 属性 | 值 |
|------|-----|
| 接口表 | `JS_201_GRDKFS` |
| 中文名 | 个人贷款发生额信息 |
| 章节 | 3.2.2.5 |
| 时间范围 | 报告期内发生、结清、收回、兑付、买卖等发生额数据，具体以官方报送范围为准。 |
| 报送粒度 | 以单笔交易流水为核心识别维度逐笔报送。 |

---

# 第一部分：发文原文要求（人行规范层）

> **用于回答"这个表要求报送什么"、"新增业务应该报到哪个表"等问题**

## 1. 官方报送范围

个人贷款发生额指金融机构报告期内发放、收回、发放又收回的个人贷款，包括报告期内核销、剥离、转让的贷款。贷款展期不视为新发放。以贷款合同下单笔借据为单位逐笔报送。

## 2. 纳入与排除口径

| 方向 | 内容 |
|------|------|
| ✅ 纳入 | 包括报告期内核销、剥离、转让的贷款 |
| ❌ 排除 | 未在官方口径中明确排除的，应按采集任务和字段规则判断是否纳入。 |

## 3. 关键业务要素（要求报送的内容维度）

报送机构及经办机构识别；交易主体/客户主体识别；合同、协议或资产唯一标识；金额、币种及折人民币计量；利率与计息要素；起止日期、到期日或实际终止日；地区、行业、部门及企业属性分类。

## 4. 字段清单

完整字段清单（共29个字段）及填报说明、码值表详见原文文件：
[JS_201_GRDKFS_个人贷款发生额信息-原文.md](../参考资料/发文原文/JS_201_GRDKFS_个人贷款发生额信息-原文.md)

---


# 第二部分：代码取数业务范围（实现层）

> **用于回答"这个表怎么取数"、"取了哪些业务"、"业务变更对金数有什么影响"等问题**

## 1. 数据生成程序

`bsp_sp_js_201_grdkfs.prc`（加工层存储过程）

## 2. 监管集市表来源

| 表名 | 中文名 | 角色 |
|------|--------|------|
| `SMTMODS.L_ACCT_LOAN` | 贷款借据信息表 | **主表** |
| `SMTMODS.L_ACCT_WRITE_OFF` | 资产核销 | **核销判断** |
| `SMTMODS.L_CUST_ALL` | 全量客户信息表 | **客户信息** |
| `SMTMODS.L_CUST_C` | 对公客户补充信息表 | **对公客户** |
| `SMTMODS.L_CUST_IDENTIFY` | 客户证件信息表 | **证件信息** |
| `SMTMODS.L_PUBL_RATE` | 汇率表 | **汇率折算** |
| `SMTMODS.L_TRAN_LOAN_PAYM` | 贷款还款明细信息表 | **还款信息** |

## 3. 输出接口表

`JS_xxx` — 生成接口表 JS_201_GRDKFS 个人贷款发生额信息

## 4. 业务筛选条件

**程序用途**：生成接口表 JS_201_GRDKFS 个人贷款发生额信息

**SMTMODS 数据源表**：
- `SMTMODS.L_ACCT_LOAN`
- `SMTMODS.L_CUST_ALL`
- `SMTMODS.L_CUST_IDENTIFY`
- `SMTMODS.L_CUST_C`
- `SMTMODS.L_PUBL_RATE`
- `SMTMODS.L_TRAN_LOAN_PAYM`
- `SMTMODS.L_ACCT_WRITE_OFF`

**时间筛选**：
```sql
WHERE T.DATA_DATE = IS_DATE  -- 数据日期等于跑批日期，取当前批次数据
```

**业务筛选条件**：
```sql
WHERE TABLE_NAME = 'JS_201_GRDKFS'
AND B.ID_TYPE = D.ID_TYPE
WHERE (TRUNC(A.DRAWDOWN_DT, 'MM') = TRUNC(D_DATADATE, 'MM') OR
AND (B.CUST_TYPE = '00' OR E.CUST_TYP = '3')
AND B.ID_TYPE = D.ID_TYPE
WHERE (TRUNC(A.REPAY_DT, 'MM') = TRUNC(D_DATADATE, 'MM') OR
AND (B.CUST_TYPE = '00' OR E.CUST_TYP = '3')
WHERE T.EFF_FLAG = 'Y'
```



## 5. 特殊处理规则

| 字段 | 规则 | 说明 |
|------|------|------|
| `...` | `CASE WHEN LA.RN = 1 THEN '1' WHEN LA.RN >= 2 THEN '0' END FI...` | 28  是否首次贷款 |
| `...` | `CASE WHEN A.LOAN_KIND_CD = '91'   THEN` | 资产重组 |
| `...` | `CASE WHEN A.ACCT_TYP = '010302' THEN '线上联合消费贷款'` | 字段映射规则 |
| `...` | `/*CASE WHEN A.ORG_NUM LIKE '5100%' THEN '510000' ELSE '99000...` | 字段映射规则 |
| `...` | `CASE WHEN F.ORG_NUM LIKE  '5100%' THEN` | 字段映射规则 |
| `...` | `CASE WHEN LA.RN = 1 THEN '1' WHEN LA.RN >= 2 THEN '0' END FI...` | 28  是否首次贷款 |
| `...` | `CASE WHEN A.PAY_TYPE  IN ('04', '12') THEN` | 字段映射规则 |
| `...` | `CASE WHEN A.PAY_AMT < 0 THEN '1' ELSE '0' END AS TRANS_TYPE,` | 发放/收回标识 |
| `...` | `CASE WHEN F.ACCT_TYP = '010302' THEN '线上联合消费贷款'` | 字段映射规则 |
| `...` | `CASE WHEN T.INT_RATE_TYPE = 'RF01' THEN NULL ELSE NVL(T.BASE...` | 19  基准利率 |

## 6. 历史变更记录

| 编号 | 日期 | 修改人 | 提出人 | 原因 |
|------|------|--------|--------|------|
| JLBA202412270002 | 2025-04-27 | 周立鹏 | 李楠 | 剔除取上期/配置表 |

## 7. 涉及源码文件

| 角色 | 文件路径 |
|------|---------|
| 数据生成（主程序） | `源码/加工层存储/bsp_sp_js_201_grdkfs.prc` |
| 数据生成（解析版） | `源码解析/加工层存储/bsp_sp_js_201_grdkfs.prc` |

---

> **使用说明**：
> - 问"**要求报送什么**"→ 查**第一部分（发文原文要求）**
> - 问"**怎么取数/取了哪些业务/业务变更影响**"→ 查**第二部分（代码取数业务范围）**

*← [返回首页索引](../首页/index.md) · 原文：[JS_201_GRDKFS_个人贷款发生额信息-原文.md](../参考资料/发文原文/JS_201_GRDKFS_个人贷款发生额信息-原文.md)*