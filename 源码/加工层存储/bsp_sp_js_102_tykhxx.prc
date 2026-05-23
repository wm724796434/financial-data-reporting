CREATE OR REPLACE PROCEDURE BSP_SP_JS_102_TYKHXX(IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  --    SP_JS_102_TYKHXX
  -- 用途:生成接口表 JS_102_TYKHXX 同业客户基础信息
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    CAEATE BY USER AT 20210330
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
  NUM               INTEGER;
  VS_NMONTH         VARCHAR2(10);

BEGIN
  VS_TEXT := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_102_TYKHXX';
  VS_NMONTH := TO_CHAR(TRUNC(TO_DATE(IS_DATE,'YYYYMMDD') + 1),'YYYYMMDD');
  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------

  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_102_TYKHXX_TEMP1';

  --分别从存量同业存款和同业存款发生额表取客户号
  INSERT /*+ APPEND*/ INTO JS_102_TYKHXX_TEMP1 NOLOGGING
  SELECT DISTINCT A.CUST_ID FROM JS_202_CLTYCK A WHERE TRIM(A.DATA_DATE) = IS_DATE AND A.BALANCE <> 0;
  COMMIT;
  INSERT /*+ APPEND*/ INTO JS_102_TYKHXX_TEMP1 NOLOGGING
  SELECT DISTINCT A.CUST_ID FROM PBOCD_JS_202_TYCKFS A WHERE TRIM(A.DATA_DATE) = VS_TEXT
  AND A.CUST_ID NOT IN(SELECT CUST_ID FROM JS_102_TYKHXX_TEMP1);
  COMMIT;

  --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'JS_102_TYKHXX'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE JS_102_TYKHXX ADD PARTITION P' ||
                      IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE JS_102_TYKHXX TRUNCATE PARTITION P' ||
                    IS_DATE;

  INSERT /*+ APPEND*/ INTO JS_102_TYKHXX NOLOGGING (
       DATA_DATE             --数据日期
      ,ORG_CODE             --金融机构代码
      ,CUST_NAME            --客户名称
      ,CUST_ID_NO           --客户代码
      ,CUST_ORG_ID          --客户金融机构编码
      ,BASIC_ACCOUNT        --基本存款账号
      ,BASIC_ACCOUNT_BANK   --基本账户开户行名称
      ,REG_REGION_CODE      --地区代码
      ,CUST_TYPE            --客户类别
      ,OPEN_DATE            --成立日期
      ,RELATED_FLG          --是否关联方
      ,CUST_NO              --客户内部编号
      ,REG_ADDRESS          --注册地址
      ,CTRL_ECO_ELEM        --客户经济成分
      ,CREDIT_RATE_NUM      --客户信用级别总等级数
      ,CREDIT_RATING        --客户信用评级
      ,CJRQ                 --采集日期
      ,NBJGH                --内部机构号
      ,DEPT_TYPE            --客户国民经济部门
      ,FRNBJGH              --法人内部机构号
      ,ORG_NUM              --内部机构号
      ,CUST_ID              --客户号
  )
  SELECT
       DATA_DATE             --数据日期
      ,ORG_CODE             --金融机构代码
      ,CUST_NAME            --客户名称
      ,CUST_ID_NO           --客户代码
      ,CUST_ORG_ID          --客户金融机构编码
      ,BASIC_ACCOUNT        --基本存款账号
      ,BASIC_ACCOUNT_BANK   --基本账户开户行名称
      ,REG_REGION_CODE      --地区代码
      ,CUST_TYPE            --客户类别
      ,OPEN_DATE            --成立日期
      ,RELATED_FLG          --是否关联方
      ,CUST_NO              --客户内部编号
      ,REG_ADDRESS          --注册地址
      ,CTRL_ECO_ELEM        --客户经济成分
      ,CREDIT_RATE_NUM      --客户信用级别总等级数
      ,CREDIT_RATING        --客户信用评级
      ,CJRQ                 --采集日期
      ,NBJGH                --内部机构号
      ,DEPT_TYPE            --客户国民经济部门
      ,FRNBJGH              --法人内部机构号
      ,ORG_NUM              --内部机构号
      ,CUST_ID              --客户号
   FROM (SELECT
      DATA_DATE             --数据日期
      ,ORG_CODE             --金融机构代码
      ,CUST_NAME            --客户名称
      ,CUST_ID_NO           --客户代码
      ,CUST_ORG_ID          --客户金融机构编码
      ,BASIC_ACCOUNT        --基本存款账号
      ,BASIC_ACCOUNT_BANK   --基本账户开户行名称
      ,REG_REGION_CODE      --地区代码
      ,CUST_TYPE            --客户类别
      ,OPEN_DATE            --成立日期
      ,RELATED_FLG          --是否关联方
      ,CUST_NO              --客户内部编号
      ,REG_ADDRESS          --注册地址
      ,CTRL_ECO_ELEM        --客户经济成分
      ,CREDIT_RATE_NUM      --客户信用级别总等级数
      ,CREDIT_RATING        --客户信用评级
      ,CJRQ                 --采集日期
      ,NBJGH                --内部机构号
      ,DEPT_TYPE            --客户国民经济部门
      ,FRNBJGH              --法人内部机构号
      ,ORG_NUM              --内部机构号
      ,CUST_ID              --客户号
/*      ,ROW_NUMBER() OVER(PARTITION BY CUST_ID_NO ORDER BY CUST_ID_NO)RN--多条记录是因为JS_102_TYKHXX_CODE里面多个分公司对应一个总公司，此处取任意一条就可以
*/      ,ROW_NUMBER() OVER(PARTITION BY CUST_ID_NO,FRNBJGH ORDER BY CUST_ID_NO)RN--多条记录是因为JS_102_TYKHXX_CODE里面多个分公司对应一个总公司，此处取任意一条就可以
--20231130WXB多法人改造
  FROM(
  SELECT  /*+parallel(4)*/
      IS_DATE DATA_DATE
      ,'' ORG_CODE --金融机构代码
      ,NVL(CD.CUST_NAME,B.CUST_NAM) CUST_NAME --客户名称
      --,CASE WHEN B.ID_TYPE IN ('21','236') THEN NVL(CD.CUST_ID_NO,B.ID_NO) END AS CUST_ID_NO--客户代码   ------20220222  夏文博
      ,NVL(CD.CUST_ID_NO,B.ID_NO) AS CUST_ID_NO--客户代码
      ,'' CUST_ORG_ID --客户金融机构编码
      ,NVL2(B1.CUST_ID,B1.BASE_ACCT,B.BASE_ACCT) BASIC_ACCOUNT--基本存款账号
      ,NVL2(B1.CUST_ID,B1.BASE_ACCT_OP_NAME,B.BASE_ACCT_OP_NAME) BASIC_ACCOUNT_BANK--基本账户开户行名称
      ,REPLACE(NVL2(B1.CUST_ID,B1.REGION_CD,B.REGION_CD), '待治理', '') REG_REGION_CODE--地区代码
      ,'' CUST_TYPE--客户类别
      ,TO_CHAR(NVL2(B1.CUST_ID,B1.BORROWER_BULID_YEAR,B.BORROWER_BULID_YEAR),'YYYY-MM-DD') OPEN_DATE--成立日期
      ,CASE WHEN NVL2(B1.CUST_ID,B1.RELATED_TYP,B.RELATED_TYP) IS NOT NULL THEN '1' ELSE '0' END RELATED_FLG----20220221  夏文博修改
      ,NVL2(B1.CUST_ID,B1.CUST_ID,B.CUST_ID) CUST_NO--客户内部编码
      ,REGEXP_REPLACE(NVL2(B1.CUST_ID,B1.BORROWER_REGISTER_ADDR,B.BORROWER_REGISTER_ADDR), '[!?^？！|]') REG_ADDRESS--注册地址
      ,NVL2(B1.CUST_ID,B1.CORP_HOLD_TYPE,B.CORP_HOLD_TYPE) CTRL_ECO_ELEM--客户经济成分
      ,12 CREDIT_RATE_NUM--客户信用级别总等级数
      ,PJ.PARAM_NAME CREDIT_RATING--客户信用评级
      ,IS_DATE CJRQ--采集日期
      ,NVL2(B1.CUST_ID,B1.ORG_NUM,B.ORG_NUM) NBJGH--内部机构号
      ,NVL2(B1.CUST_ID,B1.DEPT_TYPE,B.DEPT_TYPE) DEPT_TYPE--客户国民经济部门
/*      ,CASE WHEN NVL2(B1.CUST_ID,B1.ORG_NUM,B.ORG_NUM) LIKE '5100%' THEN '510000' ELSE '990000' END FRNBJGH*/
      ,CASE WHEN NVL2(B1.CUST_ID,B1.ORG_NUM,B.ORG_NUM) LIKE '5100%' THEN '510000'
      WHEN NVL2(B1.CUST_ID,B1.ORG_NUM,B.ORG_NUM) LIKE '52%' THEN '520000'
      WHEN NVL2(B1.CUST_ID,B1.ORG_NUM,B.ORG_NUM) LIKE '53%' THEN '530000'
      WHEN NVL2(B1.CUST_ID,B1.ORG_NUM,B.ORG_NUM) LIKE '54%' THEN '540000'
      WHEN NVL2(B1.CUST_ID,B1.ORG_NUM,B.ORG_NUM) LIKE '55%' THEN '550000'
      WHEN NVL2(B1.CUST_ID,B1.ORG_NUM,B.ORG_NUM) LIKE '56%' THEN '560000'
      WHEN NVL2(B1.CUST_ID,B1.ORG_NUM,B.ORG_NUM) LIKE '57%' THEN '570000'
      WHEN NVL2(B1.CUST_ID,B1.ORG_NUM,B.ORG_NUM) LIKE '58%' THEN '580000'
      WHEN NVL2(B1.CUST_ID,B1.ORG_NUM,B.ORG_NUM) LIKE '59%' THEN '590000'
      WHEN NVL2(B1.CUST_ID,B1.ORG_NUM,B.ORG_NUM) LIKE '60%' THEN '600000'
       ELSE '990000' END FRNBJGH----20230620多法人新增
      ,NVL2(B1.CUST_ID,B1.ORG_NUM,B.ORG_NUM) ORG_NUM--内部机构号
      ,NVL2(B1.CUST_ID,B1.CUST_ID,B.CUST_ID) CUST_ID--客户内部编码
  FROM JS_102_TYKHXX_TEMP1 A
  INNER JOIN L_CUST_C_TMP B
  ON A.CUST_ID = B.CUST_ID
  AND B.DATA_DATE = IS_DATE

  LEFT JOIN JS_102_TYKHXX_CODE CD
  ON  B.ID_NO = CD.CUST_ID_NO_SOURCE
  AND B.CUST_NAM = CD.CUST_NAME_SOURCE

  LEFT JOIN L_CUST_C_TMP B1
  ON CD.CUST_ID = B1.CUST_ID
  AND B1.DATA_DATE = IS_DATE

  LEFT JOIN TMP_JS_102_FTYKHX_GLF GLF
  ON NVL2(B1.CUST_ID,B1.CUST_NAM,B.CUST_NAM) = GLF.CUST_NAME
  LEFT JOIN M_EAST_META_FIELD_SCOPE PJ
  ON NVL2(B1.CUST_ID,B1.CUS_RISK_LV_DE,B.CUS_RISK_LV_DE) = PJ.PARAM_CODE
  AND PJ.PARAM_TYPE = 'NBPJ')

  )T
  WHERE T.RN=1 AND T.CUST_ID_NO IS NOT NULL;
  COMMIT;



/*  --机构变更按照老机构报，如果不用了的机构可以把ORG_NEW表EFF_FLAG字段改成'N'
  UPDATE JS_102_TYKHXX A SET A.ORG_NUM = (SELECT T.ORG_NUM_BK FROM ORG_NEW T WHERE T.EFF_FLAG = 'Y' AND A.ORG_NUM = T.ORG_NUM_NEW)
  WHERE A.DATA_DATE = IS_DATE AND EXISTS(SELECT 1 FROM ORG_NEW B WHERE A.ORG_NUM = B.ORG_NUM_NEW AND B.EFF_FLAG = 'Y');
  COMMIT;*/

  ---吉林银行目标表数据
/*  DELETE FROM PBOCD_JS_102_TYKHXX
  WHERE DATA_DATE = TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  COMMIT;*/

  SP_PBOCD_PARTITIONS(IS_DATE,'PBOCD_JS_102_TYKHXX',OI_RETCODE);

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_102_TYKHXX TRUNCATE PARTITION P' ||
                    IS_DATE;

   ---以下包含原应用层加工逻辑，现都放在加工层处理
     --更新全量客户表
   BSP_SP_JS_102_TYKHXX_ALL(IS_DATE,OI_RETCODE);

INSERT /*+ APPEND*/ INTO PBOCD_JS_102_TYKHXX NOLOGGING (
      DATA_DATE               --数据日期
      ,ORG_CODE               --金融机构代码
      ,CUST_NAME              --客户名称
      ,CUST_ID_NO             --客户代码
      ,CUST_ORG_ID            --客户金融机构编码
      ,BASIC_ACCOUNT          --基本存款账号
      ,BASIC_ACCOUNT_BANK     --基本账户开户行名称
      ,REG_REGION_CODE        --地区代码
      ,CUST_TYPE              --客户类别
      ,OPEN_DATE              --成立日期
      ,RELATED_FLG            --是否关联方
      ,CUST_NO                --客户内部编号
      ,REG_ADDRESS            --注册地址
      ,CTRL_ECO_ELEM          --客户经济成分
      ,CREDIT_RATE_NUM        --客户信用级别总等级数
      ,CREDIT_RATING          --客户信用评级
      ,REPORT_ID              --
      ,CJRQ                   --
      ,NBJGH                  --
      ,BIZ_LINE_ID            --
      ,DEPT_TYPE              --客户国民经济部门
      ,FRNBJGH                --法人内部机构号
      ,ORG_NUM                --内部机构号
      ,CUST_ID                --客户号
      ,CUST_NAME_SOURCE       --原客户名称
      ,CUST_ID_NO_SOURCE     --原客户代码
      )
  SELECT   VS_TEXT --数据日期
/*        ,
         CASE
           WHEN A.FRNBJGH = '990000' THEN
            '9122010170255776XN'
           ELSE
            '912202016601010854'
         END JRJGBM --金融机构代码*/
        ,
   CASE WHEN A.FRNBJGH = '510000' THEN '912202016601010854'
             WHEN A.FRNBJGH = '520000' THEN '91321000564261222Q'
             WHEN A.FRNBJGH = '530000' THEN '91220201584622304Y'
             WHEN A.FRNBJGH = '540000' THEN '91220101586213344F'
             WHEN A.FRNBJGH = '550000' THEN '911309005881693407'
             WHEN A.FRNBJGH = '560000' THEN '91131000589668889D'
             WHEN A.FRNBJGH = '570000' THEN '91222404584629733N'
             WHEN A.FRNBJGH = '580000' THEN '912203005846084148'
             WHEN A.FRNBJGH = '590000' THEN '91220421660100250Y'
             WHEN A.FRNBJGH = '600000' THEN '912202015846358186' ----20230620多法人新增
             ELSE '9122010170255776XN' END AS JRJGBM--金融机构代码
        ,
         NVL2(BK.CUST_ID_NO, BK.CUST_NAME, A.CUST_NAME) --上报客户名称
        ,
         A.CUST_ID_NO --上报客户代码
        ,
         NVL2(BK.CUST_ID_NO, BK.CUST_ORG_ID, A.CUST_ORG_ID) --客户金融机构编码
        ,
         NVL2(BK.CUST_ID_NO, BK.BASIC_ACCOUNT, A.BASIC_ACCOUNT) --基本存款账号
        ,
         NVL2(BK.CUST_ID_NO, BK.BASIC_ACCOUNT_BANK, A.BASIC_ACCOUNT_BANK) --基本账户开户行名称
        ,
         NVL2(BK.CUST_ID_NO, BK.REG_REGION_CODE, A.REG_REGION_CODE) --地区代码
        ,
         NVL2(BK.CUST_ID_NO, BK.CUST_TYPE, A.CUST_TYPE) --客户类别
        ,
         NVL2(BK.CUST_ID_NO, BK.OPEN_DATE, A.OPEN_DATE) --成立日期
        ,
         NVL2(BK.CUST_ID_NO, BK.RELATED_FLG, A.RELATED_FLG) --是否关联方
        ,
         NVL2(BK.CUST_ID_NO, BK.CUST_NO, A.CUST_NO) --客户内部编号
        ,
         NVL2(BK.CUST_ID_NO, BK.REG_ADDRESS, A.REG_ADDRESS) --注册地址
        ,
         NVL2(BK.CUST_ID_NO, BK.CTRL_ECO_ELEM, A.CTRL_ECO_ELEM) --客户经济成分
        ,
         NVL2(BK.CUST_ID_NO, BK.CREDIT_RATE_NUM, A.CREDIT_RATE_NUM) --客户信用级别总等级数
        ,
         NVL2(BK.CUST_ID_NO, BK.CREDIT_RATING, A.CREDIT_RATING) --客户信用评级
        ,
         A.REPORT_ID --
        ,
         A.CJRQ --采集日期
        ,
         NVL2(BK.CUST_ID_NO, BK.NBJGH, A.NBJGH) --内部机构号
        ,
         '99' --业务条线
        ,
         NVL2(BK.CUST_ID_NO, BK.DEPT_TYPE, A.DEPT_TYPE) --客户国民经济部门
        ,
         A.FRNBJGH --法人内部机构号
        ,
         NVL2(BK.CUST_ID_NO, BK.ORG_NUM, A.ORG_NUM) --内部机构号
        ,
         NVL2(BK.CUST_ID_NO, BK.CUST_ID, A.CUST_ID) --客户号
        ,
         NVL2(BK.CUST_ID_NO, BK.CUST_NAME, A.CUST_NAME) --原客户名称
        ,
         NVL2(BK.CUST_ID_NO, BK.CUST_ID_NO, A.CUST_ID_NO) --原客户代码
    FROM JS_102_TYKHXX A
  LEFT JOIN JS_102_TYKHXX_ALL BK
  ON A.CUST_ID_NO = BK.CUST_ID_NO
  AND A.FRNBJGH=BK.FRNBJGH --20231130wxb 
  /*LEFT JOIN SYS_OFFICE OFF
  ON OFF.ID =A.NBJGH*/
  WHERE TRIM(A.DATA_DATE) = IS_DATE;
  COMMIT;



  --应业务要求全量客户表，本期业务未发生的客户。待业务手工录入后再删掉没有发生交易的客户
  INSERT INTO PBOCD_JS_102_TYKHXX(
      DATA_DATE
      ,ORG_CODE
      ,CUST_NAME
      ,CUST_ID_NO
      ,CUST_ORG_ID
      ,BASIC_ACCOUNT
      ,BASIC_ACCOUNT_BANK
      ,REG_REGION_CODE
      ,CUST_TYPE
      ,OPEN_DATE
      ,RELATED_FLG
      ,CUST_NO
      ,REG_ADDRESS
      ,CTRL_ECO_ELEM
      ,CREDIT_RATE_NUM
      ,CREDIT_RATING
      ,CJRQ
      ,NBJGH
      ,BIZ_LINE_ID
      ,DEPT_TYPE
      ,FRNBJGH
      ,ORG_NUM
      ,CUST_ID
      ,CUST_NAME_SOURCE
      ,CUST_ID_NO_SOURCE)
  SELECT   DISTINCT
      VS_TEXT
      ,ORG_CODE
      ,CUST_NAME
      ,CUST_ID_NO
      ,CUST_ORG_ID
      ,BASIC_ACCOUNT
      ,BASIC_ACCOUNT_BANK
      ,REG_REGION_CODE
      ,CUST_TYPE
      ,OPEN_DATE
      ,RELATED_FLG
      ,CUST_NO
      ,REG_ADDRESS
      ,CTRL_ECO_ELEM
      ,CREDIT_RATE_NUM
      ,CREDIT_RATING
      ,IS_DATE
      ,NBJGH
      ,BIZ_LINE_ID
      ,DEPT_TYPE
      ,FRNBJGH
      ,ORG_NUM
      ,CUST_ID
      ,CUST_NAME_SOURCE
      ,CUST_ID_NO_SOURCE
  FROM JS_102_TYKHXX_ALL A WHERE /*A.FRNBJGH = '990000'AND*/ --20231130wxb
    NOT EXISTS(
       SELECT 1 FROM PBOCD_JS_102_TYKHXX B WHERE B.CJRQ = IS_DATE
       AND A.CUST_ID_NO = B.CUST_ID_NO AND A.FRNBJGH = B.FRNBJGH
  );
  COMMIT;

--公主岭地区代码
UPDATE PBOCD_JS_102_TYKHXX
   SET REG_REGION_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND REG_REGION_CODE = '220381';
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
/

