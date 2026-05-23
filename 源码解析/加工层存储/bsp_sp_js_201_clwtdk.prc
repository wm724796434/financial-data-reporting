CREATE OR REPLACE PROCEDURE BSP_SP_JS_201_CLWTDK(IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_201_CLWTDK
  -- 业务域: 贷款类
  -- 用途: 生成接口表 JS_201_CLWTDK 存量委托贷款信息
  -- 参数
  --    IS_DATE 输入，传入跑批日期
  --    OI_RETCODE 输出，用来标识存储过程执行过程中是否出现异常
  -- 引用的监管集市表
  --    SMTMODS.L_ACCT_LOAN                                — 贷款借据信息表
  --    SMTMODS.L_ACCT_LOAN_ENTRUST                        — 委托贷款补充信息
  --    SMTMODS.L_CUST_ALL                                 — 全量客户信息表
  --    SMTMODS.L_CUST_C                                   — 对公客户补充信息表
  --    SMTMODS.L_CUST_P                                   — 对私客户补充信息表
  --    SMTMODS.L_PUBL_RATE                                — 汇率表
  --    SMTMODS.v_pub_idx_dk_zqdqrjj                       — v_pub_idx_dk_zqdqrjj
  -- 修改历史
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段 上线日期：2025-05-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL; ---字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
  NUM               INTEGER;
  VS_NMONTH         VARCHAR2(10);

BEGIN
  VS_TEXT      := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');

  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_201_CLWTDK';
  VS_NMONTH         := TO_CHAR(TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD') + 1),
                               'YYYYMMDD');
  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------
  EXECUTE IMMEDIATE 'TRUNCATE TABLE CUST_WT_TEMP01';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_201_CLWTDK_TEMP03';
  EXECUTE IMMEDIATE 'TRUNCATE table JS_201_CLWTDK_TEMP4';

  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'JS_201_CLWTDK'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --查看落地表是否已经建立分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE JS_201_CLWTDK ADD PARTITION P' ||
                      IS_DATE || ' VALUES less than (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE JS_201_CLWTDK TRUNCATE PARTITION P' ||
                    IS_DATE;

  INSERT INTO JS_201_CLWTDK_TEMP4

    SELECT  T.LOAN_NUM, T.CUST_ID, ''/*T1.TRUSTOR_ID*/
      FROM SMTMODS.L_ACCT_LOAN T

     WHERE T.DATA_DATE = IS_DATE
       --AND T.ITEM_CD LIKE '40602%'
       AND T.ITEM_CD LIKE '3020%'
       --AND T.ITEM_CD NOT IN ('406020201', '406020202', '406020204') --剔除个人公积金委托贷款
       AND T.ITEM_CD NOT IN ('30200201', '30200202')--20220705-夏文博
       AND T.CANCEL_FLG = 'N'
     AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
     ;
  --AND T.COD_PROD <> 'WD003000200002';
  COMMIT;

  --?????
  INSERT INTO JS_201_CLWTDK_TEMP03
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
    SELECT /*+ use_hash(T,LP,LC,CD1,CD2,CD3,D4) parallel(4)*/

     T.LOAN_NUM,
     T.CUST_ID,
     --NVL2(LP.CUST_ID, 'D01', B.DEPT_TYPE),
     NVL(NVL2(LP.CUST_ID, 'D01', CASE WHEN LC.CUST_TYP ='3' THEN 'D01' ELSE   D4.PBOCD_CODE END),G.DEPT_TYPE),
     
     --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 直取ID_TYPE、ID_NO
     /*CASE
      WHEN LC.CUST_TYP='3' THEN
        (SELECT PBOCD_CODE
         FROM  L_CODE_DICTIONARY D4
         WHERE  trim(LC.Legal_Card_TYPE) = D4.L_CODE
         AND D4.CODE_CLMN_NAME = 'ID_TYPE')
      ELSE
         NVL2(LP.CUST_ID,
         CD2.PBOCD_CODE,
         NVL2(LC.TYSHXYDM, 'A01',
         NVL2(LC.id_no,CASE WHEN LENGTH(LC.id_no) = 18 THEN 'A01' ELSE CD1.PBOCD_CODE END, 'A02')))
     END , --借款人证件类型
    -- B.ID_TYPE AS CUST_ID_TYPE,
     CASE when LC.CUST_TYP='3' THEN
        LC.Legal_Card_No
      ELSE
         NVL2(LP.CUST_ID,LP.ID_NO,
              NVL2(LC.TYSHXYDM,LC.TYSHXYDM,
         NVL2(LC.id_no,replace(LC.id_no,'-',''),replace(LC.ORGANIZATIONCODE,'-','')))) END, --借款人证件代码*/
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
     
     NVL2(LP.CUST_ID, '100',CASE  WHEN LC.CUST_TYP=3  THEN '100' ELSE  SUBSTRB(TRIM(LC.CORP_BUSINSESS_TYPE), 0, 3)END), --借款人行业
     NVL2(LP.CUST_ID, LP.REGION_CD, CASE WHEN LC.REGION_CD IS NULL OR LC.REGION_CD='999999'THEN LC.ORG_AREA ELSE LC.REGION_CD  END ), --借款人地区代码
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
      FROM JS_201_CLWTDK_TEMP4 T
      LEFT JOIN SMTMODS.L_CUST_C LC
        ON T.CUST_ID = LC.CUST_ID
       AND LC.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_CUST_ALL B
        ON T.CUST_ID = B.CUST_ID
       AND B.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_CUST_P LP
        ON T.CUST_ID = LP.CUST_ID
       AND LP.DATA_DATE = IS_DATE
      LEFT JOIN L_CODE_DICTIONARY CD1
        ON LC.id_type = CD1.L_CODE
       AND CD1.CODE_CLMN_NAME = 'ID_TYPE'
      LEFT JOIN L_CODE_DICTIONARY CD2
        ON LP.ID_TYPE = CD2.L_CODE
          -- AND CD2.CODE_CLMN_NAME = 'ID_TYPE' --借款人证件代码
       AND CD2.CODE_CLMN_NAME = 'BZR_ID_TYPE' --借款人证件代码
      LEFT JOIN L_CODE_DICTIONARY CD3
        ON LC.CORP_HOLD_TYPE = CD3.L_CODE
       AND CD3.CODE_CLMN_NAME = 'CORP_HOLD_TYPE' --企业控股类型

      LEFT JOIN L_CUST_C_tmp G ---2022.1.14
        ON T.CUST_ID = G.CUST_ID
       AND G.DATA_DATE = IS_DATE
      LEFT JOIN L_CODE_DICTIONARY D4
        ON trim(G.DEPT_TYPE) = D4.L_CODE
       AND D4.CODE_CLMN_NAME = 'DEPT_TYPE' --国民经济部门
    ;
  COMMIT;

  --取委托人信息
  INSERT INTO CUST_WT_TEMP01
    (LOAN_NUM,
     WTRCUSTID,
     DEPT_TYPE,
     CUST_ID_TYPE,
     CUST_ID_NO,
     INDUSTRY_TYPE,
     REG_REGION_CODE,
     CORP_HOLD_TYPE,
     ENT_SCALE,
     CUST_NAME)
    SELECT /*+ use_hash(T,LP,M,LC,CD1,CD2,CD3,D4) parallel(4)*/

     DISTINCT T.LOAN_NUM,
     K.TRUSTOR_ID,
     NVL2(LP.CUST_ID, 'D01', G.DEPT_TYPE), --委托人国民经济部门
     
     
     --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 直取ID_TYPE、ID_NO
     /*NVL2(LP.CUST_ID,
     CD2.PBOCD_CODE,
     NVL2(G.TYSHXYDM,'A01',
     NVL2(G.id_no,CASE WHEN LENGTH(G.id_no) = 18 THEN 'A01' ELSE CD1.PBOCD_CODE END, 'A02'))), --委托人证件类型
   --  G.ID_TYPE AS TRUSTOR_ID_TYPE,
     NVL2(LP.CUST_ID,
     LP.ID_NO,
     NVL2(G.TYSHXYDM,
          G.TYSHXYDM,
          NVL2(G.id_no,replace(G.id_no, '-', ''),replace(G.ORGANIZATIONCODE, '-', '')
               ))), --委托人证件代码
     --  G.ID_NO AS TRUSTOR_ID_NO, --委托人证件代码*/
     NVL2(LP.CUST_ID,CD2.PBOCD_CODE,CD1.PBOCD_CODE), --委托人证件类型
     NVL2(LP.CUST_ID,LP.ID_NO,CASE WHEN CD1.PBOCD_CODE = 'A02' THEN REPLACE(G.ID_NO,'-') ELSE G.ID_NO END), --委托人证件代码

     NVL2(LP.CUST_ID, '100', SUBSTRB(TRIM(G.CORP_BUSINSESS_TYPE), 0, 3)), --委托人行业
     NVL2(LP.CUST_ID, LP.REGION_CD,CASE WHEN G.REGION_CD IS NULL OR  G.REGION_CD='999999' THEN G.ORG_AREA ELSE G.REGION_CD END), --委托人地区代码
     CD3.PBOCD_CODE, --委托人经济成分
     NVL2(G.CUST_ID,
          DECODE(G.CORP_SCALE,
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
     NVL(LP.CUST_NAM, G.CUST_NAM) --委托客户名
      FROM JS_201_CLWTDK_TEMP4 T

      /*LEFT JOIN JS_102_FTYKHX_MAPPING M
        ON T.WTRCUSTID = M.COD_CUST_ID*/
     INNER JOIN SMTMODS.L_ACCT_LOAN_ENTRUST K
        ON T.LOAN_NUM = K.LOAN_NUM
       AND K.DATA_DATE = IS_DATE
     /* LEFT JOIN SMTMODS.L_CUST_ALL H --2022.2.10
        ON K.TRUSTOR_ID = H.CUST_ID*/
      LEFT JOIN L_CUST_C_tmp G ---2022.1.14
        ON K.TRUSTOR_ID = G.CUST_ID
       AND G.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_CUST_P LP
        ON K.TRUSTOR_ID = LP.CUST_ID
       AND LP.DATA_DATE = IS_DATE
      LEFT JOIN L_CODE_DICTIONARY CD1
        ON G.ID_TYPE = CD1.L_CODE
       AND CD1.CODE_CLMN_NAME = 'ID_TYPE'
      LEFT JOIN L_CODE_DICTIONARY CD2
        ON LP.ID_TYPE = CD2.L_CODE
       AND CD2.CODE_CLMN_NAME = 'ID_TYPE'
      LEFT JOIN L_CODE_DICTIONARY CD3
        ON G.CORP_HOLD_TYPE = CD3.L_CODE
       AND CD3.CODE_CLMN_NAME = 'CORP_HOLD_TYPE' --企业控股类型


      LEFT JOIN L_CODE_DICTIONARY D4
        ON trim(G.DEPT_TYPE) = D4.L_CODE
       AND D4.CODE_CLMN_NAME = 'DEPT_TYPE' --国民经济部门
    ;
  COMMIT;





  INSERT INTO JS_201_CLWTDK
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
     ENT_SCALE --10 借款人企业规模
    ,
     LOAN_NUM --11 委托贷款借据编码
    ,
     CONTRACT_CODE --12 委托贷款合同编码
    ,
     ENTRUST_LOAN_GRANT_DATE --13 委托贷款发放日期
    ,
     ENTRUST_LOAN_DUE_DATE --14 委托贷款到期日期
    ,
     ENTRUST_LOAN_DEFER_DUE_DATE --15 委托贷款展期到期日期
    ,
     LOAN_PURPOSE_CD --16 贷款实际投向
    ,
     CURR_CODE --17 委托贷款币种
    ,
     BALANCE --18 委托贷款金额
    ,
     BALANCE_RMB --19 委托贷款金额折人民币
    ,
     INT_RATE_TYPE --20 利率是否固定
    ,
     INT_RATE --21 利率水平
    ,
     FEE_AMT_RMB --22 手续费金额折人民币
    ,
     GUAR_TYPE --23 贷款担保方式
    ,
     LOAN_CLASSIFY --24 贷款质量
    ,
     LOAN_STATUS --25 贷款状态
    ,
     TRUSTOR_DEPT_TYPE --26 委托人国民经济部门
    ,
     TRUSTOR_ID_TYPE --27 委托人证件类型
    ,
     TRUSTOR_ID_NO --28 委托人证件代码
    ,
     TRUSTOR_BUSINSESS_TYPE --29 委托人行业
    ,
     TRUSTOR_REG_AREA_CODE --30 委托人所在地区
    ,
     TRUSTOR_CTRL_ECO_ELEM --31 委托人经济成分
    ,
     TRUSTOR_ENT_SCALE --32 委托人企业规模
    ,
     REPORT_ID --33
    ,
     CJRQ --34 采集日期
    ,
     NBJGH --35 内部机构号
    ,
     BIZ_LINE_ID --36 业务条线
    ,
     VERIFY_STATUS --37
    ,
     BSCJRQ --38
    ,
     USEOFUNDS --39 贷款用途
    ,
     FRNBJGH --40 法人内部机构号
    ,
     CUST_ID --41 客户号
    ,
     CUST_NAME --42 客户名称
    ,
     TRUSTOR_CUST_ID --43 委托人客户号
    ,
     TRUSTOR_CUST_NAME --44 委托人客户名称
     )
    SELECT /*+parallel(4)*/  IS_DATE, --  数据日期
           '',--OFF.JRJGBM ORG_CODE, --1  金融机构代码
           T.ORG_NUM ORG_NUM, --2  内部机构号
           '',--- OFF.AREA_ID ORG_AREA_COD, --3  金融机构地区代码
           T3.DEPT_TYPE DEPT_TYPE, --4 借款人国民经济部门
           T3.CUST_ID_TYPE CUST_ID_TYPE, --5 借款人证件类型
           T3.CUST_ID_NO CUST_ID_NO, --6 借款人证件代码
           T3.INDUSTRY_TYPE INDUSTRY_TYPE, --7 借款人行业
           T3.REG_REGION_CODE REG_AREA_CODE, --8 借款人地区代码
           T3.CORP_HOLD_TYPE ENT_CON_ECO_ELEM, --9 借款人经济成分
           T3.ENT_SCALE ENT_SCALE, --10  借款人企业规模
           T.LOAN_NUM LOAN_NUM, --11  委托贷款借据编码
           T.ACCT_NUM CONTRACT_CODE, --12  委托贷款合同编码
           TO_CHAR(T.DRAWDOWN_DT, 'YYYY-MM-DD') ENTRUST_LOAN_GRANT_DATE, --13  委托贷款发放日期
           TO_CHAR(T.MATURITY_DT, 'YYYY-MM-DD') ENTRUST_LOAN_DUE_DATE, --14  委托贷款到期日期
           CASE
             WHEN ZQ.EXTENDTERM_FLG = 'Y' /*展期标志*/
              THEN
              TO_CHAR(ZQ.ACTUAL_MATURITY_DT, 'YYYY-MM-DD')
           END ENTRUST_LOAN_DEFER_DUE_DATE, --15  委托贷款展期到期日期
           SUBSTRB(T.LOAN_PURPOSE_CD, 1, 4) LOAN_PURPOSE_CD, --16  贷款实际投向
           T.CURR_CD CURR_CODE, --17  币种
           T.LOAN_ACCT_BAL BALANCE, --18  委托贷款余额
           T.LOAN_ACCT_BAL * R.CCY_RATE BALANCE_RMB, --19  贷款余额折人民币
           CASE
             WHEN T.INT_RATE_TYP = 'F' THEN
              'RF01'
             ELSE
              'RF02'
           END INT_RATE_TYPE, --20  利率是否固定
           T.REAL_INT_RAT INT_RATE, --21  利率水平
           E.FEE_AMT FEE_AMT_RMB, --22  手续费金额折人民币

          TP7.GUAR_TYPE AS GUAR_TYPE, --23  贷款担保方式
          CASE
            WHEN T.LOAN_GRADE_CD = '1' /*正常*/
             THEN
             'FQ01'
            WHEN T.LOAN_GRADE_CD = '2' /*关注*/
             THEN
             'FQ02'
            WHEN T.LOAN_GRADE_CD = '3' /*次级*/
             THEN
             'FQ03'
            WHEN T.LOAN_GRADE_CD = '4' /*可疑*/
             THEN
             'FQ04'
            WHEN T.LOAN_GRADE_CD = '5' /*损失*/
             THEN
             'FQ05'
          END LOAN_CLASSIFY, --24  贷款质量
           CASE
             WHEN T.OD_FLG = 'Y' THEN
              'LS03' /*逾期标志*/
             WHEN T.EXTENDTERM_FLG /*展期标志*/
                  = 'Y' THEN
              'LS02'
             ELSE
              'LS01'
           END LOAN_STATUS, --25  贷款状态
           CW.DEPT_TYPE TRUSTOR_DEPT_TYPE, --26  委托人国民经济部门
           CW.CUST_ID_TYPE TRUSTOR_ID_TYPE, --27  委托人证件类型
           CW.CUST_ID_NO TRUSTOR_ID_NO, --28  委托人证件代码
           CW.INDUSTRY_TYPE TRUSTOR_BUSINSESS_TYPE, --29  委托人行业
           CW.REG_REGION_CODE TRUSTOR_REG_AREA_CODE, --30  委托人地区代码
           CW.CORP_HOLD_TYPE TRUSTOR_CTRL_ECO_ELEM, --31  委托人经济成分
           CW.ENT_SCALE TRUSTOR_ENT_SCALE, --32  委托人企业规模
           SYS_GUID() REPORT_ID, --33  REPORT_ID
           IS_DATE CJRQ, --34  采集日期
           T.ORG_NUM NBJGH, --35  内部机构号

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
                 WHEN T.DEPARTMENTD = '公司金融' THEN 'E'
                 WHEN T.DEPARTMENTD = '普惠金融' THEN 'S'
                 WHEN T.DEPARTMENTD = '个人信贷' THEN 'P'
                 --WHEN T.DEPARTMENTD = '磐石村镇' THEN 'V'
                 WHEN T.DEPARTMENTD = '德惠长银' THEN 'E'
             ELSE'99'  END BIZ_LINE_ID, --32 业务条线 20230919王晓彬
           '' VERIFY_STATUS, --37  VERIFY_STATUS
           '' BSCJRQ, --38  BSCJRQ
           T.USEOFUNDS USEOFUNDS, --39  贷款用途

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

           T.CUST_ID CUST_ID, --41  客户号
           T3.CUST_NAME CUST_NAM, --42  客户名称
           CW.WTRCUSTID TRUSTOR_CUST_ID, --43  委托人客户号
           CW.CUST_NAME --44  委托人客户名称
      FROM SMTMODS.L_ACCT_LOAN T

      LEFT JOIN JS_201_CLWTDK_TEMP03 T3 --借款人信息
        ON T.LOAN_NUM = T3.LOAN_NUM
      LEFT JOIN SMTMODS.L_PUBL_RATE R
        ON R.DATA_DATE = IS_DATE
       AND R.BASIC_CCY = T.CURR_CD
       AND R.FORWARD_CCY = 'CNY'
       AND R.DATA_DATE = IS_DATE

      LEFT JOIN DBFS_TMP TP7 --贷款担保方式中间表--在总调里加工
        ON T.LOAN_NUM = TP7.LOAN_NUM

      LEFT JOIN CUST_WT_TEMP01 CW
        ON T.LOAN_NUM = CW.LOAN_NUM
      LEFT JOIN SMTMODS.L_ACCT_LOAN_ENTRUST E --委托贷款补充字段
        ON T.LOAN_NUM = E.LOAN_NUM
       AND E.DATA_DATE = IS_DATE
       LEFT JOIN SMTMODS.v_pub_idx_dk_zqdqrjj ZQ
      ON T.LOAN_NUM = ZQ.LOAN_NUM AND T.DATA_DATE = ZQ.DATA_DATE
     WHERE T.DATA_DATE = IS_DATE
       AND T.LOAN_ACCT_BAL > 0
       AND T.ITEM_CD LIKE '3020%'
       AND T.CANCEL_FLG = 'N' --去掉核销数据
          /*AND T.COD_PROD <> 'WD003000200002'; --剔除个人公积金委托贷款*/
       --AND T.ITEM_CD NOT IN ('406020201', '406020202', '406020204')
       AND T.ITEM_CD NOT IN ('30200201', '30200202')--20220629 夏文博改
     AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
       ;
  COMMIT;

/* --机构变更按照老机构报，如果不用了的机构可以把ORG_NEW表EFF_FLAG字段改成'N'
  UPDATE JS_201_CLWTDK A
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

/*  DELETE FROM PBOCD_JS_201_CLWTDK\*@PBOCD_34*\
   WHERE DATA_DATE = TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  COMMIT;*/
  SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_201_CLWTDK', OI_RETCODE);
  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_201_CLWTDK TRUNCATE PARTITION P' ||
                    IS_DATE;
  INSERT INTO PBOCD_JS_201_CLWTDK /*@PBOCD_34*/
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
     ENT_SCALE --10 借款人企业规模
    ,
     LOAN_NUM --11 委托贷款借据编码
    ,
     CONTRACT_CODE --12 委托贷款合同编码
    ,
     ENTRUST_LOAN_GRANT_DATE --13 委托贷款发放日期
    ,
     ENTRUST_LOAN_DUE_DATE --14 委托贷款到期日期
    ,
     ENTRUST_LOAN_DEFER_DUE_DATE --15 委托贷款展期到期日期
    ,
     LOAN_PURPOSE_CD --16 贷款实际投向
    ,
     CURR_CODE --17 委托贷款币种
    ,
     BALANCE --18 委托贷款金额
    ,
     BALANCE_RMB --19 委托贷款金额折人民币
    ,
     INT_RATE_TYPE --20 利率是否固定
    ,
     INT_RATE --21 利率水平
    ,
     FEE_AMT_RMB --22 手续费金额折人民币
    ,
     GUAR_TYPE --23 贷款担保方式
    ,
     LOAN_CLASSIFY --24 贷款质量
    ,
     LOAN_STATUS --25 贷款状态
    ,
     TRUSTOR_DEPT_TYPE --26 委托人国民经济部门
    ,
     TRUSTOR_ID_TYPE --27 委托人证件类型
    ,
     TRUSTOR_ID_NO --28 委托人证件代码
    ,
     TRUSTOR_BUSINSESS_TYPE --29 委托人行业
    ,
     TRUSTOR_REG_AREA_CODE --30 委托人所在地区
    ,
     TRUSTOR_CTRL_ECO_ELEM --31 委托人经济成分
    ,
     TRUSTOR_ENT_SCALE --32 委托人企业规模
    ,
     REPORT_ID --33
    ,
     CJRQ --34 采集日期
    ,
     NBJGH --35 内部机构号
    ,
     BIZ_LINE_ID --36 业务条线
    ,
     BSCJRQ --38
    ,
     USEOFUNDS --39 贷款用途
    ,
     FRNBJGH --40 法人内部机构号
    ,
     CUST_NAME --41 借款人名称
    ,
     TRUSTOR_CUST_NAME --42 委托人名称
     )
    SELECT /*+parallel(4)*/  VS_TEXT --数据日期
          ,
           NVL(OB.ID_NO,OB.UP_ID_NO) --金融机构代码
           ,
           T.ORG_NUM   --2 内部机构号
            ,
           OB.REGION_CD --3  金融机构地区代码
          ,
           T.DEPT_TYPE --4 借款人国民经济部门
          ,
           T.CUST_ID_TYPE --5 借款人证件类型
          ,
           T.CUST_ID_NO --6 借款人证件代码
          ,
           T.INDUSTRY_TYPE --7 借款人行业
          ,
           T.REG_AREA_CODE --8 借款人地区代码
          ,
           T.ENT_CON_ECO_ELEM --9 借款人经济成分
          ,
           T.ENT_SCALE --10 借款人企业规模
          ,
           T.LOAN_NUM --11 委托贷款借据编码
          ,
           T.CONTRACT_CODE --12 委托贷款合同编码
          ,
           T.ENTRUST_LOAN_GRANT_DATE --13 委托贷款发放日期
          ,
           T.ENTRUST_LOAN_DUE_DATE --14 委托贷款到期日期
          ,
           T.ENTRUST_LOAN_DEFER_DUE_DATE --15 委托贷款展期到期日期
          ,
           NVL(T.LOAN_PURPOSE_CD,
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
          ,
           T.CURR_CODE --17 委托贷款币种
          ,
           T.BALANCE --18 委托贷款金额
          ,
           T.BALANCE_RMB --19 委托贷款金额折人民币
          ,
           T.INT_RATE_TYPE --20 利率是否固定
          ,
           T.INT_RATE --21 利率水平
          ,
           NVL(BK.FEE_AMT_RMB,T.FEE_AMT_RMB) --22 手续费金额折人民币
          ,
           T.GUAR_TYPE --23 贷款担保方式
          ,
           T.LOAN_CLASSIFY --24 贷款质量
          ,
           T.LOAN_STATUS --25 贷款状态
          ,
          --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
          -- NVL(T.TRUSTOR_DEPT_TYPE,BK.TRUSTOR_DEPT_TYPE)  --26 委托人国民经济部门
           T.TRUSTOR_DEPT_TYPE  --26 委托人国民经济部门
          ,
           T.TRUSTOR_ID_TYPE --27 委托人证件类型
          ,
           T.TRUSTOR_ID_NO --28 委托人证件代码
          ,
           T.TRUSTOR_BUSINSESS_TYPE --29 委托人行业
          ,
          --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
           --DECODE(T.TRUSTOR_REG_AREA_CODE,'220171','220105','220172','220104',T.TRUSTOR_REG_AREA_CODE)--30 委托人所在地区
           T.TRUSTOR_REG_AREA_CODE--30 委托人所在地区
          ,
           T.TRUSTOR_CTRL_ECO_ELEM --31 委托人经济成分
          ,
          --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
           /*CASE WHEN NVL(T.TRUSTOR_DEPT_TYPE,BK.TRUSTOR_DEPT_TYPE) LIKE 'C%'
                     AND NVL(T.TRUSTOR_DEPT_TYPE,BK.TRUSTOR_DEPT_TYPE) <> 'C99'
                     AND T.TRUSTOR_ENT_SCALE='CS05' THEN BK.TRUSTOR_ENT_SCALE
                ELSE T.TRUSTOR_ENT_SCALE END--32 委托人企业规模*/
           T.TRUSTOR_ENT_SCALE --32 委托人企业规模  
                
          ,
           T.REPORT_ID --33
          ,
           T.CJRQ --34 采集日期
          ,
           T.NBJGH --35 内部机构号
          ,
           T.BIZ_LINE_ID --36 业务条线
          ,
           T.BSCJRQ --38
          ,
           T.USEOFUNDS --39 贷款用途
          ,
           T.FRNBJGH,
           T.CUST_NAME --41 借款人名称
          ,
           T.TRUSTOR_CUST_NAME --42 委托人名称
      FROM JS_201_CLWTDK T
     LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=T.ORG_NUM AND OB.DATA_DATE=IS_DATE
     LEFT JOIN PBOCD_JS_201_CLWTDK_SQ/*@PBOCD_20_34*/ BK
      ON T.LOAN_NUM = BK.LOAN_NUM
      AND BK.CJRQ = VS_LAST_TEXT
     WHERE TRIM(T.DATA_DATE) = IS_DATE;

  COMMIT;

--特殊处理
--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除借款人经济成分的刷数逻辑
--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
/*--借款人经济成分、企业规模，委托人经济成分、企业规模
UPDATE PBOCD_JS_201_CLWTDK
   SET --ENT_CON_ECO_ELEM      = 'A0101',
       ENT_SCALE             = 'CS03',
       TRUSTOR_CTRL_ECO_ELEM = '',
       TRUSTOR_ENT_SCALE     = 'CS05'
 WHERE CJRQ = IS_DATE
   AND CONTRACT_CODE = '82401242006062701';
COMMIT;*/

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 这笔已经过渡没了
/*--经济部门
UPDATE PBOCD_JS_201_CLWTDK
   SET DEPT_TYPE = 'A04'
 WHERE CJRQ = IS_DATE
   AND CUST_ID_NO IN ('12220600589487324Q')
   AND DEPT_TYPE IS NULL;
COMMIT;*/

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除借款人经济成分的刷数逻辑
--借款人经济成分
/*UPDATE PBOCD_JS_201_CLWTDK A
   SET ENT_CON_ECO_ELEM = ''
 WHERE CJRQ = IS_DATE
   AND LOAN_NUM = '20221125051609001'
   AND ENT_CON_ECO_ELEM IS NOT NULL;
COMMIT;*/

--[2025-07-29] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_三阶段][李楠] 改之前就是2022-06-03，相当于无效语句
/*--当贷款展期到期日期不为空且贷款状态为LS02-展期时，委托贷款到期日期应小于委托贷款展期到期日期
UPDATE PBOCD_JS_201_CLWTDK
   SET ENTRUST_LOAN_DUE_DATE = '2022-06-03'
 WHERE CJRQ = IS_DATE
   AND CONTRACT_CODE = '010301210012177606';
COMMIT;*/


--这笔历史数据，利率是0置空，手续费折人民币是0置空，证件类型/代码维持不变  --zhoulp20260116此操作经楠姐确认保留
UPDATE PBOCD_JS_201_CLWTDK B
   SET INT_RATE        = ''
      ,FEE_AMT_RMB     = ''
      ,CUST_ID_TYPE    = 'A02'
      ,CUST_ID_NO      = '82411001Z'
      ,TRUSTOR_ID_TYPE = 'A02'
      --,TRUSTOR_ID_NO   = '82411008Z'
 WHERE CJRQ = IS_DATE
   AND LOAN_NUM = '8240124200606270101';
COMMIT;

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
/*--委托人国民经济部门为C开头且不是C99-其他非金融企业部门的非金融企业部门，则委托人企业规模应该在CS01-大型至CS04-微型范围内
MERGE INTO PBOCD_JS_201_CLWTDK A
USING (SELECT * FROM PBOCD_JS_201_CLWTDK_SQ WHERE CJRQ = VS_LAST_TEXT) B
ON (A.LOAN_NUM = B.LOAN_NUM)
WHEN MATCHED THEN
  UPDATE
     SET A.TRUSTOR_ENT_SCALE = B.TRUSTOR_ENT_SCALE
   WHERE CJRQ = IS_DATE
     AND TRUSTOR_DEPT_TYPE LIKE 'C%'
     AND TRUSTOR_DEPT_TYPE <> 'C99'
     AND TRUSTOR_ENT_SCALE = 'CS05';
COMMIT;*/

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
/*--公主岭地区代码
UPDATE PBOCD_JS_201_CLWTDK
   SET ORG_AREA_COD = '220184'
 WHERE CJRQ = IS_DATE
   AND ORG_AREA_COD = '220381';
COMMIT;*/

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
/*UPDATE PBOCD_JS_201_CLWTDK
   SET REG_AREA_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND REG_AREA_CODE = '220381';
COMMIT;*/

--[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
/*UPDATE PBOCD_JS_201_CLWTDK
   SET TRUSTOR_REG_AREA_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND TRUSTOR_REG_AREA_CODE = '220381';
COMMIT;*/

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
/*--总行每月固定借据号，刷借款人地区代码
MERGE INTO PBOCD_JS_201_CLWTDK A
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

    VI_ERRORCODE := SQLCODE; --设置异常代码
    VS_TEXT      := VS_STEP || '|' || IS_DATE || '|' ||
                    SUBSTR(SQLERRM, 1, 200); --设置异常描述
    ROLLBACK; --数据回滚
    OI_RETCODE := -1; --设置异常状态为-1
    OI_RETCODE_DEC :=SQLCODE||':'||SUBSTR(SQLERRM,1,50);--系统错误描述
    --插入日志表，记录错误
    SP_PBOCD_LOG(VS_PROCEDURE_NAME, 'ERROR', VI_ERRORCODE, VS_TEXT, IS_DATE);
END;