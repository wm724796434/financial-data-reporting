# 存量个人贷款信息（JS_201_CLGRDK）

> **来源**：[JS_201_CLGRDK_存量个人贷款信息-原文.md](../参考资料/发文原文/JS_201_CLGRDK_存量个人贷款信息-原文.md)

## 业务分类

| 属性 | 值 |
|------|-----|
| 接口表 | `JS_201_CLGRDK` |
| 中文名 | 存量个人贷款信息 |
| 章节 | 3.2.2.4 |
| 时间范围 | 报告期末存续数据。 |
| 报送粒度 | 以贷款合同下单笔借据为单位逐笔报送。 |

---

# 第一部分：发文原文要求（人行规范层）

> **用于回答"这个表要求报送什么"、"新增业务应该报到哪个表"等问题**

## 1. 官方报送范围

存量个人贷款指金融机构报告期末存续的、在资产负债表内核算的个人贷款，不含金融机构已核销、剥离、转出的贷款。以贷款合同下单笔借据为单位逐笔报送。

## 2. 纳入与排除口径

| 方向 | 内容 |
|------|------|
| ✅ 纳入 | 按官方报送范围采集规范定义的相关业务。 |
| ❌ 排除 | 未在官方口径中明确排除的，应按采集任务和字段规则判断是否纳入。 |

## 3. 关键业务要素（要求报送的内容维度）

报送机构及经办机构识别；交易主体/客户主体识别；合同、协议或资产唯一标识；金额、币种及折人民币计量；利率与计息要素；起止日期、到期日或实际终止日；地区、行业、部门及企业属性分类。

## 4. 字段清单

完整字段清单（共27个字段）及填报说明、码值表详见原文文件：
[JS_201_CLGRDK_存量个人贷款信息-原文.md](../参考资料/发文原文/JS_201_CLGRDK_存量个人贷款信息-原文.md)

---


# 第二部分：代码取数业务范围（实现层）

> **用于回答"这个表怎么取数"、"取了哪些业务"、"业务变更对金数有什么影响"等问题**

## 1. 数据生成程序

`bsp_sp_js_201_clgrdk.prc`（加工层存储过程）

## 2. 监管集市表来源

| 表名 | 中文名 | 角色 |
|------|--------|------|
| `SMTMODS.L_ACCT_LOAN` | 贷款借据信息表 | **主表** |
| `SMTMODS.L_PUBL_RATE` | 汇率表 | **汇率折算** |
| `SMTMODS.v_pub_idx_dk_zqdqrjj` | 展期到期日期视图 | **展期信息** |

## 3. 输出接口表

`JS_xxx` — 生成接口表 JS_201_CLGRDK 存量个人贷款

## 4. 业务筛选条件（代码实际取数范围）

### 4.1 会计科目范围（核心过滤条件）

```sql
T.ACCT_TYP LIKE '01%'   -- 01开头=个人贷款科目
```

| 科目前缀 | 说明 |
|----------|------|
| 01% | 个人贷款科目（个人消费贷、个人经营贷等各类个人贷款） |

> 存量个人贷款通过 **科目（ACCT_TYP）** 辨别，存量单位贷款通过 **科目（ITEM_CD）** 辨别，两个报表使用不同的字段体系。

### 4.2 客户类型范围

通过 INNER JOIN `JS_102_GRKHXX`（个人客户基础信息表）**隐性过滤**非个人客户。INNER JOIN 即过滤条件——客户在个人客户表中不存在则整行排除。

```sql
INNER JOIN (SELECT ... FROM JS_102_GRKHXX WHERE DATA_DATE = IS_DATE) C
   ON T.CUST_ID = C.CUST_ID
  AND C.CJRQ = IS_DATE
  AND C.RN = 1
```

**不包含**：对公客户。与存量单位贷款显式排除个体工商户（`CUST_TYP <> '3'`）不同，此处仅通过连接个人客户表做隐性限定。

### 4.3 排除条件

| 条件 | 位置 | 说明 |
|------|------|------|
| `T.LOAN_ACCT_BAL > 0` | WHERE | 余额大于0（存量在贷） |
| `T.CURR_CD = 'CNY'` | WHERE | 仅取人民币贷款（外币个人贷款不纳入） |
| `T.CANCEL_FLG = 'N'` | WHERE | 未核销 —— 码表A0010：Y=是（已核销）、N=否（保留） |
| `T.LOAN_STOCKEN_DATE IS NULL` | WHERE | 资产未转让（未证券化） |

### 4.4 完整取数范围（FROM + JOIN + WHERE）

以下条件**共同决定一条记录能否进入存量个人贷款**，包含 INNER JOIN（过滤）和 WHERE（过滤），LEFT JOIN 不排数据只补充字段：

```sql
FROM SMTMODS.L_ACCT_LOAN T                          -- 主表：贷款借据

INNER JOIN (                                         -- 【过滤】仅取个人客户
    SELECT ROW_NUMBER() OVER(PARTITION BY T.CUST_ID
                             ORDER BY T.CUST_ID DESC) RN,
           T.*
      FROM JS_102_GRKHXX T
     WHERE T.DATA_DATE = IS_DATE
) C
   ON T.CUST_ID = C.CUST_ID
  AND C.CJRQ = IS_DATE
  AND C.RN = 1

LEFT JOIN SMTMODS.L_PUBL_RATE R                      -- 不排数据，仅汇率折算
  ON R.DATA_DATE = IS_DATE
 AND R.BASIC_CCY = T.CURR_CD
 AND R.FORWARD_CCY = 'CNY'

LEFT JOIN DBFS_TMP TP7                               -- 不排数据，仅担保方式
  ON T.LOAN_NUM = TP7.LOAN_NUM

LEFT JOIN SMTMODS.v_pub_idx_dk_zqdqrjj ZQ            -- 不排数据，仅展期到期日
  ON T.LOAN_NUM = ZQ.LOAN_NUM
 AND T.DATA_DATE = ZQ.DATA_DATE

LEFT JOIN L_ACCT_LOAN_SUOQI T1                       -- 不排数据，仅缩期判断
  ON T.LOAN_NUM = T1.LOAN_NUM
 AND T.MATURITY_DT_BEFORE = T1.MATURITY_DT_BEFORE
 AND T.MATURITY_DT = T1.MATURITY_DT

WHERE T.DATA_DATE = IS_DATE                           -- 【过滤】数据日期=跑批日期
  AND T.LOAN_ACCT_BAL > 0                             -- 【过滤】余额大于0
  AND T.CURR_CD = 'CNY'                               -- 【过滤】仅人民币
  AND T.ACCT_TYP LIKE '01%'                           -- 【过滤】个人贷款科目
  AND T.CANCEL_FLG = 'N'                              -- 【过滤】未核销
  AND T.LOAN_STOCKEN_DATE IS NULL                     -- 【过滤】资产未转让
```

### 4.5 产品类型映射（SELECT中，非筛选条件）

`ACCT_TYP` 通过 CASE WHEN 映射为发文要求的产品类别码（F码），**不参与 WHERE 过滤**：

| 产品类别码 | 产品名称 | ACCT_TYP / 判断条件 |
|-----------|---------|-------------------|
| F0211 | — | ACCT_TYP LIKE '0101%' |
| F0212 | — | ACCT_TYP = '010301' |
| F02131 | — | ACCT_TYP IN ('010402','010403','010404') |
| F02132 | — | ACCT_TYP IN ('010401','010405','010499') |
| F0219 | — | ACCT_TYP IN ('010302','010399','019999') |

> **注**：源码中 CASE WHEN 还包含 0201%、0202、0401%、0801、05 等非01科目分支，但因 WHERE 已限定 `ACCT_TYP LIKE '01%'`，实际执行时仅命中上表列出的01开头科目。

## 5. 特殊处理规则

### 5.1 信用卡数据并入

除常规个人贷款外，另从 `PBOCD_DATACORE.JS_201_CLGRDK_XYK` 表并入信用卡数据，以固定内部机构号 `009803` 报送。

```sql
INSERT INTO PBOCD_JS_201_CLGRDK
SELECT ...
  FROM PBOCD_DATACORE.JS_201_CLGRDK_XYK T
 WHERE T.DATA_DATE = IS_DATE;
```

### 5.2 缩期处理

通过 MERGE INTO 处理到期日发生缩期的借据（JLBA202509240002_一阶段）：

| 场景 | 到期日 | 展期到期日/重定价日 | 贷款状态 |
|------|--------|-------------------|---------|
| 缩期（清单到期日 > L层到期日） | 取清单到期日 | 取原始到期日 | LS04 |
| 展期（清单到期日 < L层到期日 + 有展期） | 取L层到期日 | 取展期后到期日 | LS02 |
| 正常（无展期、无缩期） | 取L层到期日 | 空 | 逾期/正常 |

### 5.3 历史逻辑清理

- **JLBA202412270002**（2025-04-27）：剔除取上期/配置表逻辑，所有字段改为直接从TMP表取值
- **JLBA202509240002_一阶段**（2025-12-30）：剔除特殊处理SQL，改用MERGE INTO在主存储过程中统一实现缩期处理

## 6. 历史变更记录

| 编号 | 日期 | 修改人 | 提出人 | 原因 |
|------|------|--------|--------|------|
| JLBA202412270002 | 2025-04-27 | 周立鹏 | 李楠 | 剔除取上期/配置表 |

## 7. 涉及源码文件

| 角色 | 文件路径 |
|------|---------|
| 数据生成（主程序） | `源码/加工层存储/bsp_sp_js_201_clgrdk.prc` |
| 数据生成（解析版） | `源码解析/加工层存储/bsp_sp_js_201_clgrdk.prc` |

---

> **使用说明**：
> - 问"**要求报送什么**"→ 查**第一部分（发文原文要求）**
> - 问"**怎么取数/取了哪些业务/业务变更影响**"→ 查**第二部分（代码取数业务范围）**

*← [返回首页索引](../首页/index.md) · 原文：[JS_201_CLGRDK_存量个人贷款信息-原文.md](../参考资料/发文原文/JS_201_CLGRDK_存量个人贷款信息-原文.md)*