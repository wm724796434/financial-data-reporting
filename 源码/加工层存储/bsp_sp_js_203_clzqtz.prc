CREATE OR REPLACE PROCEDURE BSP_SP_JS_203_CLZQTZ(IS_DATE        IN VARCHAR2,
                                                 OI_RETCODE     OUT INTEGER,
                                                 OI_RETCODE_DEC OUT VARCHAR2) AS
  /******************************
  @author:zy
  @create-date:20240613
  @description:存量债券投资信息
  @modification history:
  *******************************/
  --V_SCHEMA            VARCHAR2(30); --当前存储过程所属的模式名
  VS_PROCEDURE_NAME VARCHAR(30); --当前储存过程名称
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_STEP           VARCHAR2(100); --存储过程执行步骤标志
  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  NUM               INTEGER;
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_NMONTH         VARCHAR2(10);
BEGIN
  VS_TEXT   := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  VS_NMONTH := TO_CHAR(TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD') + 1), 'YYYYMMDD');

  VS_STEP := '参数初始化处理';

  VS_PROCEDURE_NAME := UPPER('BSP_SP_JS_203_CLZQTZ');
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;

  --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'PBOCD_JS_203_CLZQTZ'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_203_CLZQTZ ADD PARTITION P' ||
                      IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;
  ----清理分区当前期数据
  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_203_CLZQTZ TRUNCATE PARTITION P' ||
                    IS_DATE;

  VS_STEP := '1.插入存量债券投资信息';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  --=====================================
  -- 存单和债券的区别：  
  -- 1、发行主体不同：同业存单的发行主体是存款类金融机构，债券的发行主体是政府、金融机构、企业或公司等。
  -- 2、发行对象不同：同业存单的发行对象是全国银行间同业拆借市场成员、基金管理公司及基金类产品，债券的发行对象是个人。
  -- 3、两者的性质不同：同业存单是同业存款的替代品，属于一种定期存款凭证。债券是一种金融契约，属于有价证券。
  --=====================================
  --=====================================
  --   债券余额，从该笔债券角度来看，需要剩余本金求和，原因：按照账户划分不同，政府发行1笔国债，金额100万，
  --  其中10万可供交易1（随意交易），20万可供出售2（用于转手转卖），70万可供持有至到期3（到期兑换），
  --  如果从账户的角度来看数据，则不能进行汇总
  --=====================================

  INSERT /*+APPEND*/
  INTO PBOCD_JS_203_CLZQTZ
    (DATA_DATE, --数据日期 
     ORG_CODE, --金融机构代码 
     ORG_NUM, --内部机构号 
     BOND_CD, --债券代码 
     TRUSTEE_ORG, --债券总托管机构 
     PRODUCT_TYPE, --债券品种 
     CREDIT_RATING, --债券信用级别 
     CURR_CODE, --币种 
     BOND_BALANCE, --债券余额 
     BOND_BALANCE_RMB, --债券余额折人民币 
     REGIST_DT, --债权债务登记日 
     INT_ST_DT, --起息日 
     MATURITY_DT, --兑付日期 
     INT_RATE, --票面利率 
     ISSU_ID_NO, --发行人证件代码 
     ISSU_REG_REGION_CODE, ---发行人地区代码
     ISSU_INDUSTRY_TYPE, --发行人行业 
     ISSU_ENT_SCALE, --债券发行人企业规模 
     ISSU_CTRL_ECO_ELEM, ---发行人经济成分 
     REPORT_ID,
     CJRQ,
     NBJGH,
     BIZ_LINE_ID, ---条线
     VERIFY_STATUS,
     BSCJRQ,
     ISSU_DEPT_TYPE, --发行人国民经济部门 
     FRNBJGH --法人内部机构号 
     )
    SELECT /*+parallel(4)*/
     VS_TEXT AS DATA_DATE,
     '9122010170255776XN' AS ORG_CODE, --金融机构代码
     A.ORG_NUM,
     REPLACE(REPLACE(REPLACE(B.STOCK_CD, 'SS', ''), 'SZ', ''),'X0003120B2700001','041800014') AS BOND_CD, --债券代码   
     B.HOST_ORG_TYPE AS TRUSTEE_ORG, --债券总托管机构  
     B.STOCK_PRO_EXP_TYPE AS PRODUCT_TYPE, --债券品种
     CASE
       WHEN REPLACE(REPLACE(B.STOCK_CD, 'SS', ''), 'SZ', '') IN
            ('011754134', '031672037') THEN
        'C21' --- 金融市场部，王关越反馈，这两笔特殊，要写死
       WHEN B.BOND_CREDIT_RATE = 'AAA' THEN
        'C01'
       WHEN B.BOND_CREDIT_RATE = 'AA+' THEN
        'C02'
       WHEN B.BOND_CREDIT_RATE = 'AA' THEN
        'C03'
       WHEN B.BOND_CREDIT_RATE = 'AA-' THEN
        'C04'
       WHEN B.BOND_CREDIT_RATE = 'A+' THEN
        'C05'
       WHEN B.BOND_CREDIT_RATE = 'A' THEN
        'C06'
       WHEN B.BOND_CREDIT_RATE = 'A-' THEN
        'C07'
       WHEN B.BOND_CREDIT_RATE = 'BBB+' THEN
        'C08'
       WHEN B.BOND_CREDIT_RATE = 'BBB' THEN
        'C09'
       WHEN B.BOND_CREDIT_RATE = 'BBB-' THEN
        'C10'
       WHEN B.BOND_CREDIT_RATE = 'BB+' THEN
        'C11'
       WHEN B.BOND_CREDIT_RATE = 'BB' THEN
        'C12'
       WHEN B.BOND_CREDIT_RATE = 'BB-' THEN
        'C13'
       WHEN B.BOND_CREDIT_RATE = 'B+' THEN
        'C14'
       WHEN B.BOND_CREDIT_RATE = 'B' THEN
        'C15'
       WHEN B.BOND_CREDIT_RATE = 'B-' THEN
        'C16'
       WHEN B.BOND_CREDIT_RATE = 'CCC+' THEN
        'C17'
       WHEN B.BOND_CREDIT_RATE = 'CCC' THEN
        'C18'
       WHEN B.BOND_CREDIT_RATE = 'CCC-' THEN
        'C19'
       WHEN B.BOND_CREDIT_RATE = 'CC' THEN
        'C20'
       WHEN B.BOND_CREDIT_RATE = 'C' THEN
        'C21'
       WHEN B.BOND_CREDIT_RATE = 'D' THEN
        'C22'
       WHEN B.BOND_CREDIT_RATE = 'A-1' THEN
        'C23'
       WHEN B.BOND_CREDIT_RATE = 'A-2' THEN
        'C24'
       WHEN B.BOND_CREDIT_RATE = 'A-3' THEN
        'C25'
       WHEN B.BOND_CREDIT_RATE IS NULL THEN
        'C00' --无评级
       ELSE
        B.BOND_CREDIT_RATE
     END AS CREDIT_RATING, --债券信用级别  有问题    
     A.CURR_CD AS CURR_CODE, --币种 
     SUM(A.PRINCIPAL_BALANCE) AS BOND_BALANCE, --债券余额 
     SUM(A.PRINCIPAL_BALANCE * T3.CCY_RATE) AS BOND_BALANCE_RMB, --债券余额折人民币
     TO_CHAR(REGIST_DT, 'YYYY-MM-DD') AS REGIST_DT, --债权债务登记日 有问题  得康星平台升级后才能下发 
     TO_CHAR(B.INT_ST_DT, 'YYYY-MM-DD') AS INT_ST_DT, --起息日
     TO_CHAR(MATURITY_DATE, 'YYYY-MM-DD') AS MATURITY_DT, --兑付日期  
     B.INT_RAT AS INT_RATE, --票面利率 
     NVL(NVL(C2.USCD,C.USCD), D.ID_NO) AS ISSU_ID_NO, --发行人证件代码  
     CASE
       WHEN C.ORG_FULLNAME LIKE '%财政部' OR C.ORG_FULLNAME LIKE '%人民银行%' THEN
        '000000'
       WHEN B.STOCK_PRO_EXP_TYPE IN ('GB01', 'GB02', 'GB03', 'CBN') THEN
        '000000'
       WHEN B.STOCK_PRO_EXP_TYPE IN ('FB00') THEN
        '110000'
       ELSE
        NVL(NVL(C.AFLT_DIST, C.AFLT_PROV),NVL(C.AFLT_DIST, C.AFLT_PROV))
     END AS ISSU_REG_REGION_CODE, ---发行人地区代码
     CASE
       WHEN C.ORG_FULLNAME LIKE '%财政部' OR C.ORG_FULLNAME LIKE '%省政府' OR
            C.ORG_FULLNAME LIKE '%省财政厅' OR C.ORG_FULLNAME LIKE '%自治区政府' OR
            C.ORG_FULLNAME LIKE '%自治区财政厅' OR C.ORG_FULLNAME LIKE '%市人民政府' OR
            C.ORG_FULLNAME LIKE '%市财政局' OR C.ORG_FULLNAME LIKE '%市政府' OR
            C.ORG_FULLNAME LIKE '%省人民政府' OR C.ORG_FULLNAME LIKE '%自治区人民政府' THEN
        'S'
       WHEN B.STOCK_PRO_EXP_TYPE = 'A' THEN
        'S' ---当是政府债的时候，给S 
       WHEN C.INDS_INVEST = '7401' THEN
        'A'
       WHEN C.INDS_INVEST = '7402' THEN
        'B'
       WHEN C.INDS_INVEST = '7403' THEN
        'C'
       WHEN C.INDS_INVEST = '7404' THEN
        'D'
       WHEN C.INDS_INVEST = '7405' THEN
        'E'
       WHEN C.INDS_INVEST = '7406' THEN
        'F'
       WHEN C.INDS_INVEST = '7407' THEN
        'G'
       WHEN C.INDS_INVEST = '7408' THEN
        'H'
       WHEN C.INDS_INVEST = '7409' THEN
        'I'
       WHEN C.INDS_INVEST = '7410' THEN
        'J'
       WHEN C.INDS_INVEST = '7411' THEN
        'K'
       WHEN C.INDS_INVEST = '7412' THEN
        'L'
       WHEN C.INDS_INVEST = '7413' THEN
        'M'
       WHEN C.INDS_INVEST = '7414' THEN
        'N'
       WHEN C.INDS_INVEST = '7415' THEN
        'O'
       WHEN C.INDS_INVEST = '7416' THEN
        'P'
       WHEN C.INDS_INVEST = '7417' THEN
        'Q'
       WHEN C.INDS_INVEST = '7418' THEN
        'R'
       WHEN C.INDS_INVEST = '7419' THEN
        'S'
       WHEN C.INDS_INVEST = '7420' THEN
        'T'
       ELSE
        '2'
     END AS ISSU_INDUSTRY_TYPE, --发行人行业 
     CASE
       WHEN C.ORG_FULLNAME LIKE '%财政部' OR C.ORG_FULLNAME LIKE '%省政府' OR
            C.ORG_FULLNAME LIKE '%省财政厅' OR C.ORG_FULLNAME LIKE '%自治区政府' OR
            C.ORG_FULLNAME LIKE '%自治区财政厅' OR C.ORG_FULLNAME LIKE '%市人民政府' OR
            C.ORG_FULLNAME LIKE '%市财政局' OR C.ORG_FULLNAME LIKE '%市政府' OR
            C.ORG_FULLNAME LIKE '%省人民政府' OR C.ORG_FULLNAME LIKE '%自治区人民政府' THEN
        'CS05'
       WHEN C.CORP_SIZE = '01' THEN
        'CS01'
       WHEN C.CORP_SIZE = '02' THEN
        'CS02'
       WHEN C.CORP_SIZE = '03' THEN
        'CS03'
       WHEN C.CORP_SIZE = '04' THEN
        'CS04'
       ELSE
        'CS05' ---非企业债，没有企业规模
     END AS ISSU_ENT_SCALE, --债券发行人企业规模 
     CASE
       WHEN C.ORG_FULLNAME LIKE '%财政部' OR C.ORG_FULLNAME LIKE '%省政府' OR
            C.ORG_FULLNAME LIKE '%省财政厅' OR C.ORG_FULLNAME LIKE '%自治区政府' OR
            C.ORG_FULLNAME LIKE '%自治区财政厅' OR C.ORG_FULLNAME LIKE '%市人民政府' OR
            C.ORG_FULLNAME LIKE '%市财政局' OR C.ORG_FULLNAME LIKE '%市政府' OR
            C.ORG_FULLNAME LIKE '%省人民政府' OR C.ORG_FULLNAME LIKE '%自治区人民政府' THEN
        'A01'
       WHEN REPLACE(REPLACE(B.STOCK_CD, 'SS', ''), 'SZ', '') in
            ('1523004', '232380020') then
        'B01'
       when REPLACE(REPLACE(B.STOCK_CD, 'SS', ''), 'SZ', '') in
            ('232380032') then
        'B03'
       WHEN C.CORP_PROPTY IN ('0805010100', '0805010200','0805050000') THEN
        'A01'
       WHEN C.CORP_PROPTY IN ('0805040000') THEN
        'A02'
       WHEN C.CORP_PROPTY IN ('0805020000') THEN
        'B01'
       WHEN C.CORP_PROPTY IN ('0805030200') THEN
        'B03'
     END AS ISSU_CTRL_ECO_ELEM, ---发行人经济成分  金融市场，王关越反馈，这3笔债券需求写死的
     SYS_GUID() AS REPORT_ID,
     IS_DATE AS CJRQ,
     A.ORG_NUM AS NBJGH,
     'SC' AS BIZ_LINE_ID, ---条线
     '' AS VERIFY_STATUS,
     '' AS BSCJRQ,
     CASE
       WHEN C.ORG_FULLNAME LIKE '%财政部' THEN
        'A01'
       WHEN C.ORG_FULLNAME LIKE '%省政府' OR C.ORG_FULLNAME LIKE '%省财政厅' OR
            C.ORG_FULLNAME LIKE '%自治区政府' OR C.ORG_FULLNAME LIKE '%自治区财政厅' OR
            C.ORG_FULLNAME LIKE '%市人民政府' OR C.ORG_FULLNAME LIKE '%市财政局' OR
            C.ORG_FULLNAME LIKE '%市政府' OR C.ORG_FULLNAME LIKE '%省人民政府' OR
            C.ORG_FULLNAME LIKE '%自治区人民政府' THEN
        'A02'
       WHEN B.STOCK_PRO_EXP_TYPE IN ('FB00') THEN
        'B04'
       WHEN B.STOCK_PRO_EXP_TYPE = 'GB03' THEN
        'A01'
       WHEN B.STOCK_PRO_EXP_TYPE IN ('GB041', 'GB042') THEN
        'A02'
       WHEN C.ORG_TYPE_MCLS = 'A' THEN
        'B01'
       WHEN C.ORG_TYPE_MCLS = 'B' THEN
        'B02'
       WHEN C.ORG_TYPE_MCLS = 'C' THEN
        'B03'
       WHEN C.ORG_TYPE_MCLS = 'D' THEN
        'B04'
       WHEN C.ORG_TYPE_MCLS = 'E' THEN
        'B05'
       WHEN C.ORG_TYPE_MCLS = 'F' THEN
        'B06'
       WHEN C.ORG_TYPE_MCLS = 'G' THEN
        'B07'
       WHEN C.ORG_TYPE_MCLS = 'H' THEN
        'B08'
       WHEN C.ORG_TYPE_MCLS = 'I' THEN
        'B09'
       WHEN C.ORG_TYPE_MCLS = 'Z' THEN
        'B99'
       ELSE
        'C01'
     END AS ISSU_DEPT_TYPE, --发行人国民经济部门 
     '990000' FRNBJGH --法人内部机构号 
      FROM SMTMODS.L_ACCT_FUND_INVEST A ---投资业务信息表 
      LEFT JOIN SMTMODS.L_AGRE_BOND_INFO B --- 债券信息表 
        ON REPLACE(A.ACCT_NUM, '0041800014', '041800014') = B.STOCK_CD --康星做的业务错误，X0003120B2700001，应为041800014   
       AND A.DATA_DATE = B.DATA_DATE
       AND B.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_CUST_EXTERNAL_INFO C ----客户外部信息表
        ON A.CUST_ID = C.CUST_ID
       AND A.DATA_DATE = C.DATA_DATE
       AND C.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_CUST_EXTERNAL_INFO C2 ----客户外部信息表
        ON (CASE
              WHEN C.ORG_FULLNAME LIKE '%省政府'  THEN
               REPLACE(C.ORG_FULLNAME, '省政府', '省财政厅')
              WHEN C.ORG_FULLNAME LIKE '%自治区政府' THEN
               REPLACE(C.ORG_FULLNAME, '自治区政府', '自治区财政厅')
              WHEN C.ORG_FULLNAME LIKE '%市人民政府' THEN
               REPLACE(C.ORG_FULLNAME, '市人民政府', '市财政局')
              WHEN C.ORG_FULLNAME LIKE '%市政府' THEN
               REPLACE(C.ORG_FULLNAME, '市政府', '市财政局')
              WHEN C.ORG_FULLNAME LIKE '%省人民政府' THEN
               REPLACE(C.ORG_FULLNAME, '省人民政府', '省财政厅')
              WHEN C.ORG_FULLNAME LIKE '%自治区人民政府' THEN
               REPLACE(C.ORG_FULLNAME, '自治区人民政府', '自治区财政厅')
           END) = C2.ORG_FULLNAME
       AND A.DATA_DATE = C2.DATA_DATE
       AND C2.DATA_DATE = IS_DATE
      
      LEFT JOIN SMTMODS.L_CUST_ALL D
        ON A.CUST_ID = D.CUST_ID
       AND A.DATA_DATE = D.DATA_DATE
       AND D.DATA_DATE = IS_DATE
      /*LEFT JOIN L_PUBL_ORG_BRA_TMP OB --金数机构表
        ON OB.ORG_NUM = A.ORG_NUM
       AND OB.DATA_DATE = IS_DATE*/
      LEFT JOIN SMTMODS.L_PUBL_RATE T3 --汇率表 
        ON T3.BASIC_CCY = A.CURR_CD
       AND T3.FORWARD_CCY = 'CNY'
       AND T3.DATA_DATE = IS_DATE
     WHERE A.DATA_DATE = IS_DATE
       and A.GL_ITEM_CODE in ('15030103',
                              '11010101',
                              '15010103',
                              '15030101',
                              '11010103',
                              '11010102',
                              '15030102',
                              '15010101',
                              '15010102')
       and a.DATE_SOURCESD = '债券投资'
       AND A.PRINCIPAL_BALANCE > 0
     GROUP BY /*NVL(OB.ID_NO, OB.UP_ID_NO), --金融机构代码*/
              A.ORG_NUM,
              REPLACE(REPLACE(REPLACE(B.STOCK_CD, 'SS', ''), 'SZ', ''),'X0003120B2700001','041800014'), --债券代码   
              B.HOST_ORG_TYPE, --债券总托管机构  
              B.STOCK_PRO_EXP_TYPE, --债券品种  有问题  得康星平台升级后才能下发 
              CASE
                WHEN REPLACE(REPLACE(B.STOCK_CD, 'SS', ''), 'SZ', '') IN
                     ('011754134', '031672037') THEN
                 'C21' --- 金融市场部，王关越反馈，这两笔特殊，要写死
                WHEN B.BOND_CREDIT_RATE = 'AAA' THEN
                 'C01'
                WHEN B.BOND_CREDIT_RATE = 'AA+' THEN
                 'C02'
                WHEN B.BOND_CREDIT_RATE = 'AA' THEN
                 'C03'
                WHEN B.BOND_CREDIT_RATE = 'AA-' THEN
                 'C04'
                WHEN B.BOND_CREDIT_RATE = 'A+' THEN
                 'C05'
                WHEN B.BOND_CREDIT_RATE = 'A' THEN
                 'C06'
                WHEN B.BOND_CREDIT_RATE = 'A-' THEN
                 'C07'
                WHEN B.BOND_CREDIT_RATE = 'BBB+' THEN
                 'C08'
                WHEN B.BOND_CREDIT_RATE = 'BBB' THEN
                 'C09'
                WHEN B.BOND_CREDIT_RATE = 'BBB-' THEN
                 'C10'
                WHEN B.BOND_CREDIT_RATE = 'BB+' THEN
                 'C11'
                WHEN B.BOND_CREDIT_RATE = 'BB' THEN
                 'C12'
                WHEN B.BOND_CREDIT_RATE = 'BB-' THEN
                 'C13'
                WHEN B.BOND_CREDIT_RATE = 'B+' THEN
                 'C14'
                WHEN B.BOND_CREDIT_RATE = 'B' THEN
                 'C15'
                WHEN B.BOND_CREDIT_RATE = 'B-' THEN
                 'C16'
                WHEN B.BOND_CREDIT_RATE = 'CCC+' THEN
                 'C17'
                WHEN B.BOND_CREDIT_RATE = 'CCC' THEN
                 'C18'
                WHEN B.BOND_CREDIT_RATE = 'CCC-' THEN
                 'C19'
                WHEN B.BOND_CREDIT_RATE = 'CC' THEN
                 'C20'
                WHEN B.BOND_CREDIT_RATE = 'C' THEN
                 'C21'
                WHEN B.BOND_CREDIT_RATE = 'D' THEN
                 'C22'
                WHEN B.BOND_CREDIT_RATE = 'A-1' THEN
                 'C23'
                WHEN B.BOND_CREDIT_RATE = 'A-2' THEN
                 'C24'
                WHEN B.BOND_CREDIT_RATE = 'A-3' THEN
                 'C25'
                WHEN B.BOND_CREDIT_RATE IS NULL THEN
                 'C00' --无评级
                ELSE
                 B.BOND_CREDIT_RATE
              END, --债券信用级别  有问题    
              A.CURR_CD, --币种 
              TO_CHAR(REGIST_DT, 'YYYY-MM-DD'), --债权债务登记日 有问题  得康星平台升级后才能下发 
              TO_CHAR(B.INT_ST_DT, 'YYYY-MM-DD'), --起息日
              TO_CHAR(MATURITY_DATE, 'YYYY-MM-DD'), --兑付日期  
              B.INT_RAT, --票面利率 
              NVL(NVL(C2.USCD,C.USCD), D.ID_NO), --发行人证件代码  
              CASE
                WHEN C.ORG_FULLNAME LIKE '%财政部' OR
                     C.ORG_FULLNAME LIKE '%人民银行%' THEN
                 '000000'
                WHEN B.STOCK_PRO_EXP_TYPE IN ('GB01', 'GB02', 'GB03', 'CBN') THEN
                 '000000'
                WHEN B.STOCK_PRO_EXP_TYPE IN ('FB00') THEN
                 '110000'
                ELSE
                 NVL(NVL(C.AFLT_DIST, C.AFLT_PROV),NVL(C.AFLT_DIST, C.AFLT_PROV))
              END, ---发行人地区代码
              CASE
                WHEN C.ORG_FULLNAME LIKE '%财政部' OR
                     C.ORG_FULLNAME LIKE '%省政府' OR
                     C.ORG_FULLNAME LIKE '%省财政厅' OR
                     C.ORG_FULLNAME LIKE '%自治区政府' OR
                     C.ORG_FULLNAME LIKE '%自治区财政厅' OR
                     C.ORG_FULLNAME LIKE '%市人民政府' OR
                     C.ORG_FULLNAME LIKE '%市财政局' OR
                     C.ORG_FULLNAME LIKE '%市政府' OR
                     C.ORG_FULLNAME LIKE '%省人民政府' OR
                     C.ORG_FULLNAME LIKE '%自治区人民政府' THEN
                 'S'
                WHEN B.STOCK_PRO_EXP_TYPE = 'A' THEN
                 'S' ---当是政府债的时候，给S 
                WHEN C.INDS_INVEST = '7401' THEN
                 'A'
                WHEN C.INDS_INVEST = '7402' THEN
                 'B'
                WHEN C.INDS_INVEST = '7403' THEN
                 'C'
                WHEN C.INDS_INVEST = '7404' THEN
                 'D'
                WHEN C.INDS_INVEST = '7405' THEN
                 'E'
                WHEN C.INDS_INVEST = '7406' THEN
                 'F'
                WHEN C.INDS_INVEST = '7407' THEN
                 'G'
                WHEN C.INDS_INVEST = '7408' THEN
                 'H'
                WHEN C.INDS_INVEST = '7409' THEN
                 'I'
                WHEN C.INDS_INVEST = '7410' THEN
                 'J'
                WHEN C.INDS_INVEST = '7411' THEN
                 'K'
                WHEN C.INDS_INVEST = '7412' THEN
                 'L'
                WHEN C.INDS_INVEST = '7413' THEN
                 'M'
                WHEN C.INDS_INVEST = '7414' THEN
                 'N'
                WHEN C.INDS_INVEST = '7415' THEN
                 'O'
                WHEN C.INDS_INVEST = '7416' THEN
                 'P'
                WHEN C.INDS_INVEST = '7417' THEN
                 'Q'
                WHEN C.INDS_INVEST = '7418' THEN
                 'R'
                WHEN C.INDS_INVEST = '7419' THEN
                 'S'
                WHEN C.INDS_INVEST = '7420' THEN
                 'T'
                ELSE
                 '2'
              END, --发行人行业 
              CASE
                WHEN C.ORG_FULLNAME LIKE '%财政部' OR
                     C.ORG_FULLNAME LIKE '%省政府' OR
                     C.ORG_FULLNAME LIKE '%省财政厅' OR
                     C.ORG_FULLNAME LIKE '%自治区政府' OR
                     C.ORG_FULLNAME LIKE '%自治区财政厅' OR
                     C.ORG_FULLNAME LIKE '%市人民政府' OR
                     C.ORG_FULLNAME LIKE '%市财政局' OR
                     C.ORG_FULLNAME LIKE '%市政府' OR
                     C.ORG_FULLNAME LIKE '%省人民政府' OR
                     C.ORG_FULLNAME LIKE '%自治区人民政府' THEN
                 'CS05'
                WHEN C.CORP_SIZE = '01' THEN
                 'CS01'
                WHEN C.CORP_SIZE = '02' THEN
                 'CS02'
                WHEN C.CORP_SIZE = '03' THEN
                 'CS03'
                WHEN C.CORP_SIZE = '04' THEN
                 'CS04'
                ELSE
                 'CS05' ---非企业债，没有企业规模
              END, --债券发行人企业规模 
              CASE
                WHEN C.ORG_FULLNAME LIKE '%财政部' OR
                     C.ORG_FULLNAME LIKE '%省政府' OR
                     C.ORG_FULLNAME LIKE '%省财政厅' OR
                     C.ORG_FULLNAME LIKE '%自治区政府' OR
                     C.ORG_FULLNAME LIKE '%自治区财政厅' OR
                     C.ORG_FULLNAME LIKE '%市人民政府' OR
                     C.ORG_FULLNAME LIKE '%市财政局' OR
                     C.ORG_FULLNAME LIKE '%市政府' OR
                     C.ORG_FULLNAME LIKE '%省人民政府' OR
                     C.ORG_FULLNAME LIKE '%自治区人民政府' THEN
                 'A01'
                WHEN REPLACE(REPLACE(B.STOCK_CD, 'SS', ''), 'SZ', '') in
                     ('1523004', '232380020') then
                 'B01'
                when REPLACE(REPLACE(B.STOCK_CD, 'SS', ''), 'SZ', '') in
                     ('232380032') then
                 'B03'
                WHEN C.CORP_PROPTY IN ('0805010100', '0805010200','0805050000') THEN
                 'A01'
                WHEN C.CORP_PROPTY IN ('0805040000') THEN
                 'A02'
                WHEN C.CORP_PROPTY IN ('0805020000') THEN
                 'B01'
                WHEN C.CORP_PROPTY IN ('0805030200') THEN
                 'B03'
              END, ---发行人经济成分 
              A.ORG_NUM,
              CASE
                WHEN C.ORG_FULLNAME LIKE '%财政部' THEN
                 'A01'
                WHEN C.ORG_FULLNAME LIKE '%省政府' OR
                     C.ORG_FULLNAME LIKE '%省财政厅' OR
                     C.ORG_FULLNAME LIKE '%自治区政府' OR
                     C.ORG_FULLNAME LIKE '%自治区财政厅' OR
                     C.ORG_FULLNAME LIKE '%市人民政府' OR
                     C.ORG_FULLNAME LIKE '%市财政局' OR
                     C.ORG_FULLNAME LIKE '%市政府' OR
                     C.ORG_FULLNAME LIKE '%省人民政府' OR
                     C.ORG_FULLNAME LIKE '%自治区人民政府' THEN
                 'A02'
                WHEN B.STOCK_PRO_EXP_TYPE IN ('FB00') THEN
                 'B04'
                WHEN B.STOCK_PRO_EXP_TYPE = 'GB03' THEN
                 'A01'
                WHEN B.STOCK_PRO_EXP_TYPE IN ('GB041', 'GB042') THEN
                 'A02'
                WHEN C.ORG_TYPE_MCLS = 'A' THEN
                 'B01'
                WHEN C.ORG_TYPE_MCLS = 'B' THEN
                 'B02'
                WHEN C.ORG_TYPE_MCLS = 'C' THEN
                 'B03'
                WHEN C.ORG_TYPE_MCLS = 'D' THEN
                 'B04'
                WHEN C.ORG_TYPE_MCLS = 'E' THEN
                 'B05'
                WHEN C.ORG_TYPE_MCLS = 'F' THEN
                 'B06'
                WHEN C.ORG_TYPE_MCLS = 'G' THEN
                 'B07'
                WHEN C.ORG_TYPE_MCLS = 'H' THEN
                 'B08'
                WHEN C.ORG_TYPE_MCLS = 'I' THEN
                 'B09'
                WHEN C.ORG_TYPE_MCLS = 'Z' THEN
                 'B99'
                ELSE
                 'C01'
              END --发行人国民经济部门 
    ;
  COMMIT;
  ------------------------------------------------------------------------------------------------------------------------------------
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

  OI_RETCODE     := 0; --设置异常状态为0 成功状态
  OI_RETCODE_DEC := '执行成功';
  VS_STEP        := VS_PROCEDURE_NAME || '的业务逻辑全部处理完成';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

EXCEPTION
  WHEN OTHERS THEN
    --VS_STEP := '发生异常。详细信息为，' || TO_CHAR(SQLCODE) || SUBSTR(SQLERRM, 1, 280);
    VS_STEP        := -1;
    OI_RETCODE     := -1; --设置异常状态为-1
    OI_RETCODE_DEC := SQLCODE || ':' || SUBSTR(SQLERRM, 1, 50); --系统错误描述
    VI_ERRORCODE   := SQLCODE; --设置异常代码
    VS_TEXT        := VS_STEP || '|' || IS_DATE || '|' ||
                      SUBSTR(SQLERRM, 1, 200); --设置异常描述
    --记录异常信息
    SP_PBOCD_LOG(VS_PROCEDURE_NAME,
                 'ERROR',
                 VI_ERRORCODE,
                 VS_TEXT,
                 IS_DATE);
    --更新执行计划
  --SP_ETL_PROC_PLAN(I_DATADATE, V_PROCNAME, 0);
END;
