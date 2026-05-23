CREATE OR REPLACE PROCEDURE BSP_SP_JS_205_CLYHCD(IS_DATE    IN VARCHAR2,
                                                  OI_RETCODE OUT INTEGER,
                                                  OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  --    SP_JS_205_CLYHCD
  -- 用途:生成接口表 JS_205_CLYHCD 存量银行承兑
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    CAEATE BY USER AT 20220128
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段 上线日期：2025-04-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段 上线日期：2025-05-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  --    需求编号：JLBA202504170013_关于在监管集市修改部分字段取数逻辑的需求  上线日期：2025-06-19，修改人：白杨，提出人：李楠   修改原因：填补部分空值字段
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_四阶段 上线日期：2025-09-18，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  --    需求编号：JLBA202510210010_关于金数平台银承部分报表取数规则及展示的优化的需求 上线日期：2026-04-21，修改人：周立鹏，提出人：孙平刚   修改原因：优化收款人证件类型、号码取数口径
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  --VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
  --NUM               INTEGER;

BEGIN
  VS_TEXT      := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  --VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');
  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_205_CLYHCD';
  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------

EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_205_CLYHCD_TMP2';

--房产抵押贷款方式
INSERT INTO JS_205_CLYHCD_TMP2
  SELECT /*+ use_hash(T,t2,t4,t5,t7,t6) parallel(4)*/
  DISTINCT T4.CONTRACT_NUM, --4  被担保合同编码
           '' --6  担保物类别
    FROM SMTMODS.L_AGRE_GUARANTY_INFO T --抵押物
   INNER JOIN SMTMODS.L_AGRE_GUARANTEE_RELATION T2 --抵押物与担保合同对应关系表
      ON T.GUARANTEE_SERIAL_NUM = T2.GUARANTEE_SERIAL_NUM
     AND T2.DATA_DATE = IS_DATE
     AND T2.REL_STATUS = 'Y'
   INNER JOIN SMTMODS.L_AGRE_GUA_RELATION T4 --业务合同与担保合同对应关系表
      ON T2.GUAR_CONTRACT_NUM = T4.GUAR_CONTRACT_NUM
     AND T4.DATA_DATE = IS_DATE
     AND T4.REL_STATUS = 'Y'
   INNER JOIN SMTMODS.L_AGRE_GUARANTEE_CONTRACT T1 --担保合同
      ON T2.GUAR_CONTRACT_NUM = T1.GUAR_CONTRACT_NUM
     AND T1.DATA_DATE = IS_DATE
     AND T1.GUAR_CONTRACT_STATUS = 'Y'

   INNER JOIN (SELECT ACCT_NO
                 FROM SMTMODS.L_ACCT_OBS_LOAN
                WHERE DATA_DATE = IS_DATE
                GROUP BY ACCT_NO) T5
      ON T4.CONTRACT_NUM = T5.ACCT_NO
   INNER JOIN SMTMODS.L_AGRE_LOAN_CONTRACT T7
      ON T4.CONTRACT_NUM = T7.CONTRACT_NUM
     AND T7.DATA_DATE = IS_DATE

   INNER JOIN SMTMODS.L_CUST_C T6
      ON T7.CUST_ID = T6.CUST_ID
     AND T6.DATA_DATE = IS_DATE --本期报送取对公
   WHERE T.DATA_DATE = IS_DATE
     AND TRIM(T.COLL_TYP) IN ('B01',
                              'B0101',
                              'B0102',
                              'B02',
                              'B0201',
                              'B0209',
                              'B03',
                              'B0301',
                              'B0302',
                              'B0501',
                              'B0502',
                              'B0509')
     AND T.COLL_STATUS = 'Y';
 COMMIT;


/*    --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'JS_205_CLYHCD'
     AND PARTITION_NAME = 'JS_205_CLYHCD_' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE JS_205_CLYHCD ADD PARTITION JS_205_CLYHCD_' ||
                      IS_DATE || ' VALUES (' || IS_DATE || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE JS_205_CLYHCD TRUNCATE PARTITION JS_205_CLYHCD_' ||
                    IS_DATE;*/

DELETE FROM PBOCD_JS_205_CLYHCD
   WHERE DATA_DATE = TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  COMMIT;
  
INSERT INTO PBOCD_JS_205_CLYHCD
  (DATA_DATE --数据日期
  ,
   ORG_CODE --金融机构代码
  ,
   ORG_NUM --内部机构号
  ,
   REG_REGION_CODE --金融机构地区代码
  ,
   DRAWER_NAME --出票人名称
  ,
   DRAWER_ID_TYPE --出票人证件类型
  ,
   DRAWER_ID_NO --出票人证件代码
  ,
   DRAWER_INDUSTRY_TYPE --出票人行业
  ,
   DRAWER_AREA_CODE --出票人地区代码
  ,
   DRAWER_CON_ECO_ELEM --出票人经济成分
  ,
   DRAWER_ENT_SCALE --出票人企业规模
  ,
   RECE_NAME --收款人名称
  ,
   RECE_ID_TYPE --收款人证件类型
  ,
   RECE_ID_NO --收款人证件代码
  ,
   BILL_NUM --票据编号
  ,
   BILL_MEDIUM --票据介质
  ,
   OPEN_DATE --出票日期
  ,
   BILL_DUE_DATE --票据到期日期
  ,
   BILL_CURR_CODE --币种
  ,
   BILL_AMT --票面金额
  ,
   BILL_AMT_RMB --票面金额折人民币
  ,
   FEE_AMT_RMB --手续费金额折人民币
  ,
   MARGIN_RATIO --保证金比例
  ,
   GUAR_TYPE --担保方式
  ,REPORT_ID
  ,CJRQ
  ,BIZ_LINE_ID
  ,VERIFY_STATUS
  ,BSCJRQ
  ,FRNBJGH
  ,NBJGH)
  select /*+ PARALLEL(4)*/ 
         VS_TEXT DATA_DATE --数据日期
        ,
         NVL(OB.ID_NO,OB.UP_ID_NO) JRJGBM --金融机构
        ,
         A.ORG_NUM --机构号
        ,
         OB.REGION_CD AREA_ID --地区代码
        ,
         B.AFF_NAME --出票人名称
        ,
         'A01' --出票人证件类型  --[2025-06-19] [白杨] [JLBA202504170013_关于在监管集市修改部分字段取数逻辑的需求 ][李楠] 修改为默认值'A01'
        ,
        F1.ID_NO --出票人证件代码  --[2025-06-19] [白杨] [JLBA202504170013_关于在监管集市修改部分字段取数逻辑的需求 ][李楠] 空值改成统一社会信用代码
        ,
         NVL2(D.CUST_ID, '100', SUBSTRB(TRIM(F.CORP_BUSINSESS_TYPE), 0, 3)) --出票人行业
        ,
         NVL2(D.CUST_ID, D.REGION_CD, F.REGION_CD) --出票人地区代码
        ,
         CD4.PBOCD_CODE --出票人经济成分
        ,
         NVL2(F.CUST_ID,
              DECODE(F.CORP_SCALE,
                     'B',
                     'CS01',
                     'M',
                     'CS02',
                     'S',
                     'CS03',
                     'T',
                     'CS04',
                     'CS05'),
              '') --出票人企业规模
        ,
         B.RECE_NAME --收款人名称
        --[2026-04-21] [周立鹏] [JLBA202510210010_关于金数平台银承部分报表取数规则及展示的优化的需求][孙平刚] 优化收款人证件类型、号码取数口径
        ,
         'A01' --收款人证件类型
        ,
         B.RECE_ID_NO --收款人证件代码
        ,
         A.ACCT_NUM --票据编号
        ,
         CASE
           WHEN B.IS_P_BILL = 'Y' THEN
            '01'
           ELSE
            '02'
         END AS BILL_MEDIUM --票据介质
        ,
         TO_CHAR(B.OPEN_DATE, 'YYYY-MM-DD') --出票日期
        ,
         TO_CHAR(B.MATU_DATE, 'YYYY-MM-DD') --票据到期日期
        ,
         trim(B.CURR_CD) --币种
        ,
         A.BALANCE -- B.AMOUNT --票面金额
        ,
         A.BALANCE * R.CCY_RATE --B.AMOUNT * R.CCY_RATE --票面金额折人民币
        ,
        (A.BALANCE * R.CCY_RATE) / 10000 * 5 --(B.AMOUNT * R.CCY_RATE) / 10000 * 5 --手续费金额折人民币 20220824 将手续费改为票据面额的万分之五
         --,A.COST_AMOUNT--手续费金额折人民币
        ,
         NVL(A.SECURITY_RATE,0) * 100 --保证金比例
        ,
         CASE
           WHEN DBFS.CN >= 2 AND DBW.BUSINESSCODE IS NOT NULL THEN
            'E01' --含房地产抵押的组合担保
           WHEN H.MAIN_GUARANTY_TYP = '1' AND DBW.BUSINESSCODE IS NOT NULL THEN
            'B01' --房产抵押贷款
           WHEN DBFS.CN >= 2 THEN
            'E' --组合贷款
           WHEN H.MAIN_GUARANTY_TYP = '1' AND NVL(SECURITY_AMT, 0) <> 0 THEN
            'E'
           WHEN H.MAIN_GUARANTY_TYP = '1' THEN
            'B99' --其他抵押
           WHEN H.MAIN_GUARANTY_TYP = '0' THEN
            'A' --质押贷款
           WHEN H.MAIN_GUARANTY_TYP = '2' AND NVL(SECURITY_AMT, 0) <> 0 THEN
            'E'
           WHEN H.MAIN_GUARANTY_TYP = '2' THEN
            'C99' --保证贷款
           WHEN H.MAIN_GUARANTY_TYP = '3' AND NVL(SECURITY_AMT, 0) <> 0 THEN
            'A'
           WHEN H.MAIN_GUARANTY_TYP = '3' THEN
            'D'
           ELSE
            'E'
         END AS GURT_TYPE --担保方式
        ,SYS_GUID() REPORT_ID
        ,IS_DATE CJRQ
        ,CASE
          WHEN A.ORG_NUM LIKE '51%' THEN '99'
          WHEN A.ORG_NUM LIKE '52%' THEN '99'
          WHEN A.ORG_NUM LIKE '53%' THEN '99'
          WHEN A.ORG_NUM LIKE '54%' THEN '99'
          WHEN A.ORG_NUM LIKE '55%' THEN '99'
          WHEN A.ORG_NUM LIKE '56%' THEN '99'
          WHEN A.ORG_NUM LIKE '57%' THEN '99'
          WHEN A.ORG_NUM LIKE '58%' THEN '99'
          WHEN A.ORG_NUM LIKE '59%' THEN '99'
          WHEN A.ORG_NUM LIKE '60%' THEN '99'
          ELSE 'E'
          END AS BIZ_LINE_ID
          ,''
          ,''
         ,CASE
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
           ELSE '990000'
             END FRNBJGH
        ,A.ORG_NUM NBJGH
    FROM SMTMODS.L_ACCT_OBS_LOAN A --表外
    LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B --商业汇票票面信息表
      ON A.acct_num = B.BILL_NUM
     AND B.DATA_DATE = IS_DATE
    LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=A.ORG_NUM 
     AND OB.DATA_DATE=IS_DATE
LEFT JOIN  SMTMODS.L_CUST_P D --对私客户补充信息表
  ON A.CUST_ID = D.CUST_ID
 AND D.DATA_DATE = IS_DATE
LEFT JOIN  SMTMODS.L_CUST_C F --对公客户补充信息表
  ON A.CUST_ID = F.CUST_ID
 AND F.DATA_DATE = IS_DATE

LEFT JOIN  SMTMODS.L_CUST_C F1 --对公客户补充信息表
  ON B.AFF_CODE = F1.CUST_ID
 AND F1.DATA_DATE = IS_DATE    --[2025-06-19] [白杨] [JLBA202504170013_关于在监管集市修改部分字段取数逻辑的需求 ][李楠] 

LEFT JOIN SMTMODS.L_AGRE_LOAN_CONTRACT H
  ON A.ACCT_NO=H.CONTRACT_NUM
  AND H.DATA_DATE=IS_DATE
LEFT JOIN L_CODE_DICTIONARY CD1
  ON D.id_type = CD1.L_CODE
 AND CD1.CODE_CLMN_NAME = 'ID_TYPE'
LEFT JOIN L_CODE_DICTIONARY CD2
  ON F.ID_TYPE = CD2.L_CODE
 AND CD2.CODE_CLMN_NAME = 'BZR_ID_TYPE'
/*LEFT JOIN L_CODE_DICTIONARY CD3
  ON trim(F.DEPT_TYPE) = CD3.L_CODE
 AND CD3.CODE_CLMN_NAME = 'DEPT_TYPE' --国民经济部门*/
LEFT JOIN L_CODE_DICTIONARY CD4
  ON F.CORP_HOLD_TYPE = CD4.L_CODE
 AND CD4.CODE_CLMN_NAME = 'CORP_HOLD_TYPE' --企业控股类型
/*LEFT JOIN L_CODE_DICTIONARY CD5
  ON B.id_type = CD5.L_CODE
 AND CD1.CODE_CLMN_NAME = 'ID_TYPE' --出票人证件类型
*/
LEFT JOIN  SMTMODS.L_PUBL_RATE R --汇率信息表
  ON R.DATA_DATE = IS_DATE
 AND R.BASIC_CCY =trim(B.CURR_CD)
 AND R.FORWARD_CCY = 'CNY'
 AND R.DATA_DATE = IS_DATE
 LEFT JOIN (SELECT   T.CONTRACT_NUM,
                     COUNT(DISTINCT SUBSTR(T1.GUAR_TYP,1,1)) CN
               FROM  SMTMODS.L_AGRE_GUA_RELATION T
               INNER JOIN SMTMODS.L_AGRE_GUARANTEE_CONTRACT T1
                 ON T.GUAR_CONTRACT_NUM = T1.GUAR_CONTRACT_NUM
                AND T1.GUAR_CONTRACT_STATUS='Y'
                AND T1.DATA_DATE = IS_DATE
              WHERE T.DATA_DATE = IS_DATE
                AND T.REL_STATUS ='Y'
              GROUP BY T.CONTRACT_NUM)DBFS
     ON A.ACCT_NO = DBFS.CONTRACT_NUM
LEFT JOIN JS_205_CLYHCD_TMP2 DBW --担保物表，当担保方式为质押贷款时，关联担保物确定是否是房地产抵押
    ON A.ACCT_NO = DBW.BUSINESSCODE
WHERE A.DATA_DATE = IS_DATE
--and A.GL_ITEM_CODE  LIKE '602%'
and A.GL_ITEM_CODE  LIKE '7020%'--20220705-夏文博
and A.BALANCE <> 0
;
COMMIT;

--[2026-04-21] [周立鹏] [JLBA202510210010_关于金数平台银承部分报表取数规则及展示的优化的需求][孙平刚] 逻辑前移，剔除冗余代码
/*-------------------吉林银行目标表数据--------------------
  ---清除历史数据
  DELETE FROM PBOCD_JS_205_CLYHCD
   WHERE DATA_DATE = TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  COMMIT;
 ---以下包含原应用层加工逻辑，现都放在加工层处理
 INSERT INTO  PBOCD_JS_205_CLYHCD （
 DATA_DATE  --数据日期
,ORG_CODE  --金融机构代码
,ORG_NUM  --内部机构号
,REG_REGION_CODE  --金融机构地区代码
,DRAWER_NAME    --出票人名称
,DRAWER_ID_TYPE  --出票人证件类型
,DRAWER_ID_NO  --出票人证件代码
,DRAWER_INDUSTRY_TYPE  --出票人行业
,DRAWER_AREA_CODE  --出票人地区代码
,DRAWER_CON_ECO_ELEM  --出票人经济成分
,DRAWER_ENT_SCALE  --出票人企业规模
,RECE_NAME  --收款人名称
,RECE_ID_TYPE  --收款人证件类型
,RECE_ID_NO  --收款人证件代码
,BILL_NUM  --票据编号
,BILL_MEDIUM  --票据介质
,OPEN_DATE  --出票日期
,BILL_DUE_DATE  --票据到期日期
,BILL_CURR_CODE  --币种
,BILL_AMT  --票面金额
,BILL_AMT_RMB  --票面金额折人民币
,FEE_AMT_RMB  --手续费金额折人民币
,MARGIN_RATIO  --保证金比例
,GUAR_TYPE  --担保方式
,REPORT_ID
,CJRQ
,BIZ_LINE_ID
,VERIFY_STATUS
,BSCJRQ
,FRNBJGH
,NBJGH
 )
 SELECT
 VS_TEXT  --数据日期
,NVL(OB.ID_NO,OB.UP_ID_NO) --金融机构代码
,T.ORG_NUM  --内部机构号
,OB.REGION_CD --3  金融机构地区代码
,T.DRAWER_NAME    --出票人名称
\*,T.DRAWER_ID_TYPE  --出票人证件类型*\
,'A01' --出票人证件类型   --[2025-06-19] [白杨] [JLBA202504170013_关于在监管集市修改部分字段取数逻辑的需求 ][李楠] 修改为默认值'A01'
,T.DRAWER_ID_NO  --出票人证件代码
,T.DRAWER_INDUSTRY_TYPE  --出票人行业
--[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
\*,CASE WHEN A.DRAWER_AREA_CODE IS NOT NULL THEN A.DRAWER_AREA_CODE
      WHEN T.DRAWER_AREA_CODE <> '999999' THEN NVL(A.DRAWER_AREA_CODE ,T.DRAWER_AREA_CODE )
 END  --出票人地区代码*\
,T.DRAWER_AREA_CODE   --出票人地区代码
 
,T.DRAWER_CON_ECO_ELEM  --出票人经济成分
,T.DRAWER_ENT_SCALE  --出票人企业规模
,T.RECE_NAME  --收款人名称
,T.RECE_ID_TYPE  --收款人证件类型
,T.RECE_ID_NO  --收款人证件代码
,T.BILL_NUM  --票据编号
,T.BILL_MEDIUM  --票据介质
,T.OPEN_DATE  --出票日期
,T.BILL_DUE_DATE  --票据到期日期
,T.BILL_CURR_CODE  --币种
,T.BILL_AMT  --票面金额
,T.BILL_AMT_RMB  --票面金额折人民币
,T.FEE_AMT_RMB  --手续费金额折人民币
,T.MARGIN_RATIO  --保证金比例
,T.GUAR_TYPE  --担保方式
,SYS_GUID()
,IS_DATE
,
 CASE
          WHEN T.ORG_NUM LIKE '51%' THEN '99'
          WHEN T.ORG_NUM LIKE '52%' THEN '99'
          WHEN T.ORG_NUM LIKE '53%' THEN '99'
          WHEN T.ORG_NUM LIKE '54%' THEN '99'
          WHEN T.ORG_NUM LIKE '55%' THEN '99'
          WHEN T.ORG_NUM LIKE '56%' THEN '99'
          WHEN T.ORG_NUM LIKE '57%' THEN '99'
          WHEN T.ORG_NUM LIKE '58%' THEN '99'
          WHEN T.ORG_NUM LIKE '59%' THEN '99'
          WHEN T.ORG_NUM LIKE '60%' THEN '99'
          ELSE 'E'
          END AS BIZ_LINE_ID  --20231013王晓彬
          ,''
          ,''
         ,CASE
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
,T.ORG_NUM
 FROM JS_205_CLYHCD T
 LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=T.ORG_NUM AND OB.DATA_DATE=IS_DATE
--[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
\*LEFT JOIN PBOCD_JS_205_CLYHCD_SQ A
ON T.BILL_NUM = A.BILL_NUM
AND A.CJRQ = VS_LAST_TEXT*\
 WHERE T.CJRQ=IS_DATE;
 COMMIT;*/

--[2025-09-18] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_四阶段][李楠] 剔除取上期/配置表
--出票人和收款人不应该是同一人
/*MERGE INTO PBOCD_JS_205_CLYHCD A
USING (SELECT * FROM PBOCD_JS_205_CLYHCD_SQ WHERE CJRQ = VS_LAST_TEXT) B
ON (A.BILL_NUM = B.BILL_NUM)
WHEN MATCHED THEN
  UPDATE
     SET A.DRAWER_NAME    = B.DRAWER_NAME,
         A.DRAWER_ID_TYPE = B.DRAWER_ID_TYPE,
         A.DRAWER_ID_NO   = B.DRAWER_ID_NO,
         A.RECE_NAME      = B.RECE_NAME,
         A.RECE_ID_TYPE   = B.RECE_ID_TYPE,
         A.RECE_ID_NO     = B.RECE_ID_NO
   WHERE A.CJRQ = IS_DATE
     AND A.DRAWER_ID_NO = A.RECE_ID_NO;
 COMMIT;*/

--[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
/*--出票人地区代码
UPDATE PBOCD_JS_205_CLYHCD
   SET DRAWER_AREA_CODE = '220201'
 WHERE CJRQ = IS_DATE
   AND DRAWER_AREA_CODE = '220272';
COMMIT;

UPDATE PBOCD_JS_205_CLYHCD
   SET DRAWER_AREA_CODE = '220104'
 WHERE CJRQ = IS_DATE
   AND DRAWER_AREA_CODE = '220172';
COMMIT;

UPDATE PBOCD_JS_205_CLYHCD
   SET DRAWER_AREA_CODE = '220200'
 WHERE CJRQ = IS_DATE
   AND DRAWER_AREA_CODE = '220271';
COMMIT;*/

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除金融机构地区代码的刷数逻辑
--公主岭地区代码
/*UPDATE PBOCD_JS_205_CLYHCD
   SET REG_REGION_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND REG_REGION_CODE = '220381';
COMMIT;*/

--[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
/*UPDATE PBOCD_JS_205_CLYHCD
   SET DRAWER_AREA_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND DRAWER_AREA_CODE = '220381';
COMMIT;*/

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除出票人经济成分的刷数逻辑
/*--出票人经济成分
UPDATE PBOCD_JS_205_CLYHCD
   SET DRAWER_CON_ECO_ELEM = 'B0101'
 WHERE CJRQ = IS_DATE
   AND DRAWER_NAME = '通药制药集团股份有限公司'
   AND DRAWER_CON_ECO_ELEM <> 'B0101';
COMMIT;

--出票人企业规模是CS05的，出票人经济成分置空
UPDATE PBOCD_JS_205_CLYHCD
   SET DRAWER_CON_ECO_ELEM = ''
 WHERE CJRQ = IS_DATE
   AND DRAWER_ENT_SCALE='CS05' AND DRAWER_CON_ECO_ELEM IS NOT NULL;
COMMIT;*/

--[2025-09-18] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_四阶段][李楠] 剔除取上期/配置表
/*--出票人名称
UPDATE PBOCD_JS_205_CLYHCD
   SET DRAWER_NAME = '吉林市群鸣耐火材料有限公司'
 WHERE CJRQ = IS_DATE
   AND DRAWER_NAME = '吉林群鸣耐火材料有限公司';
COMMIT;*/


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
