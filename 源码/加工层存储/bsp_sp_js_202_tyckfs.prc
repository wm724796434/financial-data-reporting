CREATE OR REPLACE PROCEDURE BSP_SP_JS_202_TYCKFS(IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS
/******************************
  @author:shenyunfei
  @create-date:20200706
  @description:同业存款发生额信息
  @modification history:
  --    需求编号：JLBA202503120002_关于金融市场部金融基础数据报送逻辑变更的需求 上线日期：2025-04-29，修改人：周立鹏，提出人：徐晖   修改原因：修改交易日期取数逻辑
  --    需求编号：JLBA202504110003_关于优化金数系统同业存款发生和存量取数逻辑的需求 上线日期：2025-07-29，修改人：白杨，提出人：姜硕  修改原因：由于监管报送口径变更
  --    需求编号：JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求 上线日期：2026-01-30，修改人：周立鹏，提出人：李楠   修改原因：制度升级
  *******************************/
  --V_SCHEMA            VARCHAR2(30); --当前存储过程所属的模式名
  VS_PROCEDURE_NAME     VARCHAR(30); --当前储存过程名称
  V_TAB_NAME            VARCHAR(30); --目标表名
  V_DATADATE            VARCHAR2(10); --数据日期(字符型)YYYY-MM-DD
  D_DATADATE            DATE; --数据日期(日期型)
  VS_MAX_DATE           VARCHAR2(10) DEFAULT NULL;
  VS_LAST_TEXT          VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  --V_STEP_ID           PLS_INTEGER; --任务号
  --V_STEP_DESC         VARCHAR(300); --任务描述
  --V_STEP_FLAG         PLS_INTEGER; --任务执行状态标识
  VS_OWNER              VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_STEP               VARCHAR2(100); --存储过程执行步骤标志
  VI_ERRORCODE          NUMBER DEFAULT 0; --数值型  异常代码
  NUM                   INTEGER;
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_NMONTH         VARCHAR2(10);
BEGIN
  VS_TEXT := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  VS_NMONTH := TO_CHAR(TRUNC(TO_DATE(IS_DATE,'YYYYMMDD') + 1),'YYYYMMDD');

    VS_STEP := '参数初始化处理';

    VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');
    --V_SCHEMA   := USER;
    VS_PROCEDURE_NAME := UPPER('SP_JS_202_TYCKFS');
    SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

    V_TAB_NAME := 'JS_202_TYCKFS';
    D_DATADATE := TO_DATE(IS_DATE,'YYYYMMDD');
    V_DATADATE := TO_CHAR(D_DATADATE,'YYYY-MM-DD');

    --V_STEP_FLAG := 1;
    --SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

    SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;


    --V_STEP_ID   := 1;
    --V_STEP_FLAG := 0;
    VS_STEP := '清理 [' || V_TAB_NAME || ']表历史数据';
    SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

    DELETE FROM PBOCD_DATACORE.PBOCD_JS_202_TYCKFS_TMP WHERE CJRQ = IS_DATE;
    COMMIT;


    EXECUTE IMMEDIATE 'TRUNCATE TABLE  JS_202_TYCKFS_TMP';

    --V_STEP_FLAG := 1;
    --SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);


    --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'PBOCD_JS_202_TYCKFS_TMP'
     AND PARTITION_NAME = 'P' || IS_DATE;

   --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_202_TYCKFS_TMP ADD PARTITION P' ||
                      IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_202_TYCKFS_TMP TRUNCATE PARTITION P' ||
                    IS_DATE;

 VS_STEP := '0.开始插入流水临时表';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
--流水表耗时，建临时表
  EXECUTE IMMEDIATE 'truncate table js_202_tyckfs_tmp01';
INSERT /*+APPEND*/
INTO JS_202_TYCKFS_TMP01
  (DATA_DATE,
   ORG_NUM,
   ACCOUNT_CODE,
   CURRENCY,
   TRANS_AMT,
   TX_DT,
   REFERENCE_NUM,
   OPPO_ACCT_NUM,
   --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
   OPP_NAME,
   CD_TYPE,
   CUST_ID)
  SELECT /*+parallel(4)*/
   A.DATA_DATE,
   A.ORG_NUM,
   A.ACCOUNT_CODE,
   A.CURRENCY,
   A.TRANS_AMT,
   A.TX_DT,
   A.REFERENCE_NUM,
   A.OPPO_ACCT_NUM,
   --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
   A.OPP_NAME,
   A.CD_TYPE,
   A.CUST_ID
    FROM SMTMODS.L_TRAN_TX A
   WHERE A.DATA_DATE BETWEEN SUBSTR(IS_DATE, 1, 6) || '01' AND
         IS_DATE
     AND A.TRANS_AMT <> 0
     AND SUBSTR(GL_ITEM_CODE, 1, 4) IN ('1011', '1031', '2012');
  COMMIT;

    VS_STEP := '1.开始生成活期数据';
    SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);


INSERT/*+append*/ INTO JS_202_TYCKFS_TMP NOLOGGING
    (
      --DATA_DATE, --数据日期
      ORG_CODE, --金融机构代码
      ORG_NUM, --内部机构号
      PRODUCT_TYPE, --业务类型
      CONT_PARTY_TYPE, --交易对手证件类型
      CONT_PARTY_CODE, --交易对手代码
      DEP_ACC_CODE, --存款账户编码
      DEP_AGR_CODE, --存款协议代码
      CON_BGN_DATE, --协议起始日期
      CON_DUE_DATE, --协议到期日期
      CURR_CODE, --币种
      TRANS_AMT, --交易金额
      TRANS_AMT_RMB, --交易金额折人民币
      TRANS_DATE, --交易日期
      SERIAL_NO, --交易流水号
      INT_RATE, --利率水平
      TRANS_ACCT_NUM, --交易账户号
      TRANS_ORG_CODE, --交易账户开户行号
      OPPO_ACCT_NUM, --交易对手账户号
      TRANS_TYPE, --交易方向
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      FINI_REGION_CODE,   --金融机构地区代码
      CONT_PARTY_INVESTEE_TYPE,   --交易对手机构类型
      DEP_ACC_TYPE,   --存款账户类型
      DEP_STATUS,   --存款状态
      OPPO_NAME,  --存款转入转出方名称
      OPPO_ACCT_ORG_CODE, --存款转入转出方账户开户行号
      
      --CJRQ, --采集日期
      NBJGH, --内部机构号
      BIZ_LINE_ID, --业务条线
     -- VERIFY_STATUS, --校验状态
      FRNBJGH, --法人内部机构号
      CUST_ID,
      CUST_NAME
    )
select /*+parallel(4)*/
      --IS_DATE DATA_DATE, --数据日期
      '' ORG_CODE, --金融机构代码
      A.ORG_NUM, --内部机构号
      CASE
     WHEN D.ACCT_TYP LIKE '201%' AND D.DEPOSIT_TERM_FLG LIKE 'B%' THEN 'T011'
     WHEN D.ACCT_TYP LIKE '201%' AND D.DEPOSIT_TERM_FLG LIKE 'A%' THEN 'T012'
     WHEN D.ACCT_TYP LIKE '101%' AND D.DEPOSIT_TERM_FLG LIKE 'B%' THEN 'T021'
     WHEN D.ACCT_TYP LIKE '101%' AND D.DEPOSIT_TERM_FLG LIKE 'A%' THEN 'T022'
     END AS PRODUCT_TYPE, --业务类型
     '' CONT_PARTY_TYPE, --交易对手证件类型
     CASE
    WHEN B.INLANDORRSHORE_FLG='Y' THEN
    CASE
      WHEN (T1.FINA_CODE<>'I20000' OR T1.FINA_CODE IS NULL) /*AND B.ID_TYPE IN ('21','236')*/ THEN B.ID_NO
      WHEN T1.FINA_CODE='I20000' THEN T1.SPECIAL_CODE
         END
        WHEN B.INLANDORRSHORE_FLG='N' THEN COALESCE(T1.LEI_CODE,B.ID_NO,B.CUST_ID)
      END CONT_PARTY_CODE, --交易对手代码 --
      A.ACCOUNT_CODE AS DEP_ACC_CODE, --存款账户编码
      D.REF_NUM AS DEP_AGR_CODE, --存款协议代码
      TO_CHAR(D.START_DATE,'YYYY-MM-DD'),   --协议起始日期
      TO_CHAR(D.MATURE_DATE,'YYYY-MM-DD'),  --协议到期日期
      A.CURRENCY AS CURR_CODE, --币种
      A.TRANS_AMT, --交易金额
      A.TRANS_AMT * T3.CCY_RATE AS TRANS_AMT_RMB, --交易金额折人民币
      TO_CHAR(A.TX_DT,'YYYY-MM-DD') TRANS_DATE, --交易日期
      A.REFERENCE_NUM AS SERIAL_NO, --交易流水号
      D.REAL_INT_RAT AS INT_RATE, --利率水平
      D.DEP_ACC_CODE AS TRANS_ACCT_NUM, --交易账户号
      OB.BANK_CD AS TRANS_ORG_CODE, --交易账户开户行号

    CASE WHEN D.ACCT_TYP LIKE '201%' AND D.DEPOSIT_TERM_FLG LIKE 'A%' --T012
         AND  A.OPPO_ACCT_NUM IS NULL THEN AD.acct_num
       ELSE A.OPPO_ACCT_NUM END , --交易对手账户号

   -- A.OPPO_ACCT_NUM AS OPPO_ACCT_NUM, --交易对手账户号
      CASE WHEN D.ACCT_TYP LIKE '101%' THEN
        CASE WHEN A.CD_TYPE = '2' THEN '0' ELSE '1'  END
      ELSE CASE WHEN A.CD_TYPE = '2' THEN '1' ELSE '0'  END
      END TRANS_TYPE, --交易方向
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      OB.REGION_CD AS FINI_REGION_CODE,   --金融机构地区代码
      E2.PBOCD_CODE AS CONT_PARTY_INVESTEE_TYPE,   --交易对手机构类型
      CASE WHEN D.ACCT_TYP LIKE '101%' THEN 'C010302' ELSE D.ACCT_ATTR END AS DEP_ACC_TYPE,   --存款账户类型  --T01同业存放集市直接映射成金数码值，直取即可；姜硕：T02存放同业部分都用C010302自有资金账户
      E.PBOCD_CODE AS DEP_STATUS,   --存款状态 DS01-正常 DS02-休眠 DS03-限制 DS04-销户 DS99-其他
      CASE WHEN LENGTH(A.OPP_NAME) >=4 THEN A.OPP_NAME END AS OPPO_NAME,  --存款转入转出方名称  发文：资金转入或转出的交易对手的全称 --经分析EAST对公存款表有效逻辑仅是判断长度
      TY.CUST_BANK_CD AS OPPO_ACCT_ORG_CODE, --存款转入转出方账户开户行号
      
      --IS_DATE AS CJRQ, --采集日期
      A.ORG_NUM AS NBJGH, --内部机构号
      '99' BIZ_LINE_ID, --业务条线
      --'' VERIFY_STATUS, --校验状态
     -- '000000' FRNBJGH, --法人内部机构号
      /*CASE WHEN A.ORG_NUM LIKE '5100%' THEN '510000' ELSE '990000' END FRNBJGH,*/
         /*CASE
           WHEN A.ORG_NUM LIKE '5100%' THEN
           '510000'
           WHEN A.ORG_NUM LIKE '5200%' THEN
            '520000'
           WHEN A.ORG_NUM LIKE '5300%' THEN
            '530000'
           WHEN A.ORG_NUM LIKE '5400%' THEN
            '540000'
           WHEN A.ORG_NUM LIKE '5500%' THEN
            '550000'
           WHEN A.ORG_NUM LIKE '5600%' THEN
            '560000'
           WHEN A.ORG_NUM LIKE '5700%' THEN
            '570000'
           WHEN A.ORG_NUM LIKE '5800%' THEN
            '580000'
           WHEN A.ORG_NUM LIKE '5900%' THEN
            '590000'
           WHEN A.ORG_NUM LIKE '6000%' THEN
            '600000'----20230620多法人新增*/
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
            '600000'----20231013王晓彬
           ELSE '990000'
             END FRNBJGH,

      A.CUST_ID AS CUST_ID,
      T1.CUST_NAM AS CUST_NAME
from JS_202_TYCKFS_TMP01 a
inner join smtmods.l_acct_fund_mmfund D
on a.account_code = D.acct_num and D.data_date = IS_DATE
INNER JOIN SMTMODS.L_CUST_ALL B --全量客户信息表
           ON A.CUST_ID = B.CUST_ID
          AND B.DATA_DATE = IS_DATE
LEFT JOIN SMTMODS.L_PUBL_RATE T3
  ON T3.BASIC_CCY = A.CURRENCY
  AND T3.FORWARD_CCY = 'CNY'
  AND T3.DATA_DATE = IS_DATE
LEFT JOIN L_PUBL_ORG_BRA_TMP OB --机构表
            ON A.ORG_NUM = OB.ORG_NUM
           AND OB.DATA_DATE = IS_DATE
 LEFT JOIN  L_CUST_C_TMP T1
   ON A.CUST_ID = T1.CUST_ID
  AND T1.DATA_DATE = IS_DATE
 LEFT JOIN  SMTMODS.L_ACCT_DEPOSIT AD --
 ON A.CUST_ID = AD.CUST_ID AND A.ACCOUNT_CODE = AD.ACCT_NUM AND AD.DATA_DATE = IS_DATE --
 
 --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
 LEFT JOIN (SELECT * FROM (SELECT ECIF_CUST_ID,FINA_CODE_NEW,CUST_BANK_CD,LEGAL_FLAG,
              ROW_NUMBER() OVER(PARTITION BY ECIF_CUST_ID ORDER BY LEGAL_FLAG DESC ,FINA_CODE_NEW,CUST_BANK_CD) RN
   FROM SMTMODS.L_CUST_BILL_TY TY WHERE DATA_DATE = IS_DATE) TY WHERE TY.RN = 1) TY
     ON D.CUST_ID = TY.ECIF_CUST_ID
 LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E --存款状态
     ON D.ACCT_STS = E.L_CODE
     AND E.CODE_CLMN_NAME = 'ACCT_STS'
 LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E2 --交易对手机构类型
     ON TRIM(TY.FINA_CODE_NEW) = E2.L_CODE
     AND E2.CODE_CLMN_NAME = 'FINA_CODE_NEW'
 
where substr(D.acct_typ,1,3) in ('201','101')
AND D.DEPOSIT_TERM_FLG LIKE 'B%';--定活标志 A定期 B活期
--and a.TRAN_CODE_DESCRIBE not like '%手续费%'; --20221212 by bqw 新核心中多取了手续费
commit;

    VS_STEP := '2.开始生成定期数据';
    SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);


INSERT/*+append*/ INTO JS_202_TYCKFS_TMP NOLOGGING
(
      --DATA_DATE, --数据日期
      ORG_CODE, --金融机构代码
      ORG_NUM, --内部机构号
      PRODUCT_TYPE, --业务类型
      CONT_PARTY_TYPE, --交易对手证件类型
      CONT_PARTY_CODE, --交易对手代码
      DEP_ACC_CODE, --存款账户编码
      DEP_AGR_CODE, --存款协议代码
      CON_BGN_DATE, --协议起始日期
      CON_DUE_DATE, --协议到期日期
      CURR_CODE, --币种
      TRANS_AMT, --交易金额
      TRANS_AMT_RMB, --交易金额折人民币
      TRANS_DATE, --交易日期
      SERIAL_NO, --交易流水号
      INT_RATE, --利率水平
      TRANS_ACCT_NUM, --交易账户号
      TRANS_ORG_CODE, --交易账户开户行号
      OPPO_ACCT_NUM, --交易对手账户号
      TRANS_TYPE, --交易方向
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      FINI_REGION_CODE,   --金融机构地区代码
      CONT_PARTY_INVESTEE_TYPE,   --交易对手机构类型
      DEP_ACC_TYPE,   --存款账户类型
      DEP_STATUS,   --存款状态
      OPPO_NAME,  --存款转入转出方名称
      OPPO_ACCT_ORG_CODE, --存款转入转出方账户开户行号
      
      --CJRQ, --采集日期
      NBJGH, --内部机构号
      BIZ_LINE_ID, --业务条线
     -- VERIFY_STATUS, --校验状态
      FRNBJGH, --法人内部机构号
      CUST_ID,
      CUST_NAME
    )
select /*+parallel(4)*/
     '' ORG_CODE, --金融机构代码
      A.ORG_NUM, --内部机构号
      CASE
     WHEN D.ACCT_TYP LIKE '201%' AND D.DEPOSIT_TERM_FLG LIKE 'B%' THEN 'T011'
     WHEN D.ACCT_TYP LIKE '201%' AND D.DEPOSIT_TERM_FLG LIKE 'A%' THEN 'T012'
     WHEN D.ACCT_TYP LIKE '101%' AND D.DEPOSIT_TERM_FLG LIKE 'B%' THEN 'T021'
     WHEN D.ACCT_TYP LIKE '101%' AND D.DEPOSIT_TERM_FLG LIKE 'A%' THEN 'T022'
     END AS PRODUCT_TYPE, --业务类型
     '' CONT_PARTY_TYPE, --交易对手证件类型
     CASE
    WHEN B.INLANDORRSHORE_FLG='Y' THEN
    CASE
      WHEN (T1.FINA_CODE<>'I20000' OR T1.FINA_CODE IS NULL) /*AND B.ID_TYPE IN ('21','236')*/ THEN B.ID_NO
      WHEN T1.FINA_CODE='I20000' THEN T1.SPECIAL_CODE
         END
        WHEN B.INLANDORRSHORE_FLG='N' THEN COALESCE(T1.LEI_CODE,B.ID_NO,B.CUST_ID)
      END CONT_PARTY_CODE, --交易对手代码
      A.ACCOUNT_CODE AS DEP_ACC_CODE, --存款账户编码
      A.ACCOUNT_CODE AS DEP_AGR_CODE, --存款协议代码
      TO_CHAR(D.START_DATE,'YYYY-MM-DD'),   --协议起始日期
      TO_CHAR(D.MATURE_DATE,'YYYY-MM-DD'),  --协议到期日期
      A.CURRENCY AS CURR_CODE, --币种
      A.TRANS_AMT, --交易金额
      A.TRANS_AMT * T3.CCY_RATE AS TRANS_AMT_RMB, --交易金额折人民币
      TO_CHAR(A.TX_DT,'YYYY-MM-DD') TRANS_DATE, --交易日期
      A.REFERENCE_NUM AS SERIAL_NO, --交易流水号
      D.REAL_INT_RAT AS INT_RATE, --利率水平
      A.ACCOUNT_CODE AS TRANS_ACCT_NUM, --交易账户号
      OB.BANK_CD AS TRANS_ORG_CODE, --交易账户开户行号

      CASE WHEN D.ACCT_TYP LIKE '201%' AND D.DEPOSIT_TERM_FLG LIKE 'A%' --T012
         AND  A.OPPO_ACCT_NUM IS NULL THEN AD.acct_num
       ELSE A.OPPO_ACCT_NUM END , --交易对手账户号

   -- A.OPPO_ACCT_NUM AS OPPO_ACCT_NUM, --交易对手账户号
      CASE WHEN D.ACCT_TYP LIKE '101%' THEN
        CASE WHEN A.CD_TYPE = '2' THEN '0' ELSE '1'  END
      ELSE CASE WHEN A.CD_TYPE = '2' THEN '1' ELSE '0'  END
      END TRANS_TYPE, --交易方向
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      OB.REGION_CD AS FINI_REGION_CODE,   --金融机构地区代码
      E2.PBOCD_CODE AS CONT_PARTY_INVESTEE_TYPE,   --交易对手机构类型
      CASE WHEN D.ACCT_TYP LIKE '101%' THEN 'C010302' ELSE D.ACCT_ATTR END AS DEP_ACC_TYPE,   --存款账户类型  --T01同业存放集市直接映射成金数码值，直取即可；姜硕：T02存放同业部分都用C010302自有资金账户
      E.PBOCD_CODE AS DEP_STATUS,   --存款状态 DS01-正常 DS02-休眠 DS03-限制 DS04-销户 DS99-其他
      CASE WHEN LENGTH(A.OPP_NAME) >=4 THEN A.OPP_NAME END AS OPPO_NAME,  --存款转入转出方名称  发文：资金转入或转出的交易对手的全称 --经分析EAST对公存款表有效逻辑仅是判断长度
      TY.CUST_BANK_CD AS OPPO_ACCT_ORG_CODE, --存款转入转出方账户开户行号
      
      --IS_DATE AS CJRQ, --采集日期
      A.ORG_NUM AS NBJGH, --内部机构号
      '99' BIZ_LINE_ID, --业务条线
      --'' VERIFY_STATUS, --校验状态
      --'000000' FRNBJGH, --法人内部机构号
      /*CASE WHEN A.ORG_NUM LIKE '5100%' THEN '510000' ELSE '990000' END FRNBJGH,*/
         /*CASE
           WHEN A.ORG_NUM LIKE '5100%' THEN
           '510000'
           WHEN A.ORG_NUM LIKE '5200%' THEN
            '520000'
           WHEN A.ORG_NUM LIKE '5300%' THEN
            '530000'
           WHEN A.ORG_NUM LIKE '5400%' THEN
            '540000'
           WHEN A.ORG_NUM LIKE '5500%' THEN
            '550000'
           WHEN A.ORG_NUM LIKE '5600%' THEN
            '560000'
           WHEN A.ORG_NUM LIKE '5700%' THEN
            '570000'
           WHEN A.ORG_NUM LIKE '5800%' THEN
            '580000'
           WHEN A.ORG_NUM LIKE '5900%' THEN
            '590000'
           WHEN A.ORG_NUM LIKE '6000%' THEN
            '600000'----20230620多法人新增*/
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
            '600000'----20231013王晓彬
           ELSE '990000'
             END FRNBJGH,

      A.CUST_ID AS CUST_ID,
      T1.CUST_NAM AS CUST_NAME
from JS_202_TYCKFS_TMP01 a
INNER join (
      select D.ACCT_NUM,D.ACCT_TYP,REAL_INT_RAT,D.DEPOSIT_TERM_FLG,D.ACCT_STS,D.ACCT_ATTR,
             max(D.MATURE_DATE) OVER (PARTITION BY D.ACCT_NUM) MATURE_DATE,
             min(D.START_DATE) OVER (PARTITION BY D.ACCT_NUM) START_DATE,
             ROW_NUMBER() OVER (PARTITION BY D.ACCT_NUM ORDER BY D.MATURE_DATE desc) RN
      from smtmods.l_acct_fund_mmfund d
      where d.data_date = IS_DATE
--    and balance>0--加这个条件后会有极个别数据的起始日期大于交易日期，并且会丢掉当月余额变为0的数据
      and d.deposit_term_flg like 'A%'--定活标志 A定期 B活期
      and substr(D.acct_typ,1,3) in ('201','101')
) D
on a.account_code = D.ACCT_NUM  AND RN = 1
INNER JOIN SMTMODS.L_CUST_ALL B --全量客户信息表
           ON A.CUST_ID = B.CUST_ID
          AND B.DATA_DATE = IS_DATE
LEFT JOIN SMTMODS.L_PUBL_RATE T3
  ON T3.BASIC_CCY = A.CURRENCY
  AND T3.FORWARD_CCY = 'CNY'
  AND T3.DATA_DATE = IS_DATE
LEFT JOIN L_PUBL_ORG_BRA_TMP OB --机构表
            ON A.ORG_NUM = OB.ORG_NUM
           AND OB.DATA_DATE = IS_DATE
 LEFT JOIN  L_CUST_C_TMP T1
   ON A.CUST_ID = T1.CUST_ID
  AND T1.DATA_DATE = IS_DATE
 LEFT JOIN  SMTMODS.L_ACCT_DEPOSIT AD --
 ON A.CUST_ID = AD.CUST_ID AND A.ACCOUNT_CODE = AD.ACCT_NUM AND AD.DATA_DATE = IS_DATE
 
 --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
 LEFT JOIN (SELECT * FROM (SELECT ECIF_CUST_ID,FINA_CODE_NEW,CUST_BANK_CD,LEGAL_FLAG,
              ROW_NUMBER() OVER(PARTITION BY ECIF_CUST_ID ORDER BY LEGAL_FLAG DESC ,FINA_CODE_NEW,CUST_BANK_CD) RN
   FROM SMTMODS.L_CUST_BILL_TY TY WHERE DATA_DATE = IS_DATE) TY WHERE TY.RN = 1) TY
     ON A.CUST_ID = TY.ECIF_CUST_ID
 LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E --存款状态
     ON D.ACCT_STS = E.L_CODE
     AND E.CODE_CLMN_NAME = 'ACCT_STS'
 LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E2 --交易对手机构类型
     ON TRIM(TY.FINA_CODE_NEW) = E2.L_CODE
     AND E2.CODE_CLMN_NAME = 'FINA_CODE_NEW'
     
;
--and a.TRAN_CODE_DESCRIBE not like '%手续费%'; --20221212 by bqw 新核心中多取了手续费

COMMIT;

    VS_STEP := '3.开始交易合并';
    SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
--合并定期
  INSERT INTO PBOCD_JS_202_TYCKFS_TMP(
      DATA_DATE
      ,ORG_CODE
      ,ORG_NUM
      ,PRODUCT_TYPE
      ,CONT_PARTY_CODE
      ,DEP_ACC_CODE
      ,DEP_AGR_CODE
      ,CON_BGN_DATE
      ,CON_DUE_DATE
      ,CURR_CODE
      ,TRANS_AMT
      ,TRANS_AMT_RMB
      ,TRANS_DATE
      ,SERIAL_NO
      ,INT_RATE
      ,TRANS_ACCT_NUM
      ,TRANS_ORG_CODE
      ,OPPO_ACCT_NUM
      ,TRANS_TYPE
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      ,FINI_REGION_CODE   --金融机构地区代码
      ,CONT_PARTY_INVESTEE_TYPE   --交易对手机构类型
      ,DEP_ACC_TYPE   --存款账户类型
      ,DEP_STATUS   --存款状态
      ,OPPO_NAME  --存款转入转出方名称
      ,OPPO_ACCT_ORG_CODE --存款转入转出方账户开户行号
      
      ,CJRQ
      ,CONT_PARTY_TYPE
      ,CUST_ID
      ,CUST_NAME
  )
  SELECT
      V_DATADATE
      ,ORG_CODE
      ,ORG_NUM
      ,PRODUCT_TYPE
      ,CONT_PARTY_CODE
      ,DEP_ACC_CODE
      ,DEP_AGR_CODE
      ,CON_BGN_DATE
      ,CON_DUE_DATE
      ,CURR_CODE
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 楠姐要求定期不再合并，因为发文没有指示
      /*,SUM(TRANS_AMT)
      ,SUM(TRANS_AMT_RMB)
      ,MAX(A.TRANS_DATE)*/
      ,TRANS_AMT
      ,TRANS_AMT_RMB
      ,A.TRANS_DATE
      ,SERIAL_NO
      ,NVL(INT_RATE,0)
      ,TRANS_ACCT_NUM
      ,TRANS_ORG_CODE
      ,OPPO_ACCT_NUM
      ,TRANS_TYPE
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      ,FINI_REGION_CODE   --金融机构地区代码
      ,CONT_PARTY_INVESTEE_TYPE   --交易对手机构类型
      ,DEP_ACC_TYPE   --存款账户类型
      ,DEP_STATUS   --存款状态
      ,OPPO_NAME  --存款转入转出方名称
      ,OPPO_ACCT_ORG_CODE --存款转入转出方账户开户行号
      
      ,IS_DATE AS CJRQ
      ,CASE WHEN CONT_PARTY_CODE IS NULL THEN '' ELSE CONT_PARTY_TYPE END  --交易对手代码为空时，把交易对手代码类别也赋空
      ,CUST_ID
      ,CUST_NAME
  FROM JS_202_TYCKFS_TMP A WHERE PRODUCT_TYPE IN ('T012','T022')
  --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 楠姐要求定期不再合并，因为发文没有指示
  /*GROUP BY ORG_CODE
    ,ORG_NUM
    ,PRODUCT_TYPE
    ,CONT_PARTY_CODE
    ,DEP_ACC_CODE
    ,DEP_AGR_CODE
    ,CON_BGN_DATE
    ,CON_DUE_DATE
    ,CURR_CODE
    ,INT_RATE
    ,TRANS_ACCT_NUM
    ,TRANS_ORG_CODE
    ,OPPO_ACCT_NUM
    ,TRANS_TYPE
    
    --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
    ,FINI_REGION_CODE   --金融机构地区代码
    ,CONT_PARTY_INVESTEE_TYPE   --交易对手机构类型
    ,DEP_ACC_TYPE   --存款账户类型
    ,DEP_STATUS   --存款状态
    ,OPPO_NAME  --存款转入转出方名称
    ,OPPO_ACCT_ORG_CODE --存款转入转出方账户开户行号
    
    ,CONT_PARTY_TYPE
    ,CUST_ID
    ,CUST_NAME*/
    ;
  COMMIT;

--合并活期
  INSERT INTO PBOCD_JS_202_TYCKFS_TMP(
      DATA_DATE
      ,ORG_CODE
      ,ORG_NUM
      ,PRODUCT_TYPE
      ,CONT_PARTY_CODE
      ,DEP_ACC_CODE
      ,DEP_AGR_CODE
      ,CON_BGN_DATE
      ,CON_DUE_DATE
      ,CURR_CODE
      ,TRANS_AMT
      ,TRANS_AMT_RMB
      ,TRANS_DATE
      ,INT_RATE
      ,TRANS_ACCT_NUM
      ,TRANS_ORG_CODE
      ,OPPO_ACCT_NUM
      ,TRANS_TYPE
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      ,FINI_REGION_CODE   --金融机构地区代码
      ,CONT_PARTY_INVESTEE_TYPE   --交易对手机构类型
      ,DEP_ACC_TYPE   --存款账户类型
      ,DEP_STATUS   --存款状态
      ,OPPO_NAME  --存款转入转出方名称
      ,OPPO_ACCT_ORG_CODE --存款转入转出方账户开户行号
      
      ,CJRQ
      ,CONT_PARTY_TYPE
      ,CUST_ID
      ,CUST_NAME
  )
  SELECT
      V_DATADATE
      ,ORG_CODE
      ,ORG_NUM
      ,PRODUCT_TYPE
      ,CONT_PARTY_CODE
      ,DEP_ACC_CODE
      ,DEP_AGR_CODE
      ,CON_BGN_DATE
      ,CON_DUE_DATE
      ,CURR_CODE
      ,SUM(TRANS_AMT)
      ,SUM(TRANS_AMT_RMB)
      ,'' TRANS_DATE
      ,NVL(INT_RATE,0)
      ,'' TRANS_ACCT_NUM
      ,'' TRANS_ORG_CODE
      ,'' OPPO_ACCT_NUM
      ,TRANS_TYPE
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段，
      --人行答疑：同业活期交易合并时，交易日期、交易流水号、交易账户号、交易账户开户行号、交易对手账户号等信息可置空。楠姐要求此处两个字段也置空。
      ,FINI_REGION_CODE   --金融机构地区代码
      ,CONT_PARTY_INVESTEE_TYPE   --交易对手机构类型
      ,DEP_ACC_TYPE   --存款账户类型
      ,DEP_STATUS   --存款状态
      ,'' OPPO_NAME  --存款转入转出方名称
      ,'' OPPO_ACCT_ORG_CODE --存款转入转出方账户开户行号
      
      ,IS_DATE AS CJRQ
      ,CASE WHEN CONT_PARTY_CODE IS NULL THEN '' ELSE CONT_PARTY_TYPE END  --交易对手代码为空时，把交易对手代码类别也赋空
      ,CUST_ID
      ,CUST_NAME
  FROM JS_202_TYCKFS_TMP A WHERE PRODUCT_TYPE IN ('T011','T021')
  GROUP BY ORG_CODE
    ,ORG_NUM
    ,PRODUCT_TYPE
    ,CONT_PARTY_CODE
    ,DEP_ACC_CODE
    ,DEP_AGR_CODE
    ,CON_BGN_DATE
    ,CON_DUE_DATE
    ,CURR_CODE
    ,INT_RATE
    ,TRANS_TYPE
    
    --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
    ,FINI_REGION_CODE   --金融机构地区代码
    ,CONT_PARTY_INVESTEE_TYPE   --交易对手机构类型
    ,DEP_ACC_TYPE   --存款账户类型
    ,DEP_STATUS   --存款状态
      
    ,CONT_PARTY_TYPE
    ,CUST_ID
    ,CUST_NAME
    ;
  COMMIT;

---以下包含原应用层加工逻辑，现都放在加工层处理

--查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'PBOCD_JS_202_TYCKFS'
     AND PARTITION_NAME = 'P' || IS_DATE;

 --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_202_TYCKFS ADD PARTITION P' ||
                      IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_202_TYCKFS TRUNCATE PARTITION P' ||
                    IS_DATE;

SELECT MAX(CJRQ) INTO VS_MAX_DATE FROM PBOCD_JS_101_JRJGFZ;

    VS_STEP := '4.开始插入落地表';
    SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
INSERT INTO PBOCD_JS_202_TYCKFS
    (DATA_DATE           --数据日期
      ,ORG_CODE            --金融机构代码
      ,ORG_NUM             --内部机构号
      ,PRODUCT_TYPE        --业务类型
      ,CONT_PARTY_CODE     --交易对手代码
      ,DEP_ACC_CODE        --存款账户代码
      ,DEP_AGR_CODE        --合同编码
      ,CON_BGN_DATE        --合同起始日期
      ,CON_DUE_DATE        --合同到期日期
      ,CURR_CODE           --交易币种
      ,TRANS_AMT           --交易金额
      ,TRANS_AMT_RMB       --交易金额折人民币
      ,TRANS_DATE          --交易日期
      ,SERIAL_NO           --流水号
      ,INT_RATE            --利率水平
      ,TRANS_ACCT_NUM      --交易账户号
      ,TRANS_ORG_CODE      --交易账户开户行号
      ,OPPO_ACCT_NUM       --交易对手账户号
      ,TRANS_TYPE          --交易方向
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      ,FINI_REGION_CODE   --金融机构地区代码
      ,CONT_PARTY_INVESTEE_TYPE   --交易对手机构类型
      ,DEP_ACC_TYPE   --存款账户类型
      ,DEP_STATUS   --存款状态
      ,OPPO_NAME  --存款转入转出方名称
      ,OPPO_ACCT_ORG_CODE --存款转入转出方账户开户行号
      
      ,REPORT_ID           --REPORT_ID
      ,CJRQ                --采集日期
      ,NBJGH               --内部机构
      ,BIZ_LINE_ID         --条线
      ,CONT_PARTY_TYPE     --交易对手类别
      ,FRNBJGH             --法人内部机构号
      ,CUST_ID             --客户号
      ,CUST_NAME           --客户名称
      ,CUST_NAME_SOURCE    --原客户名称
      ,CONT_PARTY_CODE_SOURCE    --原交易对手代码
     )
    SELECT
      VS_TEXT             --  数据日期
      --,NVL(C.JRJGBM,'9122010170255776XN') AS ORG_CODE         --金融机构代码
      ,NVL(NVL(OB.ID_NO,OB.UP_ID_NO),'9122010170255776XN') AS ORG_CODE         --金融机构代码
      ,T.ORG_NUM          --内部机构号
      ,T.PRODUCT_TYPE     --业务类型
      ,NVL(NVL(NVL(BK1.CONT_PARTY_CODE,BK2.CONT_PARTY_CODE),NVL(CD.CUST_ID_NO,CD1.CUST_ID_NO)),T.CONT_PARTY_CODE)  --交易对手代码
      ,T.DEP_ACC_CODE     --存款账户代码
      ,NVL(T.DEP_AGR_CODE,T.DEP_ACC_CODE)     --合同编码
      ,T.CON_BGN_DATE     --合同起始日期
      ,T.CON_DUE_DATE     --合同到期日期
      ,T.CURR_CODE        --交易币种
      ,T.TRANS_AMT        --交易金额
      ,T.TRANS_AMT_RMB    --交易金额折人民币
      ,T.TRANS_DATE       --交易日期
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 发文要求因合并而自定义生产的流水号前拼'JYLSHA'
      ,CASE WHEN T.PRODUCT_TYPE IN ('T011','T021') THEN 'JYLSHA' || SYS_GUID() ELSE T.SERIAL_NO END AS SERIAL_NO --流水号
      ,T.INT_RATE         --利率水平
      ,CASE WHEN SUBSTR(T.PRODUCT_TYPE,1,3) = 'T01' THEN T.DEP_ACC_CODE ELSE T.TRANS_ACCT_NUM END  --交易账户号
      ,T2.ORG_PAY_NUM   --交易账户开户行号
      ,T.OPPO_ACCT_NUM    --交易对手账户号
      ,T.TRANS_TYPE       --交易方向
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      ,FINI_REGION_CODE   --金融机构地区代码
      ,CONT_PARTY_INVESTEE_TYPE   --交易对手机构类型
      ,DEP_ACC_TYPE   --存款账户类型
      ,DEP_STATUS   --存款状态
      ,OPPO_NAME  --存款转入转出方名称
      ,OPPO_ACCT_ORG_CODE --存款转入转出方账户开户行号
      
      ,T.REPORT_ID        --REPORT_ID
      ,T.CJRQ             --采集日期
      ,T.ORG_NUM            --内部机构号
      ,CASE WHEN T.ORG_NUM ='009804' THEN 'SC'
            WHEN T.ORG_NUM ='009820' THEN 'TY'
            ELSE '99' END      --业务条线
      ,NVL(NVL(NVL(BK1.CONT_PARTY_TYPE,BK2.CONT_PARTY_TYPE),CD.CONT_PARTY_TYPE),'A01') --交易对手类别
      /*,CASE WHEN T.ORG_NUM LIKE '51%' THEN '510000' ELSE '990000' END FRNBJGH*/
         ,CASE
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
             END FRNBJGH

      ,T.CUST_ID          --客户号
      ,NVL(NVL(BK1.CUST_NAME,BK2.CUST_NAME),CD.CUST_NAME)        --客户名称
      ,NVL(T.CUST_NAME,T1.CUST_NAM)    --原客户名称
      ,NVL(NVL(T1.TYSHXYDM,T1.ID_NO),T1.ID_NO)    --原交易对手代码
      FROM PBOCD_DATACORE.PBOCD_JS_202_TYCKFS_TMP T
      LEFT JOIN SMTMODS.L_CUST_C T1
      ON T.CUST_ID = T1.CUST_ID
      AND T1.DATA_DATE = IS_DATE
      LEFT JOIN PBOCD_JS_101_JRJGFZ T2
      ON T.ORG_NUM = T2.ORG_NUM
      AND T2.CJRQ = VS_MAX_DATE
      /*LEFT JOIN SYS_OFFICE C --机构表
      ON trim(T.ORG_NUM) = C.ID*/
      LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=trim(T.ORG_NUM) AND OB.DATA_DATE=IS_DATE
      LEFT JOIN (SELECT DISTINCT B.DEP_ACC_CODE,B.DEP_AGR_CODE,B.CONT_PARTY_CODE,B.CUST_NAME,B.CONT_PARTY_TYPE
           FROM PBOCD_JS_202_CLTYCK_SQ B WHERE B.CJRQ = VS_LAST_TEXT AND B.PRODUCT_TYPE <> 'T03') BK1
      ON T.DEP_ACC_CODE = BK1.DEP_ACC_CODE
      --AND T.DEP_AGR_CODE = BK1.DEP_AGR_CODE
      LEFT JOIN (SELECT DISTINCT B.DEP_ACC_CODE,B.DEP_AGR_CODE,B.CONT_PARTY_CODE,B.CUST_NAME,B.CONT_PARTY_TYPE
           FROM PBOCD_JS_202_CLTYCK B WHERE B.CJRQ = IS_DATE AND B.PRODUCT_TYPE <> 'T03') BK2
      ON T.DEP_ACC_CODE = BK2.DEP_ACC_CODE
      --AND T.DEP_AGR_CODE = BK2.DEP_AGR_CODE
      LEFT JOIN (SELECT DISTINCT T.CUST_NAME,T.CUST_ID_NO,T.CUST_ID_NO_SOURCE,T.CONT_PARTY_TYPE FROM JS_102_TYKHXX_CODE T
                WHERE T.CUST_ID_NO_SOURCE <> '2999999999') CD
      ON NVL(NVL(T1.TYSHXYDM,T1.ID_NO),T1.ID_NO) = CD.CUST_ID_NO_SOURCE
      LEFT JOIN (SELECT DISTINCT T.CUST_NAME,T.CUST_ID_NO,T.CUST_NAME_SOURCE,T.CONT_PARTY_TYPE FROM JS_102_TYKHXX_CODE T) CD1
      ON NVL(T.CUST_NAME,T1.CUST_NAM) = CD1.CUST_NAME_SOURCE
      WHERE T.CJRQ= IS_DATE
      ;

    COMMIT;

DELETE FROM PBOCD_JS_202_TYCKFS
 WHERE CJRQ = IS_DATE AND DEP_ACC_CODE in('9029801141140000001_1','9019804011390200001_1');
COMMIT;

  MERGE INTO PBOCD_JS_202_TYCKFS A
  USING (SELECT B.CUST_NAME,
                B.CUST_ID_NO,
                B.CUST_ID_NO_SOURCE,
                B.CUST_NAME_SOURCE,
                B.CONT_PARTY_TYPE
           FROM JS_102_TYKHXX_CODE B) C
  ON (A.CONT_PARTY_CODE_SOURCE = C.CUST_ID_NO_SOURCE AND A.CUST_NAME_SOURCE = C.CUST_NAME_SOURCE AND A.CJRQ = IS_DATE)
  WHEN MATCHED THEN
    UPDATE
       SET A.CUST_NAME       = C.CUST_NAME,
           A.CONT_PARTY_CODE = C.CUST_ID_NO,
           A.CONT_PARTY_TYPE = C.CONT_PARTY_TYPE
     WHERE A.CONT_PARTY_CODE IS NULL;
  COMMIT;

------------------------------------------add  by  zy  20240531 start ------------------------------------
  VS_STEP := '2.插入T03-同业存单发行/T04-同业存单投资';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

-----------存单投资,009804和009820，存单号唯一，逻辑如下-------------------------

  INSERT INTO PBOCD_JS_202_TYCKFS
    (DATA_DATE           --数据日期
      ,ORG_CODE            --金融机构代码
      ,ORG_NUM             --内部机构号
      ,PRODUCT_TYPE        --业务类型
      ,CONT_PARTY_CODE     --交易对手代码
      ,DEP_ACC_CODE        --存款账户代码
      ,DEP_AGR_CODE        --合同编码
      ,CON_BGN_DATE        --合同起始日期
      ,CON_DUE_DATE        --合同到期日期
      ,CURR_CODE           --交易币种
      ,TRANS_AMT           --交易金额
      ,TRANS_AMT_RMB       --交易金额折人民币
      ,TRANS_DATE          --交易日期
      ,SERIAL_NO           --流水号
      ,INT_RATE            --利率水平
      ,TRANS_ACCT_NUM      --交易账户号
      ,TRANS_ORG_CODE      --交易账户开户行号
      ,OPPO_ACCT_NUM       --交易对手账户号
      ,TRANS_TYPE          --交易方向
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      ,FINI_REGION_CODE   --金融机构地区代码
      ,CONT_PARTY_INVESTEE_TYPE   --交易对手机构类型
      ,DEP_ACC_TYPE   --存款账户类型
      ,DEP_STATUS   --存款状态
      ,OPPO_NAME  --存款转入转出方名称
      ,OPPO_ACCT_ORG_CODE --存款转入转出方账户开户行号
      
      ,REPORT_ID           --REPORT_ID
      ,CJRQ                --采集日期
      ,NBJGH               --内部机构
      ,BIZ_LINE_ID         --条线
      ,CONT_PARTY_TYPE     --交易对手类别
      ,FRNBJGH             --法人内部机构号
      ,CUST_ID             --客户号
      ,CUST_NAME           --客户名称
      ,CUST_NAME_SOURCE    --原客户名称
      ,CONT_PARTY_CODE_SOURCE    --原交易对手代码
     )
    SELECT VS_TEXT --  数据日期
      ,NVL(OB.ID_NO, OB.UP_ID_NO) AS ORG_CODE --金融机构代码
      ,T.ORG_NUM --内部机构号
      ,'T04' --业务类型
      ,T.CONT_PARTY_CODE --交易对手代码,业务反馈，取不到的交易对手，取母公司的统一社会信用代码
      ,T.CDS_NO  AS DEP_ACC_CODE--存款账户代码
      ,T.CDS_NO   AS DEP_AGR_CODE --合同编码
      ,TO_CHAR(T.ISSU_DT, 'yyyy-mm-dd') AS CON_BGN_DATE --合同起始日期
      ,TO_CHAR(T.MATURITY_DT, 'yyyy-mm-dd') AS CON_DUE_DATE --合同到期日期
      ,T.CURR_CD AS CURR_CODE --交易币种
      ,A.AMOUNT AS TRANS_AMT --交易金额
      ,A.AMOUNT * T3.CCY_RATE AS TRANS_AMT_RMB --交易金额折人民币
     /* ,TO_CHAR(A.TRAN_DT, 'yyyy-mm-dd') AS TRANS_DATE --交易日期*/
      --,CASE WHEN A.TRAN_DT> T.MATURITY_DT  THEN TO_CHAR(T.MATURITY_DT, 'yyyy-mm-dd') ELSE  TO_CHAR(A.TRAN_DT, 'yyyy-mm-dd') END  AS TRANS_DATE --交易日期,根据刘名赫新给的口径调整
      ,TO_CHAR(A.TRAN_DT, 'yyyy-mm-dd') AS TRANS_DATE --交易日期 --[2025-04-29] [周立鹏] [JLBA202503120002_关于金融市场部金融基础数据报送逻辑变更的需求][徐晖] 直取交易日期
      ,CASE WHEN A.PRODUCT_NAME='同业存单交易信息' THEN  A.REF_NUM || '1'      ---同业存单交易信息：包含买入和中途转卖 ； 债券/存单还本交易 ：只有还本结清
           WHEN  A.PRODUCT_NAME='债券/存单还本交易' THEN  A.REF_NUM || '0'  END    AS SERIAL_NO --流水号
      ,T.INT_RAT  AS INT_RATE --利率水平
      ,'9019801014070300003' --交易账户号 我行的
      ,'313241066661' --交易账户开户行号 我行的
      ,CASE WHEN T.ORG_NUM ='009820' AND  A.PRODUCT_NAME='债券/存单还本交易'   THEN  '1023130000063' ELSE  A.OPPO_ACCT_NUM  END    OPPO_ACCT_NUM  --交易对手账户号
      ,A.TRADE_DIRECT TRANS_TYPE --交易方向  1 发生买入存单   0  2种方向，1种是中途转卖，1种是结清卖出存单
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      ,OB.REGION_CD AS FINI_REGION_CODE   --金融机构地区代码
      ,E2.PBOCD_CODE AS CONT_PARTY_INVESTEE_TYPE   --交易对手机构类型
      ,'' AS DEP_ACC_TYPE   --存款账户类型 -- 发文要求报送同业存单发行/投资业务时，此项空置。
      ,E.PBOCD_CODE AS DEP_STATUS   --存款状态
      ,CASE WHEN LENGTH(T.CONT_PARTY_NAME) >=4 THEN T.CONT_PARTY_NAME END AS OPPO_NAME  --存款转入转出方名称  发文：资金转入或转出的交易对手的全称 --经分析EAST对公存款表有效逻辑仅是判断长度
      ,TY.CUST_BANK_CD AS OPPO_ACCT_ORG_CODE --存款转入转出方账户开户行号
      
      ,SYS_GUID() AS REPORT_ID --REPORT_ID
      ,IS_DATE AS CJRQ --采集日期
      ,T.ORG_NUM  AS NBJGH --内部机构号
      ,CASE
         WHEN T.ORG_NUM ='009820' THEN
          'TY'
          WHEN T.ORG_NUM ='009804' THEN
          'SC'
         ELSE
          '99'
       END  AS BIZ_LINE_ID--条线
      , CASE WHEN T.CONT_PARTY_CODE IS NOT  NULL  THEN  'A01' END   AS  CONT_PARTY_TYPE --交易对手类别
      ,'990000' AS FRNBJGH
      ,T.CONT_PARTY_CODE AS CUST_ID --客户号
      ,T.CONT_PARTY_NAME --客户名称
      ,'' AS  CUST_NAME_SOURCE  --原客户名称
      ,'' AS  CONT_PARTY_CODE_SOURCE --原交易对手代码
 FROM SMTMODS.L_TRAN_FUND_FX A    ---资金交易信息表
 INNER JOIN SMTMODS.L_ACCT_FUND_CDS_BAL T   ---存单投资与发行信息表
    ON A.CONTRACT_NUM = T.ACCT_NUM AND T.DATA_DATE = IS_DATE    ---存单投资会有1个存单号，2个合同号的情况，但仍需要按照实际发生的交易业务逐笔进行报送，比如：CONTRACT_NUM like ( '112403029%')
   AND (SUBSTR(GL_ITEM_CODE, 1, 6)  IN ('250202')  OR GL_ITEM_CODE   IN ('11010105','15030105'))
 LEFT JOIN SMTMODS.L_PUBL_RATE T3
            ON T3.BASIC_CCY = T.CURR_CD
           AND T3.FORWARD_CCY = 'CNY'
           AND T3.DATA_DATE = IS_DATE
 LEFT JOIN L_PUBL_ORG_BRA_TMP OB --金数机构表
    ON OB.ORG_NUM = trim(A.ORG_NUM)
   AND OB.DATA_DATE = IS_DATE
   
 --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
 LEFT JOIN (SELECT * FROM (SELECT ECIF_CUST_ID,FINA_CODE_NEW,CUST_BANK_CD,LEGAL_FLAG,
              ROW_NUMBER() OVER(PARTITION BY ECIF_CUST_ID ORDER BY LEGAL_FLAG DESC ,FINA_CODE_NEW,CUST_BANK_CD) RN
   FROM SMTMODS.L_CUST_BILL_TY TY WHERE DATA_DATE = IS_DATE) TY WHERE TY.RN = 1)TY
     ON T.CUST_ID = TY.ECIF_CUST_ID
 LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E --存款状态
     ON T.ACCT_STS = E.L_CODE
     AND E.CODE_CLMN_NAME = 'ACCT_STS'
 LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E2 --交易对手机构类型
     ON TRIM(TY.FINA_CODE_NEW) = E2.L_CODE
     AND E2.CODE_CLMN_NAME = 'FINA_CODE_NEW'
   
 WHERE TO_CHAR(A.TRAN_DT,'YYYYMM') =SUBSTR( IS_DATE,1,6)
  AND  T.DATE_SOURCESD ='存单投资';
  COMMIT;

-----存单发行,009820，认购业务：存在多个交易对手购买同一存单的情况，存单号按照交易对手名称拼-1、-2等，交易流水号一致，逻辑如下----------------
-----存单发行,009820，收回业务：业务报送是按照认购时逐笔报送的，收回金额需要拆分到每个交易对手上，存单号按照交易对手名称拼-1、-2等，交易流水号一致，逻辑如下--------------
  INSERT INTO PBOCD_JS_202_TYCKFS
    (DATA_DATE           --数据日期
      ,ORG_CODE            --金融机构代码
      ,ORG_NUM             --内部机构号
      ,PRODUCT_TYPE        --业务类型
      ,CONT_PARTY_CODE     --交易对手代码
      ,DEP_ACC_CODE        --存款账户代码
      ,DEP_AGR_CODE        --合同编码
      ,CON_BGN_DATE        --合同起始日期
      ,CON_DUE_DATE        --合同到期日期
      ,CURR_CODE           --交易币种
      ,TRANS_AMT           --交易金额
      ,TRANS_AMT_RMB       --交易金额折人民币
      ,TRANS_DATE          --交易日期
      ,SERIAL_NO           --流水号
      ,INT_RATE            --利率水平
      ,TRANS_ACCT_NUM      --交易账户号
      ,TRANS_ORG_CODE      --交易账户开户行号
      ,OPPO_ACCT_NUM       --交易对手账户号
      ,TRANS_TYPE          --交易方向
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      ,FINI_REGION_CODE   --金融机构地区代码
      ,CONT_PARTY_INVESTEE_TYPE   --交易对手机构类型
      ,DEP_ACC_TYPE   --存款账户类型
      ,DEP_STATUS   --存款状态
      ,OPPO_NAME  --存款转入转出方名称
      ,OPPO_ACCT_ORG_CODE --存款转入转出方账户开户行号
      
      ,REPORT_ID           --REPORT_ID
      ,CJRQ                --采集日期
      ,NBJGH               --内部机构
      ,BIZ_LINE_ID         --条线
      ,CONT_PARTY_TYPE     --交易对手类别
      ,FRNBJGH             --法人内部机构号
      ,CUST_ID             --客户号
      ,CUST_NAME           --客户名称
      ,CUST_NAME_SOURCE    --原客户名称
      ,CONT_PARTY_CODE_SOURCE    --原交易对手代码
     )
       SELECT VS_TEXT --  数据日期
      ,NVL(OB.ID_NO, OB.UP_ID_NO)  AS ORG_CODE --金融机构代码
      ,T.ORG_NUM --内部机构号
      ,'T03' --业务类型
      ,T.CONT_PARTY_CODE --交易对手代码,业务反馈，取不到的交易对手，取母公司的统一社会信用代码
      ,T.CDS_NO || '-' || ROW_NUMBER() OVER  (PARTITION  BY  T.ACCT_NUM, T.CDS_NO  ORDER BY T.CONT_PARTY_NAME   ) AS  DEP_ACC_CODE  --存款账户代码，由于存单号不唯一，因此
      ,T.CDS_NO || '-' || ROW_NUMBER() OVER  (PARTITION  BY  T.ACCT_NUM, T.CDS_NO  ORDER BY T.CONT_PARTY_NAME   ) AS  DEP_AGR_CODE  --合同编码
      ,TO_CHAR(T.ISSU_DT, 'yyyy-mm-dd') AS CON_BGN_DATE --合同起始日期
      ,TO_CHAR(T.MATURITY_DT, 'yyyy-mm-dd') AS CON_DUE_DATE --合同到期日期
      ,T.CURR_CD AS CURR_CODE --交易币种
/*      ,CASE WHEN A.TRADE_DIRECT ='0' THEN A.AMOUNT  ELSE  A.AMOUNT/10  END  AS TRANS_AMT --交易金额
      ,CASE WHEN A.TRADE_DIRECT ='0' THEN A.AMOUNT * T3.CCY_RATE ELSE  A.AMOUNT * T3.CCY_RATE END   AS TRANS_AMT_RMB --交易金额折人民币*/
      ,CASE WHEN A.TRADE_DIRECT ='0' THEN A.AMOUNT  ELSE  T.PRINCIPAL_BALANCE  END  AS TRANS_AMT --交易金额 [2025-07-29] [白杨] [JLBA202504110003_关于优化金数系统同业存款发生和存量取数逻辑的需求 ][姜硕] 台账的持有仓位加上利息收益=剩余本金
      ,CASE WHEN A.TRADE_DIRECT ='0' THEN A.AMOUNT * T3.CCY_RATE  ELSE T.PRINCIPAL_BALANCE* T3.CCY_RATE END AS TRANS_AMT_RMB --交易金额折人民币 [2025-07-29] [白杨] [JLBA202504110003_关于优化金数系统同业存款发生和存量取数逻辑的需求 ][姜硕] 台账的持有仓位加上利息收益=剩余本金
      ,TO_CHAR(A.TRAN_DT, 'yyyy-mm-dd') AS TRANS_DATE --交易日期
      ,A.REF_NUM || A.TRADE_DIRECT AS SERIAL_NO --流水号
      ,T.INT_RAT  AS INT_RATE --利率水平
      ,'9019801014070300003' --交易账户号 我行的
      ,'313241066661' --交易账户开户行号 我行的
      ,CASE WHEN  A.TRADE_DIRECT ='0' THEN  '1010030000013' ELSE A.OPPO_ACCT_NUM  END  OPPO_ACCT_NUM    --交易对手账户号
      ,A.TRADE_DIRECT TRANS_TYPE --交易方向  1 存单认购  0 存单收回
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      ,OB.REGION_CD AS FINI_REGION_CODE   --金融机构地区代码
      ,E2.PBOCD_CODE AS CONT_PARTY_INVESTEE_TYPE   --交易对手机构类型
      ,'' AS DEP_ACC_TYPE   --存款账户类型 -- 发文要求报送同业存单发行/投资业务时，此项空置。
      ,E.PBOCD_CODE AS DEP_STATUS   --存款状态
      ,CASE WHEN LENGTH(T.CONT_PARTY_NAME) >=4 THEN T.CONT_PARTY_NAME END AS OPPO_NAME  --存款转入转出方名称  发文：资金转入或转出的交易对手的全称 --经分析EAST对公存款表有效逻辑仅是判断长度
      ,TY.CUST_BANK_CD AS OPPO_ACCT_ORG_CODE --存款转入转出方账户开户行号
      
      ,SYS_GUID() AS REPORT_ID --REPORT_ID
      ,IS_DATE AS CJRQ --采集日期
      ,T.ORG_NUM --内部机构号
      ,CASE
         WHEN T.ORG_NUM ='009820' THEN
          'TY'
          WHEN T.ORG_NUM ='009804' THEN
          'SC'
         ELSE
          '99'
       END  AS BIZ_LINE_ID--条线
      ,CASE WHEN  T.CONT_PARTY_NAME LIKE '%证券%'  THEN  ''
              WHEN  T.CONT_PARTY_NAME LIKE '%基金%'  THEN ''
              WHEN  T.CONT_PARTY_NAME LIKE '%理财%'  THEN ''
              WHEN  T.CONT_PARTY_NAME LIKE '%计划%'  THEN  ''
              WHEN  T.CONT_PARTY_NAME LIKE '%如意钱包%'  THEN ''
              ELSE  'A01'  END   AS CONT_PARTY_TYPE --交易对手类别  业务给出逻辑：银行类的A01，其余为空
      ,'990000' AS FRNBJGH
      ,T.CONT_PARTY_CODE AS CUST_ID --客户号
      ,T.CONT_PARTY_NAME --客户名称
      ,'' AS  CUST_NAME_SOURCE  --原客户名称
      ,'' AS  CONT_PARTY_CODE_SOURCE --原交易对手代码
 FROM (SELECT T1.DATA_DATE,
       T1.ORG_NUM,
       SUBSTR(T1.REF_NUM, 1, INSTR(T1.REF_NUM, '_') - 1) AS REF_NUM,
       T1.CONTRACT_NUM,
       SUM(T1.AMOUNT) AS AMOUNT ,
       T1.TRAN_DT,
       T1.TRADE_DIRECT,
       T1.CUST_ID,
       T1.OPPO_ACCT_NUM,
       T1.CONT_PARTY_NAME
  FROM SMTMODS.L_TRAN_FUND_FX T1
 WHERE TO_CHAR(T1.TRAN_DT, 'YYYYMM') = SUBSTR(IS_DATE, 1, 6)
   and PRODUCT_NAME in( '存单发行_康星','存单发行_还本交易')
 GROUP BY T1.DATA_DATE,
          T1.ORG_NUM,
          T1.CONTRACT_NUM,
          T1.TRAN_DT,
          T1.TRADE_DIRECT,
          SUBSTR(T1.REF_NUM, 1, INSTR(T1.REF_NUM, '_') - 1),
          T1.CUST_ID,
          T1.OPPO_ACCT_NUM,
          T1.CONT_PARTY_NAME) A    --2种业务，存单认购和收回业务，按照交易对手名称、截取后的交易流水、账户号进行汇总后在与账户表进行关联(解决同一客户同一天内购买多笔同一存单的问题)
 INNER JOIN SMTMODS.L_ACCT_FUND_CDS_BAL T   ----存单投资与发行信息表
    ON A.CONTRACT_NUM = T.CDS_NO
    AND A.CONT_PARTY_NAME  =T.CONT_PARTY_NAME  --交易对手名称是主键，因此可以用来关联，此外名称是业务报送的全量的理财计划名称等，而不是该理财计划发行的公司；
    AND T.DATA_DATE = IS_DATE
   AND (SUBSTR(GL_ITEM_CODE, 1, 6)  IN ('250202')  OR GL_ITEM_CODE   IN ('11010105','15030105'))
 LEFT JOIN SMTMODS.L_PUBL_RATE T3
            ON T3.BASIC_CCY = T.CURR_CD
           AND T3.FORWARD_CCY = 'CNY'
           AND T3.DATA_DATE = IS_DATE
 LEFT JOIN L_PUBL_ORG_BRA_TMP OB --金数机构表
    ON OB.ORG_NUM = trim(A.ORG_NUM)
   AND OB.DATA_DATE = IS_DATE
   
 --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
 LEFT JOIN (SELECT * FROM (SELECT ECIF_CUST_ID,FINA_CODE_NEW,CUST_BANK_CD,LEGAL_FLAG,
              ROW_NUMBER() OVER(PARTITION BY ECIF_CUST_ID ORDER BY LEGAL_FLAG DESC ,FINA_CODE_NEW,CUST_BANK_CD) RN
   FROM SMTMODS.L_CUST_BILL_TY TY WHERE DATA_DATE = IS_DATE) TY WHERE TY.RN = 1) TY
     ON T.CUST_ID = TY.ECIF_CUST_ID
 LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E --存款状态
     ON T.ACCT_STS = E.L_CODE
     AND E.CODE_CLMN_NAME = 'ACCT_STS'
 LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E2 --交易对手机构类型
     ON TRIM(TY.FINA_CODE_NEW) = E2.L_CODE
     AND E2.CODE_CLMN_NAME = 'FINA_CODE_NEW'
     
 WHERE T.DATE_SOURCESD ='存单发行';
    COMMIT;

------------------------------------------add  by  zy  20240531 end ------------------------------------

    OI_RETCODE := 0; --设置异常状态为0 成功状态
    OI_RETCODE_DEC :='执行成功';
    VS_STEP := VS_PROCEDURE_NAME || '的业务逻辑全部处理完成';
    SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

EXCEPTION
  WHEN OTHERS THEN
    --VS_STEP := '发生异常。详细信息为，' || TO_CHAR(SQLCODE) || SUBSTR(SQLERRM, 1, 280);
    VS_STEP := -1;
  OI_RETCODE := -1; --设置异常状态为-1
  OI_RETCODE_DEC :=SQLCODE||':'||SUBSTR(SQLERRM,1,50);--系统错误描述
  VI_ERRORCODE := SQLCODE; --设置异常代码
  VS_TEXT      := VS_STEP || '|' || IS_DATE || '|' ||
                    SUBSTR(SQLERRM, 1, 200); --设置异常描述
    --记录异常信息
    SP_PBOCD_LOG(VS_PROCEDURE_NAME, 'ERROR', VI_ERRORCODE, VS_TEXT, IS_DATE);
    --更新执行计划
    --SP_ETL_PROC_PLAN(IS_DATE, V_PROCNAME, 0);
END;