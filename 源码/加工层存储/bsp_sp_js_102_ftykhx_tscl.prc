CREATE OR REPLACE PROCEDURE BSP_SP_JS_102_FTYKHX_TSCL(IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  --    SP_JS_102_FTYKHX
  --用途:生成接口表 JS_102_FTYKHX  非同业单位客户信息_特殊处理
  --删除没有业务的数据；补录上期报了本期没报的数据。（受批量顺序限制，所以单独处理）
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    CAEATE BY ZHOULP AT 20230320
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT      VARCHAR2(1000) DEFAULT NULL; --字符型  过程描述
  VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
BEGIN
  VS_TEXT := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'),-1), 'YYYYMMDD');

    -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_102_FTYKHX_TSCL';

 -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------

--删除上期客户表没有、本期存量贷款没有、本期贷款发生没有的数据
DELETE FROM PBOCD_JS_102_FTYKHX A
 WHERE A.CJRQ = IS_DATE
   AND FRNBJGH = '990000'
   AND NOT EXISTS (SELECT 1
          FROM PBOCD_JS_102_FTYKHX_SQ B--上期客户表
         WHERE B.CJRQ = VS_LAST_TEXT
           AND B.FRNBJGH = '990000'
           AND A.CUST_ID_NO = B.CUST_ID_NO)
   AND NOT EXISTS (SELECT 1
          FROM PBOCD_JS_201_CLDWDK B--本期存量贷款表
         WHERE B.CJRQ = IS_DATE
           AND B.FRNBJGH = '990000'
           AND A.CUST_ID_NO = B.CUST_ID_NO)
   AND NOT EXISTS (SELECT 1
          FROM PBOCD_JS_201_DWDKFS B--本期贷款发生额
         WHERE B.CJRQ = IS_DATE
           AND B.FRNBJGH = '990000'
           AND A.CUST_ID_NO = B.CUST_ID_NO);
COMMIT;

--补录上期报了本期没报的数据
INSERT INTO PBOCD_JS_102_FTYKHX
  SELECT VS_TEXT DATA_DATE,
         ORG_CODE,
         CUST_NAME,
         CUST_ID_NO,
         BASIC_ACCOUNT,
         BASIC_ACCOUNT_BANK,
         CAPITAL_AMT,
         PAICL_UP_CAP,
         TOTAL_ASSET,
         OPERATE_INCOME,
         LIST_FLG,
         FIRST_CREDIT_DATA,
         STAFF_NUM,
         REG_ADDRESS,
         REG_REGION_CODE,
         BUSI_STATUS,
         OPEN_DATE,
         INDUSTRY_TYPE,
         ENT_SCALE,
         FACILITY_AMT,
         USED_FACILITY_AMT,
         RELATED_FLG,
         ACTR_CTRL_ID_TYPE,
         ACTR_CTRL_ID_NO,
         CUST_ID_TYPE,
         BUSI_SCOPE,
         CTRL_ECO_ELEM,
         DEPT_TYPE,
         CREDIT_RATE_NUM,
         CREDIT_RATING,
         SYS_GUID() REPORT_ID,
         IS_DATE CJRQ,
         NBJGH,
         BIZ_LINE_ID,
         '' VERIFY_STATUS,
         '' BSCJRQ,
         FRNBJGH,
         ORG_NUM,
         CUST_ID
    FROM PBOCD_JS_102_FTYKHX_SQ A
   WHERE A.CJRQ = VS_LAST_TEXT
     AND A.FRNBJGH = '990000'
     AND NOT EXISTS (SELECT *
            FROM PBOCD_JS_102_FTYKHX B
           WHERE B.CJRQ = IS_DATE
             AND B.FRNBJGH = '990000'
             AND A.CUST_ID_NO = B.CUST_ID_NO);
COMMIT;

  -------------------------------------------------------------------------
 OI_RETCODE := 0; --设置异常状态为0 成功状态
 OI_RETCODE_DEC :='执行成功';

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

