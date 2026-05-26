# 非同业单位存款发生额信息（JS_202_DWCKFS）

> **来源**：[JS_202_DWCKFS_非同业单位存款发生额信息-原文.md](../参考资料/发文原文/JS_202_DWCKFS_非同业单位存款发生额信息-原文.md)

## 业务分类

| 属性 | 值 |
|------|-----|
| 接口表 | `JS_202_DWCKFS` |
| 中文名 | 非同业单位存款发生额信息 |
| 章节 | 3.4.2.2 |
| 时间范围 | 报告期内发生、结清、收回、兑付、买卖等发生额数据，具体以官方报送范围为准。 |
| 报送粒度 | 以单笔交易流水为核心识别维度逐笔报送。 |

---

# 第一部分：发文原文要求（人行规范层）

> **用于回答"这个表要求报送什么"、"新增业务应该报到哪个表"等问题**

## 1. 官方报送范围

非同业单位存款发生额指金融机构报告期内新发生、结清、发生又结清的非同业单位存款。以存款账户下单笔存款协议为单位逐笔报送。

## 2. 纳入与排除口径

| 方向 | 内容 |
|------|------|
| ✅ 纳入 | 按官方报送范围采集规范定义的相关业务。 |
| ❌ 排除 | 未在官方口径中明确排除的，应按采集任务和字段规则判断是否纳入。 |

## 3. 关键业务要素（要求报送的内容维度）

报送机构及经办机构识别；交易主体/客户主体识别；合同、协议或资产唯一标识；金额、币种及折人民币计量；起止日期、到期日或实际终止日；地区、行业、部门及企业属性分类。

## 4. 字段清单

完整字段清单（共27个字段）及填报说明、码值表详见原文文件：
[JS_202_DWCKFS_非同业单位存款发生额信息-原文.md](../参考资料/发文原文/JS_202_DWCKFS_非同业单位存款发生额信息-原文.md)

---


# 第二部分：代码取数业务范围（实现层）

> **用于回答"这个表怎么取数"、"取了哪些业务"、"业务变更对金数有什么影响"等问题**

## 1. 数据生成程序

`bsp_sp_js_202_dwckfs.prc`（加工层存储过程）

## 2. 监管集市表来源

| 表名 | 中文名 | 角色 |
|------|--------|------|
| `SMTMODS.L_ACCT_DEPOSIT` | 存款账户信息表 | **主表** |
| `SMTMODS.L_ACCT_INNER` | 内部分户账 | **内部账** |
| `SMTMODS.L_CUST_C` | 对公客户补充信息表 | **对公客户** |
| `SMTMODS.L_FINA_GL` | 总账科目表 | **科目过滤** |
| `SMTMODS.L_PUBL_RATE` | 汇率表 | **汇率折算** |
| `SMTMODS.L_TRAN_TX` | 交易信息表 | **交易流水** |

## 3. 输出接口表

`JS_xxx` — 生成接口表 JS_202_DWCKFS 非同业单位存款发生额

## 4. 业务筛选条件

**程序用途**：生成接口表 JS_202_DWCKFS 非同业单位存款发生额

**SMTMODS 数据源表**：
- `SMTMODS.L_TRAN_TX`
- `SMTMODS.L_ACCT_DEPOSIT`
- `SMTMODS.L_CUST_C`
- `SMTMODS.L_PUBL_RATE`
- `SMTMODS.L_FINA_GL`
- `SMTMODS.L_ACCT_INNER`

**时间筛选**：
```sql
WHERE T.DATA_DATE = IS_DATE  -- 数据日期等于跑批日期，取当前批次数据
```

**业务筛选条件**：
```sql
WHERE TABLE_NAME = 'PBOCD_JS_202_DWCKFS_TMP'
WHERE TABLE_NAME = 'PBOCD_JS_202_DWCKFS'
AND (T.TRAN_CODE_DESCRIBE NOT IN ('转久悬', '久悬激活') OR (T.TRAN_CODE_DESCRIBE='久悬激活' AND TRANTYPE2_DESC='营业外激活'))
WHEN B.ACCT_TYPE = '0601' AND B.GL_ITEM_CODE='20110201' THEN
WHEN B.ACCT_TYPE = '0602' AND B.GL_ITEM_CODE='20110201' THEN--20220705-夏文博
--CASE WHEN B.ACCT_TYPE = '0101' AND NVL(B.INT_RATE,0) = 0  THEN 4.5 else B.INT_RATE end, --17利率水平
CASE WHEN T.TRANS_CHANNEL IN( 'JCBS','SMKS','NGIJ','HSFJ','JCMS','NBIS','EFSM','AG','CCUF','ISCP','FMSJ','DECD','CCIP','GBAJ','TIPS','DTIP') AND T.CD_TYPE = '2' THEN
WHEN T.TRANS_CHANNEL = 'GLS' AND SUBSTR(T.SERIAL_NO,1,4)='FMSJ' AND T.CD_TYPE IN( '2','1' )THEN
```



## 5. 特殊处理规则

| 字段 | 规则 | 说明 |
|------|------|------|
| `...` | `REGEXP_REPLACE(REGEXP_REPLACE(CASE WHEN T.CUST_ID LIKE '2999...` | 6注册地址 |
| `...` | `CASE WHEN TO_CHAR(B.ST_INT_DT, 'YYYY-MM-DD')='1900-01-01'` | 字段映射规则 |
| `...` | `CASE WHEN (` | 字段映射规则 |
| `...` | `(CASE WHEN T.TRANS_AMT < 0 THEN` | 字段映射规则 |
| `...` | `CASE WHEN T.CD_TYPE = '2' THEN '0' ELSE '1' END` | 字段映射规则 |
| `...` | `CASE WHEN T.CD_TYPE = '2' THEN '1' ELSE '0' END` | 字段映射规则 |
| `...` | `CASE WHEN T.TRANS_AMT < 0 THEN ABS(T.TRANS_AMT) ELSE T.TRANS...` | 15存款发生金额 |
| `...` | `CASE WHEN T.TRANS_AMT < 0 THEN ABS(T.TRANS_AMT)*E.CCY_RATE E...` | 16存款发生金额折人民币 |
| `...` | `CASE WHEN T.TRANS_AMT < 0 THEN` | 字段映射规则 |

## 6. 历史变更记录

| 编号 | 日期 | 修改人 | 提出人 | 原因 |
|------|------|--------|--------|------|
| JLBA202412270002 | 2025-04-27 | 周立鹏 | 李楠 | 剔除取上期/配置表 |

## 7. 涉及源码文件

| 角色 | 文件路径 |
|------|---------|
| 数据生成（主程序） | `源码/加工层存储/bsp_sp_js_202_dwckfs.prc` |
| 数据生成（解析版） | `源码解析/加工层存储/bsp_sp_js_202_dwckfs.prc` |

---

> **使用说明**：
> - 问"**要求报送什么**"→ 查**第一部分（发文原文要求）**
> - 问"**怎么取数/取了哪些业务/业务变更影响**"→ 查**第二部分（代码取数业务范围）**

*← [返回首页索引](../首页/index.md) · 原文：[JS_202_DWCKFS_非同业单位存款发生额信息-原文.md](../参考资料/发文原文/JS_202_DWCKFS_非同业单位存款发生额信息-原文.md)*