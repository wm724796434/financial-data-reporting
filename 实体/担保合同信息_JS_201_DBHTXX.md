# 担保合同信息（JS_201_DBHTXX）

> **来源**：[JS_201_DBHTXX_担保合同信息-原文.md](../参考资料/发文原文/JS_201_DBHTXX_担保合同信息-原文.md)

## 业务分类

| 属性 | 值 |
|------|-----|
| 接口表 | `JS_201_DBHTXX` |
| 中文名 | 担保合同信息 |
| 章节 | 3.2.3.1 |
| 时间范围 | 报告期末存续数据。 |
| 报送粒度 | 以业务合同或协议为单位逐笔报送。 |

---

# 第一部分：发文原文要求（人行规范层）

> **用于回答"这个表要求报送什么"、"新增业务应该报到哪个表"等问题**

## 1. 官方报送范围

担保合同是指金融机构与借款人（或与借款人及第三人）之间协商形成的，当借款人不履行或无法履行债务时，以一定方式保证金融机构债权得以实现的协议。担保合同信息报告金融机构期末存续的担保合同，以合同为单位逐笔报送。

## 2. 纳入与排除口径

| 方向 | 内容 |
|------|------|
| ✅ 纳入 | 按官方报送范围采集规范定义的相关业务。 |
| ❌ 排除 | 无特殊排除。 |

## 3. 关键业务要素（要求报送的内容维度）

报送机构及经办机构识别；交易主体/客户主体识别；合同、协议或资产唯一标识；金额、币种及折人民币计量；利率与计息要素；起止日期、到期日或实际终止日；地区、行业、部门及企业属性分类。

## 4. 字段清单

完整字段清单（共16个字段）及填报说明、码值表详见原文文件：
[JS_201_DBHTXX_担保合同信息-原文.md](../参考资料/发文原文/JS_201_DBHTXX_担保合同信息-原文.md)

---

# 第二部分：代码取数业务范围（实现层）

> **用于回答"这个表怎么取数"、"取了哪些业务"、"业务变更对金数有什么影响"等问题**

## 1. 数据生成程序

`bsp_sp_js_201_dbhtxx.prc`（加工层存储过程）

## 2. 监管集市表来源

| 表名 | 中文名 | 角色 |
|------|--------|------|
| `SMTMODS.L_ACCT_LOAN` | 贷款借据信息表 | **主表**—借据信息及核销/转让状态 |
| `SMTMODS.L_AGRE_GUARANTEE_CONTRACT` | 担保合同信息表 | **主表**—担保合同基本信息 |
| `SMTMODS.L_AGRE_GUARANTEE_RELATION` | 担保合同与担保信息对应关系表 | **关联表**—合同-押品关系 |
| `SMTMODS.L_AGRE_GUARANTY_INFO` | 抵质押物详细信息 | **押品表**—抵质押物价值 |
| `SMTMODS.L_AGRE_GUA_RELATION` | 业务合同与担保合同对应关系表 | **关联表**—贷款-担保关系 |
| `SMTMODS.L_AGRE_LOAN_CONTRACT` | 贷款合同信息表 | **合同表**—贷款合同信息 |
| `SMTMODS.L_CODE_DICTIONARY` | 码值字典表 | **映射表**—码值转换 |
| `SMTMODS.L_CUST_ALL` | 全量客户信息表 | **客户信息**—客户基本信息 |
| `SMTMODS.L_CUST_C` | 对公客户补充信息表 | **对公客户**—对公客户属性 |
| `SMTMODS.L_CUST_P` | 对私客户补充信息表 | **对私客户**—个人客户属性 |
| `SMTMODS.L_PUBL_RATE` | 汇率表 | **汇率折算**—外币折算人民币 |

## 3. 业务筛选条件

### 3.1 抵质押物有效性

```sql
WHERE GI.COLL_STATUS = 'Y'            -- 抵质押物状态有效
  AND GR.REL_STATUS = 'Y'             -- 担保关系存续
```

### 3.2 贷款余额及状态过滤

```sql
WHERE D.LOAN_ACCT_BAL > 0            -- 余额大于0
  AND D.CANCEL_FLG = 'N'             -- 未核销
  AND D.LOAN_STOCKEN_DATE IS NULL    -- 资产未转让
```

### 3.3 核销客户剔除

从担保合同数据中剔除核销客户（`CANCEL_FLG='Y'`）的客户ID，存入`JS_102_FTYKHX_TEMP03`中间表。

## 4. 特殊处理规则

### 4.1 担保人唯一性去重

同一个担保人证件号码可能对应两个不同的客户编码，需通过`DBHTXX_BZR_TMP01`中间表做唯一性处理：

```sql
-- 中间表分组统计，按证件号码+担保合同编号去重
INSERT INTO DBHTXX_BZR_TMP01 NOLOGGING
SELECT DATE_SOURCESD, GUAR_CONTRACT_NUM, ...
  GROUP BY 证件号码, GUAR_CONTRACT_NUM
```

### 4.2 押品价值汇总

担保合同对应的全部抵质押物价值汇总：

```sql
-- 按担保合同编号汇总押品价值
SELECT GR.GUAR_CONTRACT_NUM, SUM(GI.COLL_MK_VAL) AS COLL_VALUE
  FROM SMTMODS.L_AGRE_GUARANTY_INFO GI
 INNER JOIN SMTMODS.L_AGRE_GUARANTEE_RELATION GR
    ON GI.GUARANTEE_SERIAL_NUM = GR.GUARANTEE_SERIAL_NUM
 WHERE GI.COLL_STATUS = 'Y' AND GR.REL_STATUS = 'Y'
 GROUP BY GR.GUAR_CONTRACT_NUM;
```

### 4.3 贷款余额汇总

担保合同对应的贷款余额按合同汇总：

```sql
SELECT D.ACCT_NUM, SUM(D.LOAN_ACCT_BAL) AS LOAN_ACCT_BAL_SUM
  FROM SMTMODS.L_ACCT_LOAN D
 WHERE D.LOAN_ACCT_BAL > 0 AND D.CANCEL_FLG = 'N'
   AND D.LOAN_STOCKEN_DATE IS NULL
 GROUP BY D.ACCT_NUM;
```

## 5. 中间表说明

| 中间表 | 用途 |
|--------|------|
| `GUAR_CONTRACT_TMP01` | 担保合同中间表 |
| `DBHTXX_BZR_TMP01` | 保证人信息中间表（去重） |
| `ACCT_LOAN_TMP01` | 借据信息中间表 |
| `JS_102_FTYKHX_TEMP03` | 核销客户名单（排除用） |
| `DBHTXX_PLED_TEMP1` | 押品价值汇总中间表 |
| `DBHTXX_PLED_TEMP2` | 贷款余额汇总中间表 |

## 6. 历史变更记录

| 编号 | 日期 | 修改人 | 提出人 | 原因 |
|------|------|--------|--------|------|
| JLBA202412270002 | 2025-04-27 | 周立鹏 | 李楠 | 剔除取上期/配置表 |

## 7. 涉及源码文件

| 角色 | 文件路径 |
|------|---------|
| 数据生成（主程序） | `源码/加工层存储/bsp_sp_js_201_dbhtxx.prc` |
| 数据生成（解析版） | `源码解析/加工层存储/bsp_sp_js_201_dbhtxx.prc` |
