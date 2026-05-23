CREATE OR REPLACE PROCEDURE BSP_SP_JS_201_TYJDFS (IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  --    SP_JS_201_TYJDFS
  -- 用途:生成接口表 JS_201_TYJDFS 同业借贷发生额信息
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    CAEATE BY USER AT 20230421
  --    需求编号：JLBA202503120002_关于金融市场部金融基础数据报送逻辑变更的需求 上线日期：2025-04-29，修改人：周立鹏，提出人：徐晖   
  --              修改原因：新增发起机构名称债券回购部分取数逻辑、修改产品类别债券回购部分取数逻辑
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(100); --存储过程执行步骤标志
  NUM               INTEGER;
  VS_NMONTH         VARCHAR2(10);
  VS_LAST_TEXT      VARCHAR2(8);

BEGIN
  VS_TEXT := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  VS_NMONTH := TO_CHAR(TRUNC(TO_DATE(IS_DATE,'YYYYMMDD') + 1),'YYYYMMDD');
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');
  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_201_TYJDFS';
  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------


  --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'PBOCD_JS_201_TYJDFS'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_201_TYJDFS ADD PARTITION P'||
                      IS_DATE || ' VALUES LESS THAN(' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_201_TYJDFS TRUNCATE PARTITION P'||
                    IS_DATE;

  VS_STEP := '1.插入F03-拆放同业/同业拆借的外币009801';
  --
  EXECUTE IMMEDIATE 'TRUNCATE TABLE PBOCD_JS_201_TYJDFS_TMP';

INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_TYJDFS_TMP
  SELECT 1 AS ID, T.*
    FROM PBOCD_JS_201_CLTYJD T
   WHERE T.CJRQ = IS_DATE
     AND NOT EXISTS (SELECT 1
            FROM PBOCD_JS_201_CLTYJD_SQ F
           WHERE F.CJRQ = VS_LAST_TEXT
             AND T.CONTRACT_CODE = F.CONTRACT_CODE
             AND F.CURR_CODE <> 'CNY')
     AND T.CURR_CODE <> 'CNY'
  UNION
  SELECT 0, T.*
    FROM PBOCD_JS_201_CLTYJD_SQ T
   WHERE T.CJRQ = VS_LAST_TEXT
     AND NOT EXISTS (SELECT 1
            FROM PBOCD_JS_201_CLTYJD F
           WHERE F.CJRQ = IS_DATE
             AND T.CONTRACT_CODE = F.CONTRACT_CODE
             AND F.CURR_CODE <> 'CNY')
     AND T.CURR_CODE <> 'CNY';
  COMMIT;

INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_TYJDFS(
         DATA_DATE,                --数据日期
         ORG_CODE,                 --金融机构代码
         ORG_NUM,                  --内部机构号
         CONT_PARTY_CODE,          --交易对手代码
         CONTRACT_CODE,            --合同编码
         AL_TYPE,                  --资产负债类型
         PRODUCT_TYPE,             --产品类别
         CON_BGN_DATE,             --合同起始日期
         CON_DUE_DATE,             --合同到期日期
         CURR_CODE,                --币种
         TRANS_AMT,                  --合同余额
         TRANS_AMT_RMB,              --合同余额折人民币
         INT_RATE_TYPE,            --利率是否固定
         INT_RATE,                 --利率水平
         PRI_BENCH_MARK,           --定价基准类型
         INT_METH,                 --计息方式
         TRANS_TYPE,               --发生/结清标识
         REPORT_ID,                --报表ID(SYS_GUID())
         CJRQ,                     --数据日期
         NBJGH,                    --内部机构号
         BIZ_LINE_ID,              --业务条线
         VERIFY_STATUS,            --校验状态
         BSCJRQ,                   --报送期
         CONT_PARTY_TYPE,          --交易对手代码类别
         SERIAL_NO,                 --交易流水号
         CON_ACTUAL_DUE_DATE,      --合同实际终止日期
         BASE_INT_RAT,             --基准利率
         FRNBJGH,                  --法人内部机构号
         CUST_ID,                  --客户号
         CUST_NAME,                --客户名
         CUST_NAME_SOURCE,         --原客户名称
         CONT_PARTY_CODE_SOURCE    --原交易对手代码
  )
  SELECT VS_TEXT --数据日期
        ,
         ORG_CODE --金融机构代码
        ,
         ORG_NUM --内部机构号
        ,
         CONT_PARTY_CODE --交易对手代码
        ,
         CONTRACT_CODE --合同编码
        ,
         AL_TYPE --资产负债类型
        ,
         PRODUCT_TYPE --产品类别
        ,
         CON_BGN_DATE --合同起始日期
        ,
         CON_DUE_DATE --合同到期日期
        ,
         CURR_CODE --币种
        ,
         BALANCE --合同余额
        ,
         BALANCE_RMB --合同余额折人民币
        ,
         INT_RATE_TYPE --利率是否固定
        ,
         INT_RATE --利率水平
        ,
         PRI_BENCH_MARK --定价基准类型
        ,
         INT_METH --计息方式
        ,
         ID --发生/结清标识
        ,
         SYS_GUID(),
         IS_DATE,
         NBJGH,
         '99',
         '',
         '',
         CONT_PARTY_TYPE --交易对手代码类别
        ,
         SYS_GUID() --交易流水号
        ,
         '' --合同实际终止日期
        ,
         '' --基准利率
        ,
         FRNBJGH --法人内部机构号
        ,
         '' --客户号
        ,
         '' --上报客户名称
        ,
         '' --原客户名称
        ,
         '' --原交易对手代码
    FROM PBOCD_DATACORE.PBOCD_JS_201_TYJDFS_TMP;
  COMMIT;

------------------------------------------------------------add   by   zy  20240523   上线开始-----------------------------------
VS_STEP := '1.插入F03-拆放同业/同业拆借';
  --之前取外币本期上期轧差，改成取本外币F03-拆放同业/同业拆借，上线的时候删掉临时表PBOCD_JS_201_TYJDFS_TMP
  --
  INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_TYJDFS(
         DATA_DATE,                --数据日期
         ORG_CODE,                 --金融机构代码
         ORG_NUM,                  --内部机构号
         CONT_PARTY_CODE,          --交易对手代码
         CONTRACT_CODE,            --合同编码
         AL_TYPE,                  --资产负债类型
         PRODUCT_TYPE,             --产品类别
         CON_BGN_DATE,             --合同起始日期
         CON_DUE_DATE,             --合同到期日期
         CURR_CODE,                --币种
         TRANS_AMT,                  --合同余额
         TRANS_AMT_RMB,              --合同余额折人民币
         INT_RATE_TYPE,            --利率是否固定
         INT_RATE,                 --利率水平
         PRI_BENCH_MARK,           --定价基准类型
         INT_METH,                 --计息方式
         TRANS_TYPE,               --发生/结清标识
         REPORT_ID,                --报表ID(SYS_GUID())
         CJRQ,                     --数据日期
         NBJGH,                    --内部机构号
         BIZ_LINE_ID,              --业务条线
         VERIFY_STATUS,            --校验状态
         BSCJRQ,                   --报送期
         CONT_PARTY_TYPE,          --交易对手代码类别
         SERIAL_NO,                 --交易流水号
         CON_ACTUAL_DUE_DATE,      --合同实际终止日期
         BASE_INT_RAT,             --基准利率
         FRNBJGH,                  --法人内部机构号
         CUST_ID,                  --客户号
         CUST_NAME,                --客户名
         CUST_NAME_SOURCE,         --原客户名称
         CONT_PARTY_CODE_SOURCE    --原交易对手代码
  )
SELECT /*+PARALLEL(4)*/
         VS_TEXT DATA_DATE, --数据日期
         NVL(OB.ID_NO,OB.UP_ID_NO) AS ORG_CODE  , --金融机构代码
         T1.ORG_NUM, --内部机构号
         CASE WHEN BB.TYSHXYDM IS NOT NULL THEN BB.TYSHXYDM
              WHEN BB.ORGANIZATIONCODE IS NOT NULL THEN REPLACE(BB.ORGANIZATIONCODE ,'-','')
         ELSE BB.ID_NO END AS CONT_PARTY_CODE, --交易对手代码
         T1.CJDBH AS CONTRACT_CODE, --合同编码
         CASE WHEN SUBSTR(T1.ACCT_TYP,1,3) IN ('202','205') THEN 'AL02' ELSE 'AL01' END AS AL_TYPE, --资产负债类型
         'F03' AS PRODUCT_TYPE, --产品类别 票据买入返售/卖出回购
         TO_CHAR(T1.START_DATE, 'yyyy-mm-dd') AS CON_BGN_DATE, --合同起始日期
         TO_CHAR(T1.MATURE_DATE, 'yyyy-mm-dd') AS CON_DUE_DATE, --合同到期日期
         T1.CURR_CD  CURR_CODE , --币种
         SUM(T.AMOUNT) TRANS_AMT , --合同余额
         SUM(T.AMOUNT * C.CCY_RATE) TRANS_AMT_RMB , --合同余额折人民币
         'RF01' INT_RATE_TYPE, --利率是否固定
         T1.REAL_INT_RAT  AS INT_RATE, --利率水平
         CASE WHEN  T1.ORG_NUM ='009804' THEN  'TR01' ELSE NVL(T1.PRICING_BASE_TYPE,'TR99')  END   PRI_BENCH_MARK, --定价基准类型
            CASE WHEN  T1.ACC_INT_TYPE ='1'  THEN 'B01'
           WHEN T1.ACC_INT_TYPE ='2'  THEN 'B02'
           WHEN  T1.ACC_INT_TYPE ='3'  THEN 'B03'
           WHEN   T1.ACC_INT_TYPE ='4'  THEN 'B04'
           WHEN   T1.ACC_INT_TYPE ='5'  THEN 'B05'
              WHEN   T1.ACC_INT_TYPE ='99'  THEN 'B99'
           ELSE  NVL(T1.ACC_INT_TYPE,'B99')  END INT_METH, --计息方式
         T.TRADE_DIRECT  TRANS_TYPE , --发生/结清标识
         SYS_GUID() REPORT_ID,
         IS_DATE AS CJRQ,
         T1.ORG_NUM AS NBJGH,
         CASE  WHEN  T1.ORG_NUM='009820'  THEN 'TY'
         WHEN   T1.ORG_NUM='009804'    THEN 'SC' 
           ELSE '99'  END  BIZ_LINE_ID  , ---业务条线
         '' VERIFY_STATUS,
         '' BSCJRQ,
         CASE WHEN BB.TYSHXYDM IS NOT NULL THEN 'A01'
              WHEN BB.ORGANIZATIONCODE IS NOT NULL THEN 'A02'
              WHEN BB.ID_NO IS NOT NULL THEN 'A03' END AS CONT_PARTY_TYPE, --交易对手代码类别
         T1.REF_NUM || T.TRADE_DIRECT as SERIAL_NO , --交易流水号
         CASE WHEN T.TRADE_DIRECT = '0' THEN TO_CHAR(T1.MATURE_DATE, 'YYYY-MM-DD') END    CON_ACTUAL_DUE_DATE ,      --合同实际终止日期
         ''  AS BASE_INT_RAT,--基准利率 --利率类型为固定利率的，基准利率必须为空
         '990000' AS FRNBJGH,
         CASE WHEN T1.ORG_NUM='009804' THEN '' ELSE  ( CASE WHEN BB.TYSHXYDM IS NOT NULL THEN BB.TYSHXYDM
              WHEN BB.ORGANIZATIONCODE IS NOT NULL THEN  REPLACE(BB.ORGANIZATIONCODE ,'-','')
         ELSE BB.ID_NO END ) END CUST_ID , --客户号
         AA.CUST_NAM AS CUST_NAME, --上报客户名称
         CASE WHEN T1.ORG_NUM in('009804','009801') THEN '' ELSE  AA.CUST_NAM  END    AS  CUST_NAME_SOURCE , --原客户名称
         CASE WHEN  T1.ORG_NUM in('009804','009801') THEN '' ELSE 
         (CASE WHEN BB.TYSHXYDM IS NOT NULL THEN BB.TYSHXYDM
              WHEN BB.ORGANIZATIONCODE IS NOT NULL THEN  REPLACE(BB.ORGANIZATIONCODE ,'-','')
         ELSE BB.ID_NO END) END  AS CONT_PARTY_CODE_SOURCE --原交易对手代码
FROM ( SELECT  DISTINCT REF_NUM , TRADE_DIRECT   ,CONTRACT_NUM, AMOUNT   
FROM   SMTMODS.L_TRAN_FUND_FX   ---上线后是增量数据，取全月的数据
WHERE  SUBSTR(DATA_DATE,1,6) = SUBSTR(IS_DATE,1,6) AND AMOUNT IS NOT NULL   AND REF_NUM  NOT  LIKE 'W%') T  ----W表示：康星同业借款提前还款，只有009820有这种情况
INNER JOIN 
( SELECT  * FROM  
SMTMODS.L_ACCT_FUND_MMFUND T1 
WHERE T1.DATA_DATE=IS_DATE 
---AND T1.GL_ITEM_CODE  IN('20030101','20030102','13020104','13020102') 
AND SUBSTR(T1.ACCT_TYP, 1, 3) IN('202', '205','105','102')  )T1 
ON  T.CONTRACT_NUM=T1.ACCT_NUM
LEFT JOIN SMTMODS.L_PUBL_RATE C
      ON C.DATA_DATE = IS_DATE
     AND C.BASIC_CCY = T1.CURR_CD
     AND C.FORWARD_CCY = 'CNY'
LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=T1.ORG_NUM AND OB.DATA_DATE=IS_DATE
LEFT JOIN SMTMODS.L_CUST_ALL AA
      ON T1.CUST_ID = AA.CUST_ID
     AND AA.DATA_DATE = IS_DATE
LEFT JOIN SMTMODS.L_CUST_C BB
    ON AA.CUST_ID = BB.CUST_ID AND BB.DATA_DATE = IS_DATE
 where   T1.ORG_NUM <> '009801' 
GROUP  BY  NVL(OB.ID_NO,OB.UP_ID_NO), --金融机构代码
         T1.ORG_NUM, --内部机构号
         CASE WHEN BB.TYSHXYDM IS NOT NULL THEN BB.TYSHXYDM
              WHEN BB.ORGANIZATIONCODE IS NOT NULL THEN REPLACE(BB.ORGANIZATIONCODE ,'-','')
         ELSE BB.ID_NO END , --交易对手代码
         T1.CJDBH , --合同编码
         CASE WHEN SUBSTR(T1.ACCT_TYP,1,3) IN ('202','205') THEN 'AL02' ELSE 'AL01' END , --资产负债类型
         TO_CHAR(T1.START_DATE, 'yyyy-mm-dd'), --合同起始日期
         TO_CHAR(T1.MATURE_DATE, 'yyyy-mm-dd') , --合同到期日期
         T1.CURR_CD, --币种
         T1.REAL_INT_RAT , --利率水平
         CASE WHEN  T1.ORG_NUM ='009804' THEN  'TR01' ELSE NVL(T1.PRICING_BASE_TYPE,'TR99')  END  , --定价基准类型
          CASE WHEN  T1.ACC_INT_TYPE ='1'  THEN 'B01'
           WHEN T1.ACC_INT_TYPE ='2'  THEN 'B02'
           WHEN  T1.ACC_INT_TYPE ='3'  THEN 'B03'
           WHEN   T1.ACC_INT_TYPE ='4'  THEN 'B04'
           WHEN   T1.ACC_INT_TYPE ='5'  THEN 'B05'
              WHEN   T1.ACC_INT_TYPE ='99'  THEN 'B99'
           ELSE  NVL(T1.ACC_INT_TYPE,'B99')  END , --计息方式
         T.TRADE_DIRECT, --发生/结清标识
         T1.ORG_NUM ,
         CASE  WHEN  T1.ORG_NUM='009820'  THEN 'TY'
         WHEN   T1.ORG_NUM='009804'    THEN 'SC'  ELSE '99'   END,
         CASE WHEN BB.TYSHXYDM IS NOT NULL THEN 'A01'
              WHEN BB.ORGANIZATIONCODE IS NOT NULL THEN 'A02'
              WHEN BB.ID_NO IS NOT NULL THEN 'A03' END , --交易对手代码类别
         T1.REF_NUM || T.TRADE_DIRECT, --交易流水号
         CASE WHEN T.TRADE_DIRECT = '0' THEN TO_CHAR(T1.MATURE_DATE, 'YYYY-MM-DD') END,      --合同实际终止日期
          CASE WHEN T1.ORG_NUM='009804' THEN '' ELSE  T1.CUST_ID  END , --客户号
         AA.CUST_NAM,
         CASE WHEN T1.ORG_NUM='009804' THEN '' ELSE  AA.CUST_NAM  END,
         CASE WHEN  T1.ORG_NUM='009804' THEN '' ELSE 
         (CASE WHEN BB.TYSHXYDM IS NOT NULL THEN BB.TYSHXYDM
              WHEN BB.ORGANIZATIONCODE IS NOT NULL THEN  REPLACE(BB.ORGANIZATIONCODE ,'-','')
         ELSE BB.ID_NO END) END;
    COMMIT;
------------------------------------------------------------add   by   zy  20240523   上线结束------------------------------------

------add by  zy  20240829 start 
VS_STEP := '2.插入F061-债券买入返售/卖出回购';
  --
  INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_TYJDFS(
         DATA_DATE,                --数据日期
         ORG_CODE,                 --金融机构代码
         ORG_NUM,                  --内部机构号
         CONT_PARTY_CODE,          --交易对手代码
         CONTRACT_CODE,            --合同编码
         AL_TYPE,                  --资产负债类型
         PRODUCT_TYPE,             --产品类别
         CON_BGN_DATE,             --合同起始日期
         CON_DUE_DATE,             --合同到期日期
         CURR_CODE,                --币种
         TRANS_AMT,                  --发生金额
         TRANS_AMT_RMB,              --发生金额折人民币
         INT_RATE_TYPE,            --利率是否固定
         INT_RATE,                 --利率水平
         PRI_BENCH_MARK,           --定价基准类型
         INT_METH,                 --计息方式
         TRANS_TYPE,               --发生/结清标识
         REPORT_ID,                --报表ID(SYS_GUID())
         CJRQ,                     --数据日期
         NBJGH,                    --内部机构号
         BIZ_LINE_ID,              --业务条线
         VERIFY_STATUS,            --校验状态
         BSCJRQ,                   --报送期
         CONT_PARTY_TYPE,          --交易对手代码类别
         SERIAL_NO,                 --交易流水号
         CON_ACTUAL_DUE_DATE,      --合同实际终止日期
         BASE_INT_RAT,             --基准利率
         FRNBJGH,                  --法人内部机构号
         CUST_ID,                  --客户号
         CUST_NAME,                --客户名
         CUST_NAME_SOURCE,         --原客户名称
         CONT_PARTY_CODE_SOURCE,   --原交易对手代码
         MAIN_ORG_CN_NAME          --发起机构名称  --[2025-04-29] [周立鹏] [JLBA202503120002_关于金融市场部金融基础数据报送逻辑变更的需求][徐晖] 新增显示字段
  )
SELECT /*+PARALLEL(4)*/
         VS_TEXT DATA_DATE, --数据日期
        --- '9122010170255776XN' AS ORG_CODE, --金融机构代码
         NVL(OB.ID_NO,OB.UP_ID_NO) AS ORG_CODE, --金融机构代码
         T.ORG_NUM, --内部机构号
  /*       CASE WHEN  IS_PRODUCT='Y'  THEN  ''  ELSE  NVL(T1.TYSHXYDM,FR.LEGAL_TYSHXYDM)  END   AS CONT_PARTY_CODE, --交易对手代码,刘名赫反馈，产品户不取交易对手代码*/
  
  CASE WHEN  M.IS_PRODUCT='Y' AND M.CFETSMEMBERID IS NOT  NULL  THEN M.CFETSMEMBERID 
           WHEN M.IS_PRODUCT='Y' AND M.CFETSMEMBERID IS NULL  THEN '' 
              ELSE  NVL(T1.TYSHXYDM,FR.LEGAL_TYSHXYDM)  END   AS CONT_PARTY_CODE, --交易对手代码,刘名赫反馈，所有的产品户置空,修改：产品户优先取本币会员ID，然后再置空
              
         M.DEAL_ACCT_NUM AS CONTRACT_CODE, --合同编码
        --- CASE WHEN T.ITEM_CD ='111101' THEN 'AL01' ELSE 'AL02' END AS AL_TYPE, --资产负债类型
         CASE WHEN M.GL_ITEM_CODE ='111101' THEN 'AL01' ELSE 'AL02' END AS AL_TYPE,--资产负债类型 ,账户级别的
         --[2025-04-29] [周立鹏] [JLBA202503120002_关于金融市场部金融基础数据报送逻辑变更的需求][徐晖] 质押品是存单，产品归到F069
         CASE WHEN A.COLL_SUBJECT_TYPE = '同业存单' THEN 'F069' ELSE 'F061' END AS PRODUCT_TYPE, --产品类别
         TO_CHAR(M.VALUE_DATE, 'YYYY-MM-DD') AS CON_BGN_DATE, --合同起始日期，取首次交割日期=首次交日期+清算速度
         TO_CHAR(M.END_DT, 'YYYY-MM-DD') AS CON_DUE_DATE, --合同到期日期
         --TO_CHAR(T.START_DATE, 'YYYY-MM-DD') AS CON_BGN_DATE, --合同起始日期
         --TO_CHAR(T.MATURITY_DT, 'YYYY-MM-DD') AS CON_DUE_DATE, --合同到期日期
         T.CURR_CD, --币种
         M.CONTRACT_AMT   as  TRANS_AMT , --发生金额,就是合同金额，也是首次交易金额
         M.CONTRACT_AMT * C.CCY_RATE as TRANS_AMT_RMB , --发生金额折人民币
         'RF01' INT_RATE_TYPE, --利率是否固定
         T.REAL_INT_RAT AS INT_RATE, --利率水平
         'TR99' PRI_BENCH_MARK, --定价基准类型
         'B99' INT_METH, --计息方式
         T.TRADE_DIRECT, --发生/结清标识
         SYS_GUID() REPORT_ID,
         IS_DATE AS CJRQ,
         T.ORG_NUM AS NBJGH,
         'SC' BIZ_LINE_ID,
         '' VERIFY_STATUS,
         '' BSCJRQ,
        /* CASE WHEN IS_PRODUCT='Y'  THEN  ''   --产品户
             WHEN  IS_PRODUCT<>'Y'  AND   NVL(T1.TYSHXYDM,FR.LEGAL_TYSHXYDM)  IS NOT NULL  THEN 'A01' END, --交易对手代码类别*/
              CASE WHEN  M.IS_PRODUCT='Y'  AND M.CFETSMEMBERID IS NOT  NULL  THEN  'C02'  ---产品户
              WHEN  M.IS_PRODUCT='Y' AND M.CFETSMEMBERID IS NULL  THEN '' 
              WHEN  M.IS_PRODUCT<>'Y'  AND  NVL(T1.TYSHXYDM,FR.LEGAL_TYSHXYDM) IS NOT NULL  THEN 'A01' END, --交易对手代码类别
             
         T.REF_NUM || T.TRADE_DIRECT   AS  SERIAL_NO, --交易流水号
         CASE WHEN T.TRADE_DIRECT = '0' THEN TO_CHAR(T.TRAN_DT, 'YYYY-MM-DD') END  CON_ACTUAL_DUE_DATE ,      --合同实际终止日期
         '',--基准利率 --利率类型为固定利率的，基准利率必须为空
         '990000' FRNBJGH,
        '' , --客户号
         M.CUST_SHORT_NAME AS CUST_NAME, --上报客户名称
         '' CUST_NAME_SOURCE, --原客户名称
         '' AS CONT_PARTY_CODE_SOURCE, --原交易对手代码
         M.MAIN_ORG_CN_NAME --发起机构名称  --[2025-04-29] [周立鹏] [JLBA202503120002_关于金融市场部金融基础数据报送逻辑变更的需求][徐晖] 新增显示字段
    FROM (
    SELECT * FROM SMTMODS.L_TRAN_FUND_FX WHERE  SUBSTR(TO_CHAR(TRAN_DT,'YYYYMMDD'),1,6) = SUBSTR(IS_DATE,1,6)  AND ITEM_CD IN ('111101','211101')
    ) T  ---交易流水表 
    INNER JOIN (--L_ACCT_FUND_REPURCHASE 票据是全量，债券也是全量的数据，并且不限制到期日期>=当前日期的数据
    SELECT ACCT_NUM,DEAL_ACCT_NUM,MAIN_ORG_CN_NAME,REF_NUM,CUST_ID,CUST_SHORT_NAME,BALANCE,VALUE_DATE,END_DT,CONTRACT_AMT,GL_ITEM_CODE,IS_PRODUCT,CFETSMEMBERID
    FROM SMTMODS.L_ACCT_FUND_REPURCHASE
      WHERE DATA_DATE = IS_DATE AND GL_ITEM_CODE IN ('111101','211101') --债券卖出回购  211101  债券买入返售  111101
    )M ON T.CONTRACT_NUM=M.ACCT_NUM
    --[2025-04-29] [周立鹏] [JLBA202503120002_关于金融市场部金融基础数据报送逻辑变更的需求][徐晖] 质押品是存单，产品归到F069
    LEFT JOIN (SELECT ACCT_NUM,COLL_SUBJECT_TYPE FROM (
                 SELECT ACCT_NUM,COLL_SUBJECT_TYPE,ROW_NUMBER() OVER(PARTITION BY ACCT_NUM ORDER BY COLL_SUBJECT_TYPE)RN 
                   FROM SMTMODS.L_AGRE_REPURCHASE_GUARANTY_INFO WHERE DATA_DATE = IS_DATE) A
               WHERE A.RN = 1) A
      ON A.ACCT_NUM = M.ACCT_NUM
    LEFT JOIN SMTMODS.L_PUBL_RATE C
      ON C.DATA_DATE = IS_DATE
     AND C.BASIC_CCY = T.CURR_CD
     AND C.FORWARD_CCY = 'CNY'
LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=T.ORG_NUM AND OB.DATA_DATE=IS_DATE
  LEFT JOIN  (select distinct  ECIF_CUST_ID  ECIF_CUST_ID  , LEGAL_TYSHXYDM , Data_Date from   smtmods.L_CUST_BILL_TY  where LEGAL_TYSHXYDM is not  null  AND ECIF_CUST_ID IS NOT NULL   ) FR
  ON M.CUST_ID = FR.ECIF_CUST_ID   
  and FR.Data_Date =IS_DATE
   LEFT  JOIN  SMTMODS.L_CUST_C  T1
  ON  M.CUST_ID=T1.CUST_ID 
  AND T1.DATA_DATE  =IS_DATE; 
  COMMIT;


------add by  zy  20240829  end  


  VS_STEP := '3.插入F062-票据买入返售/卖出回购';
  --
  INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_TYJDFS(
         DATA_DATE,                --数据日期
         ORG_CODE,                 --金融机构代码
         ORG_NUM,                  --内部机构号
         CONT_PARTY_CODE,          --交易对手代码
         CONTRACT_CODE,            --合同编码
         AL_TYPE,                  --资产负债类型
         PRODUCT_TYPE,             --产品类别
         CON_BGN_DATE,             --合同起始日期
         CON_DUE_DATE,             --合同到期日期
         CURR_CODE,                --币种
         TRANS_AMT,                  --合同余额
         TRANS_AMT_RMB,              --合同余额折人民币
         INT_RATE_TYPE,            --利率是否固定
         INT_RATE,                 --利率水平
         PRI_BENCH_MARK,           --定价基准类型
         INT_METH,                 --计息方式
         TRANS_TYPE,               --发生/结清标识
         REPORT_ID,                --报表ID(SYS_GUID())
         CJRQ,                     --数据日期
         NBJGH,                    --内部机构号
         BIZ_LINE_ID,              --业务条线
         VERIFY_STATUS,            --校验状态
         BSCJRQ,                   --报送期
         CONT_PARTY_TYPE,          --交易对手代码类别
         SERIAL_NO,                 --交易流水号
         CON_ACTUAL_DUE_DATE,      --合同实际终止日期
         BASE_INT_RAT,             --基准利率
         FRNBJGH,                  --法人内部机构号
         CUST_ID,                  --客户号
         CUST_NAME,                --客户名
         CUST_NAME_SOURCE,         --原客户名称
         CONT_PARTY_CODE_SOURCE    --原交易对手代码
  )
 SELECT /*+PARALLEL(4)*/
         VS_TEXT DATA_DATE, --数据日期
         --OFF.JRJGBM AS ORG_CODE, --金融机构代码
         NVL(OB.ID_NO,OB.UP_ID_NO), --金融机构代码
         T.ORG_NUM, --内部机构号
         FR.LEGAL_TYSHXYDM_FR AS CONT_PARTY_CODE, --交易对手代码
         T.ACCT_NUM AS CONTRACT_CODE, --合同编码
         CASE WHEN T.GL_ITEM_CODE ='111102' THEN 'AL01' ELSE 'AL02' END AS AL_TYPE, --资产负债类型
         'F062' AS PRODUCT_TYPE, --产品类别 票据买入返售/卖出回购
         TO_CHAR(T.BEG_DT, 'yyyy-mm-dd') AS CON_BGN_DATE, --合同起始日期
         TO_CHAR(T.END_DT, 'yyyy-mm-dd') AS CON_DUE_DATE, --合同到期日期
         T.CURR_CD, --币种
         T.BALANCE, --合同余额
         T.BALANCE * C.CCY_RATE, --合同余额折人民币
         'RF01' INT_RATE_TYPE, --利率是否固定
         T.REAL_INT_RAT*100 AS INT_RATE, --利率水平
         'TR99' PRI_BENCH_MARK, --定价基准类型
         'B99' INT_METH, --计息方式
         T.TRANS_TYPE, --发生/结清标识
         SYS_GUID() REPORT_ID,
         IS_DATE AS CJRQ,
         T.ORG_NUM AS NBJGH,
         'SC' BIZ_LINE_ID,
         '' VERIFY_STATUS,
         '' BSCJRQ,
         'A01', --交易对手代码类别
         T.ACCT_NUM || T.TRANS_TYPE, --交易流水号
         CASE WHEN T.TRANS_TYPE = '0' THEN TO_CHAR(T.END_DT, 'yyyy-mm-dd') END,      --合同实际终止日期
         '',--基准利率 --利率类型为固定利率的，基准利率必须为空
          /*CASE WHEN T.ORG_NUM LIKE '5100%' THEN '510000' ELSE '990000' END FRNBJGH,*/
         CASE
           WHEN T.ORG_NUM LIKE '51%' THEN
           '510000'
           WHEN T.ORG_NUM LIKE '52%' THEN
            '520000'
           WHEN T.ORG_NUM LIKE '53%' THEN
            '530000'
           WHEN T.ORG_NUM LIKE '54%' THEN
            '540000'
           WHEN T.ORG_NUM LIKE '55%' THEN
            '550000'
           WHEN T.ORG_NUM LIKE '56%' THEN
            '560000'
           WHEN T.ORG_NUM LIKE '57%' THEN
            '570000'
           WHEN T.ORG_NUM LIKE '58%' THEN
            '580000'
           WHEN T.ORG_NUM LIKE '59%' THEN
            '590000'
           WHEN T.ORG_NUM LIKE '60%' THEN
            '600000'----20230620多法人新增
           ELSE '990000'
             END FRNBJGH,
                    T.CUST_ID, --客户号
         FR.FINA_ORG_NAME_FR AS CUST_NAME, --上报客户名称
         '' CUST_NAME_SOURCE, --原客户名称
         '' AS CONT_PARTY_CODE_SOURCE --原交易对手代码
    FROM (SELECT '1' AS TRANS_TYPE,ORG_NUM,CUST_ID,ACCT_NUM,GL_ITEM_CODE,BEG_DT,END_DT,REAL_INT_RAT,CURR_CD,SUM(ATM) AS BALANCE
            FROM SMTMODS.L_ACCT_FUND_REPURCHASE T WHERE T.DATA_DATE = IS_DATE
            AND T.GL_ITEM_CODE IN ('111102','211102') --债券卖出回购  211102  债券买入返售  111102
            AND SUBSTR(TO_CHAR(T.BEG_DT, 'yyyy-mm-dd'),1,7) = SUBSTR(VS_TEXT,1,7)--发生
            GROUP BY ORG_NUM,CUST_ID,ACCT_NUM,GL_ITEM_CODE,BEG_DT,END_DT,REAL_INT_RAT,CURR_CD
          UNION
          SELECT '0' AS TRANS_TYPE,ORG_NUM,CUST_ID,ACCT_NUM,GL_ITEM_CODE,BEG_DT,END_DT,REAL_INT_RAT,CURR_CD,SUM(ATM) AS BALANCE
            FROM SMTMODS.L_ACCT_FUND_REPURCHASE T WHERE T.DATA_DATE = IS_DATE
            AND T.GL_ITEM_CODE IN ('111102','211102') --债券卖出回购  211102  债券买入返售  111102
            AND SUBSTR(TO_CHAR(T.END_DT, 'yyyy-mm-dd'),1,7) = SUBSTR(VS_TEXT,1,7)--收回
            GROUP BY ORG_NUM,CUST_ID,ACCT_NUM,GL_ITEM_CODE,BEG_DT,END_DT,REAL_INT_RAT,CURR_CD
          ) T

    LEFT JOIN SMTMODS.L_PUBL_RATE C
      ON C.DATA_DATE = IS_DATE
     AND C.BASIC_CCY = T.CURR_CD
     AND C.FORWARD_CCY = 'CNY'
   /*LEFT JOIN SYS_OFFICE OFF
    ON OFF.ID= T.ORG_NUM*/
    LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=T.ORG_NUM AND OB.DATA_DATE=IS_DATE

  LEFT JOIN (SELECT * FROM(
    SELECT A.CUST_ID,A.FINA_ORG_CODE,A.FINA_ORG_NAME,B.FINA_ORG_NAME FINA_ORG_NAME_FR,B.LEGAL_TYSHXYDM LEGAL_TYSHXYDM_FR ,
    ROW_NUMBER()OVER(PARTITION BY A.FINA_ORG_NAME,A.FINA_ORG_CODE ORDER BY A.FINA_ORG_NAME) RN
    FROM (SELECT * FROM (
    SELECT CUST_ID,FINA_ORG_CODE,FINA_ORG_NAME,TYSHXYDM,LEGAL_TYSHXYDM,ROW_NUMBER() OVER(PARTITION BY FINA_ORG_NAME,FINA_ORG_CODE ORDER BY TYSHXYDM) RN
    FROM SMTMODS.L_CUST_BILL_TY A WHERE A.DATA_DATE=IS_DATE)A WHERE A.RN=1)A

    LEFT JOIN (SELECT * FROM (
    SELECT A.*,ROW_NUMBER() OVER(PARTITION BY TYSHXYDM ORDER BY FINA_ORG_NAME) RN
    FROM SMTMODS.L_CUST_BILL_TY A WHERE DATA_DATE=IS_DATE AND LEGAL_FLAG='Y'
    AND TYSHXYDM IS NOT NULL AND TYSHXYDM<>'000000000000000000'
    AND FINA_ORG_NAME NOT LIKE '%存托%' AND FINA_ORG_NAME NOT LIKE '%资管%' AND FINA_ORG_NAME NOT LIKE '%禁用%'
    ) A WHERE A.RN=1) B
    ON A.LEGAL_TYSHXYDM=B.TYSHXYDM) WHERE RN = 1)FR
  ON T.CUST_ID = FR.FINA_ORG_CODE ;
    COMMIT;

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
