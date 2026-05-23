CREATE OR REPLACE PROCEDURE BSP_SP_JS_201_WTDKFS(IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_201_WTDKFS
  -- 业务域: 贷款类
  -- 用途: 生成接口表 JS_201_WTDKFS 委托贷款发生额信息
  -- 参数
  --    IS_DATE 输入，传入跑批日期
  --    OI_RETCODE 输出，用来标识存储过程执行过程中是否出现异常
  -- 引用的监管集市表
  --    SMTMODS.L_ACCT_LOAN                                — 贷款借据信息表
  --    SMTMODS.L_ACCT_LOAN_ENTRUST                        — 委托贷款补充信息
  --    SMTMODS.L_CUST_C                                   — 对公客户补充信息表
  --    SMTMODS.L_CUST_P                                   — 对私客户补充信息表
  --    SMTMODS.L_Cust_ALL                                 — L_Cust_ALL
  --    SMTMODS.L_TRAN_LOAN_PAYM                           — 贷款还款明细信息表
  -- 修改历史
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段 上线日期：2025-04-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT      VARCHAR2(500) DEFAULT NULL; --字符型  过程描述

  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL;
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
  NUM               INTEGER;
  VS_NMONTH         VARCHAR2(10);
BEGIN
  VS_TEXT      := to_char(to_date(IS_DATE, 'yyyymmdd'), 'yyyy-mm-dd');
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');

  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_NMONTH         := TO_CHAR(TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD') + 1),
                               'YYYYMMDD');
  VS_PROCEDURE_NAME := 'SP_JS_201_WTDKFS';

  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------
  --历史移植数据

  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_201_WTDKFS_TEMP01 ';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_201_WTDKFS_TEMP02 ';
  --EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_201_WTDKFS_TEMP03 ';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_201_WTDKFS_TEMP04 ';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_201_WTDKFS_TEMP05 ';

  --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'JS_201_WTDKFS'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE JS_201_WTDKFS ADD PARTITION P' ||
                      IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE JS_201_WTDKFS TRUNCATE PARTITION P' ||
                    IS_DATE;

  --委托贷款发生额----发放-----2022.2.10夏文博
  INSERT /*+ APPEND*/  INTO JS_201_WTDKFS_TEMP02 NOLOGGING
    (JJBH, --借据编号----------------- 借据表  贷款编号
     JJYE, --借据金额------------------借据表  放款金额
     BUSINESSCODE, --合同号------------借据表  合同号
     JGBH, --机构(转入\转出)----------借据表  机构号
     CCYCODE, --币种-------------------借据表  币种
     FLAG, --发放收回标志
     SERIAL_NO, --交易流水号-----------汇票号码？？？？？？
     DATA_DATE, --数据日期-------------数据日期
     FKRQ --放款日期（划转日期）------放款日期
     )
    SELECT /*+parallel(4)*/  T.LOAN_NUM,
           T.DRAWDOWN_AMT,
           T.ACCT_NUM,
           T.ORG_NUM,
           T.CURR_CD,
           '1',
           '1',
           T.DATA_DATE,
           TO_CHAR(T.DRAWDOWN_DT, 'YYYYMMDD')
      from SMTMODS.L_ACCT_LOAN T
     where
     SUBSTR(TO_CHAR(T.DRAWDOWN_DT, 'YYYYMMDD'), 1, 6) =
     SUBSTR(IS_DATE, 1, 6)
     --AND T.ITEM_CD LIKE '40602%'
     AND T.ITEM_CD LIKE '3020%'--20220705-夏文博
     AND T.CANCEL_FLG = 'N' --去掉核销数据
     --AND T.ITEM_CD NOT IN ('406020201', '406020202', '406020204');
     AND T.ITEM_CD NOT IN ('30200201', '30200202')--20220705-夏文博
   AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
  ;
  COMMIT;
  -------------------------------------------------------------------------------------------------------------
  --委托贷款发生额----收回-----2022.2.10夏文博
  INSERT /*+ APPEND*/  INTO JS_201_WTDKFS_TEMP02 NOLOGGING
    (JJBH, --借据编号----------------- 借据表  贷款编号
     JJYE, --借据金额------------------借据表  放款金额
     BUSINESSCODE, --合同号------------借据表  合同号
     JGBH, --机构(转入\转出)----------借据表  机构号
     CCYCODE, --币种-------------------借据表  币种
     FLAG, --发放收回标志
     SERIAL_NO, --交易流水号-----------汇票号码？？？？？？
     DATA_DATE, --数据日期-------------数据日期
     FKRQ --放款日期（划转日期）------放款日期
     )
    SELECT /*+parallel(4)*/  T.LOAN_NUM,
           --T.DRAWDOWN_AMT,
           M.PAY_AMT,
           T.ACCT_NUM,
           T.ORG_NUM,
           T.CURR_CD,
           '0',
           M.TX_NO AS SERIAL_NO, --交易流水号
           T.DATA_DATE,
           TO_CHAR(T.DRAWDOWN_DT, 'YYYYMMDD')

      FROM SMTMODS.L_TRAN_LOAN_PAYM M --贷款还款明细信息表
     INNER JOIN SMTMODS.L_ACCT_LOAN T --贷款借据信息表
        ON M.LOAN_NUM = T.LOAN_NUM
       AND T.DATA_DATE = IS_DATE
     where

     --T.ITEM_CD LIKE '40602%'
     T.ITEM_CD LIKE '3020%'--20220705-夏文博
     AND T.CANCEL_FLG = 'N' --去掉核销数据
     --AND T.ITEM_CD NOT IN ('406020201', '406020202', '406020204')
     AND T.ITEM_CD NOT IN ('30200201', '30200202')--20220705-夏文博
     AND M.PAY_AMT <> 0
     AND SUBSTR(TO_CHAR(M.REPAY_DT, 'YYYYMMDD'), 0, 6) = SUBSTR(IS_DATE, 0, 6)
   AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
   ;
  COMMIT;

  --借款人信息
  INSERT /*+ APPEND*/  INTO JS_201_WTDKFS_TEMP04 NOLOGGING
    (LOAN_NUM,
     CUST_ID,
     DEPT_TYPE,
     CUST_ID_TYPE,
     CUST_ID_NO,
     INDUSTRY_TYPE,
     REG_REGION_CODE,
     CORP_HOLD_TYPE,
     ENT_SCALE,
     CUST_NAME)
    SELECT
    /*+ use_hash(T,LP,LC,CD1, CD2, CD3,D4) parallel(4)*/
     T.LOAN_NUM,
     T.CUST_ID,
     NVL2(LP.CUST_ID, 'D01', CASE when LC.CUST_TYP='3'  THEN 'D01' ELSE H.DEPT_TYPE END ), --借款人国民经济部门
     
     --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 直取ID_TYPE、ID_NO
     /*CASE WHEN LC.CUST_TYP='3' THEN
        (SELECT PBOCD_CODE  FROM  L_CODE_DICTIONARY D4
         WHERE  trim(LC.Legal_Card_TYPE) = D4.L_CODE
        AND D4.CODE_CLMN_NAME = 'ID_TYPE')
       ELSE
         NVL2(LP.CUST_ID,
         CD2.PBOCD_CODE,
         NVL2(LC.TYSHXYDM, 'A01',
         NVL2(LC.ID_NO,CASE WHEN LENGTH(LC.ID_NO) = 18 THEN 'A01' ELSE CD1.PBOCD_CODE END, 'A02')))
      END , --借款人证件类型
     CASE WHEN LP.ID_TYPE IS NOT NULL THEN LP.ID_NO
       WHEN LC.CUST_TYP='3' THEN
        LC.Legal_Card_No
       ELSE
         NVL2(LP.CUST_ID,LP.ID_NO,
              NVL2(LC.TYSHXYDM,LC.TYSHXYDM,
         NVL2(LC.ID_NO,replace(LC.ID_NO,'-',''),replace(LC.ORGANIZATIONCODE,'-','')))) END, --借款人证件代码*/
     CASE WHEN LC.CUST_TYP='3' THEN
        (SELECT PBOCD_CODE  FROM  L_CODE_DICTIONARY D4
         WHERE  trim(LC.Legal_Card_TYPE) = D4.L_CODE
        AND D4.CODE_CLMN_NAME = 'ID_TYPE')
       WHEN LP.CUST_ID IS NOT NULL THEN CD2.PBOCD_CODE
       WHEN LC.CUST_ID IS NOT NULL THEN CD1.PBOCD_CODE
      END , --借款人证件类型
     CASE 
       WHEN LC.CUST_TYP='3' THEN LC.Legal_Card_No
       WHEN LP.CUST_ID IS NOT NULL THEN LP.ID_NO
       WHEN LC.CUST_ID IS NOT NULL AND CD1.PBOCD_CODE = 'A02' THEN REPLACE(LC.ID_NO,'-')
       WHEN LC.CUST_ID IS NOT NULL THEN LC.ID_NO
      END , --借款人证件代码   
         
     NVL2(LP.CUST_ID, '100', CASE  WHEN LC.CUST_TYP=3  THEN '100' ELSE  SUBSTRB(TRIM(LC.CORP_BUSINSESS_TYPE), 0, 3)END), --借款人行业
     NVL2(LP.CUST_ID, LP.REGION_CD, LC.REGION_CD), --借款人地区代码
     CASE WHEN  LC.CUST_TYP='3' THEN '' ELSE CD3.PBOCD_CODE END, --借款人经济成分
       NVL2(LC.CUST_ID,
       CASE WHEN LC.CUST_TYP='3' THEN NULL
         ELSE
          DECODE(LC.CORP_SCALE,
                 'B',
                 'CS01',
                 'M',
                 'CS02',
                 'S',
                 'CS03',
                 'T',
                 'CS04',
                 'CS05') END ,
          ''), --借款人企业规模
     NVL(LP.CUST_NAM, LC.CUST_NAM) --借款人名称
      FROM SMTMODS.L_ACCT_LOAN T
      LEFT JOIN SMTMODS.L_CUST_C LC
        ON T.CUST_ID = LC.CUST_ID
       AND LC.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_CUST_P LP
        ON T.CUST_ID = LP.CUST_ID
       AND LP.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_Cust_ALL H ----2022.2.10  夏文博
        ON T.CUST_ID = H.CUST_ID
       AND H.DATA_DATE = IS_DATE
      LEFT JOIN L_CODE_DICTIONARY CD1
        ON LC.id_type = CD1.L_CODE
       AND CD1.CODE_CLMN_NAME = 'ID_TYPE'
      LEFT JOIN L_CODE_DICTIONARY CD2
        ON LP.ID_TYPE = CD2.L_CODE
       AND CD2.CODE_CLMN_NAME = 'ID_TYPE' --借款人证件代码
      LEFT JOIN L_CODE_DICTIONARY CD3
        ON LC.CORP_HOLD_TYPE = CD3.L_CODE
       AND CD3.CODE_CLMN_NAME = 'CORP_HOLD_TYPE' --企业控股类型

      LEFT JOIN L_CODE_DICTIONARY D4
        ON trim(H.DEPT_TYPE) = D4.L_CODE
       AND D4.CODE_CLMN_NAME = 'DEPT_TYPE' --国民经济部门*/  ---2022.2.10 --夏文博修改
     WHERE T.DATA_DATE = IS_DATE
       --AND T.ITEM_CD LIKE '40602%'
       AND T.ITEM_CD LIKE '3020%'--20220705-夏文博修改
          /*AND T.HXRQ IS NULL*/
       AND T.CANCEL_FLG = 'N' --去掉核销数据---2022.2.10 --夏文博修改
          /*AND T.COD_PROD <> 'WD003000200002';*/ --剔除个人公积金委托贷款
       --AND T.ITEM_CD NOT IN ('406020201', '406020202', '406020204'); ---剔除个人公积金委托贷款--2022.2.10 --夏文博修改
       AND T.ITEM_CD NOT IN ('30200201', '30200202')--20220705-夏文博修改
     AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
     ;
  COMMIT;

  --委托人信息
  INSERT /*+ APPEND*/  INTO JS_201_WTDKFS_TEMP05 NOLOGGING
    (LOAN_NUM,
     WTRCUSTID,
     DEPT_TYPE,
     CUST_ID_TYPE,
     CUST_ID_NO,
     INDUSTRY_TYPE,
     REG_REGION_CODE,
     CORP_HOLD_TYPE,
     ENT_SCALE,
     TRUSTOR_CUST_NAME)
    SELECT DISTINCT
    /*+ use_hash(T,LP,LC,M,CD1, CD2, CD3,D4) parallel(4)*/
     T.LOAN_NUM,
     T1.TRUSTOR_ID,
     NVL2(LP.CUST_ID, 'D01', H.DEPT_TYPE), --委托人国民经济部门

     --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 直取ID_TYPE、ID_NO
     /*NVL2(LP.CUST_ID,
     CD2.PBOCD_CODE,
     NVL2(LC.TYSHXYDM,'A01',
     NVL2(LC.id_no,CASE WHEN LENGTH(LC.id_no) = 18 THEN 'A01' ELSE CD1.PBOCD_CODE END, 'A02'))), --委托人证件类型

     NVL2(LP.CUST_ID,
     LP.ID_NO,
     NVL2(LC.TYSHXYDM,
          LC.TYSHXYDM,
          NVL2(LC.id_no,replace(LC.id_no,'-',''),replace(LC.ORGANIZATIONCODE, '-', '')
               ))), --委托人证件代码*/
     NVL2(LP.CUST_ID,CD2.PBOCD_CODE,CD1.PBOCD_CODE), --委托人证件类型
     NVL2(LP.CUST_ID,LP.ID_NO,CASE WHEN CD1.PBOCD_CODE = 'A02' THEN REPLACE(LC.ID_NO,'-') ELSE LC.ID_NO END), --委托人证件代码
     
     NVL2(LP.CUST_ID, '100', CASE  WHEN LC.CUST_TYP=3  THEN '100' ELSE  SUBSTRB(TRIM(LC.CORP_BUSINSESS_TYPE), 0, 3)END), --委托人行业
     NVL2(LP.CUST_ID, LP.REGION_CD, LC.REGION_CD), --委托人地区代码
     cd3.pbocd_code, --委托人经济成分
     NVL2(LC.CUST_ID,
          DECODE(LC.CORP_SCALE,
                 'B',
                 'CS01',
                 'M',
                 'CS02',
                 'S',
                 'CS03',
                 'T',
                 'CS04',
                 'CS05'),
          ''), --委托人企业规模
     NVL(LP.CUST_NAM, LC.CUST_NAM) --委托客户名
      FROM SMTMODS.L_ACCT_LOAN T
      LEFT JOIN SMTMODS.L_ACCT_LOAN_ENTRUST T1 ------------------
        ON T.LOAN_NUM = T1.LOAN_NUM
       AND T1.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_Cust_ALL H --全量客户 临时表
        ON H.DATA_DATE = IS_DATE
       AND T1.TRUSTOR_ID = H.CUST_ID
      LEFT JOIN L_CUST_C_TMP LC
        ON T1.TRUSTOR_ID = LC.CUST_ID
       AND LC.DATA_DATE = IS_DATE -------------------------------2022.2.10 夏文博

      LEFT JOIN SMTMODS.L_CUST_P LP
        ON T1.TRUSTOR_ID = LP.CUST_ID
       AND LP.DATA_DATE = IS_DATE
      LEFT JOIN L_CODE_DICTIONARY CD1
        ON LC.ID_TYPE = CD1.L_CODE
       AND CD1.CODE_CLMN_NAME = 'ID_TYPE'
      LEFT JOIN L_CODE_DICTIONARY CD2
        ON LP.ID_TYPE = CD2.L_CODE
       AND CD2.CODE_CLMN_NAME = 'ID_TYPE'
      LEFT JOIN L_CODE_DICTIONARY CD3
        ON LC.CORP_HOLD_TYPE = CD3.L_CODE
       AND CD3.CODE_CLMN_NAME = 'CORP_HOLD_TYPE' --企业控股类型
      LEFT JOIN L_CODE_DICTIONARY D4
        ON trim(H.DEPT_TYPE) = D4.L_CODE
       AND D4.CODE_CLMN_NAME = 'DEPT_TYPE' --国民经济部门
     WHERE T.DATA_DATE = IS_DATE
       --AND T.ITEM_CD LIKE '40602%'
       AND T.ITEM_CD LIKE '3020%'--20220705-夏文博
       AND T.CANCEL_FLG = 'N' --去掉核销数据
       --AND T.ITEM_CD NOT IN ('406020201', '406020202', '406020204'); ---剔除个人公积金委托贷款--2022.2.10 --夏文博修改
       AND T.ITEM_CD NOT IN ('30200201', '30200202') --20220705-夏文博
     AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
     ;
  COMMIT;

  /*  以下逻辑 是  加工 收回 数据  已存在 流水号 */
  INSERT /*+ APPEND*/  INTO JS_201_WTDKFS NOLOGGING
    (DATA_DATE --数据日期
    ,
     ORG_CODE --1 金融机构代码
    ,
     ORG_NUM --2 内部机构号
    ,
     ORG_AREA_COD --3 金融机构地区代码
    ,
     DEPT_TYPE --4 借款人国民经济部门
    ,
     CUST_ID_TYPE --5 借款人证件类型
    ,
     CUST_ID_NO --6 借款人证件代码
    ,
     INDUSTRY_TYPE --7 借款人行业
    ,
     REG_AREA_CODE --8 借款人地区代码
    ,
     ENT_CON_ECO_ELEM --9 借款人经济成分
    ,
     ENT_SCALE --10 借款企业规模
    ,
     LOAN_NUM --11 委托贷款借据编码
    ,
     CONTRACT_CODE --12 委托贷款合同编码
    ,
     ENTRUST_LOAN_GRANT_DATE --13 委托贷款发放日期
    ,
     ENTRUST_LOAN_DUE_DATE --14 委托贷款到期日期
    ,
     LOAN_PURPOSE_CD --15 贷款实际投向
    ,
     CURR_CODE --16 币种
    ,
     TRANS_AMT --17 委托贷款发生金额
    ,
     TRANS_AMT_RMB --18 委托贷款发生金额折人民币
    ,
     INT_RATE_TYPE --19 利率是否固定
    ,
     INT_RATE --20 利率水平
    ,
     FEE_AMT_RMB --21 手续费金额折人民币
    ,
     GUAR_TYPE --22 贷款担保方式
    ,
     TRUSTOR_DEPT_TYPE --23 委托人国民经济部门
    ,
     TRUSTOR_ID_TYPE --24 委托人证件类型
    ,
     TRUSTOR_ID_NO --25 委托人证件代码
    ,
     TRUSTOR_BUSINSESS_TYPE --26 委托人行业
    ,
     TRUSTOR_REG_AREA_CODE --27 委托人所在地区代码
    ,
     TRUSTOR_CTRL_ECO_ELEM --28 委托人经济成分
    ,
     TRUSTOR_ENT_SCALE --29 委托人企业规模
    ,
     TRANS_TYPE --30 发放/收回标识
    ,
     REPORT_ID --31
    ,
     CJRQ --32
    ,
     NBJGH --33
    ,
     BIZ_LINE_ID --34
    ,
     VERIFY_STATUS --35
    ,
     BSCJRQ --36
    ,
     USEOFUNDS --37 贷款用途
    ,
     SERIAL_NO --38 交易流水号
    ,
     FRNBJGH --39 法人内部机构号
    ,
     CUST_ID --40 客户号
    ,
     CUST_NAME --41 借款人名称
    ,
     TRUSTOR_CUST_NAME --42 委托人名称
     )
    SELECT /*+ use_hash(T,T1,T2,T3,DBW, OFF, DBFS,T4) parallel(4)*/
     IS_DATE DATA_DATE, --  数据日期
     '',--OFF.JRJGBM ORG_CODE, --1  金融机构代码
     T.JGBH ORG_NUM, --2  内部机构号
     '',--OFF.AREA_ID ORG_AREA_COD, --3  金融机构地区代码
     T1.DEPT_TYPE, --4 借款人国民经济部门
     T1.CUST_ID_TYPE, --5 借款人证件类型
     T1.CUST_ID_NO, --6 借款人证件代码
     T1.INDUSTRY_TYPE, --7 借款人行业
     T1.REG_REGION_CODE REG_AREA_CODE, --8 借款人地区代码
     T1.CORP_HOLD_TYPE, --9 借款人经济成分
     T1.ENT_SCALE, --10  借款人企业规模
     T.JJBH LOAN_NUM, --11  贷款借据编码
     T3.ACCT_NUM CONTRACT_CODE, --12  贷款合同编码
     CASE
       WHEN T.FLAG = '4' THEN
        NVL(TO_CHAR(TO_DATE(T.FKRQ, 'YYYYMMDD'), 'YYYY-MM-DD'),
            TO_CHAR(T3.DRAWDOWN_DT, 'YYYY-MM-DD'))
       ELSE
        TO_CHAR(T3.DRAWDOWN_DT, 'YYYY-MM-DD')
     END LOAN_GRANT_DATE, --13  贷款发放日期
     TO_CHAR(T3.MATURITY_DT, 'YYYY-MM-DD') LOAN_DUE_DATE, --14  贷款到期日期
     SUBSTRB(T3.LOAN_PURPOSE_CD, 1, 4) LOAN_PURPOSE_CD, --15  贷款实际投向
     T3.CURR_CD CURR_CODE, --16  币种
     T.JJYE BALANCE, --17  贷款发生金额
     T.JJYE BALANCE_RMB, --18  贷款发生金额折人民币
     CASE
       WHEN T3.INT_RATE_TYP = 'F' THEN
        'RF01'
       ELSE
        'RF02'
     END INT_RATE_TYPE, --19  利率是否固定
     T3.REAL_INT_RAT INT_RATE, --20  利率水平
     T4.FEE_AMT FEE_AMT_RMB, --21  手续费金额折人民币

     TP7.GUAR_TYPE AS GUAR_TYPE, --22  贷款担保方式
     T2.DEPT_TYPE, --23  委托人国民经济部门
     T2.CUST_ID_TYPE, --24  委托人证件类型
     T2.CUST_ID_NO, --25  委托人证件代码
     T2.INDUSTRY_TYPE, --26  委托人行业
     T2.REG_REGION_CODE, --27  委托人所在地区代码
     T2.CORP_HOLD_TYPE, --28  委托人经济成分
     T2.ENT_SCALE, --29  委托人企业规模
     T.FLAG AS TRANS_TYPE, --30  发放/收回标识 1：发放贷款，0：收回贷款正常发放、贷款转入视为贷款发放，填1；正常清偿、核销、剥离、贷款转出视为贷款收回，填0
     SYS_GUID() REPORT_ID, --31  REPORT_ID
     IS_DATE CJRQ, --32  采集日期
     T.JGBH NBJGH, --33  内部机构号

     CASE
       WHEN T3.ORG_NUM LIKE '51%' THEN
       '99'
       WHEN t3.ORG_NUM LIKE '52%' THEN '99'
       WHEN t3.ORG_NUM LIKE '53%' THEN '99'
       WHEN t3.ORG_NUM LIKE '54%' THEN '99'
       WHEN t3.ORG_NUM LIKE '55%' THEN '99'
       WHEN t3.ORG_NUM LIKE '56%' THEN '99'
       WHEN t3.ORG_NUM LIKE '57%' THEN '99'
       WHEN t3.ORG_NUM LIKE '58%' THEN '99'
       WHEN t3.ORG_NUM LIKE '59%' THEN '99'
       WHEN t3.ORG_NUM LIKE '60%' THEN '99'
       WHEN t3.DEPARTMENTD = '公司金融' THEN
        'E'
       WHEN t3.DEPARTMENTD = '普惠金融' THEN
        'S'
       WHEN t3.DEPARTMENTD = '个人信贷' THEN
        'P'
       /*WHEN t3.DEPARTMENTD = '磐石村镇' THEN
        'V'*/
       WHEN t3.DEPARTMENTD = '德惠长银' THEN
        'E'
       ELSE
        '99'
     END BIZ_LINE_ID, --34  业务条线 20230919王晓彬
     '' VERIFY_STATUS, --35  VERIFY_STATUS
     '' BSCJRQ, --36  BSCJRQ
     T3.USEOFUNDS USEOFUNDS, --37 贷款用途
     T.SERIAL_NO SERIAL_NO, --38 交易流水号

       CASE WHEN T3.ORG_NUM LIKE '51%' THEN '510000'
         WHEN T3.ORG_NUM LIKE '52%' THEN '520000'
         WHEN T3.ORG_NUM LIKE '53%' THEN '530000'
         WHEN T3.ORG_NUM LIKE '54%' THEN '540000'
         WHEN T3.ORG_NUM LIKE '55%' THEN '550000'
         WHEN T3.ORG_NUM LIKE '56%' THEN '560000'
         WHEN T3.ORG_NUM LIKE '57%' THEN '570000'
         WHEN T3.ORG_NUM LIKE '58%' THEN '580000'
         WHEN T3.ORG_NUM LIKE '59%' THEN '590000'
         WHEN T3.ORG_NUM LIKE '60%' THEN '600000'
       ELSE '990000' END FRNBJGH,---20230620多法人新增

     T3.CUST_ID, --40 客户号
     T1.CUST_NAME, --41 借款人名称
     T2.TRUSTOR_CUST_NAME --42 委托人名称
      FROM JS_201_WTDKFS_TEMP02 T
      LEFT JOIN JS_201_WTDKFS_TEMP04 T1
        ON T.JJBH = T1.LOAN_NUM
      LEFT JOIN JS_201_WTDKFS_TEMP05 T2
        ON T.JJBH = T2.LOAN_NUM
      LEFT JOIN SMTMODS.L_ACCT_LOAN T3
        ON T.JJBH = T3.LOAN_NUM
       AND T3.DATA_DATE = IS_DATE

      LEFT JOIN DBFS_TMP TP7 --贷款担保方式中间表--在总调里加工
        ON T.JJBH = TP7.LOAN_NUM
      LEFT JOIN SMTMODS.L_ACCT_LOAN_ENTRUST T4
        ON T3.LOAN_NUM = T4.LOAN_NUM
       AND T4.DATA_DATE = IS_DATE
    where t.data_date= is_date
    ;

  COMMIT;

/*  --机构变更按照老机构报，如果不用了的机构可以把ORG_NEW表EFF_FLAG字段改成'N'
  UPDATE JS_201_WTDKFS A
     SET A.ORG_NUM =
         (SELECT T.ORG_NUM_BK
            FROM ORG_NEW T
           WHERE T.EFF_FLAG = 'Y'
             AND A.ORG_NUM = T.ORG_NUM_NEW)
   WHERE A.DATA_DATE = IS_DATE
     AND EXISTS (SELECT 1
            FROM ORG_NEW B
           WHERE A.ORG_NUM = B.ORG_NUM_NEW
             AND B.EFF_FLAG = 'Y');
  COMMIT;*/

  ---吉林银行目标表数据
/*  DELETE FROM PBOCD_JS_201_WTDKFS
   WHERE DATA_DATE = TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  COMMIT;*/
  --SP_PBOCD_PARTITIONS(IS_DATE,'JS_201_WTDKFS',OI_RETCODE);
  SP_PBOCD_PARTITIONS(IS_DATE,'PBOCD_JS_201_WTDKFS',OI_RETCODE);

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_201_WTDKFS TRUNCATE PARTITION P' ||
                    IS_DATE;
   ---以下包含原应用层加工逻辑，现都放在加工层处理
INSERT /*+ APPEND*/ INTO PBOCD_JS_201_WTDKFS NOLOGGING
    (DATA_DATE                        --数据日期
    ,ORG_CODE                         --1 金融机构代码
    ,ORG_NUM                          --2 内部机构号
    ,ORG_AREA_COD                     --3 金融机构地区代码
    ,DEPT_TYPE                        --4 借款人国民经济部门
    ,CUST_ID_TYPE                     --5 借款人证件类型
    ,CUST_ID_NO                       --6 借款人证件代码
    ,INDUSTRY_TYPE                    --7 借款人行业
    ,REG_AREA_CODE                    --8 借款人地区代码
    ,ENT_CON_ECO_ELEM                 --9 借款人经济成分
    ,ENT_SCALE                        --10 借款企业规模
    ,LOAN_NUM                         --11 委托贷款借据编码
    ,CONTRACT_CODE                    --12 委托贷款合同编码
    ,ENTRUST_LOAN_GRANT_DATE          --13 委托贷款发放日期
    ,ENTRUST_LOAN_DUE_DATE            --14 委托贷款到期日期
    ,LOAN_PURPOSE_CD                  --15 贷款实际投向
    ,CURR_CODE                        --16 币种
    ,TRANS_AMT                        --17 委托贷款发生金额
    ,TRANS_AMT_RMB                    --18 委托贷款发生金额折人民币
    ,INT_RATE_TYPE                    --19 利率是否固定
    ,INT_RATE                         --20 利率水平
    ,FEE_AMT_RMB                      --21 手续费金额折人民币
    ,GUAR_TYPE                        --22 贷款担保方式
    ,TRUSTOR_DEPT_TYPE                --23 委托人国民经济部门
    ,TRUSTOR_ID_TYPE                  --24 委托人证件类型
    ,TRUSTOR_ID_NO                    --25 委托人证件代码
    ,TRUSTOR_BUSINSESS_TYPE           --26 委托人行业
    ,TRUSTOR_REG_AREA_CODE            --27 委托人所在地区代码
    ,TRUSTOR_CTRL_ECO_ELEM            --28 委托人经济成分
    ,TRUSTOR_ENT_SCALE                --29 委托人企业规模
    ,TRANS_TYPE                       --30 发放/收回标识
    ,REPORT_ID                        --31
    ,CJRQ                             --32
    ,NBJGH                            --33
    ,BIZ_LINE_ID                      --34
    ,BSCJRQ                           --36
    ,USEOFUNDS                        --37 贷款用途
    ,SERIAL_NO                        --38 交易流水号
    ,FRNBJGH                          --39
    ,CUST_NAME                        --40 借款人名称
    ,TRUSTOR_CUST_NAME                --41 委托人名称
     )
    SELECT /*+parallel(4)*/
          VS_TEXT

           ,NVL(OB.ID_NO,OB.UP_ID_NO) --金融机构代码
           ,T.ORG_NUM

           ,OB.REGION_CD --3  金融机构地区代码
           
           --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
           --,NVL(BK.DEPT_TYPE,T.DEPT_TYPE)
           ,T.DEPT_TYPE
           
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --,NVL(BK.CUST_ID_TYPE,T.CUST_ID_TYPE)
           ,T.CUST_ID_TYPE
           
           --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 直取ID_TYPE、ID_NO
           --,NVL(BK.CUST_ID_NO,T.CUST_ID_NO)
           ,T.CUST_ID_NO
           
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --,NVL(BK.INDUSTRY_TYPE,T.INDUSTRY_TYPE)
           ,T.INDUSTRY_TYPE
           
           --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
           --,NVL(BK.REG_AREA_CODE,T.REG_AREA_CODE)
           ,T.REG_AREA_CODE
     
           --[2025-07-29] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_三阶段][李楠] 剔除取上期/配置表
           --,NVL(BK.ENT_CON_ECO_ELEM,T.ENT_CON_ECO_ELEM)
           ,T.ENT_CON_ECO_ELEM
           
     
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --,NVL(BK.ENT_SCALE,T.ENT_SCALE)
           ,T.ENT_SCALE
           
           ,T.LOAN_NUM
           ,T.CONTRACT_CODE
           ,T.ENTRUST_LOAN_GRANT_DATE
           ,T.ENTRUST_LOAN_DUE_DATE
           
           --[2025-07-29] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_三阶段][李楠] 实际投向剔除取上期，与存量同步
           --,NVL(BK.LOAN_PURPOSE_CD,T.LOAN_PURPOSE_CD)
           ,NVL(T.LOAN_PURPOSE_CD,
               CASE
                 WHEN SUBSTR(T.CUST_ID_TYPE, 1, 1) = 'B' AND
                      T.CUST_ID_TYPE IN ('B06', 'B07', 'B09', 'B11', 'B12') THEN
                  '2000' --借款人是个人的，贷款投向是1000，如果是境外填2000
                 WHEN SUBSTR(T.CUST_ID_TYPE, 1, 1) = 'B' AND
                      T.CUST_ID_TYPE NOT IN ('B06', 'B07', 'B09', 'B11', 'B12') THEN
                  '1000'
                 ELSE
                  T.LOAN_PURPOSE_CD
               END) --16 贷款实际投向
           
           ,T.CURR_CODE
           ,T.TRANS_AMT
           ,T.TRANS_AMT_RMB
           ,T.INT_RATE_TYPE
           ,T.INT_RATE
           ,T.FEE_AMT_RMB
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --,NVL(BK.GUAR_TYPE,T.GUAR_TYPE)
           ,T.GUAR_TYPE
           
           --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
           --,NVL(BK.TRUSTOR_DEPT_TYPE,T.TRUSTOR_DEPT_TYPE)
           ,T.TRUSTOR_DEPT_TYPE
           
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --,NVL(BK.TRUSTOR_ID_TYPE,T.TRUSTOR_ID_TYPE)
           --,NVL(BK.TRUSTOR_ID_NO,T.TRUSTOR_ID_NO)
           ,T.TRUSTOR_ID_TYPE
           ,T.TRUSTOR_ID_NO
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --,NVL(BK.TRUSTOR_BUSINSESS_TYPE,T.TRUSTOR_BUSINSESS_TYPE)
           ,T.TRUSTOR_BUSINSESS_TYPE
           
           --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
           /*,DECODE(NVL(BK.TRUSTOR_REG_AREA_CODE,T.TRUSTOR_REG_AREA_CODE)
                     ,'220171','220105','220172','220104'
                     ,NVL(BK.TRUSTOR_REG_AREA_CODE,T.TRUSTOR_REG_AREA_CODE))*/
           ,T.TRUSTOR_REG_AREA_CODE       
         
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --,NVL(BK.TRUSTOR_CTRL_ECO_ELEM,T.TRUSTOR_CTRL_ECO_ELEM)
           ,T.TRUSTOR_CTRL_ECO_ELEM
           
           --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
           --,NVL(BK.TRUSTOR_ENT_SCALE,T.TRUSTOR_ENT_SCALE)
           ,T.TRUSTOR_ENT_SCALE
           
           ,T.TRANS_TYPE
           ,T.REPORT_ID
           ,T.CJRQ
           ,T.NBJGH
           ,T.BIZ_LINE_ID
           ,T.BSCJRQ
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --,NVL(BK.USEOFUNDS,T.USEOFUNDS)
           ,T.USEOFUNDS
           
           ,T.SERIAL_NO
           ,T.FRNBJGH
           ,T.CUST_NAME
           ,T.TRUSTOR_CUST_NAME
      FROM JS_201_WTDKFS T

      LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=T.NBJGH AND OB.DATA_DATE=IS_DATE
     LEFT JOIN PBOCD_JS_201_CLWTDK_SQ BK
      ON T.LOAN_NUM = BK.LOAN_NUM
      AND BK.CJRQ = VS_LAST_TEXT
     WHERE TRIM(T.DATA_DATE) = IS_DATE;

  COMMIT;

--手续费--先按上期刷，再按本期刷，确保优先以本期存量为准
MERGE INTO PBOCD_JS_201_WTDKFS A
USING (SELECT *
         FROM (SELECT LOAN_NUM,
                      FEE_AMT_RMB,
                      ROW_NUMBER() OVER(PARTITION BY LOAN_NUM ORDER BY CJRQ DESC) RN
                 FROM PBOCD_JS_201_CLWTDK_SQ B
                WHERE B.CJRQ = VS_LAST_TEXT) B
        WHERE B.RN = 1) B
ON (A.LOAN_NUM = B.LOAN_NUM)
WHEN MATCHED THEN
  UPDATE SET A.FEE_AMT_RMB = B.FEE_AMT_RMB WHERE A.CJRQ = IS_DATE;
COMMIT;

MERGE INTO PBOCD_JS_201_WTDKFS A
USING (SELECT *
         FROM (SELECT LOAN_NUM,
                      FEE_AMT_RMB,
                      ROW_NUMBER() OVER(PARTITION BY LOAN_NUM ORDER BY CJRQ DESC) RN
                 FROM PBOCD_JS_201_CLWTDK B
                WHERE B.CJRQ = IS_DATE) B
        WHERE B.RN = 1) B
ON (A.LOAN_NUM = B.LOAN_NUM)
WHEN MATCHED THEN
  UPDATE SET A.FEE_AMT_RMB = B.FEE_AMT_RMB WHERE A.CJRQ = IS_DATE;
COMMIT;

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 这笔已经过渡没了
/*--经济部门
UPDATE PBOCD_JS_201_WTDKFS
   SET DEPT_TYPE = 'A04'
 WHERE CJRQ = IS_DATE
   AND CUST_ID_NO IN ('12220600589487324Q')
   AND DEPT_TYPE IS NULL;
COMMIT;*/

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
--公主岭地区代码
/*UPDATE PBOCD_JS_201_WTDKFS
   SET ORG_AREA_COD = '220184'
 WHERE CJRQ = IS_DATE
   AND ORG_AREA_COD = '220381';
COMMIT;*/

--[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
/*UPDATE PBOCD_JS_201_WTDKFS
   SET REG_AREA_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND REG_AREA_CODE = '220381';
COMMIT;

UPDATE PBOCD_JS_201_WTDKFS
   SET TRUSTOR_REG_AREA_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND TRUSTOR_REG_AREA_CODE = '220381';
COMMIT;
--总行每月固定借据号，刷借款人地区代码
MERGE INTO PBOCD_JS_201_WTDKFS A
     USING PBOCD_WTDK_UPDATE_REG_AREA_CODE B
     ON (A.LOAN_NUM =B.LOAN_NUM AND A.CJRQ = IS_DATE AND A.FRNBJGH='990000')
   WHEN MATCHED THEN
     UPDATE SET A.REG_AREA_CODE=B.REG_AREA_CODE
     WHERE A.CJRQ = IS_DATE
     AND A.FRNBJGH='990000';
COMMIT;*/
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