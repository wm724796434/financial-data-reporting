CREATE OR REPLACE PROCEDURE BSP_SP_JS_102_XDQYXX (IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_102_XDQYXX
  -- 业务域: 客户信息类
  -- 用途: 生成接口表 JS_102_XDQYXX 信贷企业基础信息表
  -- 参数
  --    IS_DATE 输入，传入跑批日期
  --    OI_RETCODE 输出，用来标识存储过程执行过程中是否出现异常
  -- 引用的监管集市表
  --    SMTMODS.L_CUST_ALL                                 — 全量客户信息表
  --    SMTMODS.L_CUST_C_FINREPINFO                        — 贷款客户财务报表资料
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0;           --数值型  异常代码
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32)  DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32)  DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(100);              --存储过程执行步骤标志
  NUM               INTEGER;
  VS_NMONTH         VARCHAR2(10);
  VS_ORDERDATE      VARCHAR2(10);
  VS_YEARDATE       VARCHAR2(10);
  

BEGIN
  VS_TEXT   := TO_CHAR(TRUNC(TO_DATE(IS_DATE,'YYYYMMDD'),'YYYY')-1,'YYYY-MM-DD'); -- 上年末 YYYY-MM-DD 格式
  VS_YEARDATE := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE,'YYYYMMDD'),-12),'YYYY'); -- 上一年 yyyy
  VS_NMONTH := TO_CHAR(TRUNC(TO_DATE(IS_DATE,'YYYYMMDD'),'YYYY')-1,'YYYYMMDD'); -- 上年末 YYYYMMDD 格式
  VS_ORDERDATE :=TO_CHAR(TRUNC(TO_DATE(IS_DATE,'YYYYMMDD'),'YYYY'),'YYYYMMDD'); -- 本年初
  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'JS_102_XDQYXX';
  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------


  --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'PBOCD_JS_102_XDQYXX'
     AND PARTITION_NAME = 'P' || VS_NMONTH;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_102_XDQYXX ADD PARTITION P'||
                       VS_NMONTH || ' VALUES LESS THAN(' || VS_ORDERDATE || ')';
  END IF;

    EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_102_XDQYXX TRUNCATE PARTITION P'||
                       VS_NMONTH;
  --------------------------------------------------------------------------------add   by   BAIYANG  20251127  上线开始-----------------------------------------------------------
VS_STEP := '0.开始插入目标表';
  --
  INSERT INTO PBOCD_JS_102_XDQYXX(
      DATA_DATE,      --1 数据日期
      ORG_CODE,       --2 金融机构代码
      CUST_ID_TYPE,   --3 客户证件类型
      CUST_ID_NO,     --4 客户证件代码
      STATEMT_VERSION,--5 客户会计报表版本
      STATEMT_TYPE,   --6 客户会计报表类型
      BANK_CASH,      --7 货币资金
      NOTES_ACCT_REC, --8 应收票据及应收账款
      INVENTORY,      --9 存货
      TOTAL_CURR_A,   --10 流动资产合计
      FIXED_ASSETS,   --11 固定资产
      CONSTRUCT_IPROGRESS, --12 在建工程
      TOTAL_NONCURR_A,     --13 非流动资产合计
      TOTAL_ASSET,         --14 资产总计
      SHORT_TERM_LOANS,    --15 短期借款
      NOTES_ACCT_PAY,      --16 应付票据及应付账款
      TOTAL_CURR_L,        --17 流动负债合计
      LONG_TERM_LOANS,     --18 长期借款
      TOTAL_NONCURR_L,     --19 非流动负债合计
      TOTAL_LIABILITY,     --20 负债总计
      TOTAL_EQUITY,        --21所有者权益合计
      REVENUE_SALES,       --22 营业收入
      OPERAT_EXPENSE,      --23 营业成本
      BUSINESS_OTHER_TAX,  --24 营业税金及附加
      SELLING_EXPENSE,     --25 销售（营业）费用
      G_A_EXPENSE,         --26 管理费用
      FINANCE_EXPENSE,     --27 财务费用
      OPERAT_PROFIT,       --28 营业利润
      PROFIT_BEFORE_TAX,   --29 利润总额
      INCOME_TAX,          --30 所得税
      NET_PROFIT,          --31 净利润
      ORG_NUM,             --32 内部机构号
      REPORT_ID,           --33 数据id
      CJRQ,                --34 采集日期
      NBJGH,               --35 内部机构号
      BIZ_LINE_ID,         --36 条线
      VERIFY_STATUS,       --37 校验状态
      BSCJRQ,              --38 报送采集日期
      FRNBJGH,             --39 法人内部机构号
      CUST_NAME            --40 客户名称
  )
  SELECT /*+parallel(4)*/
       VS_TEXT     AS DATA_DATE, --1 数据日期  → DATA_DATE 数据日期（上年末YYYY-MM-DD格式，取自IS_DATE上年末截断）
       CASE WHEN A.ORG_NUM LIKE '51%' THEN '912202016601010854'
            WHEN A.ORG_NUM LIKE '52%' THEN '91321000564261222Q'
            WHEN A.ORG_NUM LIKE '53%' THEN '91220201584622304Y'
            WHEN A.ORG_NUM LIKE '54%' THEN '91220101586213344F'
            WHEN A.ORG_NUM LIKE '55%' THEN '911309005881693407'
            WHEN A.ORG_NUM LIKE '56%' THEN '91131000589668889D'
            WHEN A.ORG_NUM LIKE '57%' THEN '91222404584629733N'
            WHEN A.ORG_NUM LIKE '58%' THEN '912203005846084148'
            WHEN A.ORG_NUM LIKE '59%' THEN '91220421660100250Y'
            WHEN A.ORG_NUM LIKE '60%' THEN '912202015846358186'
       ELSE '9122010170255776XN' END AS ORG_CODE,  --2 金融机构代码  → ORG_CODE 机构统一社会信用代码（按A.ORG_NUM前两位映射各分行）
       DECODE(B.ID_TYPE, '236', 'A01', '21', 'A02', 'A03') AS CUST_ID_TYPE,   --3 客户证件类型  → CUST_ID_TYPE（L_CUST_ALL.ID_TYPE编码映射：236→A01统一社会信用代码, 21→A02组织机构代码, 其余→A03其他）
       B.ID_NO       AS CUST_ID_NO,      --4 客户证件代码  → CUST_ID_NO（L_CUST_ALL.ID_NO直接映射）
       '2'           AS STATEMT_VERSION, --5 客户会计报表版本  → STATEMT_VERSION 固定值'2'（2007版会计报表）
       DECODE(REPORT_SUB_TYP, '9', '1', REPORT_SUB_TYP)    AS STATEMT_TYPE, --6 客户会计报表类型  → STATEMT_TYPE（L_CUST_C_FINREPINFO.REPORT_SUB_TYP映射：'9'→'1'本部报表, 其余原值）
       SUM(DECODE(A.ID_CODE, '9100', A.ID_VAL, 0))         AS BANK_CASH,    --7 货币资金  → BANK_CASH（L_CUST_C_FINREPINFO指标ID_CODE=9100）
       SUM(DECODE(A.ID_CODE, '9102', A.ID_VAL, '9103', A.ID_VAL, 0)) AS NOTES_ACCT_REC, --8 应收票据及应收账款  → NOTES_ACCT_REC（L_CUST_C_FINREPINFO指标ID_CODE=9102+9103）
       SUM(DECODE(A.ID_CODE, '9108', A.ID_VAL, 0)) AS INVENTORY,           --9 存货  → INVENTORY（L_CUST_C_FINREPINFO指标ID_CODE=9108）
       SUM(DECODE(A.ID_CODE, '9111', A.ID_VAL, 0)) AS TOTAL_CURR_A,        --10 流动资产合计  → TOTAL_CURR_A（L_CUST_C_FINREPINFO指标ID_CODE=9111）
       SUM(DECODE(A.ID_CODE, '9117', A.ID_VAL, 0)) AS FIXED_ASSETS,        --11 固定资产  → FIXED_ASSETS（L_CUST_C_FINREPINFO指标ID_CODE=9117）
       SUM(DECODE(A.ID_CODE, '9118', A.ID_VAL, 0)) AS CONSTRUCT_IPROGRESS, --12 在建工程  → CONSTRUCT_IPROGRESS（L_CUST_C_FINREPINFO指标ID_CODE=9118）
       SUM(DECODE(A.ID_CODE, '9129', A.ID_VAL, 0)) AS TOTAL_NONCURR_A,     --13 非流动资产合计  → TOTAL_NONCURR_A（L_CUST_C_FINREPINFO指标ID_CODE=9129）
       SUM(DECODE(A.ID_CODE, '9130', A.ID_VAL, 0)) AS TOTAL_ASSET,         --14 资产总计  → TOTAL_ASSET（L_CUST_C_FINREPINFO指标ID_CODE=9130）
       SUM(DECODE(A.ID_CODE, '9131', A.ID_VAL, 0)) AS SHORT_TERM_LOANS,    --15 短期借款  → SHORT_TERM_LOANS（L_CUST_C_FINREPINFO指标ID_CODE=9131）
       SUM(DECODE(A.ID_CODE, '9133', A.ID_VAL, '9134', A.ID_VAL, 0)) AS NOTES_ACCT_PAY,  --16 应付票据及应付账款  → NOTES_ACCT_PAY（L_CUST_C_FINREPINFO指标ID_CODE=9133+9134）
       SUM(DECODE(A.ID_CODE, '9143', A.ID_VAL, 0)) AS TOTAL_CURR_L,        --17 流动负债合计  → TOTAL_CURR_L（L_CUST_C_FINREPINFO指标ID_CODE=9143）
       SUM(DECODE(A.ID_CODE, '9144', A.ID_VAL, 0)) AS LONG_TERM_LOANS,     --18 长期借款  → LONG_TERM_LOANS（L_CUST_C_FINREPINFO指标ID_CODE=9144）
       SUM(DECODE(A.ID_CODE, '9151', A.ID_VAL, 0)) AS TOTAL_NONCURR_L,     --19 非流动负债合计  → TOTAL_NONCURR_L（L_CUST_C_FINREPINFO指标ID_CODE=9151）
       SUM(DECODE(A.ID_CODE, '9152', A.ID_VAL, 0)) AS TOTAL_LIABILITY,     --20 负债总计  → TOTAL_LIABILITY（L_CUST_C_FINREPINFO指标ID_CODE=9152）
       SUM(DECODE(A.ID_CODE, '9158', A.ID_VAL, 0)) AS TOTAL_EQUITY,        --21 所有者权益合计  → TOTAL_EQUITY（L_CUST_C_FINREPINFO指标ID_CODE=9158）
       SUM(DECODE(A.ID_CODE, '9170', A.ID_VAL, 0)) AS REVENUE_SALES,       --22 营业收入  → REVENUE_SALES（L_CUST_C_FINREPINFO指标ID_CODE=9170）
       SUM(DECODE(A.ID_CODE, '9171', A.ID_VAL, 0)) AS OPERAT_EXPENSE,      --23 营业成本  → OPERAT_EXPENSE（L_CUST_C_FINREPINFO指标ID_CODE=9171）
       SUM(DECODE(A.ID_CODE, '9172', A.ID_VAL, 0)) AS BUSINESS_OTHER_TAX,  --24 营业税金及附加  → BUSINESS_OTHER_TAX（L_CUST_C_FINREPINFO指标ID_CODE=9172）
       SUM(DECODE(A.ID_CODE, '9173', A.ID_VAL, 0)) AS SELLING_EXPENSE,     --25 销售（营业）费用  → SELLING_EXPENSE（L_CUST_C_FINREPINFO指标ID_CODE=9173）
       SUM(DECODE(A.ID_CODE, '9174', A.ID_VAL, 0)) AS G_A_EXPENSE,         --26 管理费用  → G_A_EXPENSE（L_CUST_C_FINREPINFO指标ID_CODE=9174）
       SUM(DECODE(A.ID_CODE, '9175', A.ID_VAL, 0)) AS FINANCE_EXPENSE,     --27 财务费用  → FINANCE_EXPENSE（L_CUST_C_FINREPINFO指标ID_CODE=9175）
       SUM(DECODE(A.ID_CODE, '9180', A.ID_VAL, 0)) AS OPERAT_PROFIT,       --28 营业利润  → OPERAT_PROFIT（L_CUST_C_FINREPINFO指标ID_CODE=9180）
       SUM(DECODE(A.ID_CODE, '9184', A.ID_VAL, 0)) AS PROFIT_BEFORE_TAX,   --29 利润总额  → PROFIT_BEFORE_TAX（L_CUST_C_FINREPINFO指标ID_CODE=9184）
       SUM(DECODE(A.ID_CODE, '9185', A.ID_VAL, 0)) AS INCOME_TAX,          --30 所得税  → INCOME_TAX（L_CUST_C_FINREPINFO指标ID_CODE=9185）
       SUM(DECODE(A.ID_CODE, '9186', A.ID_VAL, 0)) AS NET_PROFIT,          --31 净利润  → NET_PROFIT（L_CUST_C_FINREPINFO指标ID_CODE=9186）
       A.ORG_NUM  AS ORG_NUM,      --32 内部机构号  → ORG_NUM（L_CUST_C_FINREPINFO.ORG_NUM直接映射）
       SYS_GUID() AS REPORT_ID,    --33 数据id  → REPORT_ID 系统生成GUID
       VS_NMONTH  AS CJRQ,         --34 采集日期  → CJRQ 上年末YYYYMMDD格式
       A.ORG_NUM  AS NBJGH,        --35 内部机构号  → NBJGH（L_CUST_C_FINREPINFO.ORG_NUM直接映射）
       '99'       AS BIZ_LINE_ID,  --36 条线  → BIZ_LINE_ID 固定值'99'
       ''         AS VERIFY_STATUS,--37 校验状态  → VERIFY_STATUS 空值
       ''         AS BSCJRQ,       --38 报送采集日期  → BSCJRQ 空值
       CASE
           WHEN A.ORG_NUM LIKE '51%' THEN
           '510000'
           WHEN A.ORG_NUM LIKE '52%' THEN
            '520000'
           WHEN A.ORG_NUM LIKE '53%' THEN
            '530000'
           WHEN A.ORG_NUM LIKE '54%' THEN
            '540000'
           WHEN A.ORG_NUM LIKE '55%' THEN
            '550000'
           WHEN A.ORG_NUM LIKE '56%' THEN
            '560000'
           WHEN A.ORG_NUM LIKE '57%' THEN
            '570000'
           WHEN A.ORG_NUM LIKE '58%' THEN
            '580000'
           WHEN A.ORG_NUM LIKE '59%' THEN
            '590000'
           WHEN A.ORG_NUM LIKE '60%' THEN
            '600000'
           ELSE '990000'
       END AS FRNBJGH,      --39 法人内部机构号  → FRNBJGH（按A.ORG_NUM前两位映射法人机构行政区划代码）
       B.CUST_NAM AS CUST_NAME     --40 客户名称  → CUST_NAME（L_CUST_ALL.CUST_NAM直接映射）
  FROM (SELECT A.*,
               ROW_NUMBER() OVER(PARTITION BY A.CUST_ID, A.ID_CODE, A.REPORT_SUB_TYP ORDER BY A.REPORT_TYP DESC, REPORT_KIND ASC) RN
          FROM SMTMODS.L_CUST_C_FINREPINFO A --贷款客户财务报表资料
         WHERE A.DATA_DATE = IS_DATE
           AND A.REPORT_YEAR = VS_YEARDATE --取上年数据，但第四季度的数据需要六月30日后才有
           AND (A.REPORT_TYP = '70' --第四季度
               OR A.REPORT_TYP = '10' --年报
               OR A.REPORT_TYP = '30' --下半年
               )
           AND A.ID_VAL/*指标值*/ <> 0           --指标值
           AND A.REPORT_KIND/*报表种类*/ IN ('4','5') --4-资产负债表（2007） 5-利润及利润分配表（2007）
        ) A

 INNER JOIN (SELECT CUST_ID, ID_TYPE, ID_NO, CUST_NAM
               FROM SMTMODS.L_CUST_ALL B --全量客户信息表
              WHERE B.DATA_DATE = IS_DATE) B
    ON A.CUST_ID = B.CUST_ID
 WHERE A.RN = 1
 GROUP BY A.ORG_NUM,B.ID_TYPE, B.ID_NO, REPORT_SUB_TYP, B.CUST_NAM
 ;
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  COMMIT;

  -------------------------------------------------------------------------
  OI_RETCODE := 0; --设置异常状态为0 成功状态
  OI_RETCODE_DEC :='执行成功';

  /*COMMIT; --非特殊处理只能在最后一次提交*/
  -- 结束日志
  VS_STEP := 'END';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
EXCEPTION
  WHEN OTHERS THEN
    --如果出现异常
    VI_ERRORCODE := SQLCODE; --设置异常代码
    VS_TEXT      := VS_STEP || '|' || IS_DATE || '|' ||
                    SUBSTR(SQLERRM, 1, 200); --设置异常描述
    ROLLBACK; --数据回滚
    OI_RETCODE := -1; --设置异常状态为-1
    OI_RETCODE_DEC :=SQLCODE||':'||SUBSTR(SQLERRM,1,50);--系统错误描述
    --插入日志表，记录错误
    SP_PBOCD_LOG(VS_PROCEDURE_NAME, 'ERROR', VI_ERRORCODE, VS_TEXT, IS_DATE);
END;
