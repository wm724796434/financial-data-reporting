CREATE OR REPLACE PROCEDURE BSP_SP_JS_201_ZHJZFS (IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_201_ZHJZFS
  -- 业务域: 贷款类
  -- 用途: 生成接口表 JS_201_ZHJZFS 单位贷款置换旧债发生额信息
  -- 参数
  --    IS_DATE 输入，传入跑批日期
  --    OI_RETCODE 输出，用来标识存储过程执行过程中是否出现异常
  -- 引用的监管集市表
  --    SMTMODS.L_ACCT_LOAN                                — 贷款借据信息表
  --    SMTMODS.L_CUST_C                                   — 对公客户补充信息表
  --    SMTMODS.L_CUST_P                                   — 对私客户补充信息表
  --    SMTMODS.L_PUBL_ORG_BRA                             — 机构表
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(100); --存储过程执行步骤标志
  NUM               INTEGER;
  VS_NMONTH         VARCHAR2(10);
BEGIN
  VS_TEXT := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_201_ZHJZFS';
  VS_NMONTH         := TO_CHAR(TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD') + 1),
                               'YYYYMMDD');
  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------



  VS_STEP := '1.插入数据';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
   --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'PBOCD_JS_201_ZHJZFS'
     AND PARTITION_NAME = 'PBOCD_JS_201_ZHJZFS_' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_DATACORE.PBOCD_JS_201_ZHJZFS ADD PARTITION PBOCD_JS_201_ZHJZFS_' ||
                      IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_DATACORE.PBOCD_JS_201_ZHJZFS TRUNCATE PARTITION PBOCD_JS_201_ZHJZFS_' ||
                    IS_DATE;

  INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_ZHJZFS
  (DATA_DATE, --数据日期
   ORG_CODE, --金融机构代码
   CUST_ID_TYPE, --借款人证件类型
   CUST_ID_NO, --借款人证件代码
   CONTRACT_CODE, --贷款合同编码
   LOAN_NUM, --贷款借据编码
   CURR_CODE, --币种
   TRANS_AMT_RMB, --贷款发生金额折人民币
   INT_RATE, --利率水平
   SERIAL_NO, --交易流水号
   DIS_DEBT_TYPE, --被置换债务类型
   CRE_ID_TYPE, --被置债务债权人证件类型
   CRE_ID_NO, --被置债务债权人证件代码
   LGOVFIN_FLG, --是否置换地方政府融资平台债务
   DIS_DEBT_NO, --被置换债务凭证编码
   DIS_DEBT_CURR, --被置换债务币种
   DIS_DEBT_AMT_RMB, --被置换债务折人民币
   ORG_NUM, --内部机构号
   REPORT_ID, --ID
   CJRQ, --采集日期
   NBJGH, --内部机构号
   BIZ_LINE_ID, --业务条线ID
   VERIFY_STATUS, --校验状态
   BSCJRQ, --报送采集日期
   FRNBJGH, --法人内部机构号
   DIS_DEBT_INT_RATE --被置换债务利率水平
   )
  SELECT TO_CHAR(TO_DATE(IS_DATE,'YYYY-MM-DD'), 'YYYY-MM-DD') DATA_DATE,
         C.ID_NO ORG_CODE, --金融机构代码
         CASE
           WHEN B.ID_TYPE = '236' AND LENGTH(B.ID_NO) = 18 THEN
            'A01'
           WHEN B.ORGANIZATIONCODE IS NOT NULL AND
                LENGTH(REPLACE(B.ORGANIZATIONCODE, '-', '')) = 9 THEN
            'A02'
           ELSE
            'A03'
         END CUST_ID_TYPE, --借款人证件类型
         CASE
           WHEN B.ID_TYPE = '236' AND LENGTH(B.ID_NO) = 18 THEN
            UPPER(B.ID_NO)
           WHEN B.ORGANIZATIONCODE IS NOT NULL AND
                LENGTH(REPLACE(B.ORGANIZATIONCODE, '-', '')) = 9 THEN
            REPLACE(B.ORGANIZATIONCODE, '-', '')
           ELSE
            B.ID_NO
         END AS CUST_ID_NO, --借款人证件代码
         A.ACCT_NUM CONTRACT_CODE, --贷款合同编码
         A.LOAN_NUM LOAN_NUM, --贷款借据编码
         A.CURR_CD CURR_CODE, --币种
         A.DRAWDOWN_AMT TRANS_AMT_RMB, --贷款发生金额折人民币
         A.REAL_INT_RAT INT_RATE, --利率水平
         SYS_GUID() SERIAL_NO, --交易流水号
         '01' DIS_DEBT_TYPE, --被置换债务类型 01-本行贷款 02-他行贷款 03-债券 04-其他债务
/*         CASE
           WHEN B2.CUST_ID IS NOT NULL THEN
            CASE
              WHEN B2.ID_TYPE = '236' AND LENGTH(B2.ID_NO) = 18 THEN
               'A01'
              WHEN B.ORGANIZATIONCODE IS NOT NULL AND
                LENGTH(REPLACE(B.ORGANIZATIONCODE, '-', '')) = 9 THEN
               'A02'
              ELSE
               'A03'
            END
           WHEN B3.CUST_ID IS NOT NULL THEN
            D1.PBOCD_CODE
         END CRE_ID_TYPE, --被置换债务债权人证件类型
         CASE
           WHEN B2.CUST_ID IS NOT NULL THEN
            CASE
              WHEN B2.ID_TYPE = '236' AND LENGTH(B2.ID_NO) = 18 THEN
               UPPER(B2.ID_NO)
              WHEN B2.ORGANIZATIONCODE IS NOT NULL AND
                   LENGTH(REPLACE(B2.ORGANIZATIONCODE, '-', '')) = 9 THEN
               REPLACE(B2.ORGANIZATIONCODE, '-', '')
              ELSE
               B2.ID_NO
            END
           WHEN B3.CUST_ID IS NOT NULL THEN
            B3.ID_NO
         END AS CRE_ID_NO, --被置换债务债权人证件代码*/
         'A01' AS CRE_ID_TYPE, --被置换债务债权人证件类型 --zhoulp20240410 需求JLBA202401240008
         CASE 
             WHEN A.ORG_NUM LIKE '51%' THEN '912202016601010854'
             WHEN A.ORG_NUM LIKE '52%' THEN '91321000564261222Q'
             WHEN A.ORG_NUM LIKE '53%' THEN '91220201584622304Y'
             WHEN A.ORG_NUM LIKE '54%' THEN '91220101586213344F'
             WHEN A.ORG_NUM LIKE '55%' THEN '911309005881693407'
             WHEN A.ORG_NUM LIKE '56%' THEN '91131000589668889D'
             WHEN A.ORG_NUM LIKE '57%' THEN '91222404584629733N'
             WHEN A.ORG_NUM LIKE '58%' THEN '912203005846084148'
             WHEN A.ORG_NUM LIKE '59%' THEN '91220421660100250Y'
             WHEN A.ORG_NUM LIKE '60%' THEN '912202015846358186'
             ELSE '9122010170255776XN' 
         END AS CRE_ID_NO, --被置换债务债权人证件代码 --zhoulp20240410 需求JLBA202401240008
         
         '0' LGOVFIN_FLG, --是否置换地方政府融资平台债务
         A.LOAN_NUM_OLD DIS_DEBT_NO, --被置换债务凭证编码
         A1.CURR_CD DIS_DEBT_CURR, --被置换债务币种
         A.DRAWDOWN_AMT DIS_DEBT_AMT_RMB, --被置换债务金额折人民币
         A.ORG_NUM, --非报送字段
         SYS_GUID() AS REPORT_ID,
         IS_DATE AS CJRQ,
         A.ORG_NUM AS NBJGH,
         '99' AS BIZ_LINE_ID, --业务条线ID
         '' AS VERIFY_STATUS, --校验状态
         '' AS BSCJRQ, --报送采集日期
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
           ELSE
            '990000'
         END FRNBJGH, --法人内部机构号
         A1.REAL_INT_RAT AS DIS_DEBT_INT_RATE --被置换债务利率水平
    FROM SMTMODS.L_ACCT_LOAN A --贷款借据表
   INNER JOIN SMTMODS.L_CUST_C B --对公客户补充信息表
      ON A.CUST_ID = B.CUST_ID
     AND B.DATA_DATE = IS_DATE
     AND B.CUST_TYP <> '3' --去除个体工商户
    LEFT JOIN SMTMODS.L_PUBL_ORG_BRA C --机构表
      ON A.ORG_NUM = C.ORG_NUM
     AND C.DATA_DATE = IS_DATE
    LEFT JOIN SMTMODS.L_ACCT_LOAN A1 --贷款借据信息表（获取上笔借据号信息）
      ON A.LOAN_NUM_OLD = A1.LOAN_NUM
     AND A1.DATA_DATE = IS_DATE
    LEFT JOIN SMTMODS.L_CUST_C B2 --对公客户补充信息表
      ON A1.CUST_ID = B2.CUST_ID
     AND B2.DATA_DATE = IS_DATE
    LEFT JOIN SMTMODS.L_CUST_P B3 --对私客户补充信息表
      ON A1.CUST_ID = B3.CUST_ID
     AND B3.DATA_DATE = IS_DATE
    LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY D1
      ON B3.ID_TYPE = D1.L_CODE
     AND D1.CODE_CLMN_NAME = 'ID_TYPE' --证件类型
   WHERE A.DATA_DATE = IS_DATE
     AND A.CANCEL_FLG = 'N' --核销标志
     AND A.REPAY_FLG = 'Y' --借新还旧标志
     AND A.LOAN_ACCT_BAL <> 0
     AND TRUNC(A.DRAWDOWN_DT, 'MM') =
         TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD'), 'MM')
   AND A.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
     ;
     COMMIT;

     SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

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
/

