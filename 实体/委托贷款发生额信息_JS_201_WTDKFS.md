# 委托贷款发生额信息（JS_201_WTDKFS）

> **来源**：[JS_201_WTDKFS_委托贷款发生额信息-原文.md](../参考资料/发文原文/JS_201_WTDKFS_委托贷款发生额信息-原文.md)

## 业务分类

| 属性 | 值 |
|------|-----|
| 接口表 | `JS_201_WTDKFS` |
| 中文名 | 委托贷款发生额信息 |
| 章节 | 3.2.4.2 |
| 时间范围 | 报告期内发生、结清、收回、兑付、买卖等发生额数据，具体以官方报送范围为准。 |
| 报送粒度 | 以单笔交易流水为核心识别维度逐笔报送。 |

---

# 第一部分：发文原文要求（人行规范层）

> **用于回答"这个表要求报送什么"、"新增业务应该报到哪个表"等问题**

## 1. 官方报送范围

委托贷款发生额指金融机构报告期内发放、收回、发放又收回的委托贷款（不含现金管理类委托贷款和个人住房公积金委托贷款）。以贷款合同下单笔借据为单位逐笔报送。

## 2. 纳入与排除口径

| 方向 | 内容 |
|------|------|
| ✅ 纳入 | 按官方报送范围采集规范定义的相关业务。 |
| ❌ 排除 | 不含现金管理类委托贷款和个人住房公积金委托贷款 |

## 3. 关键业务要素（要求报送的内容维度）

报送机构及经办机构识别；交易主体/客户主体识别；合同、协议或资产唯一标识；金额、币种及折人民币计量；利率与计息要素；地区、行业、部门及企业属性分类。

## 4. 字段清单

完整字段清单（共32个字段）及填报说明、码值表详见原文文件：
[JS_201_WTDKFS_委托贷款发生额信息-原文.md](../参考资料/发文原文/JS_201_WTDKFS_委托贷款发生额信息-原文.md)

---


# 第二部分：代码取数业务范围（实现层）

> **用于回答"这个表怎么取数"、"取了哪些业务"、"业务变更对金数有什么影响"等问题**

## 1. 数据生成程序

`bsp_sp_js_201_wtdkfs.prc`（加工层存储过程）

## 2. 监管集市表来源

| 表名 | 中文名 | 角色 |
|------|--------|------|
| `SMTMODS.L_ACCT_LOAN` | 贷款借据信息表 | **主表** |
| `SMTMODS.L_ACCT_LOAN_ENTRUST` | 委托贷款补充信息 | **委托人信息** |
| `SMTMODS.L_CUST_C` | 对公客户补充信息表 | **对公客户** |
| `SMTMODS.L_CUST_P` | 对私客户补充信息表 | **个人客户** |
| `SMTMODS.L_Cust_ALL` | 全量客户信息表 | **客户信息** |
| `SMTMODS.L_TRAN_LOAN_PAYM` | 贷款还款明细信息表 | **还款信息** |

## 3. 输出接口表

`JS_xxx` — 生成接口表 JS_201_WTDKFS 委托贷款发生额信息

## 4. 业务筛选条件

**程序用途**：生成接口表 JS_201_WTDKFS 委托贷款发生额信息

**SMTMODS 数据源表**：
- `SMTMODS.L_ACCT_LOAN`
- `SMTMODS.L_TRAN_LOAN_PAYM`
- `SMTMODS.L_CUST_C`
- `SMTMODS.L_CUST_P`
- `SMTMODS.L_Cust_ALL`
- `SMTMODS.L_ACCT_LOAN_ENTRUST`

**时间筛选**：
```sql
WHERE T.DATA_DATE = IS_DATE  -- 数据日期等于跑批日期，取当前批次数据
```

**业务筛选条件**：
```sql
WHERE TABLE_NAME = 'JS_201_WTDKFS'
WHERE  trim(LC.Legal_Card_TYPE) = D4.L_CODE
AND D4.CODE_CLMN_NAME = 'ID_TYPE')
WHERE  trim(LC.Legal_Card_TYPE) = D4.L_CODE
AND D4.CODE_CLMN_NAME = 'ID_TYPE')
AND CD1.CODE_CLMN_NAME = 'ID_TYPE'
AND CD2.CODE_CLMN_NAME = 'ID_TYPE' --借款人证件代码
AND CD3.CODE_CLMN_NAME = 'CORP_HOLD_TYPE' --企业控股类型
```



## 5. 特殊处理规则

| 字段 | 规则 | 说明 |
|------|------|------|
| `...` | `VL2(LP.CUST_ID, 'D01', CASE when LC.CUST_TYP='3'  THEN 'D01'...` | 借款人国民经济部门 |
| `...` | `/*CASE WHEN LC.CUST_TYP='3' THEN` | 字段映射规则 |
| `...` | `VL2(LC.ID_NO,CASE WHEN LENGTH(LC.ID_NO) = 18 THEN 'A01' ELSE...` | 字段映射规则 |
| `...` | `CASE WHEN LP.ID_TYPE IS NOT NULL THEN LP.ID_NO` | 字段映射规则 |
| `...` | `CASE WHEN LC.CUST_TYP='3' THEN` | 字段映射规则 |
| `...` | `CASE WHEN  LC.CUST_TYP='3' THEN '' ELSE CD3.PBOCD_CODE END,` | 借款人经济成分 |
| `...` | `CASE WHEN LC.CUST_TYP='3' THEN NULL` | 字段映射规则 |
| `...` | `VL2(LC.id_no,CASE WHEN LENGTH(LC.id_no) = 18 THEN 'A01' ELSE...` | 委托人证件类型 |
| `...` | `VL2(LP.CUST_ID,LP.ID_NO,CASE WHEN CD1.PBOCD_CODE = 'A02' THE...` | 委托人证件代码 |

## 6. 历史变更记录

| 编号 | 日期 | 修改人 | 提出人 | 原因 |
|------|------|--------|--------|------|
| JLBA202412270002 | 2025-04-27 | 周立鹏 | 李楠 | 剔除取上期/配置表 |

## 7. 涉及源码文件

| 角色 | 文件路径 |
|------|---------|
| 数据生成（主程序） | `源码/加工层存储/bsp_sp_js_201_wtdkfs.prc` |
| 数据生成（解析版） | `源码解析/加工层存储/bsp_sp_js_201_wtdkfs.prc` |

---

> **使用说明**：
> - 问"**要求报送什么**"→ 查**第一部分（发文原文要求）**
> - 问"**怎么取数/取了哪些业务/业务变更影响**"→ 查**第二部分（代码取数业务范围）**

*← [返回首页索引](../首页/index.md) · 原文：[JS_201_WTDKFS_委托贷款发生额信息-原文.md](../参考资料/发文原文/JS_201_WTDKFS_委托贷款发生额信息-原文.md)*