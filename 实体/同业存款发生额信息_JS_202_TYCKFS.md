# 同业存款发生额信息（JS_202_TYCKFS）

> **来源**：[JS_202_TYCKFS_同业存款发生额信息-原文.md](../参考资料/发文原文/JS_202_TYCKFS_同业存款发生额信息-原文.md)

## 业务分类

| 属性 | 值 |
|------|-----|
| 接口表 | `JS_202_TYCKFS` |
| 中文名 | 同业存款发生额信息 |
| 章节 | 3.4.1.2 |
| 时间范围 | 报告期内发生、结清、收回、兑付、买卖等发生额数据，具体以官方报送范围为准。 |
| 报送粒度 | 以单笔交易流水为核心识别维度逐笔报送。 |

---

# 第一部分：发文原文要求（人行规范层）

> **用于回答"这个表要求报送什么"、"新增业务应该报到哪个表"等问题**

## 1. 官方报送范围

同业存款发生额是指报告期内金融机构与同业之间新发生、结清、发生又结清的同业存放、存放同业、同业存单发行或同业存单投资业务。以存款协议为单位逐笔报送。

## 2. 纳入与排除口径

| 方向 | 内容 |
|------|------|
| ✅ 纳入 | 按官方报送范围采集规范定义的相关业务。 |
| ❌ 排除 | 未在官方口径中明确排除的，应按采集任务和字段规则判断是否纳入。 |

## 3. 关键业务要素（要求报送的内容维度）

报送机构及经办机构识别；交易主体/客户主体识别；利率与计息要素；起止日期、到期日或实际终止日。

## 4. 字段清单

完整字段清单（共19个字段）及填报说明、码值表详见原文文件：
[JS_202_TYCKFS_同业存款发生额信息-原文.md](../参考资料/发文原文/JS_202_TYCKFS_同业存款发生额信息-原文.md)

---


# 第二部分：代码取数业务范围（实现层）

> **用于回答"这个表怎么取数"、"取了哪些业务"、"业务变更对金数有什么影响"等问题**

## 1. 数据生成程序

`bsp_sp_js_202_tyckfs.prc`（加工层存储过程）

## 2. 监管集市表来源

| 表名 | 中文名 | 角色 |
|------|--------|------|
| `SMTMODS.L_ACCT_DEPOSIT` | 存款账户信息表 | **主表** |
| `SMTMODS.L_ACCT_FUND_CDS_BAL` | 存单投资与发行信息表 | **存单信息** |
| `SMTMODS.L_CUST_ALL` | 全量客户信息表 | **客户信息** |
| `SMTMODS.L_CUST_BILL_TY` | 同业客户补充信息表 | **同业客户** |
| `SMTMODS.L_CUST_C` | 对公客户补充信息表 | **对公客户** |
| `SMTMODS.L_PUBL_RATE` | 汇率表 | **汇率折算** |
| `SMTMODS.L_TRAN_FUND_FX` | 资金交易信息表 | **交易流水** |
| `SMTMODS.L_TRAN_TX` | 交易信息表 | **交易信息** |

## 3. 输出接口表

`JS_xxx` — 同业存款发生额信息

## 4. 业务筛选条件

**程序用途**：

**SMTMODS 数据源表**：
- `SMTMODS.L_TRAN_TX`
- `smtmods.l_acct_fund_mmfund`
- `SMTMODS.L_CUST_ALL`
- `SMTMODS.L_PUBL_RATE`
- `SMTMODS.L_CUST_BILL_TY`
- `SMTMODS.L_CUST_C`
- `SMTMODS.L_TRAN_FUND_FX`
- `SMTMODS.L_ACCT_FUND_CDS_BAL`

**时间筛选**：
```sql
WHERE T.DATA_DATE = IS_DATE  -- 数据日期等于跑批日期，取当前批次数据
```

**业务筛选条件**：
```sql
WHERE TABLE_NAME = 'PBOCD_JS_202_TYCKFS_TMP'
WHEN (T1.FINA_CODE<>'I20000' OR T1.FINA_CODE IS NULL) /*AND B.ID_TYPE IN ('21','236')*/ THEN B.ID_NO
WHEN (T1.FINA_CODE<>'I20000' OR T1.FINA_CODE IS NULL) /*AND B.ID_TYPE IN ('21','236')*/ THEN B.ID_NO
WHERE TABLE_NAME = 'PBOCD_JS_202_TYCKFS'
WHERE TO_CHAR(A.TRAN_DT,'YYYYMM') =SUBSTR( IS_DATE,1,6)
WHERE TO_CHAR(T1.TRAN_DT, 'YYYYMM') = SUBSTR(IS_DATE, 1, 6)
WHERE T.DATE_SOURCESD ='存单发行';
```



## 5. 特殊处理规则

| 字段 | 规则 | 说明 |
|------|------|------|
| `...` | `CASE WHEN D.ACCT_TYP LIKE '201%' AND D.DEPOSIT_TERM_FLG LIKE...` | T012 |  -- 码表A0004（贷款账户类型）：01=个人贷款、0102=个人经营性贷款、0301=贴现、90=委托贷款
| `...` | `CASE WHEN D.ACCT_TYP LIKE '101%' THEN` | 字段映射规则 |
| `...` | `CASE WHEN A.CD_TYPE = '2' THEN '0' ELSE '1'  END` | 字段映射规则 |
| `...` | `ELSE CASE WHEN A.CD_TYPE = '2' THEN '1' ELSE '0'  END` | 字段映射规则 |
| `...` | `CASE WHEN D.ACCT_TYP LIKE '101%' THEN 'C010302' ELSE D.ACCT_...` | 存款账户类型 |
| `...` | `CASE WHEN LENGTH(A.OPP_NAME) >=4 THEN A.OPP_NAME END AS OPPO...` | 存款转入转出方名称  发文：资金转入或转出的交易对手的全称 |
| `...` | `/*CASE WHEN A.ORG_NUM LIKE '5100%' THEN '510000' ELSE '99000...` | 字段映射规则 |
| `...` | `CASE WHEN D.ACCT_TYP LIKE '201%' AND D.DEPOSIT_TERM_FLG LIKE...` | T012 |  -- 码表A0004（贷款账户类型）：01=个人贷款、0102=个人经营性贷款、0301=贴现、90=委托贷款
| `...` | `CASE WHEN D.ACCT_TYP LIKE '101%' THEN` | 字段映射规则 |
| `...` | `CASE WHEN A.CD_TYPE = '2' THEN '0' ELSE '1'  END` | 字段映射规则 |

## 6. 历史变更记录

| 编号 | 日期 | 修改人 | 提出人 | 原因 |
|------|------|--------|--------|------|
| JLBA202503120002 | 2025-04-29 | 周立鹏 | 徐晖 | 交易日期取数逻辑 |
| JLBA202504110003 | 2025-07-29 | 白杨 | 姜硕 | 监管报送口径变更 |
| JLBA202601150009 | 2026-01-30 | 周立鹏 | 李楠 | 制度升级 |

## 7. 涉及源码文件

| 角色 | 文件路径 |
|------|---------|
| 数据生成（主程序） | `源码/加工层存储/bsp_sp_js_202_tyckfs.prc` |
| 数据生成（解析版） | `源码解析/加工层存储/bsp_sp_js_202_tyckfs.prc` |

---

> **使用说明**：
> - 问"**要求报送什么**"→ 查**第一部分（发文原文要求）**
> - 问"**怎么取数/取了哪些业务/业务变更影响**"→ 查**第二部分（代码取数业务范围）**

*← [返回首页索引](../首页/index.md) · 原文：[JS_202_TYCKFS_同业存款发生额信息-原文.md](../参考资料/发文原文/JS_202_TYCKFS_同业存款发生额信息-原文.md)*