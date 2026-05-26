# 存量票据融资信息（JS_205_CLPJRZ）

> **来源**：[JS_205_CLPJRZ_存量票据融资信息-原文.md](../参考资料/发文原文/JS_205_CLPJRZ_存量票据融资信息-原文.md)

## 业务分类

| 属性 | 值 |
|------|-----|
| 接口表 | `JS_205_CLPJRZ` |
| 中文名 | 存量票据融资信息 |
| 章节 | 3.7.1.1 |
| 时间范围 | 报告期末存续数据。 |
| 报送粒度 | 可分包票据以票据（包）的子票区间为单位逐笔报送；不可分包票据以单张票据为单位逐笔报送。 |

---

# 第一部分：发文原文要求（人行规范层）

> **用于回答"这个表要求报送什么"、"新增业务应该报到哪个表"等问题**

## 1. 官方报送范围

存量票据融资指金融机构报告期末存续的贴现及买断式转贴现业务。可分包票据以票据（包）的子票区间为单位逐笔报送。不可分包票据以单张票据为单位逐笔报送。

## 2. 纳入与排除口径

| 方向 | 内容 |
|------|------|
| ✅ 纳入 | 按官方报送范围采集规范定义的相关业务。 |
| ❌ 排除 | 未在官方口径中明确排除的，应按采集任务和字段规则判断是否纳入。 |

## 3. 关键业务要素（要求报送的内容维度）

报送机构及经办机构识别；金额、币种及折人民币计量；利率与计息要素；起止日期、到期日或实际终止日；地区、行业、部门及企业属性分类。

## 4. 字段清单

完整字段清单（共32个字段）及填报说明、码值表详见原文文件：
[JS_205_CLPJRZ_存量票据融资信息-原文.md](../参考资料/发文原文/JS_205_CLPJRZ_存量票据融资信息-原文.md)

---


# 第二部分：代码取数业务范围（实现层）

> **用于回答"这个表怎么取数"、"取了哪些业务"、"业务变更对金数有什么影响"等问题**

## 1. 数据生成程序

`bsp_sp_js_205_clpjrz.prc`（加工层存储过程）

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

## 3. 输出接口表

`JS_xxx` — 生成接口表 JS_205_CLPJRZ 存量票据融资

## 4. 业务筛选条件

**程序用途**：生成接口表 JS_205_CLPJRZ 存量票据融资

**SMTMODS 数据源表**：
- `SMTMODS.L_ACCT_LOAN`
- `SMTMODS.L_AGRE_BILL_INFO`
- `SMTMODS.L_CUST_BILL_TY`
- `SMTMODS.L_CUST_P`
- `SMTMODS.L_CUST_ALL`
- `SMTMODS.L_CUST_C`
- `SMTMODS.L_PUBL_RATE`

**时间筛选**：
```sql
WHERE T.DATA_DATE = IS_DATE  -- 数据日期等于跑批日期，取当前批次数据
```

**业务筛选条件**：
```sql
WHERE TABLE_NAME = 'JS_205_CLPJRZ'
,CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) AND TRIM(B.BILL_TYPE) = '1'THEN 'A01'
,CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) AND TRIM(B.BILL_TYPE) = '1'THEN
/*,CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) AND TRIM(B.BILL_TYPE) = '1' THEN 'C01'
,CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) AND TRIM(B.BILL_TYPE) = '1' THEN
,CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) AND TRIM(B.BILL_TYPE) = '1' THEN
) A WHERE A.RN=1) B
ON A.LEGAL_TYSHXYDM=B.TYSHXYDM) WHERE RN = 1)FR
```



## 5. 特殊处理规则

| 字段 | 规则 | 说明 |
|------|------|------|
| `...` | `CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) THE...` | 字段映射规则 |
| `...` | `CASE WHEN TRIM(B.BILL_TYPE) = '1' THEN '01'` | 银行承兑汇票 |
| `...` | `CASE WHEN B.IS_P_BILL = 'Y' THEN '01'` | 字段映射规则 |
| `...` | `/*,CASE WHEN H.TYSHXYDM IS NOT NULL THEN 'A01'` | 字段映射规则 |
| `...` | `CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) AND...` | 字段映射规则 |
| `...` | `ELSE CASE WHEN H.TYSHXYDM IS NOT NULL THEN 'A01'` | 字段映射规则 |
| `...` | `/*, CASE WHEN H.TYSHXYDM IS NOT NULL THEN H.TYSHXYDM` | 字段映射规则 |
| `...` | `CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) AND...` | 字段映射规则 |
| `...` | `VL( CASE WHEN H.TYSHXYDM IS NOT NULL THEN H.TYSHXYDM` | 字段映射规则 |
| `...` | `ELSE CASE WHEN H.TYSHXYDM IS NOT NULL THEN H.TYSHXYDM` | 字段映射规则 |

## 6. 历史变更记录

| 编号 | 日期 | 修改人 | 提出人 | 原因 |
|------|------|--------|--------|------|
| JLBA202412270002 | 2025-04-27 | 周立鹏 | 李楠 | 剔除取上期/配置表 |

## 7. 涉及源码文件

| 角色 | 文件路径 |
|------|---------|
| 数据生成（主程序） | `源码/加工层存储/bsp_sp_js_205_clpjrz.prc` |
| 数据生成（解析版） | `源码解析/加工层存储/bsp_sp_js_205_clpjrz.prc` |

---

> **使用说明**：
> - 问"**要求报送什么**"→ 查**第一部分（发文原文要求）**
> - 问"**怎么取数/取了哪些业务/业务变更影响**"→ 查**第二部分（代码取数业务范围）**

*← [返回首页索引](../首页/index.md) · 原文：[JS_205_CLPJRZ_存量票据融资信息-原文.md](../参考资料/发文原文/JS_205_CLPJRZ_存量票据融资信息-原文.md)*