# 存量个人存款信息（JS_202_CLGRCK）

> **来源**：[JS_202_CLGRCK_存量个人存款信息-原文.md](../参考资料/发文原文/JS_202_CLGRCK_存量个人存款信息-原文.md)

## 业务分类

| 属性 | 值 |
|------|-----|
| 接口表 | `JS_202_CLGRCK` |
| 中文名 | 存量个人存款信息 |
| 章节 | 3.4.2.3 |
| 时间范围 | 报告期末存续数据。 |
| 报送粒度 | 以业务合同或协议为单位逐笔报送。 |

---

# 第一部分：发文原文要求（人行规范层）

> **用于回答"这个表要求报送什么"、"新增业务应该报到哪个表"等问题**

## 1. 官方报送范围

存量个人存款指金融机构报告期末存续的、在金融机构资产负债表内核算的个人存款。以存款账户下单笔存款协议为单位逐笔报送。

## 2. 纳入与排除口径

| 方向 | 内容 |
|------|------|
| ✅ 纳入 | 按官方报送范围采集规范定义的相关业务。 |
| ❌ 排除 | 无特殊排除。 |

## 3. 关键业务要素（要求报送的内容维度）

报送机构及经办机构识别；交易主体/客户主体识别；合同、协议或资产唯一标识；金额、币种及折人民币计量；利率与计息要素；起止日期、到期日或实际终止日；地区、行业、部门及企业属性分类。

## 4. 字段清单

完整字段清单（共8个字段）及填报说明、码值表详见原文文件：
[JS_202_CLGRCK_存量个人存款信息-原文.md](../参考资料/发文原文/JS_202_CLGRCK_存量个人存款信息-原文.md)

---


# 第二部分：代码取数业务范围（实现层）

> **用于回答"这个表怎么取数"、"取了哪些业务"、"业务变更对金数有什么影响"等问题**

## 1. 数据生成程序

`bsp_sp_js_202_clgrck.prc`（加工层存储过程）

## 2. 监管集市表来源

| 表名 | 中文名 | 角色 |
|------|--------|------|
| `SMTMODS.L_ACCT_DEPOSIT` | 存款账户信息表 | **主表** |
| `SMTMODS.L_CUST_C` | 对公客户补充信息表 | **客户信息** |
| `SMTMODS.L_FINA_GL` | 总账科目表 | **科目过滤** |
| `SMTMODS.L_PUBL_RATE` | 汇率表 | **汇率折算** |

## 3. 输出接口表

`JS_xxx` — 生成接口表 JS_202_CLGRCK 存量个人存款信息

## 4. 业务筛选条件

**程序用途**：生成接口表 SP_JS_202_CLGRCK 存量个人存款信息

**SMTMODS 数据源表**：
- `SMTMODS.L_ACCT_DEPOSIT`
- `SMTMODS.L_PUBL_RATE`
- `SMTMODS.L_CUST_C`
- `SMTMODS.L_FINA_GL`

**时间筛选**：
```sql
WHERE T.DATA_DATE = IS_DATE  -- 数据日期等于跑批日期，取当前批次数据
```

**业务筛选条件**：
```sql
WHERE TABLE_NAME = 'PBOCD_JS_202_CLGRCK_TMP'
(CASE WHEN B.LEGAL_CARD_TYPE IS NULL AND LENGTH(B.LEGAL_CARD_NO)=18
WHEN B.LEGAL_CARD_TYPE IS NULL AND LENGTH(B.LEGAL_CARD_NO)=18 AND SUBSTR(B.LEGAL_CARD_NO,7,8) BETWEEN '19000101' AND '21001231' THEN SUBSTR(B.LEGAL_CARD_NO,1,6)--法人身份证号前6位
AND B.DEPOSIT_CUSTTYPE IN ('13', '14') --个体工商户
/*  AND A.ACCT_TYPE NOT LIKE '07%' --保证金存款不区分个体工商户 参照大集中
AND F.CODE_CLMN_NAME = 'ID_TYPE'
--WHEN (A.ACCT_TYPE like '07%' OR A.GL_ITEM_CODE IN('20110114','20110115')) AND NVL(TO_CHAR(A.MATUR_DATE, 'YYYYMMDD'),'99991231') < IS_DATE THEN
WHEN (A.ACCT_TYPE like '07%' OR A.GL_ITEM_CODE IN('20110114','20110115')) AND NVL(TO_CHAR(A.MATUR_DATE, 'YYYYMMDD'),'99991231') <= IS_DATE THEN
```



## 5. 特殊处理规则

| 字段 | 规则 | 说明 |
|------|------|------|
| `...` | `(CASE WHEN B.LEGAL_CARD_TYPE IS NULL AND LENGTH(B.LEGAL_CARD...` | 字段映射规则 |
| `...` | `CASE WHEN A.GL_ITEM_CODE IN ('20110201', '22410101') THEN 'D...` | 个人活期 |
| `...` | `CASE WHEN (TO_CHAR(A.ST_INT_DT, 'YYYY-MM-DD')='1900-01-01'` | 字段映射规则 |
| `...` | `(CASE WHEN A.INT_RATE = 0.8 THEN '1999-01-01'` | 字段映射规则 |
| `...` | `CASE WHEN LENGTH(TRIM(OB.REGION_CD)) = 6 AND OB.REGION_CD NO...` | 金融机构地区代码 |
| `...` | `/*CASE WHEN LENGTH(TRIM(C.REGION_CD)) = 6 THEN C.REGION_CD` | 字段映射规则 |
| `...` | `CASE WHEN A.GL_ITEM_CODE IN ('20110101','22410102') THEN 'D0...` | 个人活期存款 |
| `...` | `CASE WHEN (TO_CHAR(A.ST_INT_DT, 'YYYY-MM-DD')='1900-01-01'` | 字段映射规则 |
| `...` | `(CASE WHEN A.INT_RATE = 0.8 THEN '1999-01-01' ELSE '1999-01-...` | 字段映射规则 |

## 6. 历史变更记录

| 编号 | 日期 | 修改人 | 提出人 | 原因 |
|------|------|--------|--------|------|
| JLBA202412270002 | 2025-05-27 | 周立鹏 | 李楠 | 剔除取上期/配置表 |

## 7. 涉及源码文件

| 角色 | 文件路径 |
|------|---------|
| 数据生成（主程序） | `源码/加工层存储/bsp_sp_js_202_clgrck.prc` |
| 数据生成（解析版） | `源码解析/加工层存储/bsp_sp_js_202_clgrck.prc` |

---

> **使用说明**：
> - 问"**要求报送什么**"→ 查**第一部分（发文原文要求）**
> - 问"**怎么取数/取了哪些业务/业务变更影响**"→ 查**第二部分（代码取数业务范围）**

*← [返回首页索引](../首页/index.md) · 原文：[JS_202_CLGRCK_存量个人存款信息-原文.md](../参考资料/发文原文/JS_202_CLGRCK_存量个人存款信息-原文.md)*