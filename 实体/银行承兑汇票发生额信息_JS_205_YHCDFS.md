# 银行承兑汇票发生额信息（JS_205_YHCDFS）

> **来源**：[JS_205_YHCDFS_银行承兑汇票发生额信息-原文.md](../参考资料/发文原文/JS_205_YHCDFS_银行承兑汇票发生额信息-原文.md)

## 业务分类

| 属性 | 值 |
|------|-----|
| 接口表 | `JS_205_YHCDFS` |
| 中文名 | 银行承兑汇票发生额信息 |
| 章节 | 3.7.3.2 |
| 时间范围 | 报告期内发生、结清、收回、兑付、买卖等发生额数据，具体以官方报送范围为准。 |
| 报送粒度 | 以单笔交易流水为核心识别维度逐笔报送。 |

---

# 第一部分：发文原文要求（人行规范层）

> **用于回答"这个表要求报送什么"、"新增业务应该报到哪个表"等问题**

## 1. 官方报送范围

银行承兑汇票发生额指金融机构报告期内承兑、兑付的商业汇票业务。可分包票据以票据（包）的子票区间为单位逐笔报送。不可分包票据以单张票据为单位逐笔报送。

## 2. 纳入与排除口径

| 方向 | 内容 |
|------|------|
| ✅ 纳入 | 按官方报送范围采集规范定义的相关业务。 |
| ❌ 排除 | 未在官方口径中明确排除的，应按采集任务和字段规则判断是否纳入。 |

## 3. 关键业务要素（要求报送的内容维度）

报送机构及经办机构识别；金额、币种及折人民币计量；地区、行业、部门及企业属性分类。

## 4. 字段清单

完整字段清单（共27个字段）及填报说明、码值表详见原文文件：
[JS_205_YHCDFS_银行承兑汇票发生额信息-原文.md](../参考资料/发文原文/JS_205_YHCDFS_银行承兑汇票发生额信息-原文.md)

---


# 第二部分：代码取数业务范围（实现层）

> **用于回答"这个表怎么取数"、"取了哪些业务"、"业务变更对金数有什么影响"等问题**

## 1. 数据生成程序

`bsp_sp_js_205_yhcdfs.prc`（加工层存储过程）

## 2. 监管集市表来源

| 表名 | 中文名 | 角色 |
|------|--------|------|
| `SMTMODS.L_ACCT_LOAN` | 贷款借据信息表 | **主表** |
| `SMTMODS.L_ACCT_OBS_LOAN` | 贷款表外信息表 | **表外信息** |
| `SMTMODS.L_AGRE_BILL_INFO` | 商业汇票票面信息表 | **票据信息** |
| `SMTMODS.L_AGRE_GUARANTEE_CONTRACT` | 担保合同信息 | **担保合同** |
| `SMTMODS.L_AGRE_GUA_RELATION` | 业务合同与担保合同对应关系表 | **关联关系** |
| `SMTMODS.L_AGRE_LOAN_CONTRACT` | 贷款合同信息表 | **合同信息** |
| `SMTMODS.L_CUST_C` | 对公客户补充信息表 | **对公客户** |
| `SMTMODS.L_CUST_P` | 对私客户补充信息表 | **个人客户** |
| `SMTMODS.L_PUBL_RATE` | 汇率表 | **汇率折算** |

## 3. 输出接口表

`JS_xxx` — 生成接口表 JS_205_YHCDFS 银行承兑汇票发生额信息表

## 4. 业务筛选条件

**程序用途**：生成接口表 JS_205_YHCDFS 银行承兑汇票发生额信息表

**SMTMODS 数据源表**：
- `SMTMODS.L_ACCT_OBS_lOAN`
- `SMTMODS.L_ACCT_LOAN`
- `SMTMODS.L_ACCT_OBS_LOAN`
- `SMTMODS.L_AGRE_BILL_INFO`
- `SMTMODS.L_CUST_P`
- `SMTMODS.L_CUST_C`
- `SMTMODS.L_AGRE_LOAN_CONTRACT`
- `SMTMODS.L_PUBL_RATE`
- `SMTMODS.L_AGRE_GUARANTEE_CONTRACT`

**时间筛选**：
```sql
WHERE T.DATA_DATE = IS_DATE  -- 数据日期等于跑批日期，取当前批次数据
```

**业务筛选条件**：
```sql
WHERE TABLE_NAME = 'JS_205_YHCDFS'
AND LOAN.BALANCE  = 0
AND CD1.CODE_CLMN_NAME = 'ID_TYPE'
AND CD2.CODE_CLMN_NAME = 'BZR_ID_TYPE'
AND CD4.CODE_CLMN_NAME = 'CORP_HOLD_TYPE' --企业控股类型
AND T1.GUAR_CONTRACT_STATUS='Y'
AND T.REL_STATUS ='Y'  -- 担保关系状态：Y=存续，排除N=解除
AND A.BALANCE = 0
```



## 5. 特殊处理规则

| 字段 | 规则 | 说明 |
|------|------|------|
| `...` | `CASE WHEN ID = '01' THEN A.OPEN_DATE ELSE` | 字段映射规则 |
| `...` | `CASE WHEN SUBSTR(REPLACE(A.BILL_DUE_DATE,'-'),1,6) = SUBSTR(...` | 字段映射规则 |

## 6. 历史变更记录

| 编号 | 日期 | 修改人 | 提出人 | 原因 |
|------|------|--------|--------|------|
| JLBA202412270002 | 2025-04-27 | 周立鹏 | 李楠 | 剔除取上期/配置表 |

## 7. 涉及源码文件

| 角色 | 文件路径 |
|------|---------|
| 数据生成（主程序） | `源码/加工层存储/bsp_sp_js_205_yhcdfs.prc` |
| 数据生成（解析版） | `源码解析/加工层存储/bsp_sp_js_205_yhcdfs.prc` |

---

> **使用说明**：
> - 问"**要求报送什么**"→ 查**第一部分（发文原文要求）**
> - 问"**怎么取数/取了哪些业务/业务变更影响**"→ 查**第二部分（代码取数业务范围）**

*← [返回首页索引](../首页/index.md) · 原文：[JS_205_YHCDFS_银行承兑汇票发生额信息-原文.md](../参考资料/发文原文/JS_205_YHCDFS_银行承兑汇票发生额信息-原文.md)*