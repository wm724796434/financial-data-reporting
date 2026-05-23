CREATE OR REPLACE PROCEDURE BSP_SP_JS_102_TYKHXX_ALL(IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  --    SP_JS_102_TYKHXX_ALL
  -- 用途:生成接口表 SP_JS_102_TYKHXX_ALL 最新版全量客户信息
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    CAEATE BY ZHOULP AT 20221027
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
  VS_COUNT1         NUMBER;
  VS_COUNT2         NUMBER;

BEGIN
  VS_TEXT := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');
  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_102_TYKHXX_ALL';
  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------
  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_102_TYKHXX_TMP1';
--获取增变量数据，插入临时表
INSERT INTO JS_102_TYKHXX_TMP1
  SELECT ORG_CODE,
         CUST_NAME,
         CUST_ID_NO,
         CUST_ORG_ID,
         BASIC_ACCOUNT,
         BASIC_ACCOUNT_BANK,
         REG_REGION_CODE,
         CUST_TYPE,
         OPEN_DATE,
         RELATED_FLG,
         CUST_NO,
         REG_ADDRESS,
         CTRL_ECO_ELEM,
         CREDIT_RATE_NUM,
         CREDIT_RATING,
         NBJGH,
         BIZ_LINE_ID,
         DEPT_TYPE,
         FRNBJGH,
         ORG_NUM,
         CUST_ID,
         CUST_NAME_SOURCE,
         CUST_ID_NO_SOURCE
    FROM PBOCD_JS_102_TYKHXX_SQ
   WHERE CJRQ = VS_LAST_TEXT /*AND FRNBJGH = '990000'*/--20231130wxb
  MINUS
  SELECT ORG_CODE,
         CUST_NAME,
         CUST_ID_NO,
         CUST_ORG_ID,
         BASIC_ACCOUNT,
         BASIC_ACCOUNT_BANK,
         REG_REGION_CODE,
         CUST_TYPE,
         OPEN_DATE,
         RELATED_FLG,
         CUST_NO,
         REG_ADDRESS,
         CTRL_ECO_ELEM,
         CREDIT_RATE_NUM,
         CREDIT_RATING,
         NBJGH,
         BIZ_LINE_ID,
         DEPT_TYPE,
         FRNBJGH,
         ORG_NUM,
         CUST_ID,
         CUST_NAME_SOURCE,
         CUST_ID_NO_SOURCE
    FROM JS_102_TYKHXX_ALL;
COMMIT;

--删除目标表中的变量数据
DELETE FROM JS_102_TYKHXX_ALL A
 WHERE EXISTS (SELECT 1
          FROM JS_102_TYKHXX_TMP1 B
         WHERE A.CUST_ID_NO = B.CUST_ID_NO
          AND A.FRNBJGH=B.FRNBJGH);--20231124WXB防止删除总行数据，新增AND A.FRNBJGH=B.FRNBJGH
COMMIT;

--将增变量数据插入到目标表
INSERT INTO JS_102_TYKHXX_ALL
  SELECT *
    FROM PBOCD_JS_102_TYKHXX_SQ A
   WHERE A.CJRQ = VS_LAST_TEXT /*AND FRNBJGH = '990000'*/--支持多法人20231124wxb
     AND EXISTS (SELECT 1
            FROM JS_102_TYKHXX_TMP1 B
           WHERE A.CUST_ID_NO = B.CUST_ID_NO
            AND A.FRNBJGH=B.FRNBJGH);
COMMIT;

--保证数据唯一性
SELECT COUNT(1) INTO VS_COUNT1 FROM JS_102_TYKHXX_ALL;
SELECT COUNT(DISTINCT CUST_ID_NO) INTO VS_COUNT2 FROM JS_102_TYKHXX_ALL;

IF VS_COUNT1 > VS_COUNT2 THEN
EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_102_TYKHXX_TMP2';

INSERT INTO JS_102_TYKHXX_TMP2
  SELECT DATA_DATE, -- 数据日期
         ORG_CODE, -- 金融机构代码
         CUST_NAME, -- 上报客户名称
         CUST_ID_NO, -- 上报客户代码
         CUST_ORG_ID, -- 上报客户金融机构编码
         BASIC_ACCOUNT, -- 基本存款账号
         BASIC_ACCOUNT_BANK, -- 基本账户开户行名称
         REG_REGION_CODE, -- 地区代码
         CUST_TYPE, -- 客户类别
         OPEN_DATE, -- 成立日期
         RELATED_FLG, -- 是否关联方
         CUST_NO, -- 客户内部编号
         REG_ADDRESS, -- 注册地址
         CTRL_ECO_ELEM, -- 客户经济成分
         CREDIT_RATE_NUM, -- 客户信用级别总等级数
         CREDIT_RATING, -- 客户信用评级
         REPORT_ID, -- 报表ID
         CJRQ, -- 采集日期
         NBJGH, -- 内部机构号
         BIZ_LINE_ID, -- 业务条线
         VERIFY_STATUS, -- 校验状态
         BSCJRQ, -- 报送采集日期
         DEPT_TYPE, -- 客户国民经济部门
         FRNBJGH, -- 法人内部机构号
         ORG_NUM, -- 内部机构号
         CUST_ID, -- 客户号
         CUST_NAME_SOURCE, -- 原客户名称
         CUST_ID_NO_SOURCE -- 原客户代码
    FROM /*(SELECT A.*,
                 ROW_NUMBER() OVER(PARTITION BY CUST_ID_NO ORDER BY CJRQ DESC) RN
            FROM JS_102_TYKHXX_ALL A)*/
           (SELECT A.*,
                ROW_NUMBER() OVER(PARTITION BY CUST_ID_NO,FRNBJGH ORDER BY CJRQ DESC) RN
           FROM JS_102_TYKHXX_ALL A)--20231124wxb
   WHERE RN = 1;
   COMMIT;

  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_102_TYKHXX_ALL';
  INSERT INTO JS_102_TYKHXX_ALL SELECT * FROM JS_102_TYKHXX_TMP2;
   COMMIT;
END IF;
  -------------------------------------------------------------------------
  OI_RETCODE := 0; --设置异常状态为0 成功状态
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
    --插入日志表，记录错误
    SP_PBOCD_LOG(VS_OWNER,
                 VS_PROCEDURE_NAME,
                 'ERROR',
                 VI_ERRORCODE,
                 VS_TEXT);
END;
/

