# 票据融资发生额信息（JS_205_PJRZFS）

> **来源**：[JS_205_PJRZFS_票据融资发生额信息-原文.md](../参考资料/发文原文/JS_205_PJRZFS_票据融资发生额信息-原文.md)

## 业务分类

| 属性 | 值 |
|------|-----|
| 接口表 | `JS_205_PJRZFS` |
| 中文名 | 票据融资发生额信息 |
| 章节 | 3.7.1.2 |
| 时间范围 | 报告期内发生、结清、收回、兑付、买卖等发生额数据，具体以官方报送范围为准。 |
| 报送粒度 | 以单笔交易流水为核心识别维度逐笔报送。 |

---

# 第一部分：发文原文要求（人行规范层）

> **用于回答"这个表要求报送什么"、"新增业务应该报到哪个表"等问题**

## 1. 官方报送范围

票据融资发生额指金融机构报告期内发生及收回的贴现及买断式转贴现业务，收回既包括票据到期兑付，也包括对票据进行转让、核销等。可分包票据以票据（包）的子票区间为单位逐笔报送。不可分包票据以单张票据为单位逐笔报送。

## 2. 纳入与排除口径

| 方向 | 内容 |
|------|------|
| ✅ 纳入 | 包括票据到期兑付，也包括对票据进行转让、核销等 |
| ❌ 排除 | 未在官方口径中明确排除的，应按采集任务和字段规则判断是否纳入。 |

## 3. 关键业务要素（要求报送的内容维度）

报送机构及经办机构识别；金额、币种及折人民币计量；利率与计息要素；起止日期、到期日或实际终止日；地区、行业、部门及企业属性分类。

## 4. 字段清单

完整字段清单（共32个字段）及填报说明、码值表详见原文文件：
[JS_205_PJRZFS_票据融资发生额信息-原文.md](../参考资料/发文原文/JS_205_PJRZFS_票据融资发生额信息-原文.md)

---


# 第二部分：代码取数业务范围（实现层）

> **用于回答"这个表怎么取数"、"取了哪些业务"、"业务变更对金数有什么影响"等问题**

## 1. 数据生成程序

`bsp_sp_js_205_pjrzfs.prc`（加工层存储过程）

## 2. 监管集市表来源

| 表名 | 中文名 | 角色 |
|------|--------|------|
| `SMTMODS.L_ACCT_LOAN` | 贷款借据信息表 | **主表** |
| `SMTMODS.L_AGRE_BILL_INFO` | 商业汇票票面信息表 | **票据信息** |
| `SMTMODS.L_CUST_ALL` | 全量客户信息表 | **客户信息** |
| `SMTMODS.L_CUST_BILL_TY` | 同业客户补充信息表 | **同业客户** |
| `SMTMODS.L_CUST_C` | 对公客户补充信息表 | **对公客户** |
| `SMTMODS.L_CUST_P` | 对私客户补充信息表 | **个人客户** |
| `SMTMODS.L_PUBL_RATE` | 汇率表 | **汇率折算** |
| `SMTMODS.L_TRAN_LOAN_PAYM` | 贷款还款明细信息表 | **还款信息** |

## 3. 输出接口表

`JS_xxx` — 生成接口表 JS_205_PJRZFS 存量票据融资

## 4. 业务筛选条件

**程序用途**：生成接口表 JS_205_PJRZFS 存量票据融资

**SMTMODS 数据源表**：
- `SMTMODS.L_ACCT_LOAN`
- `SMTMODS.L_AGRE_BILL_INFO`
- `SMTMODS.L_CUST_BILL_TY`
- `SMTMODS.L_CUST_P`
- `SMTMODS.L_CUST_ALL`
- `SMTMODS.L_CUST_C`
- `SMTMODS.L_PUBL_RATE`
- `SMTMODS.L_TRAN_LOAN_PAYM`

**时间筛选**：
```sql
WHERE T.DATA_DATE = IS_DATE  -- 数据日期等于跑批日期，取当前批次数据
```

**业务筛选条件**：
```sql
AND T.DISCOUNT_TYPE = F.DISCOUNT_TYPE
AND T.DISCOUNT_TYPE = F.DISCOUNT_TYPE
AND NOT EXISTS (SELECT 1 FROM JS_205_PJRZFS_TMP3 T3 WHERE T3.acct_Num||T3.draft_rng=T.bill_num AND T.ORG_NUM<>'009804')
WHERE TABLE_NAME = 'JS_205_PJRZFS'
WHEN T.DISCOUNT_TYPE = '01' AND T.BILL_TYPE = '02' THEN 'E'
,CASE WHEN SUBSTR(A.ITEM_CD,1,6) IN ('130101','130104' ) AND  B.BILL_TYPE = '1' THEN 'A01'
,CASE WHEN (SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) AND TRIM(B.BILL_TYPE) = '1') THEN
/*,CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104') AND TRIM(B.BILL_TYPE) = '1'THEN 'C01'
```



## 5. 特殊处理规则

| 字段 | 规则 | 说明 |
|------|------|------|
| `...` | `(CASE WHEN T.ORG_NUM LIKE '51%' THEN 1 ELSE 99 END)=(CASE WH...` | 字段映射规则 |
| `...` | `(CASE WHEN T.ORG_NUM LIKE '52%' THEN 2 ELSE 99 END)=(CASE WH...` | 字段映射规则 |
| `...` | `(CASE WHEN T.ORG_NUM LIKE '53%' THEN 3 ELSE 99 END)=(CASE WH...` | 字段映射规则 |
| `...` | `(CASE WHEN T.ORG_NUM LIKE '54%' THEN 4 ELSE 99 END)=(CASE WH...` | 字段映射规则 |
| `...` | `(CASE WHEN T.ORG_NUM LIKE '55%' THEN 5 ELSE 99 END)=(CASE WH...` | 字段映射规则 |
| `...` | `(CASE WHEN T.ORG_NUM LIKE '56%' THEN 6 ELSE 99 END)=(CASE WH...` | 字段映射规则 |
| `...` | `(CASE WHEN T.ORG_NUM LIKE '57%' THEN 7 ELSE 99 END)=(CASE WH...` | 字段映射规则 |
| `...` | `(CASE WHEN T.ORG_NUM LIKE '58%' THEN 8 ELSE 99 END)=(CASE WH...` | 字段映射规则 |
| `...` | `(CASE WHEN T.ORG_NUM LIKE '59%' THEN 9 ELSE 99 END)=(CASE WH...` | 字段映射规则 |
| `...` | `(CASE WHEN T.ORG_NUM LIKE '60%' THEN 10 ELSE 99 END)=(CASE W...` | 20231013王晓彬 |

## 6. 历史变更记录

| 编号 | 日期 | 修改人 | 提出人 | 原因 |
|------|------|--------|--------|------|
| JLBA202502130004 | 2025-03-27 | 周立鹏 | 李楠 | 制度升级2025 |

## 7. 涉及源码文件

| 角色 | 文件路径 |
|------|---------|
| 数据生成（主程序） | `源码/加工层存储/bsp_sp_js_205_pjrzfs.prc` |
| 数据生成（解析版） | `源码解析/加工层存储/bsp_sp_js_205_pjrzfs.prc` |

---

> **使用说明**：
> - 问"**要求报送什么**"→ 查**第一部分（发文原文要求）**
> - 问"**怎么取数/取了哪些业务/业务变更影响**"→ 查**第二部分（代码取数业务范围）**

*← [返回首页索引](../首页/index.md) · 原文：[JS_205_PJRZFS_票据融资发生额信息-原文.md](../参考资料/发文原文/JS_205_PJRZFS_票据融资发生额信息-原文.md)*