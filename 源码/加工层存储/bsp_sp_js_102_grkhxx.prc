CREATE OR REPLACE PROCEDURE BSP_SP_JS_102_GRKHXX(IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  --    SP_JS_102_GRKHXX
  -- 用途:生成接口表  JS_102_GRKHXX  个人客户信息表
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    CAEATE BY USER AT 20200819
  --    MOD BY LIUD AT 20200824
  --    MOD BY DW AT 20220728
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段 上线日期：2025-05-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  --    需求编号：JLBA202505120009_关于修改金数系统与大集中系统单一客户授信逻辑的需求 上线日期：2025-05-27，修改人：周立鹏，提出人：李楠   修改原因：金数和大集中统一授信额度
  --    需求编号：JLBA202504160004_关于吉林银行修改单一客户授信逻辑的需求(从需求) 上线日期：2025-07-08，修改人：周立鹏，提出人：   修改原因：统一授信额度
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_四阶段 上线日期：2025-09-18，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  --    需求编号：JLBA202507300010关于新一代信贷管理系统新增线上微贷板块的需求 上线日期：2025-09-18，修改人：周立鹏，提出人：从需求   修改原因：NGI系统新增吉惠贷数据
  --    需求编号：无 上线日期：2025-12-03，修改人：周立鹏，提出人：李楠   修改原因：调整证件类型、证件代码、担保方式取数逻辑，剔除取上期/配置表
  --    需求编号：JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段 上线日期：2025-12-30，修改人：周立鹏，提出人：李楠   修改原因：剔除特殊处理
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(100) DEFAULT NULL; --字符型  过程描述
  VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
  --NUM               INTEGER;
  --VS_NMONTH         VARCHAR2(10);
  V_DATA_MONTH      VARCHAR2(6);
BEGIN
  VS_TEXT      := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');
  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_102_GRKHXX';
  --VS_NMONTH         := TO_CHAR(TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD') + 1),
  --                             'YYYYMMDD');
  --程序自用变量赋值
  V_DATA_MONTH := substr(is_date,0,6);

  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------

  --历史移植数据
  EXECUTE IMMEDIATE 'TRUNCATE TABLE  JS_102_GRKHXX_TEMP01';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE  JS_102_GRKHXX_TEMP02';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE  JS_102_GRKHXX_TEMP03';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE  JS_102_GRKHXX_TEMP05';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE  JS_102_GRKHXX_TEMP08';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE  JS_102_GRKHXX_TEMP09';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE  JS_102_GRKHXX_TEMP10';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE  L_CUST_P_NEW';

  --把个体工商户加工到新的L_CUST_P中
  INSERT  INTO L_CUST_P_NEW (
     DATA_DATE
    ,ORG_NUM
    ,CUST_ID
    ,CUST_NAM
    ,BIRTH_DT
    ,ID_NO
    ,SEX_TYP
    ,ID_TYPE
    ,REGION_CD
    ,INCOME_YEAR
    ,INCOME
    ,OPERATE_CUST_TYPE
    ,CITY_VILLAGE_FLG
    ,NATION_CD
    ,MARRIAGE_TYP
    ,CUST_NATION
    ,EDUCATION_CD
    ,LEGAL_CARD_TYPE
    ,LEGAL_CARD_NO
    ,CUST_TYP
    ,ZRRPD
    --,COUNTY_REGION_CD
  )

  SELECT /*+parallel(4)*/  T.DATA_DATE,  --数据日期
           T.ORG_NUM,    --机构号
           T.CUST_ID,    --客户号
           T.CUST_NAM,   --客户名
           T.BIRTH_DT,   --出生日期
           T.ID_NO,      --证件号
           T.SEX_TYP,    --性别
           T.ID_TYPE,    --证件类型
           T.REGION_CD,  --注册地行政区划
           T.INCOME_YEAR,     --个人年收入
           T.INCOME,          --家庭月均收入
           T.OPERATE_CUST_TYPE, --客户类型
           T.CITY_VILLAGE_FLG,  --农户标志
           NVL(T.NATION_CD,ORG_AREA),  --国家代码
           T.MARRIAGE_TYP,  --婚姻状况
           T.CUST_NATION,  --民族
           T.EDUCATION_CD,  --最高学历
           NULL,  --对公客户法定代表人身份证件类型
           NULL,  --对公客户法定代表人身份证件号码
           NULL,  --客户类型
           1 --自然人与非自然人机构判断
  FROM SMTMODS.L_CUST_P T
  WHERE T.DATA_DATE = IS_DATE
  UNION ALL
  SELECT T.DATA_DATE,  --数据日期
           T.ORG_NUM,    --机构号
           T.CUST_ID,    --客户号
           T.CUST_NAM,   --客户名
           NULL,         --出生日期
           T.ID_NO,      --证件号
           NULL,         --性别
           T.ID_TYPE,  --证件类型
           NVL(T.REGION_CD,ORG_AREA), --注册地行政区划
           NULL,        --个人年收入
           NULL,        --家庭月均收入
           'A',         --客户类型
           T.CITY_VILLAGE_FLG,  --农户标志
           T.NATION_CD,  --国家代码
           NULL,  --婚姻状况
           NULL,  --民族
           NULL,  --最高学历
           LEGAL_CARD_TYPE,  --对公客户法定代表人身份证件类型
           LEGAL_CARD_NO,  --对公客户法定代表人身份证件号码
           CUST_TYP,  --客户类型
           2--自然人与非自然人机构判断
  FROM SMTMODS.L_CUST_C T
  WHERE T.DATA_DATE = IS_DATE
  AND T.CUST_TYP = '3';

  --个体工商户营业执照代码、小微企业社会信用代码
  INSERT INTO JS_102_GRKHXX_TEMP01
  --个人名的个体工商户及小微企业主
  SELECT  /*+parallel(4)*/
         B.CUST_ID,
         B.OPERATE_CUST_TYPE,
         CASE WHEN B.OPERATE_CUST_TYPE = 'B' AND ID_TYPE = '236'  AND LENGTH(B.ID_NO ) = 18 THEN B.ID_NO  -- ID_TYPE码值见模型文档 代码编号C0001  236为统一社会信用代码
              WHEN B.OPERATE_CUST_TYPE = 'C' AND LENGTH(B.ID_NO ) = 18 THEN B.ID_NO
        ELSE '' END TYSHXYDMS    --MODIFY BY DW(20220728) 增加证件号长度限制
  FROM SMTMODS.L_CUST_P B
  WHERE B.DATA_DATE = IS_DATE
  AND B.OPERATE_CUST_TYPE IN ('A', 'B') --个人名的个体工商户及小微企业主
  UNION ALL
  --对公名的个体工商户
  SELECT
         C.CUST_ID,
         C.CUST_TYP,
         CASE WHEN C.TYSHXYDM IS NOT NULL AND LENGTH(C.TYSHXYDM ) = 18 THEN C.TYSHXYDM  END TYSHXYDMS  --MODIFY BY DW(20220728)直取社会统一信用码
  FROM SMTMODS.L_CUST_C C
  WHERE C.DATA_DATE = IS_DATE
  AND C.CUST_TYP = '3'   --对公名的个体工商户
  ;
  COMMIT; ----2022.1.18--夏文博 修改

  --历史移植及核销数据
  INSERT INTO JS_102_GRKHXX_TEMP03
  SELECT /*+parallel(4)*/  T.CUST_ID, COUNT(1) BS, SUM(T.DRAWDOWN_AMT), SUM(T.LOAN_ACCT_BAL)
  FROM SMTMODS.L_ACCT_LOAN T
  LEFT JOIN SMTMODS.L_ACCT_WRITE_OFF XX
   ON T.LOAN_NUM = XX.LOAN_NUM
       AND XX.DATA_DATE = IS_DATE
     AND SUBSTR(TO_CHAR(XX.WRITE_OFF_DATE,'yyyymmdd'),1,6)=SUBSTR(IS_DATE,1,6)
  WHERE T.DATA_DATE = IS_DATE
  AND T.CANCEL_FLG = 'Y' --去掉核销数据
  AND XX.LOAN_NUM IS NULL
  AND T.CUST_ID NOT IN (
      SELECT T1.CUST_ID
      FROM SMTMODS.L_ACCT_LOAN T1
      WHERE T1.DATA_DATE = IS_DATE --去掉既有核销贷款又有未核销贷款客户
    AND T1.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
      AND T1.CANCEL_FLG = 'N')
  GROUP BY T.CUST_ID;
  COMMIT;

  INSERT INTO JS_102_GRKHXX_TEMP05
  --存量贷款
  with a as (
       SELECT /*+parallel(4)*/  T.CUST_ID, SUM(LOAN_ACCT_BAL)
       FROM SMTMODS.L_ACCT_LOAN T
       WHERE T.DATA_DATE = is_date
       --AND (T.ITEM_CD LIKE '12201%' OR T.ITEM_CD LIKE '12203%' OR
       AND (T.ITEM_CD LIKE '130301%' OR T.ITEM_CD LIKE '130303%' OR
            --T.ITEM_CD = '1220201' OR T.ITEM_CD = '13201')
            T.ITEM_CD = '13030201' OR T.ITEM_CD = '13030203' OR T.ITEM_CD = '13050101')--2022924 夏文博

       GROUP BY T.CUST_ID
    HAVING SUM(LOAN_ACCT_BAL) > 0
  ),
  --本月发放收回贷款
  b as (
       --本月新发放贷款
       SELECT /*+parallel(4)*/  A.CUST_ID
       FROM SMTMODS.L_ACCT_LOAN A
       INNER JOIN L_CUST_P_NEW B
       ON A.CUST_ID = B.CUST_ID

       WHERE (SUBSTR(TO_CHAR(A.DRAWDOWN_DT, 'YYYYMMDD'), 0, 6) = V_DATA_MONTH OR
            --[2025-09-18] [周立鹏] [JLBA202507300010关于新一代信贷管理系统新增线上微贷板块的需求][从需求] 新增产品'DK001000100041'
            --(A.INTERNET_LOAN_FLG = 'Y' AND
            ((A.INTERNET_LOAN_FLG = 'Y' OR A.CP_ID = 'DK001000100041' ) AND
           A.DRAWDOWN_DT = (TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD'), 'MM') - 1)) --modify by 87v : 互联网贷款数据晚一天下发，上月末数据当月取
       )
         AND A.DATA_DATE = IS_DATE
       --AND (A.ITEM_CD LIKE '12201%' OR A.ITEM_CD LIKE '12203%' OR A.ITEM_CD = '1220201' OR A.ITEM_CD = '13201')
       AND (A.ITEM_CD LIKE '130301%' OR A.ITEM_CD LIKE '130303%' OR A.ITEM_CD = '13030201'  OR A.ITEM_CD = '13030203'  OR A.ITEM_CD = '13050101')
   --2022924 夏文博
       GROUP BY A.CUST_ID
       UNION
       --本月收回贷款
       SELECT C.CUST_ID
       FROM SMTMODS.L_TRAN_LOAN_PAYM A
       INNER JOIN SMTMODS.L_ACCT_LOAN B
       ON A.LOAN_NUM = B.LOAN_NUM
       AND B.DATA_DATE = is_date
       INNER JOIN L_CUST_P_NEW C
       ON B.CUST_ID = C.CUST_ID

       WHERE (SUBSTR(TO_CHAR(A.REPAY_DT, 'YYYYMMDD'), 0, 6) = V_DATA_MONTH OR
       --[2025-09-18] [周立鹏] [JLBA202507300010关于新一代信贷管理系统新增线上微贷板块的需求][从需求] 新增产品'DK001000100041'
       --      (B.INTERNET_LOAN_FLG = 'Y' AND
             ((B.INTERNET_LOAN_FLG = 'Y' OR B.CP_ID = 'DK001000100041' ) AND
             A.REPAY_DT = (TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD'), 'MM') - 1)) --modify by 87v : 互联网贷款数据晚一天下发，上月末数据当月取
             )
       GROUP BY C.CUST_ID)
  SELECT A.CUST_ID ,'2' KK FROM A A
  UNION
  SELECT B.CUST_ID ,'3' KK FROM B B
  WHERE NOT EXISTS (SELECT 1 FROM A A WHERE A.CUST_ID = B.CUST_ID)  ;
  COMMIT;

/*  --查看落地表是否已经建立分区
  SELECT COUNT(1) INTO NUM
  FROM USER_TAB_PARTITIONS
  WHERE TABLE_NAME = 'JS_102_GRKHXX'
  AND PARTITION_NAME = 'P' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE JS_102_GRKHXX ADD PARTITION P' ||
                      IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;*/

  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_102_GRKHXX';

  --落地表，包含吉林银行+磐石数据
  INSERT /*+ APPEND*/ INTO JS_102_GRKHXX NOLOGGING(
     DATA_DATE, --1 数据日期
     ORG_CODE, --2 金融机构代码
     CUST_ID_TYPE, --3 客户证件类型
     CUST_ID_NO, --4 客户证件代码
     COUNTRY_CODE, --5 国籍
     NATIONALITY, --6 民族
     SEX_TYP, --7 性别
     EDUCATION_CD, --8 最高学历
     BIRTH_DT, --9 出生日期
     REG_REGION_CODE, --10地区代码
     PER_INCOME_YEAR, --11个人年收入
     FAMILY_INCOME_YEAR, --12家庭年收入
     MARRIAGE_TYP, --13婚姻情况
     RELATED_FLG, --14是否关联方
     FACILITY_AMT, --15授信额度
     USED_FACILITY_AMT, --16已用额度
     CUST_TYPE, --17个人客户身份标识
     BUSI_LICENSE, --18个体工商户营业执照代码
     SOCIAL_CREDIT_CODE, --19小微企业社会信用代码
     CREDIT_RATE_NUM, --20客户信用级别总等级数
     CREDIT_RATING, --21客户信用级别
     REPORT_ID, --22
     CJRQ, --23
     NBJGH, --24内部机构号
     BIZ_LINE_ID, --25
     VERIFY_STATUS, --26
     BSCJRQ, --27
     FRNBJGH, --28法人内部机构号
     CUST_ID, --29客户号
     HOSTINGMANAGER, --30主办客户经理
     HOSTINGMANAGER_NAME, --31主办客户经理名称
     HOSTINGMANAGER_APP, --32主办客户经理条线
     CUST_NAME)
  SELECT /*+ USE_HASH(T,T5,T2,T1,D1,D2,D3,D4,D5,D6,OFF,GLF) parallel(4)*/
     IS_DATE DATA_DATE, --1 数据日期
     '' /*OFF.JRJGBM*/ ORG_CODE, --2 金融机构代码
     D1.PBOCD_CODE CUST_ID_TYPE, --3 客户证件类型
     CASE WHEN T.CUST_TYP = '3' THEN NVL(T.LEGAL_CARD_NO,T.ID_NO) ELSE T.ID_NO END CUST_ID_NO, --4 客户证件代码，如果是个体工商户，取法人证件号
     D2.PBOCD_CODE COUNTRY_CODE, --5 国籍
     D4.PBOCD_CODE NATIONALITY, --6 民族
     --  D6.PBOCD_CODE SEX_TYP , --7 性别
     CASE
       WHEN T.SEX_TYP IS NOT NULL THEN D6.PBOCD_CODE
       WHEN T.LEGAL_CARD_TYPE IN ('101', '102', '10') AND LENGTH(T.LEGAL_CARD_NO) = 18 THEN DECODE(MOD(SUBSTR(T.LEGAL_CARD_NO, -2, 1), 2), '0', '02', '1', '01')
       WHEN T.LEGAL_CARD_TYPE IN ('101', '102', '10') AND LENGTH(T.LEGAL_CARD_NO) = 15 THEN DECODE(MOD(SUBSTR(T.LEGAL_CARD_NO, -1, 1), 2), '0', '02', '1', '01')
     END AS SEX_TYP, --7 性别
     CASE WHEN D5.PBOCD_CODE = '90' THEN NULL ELSE D5.PBOCD_CODE END AS EDUCATION_CD, --8 最高学历 ALTER BY WJB 20211116 修改学历码值90默认赋空值
     CASE WHEN T.BIRTH_DT IS NOT NULL AND ZRRPD = '1' THEN TO_CHAR(T.BIRTH_DT, 'YYYY-MM-DD')
          WHEN T.BIRTH_DT IS NULL AND ZRRPD = '2' AND LEGAL_CARD_NO IS NOT NULL
            THEN SUBSTR(T.LEGAL_CARD_NO, 7, 4) || '-' || SUBSTR(T.LEGAL_CARD_NO, 11, 2) || '-' || SUBSTR(T.LEGAL_CARD_NO, 13, 2)
          WHEN T.BIRTH_DT IS NULL AND ZRRPD = '1'
            THEN SUBSTR(T.ID_NO, 7, 4) || '-' || SUBSTR(T.ID_NO, 11, 2) || '-' || SUBSTR(T.ID_NO, 13, 2)
     END, --9 出生日期 WXY20211203-----------LEGAL_CARD_NO----法人证件号码
     
     --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
     --REPLACE(T.REGION_CD, '待处理', ''), --10地区代码
     CASE WHEN LENGTH(TRIM(T.REGION_CD)) = 6 AND T.REGION_CD NOT LIKE '000%' AND T.REGION_CD <> '999999' THEN TRIM(T.REGION_CD)--客户所属地区
          WHEN T.CUST_TYP = '3' AND LENGTH(T.LEGAL_CARD_NO)=18 AND SUBSTR(T.LEGAL_CARD_NO,7,8) BETWEEN '19000101' AND '21001231' THEN SUBSTR(T.LEGAL_CARD_NO,1,6)--法人身份证号前6位
          WHEN LENGTH(T.ID_NO)=18 AND SUBSTR(T.ID_NO,7,8) BETWEEN '19000101' AND '21001231' THEN SUBSTR(T.ID_NO,1,6)--身份证号前6位
          WHEN LENGTH(TRIM(OB1.REGION_CD)) = 6 AND OB1.REGION_CD NOT LIKE '000%' AND OB1.REGION_CD <> '999999' THEN TRIM(OB1.REGION_CD)--客户所属机构地区
     END AS REG_REGION_CODE, --10地区代码
     
     --DECODE(T.INCOME_YEAR,'9999999','',T.INCOME_YEAR) , --11个人年收入
     --T.INCOME * 12 AS FAMILY_INCOME_YEAR, --家庭年收入--T.FAMILY_INCOME_YEAR, --12家庭年收入-2022.1.19 夏文博修改
     --如果个人年收入是9999999或者是个人年收入小于1000或者个人年收入大于10000000时，个人年收入置空，否则正常取个人年收入
     CASE WHEN T.INCOME_YEAR = '9999999' THEN NULL ELSE
       CASE WHEN  T.INCOME_YEAR <1000 OR T.INCOME_YEAR >10000000 THEN NULL ELSE T.INCOME_YEAR END
     END PER_INCOME_YEAR,--MODIFY BY DW(20220728) 个人年收入
     -- CAST(ROUND(T.INCOME * 12,0) AS NUMBER(16,2)) AS FAMILY_INCOME_YEAR, --家庭年收入
     --DECODE(T.INCOME,'9999999','',CAST(ROUND(T.INCOME * 12,0) AS NUMBER(16,2)))AS FAMILY_INCOME_YEAR,
     --如果家庭月均收入是9999999或者是家庭年收入小于1000或者家庭年收入大于10000000时，家庭年收入置空，否则正常取家庭年收入
     CASE WHEN T.INCOME = '9999999' THEN NULL ELSE
       CASE WHEN CAST(ROUND(T.INCOME * 12,0) AS NUMBER(16,2)) <1000 OR CAST(ROUND(T.INCOME * 12,0) AS NUMBER(16,2)) >10000000 THEN NULL
         ELSE CAST(ROUND(T.INCOME * 12,0) AS NUMBER(16,2)) END
     END FAMILY_INCOME_YEAR, --MODIFY BY DW(20220728)
     D3.PBOCD_CODE AS MARRIAGE_TYP, --13婚姻情况
     CASE WHEN GLF.ID_CARD IS NOT NULL THEN '1' ELSE '0' END RELATED_FLG, --14是否关联方  MOD BY YANLINGBO AT 20201228  ??????????????????????
     --[2025-07-08] [周立鹏] [JLBA202504160004_关于吉林银行修改单一客户授信逻辑的需求(从需求)][] 统一授信额度
     NVL(T2.FACILITY_AMT,0), --15 授信额度
     NVL(T2.USED_FACILITY_AMT,0), --16已用额度
     CASE
       WHEN T.OPERATE_CUST_TYPE = 'A' THEN
        '2' --个体工商户
       WHEN T.OPERATE_CUST_TYPE = 'B' THEN
        '3' --小微企业主
       --WHEN T.CITY_VILLAGE_FLG IS NOT NULL THEN
       WHEN T.CITY_VILLAGE_FLG = 'Y' THEN
        '1' --农户
       ELSE
        '9' --其他
     END CUST_TYPE, --17个人客户身份标识
     CASE WHEN T1.KHFL IN ('3', 'A') THEN T1.TYSHXYDMS END BUSI_LICENSE, --18个体工商户营业执照代码
     CASE WHEN T1.KHFL = 'B' THEN T1.TYSHXYDMS END SOCIAL_CREDIT_CODE, --19小微企业社会信用代码
     A.CREDIT_RANK_TYPE AS CREDIT_RATE_NUM, --T.CREDIT_RATE_NUM, --20客户信用级别总等级数-2022.1.19 夏文博修改
     A.CREDIT_RANK AS CREDIT_RATING, --T.CREDIT_RATING, --21客户信用级别---2022.1.19 夏文博修改
     SYS_GUID() REPORT_ID, --22
     IS_DATE CJRQ, --23
     CASE WHEN T.ORG_NUM = '090907' THEN '090906'
          WHEN T.ORG_NUM = '050101' THEN '050301'
     ELSE T.ORG_NUM END NBJGH, --24内部机构号
     NULL BIZ_LINE_ID, --25
     NULL VERIFY_STATUS, --26
     NULL BSCJRQ, --27
     --'000000' FRNBJGH, --28法人内部机构号
/*     CASE WHEN T.ORG_NUM LIKE '5100%' THEN '510000' ELSE '990000' END FRNBJGH,*/
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
     T.CUST_ID, --29客户号
     '' HOSTINGMANAGER, --30主办客户经理
     '' HOSTINGMANAGER_NAME, --31主办客户经理名称
     '' HOSTINGMANAGER_APP, --32主办客户经理条线
     T.CUST_NAM CUST_NAME --33客户名称
  FROM L_CUST_P_NEW T --包含个体工商户的对私客户表
  INNER JOIN JS_102_GRKHXX_TEMP05 T5 --客户的取数范围
  ON T.CUST_ID = T5.CUST_ID
  INNER JOIN SMTMODS.L_CUST_ALL A --全量客户信息
  ON T.CUST_ID = A.CUST_ID
  AND A.DATA_DATE = IS_DATE
  LEFT JOIN (
  SELECT T.CUST_ID,SUM(NVL(T.FACILITY_AMT,0)) FACILITY_AMT,SUM(NVL(T.USED_FACILITY_AMT,0)) USED_FACILITY_AMT FROM SMTMODS.L_AGRE_CREDITLINE T
      WHERE T.DATA_DATE = IS_DATE AND T.FACILITY_STS = 'Y' GROUP BY T.CUST_ID
  ) T2 --个人客户授信信息
  ON T.CUST_ID = T2.CUST_ID
  LEFT JOIN JS_102_GRKHXX_TEMP01 T1 --个体工商户营业执照代码、小微企业社会信用代码
  ON T.CUST_ID = T1.CUSTID
  LEFT JOIN L_CODE_DICTIONARY D1
  ON NVL(T.LEGAL_CARD_TYPE, T.ID_TYPE) = D1.L_CODE
  AND D1.CODE_CLMN_NAME = 'ID_TYPE' --证件类型
  LEFT JOIN L_CODE_DICTIONARY  D2
  ON T.NATION_CD = D2.L_CODE
  AND D2.CODE_CLMN_NAME = 'NATION_CD' --国家代码转换2位
  LEFT JOIN L_CODE_DICTIONARY  D3
  ON T.MARRIAGE_TYP = D3.L_CODE
  AND D3.CODE_CLMN_NAME = 'MARRIAGE_TYP' --婚姻情况
  LEFT JOIN L_CODE_DICTIONARY  D4
  ON T.CUST_NATION = D4.L_CODE
  AND D4.CODE_CLMN_NAME = 'CUST_NATION' --民族
  LEFT JOIN L_CODE_DICTIONARY  D5
  ON TRIM(T.EDUCATION_CD) = D5.L_CODE
  AND D5.CODE_CLMN_NAME = 'EDUCATION_CD' --最高学历
  LEFT JOIN L_CODE_DICTIONARY D6
  ON T.SEX_TYP = D6.L_CODE
  AND D6.CODE_CLMN_NAME = 'SEX_TYP' --性别
  LEFT JOIN (SELECT DISTINCT ID_CARD FROM TMP_JS_102_GRKHXX_GLF) GLF --关联方
  -- ON T.CUST_ID = GLF.ID_CARD
  ON T.ID_NO = GLF.ID_CARD
  
  --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
  LEFT JOIN L_PUBL_ORG_BRA_TMP OB1--金数机构表
  ON OB1.ORG_NUM=T.ORG_NUM AND OB1.DATA_DATE=IS_DATE
  
  WHERE T.DATA_DATE = IS_DATE
  AND NOT EXISTS (
      SELECT 1
      FROM JS_102_GRKHXX_TEMP03 TEMP3
      WHERE T.CUST_ID = TEMP3.CUST_ID);
  COMMIT;


  --获取客户最后一笔贷款发放时间
  INSERT INTO JS_102_GRKHXX_TEMP08 NOLOGGING
  SELECT /*+ USE_HASH(A,B) parallel(4)*/
     A.CUST_ID, MAX(B.DRAWDOWN_DT)
  FROM JS_102_GRKHXX A
  LEFT JOIN SMTMODS.L_ACCT_LOAN B
  ON A.CUST_ID = B.CUST_ID
  AND B.DATA_DATE = IS_DATE
  AND B.DEPARTMENTD IN ('德惠长银', '普惠金融', '个人信贷', '磐石村镇')
  WHERE TRIM(A.DATA_DATE) = IS_DATE
  GROUP BY A.CUST_ID;
  COMMIT;

  INSERT INTO JS_102_GRKHXX_TEMP10
  SELECT DISTINCT CUST_ID, DRAWDOWN_DT, DEPARTMENTD
  FROM SMTMODS.L_ACCT_LOAN
  WHERE DATA_DATE = IS_DATE
  AND DEPARTMENTD IN ('德惠长银', '普惠金融', '个人信贷', '磐石村镇');
  -- AND ACCT_TYP <> '90';
  COMMIT;

  --获取客户最后一笔贷款业务条线
  INSERT INTO JS_102_GRKHXX_TEMP09 NOLOGGING
  SELECT /*+parallel(4)*/
   DISTINCT A.CUST_ID,
             CASE
               WHEN B.DEPARTMENTD = '公司金融' THEN
                'E'
               WHEN B.DEPARTMENTD = '普惠金融' THEN
                'S'
               WHEN B.DEPARTMENTD = '个人信贷' THEN
                'P'
               /*WHEN B.DEPARTMENTD = '磐石村镇' THEN
                'V'*/
               WHEN B.DEPARTMENTD = '德惠长银' THEN
                'E'
               ELSE
                '99'
             END
  FROM JS_102_GRKHXX_TEMP08 A
  --MODIFY BY DW(20220415) 同一天放款的两个部门会导致数据重复
  LEFT JOIN (SELECT B.CUST_ID,
                        B.DRAWDOWN_DT,
                        B.DEPARTMENTD,
                        ROW_NUMBER() OVER(PARTITION BY B.CUST_ID ORDER BY B.DRAWDOWN_DT DESC) RN
                   FROM JS_102_GRKHXX_TEMP10 B) B
  ON A.CUST_ID = B.CUST_ID
  AND A.DRAWDOWN_DT = B.DRAWDOWN_DT
  AND B.RN = 1;
  COMMIT;

-------------------------------------------------------------------------
--应用层逻辑
  VS_STEP := '应用层逻辑';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------吉林银行目标表数据--------------------
  SP_PBOCD_PARTITIONS(IS_DATE,'PBOCD_JS_102_GRKHXX',OI_RETCODE);
  SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_102_GRKHXX_TMP', OI_RETCODE);
---------------------
  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_102_GRKHXX TRUNCATE PARTITION P' || IS_DATE;
  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_102_GRKHXX_TMP TRUNCATE PARTITION P' || IS_DATE;
--------------------------------------------------------------------------
--插入磐石除外的数据
   INSERT INTO PBOCD_JS_102_GRKHXX_TMP
     (DATA_DATE         , --数据日期
      ORG_CODE          , --金融机构代码
      CUST_ID_TYPE      , --客户证件类型
      CUST_ID_NO        , --客户证件代码
      COUNTRY_CODE      , --国籍
      NATIONALITY       , --民族
      SEX_TYP           , --性别
      EDUCATION_CD      , --最高学历
      BIRTH_DT          , --出生日期
      REG_REGION_CODE   , --地区代码
      PER_INCOME_YEAR   , --个人年收入
      FAMILY_INCOME_YEAR, --家庭年收入
      MARRIAGE_TYP      , --婚姻情况
      RELATED_FLG       , --是否关联方
      FACILITY_AMT      , --授信额度
      USED_FACILITY_AMT , --已用额度
      CUST_TYPE         , --个人客户身份标识
      BUSI_LICENSE      , --个体工商户营业执照代码
      SOCIAL_CREDIT_CODE, --小微企业社会信用代码
      CREDIT_RATE_NUM   , --客户信用级别总等级数
      CREDIT_RATING     , --客户信用级别
      REPORT_ID         , --
      CJRQ              , --
      NBJGH             , --
      BIZ_LINE_ID       , --
      VERIFY_STATUS     , --
      BSCJRQ            , --
      FRNBJGH ,           --法人内部机构号
      ORG_NUM ,
      CUST_ID ,           --客户号
      CUST_NAME           --客户名称
      )
     SELECT
        VS_TEXT DATA_DATE  , --数据日期
        CASE WHEN T.FRNBJGH = '510000' THEN '912202016601010854'
             WHEN T.FRNBJGH = '520000' THEN '91321000564261222Q'
             WHEN T.FRNBJGH = '530000' THEN '91220201584622304Y'
             WHEN T.FRNBJGH = '540000' THEN '91220101586213344F'
             WHEN T.FRNBJGH = '550000' THEN '911309005881693407'
             WHEN T.FRNBJGH = '560000' THEN '91131000589668889D'
             WHEN T.FRNBJGH = '570000' THEN '91222404584629733N'
             WHEN T.FRNBJGH = '580000' THEN '912203005846084148'
             WHEN T.FRNBJGH = '590000' THEN '91220421660100250Y'
             WHEN T.FRNBJGH = '600000' THEN '912202015846358186' ----20230620多法人新增
             ELSE '9122010170255776XN' END AS ORG_CODE,--金融机构代码
        
        --[2025-12-03] [周立鹏] [无需求][李楠] 调整证件类型、证件代码、担保方式取数逻辑
        --NVL(BK.CUST_ID_TYPE,T.CUST_ID_TYPE)  , --客户证件类型
        T.CUST_ID_TYPE  , --客户证件类型
        T.CUST_ID_NO        , --客户证件代码
        --[2025-09-18] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_四阶段][李楠] 剔除取上期/配置表
        --NVL(BK.COUNTRY_CODE,T.COUNTRY_CODE )     , --国籍
        T.COUNTRY_CODE     , --国籍
        
        --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
        --NVL(BK.NATIONALITY,T.NATIONALITY)       , --民族
        T.NATIONALITY       , --民族
        
        --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
        --NVL(BK.SEX_TYP,T.SEX_TYP)         , --性别
        T.SEX_TYP         , --性别
        
        --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
        --NVL(BK.EDUCATION_CD,T.EDUCATION_CD)      , --最高学历
        T.EDUCATION_CD      , --最高学历
        
        --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
        --NVL(BK.BIRTH_DT,T.BIRTH_DT)          , --出生日期
        T.BIRTH_DT          , --出生日期
        
        --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
        --NVL(BK.REG_REGION_CODE,T.REG_REGION_CODE)   , --地区代码
        T.REG_REGION_CODE   , --地区代码
        
        --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
        --NVL(BK.PER_INCOME_YEAR,T.PER_INCOME_YEAR)   , --个人年收入
        T.PER_INCOME_YEAR   , --个人年收入
        
        --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
        --NVL(BK.FAMILY_INCOME_YEAR,T.FAMILY_INCOME_YEAR), --家庭年收入
        T.FAMILY_INCOME_YEAR, --家庭年收入
        
        --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
        --NVL(BK.MARRIAGE_TYP,T.MARRIAGE_TYP)     , --婚姻情况
        T.MARRIAGE_TYP     , --婚姻情况
        
        --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
        --NVL(BK.RELATED_FLG,T.RELATED_FLG)       , --是否关联方
        T.RELATED_FLG       , --是否关联方
        
        t.FACILITY_AMT     , --授信额度
         t.USED_FACILITY_AMT , --已用额度
        '', --个人客户身份标识
        '', --个体工商户营业执照代码
        '', --小微企业社会信用代码
        
        --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
        /*NVL(T.CREDIT_RATE_NUM,BK.CREDIT_RATE_NUM)   , --客户信用级别总等级数
        NVL(T.CREDIT_RATING,BK.CREDIT_RATING)     , --客户信用级别*/
        T.CREDIT_RATE_NUM   , --客户信用级别总等级数
        T.CREDIT_RATING     , --客户信用级别
        
        T.REPORT_ID         , --
        T.CJRQ              , --
        T.NBJGH             , --
        CASE WHEN T.NBJGH LIKE '51%' THEN '99'
            WHEN T.NBJGH LIKE '52%' THEN '99'
            WHEN T.NBJGH LIKE '53%' THEN '99'
            WHEN T.NBJGH LIKE '54%' THEN '99'
            WHEN T.NBJGH LIKE '55%' THEN '99'
            WHEN T.NBJGH LIKE '56%' THEN '99'
            WHEN T.NBJGH LIKE '57%' THEN '99'
            WHEN T.NBJGH LIKE '58%' THEN '99'
            WHEN T.NBJGH LIKE '59%' THEN '99'
            WHEN T.NBJGH LIKE '60%' THEN '99'
             ELSE NVL(T9.DATASOURCE,'99') END AS BIZ_LINE_ID   , --
        T.VERIFY_STATUS     , --
        T.BSCJRQ            , --
        T.FRNBJGH ,          --法人内部机构号
        T.NBJGH,
        T.CUST_ID,           --客户号
        T.CUST_NAME          --客户名称
       FROM JS_102_GRKHXX T
       LEFT JOIN JS_102_GRKHXX_TEMP09 T9
       ON T.CUST_ID = T9.CUST_ID
       LEFT JOIN PBOCD_JS_102_GRKHXX_SQ BK
       ON  T.CUST_ID_NO = BK.CUST_ID_NO
       AND T.FRNBJGH = BK.FRNBJGH
       AND BK.CJRQ = VS_LAST_TEXT
      where  T.CJRQ = IS_DATE
;
   COMMIT;
------------------------------------------------------------
--插入其他网点办理借贷业务，但在磐石开立的客户
   INSERT INTO PBOCD_JS_102_GRKHXX_TMP
     (DATA_DATE         , --数据日期
      ORG_CODE          , --金融机构代码
      CUST_ID_TYPE      , --客户证件类型
      CUST_ID_NO        , --客户证件代码
      COUNTRY_CODE      , --国籍
      NATIONALITY       , --民族
      SEX_TYP           , --性别
      EDUCATION_CD      , --最高学历
      BIRTH_DT          , --出生日期
      REG_REGION_CODE   , --地区代码
      PER_INCOME_YEAR   , --个人年收入
      FAMILY_INCOME_YEAR, --家庭年收入
      MARRIAGE_TYP      , --婚姻情况
      RELATED_FLG       , --是否关联方
      FACILITY_AMT      , --授信额度
      USED_FACILITY_AMT , --已用额度
      CUST_TYPE         , --个人客户身份标识
      BUSI_LICENSE      , --个体工商户营业执照代码
      SOCIAL_CREDIT_CODE, --小微企业社会信用代码
      CREDIT_RATE_NUM   , --客户信用级别总等级数
      CREDIT_RATING     , --客户信用级别
      REPORT_ID         , --
      CJRQ              , --
      NBJGH             , --
      BIZ_LINE_ID       , --
      VERIFY_STATUS     , --
      BSCJRQ            , --
      FRNBJGH ,           --法人内部机构号
      ORG_NUM ,
      CUST_ID ,           --客户号
      CUST_NAME           --客户名称
      )
     SELECT
        VS_TEXT DATA_DATE  , --数据日期
        '9122010170255776XN' JRJGBM          , --金融机构代码
        
        --[2025-12-03] [周立鹏] [无需求][李楠] 调整证件类型、证件代码、担保方式取数逻辑
        --NVL(BK.CUST_ID_TYPE,T.CUST_ID_TYPE)  , --客户证件类型
        T.CUST_ID_TYPE  , --客户证件类型
        T.CUST_ID_NO        , --客户证件代码
        
        --[2025-09-18] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_四阶段][李楠] 剔除取上期/配置表
        --NVL(BK.COUNTRY_CODE,T.COUNTRY_CODE )     , --国籍
        T.COUNTRY_CODE     , --国籍
        
        --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
        --NVL(BK.NATIONALITY,T.NATIONALITY)       , --民族
        T.NATIONALITY       , --民族
        
        --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
        --NVL(BK.SEX_TYP,T.SEX_TYP)         , --性别
        T.SEX_TYP         , --性别
        
        --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
        --NVL(BK.EDUCATION_CD,T.EDUCATION_CD)      , --最高学历
        T.EDUCATION_CD      , --最高学历
        
        --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
        --NVL(BK.BIRTH_DT,T.BIRTH_DT)          , --出生日期
        T.BIRTH_DT          , --出生日期
        
        --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
        --NVL(BK.REG_REGION_CODE,T.REG_REGION_CODE)   , --地区代码
        T.REG_REGION_CODE   , --地区代码
        
        --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
        --NVL(BK.PER_INCOME_YEAR,T.PER_INCOME_YEAR)   , --个人年收入
        T.PER_INCOME_YEAR   , --个人年收入
        
        --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
        --NVL(BK.FAMILY_INCOME_YEAR,T.FAMILY_INCOME_YEAR), --家庭年收入
        T.FAMILY_INCOME_YEAR, --家庭年收入
        
        --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
        --NVL(BK.MARRIAGE_TYP,T.MARRIAGE_TYP)     , --婚姻情况
        T.MARRIAGE_TYP     , --婚姻情况
        
        --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
        --NVL(BK.RELATED_FLG,T.RELATED_FLG)       , --是否关联方
        T.RELATED_FLG       , --是否关联方
        
        T.FACILITY_AMT     , --授信额度
         T.USED_FACILITY_AMT , --已用额度
        '', --个人客户身份标识
        '', --个体工商户营业执照代码
        '', --小微企业社会信用代码
  
  --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
        /*NVL(T.CREDIT_RATE_NUM,BK.CREDIT_RATE_NUM)   , --客户信用级别总等级数
        NVL(T.CREDIT_RATING,BK.CREDIT_RATING)     , --客户信用级别*/
        T.CREDIT_RATE_NUM   , --客户信用级别总等级数
        T.CREDIT_RATING     , --客户信用级别
  
        T.REPORT_ID         , --
        T.CJRQ              , --
        '990000' NBJGH      , --内部机构号 5100开头的赋值成990000
        T.BIZ_LINE_ID   , --
        T.VERIFY_STATUS     , --
        T.BSCJRQ            , --
        '990000' FRNBJGH ,          --法人内部机构号
        '990000' ORG_NUM,
        ''CUST_ID,           --客户号--赋空值，不然磐石业务人员导入数据时会覆盖掉
        T.CUST_NAME          --客户名称
       FROM
       PBOCD_JS_102_GRKHXX_TMP T
       LEFT JOIN PBOCD_JS_102_GRKHXX_SQ BK
       ON T.CUST_ID_NO = BK.CUST_ID_NO
       AND T.FRNBJGH = BK.FRNBJGH
       AND BK.CJRQ = VS_LAST_TEXT
      WHERE  T.DATA_DATE = VS_TEXT AND T.FRNBJGH = '510000'
        AND T.CUST_ID_NO IN('230702198304130729'
                           ,'220602198702103315'
                           ,'220223197609266027'
                           ,'220284199206031567'
                           ,'220223198004146617')
        AND NOT EXISTS(
          SELECT * FROM PBOCD_JS_102_GRKHXX_TMP B
             WHERE B.CJRQ = IS_DATE AND B.FRNBJGH = '990000' AND B.CUST_ID_NO=T.CUST_ID_NO);
   COMMIT;
   

--合并同一证件号对应多个客户号的数据，授信加和
INSERT INTO PBOCD_JS_102_GRKHXX
     (DATA_DATE         , --数据日期
      ORG_CODE          , --金融机构代码
      CUST_ID_TYPE      , --客户证件类型
      CUST_ID_NO        , --客户证件代码
      COUNTRY_CODE      , --国籍
      NATIONALITY       , --民族
      SEX_TYP           , --性别
      EDUCATION_CD      , --最高学历
      BIRTH_DT          , --出生日期
      REG_REGION_CODE   , --地区代码
      PER_INCOME_YEAR   , --个人年收入
      FAMILY_INCOME_YEAR, --家庭年收入
      MARRIAGE_TYP      , --婚姻情况
      RELATED_FLG       , --是否关联方
      FACILITY_AMT      , --授信额度
      USED_FACILITY_AMT , --已用额度
      CUST_TYPE         , --个人客户身份标识
      BUSI_LICENSE      , --个体工商户营业执照代码
      SOCIAL_CREDIT_CODE, --小微企业社会信用代码
      CREDIT_RATE_NUM   , --客户信用级别总等级数
      CREDIT_RATING     , --客户信用级别
      REPORT_ID         , --报送ID
      CJRQ              , --采集日期
      NBJGH             , --内部机构号
      BIZ_LINE_ID       , --业务条线
      FRNBJGH ,           --法人内部机构号
      ORG_NUM,
      CUST_ID ,           --客户号
      CUST_NAME           --客户名称
      ) 
SELECT DATA_DATE         , --数据日期
      ORG_CODE          , --金融机构代码
      CUST_ID_TYPE      , --客户证件类型
      CUST_ID_NO        , --客户证件代码
      COUNTRY_CODE      , --国籍
      NATIONALITY       , --民族
      SEX_TYP           , --性别
      EDUCATION_CD      , --最高学历
      BIRTH_DT          , --出生日期
      REG_REGION_CODE   , --地区代码
      PER_INCOME_YEAR   , --个人年收入
      FAMILY_INCOME_YEAR, --家庭年收入
      MARRIAGE_TYP      , --婚姻情况
      RELATED_FLG       , --是否关联方
      FACILITY_AMT      , --授信额度
      USED_FACILITY_AMT , --已用额度
      CUST_TYPE         , --个人客户身份标识
      BUSI_LICENSE      , --个体工商户营业执照代码
      SOCIAL_CREDIT_CODE, --小微企业社会信用代码
      CREDIT_RATE_NUM   , --客户信用级别总等级数
      CREDIT_RATING     , --客户信用级别
      REPORT_ID         , --报送ID
      CJRQ              , --采集日期
      NBJGH             , --内部机构号
      BIZ_LINE_ID       , --业务条线
      FRNBJGH ,           --法人内部机构号
      ORG_NUM,
      CUST_ID ,           --客户号
      CUST_NAME           --客户名称
       FROM (
SELECT DATA_DATE         , --数据日期
      ORG_CODE          , --金融机构代码
      CUST_ID_TYPE      , --客户证件类型
      CUST_ID_NO        , --客户证件代码
      COUNTRY_CODE      , --国籍
      NATIONALITY       , --民族
      SEX_TYP           , --性别
      EDUCATION_CD      , --最高学历
      BIRTH_DT          , --出生日期
      REG_REGION_CODE   , --地区代码
      PER_INCOME_YEAR   , --个人年收入
      FAMILY_INCOME_YEAR, --家庭年收入
      MARRIAGE_TYP      , --婚姻情况
      RELATED_FLG       , --是否关联方
      SUM(FACILITY_AMT) OVER(PARTITION BY FRNBJGH,CUST_ID_NO)      FACILITY_AMT , --授信额度
      SUM(USED_FACILITY_AMT) OVER(PARTITION BY FRNBJGH,CUST_ID_NO) USED_FACILITY_AMT , --已用额度
      CUST_TYPE         , --个人客户身份标识
      BUSI_LICENSE      , --个体工商户营业执照代码
      SOCIAL_CREDIT_CODE, --小微企业社会信用代码
      CREDIT_RATE_NUM   , --客户信用级别总等级数
      CREDIT_RATING     , --客户信用级别
      REPORT_ID         , --报送ID
      CJRQ              , --采集日期
      NBJGH             , --内部机构号
      BIZ_LINE_ID       , --业务条线
      FRNBJGH ,           --法人内部机构号
      ORG_NUM ,
      CUST_ID ,           --客户号
      CUST_NAME,           --客户名称
      ROW_NUMBER() OVER(PARTITION BY FRNBJGH,CUST_ID_NO ORDER BY CUST_ID DESC) RN
      FROM PBOCD_JS_102_GRKHXX_TMP WHERE CJRQ = IS_DATE
      ) WHERE RN=1;
COMMIT;
--信用卡文件没有传客户号，无法统一授信，所以放在统一授信之后   
--插入信用卡数据
INSERT INTO PBOCD_JS_102_GRKHXX
     (DATA_DATE         , --数据日期
      ORG_CODE          , --金融机构代码
      CUST_ID_TYPE      , --客户证件类型
      CUST_ID_NO        , --客户证件代码
      COUNTRY_CODE      , --国籍
      NATIONALITY       , --民族
      SEX_TYP           , --性别
      EDUCATION_CD      , --最高学历
      BIRTH_DT          , --出生日期
      REG_REGION_CODE   , --地区代码
      PER_INCOME_YEAR   , --个人年收入
      FAMILY_INCOME_YEAR, --家庭年收入
      MARRIAGE_TYP      , --婚姻情况
      RELATED_FLG       , --是否关联方
      FACILITY_AMT      , --授信额度
      USED_FACILITY_AMT , --已用额度
      CUST_TYPE         , --个人客户身份标识
      BUSI_LICENSE      , --个体工商户营业执照代码
      SOCIAL_CREDIT_CODE, --小微企业社会信用代码
      CREDIT_RATE_NUM   , --客户信用级别总等级数
      CREDIT_RATING     , --客户信用级别
      REPORT_ID         , --报送ID
      CJRQ              , --采集日期
      NBJGH             , --内部机构号
      BIZ_LINE_ID       , --业务条线
      FRNBJGH ,           --法人内部机构号
      ORG_NUM
      )
SELECT
      VS_TEXT DATA_DATE --数据日期
      ,TRIM(T.ORG_CODE)  --金融机构代码
      ,TRIM(T.CUST_ID_TYPE) --客户证件类型
      ,TRIM(T.CUST_ID_NO) --客户证件代码
      ,TRIM(T.COUNTRY_CODE) --国籍
      ,TRIM(T.NATIONALITY) --民族
      ,TRIM(T.SEX_TYP) --性别
      ,CASE WHEN TRIM(T.EDUCATION_CD)='90' THEN '' ELSE TRIM(T.EDUCATION_CD) END--最高学历
      ,NVL2(TRIM(T.BIRTH_DT),SUBSTR(TRIM(T.BIRTH_DT),1,4)||'-'||SUBSTR(TRIM(T.BIRTH_DT),5,2)||'-'||SUBSTR(TRIM(T.BIRTH_DT),7,2),'') --出生日期
      ,TRIM(T.REG_REGION_CODE) --地区代码
      ,CASE WHEN T.PER_INCOME_YEAR >=10000000 OR T.PER_INCOME_YEAR=0 OR T.PER_INCOME_YEAR=9999999 THEN '' ELSE TRIM(T.PER_INCOME_YEAR) END--个人年收入
      ,CASE WHEN T.FAMILY_INCOME_YEAR >=10000000 OR T.FAMILY_INCOME_YEAR=0 OR T.FAMILY_INCOME_YEAR=9999999 THEN '' ELSE TRIM(T.FAMILY_INCOME_YEAR) END --家庭年收入
      ,TRIM(T.MARRIAGE_TYP) --婚姻情况
      ,TRIM(T.RELATED_FLG) --是否关联方
      ,TRIM(T.FACILITY_AMT) --授信额度
      ,TRIM(T.USED_FACILITY_AMT) --已用额度
      /*,TRIM(T.CUST_TYPE) --个人客户身份标识
      ,TRIM(T.BUSI_LICENSE) --个体工商户营业执照代码
      ,TRIM(T.SOCIAL_CREDIT_CODE) --小微企业社会信用代码*/
      ,'' --个人客户身份标识
      ,'' --个体工商户营业执照代码
      ,'' --小微企业社会信用代码
      ,TRIM(T.CREDIT_RATE_NUM) --客户信用级别总等级数
      ,NVL(REPLACE(TRIM(T.CREDIT_RATING),CHR(13),''),NULL) --客户信用级别
      ,SYS_GUID() REPORT_ID --报送ID
      ,IS_DATE --采集日期
      ,'009803' --内部机构号
      ,'99' --业务条线
      ,'990000' --法人内部机构号
      ,'009803' --机构号
FROM PBOCD_DATACORE.JS_102_GRKHXX_XYK T
WHERE T.DATA_DATE=IS_DATE AND NOT EXISTS(
SELECT 1 FROM PBOCD_JS_102_GRKHXX A WHERE A.CJRQ = IS_DATE AND A.FRNBJGH='990000'
AND T.CUST_ID_NO = A.CUST_ID_NO);

COMMIT;

---------------------------------------------------------------------------------------------------
--WXY 校验问题修改
update PBOCD_JS_102_GRKHXX
set PER_INCOME_YEAR =''
where (PER_INCOME_YEAR >=10000000 or PER_INCOME_YEAR=0 or PER_INCOME_YEAR=9999999)
and cjrq =IS_DATE  ;
COMMIT;
update PBOCD_JS_102_grkhxx
set FAMILY_INCOME_YEAR =''
where (FAMILY_INCOME_YEAR >=10000000 or FAMILY_INCOME_YEAR=0 or FAMILY_INCOME_YEAR=9999999)
and cjrq =IS_DATE  ;
COMMIT;

--家庭收入小于个人收入的
update PBOCD_JS_102_grkhxx
set FAMILY_INCOME_YEAR =PER_INCOME_YEAR
where FAMILY_INCOME_YEAR <PER_INCOME_YEAR
and cjrq =IS_DATE  ;
COMMIT;
--最高学历
update PBOCD_JS_102_grkhxx set education_cd=''
where cjrq=IS_DATE and education_cd='90';
COMMIT;

--[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
/*update PBOCD_JS_102_grkhxx
set SEX_TYP ='01'
where cjrq = IS_DATE
AND CUST_ID_NO ='210122600156097' ;
COMMIT;
update PBOCD_JS_102_grkhxx
set SEX_TYP ='02'
where cjrq = IS_DATE
AND CUST_ID_NO ='210122600156706' ;
COMMIT;
update PBOCD_JS_102_grkhxx
set SEX_TYP ='01'
where cjrq = IS_DATE
AND CUST_ID_NO ='220422600152769' ;
COMMIT;*/

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
/*--地区代码
MERGE INTO PBOCD_JS_102_GRKHXX A
USING (SELECT * FROM PBOCD_JS_102_GRKHXX_SQ WHERE CJRQ = VS_LAST_TEXT) B
--ON (A.CUST_ID_NO = B.CUST_ID_NO)
ON (A.CUST_ID_NO = B.CUST_ID_NO AND A.NBJGH = B.NBJGH)  --BY CH 20231201
WHEN MATCHED THEN
  UPDATE
     SET A.REG_REGION_CODE = B.REG_REGION_CODE
   WHERE CJRQ = IS_DATE
     AND (REG_REGION_CODE LIKE '000%' OR REG_REGION_CODE IS NULL OR REG_REGION_CODE = '999999');
COMMIT;

--公主岭地区代码
UPDATE PBOCD_JS_102_GRKHXX
   SET REG_REGION_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND REG_REGION_CODE = '220381';
COMMIT;
--[2025-12-03] [周立鹏] [无需求][李楠] 调整证件类型、证件代码、担保方式取数逻辑
--特殊处理一条数据
UPDATE PBOCD_JS_102_GRKHXX
   SET \*CUST_ID_TYPE = 'B99',*\ REG_REGION_CODE = '220105'
 WHERE CJRQ = IS_DATE
   AND CUST_ID_NO = 'KOR110064032206';
COMMIT;

--[2025-12-03] [周立鹏] [无需求][李楠] 调整证件类型、证件代码、担保方式取数逻辑
MERGE INTO PBOCD_JS_102_GRKHXX A
  USING(
      SELECT
      T.CUST_ID_TYPE
      ,T.CUST_ID_NO
      ,T.CUST_ID_NO_NEW
      ,T.REG_REGION_CODE
      ,T.NBJGH
      ,T.CUST_ID
      FROM JS_102_GRKHXX_BL T ) B
  ON (A.CUST_ID = B.CUST_ID AND A.DATA_DATE = VS_TEXT)
  WHEN MATCHED THEN
  UPDATE SET
   \*A.CUST_ID_TYPE  = B.CUST_ID_TYPE
  ,A.CUST_ID_NO    = B.CUST_ID_NO_NEW
  ,*\A.REG_REGION_CODE = B.REG_REGION_CODE
  ;
COMMIT;

--调用特殊处理程序
--地区代码999999、空、000开头的数据，按L层客户表历史数据刷一下，刷不到的截取身份证前六位
  BSP_SP_JS_SPOP(IS_DATE,OI_RETCODE,OI_RETCODE_DEC,'PBOCD_JS_102_GRKHXX');*/
  -------------------------------------------------------------------------


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