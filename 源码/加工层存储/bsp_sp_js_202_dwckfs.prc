CREATE OR REPLACE PROCEDURE BSP_SP_JS_202_DWCKFS (IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  --    SP_JS_202_DWCKFS
  -- 用途:生成接口表 JS_202_DWCKFS 非同业单位存款发生额
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    CAEATE BY USER AT 20220315
  --    MODIFY BY DW AT 20221031 增加D15委托资金（净）
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段 上线日期：2025-04-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  --    需求编号：无需求 上线日期：2025-05-13，修改人：周立鹏，提出人：李楠   修改原因：恢复到原逻辑
  --    需求编号：JLBA202504180011 上线日期：2025-05-27，修改人：白杨，提出人：李楠   修改原因：增加科目
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_三阶段 上线日期：2025-07-29，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  --    需求编号：无需求 修改日期：2025-08-07，修改人：白杨，提出人：李楠   修改内容： 21交易渠道 ： 在原先ELSE空值里增加判断取数逻辑
  --    需求编号：无需求 修改日期：2025-10-13，修改人：白杨，提出人：李楠   修改内容： D1095国库定期存款 不报,校验报错，所以从程序中注释掉
  --    需求编号：JLBA202507210012_关于调整财政性存款及一般性存款相关科目统计方式的相关需求 上线日期：2025-08-30，修改人：白杨，提出人：李楠   修改原因：2005列入财政存款统计。2008、2009、2010、2011、224101列入一般存款统计。224101属于活期存款
  --    需求编号：JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段 上线日期：2025-12-30，修改人：周立鹏，提出人：李楠   修改原因：剔除特殊处理
  --    需求编号：JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段 上线日期：2026-01-27，修改人：周立鹏，提出人：李楠   修改原因：剔除特殊处理
  --    需求编号：JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求 上线日期：2026-01-30，修改人：周立鹏，提出人：李楠   修改原因：制度升级
  --    需求编号：无需求 上线日期：2026-02-10，修改人：周立鹏，提出人：李楠   修改原因：调整渠道、交易对手类型取数逻辑
  ------------------------------------------------------------------------------------------------------


  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(500); --存储过程执行步骤标志
  VS_ORDERDATE      VARCHAR2(8);--20170526 manan 循环日期
  NUM               INTEGER;
  VS_NMONTH         VARCHAR2(8);



BEGIN
  VS_TEXT      := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  VS_ORDERDATE :=SUBSTR(IS_DATE,1,6)||'01';
  VS_NMONTH    := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD') + 1,'YYYYMMDD');
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');

  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_202_DWCKFS';

  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------
/* --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'PBOCD_JS_202_DWCKFS_TMP'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_DATACORE.PBOCD_JS_202_DWCKFS_TMP ADD PARTITION P' ||
                      IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_DATACORE.PBOCD_JS_202_DWCKFS_TMP TRUNCATE PARTITION P' ||
                    IS_DATE;*/
                    
    --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'PBOCD_JS_202_DWCKFS'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_DATACORE.PBOCD_JS_202_DWCKFS ADD PARTITION P' ||
                      IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_DATACORE.PBOCD_JS_202_DWCKFS TRUNCATE PARTITION P' ||
                    IS_DATE;
                    

  VS_STEP := '0.开始插入流水临时表';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
--流水表耗时，建临时表
  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_202_DWCKFS_TMP01';
  INSERT /*+append*/ INTO JS_202_DWCKFS_TMP01
       SELECT /*+parallel(4)*/
              T.ORG_NUM,
              T.REFERENCE_NUM,
              T.ACCOUNT_CODE,
              CUST_ID,
              CURRENCY,
              DATA_DATE,
              COUNTPTY_ID_TYPE,
              COUNTPTY_ID_TYPE2,
              GL_ITEM_CODE,
              TRAN_CODE_DESCRIBE,
              TRANS_FLG,
              CHANNEL,
              CD_TYPE,
              TX_DT,
              TRANS_AMT,
              COUNTPTY_IDENTI,
              OPPO_ORG_NUM,
              OPPO_ACCT_NUM,
              OPPO_ACCT_NAM,
              TRANS_CHANNEL,
              SERIAL_NO  --[2025-08-07] [白杨] [无需求_应李楠要求，进行修改] 在原先ELSE空值里增加判断取数逻辑
       FROM SMTMODS.L_TRAN_TX T
       WHERE (T.GL_ITEM_CODE IN ('20110202',
                                 '20110203',
                                 '20110204',
  --无需求 修改日期：2025-10-13，修改人：白杨，提出人：李楠   修改内容： D1095国库定期存款 不报，从程序中注释掉，去掉 '201107'  '20110701'  '2010%'
                                 --'201107',  
                                 --'20110701',
                                 '20110207',
                                 '20110205',
                                 '20110209',
                                 '20110210',
                                 '20110201',
                                 '20110208',
                                 '20110211') OR T.GL_ITEM_CODE IS NULL
--[2025-08-30] [白杨] [JLBA202507210012_关于调整财政性存款及一般性存款相关科目统计方式的相关需求] [李楠]财政存款转一般存款 新增 '201103','201104','201105','201106','2008','2009','2010'
                              OR SUBSTR(T.GL_ITEM_CODE,1,6) IN('201103','201104','201105','201106')
         OR SUBSTR(T.GL_ITEM_CODE,1,4) IN('2008','2009'/*,'2010'*/))
         AND T.DATA_DATE BETWEEN VS_ORDERDATE AND IS_DATE
         AND T.TRANS_AMT <> 0
         AND (T.TRAN_CODE_DESCRIBE NOT IN ('转久悬', '久悬激活') OR (T.TRAN_CODE_DESCRIBE='久悬激活' AND TRANTYPE2_DESC='营业外激活'))
         AND T.ACCOUNT_CODE IS NOT NULL;
  COMMIT;
  VS_STEP := '1.开始插入单位存款发生额';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

  INSERT /*+append*/ INTO PBOCD_DATACORE.PBOCD_JS_202_DWCKFS
    (DATA_DATE, --1数据日期
     ORG_CODE, --2金融机构代码
     ORG_NUM, --3内部机构号
     CUST_ID_TYPE, --4客户证件类型
     CUST_ID_NO, --5客户证件代码
     REG_ADDRESS, --6客户注册地址
     REG_REGION_CODE, --7客户地区代码
     DEP_ACC_CODE, --8存款账户编码
     DEP_AGR_CODE, --9存款协议代码
     PRODUCT_TYPE, --10存款产品类别
     CON_BGN_DATE, --11存款协议起始日期
     CON_DUE_DATE, --12存款协议到期日期
     CON_ACTUAL_DUE_DATE, --13存款协议实际终止日期
     CURR_CODE, --14存款币种
     TRANS_AMT, --15存款发生金额
     TRANS_AMT_RMB, --16存款发生金额折人民币
     INT_RATE, --17利率水平
     TRANS_DATE, --18交易日期
     SERIAL_NO, --19交易流水号
     TRANS_TYPE, --20交易方向
     TRANS_CHANNEL, --21交易渠道
     TRANS_FLG, --22现金转账标识
     CTPY_NAME, --23交易对手名称
     CTPY_ACC_CODE, --24交易对手存款账户编码
     CTPY_OPEN_BANK, --25交易对手账户开户行号
     CTPY_ID_TYPE, --26交易对手证件类型
     CTPY_ID_NO, --27交易对手代码
     TRANS_PURPOSE, --28存款交易用途
     
     --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
     FINI_REGION_CODE,   --金融机构地区代码
     DEP_ACC_TYPE,   --存款账户类型
     DEP_STATUS,   --存款状态
     
     REPORT_ID, --29报送ID
     CJRQ, --30采集日期
     NBJGH, --31内部机构号
     BIZ_LINE_ID, --32业务条线
     VERIFY_STATUS, --33校验状态
     BSCJRQ, --34报送周期
     FRNBJGH,--法人内部机构号
     CUST_ID, --35客户号
     CUST_NAME --36客户名
     )
  SELECT /*+parallel(4)*/
     VS_TEXT DATA_DATE, --1数据日期
     NVL(OB.ID_NO,OB.UP_ID_NO) AS ORG_CODE, --2金融机构代码
     B.ORG_NUM ORG_NUM, --3内部机构号
     
     
     CASE
       WHEN A.TYSHXYDM IS NOT NULL AND A.TYSHXYDM NOT LIKE '00000%' THEN
        'A01' --统一社会信用证
       WHEN LENGTH(A.ID_NO) = 18 THEN
        'A01'
       WHEN A.ORGANIZATIONCODE IS NOT NULL AND A.ORGANIZATIONCODE <> '0' AND
            A.ORGANIZATIONCODE <> '$' THEN
        'A02' --组织机构代码
       ELSE
        'A03' --其他
     END CUST_ID_TYPE, --4客户证件类型
      CASE
       WHEN A.TYSHXYDM IS NOT NULL AND A.TYSHXYDM NOT LIKE '00000%' THEN
        A.TYSHXYDM --统一社会信用证
       WHEN LENGTH(A.ID_NO) = 18 THEN
        A.ID_NO
       WHEN A.ORGANIZATIONCODE IS NOT NULL AND A.ORGANIZATIONCODE <> '0' AND
            A.ORGANIZATIONCODE <> '$' THEN
        REPLACE(A.ORGANIZATIONCODE, '-', '') --组织机构代码
       ELSE
        SUBSTR(A.ID_NO, 1, 20)
     END CUST_ID_NO, -- 5客户证件代码
     /*CASE 
       WHEN T.CUST_ID LIKE '2999%' THEN 'A01' -- 2999内部客户号取其归属机构信息
       ELSE D1.PBOCD_CODE 
     END AS CUST_ID_TYPE, --4客户证件类型
     CASE
       WHEN T.CUST_ID LIKE '2999%' THEN NVL(OB1.ID_NO,OB1.UP_ID_NO) -- 2999内部客户号取其归属机构信息
       WHEN LENGTH(A.ID_NO) > 20 THEN Double_Byte_conversion(A.ID_NO,60) --按照20个中文字符的极限情况判断
       WHEN D1.PBOCD_CODE = 'A02' THEN REPLACE(A.ID_NO,'-')
       ELSE A.ID_NO 
     END AS CUST_ID_NO, --5客户证件代码*/
     
     --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 特殊处理内部户和境外户
     REGEXP_REPLACE(REGEXP_REPLACE(CASE WHEN T.CUST_ID LIKE '2999%' THEN OB1.ORG_ADD ELSE A.BORROWER_REGISTER_ADDR END ,'[!?^？！ |]'),CHR(9)) AS REG_ADDRESS, --6注册地址 -- 2999内部客户号取其归属机构信息
     CASE 
       WHEN T.CUST_ID LIKE '2999%' THEN OB1.REGION_CD 
       WHEN A.NATION_CD <> 'CHN' THEN D2.PBOCD_CODE --外国客户取000+国别阿拉伯数字代码
       ELSE NVL(A.REGION_CD,A.ORG_AREA) END AS REG_REGION_CODE, --7客户地区代码 -- 2999内部客户号取其归属机构信息
     
     B.O_ACCT_NUM AS DEP_ACC_CODE,--8存款账户编码-20220727简化
     B.O_ACCT_NUM AS DEP_AGR_CODE,--9存款协议代码-20220727简化
     CASE
       WHEN B.ACCT_TYPE = '0601' AND B.GL_ITEM_CODE='20110201' THEN
        'D051' --结算户存款
       WHEN B.ACCT_TYPE = '0602' AND B.GL_ITEM_CODE='20110201' THEN--20220705-夏文博
        'D052' --协定户存款
       WHEN B.ACCT_TYPE IN ('0401', '0402') THEN
        'D03' --通知存款
       WHEN B.ACCT_TYPE = '0701' THEN
        'D061' --银行承兑汇票保证金存款
       WHEN B.ACCT_TYPE = '0702' THEN
        'D062' --信用证保证金存款
       WHEN B.ACCT_TYPE IN ('0703') THEN
        'D063' --保函保证金存款
       WHEN (B.ACCT_TYPE like '07%' OR B.GL_ITEM_CODE IN ('20110209','20110210')) THEN--20220705-夏文博
        'D069' --其他保证金存款
--[2025-08-30] [白杨] [JLBA202507210012_关于调整财政性存款及一般性存款相关科目统计方式的相关需求] [李楠]财政存款转一般存款 新增 '201103','201104','201105','201106','2008','2009'
       --WHEN B.GL_ITEM_CODE IN ('20110201','22410101') OR SUBSTR(B.GL_ITEM_CODE,1,6) IN('201103','201104','201105','201106') OR    THEN
       WHEN B.GL_ITEM_CODE IN ('20110201','22410101')
         OR SUBSTR(B.GL_ITEM_CODE,1,6) IN('201103','201104','201105','201106')
         OR SUBSTR(B.GL_ITEM_CODE,1,4) IN('2008','2009') THEN
        'D011' --单位活期存款
       WHEN B.GL_ITEM_CODE IN ('20110202', '20110203') THEN
        'D012' --单位定期存款
       WHEN B.GL_ITEM_CODE IN ('20110204', '20110211') THEN
        'D04' --协议存款
       WHEN B.GL_ITEM_CODE ='20110207'THEN
        'D08' --结构性存款
  --无需求 修改日期：2025-10-13，修改人：白杨，提出人：李楠   修改内容： D1095国库定期存款 不报，从程序中注释掉
       /*WHEN B.GL_ITEM_CODE IN ('201107', '20110701') OR B.GL_ITEM_CODE LIKE '2010%' THEN --[2025-05-27] [白杨] [JLBA202504180011_关于吉林银行交易级总账系统调整代理国库业务会计科目及核算规则的需求 ][李楠] 新增科目'2010'
        'D1095'*/ --国库定期存款
       WHEN B.ACCT_TYPE = '0101' THEN
        'D16' --大额存单存款
     END PRODUCT_TYPE, --10存款产品类别

     CASE WHEN TO_CHAR(B.ST_INT_DT, 'YYYY-MM-DD')='1900-01-01'
       OR B.ST_INT_DT IS NULL
        THEN
             TO_CHAR(B.ACCT_OPDATE, 'YYYY-MM-DD')
        ELSE TO_CHAR(B.ST_INT_DT, 'YYYY-MM-DD')
     END CON_BGN_DATE, --11存款协议起始日期
     --2023wxb起始日期加判断条件：如果起息日为空取开户日
     CASE
     WHEN B.ACCT_TYPE ='0401' THEN '1999-01-01'
     WHEN B.ACCT_TYPE ='0402' THEN '1999-01-07'--zhoulp20240410 需求JLBA202401240008
     WHEN B.MATUR_DATE IS NULL THEN '9999-12-31'
     
     --以下两种情况分别判断小于和等于，与存量存在逻辑差异，合理
     --保证金存款到期未支取的，到期日赋值99991231  会有期限跨期，人行同意
     WHEN (B.ACCT_TYPE like '07%' OR B.GL_ITEM_CODE IN('20110209','20110210')) AND NVL(TO_CHAR(B.MATUR_DATE, 'YYYYMMDD'),'99991231') < T.DATA_DATE
          THEN '9999-12-31'
     --保证金存款到期未全部支取的，到期日赋值99991231  会有期限跨期，人行同意
     --保证金存款到期全部支取的，这里不改成99991231，但核心传过来的利率是活期利率，不会触发校验，无影响
     WHEN (B.ACCT_TYPE like '07%' OR B.GL_ITEM_CODE IN('20110209','20110210')) AND NVL(TO_CHAR(B.MATUR_DATE, 'YYYYMMDD'),'99991231') = T.DATA_DATE AND B.ACCT_BALANCE <> 0
          THEN '9999-12-31'
     ELSE
     nvl(TO_CHAR(B.MATUR_DATE, 'YYYY-MM-DD'),'9999-12-31')
     END CON_DUE_DATE, --12存款协议到期日期

     CASE WHEN (
       (CASE WHEN T.TRANS_AMT < 0 THEN
          CASE WHEN T.CD_TYPE = '2' THEN '0' ELSE '1' END
            ELSE
          CASE WHEN T.CD_TYPE = '2' THEN '1' ELSE '0' END
        END) = '1' OR to_char(to_date(t.data_Date,'yyyy-mm-dd'),'yyyy-mm-dd')<>TO_CHAR(B.ACCT_CLDATE, 'YYYY-MM-DD')) --发生方向或者交易日期不等于实际终止日期时赋空值
                  THEN '' 
     ELSE TO_CHAR(B.ACCT_CLDATE, 'YYYY-MM-DD') END AS CON_ACTUAL_DUE_DATE, --存款协议实际终止日期
     
     T.CURRENCY CURR_CODE, --14存款币种
     --MODIFY BY DW (20220731) 如果交易金额小于0，交易金额取绝对值，且交易方向取反
     CASE WHEN T.TRANS_AMT < 0 THEN ABS(T.TRANS_AMT) ELSE T.TRANS_AMT END BALANCE, --15存款发生金额
     CASE WHEN T.TRANS_AMT < 0 THEN ABS(T.TRANS_AMT)*E.CCY_RATE ELSE T.TRANS_AMT*E.CCY_RATE END BALANCE_RMB, --16存款发生金额折人民币
     --CASE WHEN B.ACCT_TYPE = '0101' AND NVL(B.INT_RATE,0) = 0  THEN 4.5 else B.INT_RATE end, --17利率水平
     B.INT_RATE , --17利率水平

     to_char(to_date(t.data_Date,'yyyy-mm-dd'),'yyyy-mm-dd') TRANS_DATE, --18交易日期
     T.REFERENCE_NUM SERIAL_NO, --19交易流水号
     --MODIFY BY DW (20220731) 如果交易金额小于0，交易金额取绝对值，且交易方向取反
     CASE WHEN T.TRANS_AMT < 0 THEN
       CASE WHEN T.CD_TYPE = '2' THEN '0' ELSE '1' END
     ELSE
       CASE WHEN T.CD_TYPE = '2' THEN '1' ELSE '0' END
     END TRANS_TYPE, --20交易方向
     CASE
       WHEN T.CHANNEL = '01' THEN
        '01'
       WHEN T.CHANNEL = '04' THEN
        '02'
       WHEN T.CHANNEL = '08' THEN
        '02'
       WHEN T.CHANNEL = '02' THEN
        '03'
       WHEN T.CHANNEL = '05' THEN
        '99'
       WHEN T.CHANNEL = '06' THEN
        '04'
       WHEN T.TRANS_CHANNEL IN ('EFSJ','BCDS') THEN--EFSJ-综合柜面系统 BCDS-票据系统
        '01'
       WHEN T.TRANS_CHANNEL IN ('NBKJ','EBPS','EIBS','ibps01') THEN--NBKJ-个人网银 EBPS-网上支付跨行清算系统（超级网银） EIBS-新一代企业网上银行系统
        '03'
       WHEN T.TRANS_CHANNEL IN ('JMBK') THEN--JMBK-手机银行(屹通版)
        '04'
       WHEN T.TRANS_CHANNEL IN ('JBAT') THEN--JBAT-批量业务平台系统
        '99'
       ELSE
--[2025-08-07] [白杨] [无需求_应李楠要求，进行修改] 在原先ELSE空值里增加判断取数逻辑
         CASE WHEN T.TRANS_CHANNEL IN( 'JCBS','SMKS','NGIJ','HSFJ','JCMS','NBIS','EFSM','AG','CCUF','ISCP','FMSJ','DECD','CCIP','GBAJ','TIPS','DTIP') AND T.CD_TYPE = '2' THEN
            '99'
              WHEN T.TRANS_CHANNEL = 'GLS' AND SUBSTR(T.SERIAL_NO,1,4)='FMSJ' AND T.CD_TYPE IN( '2','1' )THEN
            '99'
              WHEN T.TRANS_CHANNEL IN ('NGIJ','SMKS','EFSM','NBIS','CUPG','HSFJ','FMSJ','NWDJ','DECD','ISCP') AND T.CD_TYPE = '1' THEN --[2025-09-24] [白杨] [无需求_应李楠要求，进行修改] 添加'ISCP'
            '99'
              WHEN (T.TRANS_CHANNEL IN ('SGPJ','DCUF','JAFA','ZJJG') AND T.CD_TYPE = '2') OR (T.TRANS_CHANNEL IN ('TIPS','DTIP','DCUF','JCBS','JAFA','ZJJG','CCUF') AND T.CD_TYPE = '1') OR (T.TRANS_CHANNEL IS NULL ) OR T.TRANS_CHANNEL='CFMP' THEN
            '99'
              WHEN T.TRANS_CHANNEL IN ('WLPJ','DIBP') AND T.CD_TYPE = '2'THEN
            '03'
              WHEN T.TRANS_CHANNEL IN ('JCMS','DIBP','CHIS') AND T.CD_TYPE = '1'THEN
            '03'
              WHEN T.TRANS_CHANNEL ='STIJ' AND T.CD_TYPE IN( '2','1' )THEN
            '01'
              WHEN T.TRANS_CHANNEL IN ('SGPJ','JCOC') AND T.CD_TYPE = '1' THEN
            '01'
              WHEN T.TRANS_CHANNEL IN ('GKZF','JLMB') AND T.CD_TYPE = '2' THEN
            '01'
              WHEN T.TRANS_CHANNEL IN('GKZF') AND SUBSTR(T.SERIAL_NO,1,4)='EFSJ' AND T.CD_TYPE = '1' THEN
            '01'
            --[2026-02-10] [周立鹏] [无需求][李楠] 调整渠道取数逻辑
              WHEN T.TRANS_CHANNEL IN('GKZF') AND SUBSTR(T.SERIAL_NO,1,4)='GKZF' AND T.CD_TYPE = '1' THEN
            '99'
           ELSE
            ''
         END
     END TRANS_CHANNEL, --21交易渠道

     CASE WHEN T.TRANS_FLG = '0' THEN '1'
          WHEN T.TRANS_FLG = '1' THEN '0' ELSE '1' END TRANS_FLG, --22现金转账标识  1-现金 0-转账 L层0为现金 1为转账

    SUBSTRB(
    CASE WHEN T.TRANS_FLG = '1' AND T.COUNTPTY_IDENTI IS NOT NULL AND NVL(COD.PBOCD_CODE,COD2.PBOCD_CODE) LIKE 'B%'
              THEN ''
       WHEN T.TRANS_FLG = '1'
       THEN REPLACE(REPLACE(REGEXP_REPLACE(T.OPPO_ACCT_NAM,'[!?^？！ |]'),CHR(9)),CHR(10)) ELSE NULL END 
    ,1,130) AS JYDSMC, --23交易对手名称  MODIFY WANGC 20241128 交易对手名称为个人的置空

     CASE WHEN T.TRANS_FLG = '1' THEN

       REPLACE(REPLACE(REGEXP_REPLACE(T.OPPO_ACCT_NUM,'[!?^？！ |]'),CHR(9)),CHR(10))
       ELSE NULL END JYDSCKZHBM, --24交易对手存款账户编码
     CASE WHEN T.TRANS_FLG = '1' THEN T.OPPO_ORG_NUM ELSE NULL  END JYDSZHKHHH, --25交易对手账户开户行号
     CASE WHEN T.TRANS_FLG = '1' AND T.COUNTPTY_IDENTI IS NULL THEN NULL
     --WHEN T.TRANS_FLG = '1' THEN NVL(COD.PBOCD_CODE,COD2.PBOCD_CODE) ELSE NULL END CTPY_ID_TYPE, --26交易对手证件类型--这个判断不准确，比如有的证件类型是营业执照但是证件号码是统一社会信用代码
     WHEN T.TRANS_FLG = '1' THEN
        CASE WHEN T.COUNTPTY_IDENTI IS NOT NULL AND NVL(COD.PBOCD_CODE,COD2.PBOCD_CODE) LIKE 'B%'
              THEN NVL(COD.PBOCD_CODE,COD2.PBOCD_CODE)
             WHEN T.COUNTPTY_IDENTI IS NOT NULL AND LENGTH(T.COUNTPTY_IDENTI) = 18
              THEN 'A01'
             WHEN T.COUNTPTY_IDENTI IS NOT NULL AND LENGTH(REPLACE(T.COUNTPTY_IDENTI,'-','')) = 9
              THEN 'A02'
             WHEN T.COUNTPTY_IDENTI IS NOT NULL
              THEN 'A03'
            ELSE NULL END
          ELSE NULL END CTPY_ID_TYPE, --26交易对手证件类型--这个判断不准确，比如有的证件类型是营业执照但是证件号码是统一社会信用代码
     CASE WHEN T.TRANS_FLG = '1' THEN T.COUNTPTY_IDENTI ELSE NULL END CTPY_ID_NO, --27交易对手代码

     CASE WHEN T.TRANS_FLG = '1'
            THEN NVL(REPLACE(REPLACE(REGEXP_REPLACE(T.TRAN_CODE_DESCRIBE,'[!?^？！ |]'),CHR(9)),CHR(10)),'转账')
          ELSE 'A' END TRANS_PURPOSE, --28存款交易用途
            
     --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
     OB.REGION_CD AS FINI_REGION_CODE,   --金融机构地区代码
     E1.PBOCD_CODE AS DEP_ACC_TYPE,   --存款账户类型
     E.PBOCD_CODE AS DEP_STATUS,   --存款状态 DS01-正常 DS02-休眠 DS03-限制 DS04-销户 DS99-其他
          
     SYS_GUID() REPORT_ID, --29报送ID
     IS_DATE AS CJRQ, --30采集日期
     B.ORG_NUM NBJGH, --31内部机构号
     '99' BIZ_LINE_ID, --32业务条线
     '' VERIFY_STATUS, --33校验状态
     '' BSCJRQ, --34报送周期
      CASE
           WHEN B.ORG_NUM LIKE '51%' THEN
           '510000'
           WHEN B.ORG_NUM LIKE '52%' THEN
            '520000'
           WHEN B.ORG_NUM LIKE '53%' THEN
            '530000'
           WHEN B.ORG_NUM LIKE '54%' THEN
            '540000'
           WHEN B.ORG_NUM LIKE '55%' THEN
            '550000'
           WHEN B.ORG_NUM LIKE '56%' THEN
            '560000'
           WHEN B.ORG_NUM LIKE '57%' THEN
            '570000'
           WHEN B.ORG_NUM LIKE '58%' THEN
            '580000'
           WHEN B.ORG_NUM LIKE '59%' THEN
            '590000'
           WHEN B.ORG_NUM LIKE '60%' THEN
            '600000'
           ELSE '990000'
     END FRORG_NUM,
     T.CUST_ID, --35客户号
     CASE WHEN T.CUST_ID LIKE '2999%' THEN B.ACCT_NAM ELSE A.CUST_NAM END --26客户名称
  FROM JS_202_DWCKFS_TMP01 T--流水临时表
  INNER JOIN SMTMODS.L_ACCT_DEPOSIT B --存款账户信息表
  ON T.ACCOUNT_CODE = B.ACCT_NUM
  AND  B.DATA_DATE=IS_DATE
  AND (B.ACCT_TYPE <> '0602' OR B.ACCT_TYPE IS NULL)
  INNER JOIN SMTMODS.L_CUST_C A --对公客户补充信息表
  ON T.CUST_ID = A.CUST_ID
  AND A.DATA_DATE=IS_DATE
  LEFT JOIN SMTMODS.L_PUBL_RATE E --汇率表
  ON T.CURRENCY = E.BASIC_CCY --账户币种
  AND E.CCY_DATE = TO_DATE(IS_DATE, 'yyyymmdd') --汇率日期
  AND E.DATA_DATE=IS_DATE
  AND E.FORWARD_CCY = 'CNY' --折算币种
  
  --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 直取ID_TYPE、ID_NO
  LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY D1
    ON A.ID_TYPE = D1.L_CODE
    AND D1.CODE_CLMN_NAME = 'ID_TYPE' --证件类型
    
  LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY D2
    ON A.NATION_CD = D2.L_CODE
    AND D2.CODE_CLMN_NAME = 'REG_REGION_CODE' --证件类型
  
  --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
  LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E --存款状态
    ON B.ACCT_STS = E.L_CODE
    AND E.CODE_CLMN_NAME = 'ACCT_STS'
  LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E1 --存款账户类型
    ON B.PBOC_ACCT_NATURE_CD/*人行账户属性*/ = E1.L_CODE
    AND E1.CODE_CLMN_NAME = 'ACCT_TYPE'
  
  LEFT JOIN L_CODE_DICTIONARY COD
  ON COD.L_CODE = T.COUNTPTY_ID_TYPE
  AND COD.CODE_CLMN_NAME = 'ID_TYPE'
  LEFT JOIN L_CODE_DICTIONARY COD2
  ON COD2.L_CODE = T.COUNTPTY_ID_TYPE2
  AND COD2.CODE_CLMN_NAME = 'COUNTPTY_ID_TYPE'
  
  LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=TRIM(B.ORG_NUM) AND OB.DATA_DATE=IS_DATE
  
  LEFT JOIN L_PUBL_ORG_BRA_TMP OB1--金数机构表
      ON OB1.ORG_NUM=CASE WHEN T.CUST_ID LIKE '2999%' THEN SUBSTR(T.CUST_ID,5) ELSE '#' END AND OB1.DATA_DATE=IS_DATE
      
--[2025-08-30] [白杨] [JLBA202507210012_关于调整财政性存款及一般性存款相关科目统计方式的相关需求] [李楠]财政存款转一般存款 新增 '201103','201104','201105','201106','2008','2009','2010'
  WHERE ((B.GL_ITEM_CODE IN ('20110202','20110203','20110204','20110211',/*'201107','20110701',*/'20110207','20110205','20110201','20110208'
        ,'20110209','20110210','22410101') OR SUBSTR(B.GL_ITEM_CODE,1,6) IN('201103','201104','201105','201106')
         OR SUBSTR(B.GL_ITEM_CODE,1,4) IN('2008','2009'/*,'2010'*/)) 
         AND A.DEPOSIT_CUSTTYPE NOT IN ('13','14'))--去除个体工商户
  AND T.TRANS_AMT != 0 AND ROUND(T.TRANS_AMT*E.CCY_RATE,2) !=0 --金额/折人民币金额是0的不报送
  ;
  COMMIT;
   --add by dw(20221031) BEGIN
  --增加 D15-委托资金（净） 目前无法准确细分，暂且按汇总一条数据报送
  --如果后期能够区分，需修改该部分脚本，已报送具体明细数据
  VS_STEP := '2.开始插入委托资金（净）值';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  INSERT /*+append*/ INTO PBOCD_DATACORE.PBOCD_JS_202_DWCKFS
    (DATA_DATE, --1数据日期
     ORG_CODE, --2金融机构代码
     ORG_NUM, --3内部机构号
     CUST_ID_TYPE, --4客户证件类型
     CUST_ID_NO, --5客户证件代码
     REG_ADDRESS, --6客户注册地址
     REG_REGION_CODE, --7客户地区代码
     DEP_ACC_CODE, --8存款账户编码
     DEP_AGR_CODE, --9存款协议代码
     PRODUCT_TYPE, --10存款产品类别
     CON_BGN_DATE, --11存款协议起始日期
     CON_DUE_DATE, --12存款协议到期日期
     CON_ACTUAL_DUE_DATE, --13存款协议实际终止日期
     CURR_CODE, --14存款币种
     TRANS_AMT, --15存款发生金额
     TRANS_AMT_RMB, --16存款发生金额折人民币
     INT_RATE, --17利率水平
     TRANS_DATE, --18交易日期
     SERIAL_NO, --19交易流水号
     TRANS_TYPE, --20交易方向
     TRANS_CHANNEL, --21交易渠道
     TRANS_FLG, --22现金转账标识
     CTPY_NAME, --23交易对手名称
     CTPY_ACC_CODE, --24交易对手存款账户编码
     CTPY_OPEN_BANK, --25交易对手账户开户行号
     CTPY_ID_TYPE, --26交易对手证件类型
     CTPY_ID_NO, --27交易对手代码
     TRANS_PURPOSE, --28存款交易用途
     
     --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
     FINI_REGION_CODE,   --金融机构地区代码
     DEP_ACC_TYPE,   --存款账户类型
     DEP_STATUS,   --存款状态
     
     REPORT_ID, --29报送ID
     CJRQ, --30采集日期
     NBJGH, --31内部机构号
     BIZ_LINE_ID, --32业务条线
     VERIFY_STATUS, --33校验状态
     BSCJRQ, --34报送周期
     FRNBJGH,--法人内部机构号
     CUST_ID, --35客户号
     CUST_NAME --36客户名
     )
  SELECT /*+parallel(4)*/
     VS_TEXT AS DATA_DATE, --1数据日期
     NVL(OB.ID_NO,OB.UP_ID_NO) AS ORG_CODE, --2金融机构代码
     T.ORG_NUM, --3内部机构号
     NULL AS CUST_ID_TYPE, --4客户证件类型
     NULL AS CUST_ID_NO, --5客户证件代码
     NULL AS REG_ADDRESS, --6客户注册地址
     NULL AS REG_REGION_CODE, --7客户地区代码
     T.O_ACCT_NUM AS DEP_ACC_CODE, --8存款账户编码
     T.O_ACCT_NUM AS DEP_AGR_CODE, --9存款协议代码
     'D15' AS PRODUCT_TYPE, --10存款产品类别

     CASE WHEN TO_CHAR(T.ST_INT_DT, 'YYYY-MM-DD')='1900-01-01'
       OR T.ST_INT_DT IS NULL
        THEN
             TO_CHAR(T.ACCT_OPDATE, 'YYYY-MM-DD')
        ELSE TO_CHAR(T.ST_INT_DT, 'YYYY-MM-DD')
     END CON_BGN_DATE, --11存款协议起始日期
     --2023wxb起始日期加判断条件：如果起息日为空取开户日
     NVL(TO_CHAR(T.MATUR_DATE, 'YYYY-MM-DD'),'9999-12-31') CON_DUE_DATE, --12存款协议到期日期--zhoulp20240410 需求JLBA202401240008
     NULL CON_ACTUAL_DUE_DATE, --13存款协议实际终止日期
     T.CURR_CD AS CURR_CODE, --14存款币种
     ABS(NVL(T1.BALANCE,0) - NVL(T2.BALANCE,0)) AS TRANS_AMT, --15存款发生金额
     ABS(NVL(T1.BALANCE,0) - NVL(T2.BALANCE_RMB,0)) AS TRANS_AMT_RMB, --16存款发生金额折人民币
     NULL AS INT_RATE, --17利率水平
     VS_TEXT AS TRANS_DATE, --18交易日期
     SYS_GUID() AS SERIAL_NO, --19交易流水号
     CASE WHEN NVL(T1.BALANCE,0) < NVL(T2.BALANCE,0) THEN '0' ELSE '1' END TRANS_TYPE, --20交易方向

     '99' TRANS_CHANNEL, --21交易渠道 --置空20230522   --[2025-10-21] [白杨] [无需求_王铭与李楠沟通进行修改] 原空值改成其他
     '1' TRANS_FLG, --22现金转账标识 --1-现金 0-转账
     NULL AS CTPY_NAME, --23交易对手名称
     NULL AS CTPY_ACC_CODE, --24交易对手存款账户编码
     NULL AS CTPY_OPEN_BANK, --25交易对手账户开户行号
     NULL AS CTPY_ID_TYPE, --26交易对手证件类型
     NULL AS CTPY_ID_NO, --27交易对手代码
     'A' AS TRANS_PURPOSE, --28存款交易用途
     
     --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
     OB.REGION_CD AS FINI_REGION_CODE,   --金融机构地区代码
     E1.PBOCD_CODE AS DEP_ACC_TYPE,   --存款账户类型
     E.PBOCD_CODE AS DEP_STATUS,   --存款状态 DS01-正常 DS02-休眠 DS03-限制 DS04-销户 DS99-其他
     
     SYS_GUID() as REPORT_ID, --29报送ID
     IS_DATE AS CJRQ, --30采集日期
     T.ORG_NUM AS NBJGH, --31内部机构号
     '99' AS BIZ_LINE_ID, --32业务条线
     '' AS VERIFY_STATUS, --33校验状态
     '' AS BSCJRQ, --34报送周期
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
            '600000'
           ELSE '990000'
     END FRORG_NUM,
     T.CUST_ID, --35客户号
     NULL CUST_NAME --36客户名
  FROM SMTMODS.L_ACCT_DEPOSIT T --存款账户信息表
  LEFT JOIN (
       SELECT /*+parallel(4)*/
        SUM(CASE WHEN GL.ITEM_CD = '3020' THEN -GL.DEBIT_BAL  ELSE GL.CREDIT_BAL END) AS BALANCE
  FROM SMTMODS.L_FINA_GL GL
       WHERE GL.DATA_DATE = IS_DATE
   AND GL.ITEM_CD IN ('3010', '3020')
         AND GL.CURR_CD = 'CNY'
         AND GL.ORG_NUM = '990000'
  ) T1 ON 1 = 1 --目前委托资金（净）无法细分，暂时按汇总后一条数据报送，客户信息置空，账号按存款余额最大一笔的账号进行报送
  LEFT JOIN PBOCD_JS_202_FTYDWC_SQ T2  --获取上期D15委托资金（净）存款余额
  ON T.O_ACCT_NUM = T2.DEP_ACC_CODE AND T2.CJRQ = VS_LAST_TEXT AND T2.PRODUCT_TYPE = 'D15'
  
  LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=TRIM(T.ORG_NUM) AND OB.DATA_DATE=IS_DATE
  
  --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
  LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E --存款状态
     ON T.ACCT_STS = E.L_CODE
     AND E.CODE_CLMN_NAME = 'ACCT_STS'
  LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E1 --存款账户类型
    ON T.PBOC_ACCT_NATURE_CD/*人行账户属性*/ = E1.L_CODE
    AND E1.CODE_CLMN_NAME = 'ACCT_TYPE'
    
  WHERE T.O_ACCT_NUM = '7330140601000020_1'
  AND T.DATA_DATE = IS_DATE
  AND ABS(NVL(T1.BALANCE,0) - NVL(T2.BALANCE,0)) <> 0
  ;
  COMMIT;


--[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 代码前移
/* ---以下包含原应用层加工逻辑，现都放在加工层处理

  --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'PBOCD_JS_202_DWCKFS'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_DATACORE.PBOCD_JS_202_DWCKFS ADD PARTITION P' ||
                      IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_DATACORE.PBOCD_JS_202_DWCKFS TRUNCATE PARTITION P' ||
                    IS_DATE;

  VS_STEP := '3.开始插入目标表';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

 INSERT INTO PBOCD_JS_202_DWCKFS
    (DATA_DATE, --数据日期
     ORG_CODE, --金融机构代码
     ORG_NUM, --内部机构号
     CUST_ID_TYPE, --客户证件类型
     CUST_ID_NO, --客户证件代码
     REG_ADDRESS, --客户注册地址
     REG_REGION_CODE, --客户地区代码
     DEP_ACC_CODE, --存款账户编码
     DEP_AGR_CODE, --存款协议代码
     PRODUCT_TYPE, --存款产品类别
     CON_BGN_DATE, --存款协议起始日期
     CON_DUE_DATE, --存款协议到期日期
     CON_ACTUAL_DUE_DATE, --存款协议实际终止日期
     CURR_CODE, --存款币种
     INT_RATE, --利率水平
     TRANS_DATE, --交易日期
     SERIAL_NO, --交易流水号
     TRANS_TYPE, --交易方向
     TRANS_CHANNEL, --交易渠道
     TRANS_FLG, --现金转账标识
     REPORT_ID, --报送ID
     CJRQ, --采集日期
     NBJGH, --内部机构号
     BIZ_LINE_ID, --业务条线
     VERIFY_STATUS, --校验状态
     BSCJRQ, --报送周期
     FRNBJGH,--法人内部机构号
     TRANS_AMT,--存款金额
     TRANS_AMT_RMB,--存款金额折人民币
     CTPY_NAME, --交易对手名称
     CTPY_ACC_CODE, --交易对手存款账户编码
     CTPY_OPEN_BANK, --交易对手账户开户行号
     CTPY_ID_TYPE, --交易对手证件类型
     CTPY_ID_NO, --交易对手证件代码
     TRANS_PURPOSE, --存款交易用途
     CUST_ID, --客户号
     CUST_NAME --客户名称
     )
    SELECT \*+parallel(4)*\
           TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD') DATA_DATE, --数据日期
           NVL(OB.ID_NO,OB.UP_ID_NO), --金融机构代码
           T.ORG_NUM, --内部机构号
           T.CUST_ID_TYPE, --客户证件类型
           T.CUST_ID_NO, --客户证件代码
           T.REG_ADDRESS, --客户注册地址
           T.REG_REGION_CODE, --客户地区代码
           T.DEP_ACC_CODE, --存款账户编码
           T.DEP_AGR_CODE, --存款协议代码
           T.PRODUCT_TYPE, --存款产品类别
           T.CON_BGN_DATE, --存款协议起始日期
           T.CON_DUE_DATE, --存款协议到期日期
           CASE WHEN (T.TRANS_TYPE = '1' OR T.TRANS_DATE<>T.CON_ACTUAL_DUE_DATE)
                  THEN '' ELSE T.CON_ACTUAL_DUE_DATE END, --存款协议实际终止日期
           T.CURR_CODE, --存款币种
           T.INT_RATE, --利率水平
           T.TRANS_DATE, --交易日期
           T.SERIAL_NO, --交易流水号
           T.TRANS_TYPE, --交易方向
           T.TRANS_CHANNEL, --交易渠道
           T.TRANS_FLG, --现金转账标识
           T.REPORT_ID, --报送ID
           T.CJRQ, --采集日期
           T.NBJGH, --内部机构号
           T.BIZ_LINE_ID, --业务条线
           T.VERIFY_STATUS, --校验状态
           T.BSCJRQ,--报送周期

           CASE
           WHEN T.NBJGH LIKE '51%' THEN
           '510000'
           WHEN T.NBJGH LIKE '52%' THEN
            '520000'
           WHEN T.NBJGH LIKE '53%' THEN
            '530000'
           WHEN T.NBJGH LIKE '54%' THEN
            '540000'
           WHEN T.NBJGH LIKE '55%' THEN
            '550000'
           WHEN T.NBJGH LIKE '56%' THEN
            '560000'
           WHEN T.NBJGH LIKE '57%' THEN
            '570000'
           WHEN T.NBJGH LIKE '58%' THEN
            '580000'
           WHEN T.NBJGH LIKE '59%' THEN
            '590000'
           WHEN T.NBJGH LIKE '60%' THEN
            '600000'----20231013王晓彬
           ELSE '990000'
             END FRNBJGH,
           T.TRANS_AMT,--存款金额
           T.TRANS_AMT_RMB, --存款金额折人民币
           SUBSTRB(T.CTPY_NAME,1,130), --交易对手名称
           T.CTPY_ACC_CODE, --交易对手存款账户编码
           T.CTPY_OPEN_BANK, --交易对手账户开户行号
           T.CTPY_ID_TYPE, --交易对手证件类型
           T.CTPY_ID_NO, --交易对手证件代码
           T.TRANS_PURPOSE, --存款交易用途
           T.CUST_ID, --客户号
           T.CUST_NAME --客户名称
      FROM PBOCD_JS_202_DWCKFS_TMP T
      LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=TRIM(T.ORG_NUM) AND OB.DATA_DATE=IS_DATE
      WHERE  T.CJRQ = IS_DATE
    ;
  COMMIT;*/


EXECUTE IMMEDIATE 'TRUNCATE TABLE DEPOSIT_TMP01';
EXECUTE IMMEDIATE 'TRUNCATE TABLE DEPOSIT_TMP02';

VS_STEP := '插入上月久悬，本月转营业外账户';
SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

INSERT INTO DEPOSIT_TMP01
SELECT A.DEP_ACC_CODE,B.GL_ITEM_CODE,C.GL_ITEM_CODE FROM
PBOCD_JS_202_FTYDWC A
INNER JOIN
SMTMODS.L_ACCT_DEPOSIT B
ON A.DEP_ACC_CODE=B.ACCT_NUM  AND  B.DATA_DATE =VS_LAST_TEXT
INNER JOIN
SMTMODS.L_ACCT_DEPOSIT C
ON A.DEP_ACC_CODE =C.ACCT_NUM AND  C.DATA_DATE =IS_DATE
WHERE
A.CJRQ =VS_LAST_TEXT
AND B.GL_ITEM_CODE<>'63010401'
AND C.GL_ITEM_CODE='63010401' --上月久悬，本月转营业外
;
COMMIT;


VS_STEP := '插入上月营业外，本月转活期又销户账户';
SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
--因0630总行数据，这段补的流水过多导致账户不平，另外上月营业外转销户的也不平，临时改为补录营业外转活期的账户使用
INSERT INTO DEPOSIT_TMP02
SELECT A.DEP_ACC_CODE,B.GL_ITEM_CODE,C.GL_ITEM_CODE,B.ACCT_BALANCE,C.ACCT_BALANCE FROM
(SELECT DISTINCT CJRQ,DEP_ACC_CODE FROM PBOCD_JS_202_DWCKFS WHERE CJRQ=IS_DATE ) A
INNER JOIN
SMTMODS.L_ACCT_DEPOSIT B
ON A.DEP_ACC_CODE=B.ACCT_NUM  AND  B.DATA_DATE =VS_LAST_TEXT
INNER JOIN
SMTMODS.L_ACCT_DEPOSIT C
ON A.DEP_ACC_CODE =C.ACCT_NUM AND  C.DATA_DATE =IS_DATE
WHERE
A.CJRQ =IS_DATE
AND B.GL_ITEM_CODE ='63010401'
AND C.GL_ITEM_CODE <>'63010401' --上月营业外，本月正常
AND C.ACCT_STS='C'              --本月销户状态
;
COMMIT;


VS_STEP := '插入上月久悬，本月转营业外，补充转出流水';
SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

--①插入发生临时表   -- 上月久悬，本月转营业外 增加转出流水
insert into PBOCD_JS_202_DWCKFS
           (DATA_DATE, --数据日期
     ORG_CODE, --金融机构代码
     ORG_NUM, --内部机构号
     CUST_ID_TYPE, --客户证件类型
     CUST_ID_NO, --客户证件代码
     REG_ADDRESS, --客户注册地址
     REG_REGION_CODE, --客户地区代码
     DEP_ACC_CODE, --存款账户编码
     DEP_AGR_CODE, --存款协议代码
     PRODUCT_TYPE, --存款产品类别
     CON_BGN_DATE, --存款协议起始日期
     CON_DUE_DATE, --存款协议到期日期
     CON_ACTUAL_DUE_DATE, --存款协议实际终止日期
     CURR_CODE, --存款币种
     INT_RATE, --利率水平
     TRANS_DATE, --交易日期
     SERIAL_NO, --交易流水号
     TRANS_TYPE, --交易方向
     TRANS_CHANNEL, --交易渠道
     TRANS_FLG, --现金转账标识
     
     --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
     FINI_REGION_CODE,   --金融机构地区代码
     DEP_ACC_TYPE,   --存款账户类型
     DEP_STATUS,   --存款状态
     
     REPORT_ID, --报送ID
     CJRQ, --采集日期
     NBJGH, --内部机构号
     BIZ_LINE_ID, --业务条线
     VERIFY_STATUS, --校验状态
     BSCJRQ, --报送周期
     FRNBJGH,--法人内部机构号
     TRANS_AMT,--存款金额
     TRANS_AMT_RMB,--存款金额折人民币
     CTPY_NAME, --交易对手名称
     CTPY_ACC_CODE, --交易对手存款账户编码
     CTPY_OPEN_BANK, --交易对手账户开户行号
     CTPY_ID_TYPE, --交易对手证件类型
     CTPY_ID_NO, --交易对手证件代码
     TRANS_PURPOSE, --存款交易用途
     CUST_ID, --客户号
     CUST_NAME --客户名称
     )
     SELECT /*+parallel(4)*/
           VS_TEXT, --数据日期
           t.org_code, --金融机构代码
           T.ORG_NUM, --内部机构号
           T.CUST_ID_TYPE, --客户证件类型
           T.CUST_ID_NO, --客户证件代码
           T.REG_ADDRESS, --客户注册地址
           T.REG_REGION_CODE, --客户地区代码
           T.DEP_ACC_CODE, --存款账户编码
           T.DEP_AGR_CODE, --存款协议代码
           T.PRODUCT_TYPE, --存款产品类别
           T.CON_BGN_DATE, --存款协议起始日期
           T.CON_DUE_DATE, --存款协议到期日期
           '', --存款协议实际终止日期
           T.CURR_CODE, --存款币种
           T.INT_RATE, --利率水平
           VS_TEXT, --交易日期
           SYS_GUID(), --交易流水号
           '0', --交易方向
           '99', --交易渠道   --修改人 ：白杨，20250808，没需求，应李楠要求，存款交易用途 为 '久悬转营业外' 的，交易渠道 为‘99’
           '0', --现金转账标识
           
           --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
           FINI_REGION_CODE,   --金融机构地区代码
           DEP_ACC_TYPE,   --存款账户类型
           DEP_STATUS,   --存款状态
           
           SYS_GUID(), --报送ID
           IS_DATE,--采集日期
           T.NBJGH, --内部机构号
           T.BIZ_LINE_ID, --业务条线
           '', --校验状态
           T.BSCJRQ,--报送周期
           CASE
           WHEN T.NBJGH LIKE '51%' THEN
           '510000'
           WHEN T.NBJGH LIKE '52%' THEN
            '520000'
           WHEN T.NBJGH LIKE '53%' THEN
            '530000'
           WHEN T.NBJGH LIKE '54%' THEN
            '540000'
           WHEN T.NBJGH LIKE '55%' THEN
            '550000'
           WHEN T.NBJGH LIKE '56%' THEN
            '560000'
           WHEN T.NBJGH LIKE '57%' THEN
            '570000'
           WHEN T.NBJGH LIKE '58%' THEN
            '580000'
           WHEN T.NBJGH LIKE '59%' THEN
            '590000'
           WHEN T.NBJGH LIKE '60%' THEN
            '600000'
           ELSE '990000'
             END FRNBJGH,
           T.BALANCE,--存款金额
           T.BALANCE_RMB, --存款金额折人民币
           '对公存款不动户收入', --交易对手名称
           '63010401', --交易对手存款账户编码
           CASE
           WHEN T.NBJGH LIKE '51%' THEN
           '510000'
           WHEN T.NBJGH LIKE '52%' THEN
            '529801'
           WHEN T.NBJGH LIKE '53%' THEN
            '539801'
           WHEN T.NBJGH LIKE '54%' THEN
            '549801'
           WHEN T.NBJGH LIKE '55%' THEN
            '559801'
           WHEN T.NBJGH LIKE '56%' THEN
            '569801'
           WHEN T.NBJGH LIKE '57%' THEN
            '579801'
           WHEN T.NBJGH LIKE '58%' THEN
            '589801'
           WHEN T.NBJGH LIKE '59%' THEN
            '599801'
           WHEN T.NBJGH LIKE '60%' THEN
            '609801'
           ELSE '009801'
             END , --交易对手账户开户行号
           '', --交易对手证件类型
           '', --交易对手证件代码
           '久悬转营业外', --存款交易用途
           T.CUST_ID, --客户号
           T.CUST_NAME --客户名称
           from PBOCD_JS_202_FTYDWC t
           inner join deposit_tmp01 aa
           on t.dep_acc_code=aa.dep_acc_code
           where t.CJRQ = VS_LAST_TEXT
       ;
commit;

  VS_STEP := '4.部分数据特殊处理';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
--发现有这种因为汇率导致交易金额折人民币是0的，直接删掉
DELETE FROM PBOCD_JS_202_DWCKFS A
 WHERE CJRQ = IS_DATE
   AND FRNBJGH = '990000'
   AND CURR_CODE <> 'CNY'
   AND TRANS_AMT > 0
   AND TRANS_AMT_RMB = 0;
COMMIT;

--[2025-07-29] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_三阶段][李楠] 去掉利率特殊处理
/*--修正利率
    UPDATE PBOCD_JS_202_DWCKFS
       SET INT_RATE = 0.05
     WHERE CJRQ = IS_DATE
       AND PRODUCT_TYPE = 'D011'
       AND CURR_CODE = 'CNY'
       AND (INT_RATE = 0 OR INT_RATE IS NULL);
    COMMIT;*/

/*    UPDATE PBOCD_JS_202_DWCKFS
       SET INT_RATE = 4.5
     WHERE CJRQ = IS_DATE
       AND PRODUCT_TYPE = 'D16'
       AND CURR_CODE = 'CNY'
       AND (INT_RATE = 0 OR INT_RATE IS NULL);
    COMMIT;              */

--[2025-07-29] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_三阶段][李楠] 去掉利率特殊处理
/*    MERGE INTO PBOCD_JS_202_DWCKFS A
    USING (SELECT *
             FROM (SELECT DEP_ACC_CODE,
                          PRODUCT_TYPE,
                          INT_RATE,
                          ROW_NUMBER() OVER(PARTITION BY DEP_ACC_CODE, PRODUCT_TYPE ORDER BY CJRQ DESC) RN
                     FROM PBOCD_JS_202_FTYDWC_SQ
                    WHERE CJRQ = VS_LAST_TEXT) B
            WHERE B.RN = 1) B
    ON (A.DEP_ACC_CODE = B.DEP_ACC_CODE \*AND A.PRODUCT_TYPE = B.PRODUCT_TYPE*\)
    WHEN MATCHED THEN
      UPDATE
         SET A.INT_RATE = B.INT_RATE
       WHERE A.CJRQ = IS_DATE
         AND (A.INT_RATE = 0 OR A.INT_RATE IS NULL);*/
    COMMIT;

    /*UPDATE PBOCD_JS_202_DWCKFS
       SET INT_RATE = INT_RATE * 100
     WHERE CJRQ = IS_DATE
       AND INT_RATE > 0
       AND INT_RATE <= 0.001;
    COMMIT;*/

--注册地址不允许有“无”的、电话号码的、金额的，含特殊字符的已在加工层处理
    UPDATE PBOCD_JS_202_DWCKFS
       SET REG_ADDRESS = ''
     WHERE CJRQ = IS_DATE
       AND (REG_ADDRESS = '无' OR REGEXP_LIKE(REG_ADDRESS, '^[0-9,.]+$'));
     COMMIT;

--[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 直取ID_TYPE、ID_NO
/*--地区代码
--20251230 辉哥要求暂时保留，等数据治理完成后剔除
MERGE INTO \*+parallel(4)*\PBOCD_JS_202_DWCKFS A
USING (SELECT *
         FROM (SELECT DEP_ACC_CODE,
                      REG_REGION_CODE,
                      ROW_NUMBER() OVER(PARTITION BY DEP_ACC_CODE ORDER BY CJRQ DESC) RN
                 FROM PBOCD_JS_202_FTYDWC_SQ
                WHERE REG_REGION_CODE IS NOT NULL) B
        WHERE B.RN = 1) B
ON (A.DEP_ACC_CODE = B.DEP_ACC_CODE) --用账号关联
WHEN MATCHED THEN
  UPDATE
     SET A.REG_REGION_CODE = B.REG_REGION_CODE
   WHERE A.CJRQ = IS_DATE
     AND (REG_REGION_CODE IS NULL OR REG_REGION_CODE IN ('999999','China '));
COMMIT;
--20251230 辉哥要求暂时保留，等数据治理完成后剔除
MERGE INTO \*+parallel(4)*\PBOCD_JS_202_DWCKFS A
USING (SELECT *
         FROM (SELECT REG_ADDRESS,
                      REG_REGION_CODE,
                      ROW_NUMBER() OVER(PARTITION BY REG_ADDRESS ORDER BY CJRQ DESC) RN
                 FROM PBOCD_JS_202_FTYDWC_SQ
                WHERE REG_REGION_CODE IS NOT NULL) B
        WHERE B.RN = 1) B
ON (A.REG_ADDRESS = B.REG_ADDRESS) --用地址关联
WHEN MATCHED THEN
  UPDATE
     SET A.REG_REGION_CODE = B.REG_REGION_CODE
   WHERE A.CJRQ = IS_DATE
     AND (REG_REGION_CODE IS NULL OR REG_REGION_CODE IN ('999999','China '));
COMMIT;*/

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
/*--公主岭地区代码
UPDATE PBOCD_JS_202_DWCKFS
   SET REG_REGION_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND REG_REGION_CODE = '220381';
COMMIT;

--地区代码 这户经常是有发生，没存量，刷不到
UPDATE PBOCD_JS_202_DWCKFS
   SET REG_REGION_CODE = '220524'--吉林省通化市柳河县柳河大街2008号
 WHERE CJRQ = IS_DATE
   AND FRNBJGH = '990000'
   AND REG_REGION_CODE IS NULL
   AND DEP_ACC_CODE = '828010188900000275_1';
COMMIT;*/

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
/*--证件类型、证件代码
  UPDATE PBOCD_JS_202_DWCKFS
     SET CUST_ID_NO = '91220204660101640X',
         CUST_ID    = '6000417608',
         CUST_NAME  = '吉林市凯晟金属材料经销有限公司'
   WHERE CJRQ = IS_DATE
     AND DEP_ACC_CODE = '0207011000001961'
     AND CUST_ID_NO = '9122010170255776XN';
  COMMIT;*/
  

--修改证件代码
  UPDATE PBOCD_JS_202_DWCKFS
     SET CUST_ID_NO = '91220105MA159TBH0E',
         CUST_ID_TYPE='A01'
   WHERE CJRQ = IS_DATE
     AND DEP_ACC_CODE = '0101011000012931_1';
  COMMIT;
  UPDATE PBOCD_JS_202_DWCKFS
     SET CUST_ID_NO = '91220103MA0Y4T80XC',
         CUST_ID_TYPE='A01'
   WHERE CJRQ = IS_DATE
     AND DEP_ACC_CODE = '0110261000000066_1';
  COMMIT;
  UPDATE PBOCD_JS_202_DWCKFS
     SET CUST_ID_NO = '522201823099616519',
         CUST_ID_TYPE='A01'
   WHERE CJRQ = IS_DATE
     AND DEP_ACC_CODE = '0123011000001645_1';
  COMMIT;

--[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 楠姐要求去掉
/*  UPDATE PBOCD_JS_202_DWCKFS A
     SET CUST_ID_NO = '', CUST_ID_TYPE = ''
   WHERE A.CJRQ = IS_DATE
     AND (LENGTH(CUST_ID_NO) <= 3 OR CUST_ID_NO = '000000000');
  COMMIT;*/

--[2025-05-13] [周立鹏] [无需求][李楠] 恢复到原逻辑
--20251230 按辉哥要求保留此逻辑
--原逻辑
UPDATE PBOCD_JS_202_DWCKFS SET CUST_ID_TYPE='A03' WHERE CJRQ=IS_DATE AND CUST_ID_TYPE='A01' AND  (SUBSTR(CUST_ID_NO,1,2) NOT IN ('11','12','13','19','21','29','31','32','33','34','35','39','41','49','51','52','53','59','61','62','69','71','72','79','81','89','91','92','93','A1','A9','N1','N2','N3','N9','Y1')
OR NOT REGEXP_LIKE(SUBSTR(CUST_ID_NO,3,6),'^[0-9]+$')
OR SUBSTR(CUST_ID_NO,3,2) NOT IN ('10','11','12','13','14','15','21','22','23','31','32','33','34','35','36','37','41','42','43','44','45','46','50','51','52','53','54','61','62','63','64','65')
OR NOT REGEXP_LIKE(SUBSTR(CUST_ID_NO,9,9),'^[0-9A-Z,_]+$') --  不是数字、大写英文字母和下划线
OR NOT REGEXP_LIKE(SUBSTR(CUST_ID_NO,-1,1),'^[0-9A-Z]+$')--不是数字和大写英文字母
OR SUBSTR(CUST_ID_NO,-1,1)   IN ('I','O','Z','S','V')
);
  COMMIT;
--新逻辑
--20240929最新规则
/*UPDATE PBOCD_JS_202_DWCKFS SET CUST_ID_TYPE='A03' WHERE CJRQ=IS_DATE AND CUST_ID_TYPE='A01' AND  (SUBSTR(CUST_ID_NO,1,2) NOT IN ('11','12','13','19','21','29','31','32','33','34','35','39','41','49','51','52','53','54','55','59','61','62','69','71','72','79','81','89','91','92','93','A1','A9','N1','N2','N3','N9','Y1')
OR NOT REGEXP_LIKE(SUBSTR(CUST_ID_NO,3,6),'^[0-9]+$')
OR SUBSTR(CUST_ID_NO,3,2) NOT IN ('10','11','12','13','14','15','21','22','23','31','32','33','34','35','36','37','41','42','43','44','45','46','50','51','52','53','54','61','62','63','64','65','99')
OR NOT REGEXP_LIKE(SUBSTR(CUST_ID_NO,9,10),'^[0-9A-Z]+$') --  不是数字、大写英文字母和下划线
--OR NOT REGEXP_LIKE(SUBSTR(CUST_ID_NO,-1,1),'^[0-9A-Z]+$')--不是数字和大写英文字母
OR SUBSTR(CUST_ID_NO,-1,1)   IN ('I','O','Z','S','V')
);*/



--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
--证件号码是空的，客户号都是一些内部号，刷一下证件类型、证件代码、户名
--先按存量刷，刷不到的再按上期刷
MERGE INTO PBOCD_JS_202_DWCKFS A
USING (SELECT *
         FROM PBOCD_JS_202_FTYDWC A
        WHERE A.CJRQ = IS_DATE
          AND A.FRNBJGH = '990000') B
ON (A.DEP_ACC_CODE = B.DEP_ACC_CODE)
WHEN MATCHED THEN
  UPDATE
     SET A.CUST_ID_TYPE = B.CUST_ID_TYPE,
         A.CUST_ID_NO   = B.CUST_ID_NO
         --A.CUST_NAME    = B.CUST_NAME
   WHERE A.CJRQ = IS_DATE
     AND A.FRNBJGH = '990000'
     AND A.CUST_ID_NO IS NULL;
COMMIT;

MERGE INTO PBOCD_JS_202_DWCKFS A
USING (SELECT *
         FROM PBOCD_JS_202_FTYDWC_SQ A
        WHERE A.CJRQ = VS_LAST_TEXT
          AND A.FRNBJGH = '990000') B
ON (A.DEP_ACC_CODE = B.DEP_ACC_CODE)
WHEN MATCHED THEN
  UPDATE
     SET A.CUST_ID_TYPE = B.CUST_ID_TYPE,
         A.CUST_ID_NO   = B.CUST_ID_NO
         --A.CUST_NAME    = B.CUST_NAM
   WHERE A.CJRQ = IS_DATE
     AND A.FRNBJGH = '990000'
     AND A.CUST_ID_NO IS NULL;
COMMIT;

--[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 上面户名不穿透了，对应的地区代码和地址也不应该穿透了
/*--内部户户名穿透的同时，对应的地区代码和地址也穿透一下
--20251230 辉哥要求保留
MERGE INTO PBOCD_JS_202_DWCKFS A
USING (SELECT \*+PARALLEL(4)*\ B.CUST_ID_NBH,B.ACCT_NAM,C.BORROWER_REGISTER_ADDR, C.REGION_CD, C.ORG_AREA
         FROM FTY_NBH B
        INNER JOIN SMTMODS.L_CUST_C C
           ON B.CUST_ID = C.CUST_ID
          AND C.DATA_DATE = IS_DATE) D
ON (A.CUST_ID = D.CUST_ID_NBH AND A.CUST_NAME = D.ACCT_NAM)
WHEN MATCHED THEN
  UPDATE
     SET A.REG_ADDRESS     = REGEXP_REPLACE(REGEXP_REPLACE(D.BORROWER_REGISTER_ADDR,
                                                           '[!?^？！ |]'),
                                            CHR(9)),
         A.REG_REGION_CODE = NVL(D.REGION_CD, D.ORG_AREA)
   WHERE A.CJRQ = IS_DATE
     AND A.FRNBJGH = '990000';
COMMIT;*/


--客户证件类型触发_硬校验-客户证件类型与存量非同业单位存款信息的客户证件类型应该一致
--存量和发生取数逻辑一致，但由于关联条件用的客户号不一致，导致还有这种问题，按存量刷一下
--20251230 这个可以保留
MERGE INTO PBOCD_JS_202_DWCKFS A
USING (SELECT DISTINCT DEP_ACC_CODE, CUST_ID_TYPE, CUST_ID_NO
         FROM PBOCD_JS_202_FTYDWC A
        WHERE CJRQ = IS_DATE) B
ON (A.DEP_ACC_CODE = B.DEP_ACC_CODE)
WHEN MATCHED THEN
  UPDATE
     SET A.CUST_ID_TYPE = B.CUST_ID_TYPE, A.CUST_ID_NO = B.CUST_ID_NO
   WHERE CJRQ = IS_DATE;
COMMIT;

--交易用途
UPDATE PBOCD_JS_202_DWCKFS
   SET TRANS_PURPOSE = CASE WHEN TRANS_FLG = 0 THEN '转账' ELSE 'A' END
 WHERE CJRQ = IS_DATE

   AND (REGEXP_LIKE(TRANS_PURPOSE, '^[a-zA-Z0-9 ·]+$') OR
       TRANS_PURPOSE LIKE '%A%' OR TRANS_PURPOSE LIKE '%B%')--包含A和B的上报人行也会报错
   AND TRANS_PURPOSE NOT IN(
 'A',
'B01',
'B0101',
'B0102',
'B0103',
'B0104',
'B0105',
'B0106',
'B02',
'B0201',
'B0202',
'B0203',
'B0204',
'B0205',
'B0206',
'B0207',
'B03',
'B0301',
'B0302',
'B0303',
'B0304',
'B0305',
'B0306',
'B0307',
'B04',
'B05',
'B06'
);
COMMIT;

UPDATE PBOCD_JS_202_DWCKFS
   SET TRANS_PURPOSE = '转账'
 WHERE CJRQ = IS_DATE
   AND TRANS_PURPOSE IS NULL
   AND TRANS_FLG = '0';
COMMIT;

UPDATE PBOCD_JS_202_DWCKFS
   SET TRANS_PURPOSE = 'A'
 WHERE CJRQ = IS_DATE
   AND TRANS_PURPOSE IS NULL
   AND TRANS_FLG = '1';
COMMIT;

/******************修改对手信息**********************/
--先把对手名称是个人的置空，避免补对手证件类型、号码时补错

UPDATE PBOCD_JS_202_DWCKFS
   SET CTPY_NAME = ''
 WHERE CJRQ = IS_DATE
   AND FRNBJGH = '990000'
   AND LENGTH(CTPY_NAME) < 4
   AND (CTPY_ID_TYPE LIKE 'B%' OR CTPY_ID_TYPE IS NULL);
COMMIT;

UPDATE PBOCD_JS_202_DWCKFS
   SET CTPY_NAME = ''
 WHERE CJRQ = IS_DATE
   AND FRNBJGH = '990000'
   AND LENGTH(CTPY_NAME) = 4
   AND (CTPY_ID_TYPE LIKE 'B%' OR CTPY_ACC_CODE LIKE '62%');
COMMIT;

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 之前不补交易对手代码了，所以类型也不应该补了
/*--补对手证件类型、号码
MERGE INTO \*+parallel(4)*\PBOCD_JS_202_DWCKFS A
USING (SELECT *
         FROM (SELECT DISTINCT CUST_NAM,
                               CASE
                                 WHEN T.TYSHXYDM IS NOT NULL AND
                                      T.TYSHXYDM NOT LIKE '00000%' THEN
                                  'A01' --统一社会信用证
                                 WHEN LENGTH(T.ID_NO) = 18 THEN
                                  'A01'
                                 WHEN T.ORGANIZATIONCODE IS NOT NULL AND
                                      T.ORGANIZATIONCODE <> '0' THEN
                                  'A02' --组织机构代码
                                 WHEN LENGTH(REPLACE(T.ID_NO, '-', '')) = 9 THEN
                                  'A02'
                                 WHEN LENGTH(T.ID_NO) IS NOT NULL THEN
                                  'A03' --其他
                               END CUST_ID_TYPE,
                               CASE
                                 WHEN T.TYSHXYDM IS NOT NULL AND
                                      T.TYSHXYDM NOT LIKE '00000%' THEN
                                  T.TYSHXYDM
                                 WHEN LENGTH(T.ID_NO) = 18 THEN
                                  T.ID_NO
                                 WHEN T.ORGANIZATIONCODE IS NOT NULL AND
                                      T.ORGANIZATIONCODE <> '0' THEN
                                  REPLACE(T.ORGANIZATIONCODE, '-', '')
                                 ELSE
                                  REPLACE(T.ID_NO, '-', '')
                               END CUST_ID_NO, --4客户证件代码
                               ROW_NUMBER() OVER(PARTITION BY T.CUST_NAM ORDER BY T.CUST_NAM DESC) RN
                 FROM L_CUST_C_TMP T
                WHERE CUST_NAM IS NOT NULL) C
        WHERE C.RN = 1) C
ON (A.CTPY_NAME = C.CUST_NAM)
WHEN MATCHED THEN
  UPDATE
     SET A.CTPY_ID_TYPE = C.CUST_ID_TYPE
     --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
         --A.CTPY_ID_NO   = SUBSTR(C.CUST_ID_NO, 1, 20)
   WHERE A.CJRQ = IS_DATE
     AND FRNBJGH = '990000'
     AND A.CTPY_NAME IS NOT NULL
     AND ((A.CTPY_ID_TYPE IS NULL AND A.CTPY_ID_NO IS NOT NULL) OR
         (A.CTPY_ID_TYPE IS NOT NULL AND A.CTPY_ID_NO IS NULL));
COMMIT;*/

--[2025-05-13] [周立鹏] [无需求][李楠] 恢复到原逻辑
--原逻辑
UPDATE PBOCD_JS_202_DWCKFS SET CTPY_ID_TYPE='A03' WHERE CJRQ=IS_DATE AND FRNBJGH='990000' AND CTPY_ID_TYPE='A01' AND  (SUBSTR(CTPY_ID_NO,1,2) NOT IN ('11','12','13','19','21','29','31','32','33','34','35','39','41','49','51','52','53','59','61','62','69','71','72','79','81','89','91','92','93','A1','A9','N1','N2','N3','N9','Y1')
OR NOT REGEXP_LIKE(SUBSTR(CTPY_ID_NO,3,6),'^[0-9]+$')
OR SUBSTR(CTPY_ID_NO,3,2) NOT IN ('10','11','12','13','14','15','21','22','23','31','32','33','34','35','36','37','41','42','43','44','45','46','50','51','52','53','54','61','62','63','64','65')
OR NOT REGEXP_LIKE(SUBSTR(CTPY_ID_NO,9,9),'^[0-9A-Z,_]+$') --  不是数字、大写英文字母和下划线
OR NOT REGEXP_LIKE(SUBSTR(CTPY_ID_NO,-1,1),'^[0-9A-Z]+$')--不是数字和大写英文字母
OR SUBSTR(CTPY_ID_NO,-1,1)   IN ('I','O','Z','S','V')
);

--新逻辑
--20240929最新规则
/*UPDATE PBOCD_JS_202_DWCKFS SET CTPY_ID_TYPE='A03' WHERE CJRQ=IS_DATE AND CTPY_ID_TYPE='A01' AND  (SUBSTR(CTPY_ID_NO,1,2) NOT IN ('11','12','13','19','21','29','31','32','33','34','35','39','41','49','51','52','53','54','55','59','61','62','69','71','72','79','81','89','91','92','93','A1','A9','N1','N2','N3','N9','Y1')
OR NOT REGEXP_LIKE(SUBSTR(CTPY_ID_NO,3,6),'^[0-9]+$')
OR SUBSTR(CTPY_ID_NO,3,2) NOT IN ('10','11','12','13','14','15','21','22','23','31','32','33','34','35','36','37','41','42','43','44','45','46','50','51','52','53','54','61','62','63','64','65','99')
OR NOT REGEXP_LIKE(SUBSTR(CTPY_ID_NO,9,10),'^[0-9A-Z]+$') --  不是数字、大写英文字母和下划线
--OR NOT REGEXP_LIKE(SUBSTR(CTPY_ID_NO,-1,1),'^[0-9A-Z]+$')--不是数字和大写英文字母
OR SUBSTR(CTPY_ID_NO,-1,1)   IN ('I','O','Z','S','V')
);*/
COMMIT;

--最新标准
MERGE INTO /*+parallel(4)*/PBOCD_JS_202_DWCKFS A
USING (SELECT * FROM L_PUBL_ORG_BRA_TMP WHERE DATA_DATE = IS_DATE) B
ON (A.ORG_NUM = B.ORG_NUM)
WHEN MATCHED THEN
  UPDATE
     SET A.CTPY_NAME = B.ORG_NAM, A.CTPY_ACC_CODE = A.ORG_CODE
   WHERE A.CJRQ = IS_DATE
     AND FRNBJGH = '990000'
     AND TRANS_PURPOSE LIKE '%结息%';
COMMIT;

UPDATE PBOCD_JS_202_DWCKFS
   SET CTPY_ID_TYPE = '', CTPY_ID_NO = ''
 WHERE CJRQ = IS_DATE
   AND FRNBJGH = '990000'
   AND CTPY_NAME LIKE '%待报解预算收入%';
COMMIT;
--内部户置空
UPDATE /*+parallel(4)*/ PBOCD_JS_202_DWCKFS A
   SET CTPY_ID_TYPE = '', CTPY_ID_NO = ''
 WHERE A.CJRQ = IS_DATE
   AND A.FRNBJGH = '990000'
   AND EXISTS
 (SELECT 1
          FROM SMTMODS.L_ACCT_INNER B
         WHERE A.CTPY_ACC_CODE || '1' = B.O_ACCT_NUM
           AND B.DATA_DATE = IS_DATE
           AND B.ACCT_NUM NOT LIKE B.O_ACCT_NUM || B.ITEM_ID || '%'
           AND B.ITEM_ID NOT LIKE '9%');
COMMIT;

UPDATE PBOCD_JS_202_DWCKFS A
   SET CTPY_ID_TYPE   = '',
       CTPY_ID_NO     = '',
       CTPY_ACC_CODE  = '',
       CTPY_OPEN_BANK = ''
 WHERE A.CJRQ = IS_DATE
   AND A.FRNBJGH = '990000'
   AND CTPY_ACC_CODE IN ('0412052700000016',
                         '9040613902000015',
                         '9079801012230100002',
                         '9091201014030100001',
                         '9091313902000012',
                         '9099801014030100001',
                         '9099801014030100003');
COMMIT;

UPDATE PBOCD_JS_202_DWCKFS A
   SET A.TRANS_PURPOSE = 'B0305'
 WHERE A.CJRQ = IS_DATE
   AND FRNBJGH = '990000'
   AND CTPY_NAME LIKE '%代发工资%';
COMMIT;

UPDATE PBOCD_JS_202_DWCKFS
   SET CTPY_ID_TYPE   = '',
       CTPY_ID_NO     = '',
       CTPY_ACC_CODE  = '',
       CTPY_OPEN_BANK = '',
       CTPY_NAME      = ''
 WHERE CJRQ = IS_DATE
   AND FRNBJGH = '990000'
   AND (CTPY_NAME LIKE '%银联%' OR CTPY_NAME LIKE '%支付宝%' OR
       CTPY_NAME LIKE '%财付通%' OR CTPY_NAME = '北京钱袋宝支付技术有限公司');
COMMIT;

--[2025-07-29] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_三阶段][李楠] 报送D1095
/*--D1095产品不报送，在此删除
DELETE FROM PBOCD_JS_202_DWCKFS
  WHERE CJRQ = IS_DATE
  AND PRODUCT_TYPE='D1095';
COMMIT;*/


--交易对手是个人，交易对手名称置空
UPDATE PBOCD_JS_202_DWCKFS A
  SET A.CTPY_NAME=''
WHERE A.CJRQ = IS_DATE
AND A.CTPY_ID_TYPE LIKE 'B%';
COMMIT;

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
/
