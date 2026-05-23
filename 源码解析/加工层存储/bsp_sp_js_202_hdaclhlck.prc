CREATE OR REPLACE PROCEDURE BSP_SP_JS_202_HDACLHLCK(IS_DATE        IN VARCHAR2,
                                                    OI_RETCODE     OUT INTEGER,
                                                    OI_RETCODE_DEC OUT VARCHAR2) AS  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_202_HDACLHLCK
  -- 业务域: 存款类
  -- 用途: 生成接口表 PBOCD_JS_202_HDACLHLCK  存量互联网存款信息表
  -- 输出接口表: PBOCD_JS_202_HDACLHLCK
  -- 参数
  --    IS_DATE 输入，传入跑批日期
  --    OI_RETCODE 输出，用来标识存储过程执行过程中是否出现异常
  -- 引用的监管集市表
  --    SMTMODS.L_ACCT_DEPOSIT                             — 存款账户信息表
  --    SMTMODS.L_ACCT_DEPOSIT_SUB                         — 存款账户介质关系表
  --    SMTMODS.L_CUST_P                                   — 对私客户补充信息表
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
BEGIN
  VS_TEXT := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');

  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'BSP_SP_JS_202_HDACLHLCK';

  --开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------
  --新建/清理分区
  SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_202_HDACLHLCK', OI_RETCODE);

  --插入存量互联网存款数据
  INSERT INTO PBOCD_DATACORE.PBOCD_JS_202_HDACLHLCK
    (DATA_DATE, --数据日期
     ORG_CODE, --金融机构代码
     ORG_NUM, --内部机构号
     DEP_ACC_CODE, --存款账户编码
     DEP_AGR_CODE, --存款协议代码
     INT_DEP_CHA, --互联网存款渠道性质
     INT_DEP_IDND, --互联网存款各参与方证件代码
     REPORT_ID, --ID
     CJRQ, --采集日期
     NBJGH, --内部机构号
     BIZ_LINE_ID, --业务条线ID
     VERIFY_STATUS, --校验状态
     BSCJRQ, --报送采集日期
     FRNBJGH, --法人内部机构号
     CUST_ID, --客户号
     CUST_NAME, --客户名
     ACCT_BALANCE --账户余额
     )
    SELECT /*+PARALLEL(4)*/
     VS_TEXT AS DATA_DATE, --数据日期
     NVL(OB.ID_NO, OB.UP_ID_NO), --金融机构代码
     T.ORG_NUM, --内部机构号
     T1.O_ACCT_NUM, --存款账户编码
     T1.O_ACCT_NUM, --存款协议代码
     DECODE(SUBSTR(T.TYPE_ID, 1, 8), '62313118', 'D01', '62313113', 'D03'), --互联网存款渠道性质
     DECODE(SUBSTR(T.TYPE_ID, 1, 8),
            '62313118',
            '9122010170255776XN',
            '62313113',
            '91220102MA176CR29P'), --互联网存款各参与方证件代码
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
     T1.ACCT_BALANCE --账户余额
      FROM SMTMODS.L_ACCT_DEPOSIT_SUB T
     INNER JOIN SMTMODS.L_ACCT_DEPOSIT T1
        ON T.ACCT_NUM = T1.ACCT_NUM
       AND T1.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_CUST_P P
        ON T.CUST_ID = P.CUST_ID
       AND P.DATA_DATE = IS_DATE
      LEFT JOIN L_PUBL_ORG_BRA_TMP OB --金数机构表
        ON OB.ORG_NUM = T.ORG_NUM
       AND OB.DATA_DATE = IS_DATE
     WHERE T.DATA_DATE = IS_DATE
       AND T.MEDIUM_STAT = 'A'
       AND SUBSTR(T.TYPE_ID, 1, 8) IN ('62313113', '62313118') -- 62313118-我行手机银行APP开立的账户；62313113-市民卡APP开立的账户
       AND T1.ACCT_BALANCE <> 0;

  COMMIT;
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

