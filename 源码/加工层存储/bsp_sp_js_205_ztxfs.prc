CREATE OR REPLACE PROCEDURE BSP_SP_JS_205_ZTXFS(IS_DATE    IN VARCHAR2,
                                                  OI_RETCODE OUT INTEGER,
                                                  OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  --    SP_JS_205_ZTXFS
  -- 用途:生成接口表 JS_205_ZTXFS 再贴现发生额信息表
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    CAEATE BY USER AT 20220128
  --    MODFY BY DW AT 20220802 增加磐石机构上期数据
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段 上线日期：2025-04-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  --    需求编号：JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段 上线日期：2025-12-30，修改人：周立鹏，提出人：李楠   修改原因：剔除特殊处理
  ------------------------------------------------------------------------------------------------------

      VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
      VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
      VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
      VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
      VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
      VS_STEP           VARCHAR2(10); --存储过程执行步骤标志

BEGIN
      VS_TEXT      := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
      VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1), 'YYYYMMDD');

      
      -- 记录日志使用
      SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
      VS_PROCEDURE_NAME := 'SP_JS_205_ZTXFS';
      -- 开始日志
      VS_STEP := 'START';
      SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

  -------------------------------------------------------------------------



      EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_205_ZTXFS_TMP2';


      INSERT INTO JS_205_ZTXFS_TMP2
      SELECT
1 AS ID,
T.data_date,
T.org_code,
T.org_num,
T.reg_region_code,
T.bill_num,
T.bill_type,
T.bill_medium,
T.open_date,
T.bill_due_date,
T.discount_date,
T.rediscount_due_date,
T.trans_date,
T.drawer_name,
T.drawer_id_type,
T.drawer_id_no,
T.accept_name,
T.accept_id_type,
T.accept_id_no,
T.bill_curr_code,
T.bill_amt,
T.bill_amt_rmb,
T.rediscount_int_rate,
T.rediscount_curr_code,
T.rediscount_bal,
T.rediscount_bal_rmb,
T.report_id,
T.cjrq,
T.biz_line_id,
T.verify_status,
T.bscjrq,
T.frnbjgh,
T.nbjgh
      FROM PBOCD_DATACORE.PBOCD_JS_205_CLZTX T
      WHERE T.CJRQ =IS_DATE
      AND NOT EXISTS (
          SELECT 1 FROM PBOCD_JS_205_CLZTX_SQ F WHERE F.CJRQ =VS_LAST_TEXT AND T.BILL_NUM =F.BILL_NUM   --总行上期数据
          )
      UNION
      SELECT 0,
T.data_date,
T.org_code,
T.org_num,
T.reg_region_code,
T.bill_num,
T.bill_type,
T.bill_medium,
T.open_date,
T.bill_due_date,
T.discount_date,
T.rediscount_due_date,
T.trans_date,
T.drawer_name,
T.drawer_id_type,
T.drawer_id_no,
T.accept_name,
T.accept_id_type,
T.accept_id_no,
T.bill_curr_code,
T.bill_amt,
T.bill_amt_rmb,
T.rediscount_int_rate,
T.rediscount_curr_code,
T.rediscount_bal,
T.rediscount_bal_rmb,
T.report_id,
T.cjrq,
T.biz_line_id,
T.verify_status,
T.bscjrq,
T.frnbjgh,
T.nbjgh

FROM  (
select
T.data_date,
T.org_code,
T.org_num,
T.reg_region_code,
T.bill_num,
T.bill_type,
T.bill_medium,
T.open_date,
T.bill_due_date,
T.discount_date,
T.rediscount_due_date,
T.trans_date,
T.drawer_name,
T.drawer_id_type,
T.drawer_id_no,
T.accept_name,
T.accept_id_type,
T.accept_id_no,
T.bill_curr_code,
T.bill_amt,
T.bill_amt_rmb,
T.rediscount_int_rate,
T.rediscount_curr_code,
T.rediscount_bal,
T.rediscount_bal_rmb,
T.report_id,
T.cjrq,
T.biz_line_id,
T.verify_status,
T.bscjrq,
T.frnbjgh,
T.nbjgh

from PBOCD_JS_205_CLZTX_SQ T
             WHERE T.CJRQ =VS_LAST_TEXT  --总行上期数据
      ) T
      WHERE T.CJRQ =VS_LAST_TEXT
      AND NOT EXISTS (
          SELECT 1 FROM  PBOCD_DATACORE.PBOCD_JS_205_CLZTX F WHERE F.CJRQ =IS_DATE AND T.BILL_NUM =F.BILL_NUM
       );
      COMMIT;

      DELETE FROM JS_205_ZTXFS WHERE CJRQ = IS_DATE;
      INSERT INTO JS_205_ZTXFS  (
             DATA_DATE --数据日期
             ,ORG_CODE   --金融机构代码
             ,ORG_NUM   --内部机构号
             ,REG_REGION_CODE  --金融机构地区代码
             ,BILL_NUM  --票据编号
             ,BILL_TYPE  --票据种类
             ,BILL_MEDIUM  --票据介质
             ,OPEN_DATE   --出票日期
             ,BILL_DUE_DATE  --票据到期日期
             ,DISCOUNT_DATE  --贴现日期
             ,REDISCOUNT_DUE_DATE  --回购到期日期
             ,TRANS_DATE  --交易日期
             ,DRAWER_NAME  --出票人名称
             ,DRAWER_ID_TYPE  --出票人证件类型
             ,DRAWER_ID_NO  --出票人证件代码
             ,ACCEPT_NAME  --承兑人名称
             ,ACCEPT_ID_TYPE  --承兑人证件类型
             ,ACCEPT_ID_NO  --承兑人证件代码
             ,BILL_CURR_CODE  --币种
             ,BILL_AMT  --票面金额
             ,BILL_AMT_RMB  --票面金额折人民币
             ,REDISCOUNT_INT_RATE  --再贴现利率
             ,REDISCOUNT_CURR_CODE  --再贴现币种
             ,REDISCOUNT_AMT  --再贴现金额
             ,REDISCOUNT_AMT_RMB  --再贴现金额折人民币
             ,TRANS_TYPE  --交易方向
             ,SERIAL_NO  --交易流水号
             ,CJRQ
      )
      SELECT
             VS_TEXT DATA_DATE,
             ORG_CODE,
             ORG_NUM,
             REG_REGION_CODE,
             BILL_NUM,
             BILL_TYPE,
             BILL_MEDIUM,
             OPEN_DATE,
             BILL_DUE_DATE,
             DISCOUNT_DATE,
             REDISCOUNT_DUE_DATE,
             TRANS_DATE,
             DRAWER_NAME,
             DRAWER_ID_TYPE,
             DRAWER_ID_NO,
             ACCEPT_NAME,
             ACCEPT_ID_TYPE,
             ACCEPT_ID_NO,
             BILL_CURR_CODE,
             BILL_AMT,
             BILL_AMT_RMB,
             REDISCOUNT_INT_RATE,
             REDISCOUNT_CURR_CODE,
             
             --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 再贴现金额：发生方向与存量一致，收回方向=票面金额
             /*REDISCOUNT_BAL REDISCOUNT_AMT,
             REDISCOUNT_BAL_RMB REDISCOUNT_AMT_RMB,*/
             CASE WHEN ID = '1' THEN REDISCOUNT_BAL ELSE BILL_AMT END AS DISCOUNT_AMT,--再贴现金额
             CASE WHEN ID = '1' THEN REDISCOUNT_BAL_RMB ELSE BILL_AMT_RMB END AS REDISCOUNT_BAL_RMB,--再贴现金额折人民币
           
             ID TRANS_TYPE,
             SYS_GUID() SERIAL_NO,
             IS_DATE CJRQ
      FROM JS_205_ZTXFS_TMP2 A
      ;
      COMMIT;
-------------------吉林银行目标表数据--------------------
      ---清除历史数据
      DELETE FROM PBOCD_JS_205_ZTXFS WHERE CJRQ = IS_DATE;
      COMMIT;

      INSERT INTO PBOCD_JS_205_ZTXFS (
             DATA_DATE --数据日期
             ,ORG_CODE   --金融机构代码
             ,ORG_NUM   --内部机构号
             ,REG_REGION_CODE  --金融机构地区代码
             ,BILL_NUM  --票据编号
             ,BILL_TYPE  --票据种类
             ,BILL_MEDIUM  --票据介质
             ,OPEN_DATE   --出票日期
             ,BILL_DUE_DATE  --票据到期日期
             ,DISCOUNT_DATE  --贴现日期
             ,REDISCOUNT_DUE_DATE  --回购到期日期
             ,TRANS_DATE  --交易日期
             ,DRAWER_NAME  --出票人名称
             ,DRAWER_ID_TYPE  --出票人证件类型
             ,DRAWER_ID_NO  --出票人证件代码
             ,ACCEPT_NAME  --承兑人名称
             ,ACCEPT_ID_TYPE  --承兑人证件类型
             ,ACCEPT_ID_NO  --承兑人证件代码
             ,BILL_CURR_CODE  --币种
             ,BILL_AMT  --票面金额
             ,BILL_AMT_RMB  --票面金额折人民币
             ,REDISCOUNT_INT_RATE  --再贴现利率
             ,REDISCOUNT_CURR_CODE  --再贴现币种
             ,REDISCOUNT_AMT  --再贴现金额
             ,REDISCOUNT_AMT_RMB  --再贴现金额折人民币
             ,TRANS_TYPE  --交易方向
             ,SERIAL_NO  --交易流水号
             ,report_id
             ,CJRQ
             ,biz_line_id
             ,verify_status
             ,bscjrq
             ,frnbjgh
             ,nbjgh
      )
      SELECT
             VS_TEXT --数据日期
             ,NVL(OB.ID_NO,OB.UP_ID_NO) --金融机构代码
             ,T.ORG_NUM   --内部机构号--,REG_REGION_CODE  --金融机构地区代码
             ,OB.REGION_CD --3  金融机构地区代码
             ,BILL_NUM  --票据编号
             ,BILL_TYPE  --票据种类
             ,BILL_MEDIUM  --票据介质
             ,OPEN_DATE   --出票日期
             ,BILL_DUE_DATE  --票据到期日期
             ,DISCOUNT_DATE  --贴现日期
             ,REDISCOUNT_DUE_DATE  --回购到期日期
             ,TRANS_DATE  --交易日期
             ,DRAWER_NAME  --出票人名称
             ,DRAWER_ID_TYPE  --出票人证件类型
             ,DRAWER_ID_NO  --出票人证件代码
             ,ACCEPT_NAME  --承兑人名称
             ,ACCEPT_ID_TYPE  --承兑人证件类型
             ,ACCEPT_ID_NO  --承兑人证件代码
             ,BILL_CURR_CODE  --币种
             ,BILL_AMT  --票面金额
             ,BILL_AMT_RMB  --票面金额折人民币
             ,REDISCOUNT_INT_RATE  --再贴现利率
             ,REDISCOUNT_CURR_CODE  --再贴现币种
             ,REDISCOUNT_AMT  --再贴现金额
             ,REDISCOUNT_AMT_RMB  --再贴现金额折人民币
             ,TRANS_TYPE  --交易方向
             ,SERIAL_NO  --交易流水号
             ,SYS_GUID() report_id
             ,IS_DATE
             ,
                CASE WHEN T.ORG_NUM LIKE '51%' THEN '99'
                   WHEN T.ORG_NUM LIKE '52%' THEN '99'
                   WHEN T.ORG_NUM LIKE '53%' THEN '99'
                   WHEN T.ORG_NUM LIKE '54%' THEN '99'
                   WHEN T.ORG_NUM LIKE '55%' THEN '99'
                   WHEN T.ORG_NUM LIKE '56%' THEN '99'
                   WHEN T.ORG_NUM LIKE '57%' THEN '99'
                   WHEN T.ORG_NUM LIKE '58%' THEN '99'
                   WHEN T.ORG_NUM LIKE '59%' THEN '99'
                   WHEN T.ORG_NUM LIKE '60%' THEN '99'
                   WHEN T.ORG_NUM = '009804' THEN 'SC'
                   ELSE '99' END biz_line_id--业务条线 20231013  王晓彬
             ,verify_status
             ,bscjrq
         ,
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
            '600000'----20231013王晓彬
           ELSE '990000'
             END FRNBJGH

             ,T.ORG_NUM nbjgh
      FROM JS_205_ZTXFS T
      LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=T.ORG_NUM AND OB.DATA_DATE=IS_DATE
      WHERE CJRQ = IS_DATE;

      COMMIT;  

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
--交易日期不在当月且回购到期日期在当月范围内的，交易日期改成回购到期日期
/*update PBOCD_JS_205_ZTXFS
   set trans_date = rediscount_due_date
 where cjrq = IS_DATE
   and substr(trans_date, 1, 7) <> substr(VS_TEXT, 1, 7)
   and substr(rediscount_due_date, 1, 7) = substr(VS_TEXT, 1, 7);
commit;

--公主岭地区代码
UPDATE PBOCD_JS_205_ZTXFS
   SET REG_REGION_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND REG_REGION_CODE = '220381';
COMMIT;*/

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