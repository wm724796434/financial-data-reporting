CREATE OR REPLACE PROCEDURE BSP_SP_JS_202_CLTYCK (IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  --    SP_JS_202_CLTYCK
  -- 用途:生成接口表 JS_202_CLTYCK 存量同业存款信息表
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    需求编号：JLBA202504110003_关于优化金数系统同业存款发生和存量取数逻辑的需求 上线日期：2025-07-29，修改人：白杨，提出人：姜硕  修改原因：由于监管报送口径变更
  --    需求编号：JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段 上线日期：2025-12-30，修改人：周立鹏，提出人：李楠   修改原因：剔除特殊处理
  --    需求编号：JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求 上线日期：2026-01-30，修改人：周立鹏，提出人：李楠   修改原因：制度升级
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0;
  VS_TEXT           VARCHAR2(500) DEFAULT NULL;
  VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL;
  --VS_OWNER          VARCHAR2(32) DEFAULT NULL;
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL;
  VS_STEP           VARCHAR2(100);
  --NUM               INTEGER;
  --VS_NMONTH         VARCHAR2(10);

BEGIN
  VS_TEXT := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');

  -- ??????
  --SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_202_CLTYCK';
  --VS_NMONTH := TO_CHAR(TRUNC(TO_DATE(IS_DATE,'YYYYMMDD') + 1),'YYYYMMDD');
  -- ????
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);


-------------同业存放/存放同业------------------------------------------------
  SP_PBOCD_PARTITIONS(IS_DATE,'PBOCD_JS_202_CLTYCK',OI_RETCODE);

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_202_CLTYCK TRUNCATE PARTITION P' ||
                    IS_DATE;
INSERT INTO PBOCD_JS_202_CLTYCK
    (DATA_DATE                  --数据日期
      ,ORG_CODE                   --金融机构代码
      ,ORG_NUM                    --内部机构号
      ,PRODUCT_TYPE               --业务类型
      ,CONT_PARTY_CODE            --交易对手代码
      ,DEP_ACC_CODE               --存款账户代码
      ,DEP_AGR_CODE               --存款协议代码
      ,CON_BGN_DATE               --协议起始日期
      ,CON_DUE_DATE               --协议到期日期
      ,CURR_CODE                  --交易币种
      ,BALANCE                    --余额
      ,BALANCE_RMB                --余额折人民币
      ,INT_RATE                   --利率水平
      ,DEPOSIT_RESERVE_METHOD     --缴存准备金方式
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      ,FINI_REGION_CODE   --金融机构地区代码
      ,CONT_PARTY_INVESTEE_TYPE   --交易对手机构类型
      ,DEP_ACC_TYPE   --存款账户类型
      ,DEP_STATUS   --存款状态
      
      ,REPORT_ID                  --
      ,CJRQ                       --采集日期
      ,NBJGH                      --内部机构号
      ,BIZ_LINE_ID                --条线
      ,VERIFY_STATUS              --
      ,BSCJRQ                     --
      ,CONT_PARTY_TYPE            --交易对手类别
      ,FRNBJGH                    --法人内部机构号
      ,CUST_ID                    --客户号
      ,CUST_NAME                  --上报客户名称
      ,KMH                        --科目号
      ,CUST_NAME_SOURCE           --原客户名称
      ,CONT_PARTY_CODE_SOURCE     --原交易对手代码
     )
select
  VS_TEXT  --数据日期
 ,NVL(OB.ID_NO, OB.UP_ID_NO) AS ORG_CODE  --金融机构代码
 ,T.ORG_NUM --内部机构号
 ,  CASE
     WHEN T.ACCT_TYP LIKE '201%' AND T.DEPOSIT_TERM_FLG LIKE 'B%' THEN 'T011'
     WHEN T.ACCT_TYP LIKE '201%' AND T.DEPOSIT_TERM_FLG LIKE 'A%' THEN 'T012'
     WHEN T.ACCT_TYP LIKE '101%' AND T.DEPOSIT_TERM_FLG LIKE 'B%' THEN 'T021'
     WHEN T.ACCT_TYP LIKE '101%' AND T.DEPOSIT_TERM_FLG LIKE 'A%' THEN 'T022'
     END AS PRODUCT_TYPE --业务类型
 ,

 COALESCE(BK.CONT_PARTY_CODE,CD.CUST_ID_NO,CD1.CUST_ID_NO,T1.TYSHXYDM,
 CASE
    WHEN T1.TYSHXYDM IS NOT NULL THEN T1.TYSHXYDM
    WHEN B.INLANDORRSHORE_FLG='Y' THEN
    CASE
      WHEN (T1.FINA_CODE<>'I20000' OR T1.FINA_CODE IS NULL) THEN B.ID_NO
      WHEN T1.FINA_CODE='I20000' THEN T1.SPECIAL_CODE
         END
        WHEN B.INLANDORRSHORE_FLG='N' THEN COALESCE(T1.LEI_CODE,B.ID_NO,B.CUST_ID)
    END) AS CONT_PARTY_CODE --交易对手代码
 ,T.ACCT_NUM AS DEP_ACC_CODE --存款账户代码
 ,NVL(T.REF_NUM,T.ACCT_NUM) AS DEP_AGR_CODE--存款协议代码
 ,TO_CHAR(T.START_DATE,'YYYY-MM-DD')   AS CON_BGN_DATE  --协议起始日期
 ,TO_CHAR(T.MATURE_DATE,'YYYY-MM-DD')  AS CON_DUE_DATE --协议到期日期
 ,T.CURR_CD AS CURR_CODE --交易币种
 ,T.BALANCE AS BALANCE --余额
 , T.BALANCE * T3.CCY_RATE  AS BALANCE_RMB --余额折人民币
 ,NVL(T.REAL_INT_RAT,0) AS INT_RATE --利率水平
 
 --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 文件规则：2005归类到DR02-全额缴存，文件上其他科目归类到DR03-比例缴存，不在文件上的科目归类到DR01-不缴存
 --,BK.DEPOSIT_RESERVE_METHOD AS DEPOSIT_RESERVE_METHOD --缴存准备金方式 
 ,CASE WHEN SUBSTR(T.GL_ITEM_CODE,1,6) IN ('201201','201202','201203') 
   AND T.GL_ITEM_CODE NOT IN ('20120103','20120106','20120108','20120201','20120204','20120206','20120301','20120302') 
   THEN 'DR03' ELSE 'DR01' END AS DEPOSIT_RESERVE_METHOD --缴存准备金方式
 
 --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
 ,OB.REGION_CD AS FINI_REGION_CODE   --金融机构地区代码
 ,E2.PBOCD_CODE AS CONT_PARTY_INVESTEE_TYPE   --交易对手机构类型
 ,CASE WHEN T.ACCT_TYP LIKE '101%' THEN 'C010302' ELSE T.ACCT_ATTR END AS DEP_ACC_TYPE   --存款账户类型  --T01同业存放集市直接映射成金数码值，直取即可；姜硕：T02存放同业部分都用C010302自有资金账户
 ,E.PBOCD_CODE AS DEP_STATUS   --存款状态 DS01-正常 DS02-休眠 DS03-限制 DS04-销户 DS99-其他
 
 ,SYS_GUID() AS REPORT_ID --报送ID
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
 ,'' AS VERIFY_STATUS --校验状态
 ,'' AS BSCJRQ --报送采集日期
 

 ,NVL(BK.CONT_PARTY_TYPE,'A01') AS CONT_PARTY_TYPE --交易对手类别
 
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
            '600000'----20230620?????
           ELSE '990000'
  END AS FRNBJGH --法人内部机构号
 ,T.CUST_ID AS CUST_ID --客户号    
 

 ,COALESCE(BK.CUST_NAME,CD.CUST_NAME,CD1.CUST_NAME,T1.CUST_NAM) AS CUST_NAME--上报客户名称
 ,GL_ITEM_CODE AS KMH --科目号
 ,'' AS CUST_NAME_SOURCE --原客户名称
 ,'' AS CONT_PARTY_CODE_SOURCE --原交易对手代码

 FROM SMTMODS.L_ACCT_FUND_MMFUND T
 LEFT JOIN  L_CUST_C_TMP T1
   ON T.CUST_ID = T1.CUST_ID
  AND T1.DATA_DATE = IS_DATE
 INNER JOIN SMTMODS.L_CUST_ALL B
           ON T.CUST_ID = B.CUST_ID
          AND B.DATA_DATE = IS_DATE
 LEFT JOIN SMTMODS.L_PUBL_RATE    T3
  ON T3.BASIC_CCY = T.CURR_CD
  AND T3.FORWARD_CCY = 'CNY'
  AND T3.DATA_DATE = IS_DATE
 LEFT JOIN L_PUBL_ORG_BRA_TMP OB
      ON OB.ORG_NUM=T.ORG_NUM AND OB.DATA_DATE=IS_DATE

 LEFT JOIN (SELECT DISTINCT B.DEP_ACC_CODE,B.CONT_PARTY_CODE,B.CUST_NAME,B.CONT_PARTY_TYPE,B.DEPOSIT_RESERVE_METHOD
           FROM PBOCD_JS_202_CLTYCK_SQ B WHERE B.CJRQ = VS_LAST_TEXT ) BK
      ON T.ACCT_NUM = BK.DEP_ACC_CODE
 
 LEFT JOIN JS_102_TYKHXX_CODE CD
      ON (CASE
    WHEN B.INLANDORRSHORE_FLG='Y' THEN
    CASE
      WHEN (T1.FINA_CODE<>'I20000' OR T1.FINA_CODE IS NULL) THEN B.ID_NO
      WHEN T1.FINA_CODE='I20000' THEN T1.SPECIAL_CODE
         END
        WHEN B.INLANDORRSHORE_FLG='N' THEN COALESCE(T1.LEI_CODE,B.ID_NO,B.CUST_ID)
    END) = CD.CUST_ID_NO_SOURCE
 LEFT JOIN (SELECT DISTINCT T.CUST_NAME,T.CUST_ID_NO,T.CUST_NAME_SOURCE,T.CONT_PARTY_TYPE FROM JS_102_TYKHXX_CODE T) CD1
      ON T1.CUST_NAM = CD1.CUST_NAME_SOURCE
 
 --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
 LEFT JOIN (SELECT * FROM (SELECT ECIF_CUST_ID,FINA_CODE_NEW,LEGAL_FLAG,
              ROW_NUMBER() OVER(PARTITION BY ECIF_CUST_ID ORDER BY LEGAL_FLAG DESC ,FINA_CODE_NEW) RN
   FROM SMTMODS.L_CUST_BILL_TY TY WHERE DATA_DATE = IS_DATE) TY WHERE TY.RN = 1) TY
     ON T.CUST_ID = TY.ECIF_CUST_ID
 LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E --存款状态
     ON T.ACCT_STS = E.L_CODE
     AND E.CODE_CLMN_NAME = 'ACCT_STS'
 LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E2 --交易对手机构类型
     ON TRIM(TY.FINA_CODE_NEW) = E2.L_CODE
     AND E2.CODE_CLMN_NAME = 'FINA_CODE_NEW'
     
 WHERE substr(T.acct_typ,1,3) in ('101' ,'201' )
  AND T.DATA_DATE = IS_DATE
  AND T.BALANCE>0
  AND T.BALANCE * T3.CCY_RATE > 0
  AND T.ACCT_NUM NOT IN ('9029801141140000001_1','9019804011390200001_1');
  COMMIT ;


------------------------------------------------------------------------------

-----------------------add   by   zy   20240530  start---------------------------------------
 VS_STEP := '2.插入T03-同业存单发行/T04-同业存单投资';

-----------存单投资,009804和009820，存单号唯一，逻辑如下-------------------------
  INSERT INTO PBOCD_JS_202_CLTYCK
    (DATA_DATE                  --数据日期
      ,ORG_CODE                   --金融机构代码
      ,ORG_NUM                    --内部机构号
      ,PRODUCT_TYPE               --业务类型
      ,CONT_PARTY_CODE            --交易对手代码
      ,DEP_ACC_CODE               --存款账户代码
      ,DEP_AGR_CODE               --存款协议代码
      ,CON_BGN_DATE               --协议起始日期
      ,CON_DUE_DATE               --协议到期日期
      ,CURR_CODE                  --交易币种
      ,BALANCE                    --余额
      ,BALANCE_RMB                --余额折人民币
      ,INT_RATE                   --利率水平
      ,DEPOSIT_RESERVE_METHOD     --缴存准备金方式
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      ,FINI_REGION_CODE   --金融机构地区代码
      ,CONT_PARTY_INVESTEE_TYPE   --交易对手机构类型
      ,DEP_ACC_TYPE   --存款账户类型
      ,DEP_STATUS   --存款状态
      
      ,REPORT_ID                  --
      ,CJRQ                       --采集日期
      ,NBJGH                      --内部机构号
      ,BIZ_LINE_ID                --条线
      ,VERIFY_STATUS              --
      ,BSCJRQ                     --
      ,CONT_PARTY_TYPE            --交易对手类别
      ,FRNBJGH                    --法人内部机构号
      ,CUST_ID                    --客户号
      ,CUST_NAME                  --上报客户名称
      ,KMH                        --科目号
      ,CUST_NAME_SOURCE           --原客户名称
      ,CONT_PARTY_CODE_SOURCE     --原交易对手代码
     )
    SELECT VS_TEXT --  数据日期
      ,NVL(OB.ID_NO, OB.UP_ID_NO) AS ORG_CODE  --金融机构代码
      ,T.ORG_NUM --内部机构号
      ,'T04' AS PRODUCT_TYPE --业务类型
      ,T.CONT_PARTY_CODE --交易对手代码
      ,T.CDS_NO  AS  DEP_ACC_CODE --存款账户代码
      ,T.CDS_NO  AS DEP_AGR_CODE--存款协议代码
      ,TO_CHAR(T.ISSU_DT,'YYYY-MM-DD') AS CON_BGN_DATE  --协议起始日期
      ,TO_CHAR(T.MATURITY_DT,'YYYY-MM-DD')  AS CON_DUE_DATE --协议到期日期
      ,T.CURR_CD  AS CURR_CODE --交易币种
      ,SUM(T.PRINCIPAL_BALANCE)  AS BALANCE --余额
      ,SUM(T.PRINCIPAL_BALANCE * T3.CCY_RATE)  AS BALANCE_RMB --余额折人民币
      ,T.INT_RAT  AS INT_RATE --利率水平
      ,'DR01' AS DEPOSIT_RESERVE_METHOD --缴存准备金方式,存单投资默认不缴存
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      ,OB.REGION_CD AS FINI_REGION_CODE   --金融机构地区代码
      ,E2.PBOCD_CODE AS CONT_PARTY_INVESTEE_TYPE   --交易对手机构类型 
      ,'' AS DEP_ACC_TYPE   --存款账户类型 -- 发文要求报送同业存单发行/投资业务时，此项空置。
      ,E.PBOCD_CODE AS DEP_STATUS   --存款状态 DS01-正常 DS02-休眠 DS03-限制 DS04-销户 DS99-其他
 
      ,SYS_GUID() AS REPORT_ID --报送ID
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
      ,'' AS VERIFY_STATUS --校验状态
      ,'' AS BSCJRQ --报送采集日期
      ,CASE WHEN T.CONT_PARTY_CODE  IS  NOT  NULL THEN  'A01'  END  CONT_PARTY_TYPE --交易对手类别
      ,'990000' AS FRNBJGH --法人内部机构号
      --,T.CONT_PARTY_CODE AS CUST_ID --客户号
      ,T.CUST_ID AS CUST_ID --客户号
      ,T.CONT_PARTY_NAME  AS CUST_NAME--上报客户名称
      ,'' AS KMH --科目号
      ,'' AS CUST_NAME_SOURCE --原客户名称
      ,'' AS CONT_PARTY_CODE_SOURCE --原交易对手代码
     FROM SMTMODS.L_ACCT_FUND_CDS_BAL T   --存单投资与发行信息表 
       LEFT JOIN L_PUBL_ORG_BRA_TMP OB --金数机构表
            ON OB.ORG_NUM = T.ORG_NUM
           AND OB.DATA_DATE = IS_DATE
       LEFT JOIN SMTMODS.L_PUBL_RATE T3
            ON T3.BASIC_CCY = T.CURR_CD
           AND T3.FORWARD_CCY = 'CNY'
           AND T3.DATA_DATE = IS_DATE
           
       --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
       LEFT JOIN (SELECT * FROM (SELECT ECIF_CUST_ID,FINA_CODE_NEW,LEGAL_FLAG,
              ROW_NUMBER() OVER(PARTITION BY ECIF_CUST_ID ORDER BY LEGAL_FLAG DESC ,FINA_CODE_NEW) RN
   FROM SMTMODS.L_CUST_BILL_TY TY WHERE DATA_DATE = IS_DATE) TY WHERE TY.RN = 1) TY
           ON T.CUST_ID = TY.ECIF_CUST_ID
       LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E --存款状态
           ON T.ACCT_STS = E.L_CODE
           AND E.CODE_CLMN_NAME = 'ACCT_STS'
       LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E2 --交易对手机构类型
           ON TRIM(TY.FINA_CODE_NEW) = E2.L_CODE
           AND E2.CODE_CLMN_NAME = 'FINA_CODE_NEW'
     
        WHERE TRIM(T.DATA_DATE) = IS_DATE
          AND (SUBSTR(GL_ITEM_CODE, 1, 6)  IN ('250202')  OR GL_ITEM_CODE   IN ('11010105','15030105')) 
           AND T.PRINCIPAL_BALANCE > 0
           AND ROUND(T.PRINCIPAL_BALANCE * T3.CCY_RATE) > 0
           AND T.DATE_SOURCESD ='存单投资'
             group  by   NVL(OB.ID_NO, OB.UP_ID_NO)  --金融机构代码
      ,T.CONT_PARTY_CODE --交易对手代码
      ,T.CDS_NO   --存款账户代码
      ,TO_CHAR(T.ISSU_DT,'YYYY-MM-DD')   --协议起始日期
      ,TO_CHAR(T.MATURITY_DT,'YYYY-MM-DD')   --协议到期日期
      ,T.CURR_CD   --交易币种
      ,T.INT_RAT   --利率水平
      ,T.ORG_NUM  --内部机构号
      ,CASE
         WHEN T.ORG_NUM ='009820' THEN
          'TY'
          WHEN T.ORG_NUM ='009804' THEN
          'SC'
         ELSE
          '99'
       END  --条线
      ,CASE WHEN T.CONT_PARTY_CODE  IS  NOT  NULL THEN  'A01'  END   --交易对手类别
      ,T.CUST_ID --客户号
      ,T.CONT_PARTY_NAME
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      ,OB.REGION_CD   --金融机构地区代码
      ,E2.PBOCD_CODE   --交易对手机构类型 
      ,E.PBOCD_CODE   --存款状态 DS01-正常 DS02-休眠 DS03-限制 DS04-销户 DS99-其他
      ;

  COMMIT;
  
  
  -----------存单发行,009820，存单号不唯一，逻辑如下------------------
  INSERT INTO PBOCD_JS_202_CLTYCK
    (DATA_DATE                  --数据日期
      ,ORG_CODE                   --金融机构代码
      ,ORG_NUM                    --内部机构号
      ,PRODUCT_TYPE               --业务类型
      ,CONT_PARTY_CODE            --交易对手代码
      ,DEP_ACC_CODE               --存款账户代码
      ,DEP_AGR_CODE               --存款协议代码
      ,CON_BGN_DATE               --协议起始日期
      ,CON_DUE_DATE               --协议到期日期
      ,CURR_CODE                  --交易币种
      ,BALANCE                    --余额
      ,BALANCE_RMB                --余额折人民币
      ,INT_RATE                   --利率水平
      ,DEPOSIT_RESERVE_METHOD     --缴存准备金方式
      
      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      ,FINI_REGION_CODE   --金融机构地区代码
      ,CONT_PARTY_INVESTEE_TYPE   --交易对手机构类型
      ,DEP_ACC_TYPE   --存款账户类型
      ,DEP_STATUS   --存款状态
      
      ,REPORT_ID                  --
      ,CJRQ                       --采集日期
      ,NBJGH                      --内部机构号
      ,BIZ_LINE_ID                --条线
      ,VERIFY_STATUS              --
      ,BSCJRQ                     --
      ,CONT_PARTY_TYPE            --交易对手类别
      ,FRNBJGH                    --法人内部机构号
      ,CUST_ID                    --客户号
      ,CUST_NAME                  --上报客户名称
      ,KMH                        --科目号
      ,CUST_NAME_SOURCE           --原客户名称
      ,CONT_PARTY_CODE_SOURCE     --原交易对手代码
     )
    SELECT VS_TEXT --  数据日期
      ,NVL(OB.ID_NO, OB.UP_ID_NO) AS ORG_CODE  --金融机构代码
      ,T.ORG_NUM --内部机构号
      ,'T03' AS PRODUCT_TYPE --业务类型
      ,T.CONT_PARTY_CODE --交易对手代码
      ,T.CDS_NO || '-' || ROW_NUMBER() OVER  (PARTITION  BY  ACCT_NUM, CDS_NO  ORDER BY CONT_PARTY_NAME   ) AS DEP_ACC_CODE  --存款账户代码，存单号随机拼-1、-2等
      ,T.CDS_NO || '-' || ROW_NUMBER() OVER  (PARTITION  BY  ACCT_NUM, CDS_NO  ORDER BY CONT_PARTY_NAME   ) AS DEP_AGR_CODE  --存款协议代码
      ,TO_CHAR(T.ISSU_DT,'YYYY-MM-DD') AS CON_BGN_DATE  --协议起始日期
      ,TO_CHAR(T.MATURITY_DT,'YYYY-MM-DD')  AS CON_DUE_DATE --协议到期日期
      ,T.CURR_CD  AS CURR_CODE --交易币种
      /*,T.FACE_VAL * T1.ISSUER_PRICE/100  AS BALANCE --认购金额=账面余额 * 发行价格/100
      ,T.FACE_VAL * T1.ISSUER_PRICE  * T3.CCY_RATE/100 AS BALANCE_RMB --认购金额折人民币*/
      ,T.PRINCIPAL_BALANCE AS BALANCE     --认购金额  [2025-07-29] [白杨] [JLBA202504110003_关于优化金数系统同业存款发生和存量取数逻辑的需求 ][姜硕] 台账的持有仓位加上利息收益=剩余本金
      ,T.PRINCIPAL_BALANCE * T3.CCY_RATE AS BALANCE_RMB--认购金额折人民币  [2025-07-29] [白杨] [JLBA202504110003_关于优化金数系统同业存款发生和存量取数逻辑的需求 ][姜硕] 台账的持有仓位加上利息收益=剩余本金
      ,T.INT_RAT  AS INT_RATE --利率水平
      
      --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 文件规则：2005归类到DR02-全额缴存，文件上其他科目归类到DR03-比例缴存，不在文件上的科目归类到DR01-不缴存
      /*,CASE WHEN  T.CONT_PARTY_NAME LIKE '%证券%'  THEN  'DR03'
              WHEN  T.CONT_PARTY_NAME LIKE '%基金%'  THEN  'DR03' 
              WHEN  T.CONT_PARTY_NAME LIKE '%理财%'  THEN  'DR03'
              WHEN  T.CONT_PARTY_NAME LIKE '%计划%'  THEN  'DR03'
              WHEN  T.CONT_PARTY_NAME LIKE '%如意钱包%'  THEN  'DR03'
              ELSE  'DR01'  END  AS DEPOSIT_RESERVE_METHOD --缴存准备金方式,通过购买我行存单的产品判断的，而不是通过客户表中的客户主体判断的，银行DR01，其余DR03*/
      ,'DR01' AS DEPOSIT_RESERVE_METHOD --缴存准备金方式 按文件处理，科目不在文件范围内，归类到DR01-不缴存

      --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
      ,OB.REGION_CD AS FINI_REGION_CODE   --金融机构地区代码
      ,E2.PBOCD_CODE AS CONT_PARTY_INVESTEE_TYPE   --交易对手机构类型  
      ,'' AS DEP_ACC_TYPE   --存款账户类型 -- 发文要求报送同业存单发行/投资业务时，此项空置。
      ,E.PBOCD_CODE AS DEP_STATUS   --存款状态 DS01-正常 DS02-休眠 DS03-限制 DS04-销户 DS99-其他
      
      ,SYS_GUID() AS REPORT_ID --报送ID
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
      ,'' AS VERIFY_STATUS --校验状态
      ,'' AS BSCJRQ --报送采集日期
      ,CASE WHEN  T.CONT_PARTY_NAME LIKE '%证券%'  THEN  ''
              WHEN  T.CONT_PARTY_NAME LIKE '%基金%'  THEN ''
              WHEN  T.CONT_PARTY_NAME LIKE '%理财%'  THEN ''
              WHEN  T.CONT_PARTY_NAME LIKE '%计划%'  THEN  ''
              WHEN  T.CONT_PARTY_NAME LIKE '%如意钱包%'  THEN ''
              ELSE  'A01'  END   AS CONT_PARTY_TYPE --交易对手类别  业务给出逻辑：银行类的A01，其余为空 
      ,'990000' AS FRNBJGH --法人内部机构号
      --,T.CONT_PARTY_CODE AS CUST_ID --客户号
      ,T.CUST_ID AS CUST_ID --客户号
      ,T.CONT_PARTY_NAME  AS CUST_NAME--上报客户名称
      ,GL_ITEM_CODE AS KMH --科目号
      ,'' AS CUST_NAME_SOURCE --原客户名称
      ,'' AS CONT_PARTY_CODE_SOURCE --原交易对手代码
     FROM   SMTMODS.L_ACCT_FUND_CDS_BAL   T  --存单投资与发行信息表 
     LEFT  JOIN   SMTMODS.L_AGRE_OTHER_SUBJECT_INFO  T1 ---其他标的物信息表 
          ON  T.CDS_NO=T1.SUBJECT_CD
          AND T.DATA_DATE= T1.DATA_DATE 
       LEFT JOIN L_PUBL_ORG_BRA_TMP OB --金数机构表
            ON OB.ORG_NUM = T.ORG_NUM
           AND OB.DATA_DATE = IS_DATE
       LEFT JOIN SMTMODS.L_PUBL_RATE T3
            ON T3.BASIC_CCY = T.CURR_CD
           AND T3.FORWARD_CCY = 'CNY'
           AND T3.DATA_DATE = IS_DATE
              
       --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
       LEFT JOIN (SELECT * FROM (SELECT ECIF_CUST_ID,FINA_CODE_NEW,LEGAL_FLAG,
              ROW_NUMBER() OVER(PARTITION BY ECIF_CUST_ID ORDER BY LEGAL_FLAG DESC ,FINA_CODE_NEW) RN
   FROM SMTMODS.L_CUST_BILL_TY TY WHERE DATA_DATE = IS_DATE) TY WHERE TY.RN = 1) TY
           ON T.CUST_ID = TY.ECIF_CUST_ID
       LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E --存款状态
           ON T.ACCT_STS = E.L_CODE
           AND E.CODE_CLMN_NAME = 'ACCT_STS'
       LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E2 --交易对手机构类型
           ON TRIM(TY.FINA_CODE_NEW) = E2.L_CODE
           AND E2.CODE_CLMN_NAME = 'FINA_CODE_NEW'
       
        WHERE TRIM(T.DATA_DATE) = IS_DATE
          AND (SUBSTR(GL_ITEM_CODE, 1, 6)  IN ('250202')  OR GL_ITEM_CODE   IN ('11010105','15030105')) 
           AND T.FACE_VAL * T1.ISSUER_PRICE > 0
           AND T.DATE_SOURCESD ='存单发行';   

  COMMIT;
  
-----------------------add   by   zy   20240530   end---------------------------------------

-------------------------------------------------------------------------
  OI_RETCODE := 0; 
  OI_RETCODE_DEC :='执行成功';

  VS_STEP := 'END';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
EXCEPTION
  WHEN OTHERS THEN
    VI_ERRORCODE := SQLCODE;
    VS_TEXT      := VS_STEP || '|' || IS_DATE || '|' ||
                    SUBSTR(SQLERRM, 1, 200);
    ROLLBACK;
    OI_RETCODE := -1;
    OI_RETCODE_DEC :=SQLCODE||':'||SUBSTR(SQLERRM,1,50);

    SP_PBOCD_LOG(VS_PROCEDURE_NAME, 'ERROR', VI_ERRORCODE, VS_TEXT, IS_DATE);
END;