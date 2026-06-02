# 金融基础数据报送系统 — .prc 与实体文件映射

## 命名规则

.prc 文件：`bsp_sp_js_{批次}_{简称}.prc`
实体文件：`{报表名}_JS_{批次}_{接口表名}.md`

## 排除的 .prc 文件

| 模式 | 原因 |
|------|------|
| `*_his.prc` | 历史版本，与主程序逻辑重复 |
| `bsp_sp_js_spop.prc` | 辅助/调度程序，非报表数据生成 |
| `bsp_job_pbocd_table.prc` | 建表/DDL，非取数逻辑 |

## 无独立 .prc 的报表（缺口B）

### 五篇大文章（12个）
无独立 .prc，数据从以下6个子程序派生（通过 FLAG 字段过滤）：

| 子程序 .prc | 简称 | 推测对应报表 |
|-------------|------|-------------|
| bsp_sp_js_201_hdaszdkfs.prc | HDASZDKFS | 数字经济产业贷款（存量+发生额） |
| bsp_sp_js_201_hdalsdkfs.prc | HDALSDKFS | 绿色贷款（存量+发生额） |
| bsp_sp_js_201_hdakjdkfs.prc | HDAKJDKFS | 科技贷款（存量+发生额） |
| bsp_sp_js_201_hdaphdkfs.prc | HDAPHDKFS | 普惠贷款（存量+发生额） |
| bsp_sp_js_201_hdahldkfs.prc | HDAHLDKFS | 养老产业贷款（存量+发生额） |
| bsp_sp_js_201_hdayldkfs.prc | HDAYLDKFS | 待确认（可能为压力贷款或其他） |

> 注：4.1/4.2 科技贷款汇总报表的数据来自上述子程序 + 汇总 SQL

### JS_204 系列（4个）
源码解析目录中无对应 .prc：
- 股权投资发生额信息_JS_204_GQTZFS
- 存量股权投资信息_JS_204_CLGQTZ
- 特定目的载体投资发生额信息_JS_204_SPVFSX
- 存量特定目的载体投资信息_JS_204_SPVTZX

### JS_101 法人系列（3个）
源码解析目录中无对应 .prc（可能数据来自其他系统）：
- 金融机构（法人）资产负债及风险统计表_JS_101_JGFRZF
- 金融机构（法人）利润及资本统计表_JS_101_JGFRLR
- 金融机构（法人）基本情况统计表_JS_101_JGFRJB

### 其他（7个）
- 个人存款发生额信息_JS_202_GRCKFS
- 债券发行发生额信息_JS_203_ZQFXFS
- 存量专项贷款一批报文信息_JS_201_CLZXYP
- 存量专项贷款二批报文信息_JS_201_CLZXEP
- 存量收购处置信息_JS_201_CLSGCZ
- 存量收购重组信息_JS_201_CLCZXX
- 收购重组发生额信息_JS_201_CZXXFS

## 已解析但无匹配实体文件的 .prc（缺口A，共14个）

| .prc 文件 | 回退名称 | 说明 |
|-----------|---------|------|
| bsp_sp_js_201_hdaszdkfs.prc | JS_201_HDASZDKFS | 五篇大文章子程序 |
| bsp_sp_js_201_hdalsdkfs.prc | JS_201_HDALSDKFS | 五篇大文章子程序 |
| bsp_sp_js_201_hdakjdkfs.prc | JS_201_HDAKJDKFS | 五篇大文章子程序 |
| bsp_sp_js_201_hdaphdkfs.prc | JS_201_HDAPHDKFS | 五篇大文章子程序 |
| bsp_sp_js_201_hdahldkfs.prc | JS_201_HDAHLDKFS | 五篇大文章子程序 |
| bsp_sp_js_201_hdayldkfs.prc | JS_201_HDAYLDKFS | 五篇大文章子程序 |
| bsp_sp_js_201_hdaclhldk.prc | JS_201_HDACLHLDK | 存量核对-核对类 |
| bsp_sp_js_201_hdaclkjdk.prc | JS_201_HDACLKJDK | 存量核对-科技贷 |
| bsp_sp_js_201_hdacllsdk.prc | JS_201_HDACLLSDK | 存量核对-绿色贷 |
| bsp_sp_js_201_hdaclphdk.prc | JS_201_HDACLPHDK | 存量核对-普惠贷 |
| bsp_sp_js_201_hdaclszdk.prc | JS_201_HDACLSZDK | 存量核对-数字贷 |
| bsp_sp_js_201_hdaclyldk.prc | JS_201_HDACLYLDK | 存量核对-养老贷 |
| bsp_sp_js_102_ftykhx_tscl.prc | JS_102_FTYKHX_TSCL | 非同业客户特殊处理 |
| bsp_sp_js_102_tykhxx_all.prc | JS_102_TYKHXX_ALL | 同业客户全量版本 |
| bsp_sp_js_203_clzqtz.prc | JS_203_CLZQTZ | 存量债券投资（实体文件名可能不同） |
