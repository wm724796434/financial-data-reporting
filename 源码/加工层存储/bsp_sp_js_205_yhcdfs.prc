CREATE OR REPLACE PROCEDURE BSP_SP_JS_205_YHCDFS(IS_DATE    IN VARCHAR2,
                                                  OI_RETCODE OUT INTEGER,
                                                  OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  --    SP_JS_205_YHCDFS
  -- 用途:生成接口表 JS_205_YHCDFS 银行承兑汇票发生额信息表
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    CAEATE BY USER AT 20220128
  --    MODFY BY DW AT 20220802 增加磐石机构上期数据
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段 上线日期：2025-04-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段 上线日期：2025-05-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_四阶段 上线日期：2025-09-18，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  --    需求编号：JLBA202510210010_关于金数平台银承部分报表取数规则及展示的优化的需求 上线日期：2026-04-21，修改人：周立鹏，提出人：孙平刚   修改原因：优化收款人证件类型、号码取数口径
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
  NUM               INTEGER;
  VS_NMONTH         VARCHAR2(10);

BEGIN
  VS_TEXT      := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),
                          'YYYYMMDD');
  VS_NMONTH         := TO_CHAR(TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD') + 1),
                           'YYYYMMDD');
  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_205_YHCDFS';
  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------



  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_205_YHCDFS_TMP2';
--轧差
  INSERT INTO  JS_205_YHCDFS_TMP2
  SELECT '01' AS ID,
  T.DATA_DATE,
  T.ORG_CODE,
  T.ORG_NUM,
  T.REG_REGION_CODE,
  T.DRAWER_NAME,
  T.DRAWER_ID_TYPE,
  T.DRAWER_ID_NO,
  T.DRAWER_INDUSTRY_TYPE,
  T.DRAWER_AREA_CODE,
  T.DRAWER_CON_ECO_ELEM,
  T.DRAWER_ENT_SCALE,
  T.RECE_NAME,
  T.RECE_ID_TYPE,
  T.RECE_ID_NO,
  T.BILL_NUM,
  T.BILL_MEDIUM,
  T.OPEN_DATE,
  T.BILL_DUE_DATE,
  T.BILL_CURR_CODE,
  T.BILL_AMT,
  T.BILL_AMT_RMB,
  T.FEE_AMT_RMB,
  T.MARGIN_RATIO,
  T.GUAR_TYPE,
  T.REPORT_ID,
  T.CJRQ,
  T.BIZ_LINE_ID,
  T.VERIFY_STATUS,
  T.BSCJRQ,
  T.FRNBJGH,
  T.NBJGH
  FROM PBOCD_DATACORE.PBOCD_JS_205_CLYHCD T
  WHERE T.CJRQ =IS_DATE
  AND NOT EXISTS (
      SELECT 1 FROM PBOCD_JS_205_CLYHCD_SQ F WHERE F.CJRQ =VS_LAST_TEXT AND T.BILL_NUM =F.BILL_NUM)
      
  UNION ALL
  SELECT '02',
  T.DATA_DATE,
  T.ORG_CODE,
  T.ORG_NUM,
  T.REG_REGION_CODE,
  T.DRAWER_NAME,
  T.DRAWER_ID_TYPE,
  T.DRAWER_ID_NO,
  T.DRAWER_INDUSTRY_TYPE,
  T.DRAWER_AREA_CODE,
  T.DRAWER_CON_ECO_ELEM,
  T.DRAWER_ENT_SCALE,
  T.RECE_NAME,
  T.RECE_ID_TYPE,
  T.RECE_ID_NO,
  T.BILL_NUM,
  T.BILL_MEDIUM,
  T.OPEN_DATE,
  T.BILL_DUE_DATE,
  T.BILL_CURR_CODE,
  T.BILL_AMT,
  T.BILL_AMT_RMB,
  T.FEE_AMT_RMB,
  T.MARGIN_RATIO,
  T.GUAR_TYPE,
  T.REPORT_ID,
  T.CJRQ,
  T.BIZ_LINE_ID,
  T.VERIFY_STATUS,
  T.BSCJRQ,
  T.FRNBJGH,
  T.NBJGH
  FROM PBOCD_JS_205_CLYHCD_SQ T WHERE T.CJRQ =VS_LAST_TEXT
  AND NOT EXISTS (SELECT 1 FROM  PBOCD_DATACORE.PBOCD_JS_205_CLYHCD F WHERE F.CJRQ =IS_DATE AND T.BILL_NUM =F.BILL_NUM  );
  COMMIT;


      --查看落地表是否已经建立分区
    SELECT COUNT(1)
      INTO NUM
      FROM USER_TAB_PARTITIONS
     WHERE TABLE_NAME = 'JS_205_YHCDFS'
       AND PARTITION_NAME = 'P' || IS_DATE;

    --如果没有建立分区，则增加分区
    IF (NUM = 0) THEN
      EXECUTE IMMEDIATE 'ALTER TABLE JS_205_YHCDFS ADD PARTITION P' ||
                        IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
    END IF;

    EXECUTE IMMEDIATE 'ALTER TABLE JS_205_YHCDFS TRUNCATE PARTITION P' ||
                      IS_DATE;


--插入轧差后的数据
    INSERT INTO JS_205_YHCDFS
  (
        DATA_DATE                 --数据日期
        ,ORG_CODE                 --金融机构代码
        ,ORG_NUM                 --内部机构号
        ,REG_REGION_CODE         --金融机构地区代码
        ,DRAWER_NAME              --出票人名称
        ,DRAWER_ID_TYPE           --出票人证件类型
        ,DRAWER_ID_NO             --出票人证件代码
        ,DRAWER_INDUSTRY_TYPE     --出票人行业
        ,DRAWER_AREA_CODE         --出票人地区代码
        ,DRAWER_CON_ECO_ELEM      --出票人经济成分
        ,DRAWER_ENT_SCALE         --出票人企业规模
        ,RECE_NAME                --收款人名称
        ,RECE_ID_TYPE             --收款人证件类型
        ,RECE_ID_NO               --收款人证件代码
        ,BILL_NUM                 --票据编号
        ,BILL_MEDIUM               --票据介质
        ,OPEN_DATE                 --出票日期
        ,BILL_DUE_DATE             --票据到期日期
        ,TRANS_DATE                --交易日期
        ,BILL_CURR_CODE            --币种
        ,TRANS_AMT                 --交易金额
        ,TRANS_AMT_RMB              --交易金额折人民币
        ,FEE_AMT_RMB               --手续费金额折人民币
        ,MARGIN_RATIO              --保证金比例
        ,TRANS_TYPE                --承兑/兑付标识
        ,ADVANCES_AMT_RMB          --垫款金额折人民币
        ,SERIAL_NO                 --交易流水号
        ,GUAR_TYPE                 --担保方式
        ,REPORT_ID
        ,CJRQ
        ,BIZ_LINE_ID
        ,VERIFY_STATUS
        ,BSCJRQ
        ,FRNBJGH
        ,NBJGH
  )
  SELECT /*+ parallel(4)*/
        VS_TEXT DATA_DATE,
        A.ORG_CODE,
        A.ORG_NUM,
        A.REG_REGION_CODE,
        A.DRAWER_NAME,
        A.DRAWER_ID_TYPE,
        A.DRAWER_ID_NO,
        A.DRAWER_INDUSTRY_TYPE,
        A.DRAWER_AREA_CODE,
        A.DRAWER_CON_ECO_ELEM,
        A.DRAWER_ENT_SCALE,
        A.RECE_NAME,
        A.RECE_ID_TYPE,
        A.RECE_ID_NO,
        A.BILL_NUM,
        A.BILL_MEDIUM,
        A.OPEN_DATE,
        A.BILL_DUE_DATE,
        CASE WHEN ID = '01' THEN A.OPEN_DATE ELSE
          CASE WHEN SUBSTR(REPLACE(A.BILL_DUE_DATE,'-'),1,6) = SUBSTR(IS_DATE,1,6) THEN  A.BILL_DUE_DATE ELSE TO_CHAR(TO_DATE(LOAN.DATA_DATE,'YYYYMMDD'),'YYYY-MM-DD') END
        END  TRANS_DATE,
        A.BILL_CURR_CODE,
        A.BILL_AMT TRANS_AMT,
        A.BILL_AMT_RMB TRANS_AMT_RMB,
        A.FEE_AMT_RMB,
        NVL(A.MARGIN_RATIO,0),
        A.ID TRANS_TYPE,
        
        --[2026-04-21] [周立鹏] [JLBA202510210010_关于金数平台银承部分报表取数规则及展示的优化的需求][孙平刚] 垫款金额折人民币
        --0 ADVANCES_AMT_RMB,
        NVL(C.DRAWDOWN_AMT * R.CCY_RATE,0) AS ADVANCES_AMT_RMB,
        
        SYS_GUID() SERIAL_NO,
        A.GUAR_TYPE,
        SYS_GUID() REPORT_ID,
        IS_DATE CJRQ,
        A.BIZ_LINE_ID,
        '' VERIFY_STATUS,
        A.BSCJRQ,
        A.FRNBJGH,
        A.NBJGH
   FROM JS_205_YHCDFS_TMP2 A
   LEFT JOIN (
        SELECT
               LOAN.ACCT_NUM,
               MIN(LOAN.DATA_DATE) DATA_DATE
        FROM SMTMODS.L_ACCT_OBS_lOAN LOAN
        WHERE LOAN.DATA_DATE BETWEEN TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE,'YYYYMMDD'),-1)+1,'YYYYMMDD')  AND IS_DATE
        AND LOAN.BALANCE  = 0
        GROUP BY LOAN.ACCT_NUM
   ) LOAN
   ON A.BILL_NUM = LOAN.ACCT_NUM
   --[2026-04-21] [周立鹏] [JLBA202510210010_关于金数平台银承部分报表取数规则及展示的优化的需求][孙平刚] 垫款金额折人民币
   LEFT JOIN SMTMODS.L_ACCT_LOAN C 
     ON C.DATA_DATE = IS_DATE 
     AND 'DK'||A.BILL_NUM = C.LOAN_NUM
   LEFT JOIN  SMTMODS.L_PUBL_RATE R --汇率信息表
     ON R.DATA_DATE = IS_DATE
     AND R.BASIC_CCY =trim(C.CURR_CD)
     AND R.FORWARD_CCY = 'CNY'
     AND R.DATA_DATE = IS_DATE
   
  ;

--插入当月开票当月作废的数据--发生方向
INSERT INTO JS_205_YHCDFS
 SELECT /*+ PARALLEL(4)*/ VS_TEXT --数据日期
        ,
         '' JRJGBM --金融机构
        ,
         A.ORG_NUM --机构号
        ,
         '' AREA_ID --地区代码
        ,
         B.AFF_NAME --出票人名称
        ,
         '' --CD5.PBOCD_CODE--出票人证件类型 --******
        ,
         '' --B.ID_NO--出票人证件代码        --******
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
         B.RECE_ID_NO--收款人证件代码
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
        ,TO_CHAR(B.OPEN_DATE, 'YYYY-MM-DD') --交易日期--因为是补录当天作废的，取出票日期
        ,
         TRIM(B.CURR_CD) --币种
        ,
         A.TRAN_AMT  --B.AMOUNT --票面金额
        ,
         A.TRAN_AMT * R.CCY_RATE --B.AMOUNT * R.CCY_RATE --票面金额折人民币
        ,
         (A.TRAN_AMT * R.CCY_RATE) / 10000 * 5  --(B.AMOUNT * R.CCY_RATE) / 10000 * 5 --手续费金额折人民币 20220824 将手续费改为票据面额的万分之五
        ,
         NVL(A.SECURITY_RATE,0) * 100 --保证金比例
        ,'01'--交易方向
        
        --[2026-04-21] [周立鹏] [JLBA202510210010_关于金数平台银承部分报表取数规则及展示的优化的需求][孙平刚] 垫款金额折人民币
        --0 ADVANCES_AMT_RMB,
        ,NVL(C.DRAWDOWN_AMT * R.CCY_RATE,0) AS ADVANCES_AMT_RMB
        
        ,SYS_GUID() SERIAL_NO
        ,CASE
           WHEN DBFS.CN >= 2 AND DBW.BUSINESSCODE IS NOT NULL THEN
            'E01' --含房地产抵押的组合担保
           WHEN H.MAIN_GUARANTY_TYP = '1' AND DBW.BUSINESSCODE IS NOT NULL THEN
            'B01' --房产抵押贷款
           WHEN DBFS.CN >= 2 THEN
            'E' --组合贷款
           WHEN H.MAIN_GUARANTY_TYP = '1' AND NVL(A.SECURITY_AMT, 0) <> 0 THEN
            'E'
           WHEN H.MAIN_GUARANTY_TYP = '1' THEN
            'B99' --其他抵押
           WHEN H.MAIN_GUARANTY_TYP = '0' THEN
            'A' --质押贷款
           WHEN H.MAIN_GUARANTY_TYP = '2' AND NVL(A.SECURITY_AMT, 0) <> 0 THEN
            'E'
           WHEN H.MAIN_GUARANTY_TYP = '2' THEN
            'C99' --保证贷款
           WHEN H.MAIN_GUARANTY_TYP = '3' AND NVL(A.SECURITY_AMT, 0) <> 0 THEN
            'A'
           WHEN H.MAIN_GUARANTY_TYP = '3' THEN
            'D'
           ELSE
            'E'
         END AS GURT_TYPE --担保方式
        ,SYS_GUID() REPORT_ID
        ,IS_DATE CJRQ
        ,'' BIZ_LINE_ID
        ,'' VERIFY_STATUS
        ,''BSCJRQ
        ,''FRNBJGH
        ,A.ORG_NUM NBJGH
       
    FROM SMTMODS.L_ACCT_OBS_LOAN A --表外
    LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B --商业汇票票面信息表
      ON A.ACCT_NUM = B.BILL_NUM
     AND B.DATA_DATE = IS_DATE
    LEFT JOIN SMTMODS.L_CUST_P D --对私客户补充信息表
      ON A.CUST_ID = D.CUST_ID
     AND D.DATA_DATE = IS_DATE
    LEFT JOIN SMTMODS.L_CUST_C F --对公客户补充信息表
      ON A.CUST_ID = F.CUST_ID
     AND F.DATA_DATE = IS_DATE
    LEFT JOIN SMTMODS.L_AGRE_LOAN_CONTRACT H
      ON A.ACCT_NO = H.CONTRACT_NUM
     AND H.DATA_DATE = IS_DATE
    LEFT JOIN L_CODE_DICTIONARY CD1
      ON D.ID_TYPE = CD1.L_CODE
     AND CD1.CODE_CLMN_NAME = 'ID_TYPE'
    LEFT JOIN L_CODE_DICTIONARY CD2
      ON F.ID_TYPE = CD2.L_CODE
     AND CD2.CODE_CLMN_NAME = 'BZR_ID_TYPE'
    LEFT JOIN L_CODE_DICTIONARY CD4
      ON F.CORP_HOLD_TYPE = CD4.L_CODE
     AND CD4.CODE_CLMN_NAME = 'CORP_HOLD_TYPE' --企业控股类型
    
    --[2026-04-21] [周立鹏] [JLBA202510210010_关于金数平台银承部分报表取数规则及展示的优化的需求][孙平刚] 垫款金额折人民币
    LEFT JOIN SMTMODS.L_ACCT_LOAN C 
      ON C.DATA_DATE = IS_DATE 
     AND 'DK'||B.BILL_NUM = C.LOAN_NUM
     
    LEFT JOIN SMTMODS.L_PUBL_RATE R --汇率信息表
      ON R.DATA_DATE = IS_DATE
     AND R.BASIC_CCY = TRIM(B.CURR_CD)
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
              GROUP BY T.CONTRACT_NUM) DBFS
      ON A.ACCT_NO = DBFS.CONTRACT_NUM
    LEFT JOIN JS_205_CLYHCD_TMP2 DBW --担保物表，当担保方式为质押贷款时，关联担保物确定是否是房地产抵押
      ON A.ACCT_NO = DBW.BUSINESSCODE
WHERE A.DATA_DATE = IS_DATE
     AND A.BALANCE = 0
     AND A.TRAN_AMT > 0 AND A.TRAN_AMT * R.CCY_RATE > 0
     AND A.ACCT_TYP IN('111','112') AND TO_CHAR(A.BUSINESS_DT,'yyyymm')=SUBSTR(IS_DATE,1,6);
COMMIT;

--插入当月开票当月作废的数据--收回方向
INSERT INTO JS_205_YHCDFS
 SELECT /*+ PARALLEL(4)*/ VS_TEXT --数据日期
        ,
         '' JRJGBM --金融机构
        ,
         A.ORG_NUM --机构号
        ,
         '' AREA_ID --地区代码
        ,
         B.AFF_NAME --出票人名称
        ,
         '' --CD5.PBOCD_CODE--出票人证件类型 --******
        ,
         '' --B.ID_NO--出票人证件代码        --******
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
         B.RECE_ID_NO--收款人证件代码
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
        ,TO_CHAR(B.OPEN_DATE, 'YYYY-MM-DD') --交易日期--因为是补录当天作废的，取出票日期
        ,
         TRIM(B.CURR_CD) --币种
        ,
         A.TRAN_AMT --B.AMOUNT --票面金额
        ,
         A.TRAN_AMT * R.CCY_RATE--B.AMOUNT * R.CCY_RATE --票面金额折人民币
        ,
         (A.TRAN_AMT * R.CCY_RATE) / 10000 * 5--(B.AMOUNT * R.CCY_RATE) / 10000 * 5 --手续费金额折人民币 20220824 将手续费改为票据面额的万分之五
        ,
         NVL(A.SECURITY_RATE,0) * 100 --保证金比例
        ,'02'--交易方向
        
        --[2026-04-21] [周立鹏] [JLBA202510210010_关于金数平台银承部分报表取数规则及展示的优化的需求][孙平刚] 垫款金额折人民币
        --0 ADVANCES_AMT_RMB,
        ,NVL(C.DRAWDOWN_AMT * R.CCY_RATE,0) AS ADVANCES_AMT_RMB
        
        ,SYS_GUID() SERIAL_NO
        ,CASE
           WHEN DBFS.CN >= 2 AND DBW.BUSINESSCODE IS NOT NULL THEN
            'E01' --含房地产抵押的组合担保
           WHEN H.MAIN_GUARANTY_TYP = '1' AND DBW.BUSINESSCODE IS NOT NULL THEN
            'B01' --房产抵押贷款
           WHEN DBFS.CN >= 2 THEN
            'E' --组合贷款
           WHEN H.MAIN_GUARANTY_TYP = '1' AND NVL(A.SECURITY_AMT, 0) <> 0 THEN
            'E'
           WHEN H.MAIN_GUARANTY_TYP = '1' THEN
            'B99' --其他抵押
           WHEN H.MAIN_GUARANTY_TYP = '0' THEN
            'A' --质押贷款
           WHEN H.MAIN_GUARANTY_TYP = '2' AND NVL(A.SECURITY_AMT, 0) <> 0 THEN
            'E'
           WHEN H.MAIN_GUARANTY_TYP = '2' THEN
            'C99' --保证贷款
           WHEN H.MAIN_GUARANTY_TYP = '3' AND NVL(A.SECURITY_AMT, 0) <> 0 THEN
            'A'
           WHEN H.MAIN_GUARANTY_TYP = '3' THEN
            'D'
           ELSE
            'E'
         END AS GURT_TYPE --担保方式
        ,SYS_GUID() REPORT_ID
        ,IS_DATE CJRQ
        ,'' BIZ_LINE_ID
        ,'' VERIFY_STATUS
        ,''BSCJRQ
        ,''FRNBJGH
        ,A.ORG_NUM NBJGH
       
    FROM SMTMODS.L_ACCT_OBS_LOAN A --表外
    LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B --商业汇票票面信息表
      ON A.ACCT_NUM = B.BILL_NUM
     AND B.DATA_DATE = IS_DATE
    LEFT JOIN SMTMODS.L_CUST_P D --对私客户补充信息表
      ON A.CUST_ID = D.CUST_ID
     AND D.DATA_DATE = IS_DATE
    LEFT JOIN SMTMODS.L_CUST_C F --对公客户补充信息表
      ON A.CUST_ID = F.CUST_ID
     AND F.DATA_DATE = IS_DATE
    LEFT JOIN SMTMODS.L_AGRE_LOAN_CONTRACT H
      ON A.ACCT_NO = H.CONTRACT_NUM
     AND H.DATA_DATE = IS_DATE
    LEFT JOIN L_CODE_DICTIONARY CD1
      ON D.ID_TYPE = CD1.L_CODE
     AND CD1.CODE_CLMN_NAME = 'ID_TYPE'
    LEFT JOIN L_CODE_DICTIONARY CD2
      ON F.ID_TYPE = CD2.L_CODE
     AND CD2.CODE_CLMN_NAME = 'BZR_ID_TYPE'
    LEFT JOIN L_CODE_DICTIONARY CD4
      ON F.CORP_HOLD_TYPE = CD4.L_CODE
     AND CD4.CODE_CLMN_NAME = 'CORP_HOLD_TYPE' --企业控股类型
     
    --[2026-04-21] [周立鹏] [JLBA202510210010_关于金数平台银承部分报表取数规则及展示的优化的需求][孙平刚] 垫款金额折人民币
    LEFT JOIN SMTMODS.L_ACCT_LOAN C 
      ON C.DATA_DATE = IS_DATE 
     AND 'DK'||B.BILL_NUM = C.LOAN_NUM
     
    LEFT JOIN SMTMODS.L_PUBL_RATE R --汇率信息表
      ON R.DATA_DATE = IS_DATE
     AND R.BASIC_CCY = TRIM(B.CURR_CD)
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
              GROUP BY T.CONTRACT_NUM) DBFS
      ON A.ACCT_NO = DBFS.CONTRACT_NUM
    LEFT JOIN JS_205_CLYHCD_TMP2 DBW --担保物表，当担保方式为质押贷款时，关联担保物确定是否是房地产抵押
      ON A.ACCT_NO = DBW.BUSINESSCODE
WHERE A.DATA_DATE = IS_DATE
     AND A.BALANCE = 0 
     AND A.TRAN_AMT > 0 AND A.TRAN_AMT * R.CCY_RATE > 0
     AND A.ACCT_TYP IN('111','112') AND TO_CHAR(A.BUSINESS_DT,'yyyymm')=SUBSTR(IS_DATE,1,6);
COMMIT;

  -------------------吉林银行目标表数据--------------------
  ---清除历史数据
  DELETE FROM PBOCD_JS_205_YHCDFS
   WHERE DATA_DATE = TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  COMMIT;


    ---以下包含原应用层加工逻辑，现都放在加工层处理
 INSERT INTO PBOCD_JS_205_YHCDFS
  (
        DATA_DATE                 --数据日期
        ,ORG_CODE                 --金融机构代码
        ,ORG_NUM                 --内部机构号
        ,REG_REGION_CODE         --金融机构地区代码
        ,DRAWER_NAME              --出票人名称
        ,DRAWER_ID_TYPE           --出票人证件类型
        ,DRAWER_ID_NO             --出票人证件代码
        ,DRAWER_INDUSTRY_TYPE     --出票人行业
        ,DRAWER_AREA_CODE         --出票人地区代码
        ,DRAWER_CON_ECO_ELEM      --出票人经济成分
        ,DRAWER_ENT_SCALE         --出票人企业规模
        ,RECE_NAME                --收款人名称
        ,RECE_ID_TYPE             --收款人证件类型
        ,RECE_ID_NO               --收款人证件代码
        ,BILL_NUM                 --票据编号
        ,BILL_MEDIUM               --票据介质
        ,OPEN_DATE                 --出票日期
        ,BILL_DUE_DATE             --票据到期日期
        ,TRANS_DATE                --交易日期
        ,BILL_CURR_CODE            --币种
        ,TRANS_AMT                 --交易金额
        ,TRANS_AMT_RMB              --交易金额折人民币
        ,FEE_AMT_RMB               --手续费金额折人民币
        ,MARGIN_RATIO              --保证金比例
        ,TRANS_TYPE                --承兑/兑付标识
        ,ADVANCES_AMT_RMB          --垫款金额折人民币
        ,SERIAL_NO                 --交易流水号
        ,GUAR_TYPE                 --担保方式
        ,REPORT_ID
    ,CJRQ                      --采集日期
    ,BIZ_LINE_ID
    ,VERIFY_STATUS
    ,BSCJRQ
    ,FRNBJGH
    ,NBJGH
  )
  SELECT /*+ parallel(4)*/
        VS_TEXT                 --数据日期
        ,NVL(OB.ID_NO,OB.UP_ID_NO) --金融机构代码
        ,T.ORG_NUM                 --内部机构号
        ,OB.REGION_CD --3  金融机构地区代码
        ,DRAWER_NAME              --出票人名称
        ,DRAWER_ID_TYPE           --出票人证件类型
        ,DRAWER_ID_NO             --出票人证件代码
        ,DRAWER_INDUSTRY_TYPE     --出票人行业
        ,DRAWER_AREA_CODE         --出票人地区代码
        ,DRAWER_CON_ECO_ELEM      --出票人经济成分
        ,DRAWER_ENT_SCALE         --出票人企业规模
        ,RECE_NAME                --收款人名称
        ,RECE_ID_TYPE             --收款人证件类型
        ,RECE_ID_NO               --收款人证件代码
        ,BILL_NUM                 --票据编号
        ,BILL_MEDIUM               --票据介质
        ,OPEN_DATE                 --出票日期
        ,BILL_DUE_DATE             --票据到期日期
        ,TRANS_DATE                --交易日期
        ,BILL_CURR_CODE            --币种
        ,TRANS_AMT                 --交易金额
        ,TRANS_AMT_RMB              --交易金额折人民币
        ,FEE_AMT_RMB               --手续费金额折人民币
        ,MARGIN_RATIO              --保证金比例
        ,TRANS_TYPE                --承兑/兑付标识
        ,ADVANCES_AMT_RMB          --垫款金额折人民币
        ,SERIAL_NO                 --交易流水号
        ,GUAR_TYPE                 --担保方式
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
          END AS BIZ_LINE_ID --业务条线 20231013王晓彬
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
  FROM   JS_205_YHCDFS T
  LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=T.ORG_NUM AND OB.DATA_DATE=IS_DATE
  WHERE TRIM(T.CJRQ) =IS_DATE;
  COMMIT;

--[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
/*--出票人地区代码
UPDATE PBOCD_JS_205_YHCDFS
   SET DRAWER_AREA_CODE = '220201'
 WHERE CJRQ = IS_DATE
   AND DRAWER_AREA_CODE = '220272';
COMMIT;

UPDATE PBOCD_JS_205_YHCDFS
   SET DRAWER_AREA_CODE = '220104'
 WHERE CJRQ = IS_DATE
   AND DRAWER_AREA_CODE = '220172';
COMMIT;

UPDATE PBOCD_JS_205_YHCDFS
   SET DRAWER_AREA_CODE = '220200'
 WHERE CJRQ = IS_DATE
   AND DRAWER_AREA_CODE = '220271';
COMMIT;*/

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
--公主岭地区代码
/*UPDATE PBOCD_JS_205_YHCDFS
   SET REG_REGION_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND REG_REGION_CODE = '220381';
COMMIT;*/

--[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
/*UPDATE PBOCD_JS_205_YHCDFS
   SET DRAWER_AREA_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND DRAWER_AREA_CODE = '220381';
COMMIT;*/

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
/*--出票人经济成分
UPDATE PBOCD_JS_205_YHCDFS
   SET DRAWER_CON_ECO_ELEM = 'B0101'
 WHERE CJRQ = IS_DATE
   AND DRAWER_NAME = '通药制药集团股份有限公司'
   AND DRAWER_CON_ECO_ELEM <> 'B0101';
COMMIT;

--出票人企业规模是CS05的，出票人经济成分置空
UPDATE PBOCD_JS_205_YHCDFS
   SET DRAWER_CON_ECO_ELEM = ''
 WHERE CJRQ = IS_DATE
   AND DRAWER_ENT_SCALE='CS05' AND DRAWER_CON_ECO_ELEM IS NOT NULL;
COMMIT;*/

--[2025-09-18] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_四阶段][李楠] 剔除取上期/配置表
/*--出票人名称
UPDATE PBOCD_JS_205_YHCDFS
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