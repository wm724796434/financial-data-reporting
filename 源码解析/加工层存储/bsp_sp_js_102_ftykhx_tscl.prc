CREATE OR REPLACE PROCEDURE BSP_SP_JS_102_FTYKHX_TSCL(IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_102_FTYKHX_TSCL
  -- 业务域: 客户信息类
  -- 用途: 生成接口表 JS_102_FTYKHX  非同业单位客户信息_特殊处理
  -- 参数
  --    IS_DATE 输入，传入跑批日期
  --    OI_RETCODE 输出，用来标识存储过程执行过程中是否出现异常
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
  SELECT VS_TEXT DATA_DATE, -- → DATA_DATE  数据日期（入参IS_DATE格式化为YYYY-MM-DD）
         ORG_CODE, -- → ORG_CODE  金融机构代码（取自A.ORG_CODE）
         CUST_NAME, -- → CUST_NAME  客户名称（取自A.CUST_NAME）
         CUST_ID_NO, -- → CUST_ID_NO  客户证件号码（取自A.CUST_ID_NO）
         BASIC_ACCOUNT, -- → BASIC_ACCOUNT  基本存款账号（取自A.BASIC_ACCOUNT）
         BASIC_ACCOUNT_BANK, -- → BASIC_ACCOUNT_BANK  基本账户开户行名称（取自A.BASIC_ACCOUNT_BANK）
         CAPITAL_AMT, -- → CAPITAL_AMT  注册资本（取自A.CAPITAL_AMT）
         PAICL_UP_CAP, -- → PAICL_UP_CAP  实收资本（取自A.PAICL_UP_CAP）
         TOTAL_ASSET, -- → TOTAL_ASSET  总资产（取自A.TOTAL_ASSET）
         OPERATE_INCOME, -- → OPERATE_INCOME  营业收入（取自A.OPERATE_INCOME）
         LIST_FLG, -- → LIST_FLG  是否上市公司（取自A.LIST_FLG）
         FIRST_CREDIT_DATA, -- → FIRST_CREDIT_DATA  首次建立信贷关系日期（取自A.FIRST_CREDIT_DATA）
         STAFF_NUM, -- → STAFF_NUM  从业人员数（取自A.STAFF_NUM）
         REG_ADDRESS, -- → REG_ADDRESS  注册地址（取自A.REG_ADDRESS）
         REG_REGION_CODE, -- → REG_REGION_CODE  地区代码（取自A.REG_REGION_CODE）
         BUSI_STATUS, -- → BUSI_STATUS  经营状态（取自A.BUSI_STATUS）
         OPEN_DATE, -- → OPEN_DATE  成立日期（取自A.OPEN_DATE）
         INDUSTRY_TYPE, -- → INDUSTRY_TYPE  所属行业（取自A.INDUSTRY_TYPE）
         ENT_SCALE, -- → ENT_SCALE  企业规模（取自A.ENT_SCALE）
         FACILITY_AMT, -- → FACILITY_AMT  授信额度（取自A.FACILITY_AMT）
         USED_FACILITY_AMT, -- → USED_FACILITY_AMT  已用额度（取自A.USED_FACILITY_AMT）
         RELATED_FLG, -- → RELATED_FLG  是否关联方（取自A.RELATED_FLG）
         ACTR_CTRL_ID_TYPE, -- → ACTR_CTRL_ID_TYPE  实际控制人证件类型（取自A.ACTR_CTRL_ID_TYPE）
         ACTR_CTRL_ID_NO, -- → ACTR_CTRL_ID_NO  实际控制人证件代码（取自A.ACTR_CTRL_ID_NO）
         CUST_ID_TYPE, -- → CUST_ID_TYPE  客户证件类型（取自A.CUST_ID_TYPE）
         BUSI_SCOPE, -- → BUSI_SCOPE  经营范围（取自A.BUSI_SCOPE）
         CTRL_ECO_ELEM, -- → CTRL_ECO_ELEM  客户经济成分（取自A.CTRL_ECO_ELEM）
         DEPT_TYPE, -- → DEPT_TYPE  客户国民经济部门（取自A.DEPT_TYPE）
         CREDIT_RATE_NUM, -- → CREDIT_RATE_NUM  客户信用级别总等级数（取自A.CREDIT_RATE_NUM）
         CREDIT_RATING, -- → CREDIT_RATING  客户信用评级（取自A.CREDIT_RATING）
         SYS_GUID() REPORT_ID, -- → REPORT_ID  报告ID（系统生成GUID）
         IS_DATE CJRQ, -- → CJRQ  采集日期（入参IS_DATE YYYYMMDD格式）
         NBJGH, -- → NBJGH  内部机构号（取自A.NBJGH）
         BIZ_LINE_ID, -- → BIZ_LINE_ID  业务条线ID（取自A.BIZ_LINE_ID）
         '' VERIFY_STATUS, -- → VERIFY_STATUS  验证状态（固定空值）
         '' BSCJRQ, -- → BSCJRQ  报送采集日期（固定空值）
         FRNBJGH, -- → FRNBJGH  法人机构号（取自A.FRNBJGH）
         ORG_NUM, -- → ORG_NUM  机构序号（取自A.ORG_NUM）
         CUST_ID -- → CUST_ID  客户ID（取自A.CUST_ID）
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

