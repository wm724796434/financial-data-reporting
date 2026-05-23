CREATE OR REPLACE PROCEDURE BSP_SP_JS_201_HDACLHLDK(IS_DATE        IN VARCHAR2,
                                                    OI_RETCODE     OUT INTEGER,
                                                    OI_RETCODE_DEC OUT VARCHAR2) AS  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_201_HDACLHLDK
  -- 业务域: 贷款类
  -- 用途: 生成接口表 PBOCD_JS_201_HDACLHLDK  存量互联网存款信息表
  -- 输出接口表: PBOCD_JS_201_HDACLHLDK
  -- 参数
  --    IS_DATE 输入，传入跑批日期
  --    OI_RETCODE 输出，用来标识存储过程执行过程中是否出现异常
  -- 引用的监管集市表
  --    SMTMODS.L_ACCT_INTERNET_LOAN                       — 互联网贷款业务信息表
  --    SMTMODS.L_ACCT_LOAN                                — 贷款借据信息表
  --    SMTMODS.L_CUST_C                                   — 对公客户补充信息表
  --    SMTMODS.L_CUST_COOP_AGEN                           — 合作机构信息表
  --    SMTMODS.L_CUST_P                                   — 对私客户补充信息表
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  --VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
BEGIN
  VS_TEXT := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');

  -- 记录日志使用
  --SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'BSP_SP_JS_201_HDACLHLDK';

  --开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------
  --新建/清理分区
  SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_201_HDACLHLDK', OI_RETCODE);
  SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_201_HDBCLHLDK', OI_RETCODE);
  SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_201_HDCCLHLDK', OI_RETCODE);

  --插入存量互联网贷款数据 改动时需同步修改发生表
  INSERT INTO PBOCD_JS_201_HDACLHLDK
    (DATA_DATE, --数据日期
     ORG_CODE, --金融机构代码
     ORG_NUM, --内部机构号
     INT_LOAN_ID, --互联网贷款统一识别编码
     CONTRACT_CODE, --贷款合同编码
     LOAN_NUM, --贷款借据编码
     INT_LOAN_PRTFUN, --该笔互联网贷款各参与方职能
     INT_LOAN_CHA, --互联网贷款渠道性质
     INT_LOAN_IDND, --互联网贷款各参与方证件代码
     INT_LOAN_PRTID, --互联网贷款各参与方名称
     INT_LOAN_CONTR, --互联网贷款出资比例
     REPORT_ID, --ID
     CJRQ, --采集日期
     NBJGH, --内部机构号
     BIZ_LINE_ID, --业务条线ID
     VERIFY_STATUS, --校验状态
     BSCJRQ, --报送采集日期
     FRNBJGH, --法人内部机构号
     CUST_ID, --客户号
     CUST_NAME, --客户名
     LOAN_ACCT_BAL --贷款余额
     )
  
  --本方
    SELECT /*+PARALLEL(4)*/
     VS_TEXT AS DATA_DATE, --数据日期
     NVL(OB.ID_NO, OB.UP_ID_NO), --金融机构代码
     T.ORG_NUM, --内部机构号
     T.LOAN_NUM, --互联网贷款统一识别编码
     T.ACCT_NUM, --贷款合同编码
     T.LOAN_NUM, --贷款借据编码
     '2', --该笔互联网贷款各参与方职能
     'L02', --互联网贷款渠道性质
     '9122010170255776XN', --互联网贷款各参与方证件代码
     '吉林银行股份有限公司', --互联网贷款各参与方名称
     100 - (C.CONTRI_RATIO * 100), --互联网贷款出资比例 
     SYS_GUID() AS REPORT_ID, --ID
     IS_DATE AS CJRQ, --采集日期
     T.ORG_NUM AS NBJGH, --内部机构号
     '99' BIZ_LINE_ID, --业务条线ID
     NULL VERIFY_STATUS, --校验状态
     IS_DATE AS BSCJRQ, --报送采集日期
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
        '600000'
       ELSE
        '990000'
     END FRNBJGH, --法人内部机构号
     T.CUST_ID, --客户号
     P.CUST_NAM, --客户名
     T.LOAN_ACCT_BAL --贷款余额
      FROM SMTMODS.L_ACCT_LOAN T -- 借据表
     INNER JOIN SMTMODS.L_ACCT_INTERNET_LOAN T1 -- 互联网贷款业务信息表
        ON T.LOAN_NUM = T1.LOAN_NUM
       AND T1.DATA_DATE = IS_DATE
     INNER JOIN SMTMODS.L_CUST_COOP_AGEN C -- 合作机构信息表
        ON T1.COOP_CUST_ID = C.COOP_CUST_ID
       AND C.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_CUST_P P
        ON T.CUST_ID = P.CUST_ID
       AND P.DATA_DATE = IS_DATE
      LEFT JOIN L_PUBL_ORG_BRA_TMP OB --金数机构表
        ON OB.ORG_NUM = T.ORG_NUM
       AND OB.DATA_DATE = IS_DATE
     WHERE T.DATA_DATE = IS_DATE
       AND T.INTERNET_LOAN_FLG = 'Y'
       AND T.LOAN_ACCT_BAL > 0
     AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
    
    --合作方    
    UNION ALL
    SELECT /*+PARALLEL(4)*/
     VS_TEXT AS DATA_DATE, --数据日期
     NVL(OB.ID_NO, OB.UP_ID_NO), --金融机构代码
     T.ORG_NUM, --内部机构号
     T.LOAN_NUM, --互联网贷款统一识别编码
     T.ACCT_NUM, --贷款合同编码
     T.LOAN_NUM, --贷款借据编码
     '1', --该笔互联网贷款各参与方职能
     C.CHANNEL_NATURE, --互联网贷款渠道性质
     C.COOP_ID_NO, --互联网贷款各参与方证件代码
     C.COOP_CUST_NAM, --互联网贷款各参与方名称
     C.CONTRI_RATIO * 100, --互联网贷款出资比例
     SYS_GUID() AS REPORT_ID, --ID
     IS_DATE AS CJRQ, --采集日期
     T.ORG_NUM AS NBJGH, --内部机构号
     '99' BIZ_LINE_ID, --业务条线ID
     NULL VERIFY_STATUS, --校验状态
     IS_DATE AS BSCJRQ, --报送采集日期
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
        '600000'
       ELSE
        '990000'
     END FRNBJGH, --法人内部机构号
     T.CUST_ID, --客户号
     P.CUST_NAM, --客户名
     T.LOAN_ACCT_BAL --贷款余额
      FROM SMTMODS.L_ACCT_LOAN T -- 借据表
     INNER JOIN SMTMODS.L_ACCT_INTERNET_LOAN T1 -- 互联网贷款业务信息表
        ON T.LOAN_NUM = T1.LOAN_NUM
       AND T1.DATA_DATE = IS_DATE
     INNER JOIN SMTMODS.L_CUST_COOP_AGEN C -- 合作机构信息表
        ON T1.COOP_CUST_ID = C.COOP_CUST_ID
       AND C.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_CUST_P P
        ON T.CUST_ID = P.CUST_ID
       AND P.DATA_DATE = IS_DATE
      LEFT JOIN L_PUBL_ORG_BRA_TMP OB --金数机构表
        ON OB.ORG_NUM = T.ORG_NUM
       AND OB.DATA_DATE = IS_DATE
     WHERE T.DATA_DATE = IS_DATE
       AND T.INTERNET_LOAN_FLG = 'Y'
       AND T.LOAN_ACCT_BAL > 0
       AND T.LOAN_STOCKEN_DATE IS NULL  ;  --add by haorui 20250311 JLBA202408200012 资产未转让
  COMMIT;
  
------[2025-03-27] [周立鹏] [JLBA202502130004_制度升级2025][李楠] 拆分成单位和个人  开始-----------
  --插入存量互联网单位贷款数据 改动时需同步修改发生表
  INSERT INTO PBOCD_JS_201_HDBCLHLDK
    (DATA_DATE, --数据日期
     ORG_CODE, --金融机构代码
     ORG_NUM, --内部机构号
     INT_LOAN_ID, --互联网贷款统一识别编码
     CONTRACT_CODE, --贷款合同编码
     LOAN_NUM, --贷款借据编码
     INT_LOAN_PRTFUN, --该笔互联网贷款各参与方职能
     INT_LOAN_CHA, --互联网贷款渠道性质
     INT_LOAN_IDND, --互联网贷款各参与方证件代码
     INT_LOAN_PRTID, --互联网贷款各参与方名称
     INT_LOAN_CONTR, --互联网贷款出资比例
     REPORT_ID, --ID
     CJRQ, --采集日期
     NBJGH, --内部机构号
     BIZ_LINE_ID, --业务条线ID
     VERIFY_STATUS, --校验状态
     BSCJRQ, --报送采集日期
     FRNBJGH, --法人内部机构号
     CUST_ID, --客户号
     CUST_NAME, --客户名
     LOAN_ACCT_BAL --贷款余额
     )
    SELECT T.DATA_DATE, --数据日期
           T.ORG_CODE, --金融机构代码
           T.ORG_NUM, --内部机构号
           T.INT_LOAN_ID, --互联网贷款统一识别编码
           T.CONTRACT_CODE, --贷款合同编码
           T.LOAN_NUM, --贷款借据编码
           T.INT_LOAN_PRTFUN, --该笔互联网贷款各参与方职能
           T.INT_LOAN_CHA, --互联网贷款渠道性质
           T.INT_LOAN_IDND, --互联网贷款各参与方证件代码
           T.INT_LOAN_PRTID, --互联网贷款各参与方名称
           T.INT_LOAN_CONTR, --互联网贷款出资比例
           T.REPORT_ID, --ID
           T.CJRQ, --采集日期
           T.NBJGH, --内部机构号
           T.BIZ_LINE_ID, --业务条线ID
           T.VERIFY_STATUS, --校验状态
           T.BSCJRQ, --报送采集日期
           T.FRNBJGH, --法人内部机构号
           T.CUST_ID, --客户号
           T.CUST_NAME, --客户名
           T.LOAN_ACCT_BAL --贷款余额
      FROM PBOCD_JS_201_HDACLHLDK T
     INNER JOIN SMTMODS.L_CUST_C LC
        ON LC.DATA_DATE = IS_DATE
       AND T.CUST_ID = LC.CUST_ID
       AND LC.CUST_TYP <> '3' --去除个体工商户 
     WHERE T.CJRQ = IS_DATE;
  COMMIT;

  --插入存量互联网个人贷款数据 改动时需同步修改发生表
  INSERT INTO PBOCD_JS_201_HDCCLHLDK
    (DATA_DATE, --数据日期
     ORG_CODE, --金融机构代码
     ORG_NUM, --内部机构号
     INT_LOAN_ID, --互联网贷款统一识别编码
     CONTRACT_CODE, --贷款合同编码
     LOAN_NUM, --贷款借据编码
     INT_LOAN_PRTFUN, --该笔互联网贷款各参与方职能
     INT_LOAN_CHA, --互联网贷款渠道性质
     INT_LOAN_IDND, --互联网贷款各参与方证件代码
     INT_LOAN_PRTID, --互联网贷款各参与方名称
     INT_LOAN_CONTR, --互联网贷款出资比例
     REPORT_ID, --ID
     CJRQ, --采集日期
     NBJGH, --内部机构号
     BIZ_LINE_ID, --业务条线ID
     VERIFY_STATUS, --校验状态
     BSCJRQ, --报送采集日期
     FRNBJGH, --法人内部机构号
     CUST_ID, --客户号
     CUST_NAME, --客户名
     LOAN_ACCT_BAL --贷款余额
     )
    SELECT T.DATA_DATE, --数据日期
           T.ORG_CODE, --金融机构代码
           T.ORG_NUM, --内部机构号
           T.INT_LOAN_ID, --互联网贷款统一识别编码
           T.CONTRACT_CODE, --贷款合同编码
           T.LOAN_NUM, --贷款借据编码
           T.INT_LOAN_PRTFUN, --该笔互联网贷款各参与方职能
           T.INT_LOAN_CHA, --互联网贷款渠道性质
           T.INT_LOAN_IDND, --互联网贷款各参与方证件代码
           T.INT_LOAN_PRTID, --互联网贷款各参与方名称
           T.INT_LOAN_CONTR, --互联网贷款出资比例
           T.REPORT_ID, --ID
           T.CJRQ, --采集日期
           T.NBJGH, --内部机构号
           T.BIZ_LINE_ID, --业务条线ID
           T.VERIFY_STATUS, --校验状态
           T.BSCJRQ, --报送采集日期
           T.FRNBJGH, --法人内部机构号
           T.CUST_ID, --客户号
           T.CUST_NAME, --客户名
           T.LOAN_ACCT_BAL --贷款余额
      FROM PBOCD_JS_201_HDACLHLDK T
      LEFT JOIN SMTMODS.L_CUST_C LC
        ON LC.DATA_DATE = IS_DATE
       AND T.CUST_ID = LC.CUST_ID
       AND LC.CUST_TYP <> '3' --去除个体工商户 
     WHERE T.CJRQ = IS_DATE
       AND LC.CUST_ID IS NULL;
  COMMIT;
------[2025-03-27] [周立鹏] [JLBA202502130004_制度升级2025][李楠] 拆分成单位和个人  结束-----------
  
  -------------------------------------------------------------------------
  OI_RETCODE     := 0; --设置异常状态为0 成功状态
  OI_RETCODE_DEC := '执行成功';
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
    OI_RETCODE     := -1; --设置异常状态为-1
    OI_RETCODE_DEC := SQLCODE || ':' || SUBSTR(SQLERRM, 1, 50); --系统错误描述
    --插入日志表，记录错误
    SP_PBOCD_LOG(VS_PROCEDURE_NAME,
                 'ERROR',
                 VI_ERRORCODE,
                 VS_TEXT,
                 IS_DATE);
END;
/

