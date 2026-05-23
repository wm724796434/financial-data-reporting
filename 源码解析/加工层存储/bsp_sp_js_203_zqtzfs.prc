CREATE OR REPLACE PROCEDURE BSP_SP_JS_203_ZQTZFS(IS_DATE        IN VARCHAR2,
                                                 OI_RETCODE     OUT INTEGER,
                                                 OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_203_ZQTZFS
  -- 业务域: 债券/投资类
  -- 引用的监管集市表
  --    SMTMODS.L_ACCT_FUND_INVEST                         — 投资业务信息表
  --    SMTMODS.L_AGRE_BOND_INFO                           — 债券信息表
  --    SMTMODS.L_CUST_ALL                                 — 全量客户信息表
  --    SMTMODS.L_CUST_EXTERNAL_INFO                       — 客户外部信息表
  --    SMTMODS.L_PUBL_RATE                                — 汇率表
  --    SMTMODS.L_TRAN_FUND_FX                             — 资金交易信息表
  ------------------------------------------------------------------------------------------------------
  /******************************
  @author:zy
  @create-date:20240603
  @description:债券投资发生额信息
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

  VS_PROCEDURE_NAME := UPPER('BSP_SP_JS_203_ZQTZFS');
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;

  --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'PBOCD_JS_203_ZQTZFS'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_203_ZQTZFS ADD PARTITION P' ||
                      IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_203_ZQTZFS TRUNCATE PARTITION P' ||
                    IS_DATE;

  VS_STEP := '1.插入债券投资发生额信息';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

  --==========================================================
  -- 1笔债券 同一天交易 同1个交易对手，发生2比，按照实际报送2条 比如：2300262
  --==========================================================
  INSERT INTO PBOCD_JS_203_ZQTZFS
    (DATA_DATE, --- 数据日期
     ORG_CODE, --金融机构代码
     ORG_NUM, --内部机构号
     ISSU_ID_NO, --发行人证件代码
     ISSU_CTRL_ECO_ELEM, --发行人经济成分
     ISSU_ENT_SCALE, --债券发行人企业规模
     ISSU_INDUSTRY_TYPE, --发行人行业
     ISSU_REG_REGION_CODE, --发行人地区代码
     SERIAL_NO, --交易流水号
     ISSU_DEPT_TYPE, --发行人国民经济部门
     BOND_CD, --债券代码
     TRUSTEE_ORG, --债券总托管机构
     PRODUCT_TYPE, --债券品种
     CREDIT_RATING, --债券信用级别
     CURR_CODE, --币种
     REGIST_DT, --债权债务登记日
     INT_ST_DT, --起息日
     MATURITY_DT, --兑付日期
     INT_RATE, --票面利率
     TRANS_DATE, --交易日期
     TRANS_AMT, --成交金额
     TRANS_AMT_RMB, --成交金额折人民币
     TRANS_TYPE, --买入/卖出标志
     REPORT_ID,
     CJRQ,
     NBJGH,
     BIZ_LINE_ID, --条线
     VERIFY_STATUS,
     BSCJRQ,
     FRNBJGH ---法人内部机构号
     )
  ---交易日期是当月，结算日期是下月的情况，剔除
    SELECT VS_TEXT, --  数据日期
           '9122010170255776XN' AS ORG_CODE, --金融机构代码
           A.ORG_NUM, --内部机构号
           NVL(NVL(C2.USCD,C.USCD), D.ID_NO) AS ISSU_ID_NO, --发行人证件代码
           CASE
             WHEN C.ORG_FULLNAME LIKE '%财政部' OR C.ORG_FULLNAME LIKE '%省政府' OR
                  C.ORG_FULLNAME LIKE '%省财政厅' OR
                  C.ORG_FULLNAME LIKE '%自治区政府' OR
                  C.ORG_FULLNAME LIKE '%自治区财政厅' OR
                  C.ORG_FULLNAME LIKE '%市人民政府' OR
                  C.ORG_FULLNAME LIKE '%市财政局' OR C.ORG_FULLNAME LIKE '%市政府' OR
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
           END AS ISSU_CTRL_ECO_ELEM, --发行人经济成分
           CASE
             WHEN C.ORG_FULLNAME LIKE '%财政部' OR C.ORG_FULLNAME LIKE '%省政府' OR
                  C.ORG_FULLNAME LIKE '%省财政厅' OR
                  C.ORG_FULLNAME LIKE '%自治区政府' OR
                  C.ORG_FULLNAME LIKE '%自治区财政厅' OR
                  C.ORG_FULLNAME LIKE '%市人民政府' OR
                  C.ORG_FULLNAME LIKE '%市财政局' OR C.ORG_FULLNAME LIKE '%市政府' OR
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
           END AS ISSU_ENT_SCALE, --债券发行人企业规模
           CASE
             WHEN C.ORG_FULLNAME LIKE '%财政部' OR C.ORG_FULLNAME LIKE '%省政府' OR
                  C.ORG_FULLNAME LIKE '%省财政厅' OR
                  C.ORG_FULLNAME LIKE '%自治区政府' OR
                  C.ORG_FULLNAME LIKE '%自治区财政厅' OR
                  C.ORG_FULLNAME LIKE '%市人民政府' OR
                  C.ORG_FULLNAME LIKE '%市财政局' OR C.ORG_FULLNAME LIKE '%市政府' OR
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
           END AS ISSU_INDUSTRY_TYPE, --发行人行业
           CASE
             WHEN C.ORG_FULLNAME LIKE '%财政部' OR C.ORG_FULLNAME LIKE '%人民银行%' THEN
              '000000'
             WHEN B.STOCK_PRO_EXP_TYPE IN ('GB01', 'GB02', 'GB03', 'CBN') THEN
              '000000'
             WHEN B.STOCK_PRO_EXP_TYPE IN ('FB00') THEN
              '110000'
             ELSE
              NVL(NVL(C2.AFLT_DIST, C2.AFLT_PROV),NVL(C.AFLT_DIST, C.AFLT_PROV))
           END AS ISSU_REG_REGION_CODE, --发行人地区代码
           A.REF_NUM AS SERIAL_NO, --交易流水号
           CASE
             WHEN C.ORG_FULLNAME LIKE '%财政部' THEN
              'A01'
             WHEN C.ORG_FULLNAME LIKE '%省政府' OR C.ORG_FULLNAME LIKE '%省财政厅' OR
                  C.ORG_FULLNAME LIKE '%自治区政府' OR
                  C.ORG_FULLNAME LIKE '%自治区财政厅' OR
                  C.ORG_FULLNAME LIKE '%市人民政府' OR
                  C.ORG_FULLNAME LIKE '%市财政局' OR C.ORG_FULLNAME LIKE '%市政府' OR
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
           END AS ISSU_DEPT_TYPE, --发行人国民经济部门
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
           END AS CREDIT_RATING, --债券信用级别
           B.CURR_CD AS CURR_CODE, --币种
           TO_CHAR(B.REGIST_DT, 'YYYY-MM-DD') AS REGIST_DT, --债权债务登记日
           TO_CHAR(B.INT_ST_DT, 'YYYY-MM-DD') AS INT_ST_DT, --起息日
           TO_CHAR(B.MATURITY_DT, 'YYYY-MM-DD') AS MATURITY_DT, --兑付日期
           B.REAL_INT_RAT AS INT_RATE, --票面利率（实际利率）
           TO_CHAR(A.TRAN_DT, 'YYYY-MM-DD') AS TRANS_DATE, --交易日期
           A.AMOUNT AS TRANS_AMT, --成交金额
           A.AMOUNT * T3.CCY_RATE AS TRANS_AMT_RMB, --成交金额折人民币
           A.TRADE_DIRECT AS TRANS_TYPE, --买入/卖出标志
           SYS_GUID() AS REPORT_ID,
           IS_DATE AS CJRQ,
           A.ORG_NUM AS NBJGH,
           'SC' AS BIZ_LINE_ID, --条线
           '' AS VERIFY_STATUS,
           '' AS BSCJRQ,
           '990000' AS FRNBJGH ---法人内部机构号
      FROM SMTMODS.L_TRAN_FUND_FX A ----资金交易信息表，流水表
      LEFT JOIN SMTMODS.L_ACCT_FUND_INVEST M
        ON SUBSTR(A.CONTRACT_NUM, 0, LENGTH(A.CONTRACT_NUM) - 1) =
           REPLACE(M.ACCT_NUM, '0041800014', '041800014')
       AND M.DATA_DATE = IS_DATE
       and M.GL_ITEM_CODE in ('15030103',
                              '11010101',
                              '15010103',
                              '15030101',
                              '11010103',
                              '11010102',
                              '15030102',
                              '15010101',
                              '15010102')
       and M.DATE_SOURCESD = '债券投资'
       AND A.ACCT_NO = M.ACCT_NO
     INNER JOIN SMTMODS.L_AGRE_BOND_INFO B --- 债券信息表，维度表
        ON SUBSTR(A.CONTRACT_NUM, 0, LENGTH(A.CONTRACT_NUM) - 1) =
           B.STOCK_CD --- 交易表的合同号拼上账户类型（1,2,3）等了
       AND B.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_CUST_EXTERNAL_INFO C ----客户外部信息表
        ON M.CUST_ID = C.CUST_ID
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
       AND C2.DATA_DATE = IS_DATE
       
      LEFT JOIN SMTMODS.L_CUST_ALL D
        ON M.CUST_ID = D.CUST_ID
       AND D.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_PUBL_RATE T3
        ON T3.BASIC_CCY = A.CURR_CD
       AND T3.FORWARD_CCY = 'CNY'
       AND T3.DATA_DATE = IS_DATE
     WHERE TO_CHAR(A.TRAN_DT, 'YYYYMM') = SUBSTR(IS_DATE, 1, 6) --- 交易日期存的就是 实际交割的日期
       AND A.PRODUCT_NAME = '债券投资交易'
       AND A.ITEM_CD not in ('21010101') ---去掉交易性金融负债成本的 
       AND A.PORTFOLIO_ID NOT IN ('1037'); --王关越反馈去掉组别是债券借贷-交易类的，但这样和EAST口径不一致，但业务坚持不要这部分数据
  COMMIT;
  --------------------------------------------取  债券/存单还本交易   数据 ------------------------- 
  INSERT INTO PBOCD_JS_203_ZQTZFS
    (DATA_DATE, --- 数据日期
     ORG_CODE, --金融机构代码
     ORG_NUM, --内部机构号
     ISSU_ID_NO, --发行人证件代码
     ISSU_CTRL_ECO_ELEM, --发行人经济成分
     ISSU_ENT_SCALE, --债券发行人企业规模
     ISSU_INDUSTRY_TYPE, --发行人行业
     ISSU_REG_REGION_CODE, --发行人地区代码
     SERIAL_NO, --交易流水号
     ISSU_DEPT_TYPE, --发行人国民经济部门
     BOND_CD, --债券代码
     TRUSTEE_ORG, --债券总托管机构
     PRODUCT_TYPE, --债券品种
     CREDIT_RATING, --债券信用级别
     CURR_CODE, --币种
     REGIST_DT, --债权债务登记日
     INT_ST_DT, --起息日
     MATURITY_DT, --兑付日期
     INT_RATE, --票面利率
     TRANS_DATE, --交易日期
     TRANS_AMT, --成交金额
     TRANS_AMT_RMB, --成交金额折人民币
     TRANS_TYPE, --买入/卖出标志
     REPORT_ID,
     CJRQ,
     NBJGH,
     BIZ_LINE_ID, --条线
     VERIFY_STATUS,
     BSCJRQ,
     FRNBJGH ---法人内部机构号
     )
    SELECT VS_TEXT, --  数据日期
           '9122010170255776XN' AS ORG_CODE, --金融机构代码
           A.ORG_NUM, --内部机构号
           NVL(NVL(C2.USCD,C.USCD), D.ID_NO) AS ISSU_ID_NO, --发行人证件代码
           CASE
             WHEN C.ORG_FULLNAME LIKE '%财政部' OR C.ORG_FULLNAME LIKE '%省政府' OR
                  C.ORG_FULLNAME LIKE '%省财政厅' OR
                  C.ORG_FULLNAME LIKE '%自治区政府' OR
                  C.ORG_FULLNAME LIKE '%自治区财政厅' OR
                  C.ORG_FULLNAME LIKE '%市人民政府' OR
                  C.ORG_FULLNAME LIKE '%市财政局' OR C.ORG_FULLNAME LIKE '%市政府' OR
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
           END AS ISSU_CTRL_ECO_ELEM, --发行人经济成分
           CASE
             WHEN C.ORG_FULLNAME LIKE '%财政部' OR C.ORG_FULLNAME LIKE '%省政府' OR
                  C.ORG_FULLNAME LIKE '%省财政厅' OR
                  C.ORG_FULLNAME LIKE '%自治区政府' OR
                  C.ORG_FULLNAME LIKE '%自治区财政厅' OR
                  C.ORG_FULLNAME LIKE '%市人民政府' OR
                  C.ORG_FULLNAME LIKE '%市财政局' OR C.ORG_FULLNAME LIKE '%市政府' OR
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
           END AS ISSU_ENT_SCALE, --债券发行人企业规模
           CASE
             WHEN C.ORG_FULLNAME LIKE '%财政部' OR C.ORG_FULLNAME LIKE '%省政府' OR
                  C.ORG_FULLNAME LIKE '%省财政厅' OR
                  C.ORG_FULLNAME LIKE '%自治区政府' OR
                  C.ORG_FULLNAME LIKE '%自治区财政厅' OR
                  C.ORG_FULLNAME LIKE '%市人民政府' OR
                  C.ORG_FULLNAME LIKE '%市财政局' OR C.ORG_FULLNAME LIKE '%市政府' OR
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
           END AS ISSU_INDUSTRY_TYPE, --发行人行业
           CASE
             WHEN C.ORG_FULLNAME LIKE '%财政部' OR C.ORG_FULLNAME LIKE '%人民银行%' THEN
              '000000'
             WHEN B.STOCK_PRO_EXP_TYPE IN ('GB01', 'GB02', 'GB03', 'CBN') THEN
              '000000'
             WHEN B.STOCK_PRO_EXP_TYPE IN ('FB00') THEN
              '110000'
             ELSE
              NVL(NVL(C.AFLT_DIST, C.AFLT_PROV),NVL(C.AFLT_DIST, C.AFLT_PROV))
           END AS ISSU_REG_REGION_CODE, --发行人地区代码
           A.REF_NUM || A.TRADE_DIRECT AS SERIAL_NO, --交易流水号
           CASE
             WHEN C.ORG_FULLNAME LIKE '%财政部' THEN
              'A01'
             WHEN C.ORG_FULLNAME LIKE '%省政府' OR C.ORG_FULLNAME LIKE '%省财政厅' OR
                  C.ORG_FULLNAME LIKE '%自治区政府' OR
                  C.ORG_FULLNAME LIKE '%自治区财政厅' OR
                  C.ORG_FULLNAME LIKE '%市人民政府' OR
                  C.ORG_FULLNAME LIKE '%市财政局' OR C.ORG_FULLNAME LIKE '%市政府' OR
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
           END AS ISSU_DEPT_TYPE, --发行人国民经济部门
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
           END AS CREDIT_RATING, --债券信用级别
           B.CURR_CD AS CURR_CODE, --币种
           TO_CHAR(B.REGIST_DT, 'YYYY-MM-DD') AS REGIST_DT, --债权债务登记日
           TO_CHAR(B.INT_ST_DT, 'YYYY-MM-DD') AS INT_ST_DT, --起息日
           TO_CHAR(B.MATURITY_DT, 'YYYY-MM-DD') AS MATURITY_DT, --兑付日期
           B.REAL_INT_RAT AS INT_RATE, --票面利率（实际利率）
           TO_CHAR(A.TRAN_DT, 'YYYY-MM-DD') AS TRANS_DATE, --交易日期
           A.AMOUNT AS TRANS_AMT, --成交金额
           A.AMOUNT * T3.CCY_RATE AS TRANS_AMT_RMB, --成交金额折人民币
           A.TRADE_DIRECT AS TRANS_TYPE, --买入/卖出标志
           SYS_GUID() AS REPORT_ID,
           IS_DATE AS CJRQ,
           A.ORG_NUM AS NBJGH,
           'SC' AS BIZ_LINE_ID, --条线
           '' AS VERIFY_STATUS,
           '' AS BSCJRQ,
           '990000' AS FRNBJGH ---法人内部机构号
    
      FROM SMTMODS.L_TRAN_FUND_FX A
      LEFT JOIN SMTMODS.L_ACCT_FUND_INVEST M
        ON M.ACCT_NUM || '_' || M.ACCT_NO = A.CONTRACT_NUM
       AND M.DATA_DATE = IS_DATE
       and M.GL_ITEM_CODE in ('15030103',
                              '11010101',
                              '15010103',
                              '15030101',
                              '11010103',
                              '11010102',
                              '15030102',
                              '15010101',
                              '15010102')
       and M.DATE_SOURCESD = '债券投资'
       AND A.ACCT_NO = M.ACCT_NO
     INNER JOIN SMTMODS.L_AGRE_BOND_INFO B --- 债券信息表，维度表
        ON M.ACCT_NUM = B.STOCK_CD --- 
       AND B.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_CUST_EXTERNAL_INFO C ----客户外部信息表
        ON M.CUST_ID = C.CUST_ID
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
       AND C2.DATA_DATE = IS_DATE
       
      LEFT JOIN SMTMODS.L_CUST_ALL D
        ON M.CUST_ID = D.CUST_ID
       AND D.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_PUBL_RATE T3
        ON T3.BASIC_CCY = A.CURR_CD
       AND T3.FORWARD_CCY = 'CNY'
       AND T3.DATA_DATE = IS_DATE
     WHERE TO_CHAR(A.TRAN_DT, 'YYYYMM') = SUBSTR(IS_DATE, 1, 6)
       AND A.PRODUCT_NAME IN ('债券/存单还本交易')
       AND A.ITEM_CD not in ('21010101');
  COMMIT;

  ---------------------------------------------------------------------------------------------------------
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
END;
