# 存量同业借贷信息（JS_201_CLTYJD）

> **来源**：[JS_201_CLTYJD_存量同业借贷信息-原文.md](../参考资料/发文原文/JS_201_CLTYJD_存量同业借贷信息-原文.md)

## 业务分类

| 属性 | 值 |
|------|-----|
| 接口表 | `JS_201_CLTYJD` |
| 中文名 | 存量同业借贷信息 |
| 章节 | 3.2.1.1 |
| 时间范围 | 报告期末存续数据。 |
| 报送粒度 | 以业务合同为核心识别维度逐笔报送。 |

---

# 第一部分：发文原文要求（人行规范层）

> **用于回答"这个表要求报送什么"、"新增业务应该报到哪个表"等问题**

## 1. 官方报送范围

存量同业借贷指金融机构报告期末存续的与同业进行的拆放同业/同业拆借、买入返售/卖出回购业务。以合同为单位逐笔报送。

## 2. 纳入与排除口径

| 方向 | 内容 |
|------|------|
| ✅ 纳入 | 按官方报送范围采集规范定义的相关业务。 |
| ❌ 排除 | 未在官方口径中明确排除的，应按采集任务和字段规则判断是否纳入。 |

## 3. 关键业务要素（要求报送的内容维度）

报送机构及经办机构识别；交易主体/客户主体识别；合同、协议或资产唯一标识；金额、币种及折人民币计量；利率与计息要素；起止日期、到期日或实际终止日。

## 4. 字段清单

完整字段清单（共17个字段）及填报说明、码值表详见原文文件：
[JS_201_CLTYJD_存量同业借贷信息-原文.md](../参考资料/发文原文/JS_201_CLTYJD_存量同业借贷信息-原文.md)

---


# 第二部分：代码取数业务范围（实现层）

> **用于回答"这个表怎么取数"、"取了哪些业务"、"业务变更对金数有什么影响"等问题**

## 1. 数据生成程序

`bsp_sp_js_201_cltyjd.prc`（加工层存储过程）

## 2. 监管集市表来源

| 表名 | 中文名 | 角色 |
|------|--------|------|
| `SMTMODS.L_ACCT_FUND_MMFUND` | 资金往来信息表 | **主表** |
| `SMTMODS.L_ACCT_FUND_REPURCHASE` | 回购信息表 | **回购信息** |
| `SMTMODS.L_AGRE_REPURCHASE_GUARANTY_INFO` | 回购抵质押物详细信息 | **质押品** |
| `SMTMODS.L_CUST_ALL` | 全量客户信息表 | **客户信息** |
| `SMTMODS.L_CUST_BILL_TY` | 同业客户补充信息表 | **同业客户** |
| `SMTMODS.L_CUST_C` | 对公客户补充信息表 | **对公客户** |
| `SMTMODS.L_PUBL_RATE` | 汇率表 | **汇率折算** |

## 3. 输出接口表

`JS_xxx` — 生成接口表 JS_201_CLTYJD 存量同业借贷信息

## 4. 业务筛选条件

**程序用途**：生成接口表 JS_201_CLTYJD 存量同业借贷信息

**SMTMODS 数据源表**：
- `SMTMODS.L_ACCT_FUND_MMFUND`
- `SMTMODS.L_CUST_ALL`
- `SMTMODS.L_CUST_C`
- `SMTMODS.L_PUBL_RATE`
- `SMTMODS.L_ACCT_FUND_REPURCHASE`
- `SMTMODS.L_AGRE_REPURCHASE_GUARANTY_INFO`
- `SMTMODS.L_CUST_BILL_TY`

**时间筛选**：
```sql
WHERE T.DATA_DATE = IS_DATE  -- 数据日期等于跑批日期，取当前批次数据
```

**业务筛选条件**：
```sql
WHERE TABLE_NAME = 'PBOCD_JS_201_CLTYJD'
WHERE A.RN = 1) A
AND T.ASS_TYPE = '1'  --债券
WHERE A.RN = 1) A
) A WHERE A.RN=1) B
ON A.LEGAL_TYSHXYDM=B.TYSHXYDM) WHERE RN = 1)FR
```



## 5. 特殊处理规则

| 字段 | 规则 | 说明 |
|------|------|------|
| `...` | `CASE WHEN BB.TYSHXYDM IS NOT NULL THEN BB.TYSHXYDM` | 字段映射规则 |
| `...` | `CASE WHEN T.ORG_NUM ='009801' THEN T.REF_NUM ||TO_CHAR(T.STA...` | 合同编码 ADD BY  ZY  20240618 增加009801外币 |
| `...` | `CASE WHEN SUBSTR(T.ACCT_TYP,1,3) IN ('202','205') THEN 'AL02...` | 资产负债类型 |
| `...` | `CASE WHEN T.ORG_NUM  ='009804' THEN 'TR01' ELSE  NVL(T.PRICI...` | 定价基准类型 |
| `...` | `CASE WHEN  T.ACC_INT_TYPE ='1'  THEN 'B01'` | 字段映射规则 |
| `...` | `CASE WHEN BB.TYSHXYDM IS NOT NULL THEN 'A01'` | 字段映射规则 |
| `...` | `CASE WHEN T.ORG_NUM='009801' THEN  NVL(T.CUST_ID,AA.CUST_NAM...` | 上报客户名称 |
| `...` | `CASE WHEN T.ORG_NUM='009801' THEN  NVL(T.CUST_ID,AA.CUST_NAM...` | 原客户名称 |
| `...` | `CASE WHEN BB.TYSHXYDM IS NOT NULL THEN BB.TYSHXYDM` | 字段映射规则 |
| `...` | `CASE WHEN SUBSTR(T.Busi_Type,1,3) IN ('101') THEN 'AL01' ELS...` | 资产负债类型 |

## 6. 历史变更记录

| 编号 | 日期 | 修改人 | 提出人 | 原因 |
|------|------|--------|--------|------|
| JLBA202503120002 | 2025-04-29 | 周立鹏 | 徐晖 | 金融市场部报送逻辑变更 |

## 7. 涉及源码文件

| 角色 | 文件路径 |
|------|---------|
| 数据生成（主程序） | `源码/加工层存储/bsp_sp_js_201_cltyjd.prc` |
| 数据生成（解析版） | `源码解析/加工层存储/bsp_sp_js_201_cltyjd.prc` |

---

> **使用说明**：
> - 问"**要求报送什么**"→ 查**第一部分（发文原文要求）**
> - 问"**怎么取数/取了哪些业务/业务变更影响**"→ 查**第二部分（代码取数业务范围）**

*← [返回首页索引](../首页/index.md) · 原文：[JS_201_CLTYJD_存量同业借贷信息-原文.md](../参考资料/发文原文/JS_201_CLTYJD_存量同业借贷信息-原文.md)*