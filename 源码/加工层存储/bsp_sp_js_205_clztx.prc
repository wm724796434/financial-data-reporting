CREATE OR REPLACE PROCEDURE BSP_SP_JS_205_CLZTX(IS_DATE    IN VARCHAR2,
                                                  OI_RETCODE OUT INTEGER,
                                                  OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  --    SP_JS_205_CLZTX
  -- 用途:生成接口表 JS_205_CLZTX 存量再贴现信息表
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    CAEATE BY USER AT 20220128
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段 上线日期：2025-04-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  --VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
  NUM               INTEGER;

BEGIN
  VS_TEXT      := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  --VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');
  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_205_CLZTX';
  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------






    --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'JS_205_CLZTX'
     AND PARTITION_NAME = 'JS_205_CLZTX_' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE JS_205_CLZTX ADD PARTITION JS_205_CLZTX_' ||
                      IS_DATE || ' VALUES (' || IS_DATE || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE JS_205_CLZTX TRUNCATE PARTITION JS_205_CLZTX_' ||
                    IS_DATE;
INSERT INTO JS_205_CLZTX
(
DATA_DATE  --数据日期
,ORG_CODE  --金融机构代码
,ORG_NUM  --内部机构号
,REG_REGION_CODE  --金融机构地区代码
,BILL_NUM    --票据编号
,BILL_TYPE  --票据种类
,BILL_MEDIUM  --票据介质
,OPEN_DATE  --出票日期
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
,REDISCOUNT_BAL  --再贴现金额
,REDISCOUNT_BAL_RMB  --再贴现金额折人民币
,CJRQ
)
select /*+ PARALLEL(4)*/
 IS_DATE     --数据日期
,'' JRJGBM    --金融机构
,A.ORG_NUM   --机构号
,'' AREA_ID   --地区代码
,A.BILL_NUM --票据编号
,CASE WHEN TRIM(B.BILL_TYPE) = '1' THEN '01' --银行承兑汇票
      WHEN B.BILL_TYPE = '2' THEN '02' --商业承兑汇票
       END AS BILL_TYPE  --票据种类
,CASE WHEN B.IS_P_BILL = 'Y' THEN '01'
      ELSE '02' END AS BILL_MEDIUM --票据介质 01 纸票 02 电票
,TO_CHAR(B.OPEN_DATE, 'YYYY-MM-DD')--出票日期
,TO_CHAR(B.MATU_DATE, 'YYYY-MM-DD')--票据到期日期
--,TO_CHAR(NVL(F.DRAWDOWN_DT,G.TX_DATE),'YYYY-MM-DD') AS DISCOUNT_DATE --贴现日期
,TO_CHAR(F.DRAWDOWN_DT,'YYYY-MM-DD') AS DISCOUNT_DATE --贴现日期
,TO_CHAR(A.MATURE_DATE,'YYYY-MM-DD') AS REDISCOUNT_DUE_DATE--回购到期日期
,TO_CHAR(A.START_DATE,'YYYY-MM-DD') AS TRANS_DATE --交易日期
,B.AFF_NAME AS DRAWER_NAME--出票人名称
,''--CD1.PBOCD_CODE--出票人证件类型 --******
,''--B.ID_NO--出票人证件代码        --******
,NVL2(FR.FINA_ORG_NAME_FR,FR.FINA_ORG_NAME_FR,B.PAY_BANK_NAME) --承兑人名称
,'A01'--承兑人证件类型
--,trim(B.BILLS_COMMIT_ORG_ID_NO) --承兑人证件代码
,NVL2(FR.FINA_ORG_NAME_FR,FR.LEGAL_TYSHXYDM_FR,B.BILLS_COMMIT_ORG_ID_NO) --承兑人证件代码
,trim(B.CURR_CD)--币种
,A.BALANCE --B.AMOUNT--票面金额
,A.BALANCE * R.CCY_RATE -- B.AMOUNT *R.CCY_RATE  --票面金额折人民币
,NVL(A.REAL_INT_RAT,0)*100 AS REDISCOUNT_INT_RATE --再贴现利率
,A.CURR_CD AS REDISCOUNT_CURR_CODE --再贴现币种
,A.BALANCE - A.ACCRUAL AS REDISCOUNT_BAL --再贴现金额
,(A.BALANCE - A.ACCRUAL) *Z.CCY_RATE    AS REDISCOUNT_BAL_RMB --再贴现金额折人民币
,IS_DATE
FROM SMTMODS.L_ACCT_FUND_MMFUND A --投资业务信息表
LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B --商业汇票票面信息表
  ON A.BILL_NUM = B.BILL_NUM

 AND B.DATA_DATE = IS_DATE

  --MODIFY BY DW(20220317) 关键借据表时数据重复，根据合同号取重
LEFT JOIN (
     select F.*,ROW_NUMBER() OVER(PARTITION BY f.acct_num ORDER BY f.drawdown_dt DESC  ) RN  from SMTMODS.L_ACCT_LOAN f
     where F.DATA_DATE = IS_DATE
) F --贷款借据信息表
  ON A.BILL_NUM = F.acct_num
 AND F.RN = 1
 AND F.DATA_DATE = IS_DATE
/*LEFT JOIN SMTMODS.L_ACCT_FUND_INVEST G --投资业务信息表
  ON A.BILL_NUM = G.ACCT_NUM
 AND G.DATA_DATE = IS_DATE*/
/*LEFT JOIN L_CODE_DICTIONARY CD1
  ON B.id_type = CD1.L_CODE
 AND CD1.CODE_CLMN_NAME = 'ID_TYPE'*/
LEFT JOIN SMTMODS.L_PUBL_RATE Z --汇率信息表
  ON Z.DATA_DATE = IS_DATE
 AND Z.BASIC_CCY = trim(A.CURR_CD)
 AND Z.FORWARD_CCY = 'CNY'
 AND Z.DATA_DATE = IS_DATE
LEFT JOIN SMTMODS.L_PUBL_RATE R --汇率信息表
  ON R.DATA_DATE = IS_DATE
 AND R.BASIC_CCY = trim(B.CURR_CD)
 AND R.FORWARD_CCY = 'CNY'
 AND R.DATA_DATE = IS_DATE

LEFT JOIN (SELECT * FROM(
SELECT A.CUST_ID,A.FINA_ORG_CODE,A.FINA_ORG_NAME,B.FINA_ORG_NAME FINA_ORG_NAME_FR,B.LEGAL_TYSHXYDM LEGAL_TYSHXYDM_FR ,
ROW_NUMBER()OVER(PARTITION BY A.FINA_ORG_NAME,A.FINA_ORG_CODE ORDER BY A.FINA_ORG_NAME) RN
FROM (SELECT * FROM (
SELECT CUST_ID,FINA_ORG_CODE,FINA_ORG_NAME,TYSHXYDM,LEGAL_TYSHXYDM,ROW_NUMBER() OVER(PARTITION BY FINA_ORG_NAME,FINA_ORG_CODE ORDER BY TYSHXYDM) RN
FROM SMTMODS.L_CUST_BILL_TY A WHERE A.DATA_DATE=IS_DATE)A WHERE A.RN=1)A

LEFT JOIN (SELECT * FROM (
SELECT A.*,ROW_NUMBER() OVER(PARTITION BY TYSHXYDM ORDER BY FINA_ORG_NAME) RN
FROM SMTMODS.L_CUST_BILL_TY A WHERE DATA_DATE=IS_DATE AND LEGAL_FLAG='Y'
AND TYSHXYDM IS NOT NULL AND TYSHXYDM<>'000000000000000000'
AND FINA_ORG_NAME NOT LIKE '%存托%' AND FINA_ORG_NAME NOT LIKE '%资管%' AND FINA_ORG_NAME NOT LIKE '%禁用%'
) A WHERE A.RN=1) B
ON A.LEGAL_TYSHXYDM=B.TYSHXYDM) WHERE RN = 1)FR
ON B.PAY_BANK_ID = FR.FINA_ORG_CODE

WHERE A.DATA_DATE = IS_DATE
 AND  A.ACCT_TYP IN ('20303','20304')
 AND A.BALANCE>0;
 COMMIT;

-------------------吉林银行目标表数据--------------------
---清除历史数据
DELETE FROM PBOCD_JS_205_CLZTX
 WHERE DATA_DATE = TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
COMMIT;
 ---以下包含原应用层加工逻辑，现都放在加工层处理
INSERT INTO  PBOCD_JS_205_CLZTX(
DATA_DATE  --数据日期
,ORG_CODE  --金融机构代码
,ORG_NUM  --内部机构号
,REG_REGION_CODE  --金融机构地区代码
,BILL_NUM    --票据编号
,BILL_TYPE  --票据种类
,BILL_MEDIUM  --票据介质
,OPEN_DATE  --出票日期
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
,REDISCOUNT_BAL  --再贴现金额
,REDISCOUNT_BAL_RMB  --再贴现金额折人民币
,REPORT_ID
,CJRQ
,BIZ_LINE_ID
,VERIFY_STATUS
,BSCJRQ
,FRNBJGH
,NBJGH
)
SELECT /*+ PARALLEL(4)*/
VS_TEXT  --数据日期
,NVL(OB.ID_NO,OB.UP_ID_NO) --金融机构代码
,T.ORG_NUM  --内部机构号
,OB.REGION_CD --3  金融机构地区代码
,BILL_NUM    --票据编号
,BILL_TYPE  --票据种类
,BILL_MEDIUM  --票据介质
,OPEN_DATE  --出票日期
,BILL_DUE_DATE  --票据到期日期
,DISCOUNT_DATE  --贴现日期
,REDISCOUNT_DUE_DATE  --回购到期日期
,TRANS_DATE  --交易日期
,DRAWER_NAME  --出票人名称
,DRAWER_ID_TYPE  --出票人证件类型
,DRAWER_ID_NO  --出票人证件代码
,ACCEPT_NAME  --承兑人名称
,ACCEPT_ID_TYPE  --承兑人证件类型
,TRIM(ACCEPT_ID_NO)  --承兑人证件代码
,BILL_CURR_CODE  --币种
,BILL_AMT  --票面金额
,BILL_AMT_RMB  --票面金额折人民币
,REDISCOUNT_INT_RATE  --再贴现利率
,REDISCOUNT_CURR_CODE  --再贴现币种
,REDISCOUNT_BAL  --再贴现金额
,REDISCOUNT_BAL_RMB  --再贴现金额折人民币
,SYS_GUID()
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
      WHEN T.ORG_NUM='009804' THEN 'SC'
      ELSE '99' END AS BIZ_LINE_ID  --业务条线 20230919 王晓彬
,''
,''
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
            '600000'----20230620多法人新增
           ELSE '990000'
             END FRNBJGH
,T.ORG_NUM
FROM   JS_205_CLZTX T
 LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=trim(T.ORG_NUM) AND OB.DATA_DATE=IS_DATE
WHERE TRIM(T.DATA_DATE)=IS_DATE;
COMMIT;

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
/*UPDATE PBOCD_JS_205_CLZTX SET DRAWER_NAME='吉林省通用机械(集团)有限责任公司'
WHERE CJRQ=IS_DATE AND DRAWER_NAME='吉林省通用机械（集团）有限责任公司';
COMMIT;
UPDATE PBOCD_JS_205_CLZTX SET DRAWER_NAME='陕西延长石油(集团)有限责任公司'
WHERE CJRQ=IS_DATE AND DRAWER_NAME='陕西延长石油（集团）有限责任公司';
COMMIT;
UPDATE PBOCD_JS_205_CLZTX SET DRAWER_NAME='双胞胎(集团)股份有限公司'
WHERE CJRQ=IS_DATE AND DRAWER_NAME='双胞胎（集团）股份有限公司';
COMMIT;
UPDATE PBOCD_JS_205_CLZTX SET DRAWER_NAME='山西潞安矿业(集团)有限责任公司'
WHERE CJRQ=IS_DATE AND DRAWER_NAME='山西潞安矿业（集团）有限责任公司';
COMMIT;
UPDATE PBOCD_JS_205_CLZTX SET DRAWER_NAME='大连福佳·大化石油化工有限公司'
WHERE CJRQ=IS_DATE AND DRAWER_NAME='大连福佳.大化石油化工有限公司';
COMMIT;*/

/*--在L_CUST_BILL_TY中个人转不了的，写死
UPDATE PBOCD_JS_205_CLZTX SET ACCEPT_NAME='招商银行股份有限公司'
WHERE CJRQ=IS_DATE AND ACCEPT_NAME='招商银行股份有限公司票据业务部' AND ACCEPT_ID_NO='9144030010001686XA';
COMMIT;

UPDATE PBOCD_JS_205_CLZTX SET ACCEPT_NAME='邢台银行股份有限公司',ACCEPT_ID_NO='91130500601199086Y'
WHERE CJRQ=IS_DATE AND ACCEPT_NAME LIKE '邢台银行股份有限公司%';
COMMIT;

UPDATE PBOCD_JS_205_CLZTX SET ACCEPT_NAME='江苏江南农村商业银行股份有限公司'
WHERE CJRQ=IS_DATE AND ACCEPT_NAME='江苏江南农村商业银行股份有限公司(不对外)' AND ACCEPT_ID_NO='91320400699343815D';
COMMIT;*/

/*--公主岭地区代码
UPDATE PBOCD_JS_205_CLZTX
   SET REG_REGION_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND REG_REGION_CODE = '220381';
COMMIT;
*/
  VS_STEP := '2';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

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
