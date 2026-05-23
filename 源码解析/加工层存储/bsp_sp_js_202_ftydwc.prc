CREATE OR REPLACE PROCEDURE BSP_SP_JS_202_FTYDWC (IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_202_FTYDWC
  -- 业务域: 存款类
  -- 用途: 生成接口表 JS_202_FTYDWC 非同业单位存款信息
  -- 参数
  --    IS_DATE 输入，传入跑批日期
  --    OI_RETCODE 输出，用来标识存储过程执行过程中是否出现异常
  -- 引用的监管集市表
  --    SMTMODS.L_ACCT_DEPOSIT                             — 存款账户信息表
  --    SMTMODS.L_CUST_C                                   — 对公客户补充信息表
  --    SMTMODS.L_FINA_GL                                  — 总账科目表
  --    SMTMODS.L_PUBL_RATE                                — 汇率表
  -- 修改历史
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段 上线日期：2025-04-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(100); --存储过程执行步骤标志
  NUM               INTEGER;

BEGIN
  VS_TEXT := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');
  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_202_FTYDWC';
  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------

/*  --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'PBOCD_JS_202_FTYDWC_TMP'
     AND PARTITION_NAME = 'PBOCD_JS_202_FTYDWC_TMP_' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_DATACORE.PBOCD_JS_202_FTYDWC_TMP ADD PARTITION PBOCD_JS_202_FTYDWC_TMP_' ||
                      IS_DATE || ' VALUES (' || IS_DATE || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_DATACORE.PBOCD_JS_202_FTYDWC_TMP TRUNCATE PARTITION PBOCD_JS_202_FTYDWC_TMP_' ||
                    IS_DATE;*/

   --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'PBOCD_JS_202_FTYDWC'
     AND PARTITION_NAME = 'PBOCD_JS_202_FTYDWC_' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_DATACORE.PBOCD_JS_202_FTYDWC ADD PARTITION PBOCD_JS_202_FTYDWC_' ||
                      IS_DATE || ' VALUES (' || IS_DATE || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_DATACORE.PBOCD_JS_202_FTYDWC TRUNCATE PARTITION PBOCD_JS_202_FTYDWC_' ||
                    IS_DATE;
                    
  VS_STEP := '1.插入非同业单位存款信息';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  --非同业单位存款
  INSERT INTO PBOCD_DATACORE.PBOCD_JS_202_FTYDWC
    (DATA_DATE, --1数据日期
     ORG_CODE, --2金融机构代码
     ORG_NUM, --3内部机构号
     CUST_ID_TYPE, --4客户证件类型
     CUST_ID_NO, --5客户证件代码
     REG_ADDRESS, --6注册地址
     REG_REGION_CODE, --7客户地区代码
     DEP_ACC_CODE, --8存款账户编码
     DEP_AGR_CODE, --9存款协议代码
     PRODUCT_TYPE, --10存款产品类别
     CON_BGN_DATE, --11存款协议起始日期
     CON_DUE_DATE, --12存款协议到期日期
     CURR_CODE, --13币种
     BALANCE, --14存款余额
     BALANCE_RMB, --  15存款余额折人民币
     INT_RATE, --16利率水平
     DEPOSIT_RESERVE_METHOD, --17缴存准备金方式
     
     --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
     FINI_REGION_CODE,   --金融机构地区代码
     DEP_ACC_TYPE,   --存款账户类型
     DEP_STATUS,   --存款状态
         
     REPORT_ID, --18报送ID
     CJRQ, --19采集日期
     NBJGH, --20内部机构号
     BIZ_LINE_ID, --21业务条线
     VERIFY_STATUS, --22校验状态
     BSCJRQ, --23报送周期
     FRNBJGH,
     CUST_ID,--24
     CUST_NAME)--25

    SELECT /*+ parallel(4)*/
     VS_TEXT DATA_DATE, --1数据日期
     NVL(OB.ID_NO,OB.UP_ID_NO) AS ORG_CODE, --2金融机构代码
     A.ORG_NUM ORG_NUM, --3内部机构号
     

          CASE
       WHEN C.TYSHXYDM IS NOT NULL AND C.TYSHXYDM NOT LIKE '00000%' THEN
        'A01' --统一社会信用证
       WHEN LENGTH(C.ID_NO) = 18 THEN
        'A01'
       WHEN C.ORGANIZATIONCODE IS NOT NULL AND C.ORGANIZATIONCODE <> '0' AND
            C.ORGANIZATIONCODE <> '$' THEN
        'A02' --组织机构代码
       ELSE
        'A03' --其他
     END CUST_ID_TYPE, --4客户证件类型
     CASE
       WHEN C.TYSHXYDM IS NOT NULL AND C.TYSHXYDM NOT LIKE '00000%' THEN
        C.TYSHXYDM --统一社会信用证
       WHEN LENGTH(C.ID_NO) = 18 THEN
        C.ID_NO
       WHEN C.ORGANIZATIONCODE IS NOT NULL AND C.ORGANIZATIONCODE <> '0' AND
            C.ORGANIZATIONCODE <> '$' THEN
        REPLACE(C.ORGANIZATIONCODE, '-', '') --组织机构代码
       ELSE
        SUBSTR(C.ID_NO, 1, 20)
     END,--5客户证件代码
     /*CASE 
       WHEN A.CUST_ID LIKE '2999%' THEN 'A01' -- 2999内部客户号取其归属机构信息
       ELSE D1.PBOCD_CODE 
     END AS CUST_ID_TYPE, --4客户证件类型
     
     CASE
       WHEN A.CUST_ID LIKE '2999%' THEN NVL(OB1.ID_NO,OB1.UP_ID_NO) -- 2999内部客户号取其归属机构信息
       WHEN LENGTH(C.ID_NO) > 20 THEN Double_Byte_conversion(C.ID_NO,60) --按照20个中文字符的极限情况判断
       WHEN D1.PBOCD_CODE = 'A02' THEN REPLACE(C.ID_NO,'-') 
       ELSE C.ID_NO 
     END AS CUST_ID_NO, --5客户证件代码*/
     
     --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 特殊处理内部户和境外户
     REGEXP_REPLACE(REGEXP_REPLACE(CASE WHEN A.CUST_ID LIKE '2999%' THEN OB1.ORG_ADD ELSE C.BORROWER_REGISTER_ADDR END ,'[!?^？！ |]'),CHR(9)) AS REG_ADDRESS, --6注册地址 -- 2999内部客户号取其归属机构信息     
     CASE 
       WHEN A.CUST_ID LIKE '2999%' THEN OB1.REGION_CD  -- 2999内部客户号取其归属机构信息
       WHEN C.NATION_CD <> 'CHN' THEN D2.PBOCD_CODE --外国客户取000+国别阿拉伯数字代码
       ELSE NVL(C.REGION_CD,C.ORG_AREA) END AS REG_REGION_CODE, --7客户地区代码
  
     A.O_ACCT_NUM DEP_ACC_CODE, --8存款账户编码
     
     --[2026-02-10] [周立鹏] [无需求][李楠] 通过存款协议代码区分结算户和协定户
     --A.O_ACCT_NUM DEP_AGR_CODE, --9存款协议编码
     CASE 
       WHEN A.ACCT_TYPE ='0601' THEN '1'
       WHEN A.ACCT_TYPE ='0602' THEN '2'
       ELSE A.O_ACCT_NUM 
     END AS DEP_AGR_CODE, --9存款协议编码
     
     CASE
       WHEN A.ACCT_TYPE = '0601' AND A.GL_ITEM_CODE='20110201' THEN--20220701
        'D051' --结算户存款
       WHEN A.ACCT_TYPE = '0602' AND A.GL_ITEM_CODE='20110201' THEN--20220701
        'D052' --协定户存款
       WHEN A.ACCT_TYPE IN ('0401', '0402') THEN
        'D03' --通知存款
       WHEN A.ACCT_TYPE = '0701' THEN
        'D061' --银行承兑汇票保证金存款
       WHEN A.ACCT_TYPE = '0702' THEN
        'D062' --信用证保证金存款
       WHEN A.ACCT_TYPE IN ('0703') THEN
        'D063' --保函保证金存款
       WHEN (A.ACCT_TYPE like '07%' OR A.GL_ITEM_CODE IN('20110209','20110210')) THEN--20220701
        'D069' --其他保证金存款
       WHEN A.GL_ITEM_CODE IN('20110201','22410101')
--[2025-08-30] [白杨] [JLBA202507210012_关于调整财政性存款及一般性存款相关科目统计方式的相关需求 ] [李楠]财政存款转一般存款 新增 '201103','201104','201105','201106','2008','2009'
       --WHEN B.GL_ITEM_CODE IN ('20110201','22410101') OR SUBSTR(B.GL_ITEM_CODE,1,6) IN('201103','201104','201105','201106') OR    THEN
         OR SUBSTR(A.GL_ITEM_CODE,1,6) IN('201103','201104','201105','201106')
         OR SUBSTR(A.GL_ITEM_CODE,1,4) IN('2008','2009') THEN
        'D011' --单位活期存款
       WHEN A.GL_ITEM_CODE IN ('20110202', '20110203') THEN
        'D012' --单位定期存款
       WHEN A.GL_ITEM_CODE IN ('20110204', '20110211') THEN
        'D04' --协议存款
       WHEN A.GL_ITEM_CODE ='20110207' THEN
        'D08' --结构性存款
  --  需求编号：无需求 修改日期：2025-10-13，修改人：白杨，提出人：李楠   修改内容： D1095国库定期存款 不报,校验报错，所以从程序中注释掉
       /*WHEN A.GL_ITEM_CODE LIKE '201107%' OR A.GL_ITEM_CODE LIKE '2010%' THEN --[2025-05-27] [白杨] [JLBA202504180011_关于吉林银行交易级总账系统调整代理国库业务会计科目及核算规则的需求 ][李楠] 新增科目'2010'
        'D1095' */--国库定期存款
       WHEN A.ACCT_TYPE = '0101' THEN
        'D16' --大额存单存款
     END AS PRODUCT_TYPE, --10存款产品类别

      CASE WHEN (TO_CHAR(A.ST_INT_DT, 'YYYY-MM-DD')='1900-01-01'
        OR A.ST_INT_DT IS NULL)
        THEN
             TO_CHAR(A.ACCT_OPDATE, 'YYYY-MM-DD')
        ELSE TO_CHAR(A.ST_INT_DT, 'YYYY-MM-DD')
     END CON_BGN_DATE, --11存款协议起始日期
     --2023wxb起始日期加判断条件：如果起息日为空取开户日
     CASE

     WHEN A.ACCT_TYPE ='0401' THEN '1999-01-01'
     WHEN A.ACCT_TYPE ='0402' THEN '1999-01-07'--zhoulp20240410 需求JLBA202401240008
     WHEN (A.ACCT_TYPE like '07%' OR A.GL_ITEM_CODE IN('20110209','20110210')) AND NVL(TO_CHAR(A.MATUR_DATE, 'YYYYMMDD'),'99991231') <= IS_DATE THEN
       '9999-12-31'--保证金存款到期未取的，到期日赋值99991231  会有期限跨期，人行同意
     ELSE
     nvl(TO_CHAR(A.MATUR_DATE, 'YYYY-MM-DD'),'9999-12-31')
     END CON_DUE_DATE, --12存款协议到期日期
     A.CURR_CD CURR_CODE, --13币种
     A.ACCT_BALANCE BALANCE, --14存款余额
     A.ACCT_BALANCE * B.CCY_RATE BALANCE_RMB, --15存款余额折人民币
     A.INT_RATE, --16利率水平
     
     --[2025-07-29] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_三阶段][李楠] 文件规则：2005归类到DR02-全额缴存，文件上其他科目归类到DR03-比例缴存
     --NVL(A.RESERVE_DEPO_TYPE, 'DR03') DEPOSIT_RESERVE_METHOD, --17缴存准备金方式
     'DR03' DEPOSIT_RESERVE_METHOD, --缴存准备金方式  按文件处理，2011、224101、2010归类到DR03-比例缴存
     
     --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
     OB.REGION_CD AS FINI_REGION_CODE,   --金融机构地区代码
     E1.PBOCD_CODE AS DEP_ACC_TYPE,   --存款账户类型
     E.PBOCD_CODE AS DEP_STATUS,   --存款状态 DS01-正常 DS02-休眠 DS03-限制 DS04-销户 DS99-其他
     
     SYS_GUID() REPORT_ID, --18报送ID
     IS_DATE CJRQ, --19采集日期
     A.ORG_NUM NBJGH, --20内部机构号
     '99' BIZ_LINE_ID, --21业务条线
     '' VERIFY_STATUS, --22校验状态
     '' BSCJRQ, --23报送周期
     CASE
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
     END FRNBJGH,
     A.CUST_ID, --25客户号
     CASE WHEN A.CUST_ID LIKE '2999%' THEN A.ACCT_NAM ELSE C.CUST_NAM END --26客户名称
      FROM SMTMODS.L_ACCT_DEPOSIT A --存款账户信息表
     LEFT JOIN SMTMODS.L_PUBL_RATE B --汇率表
        ON A.CURR_CD = B.BASIC_CCY --账户币种
       AND B.CCY_DATE = TO_DATE(IS_DATE, 'yyyymmdd') --汇率日期
       AND A.DATA_DATE = B.DATA_DATE
       AND B.FORWARD_CCY = 'CNY' --折算币种
     inner JOIN SMTMODS.L_CUST_C C
        ON A.CUST_ID = C.CUST_ID
       --AND C.CUST_TYP <> '3' --去除个体工商户
       --AND A.DATA_DATE = C.DATA_DATE
       AND C.DATA_DATE = IS_DATE
       
     --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 直取ID_TYPE、ID_NO
     LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY D1
        ON C.ID_TYPE = D1.L_CODE
        AND D1.CODE_CLMN_NAME = 'ID_TYPE' --证件类型
        
     LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY D2
        ON C.NATION_CD = D2.L_CODE
        AND D2.CODE_CLMN_NAME = 'REG_REGION_CODE' --证件类型
     
     --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
     LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E --存款状态
        ON A.ACCT_STS = E.L_CODE
        AND E.CODE_CLMN_NAME = 'ACCT_STS'
     LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E1 --存款账户类型
        ON A.PBOC_ACCT_NATURE_CD/*人行账户属性*/ = E1.L_CODE
        AND E1.CODE_CLMN_NAME = 'ACCT_TYPE'
     
     LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=A.ORG_NUM AND OB.DATA_DATE=IS_DATE
     
     LEFT JOIN L_PUBL_ORG_BRA_TMP OB1--金数机构表
      ON OB1.ORG_NUM=CASE WHEN A.CUST_ID LIKE '2999%' THEN SUBSTR(A.CUST_ID,5) ELSE '#' END AND OB1.DATA_DATE=IS_DATE
      
  -- 需求编号：无需求 修改日期：2025-10-13，修改人：白杨，提出人：李楠   修改内容： D1095国库定期存款 不报,校验报错，去掉 '201107','20110701','2010%'
       WHERE ((A.GL_ITEM_CODE IN ('20110202','20110203','20110204','20110211',/*'201107','20110701',*/'20110207','20110205','20110201','20110208'
            ,'20110209','20110210','22410101') 
--[2025-08-30] [白杨] [JLBA202507210012_关于调整财政性存款及一般性存款相关科目统计方式的相关需求 ] [李楠]财政存款转一般存款 新增 '201103','201104','201105','201106','2008','2009','2010'
            OR SUBSTR(A.GL_ITEM_CODE,1,6) IN('201103','201104','201105','201106')
         OR SUBSTR(A.GL_ITEM_CODE,1,4) IN('2008','2009'/*,'2010'*/) )
            AND C.DEPOSIT_CUSTTYPE NOT IN ('13','14'))--去除个体工商户
             --OR A.GL_ITEM_CODE LIKE '25102%'--保证金
             --2021113保证金去除个体工商户'20110209','20110210'

       AND A.DATA_DATE = IS_DATE
       AND A.ACCT_BALANCE > 0 AND ROUND(A.ACCT_BALANCE * B.CCY_RATE,2) > 0;--金额/折人民币金额是0的不报送
  COMMIT;

  VS_STEP := '2.插入委托资金（净）';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  INSERT INTO PBOCD_DATACORE.PBOCD_JS_202_FTYDWC
    (DATA_DATE, --数据日期
     ORG_CODE, --金融机构代码
     ORG_NUM, --内部机构号
     CUST_ID_TYPE, --客户证件类型
     CUST_ID_NO, --客户证件代码
     REG_ADDRESS, --注册地址
     REG_REGION_CODE, --客户地区代码
     DEP_ACC_CODE, --存款账户编码
     DEP_AGR_CODE, --存款协议代码
     PRODUCT_TYPE, --存款产品类别
     CON_BGN_DATE, --存款协议起始日期
     CON_DUE_DATE, --存款协议到期日期
     CURR_CODE, --币种
     BALANCE, --存款余额
     BALANCE_RMB, --  存款余额折人民币
     INT_RATE, --利率水平
     DEPOSIT_RESERVE_METHOD, --缴存准备金方式
     
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
     FRNBJGH,
     CUST_ID,
     CUST_NAME)
  SELECT  /*+ PARALLEL(4)*/
     VS_TEXT DATA_DATE, --数据日期
     NVL(OB.ID_NO,OB.UP_ID_NO) AS ORG_CODE, --金融机构代码
     T.ORG_NUM ORG_NUM, --内部机构号
     NULL AS CUST_ID_TYPE, --客户证件类型
     NULL AS CUST_ID_NO,
     NULL AS REG_ADDRESS, --注册地址(需要修改)
     NULL AS REG_REGION_CODE, --客户地区代码K(需要修改)
     T.O_ACCT_NUM DEP_ACC_CODE, --存款账户编码
     T.O_ACCT_NUM DEP_AGR_CODE, --存款协议编码
     'D15' AS PRODUCT_TYPE, --存款产品类别

     CASE WHEN (TO_CHAR(T.ST_INT_DT, 'YYYY-MM-DD')='1900-01-01'
       OR T.ST_INT_DT IS NULL)
        THEN
             TO_CHAR(T.ACCT_OPDATE, 'YYYY-MM-DD')
        ELSE TO_CHAR(T.ST_INT_DT, 'YYYY-MM-DD')
     END CON_BGN_DATE, --存款协议起始日期
     --2023wxb起始日期加判断条件：如果起息日为空取开户日
     NVL(TO_CHAR(T.MATUR_DATE, 'YYYY-MM-DD'),'9999-12-31') CON_DUE_DATE, --存款协议到期日期--zhoulp20240410 需求JLBA202401240008
     T.CURR_CD CURR_CODE, --币种
     BALANCE AS BALANCE, --存款余额
     BALANCE AS BALANCE_RMB, --存款余额折人民币
     NULL AS INT_RATE, --利率水平
     
     --[2025-07-29] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_三阶段][李楠] 文件规则：2005归类到DR02-全额缴存，文件上其他科目归类到DR03-比例缴存
     --NVL(T.RESERVE_DEPO_TYPE, 'DR03') DEPOSIT_RESERVE_METHOD, --缴存准备金方式
     'DR03' DEPOSIT_RESERVE_METHOD, --缴存准备金方式  按文件处理，3010、3030归类到DR03-比例缴存
     
     --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
     OB.REGION_CD AS FINI_REGION_CODE,   --金融机构地区代码
     E1.PBOCD_CODE AS DEP_ACC_TYPE,   --存款账户类型
     E.PBOCD_CODE AS DEP_STATUS,   --存款状态 DS01-正常 DS02-休眠 DS03-限制 DS04-销户 DS99-其他
     
     SYS_GUID() REPORT_ID, --报送ID
     IS_DATE CJRQ, --采集日期
     T.ORG_NUM NBJGH, --内部机构号
     '99' BIZ_LINE_ID, --业务条线
     '' VERIFY_STATUS, --校验状态
     '' BSCJRQ, --报送周期
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
     END FRNBJGH,
     T.CUST_ID, --客户号
     NULL AS CUST_NAM --客户名称
  FROM SMTMODS.L_ACCT_DEPOSIT T
  LEFT JOIN (
       SELECT /*+parallel(4)*/

       SUM(CASE WHEN GL.ITEM_CD in ('3020','304002') THEN -GL.DEBIT_BAL  ELSE GL.CREDIT_BAL END) AS BALANCE
        FROM SMTMODS.L_FINA_GL GL
       WHERE GL.DATA_DATE = IS_DATE

   AND GL.ITEM_CD IN ('3010', '3020','303002','304002')
         AND GL.CURR_CD = 'CNY'
         AND GL.ORG_NUM = '990000'
  ) T1 ON 1 = 1 --目前委托资金（净）无法细分，暂时按汇总后一条数据报送，客户信息置空，账号按存款余额最大一笔的账号进行报送
  LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=T.ORG_NUM AND OB.DATA_DATE=IS_DATE
  
  --[2026-01-30] [周立鹏] [JLBA202601150009 关于2026年吉林银行人行大集中及金融基础数据采集系统人行报表制度升级的相关需求][李楠] 新增报送字段
  LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E --存款状态
     ON T.ACCT_STS = E.L_CODE
     AND E.CODE_CLMN_NAME = 'ACCT_STS'
  LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E1 --存款账户类型
        ON T.PBOC_ACCT_NATURE_CD/*人行账户属性*/ = E1.L_CODE
        AND E1.CODE_CLMN_NAME = 'ACCT_TYPE'
        
  WHERE T.O_ACCT_NUM = '7330140601000020_1'
  AND T.DATA_DATE = IS_DATE;
  COMMIT;

/*--插入久悬户
  VS_STEP := '3.插入久悬户';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

  DELETE FROM JS_202_FTYDWC_SMH WHERE CJRQ = IS_DATE;
  COMMIT;

  INSERT INTO JS_202_FTYDWC_SMH
  SELECT \*+parallel(4)*\
  VS_TEXT DATA_DATE,
  --OFF.JRJGBM AS ORG_CODE,
  NVL(OB.ID_NO,OB.UP_ID_NO), --金融机构代码
  AA.ORG_NO ORG_NUM,
    CASE
        WHEN AA.TYSHXYDM IS NOT NULL AND AA.TYSHXYDM NOT LIKE '00000%' THEN
         'A01' --统一社会信用证
        WHEN LENGTH(AA.ID_NO) = 18 THEN
         'A01'
        WHEN AA.ORGANIZATIONCODE IS NOT NULL AND AA.ORGANIZATIONCODE <> '0' AND
             AA.ORGANIZATIONCODE <> '$' THEN
         'A02' --组织机构代码
       ELSE
         'A03' --其他
     END CUST_ID_TYPE, --客户证件类型
     CASE
        WHEN AA.TYSHXYDM IS NOT NULL AND AA.TYSHXYDM NOT LIKE '00000%' THEN
         AA.TYSHXYDM --统一社会信用证
       WHEN LENGTH(AA.ID_NO) = 18 THEN
         AA.ID_NO
        WHEN AA.ORGANIZATIONCODE IS NOT NULL AND AA.ORGANIZATIONCODE <> '0' AND
             AA.ORGANIZATIONCODE <> '$' THEN
         REPLACE(AA.ORGANIZATIONCODE, '-', '') --组织机构代码
       ELSE
         SUBSTR(AA.ID_NO, 1, 20)
      END CUST_ID_NO, --客户证件代码
  CASE WHEN AA.BORROWER_REGISTER_ADDR='无' THEN '' ELSE REGEXP_REPLACE(REGEXP_REPLACE(AA.BORROWER_REGISTER_ADDR,'[!?^？！ |]'),CHR(9)) END REG_ADDRESS, --注册地址
  TRIM(AA.REGION_CD) REG_REGION_CODE, --客户地区代码
  AA.COD_MC_ACCT_NO || '_1' AS DEP_ACC_CODE,
  AA.COD_MC_ACCT_NO || '_1' AS DEP_AGR_CODE,
  CASE WHEN LIAB_ITEM LIKE '201%' THEN 'D011' WHEN  LIAB_ITEM LIKE '251%' THEN 'D069' ELSE  LIAB_ITEM END PRODUCT_TYPE,
  CASE WHEN AA.OPEN_DATE<'1949-10-01' THEN '' ELSE AA.OPEN_DATE END CON_BGN_DATE,
  CASE WHEN AA.MATURE_DATE IS NULL OR (LIAB_ITEM LIKE '251%' AND AA.MATURE_DATE < VS_TEXT) THEN '9999-12-31' ELSE AA.MATURE_DATE END CON_DUE_DATE,
  T1.CCY_CODE CURR_CODE,
  AFTER_EOD_BAL BALANCE,
  AFTER_EOD_BAL * X.CCY_RATE BALANCE_RMB,
  DEP_INT_RATE INT_RATE,
  'DR03' DEPOSIT_RESERVE_METHOD,
  SYS_GUID() REPORT_ID,
  IS_DATE CJRQ,
  AA.ORG_NO NBJGH,
  '99' BIZ_LINE_ID,
  '' VERIFY_STATUS,
  '' BSCJRQ,
  \*CASE WHEN AA.ORG_NO LIKE '5100%' THEN '510000' ELSE '990000' END FRNBJGH,*\
\*  CASE WHEN AA.ORG_NO LIKE '5100%' THEN '510000'
   WHEN AA.ORG_NO LIKE '5200%' THEN '520000'
   WHEN AA.ORG_NO LIKE '5300%' THEN '530000'
   WHEN AA.ORG_NO LIKE '5400%' THEN '540000'
   WHEN AA.ORG_NO LIKE '5500%' THEN '550000'
   WHEN AA.ORG_NO LIKE '5600%' THEN '560000'
   WHEN AA.ORG_NO LIKE '5700%' THEN '570000'
   WHEN AA.ORG_NO LIKE '5800%' THEN '580000'
   WHEN AA.ORG_NO LIKE '5900%' THEN '590000'
   WHEN AA.ORG_NO LIKE '6000%' THEN '600000'
    ELSE '990000' END FRNBJGH,  ---20230620多法人新增*\
     CASE WHEN AA.ORG_NO LIKE '51%' THEN '510000'
   WHEN AA.ORG_NO LIKE '52%' THEN '520000'
   WHEN AA.ORG_NO LIKE '53%' THEN '530000'
   WHEN AA.ORG_NO LIKE '54%' THEN '540000'
   WHEN AA.ORG_NO LIKE '55%' THEN '550000'
   WHEN AA.ORG_NO LIKE '56%' THEN '560000'
   WHEN AA.ORG_NO LIKE '57%' THEN '570000'
   WHEN AA.ORG_NO LIKE '58%' THEN '580000'
   WHEN AA.ORG_NO LIKE '59%' THEN '590000'
   WHEN AA.ORG_NO LIKE '60%' THEN '600000'
    ELSE '990000' END FRNBJGH,  ---20231013王晓彬
  AA.CUST_NO CUST_ID,
  AA.ACCT_NAME CUST_NAME
 FROM (
        SELECT AA.AGMT_NO,AA.COD_MC_ACCT_NO,ORG_NO ,ACCT_NAME,CUST_NO,DM_DATE,DEP_INT_RATE,AFTER_EOD_BAL,MATURE_DATE,OPEN_DATE,
                   CCY_CD,LIAB_ITEM,REGION_CD,BORROWER_REGISTER_ADDR,TYSHXYDM,ORGANIZATIONCODE,ID_NO
       FROM  PBOCD_T_DP_AL_ACCT AA
          INNER JOIN SMTMODS.L_CUST_C C
          ON AA.CUST_NO = C.CUST_ID AND C.DATA_DATE = IS_DATE
        WHERE   AA.DM_DATE = IS_DATE
         AND AA.CCY_CD <> '9999' AND AA.AFTER_EOD_BAL<>0
         AND  \*(
         (
            (AA.LIAB_ITEM IN ('20110202','20110203','20110204','20110211','201107','20110701','20110207','20110205','20110201','20110208'))
            AND C.DEPOSIT_CUSTTYPE NOT IN ('13','14'))--去除个体工商户
             OR AA.LIAB_ITEM IN('20110209','20110210')--保证金
            )*\
           ( (
            (AA.LIAB_ITEM IN ('20110202','20110203','20110204','20110211','201107','20110701','20110207','20110205','20110201','20110208'
            ,'20110209','20110210'))
            AND C.DEPOSIT_CUSTTYPE NOT IN ('13','14'))--去除个体工商户
            --20231117wxb '20110209','20110210'保证金去除个体工商户
            )
   ) AA
   \*LEFT JOIN PBOCD_FCR_MC_ACCT_XREF_ALL Q
     ON AA.COD_MC_ACCT_NO  = Q.COD_MC_ACCT_NO
    AND Q.ODS_DATA_DATE = '20220509'--这个表这个日期不能改，JGJS再往后的日期没数据了，146.1的L_ACCT_DEPOSIT没有久悬户数据*\
   INNER JOIN PBOCD_T_BA_DORMANCY_TABLE T
     ON AA.AGMT_NO = T.COD_ACCT_NO
    AND T.DM_DATE = IS_DATE
  \*LEFT JOIN SYS_OFFICE OFF
  ON  AA.ORG_NO = OFF.ID*\
  LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=AA.ORG_NO AND OB.DATA_DATE=IS_DATE
  LEFT JOIN PBOCD_T_DM_DIM_CCY T1
  ON T1.CCY_NUM=AA.CCY_CD
  INNER JOIN SMTMODS.L_PUBL_RATE X
    ON T1.CCY_CODE = X.BASIC_CCY --账户币种
    AND X.CCY_DATE = TO_DATE(IS_DATE, 'yyyymmdd') --汇率日期
    AND X.DATA_DATE = IS_DATE
    AND X.FORWARD_CCY = 'CNY'; --折算币种
  COMMIT;*/



--[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 代码前移
/*---以下包含原应用层加工逻辑，现都放在加工层处理
  VS_STEP := '4.插入落地表';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
   --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'PBOCD_JS_202_FTYDWC'
     AND PARTITION_NAME = 'PBOCD_JS_202_FTYDWC_' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_DATACORE.PBOCD_JS_202_FTYDWC ADD PARTITION PBOCD_JS_202_FTYDWC_' ||
                      IS_DATE || ' VALUES (' || IS_DATE || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_DATACORE.PBOCD_JS_202_FTYDWC TRUNCATE PARTITION PBOCD_JS_202_FTYDWC_' ||
                    IS_DATE;

 INSERT INTO PBOCD_JS_202_FTYDWC
    ( DATA_DATE,  --数据日期
      ORG_CODE,  --金融机构代码
      ORG_NUM,  --内部机构号
      CUST_ID_TYPE,  --客户证件类型
      CUST_ID_NO,  --客户证件代码
      REG_ADDRESS,  --注册地址
      REG_REGION_CODE,  --客户地区代码
      DEP_ACC_CODE,  --存款账户编码
      DEP_AGR_CODE,  --存款协议代码
      PRODUCT_TYPE,  --存款产品类别
      CON_BGN_DATE,  --存款协议起始日期
      CON_DUE_DATE,  --存款协议到期日期
      CURR_CODE,  --币种
      BALANCE,  --存款余额
      BALANCE_RMB,  --  存款余额折人民币
      INT_RATE,  --利率水平
      DEPOSIT_RESERVE_METHOD,  --缴存准备金方式
      REPORT_ID,  --报送ID
      CJRQ,  --采集日期
      NBJGH,  --内部机构号
      BIZ_LINE_ID,  --业务条线
      VERIFY_STATUS,  --校验状态
      BSCJRQ,  --报送周期
      FRNBJGH,
      CUST_ID,
      CUST_NAME
     )
    SELECT
      VS_TEXT AS DATA_DATE,  --数据日期
      --OFF.JRJGBM AS ORG_CODE,  --金融机构代码
      NVL(OB.ID_NO,OB.UP_ID_NO), --金融机构代码
      A.ORG_NUM,  --内部机构号
      A.CUST_ID_TYPE,  --客户证件类型
      A.CUST_ID_NO,  --客户证件代码
      A.REG_ADDRESS,  --注册地址
      A.REG_REGION_CODE,  --客户地区代码
      A.DEP_ACC_CODE,  --存款账户编码
      A.DEP_AGR_CODE,  --存款协议代码
      A.PRODUCT_TYPE,  --存款产品类别
      A.CON_BGN_DATE,  --存款协议起始日期
      A.CON_DUE_DATE,  --存款协议到期日期
      A.CURR_CODE,  --币种
      A.BALANCE,  --存款余额
      A.BALANCE_RMB,  --  存款余额折人民币
      A.INT_RATE,  --利率水平
      A.DEPOSIT_RESERVE_METHOD,  --缴存准备金方式
      A.REPORT_ID,  --报送ID
      IS_DATE AS CJRQ,  --采集日期
      A.NBJGH,  --内部机构号
      '99' BIZ_LINE_ID,  --业务条线
      '' VERIFY_STATUS,  --校验状态
      '' BSCJRQ,  --报送周期
           CASE
           WHEN A.NBJGH LIKE '51%' THEN
           '510000'
           WHEN A.NBJGH LIKE '52%' THEN
            '520000'
           WHEN A.NBJGH LIKE '53%' THEN
            '530000'
           WHEN A.NBJGH LIKE '54%' THEN
            '540000'
           WHEN A.NBJGH LIKE '55%' THEN
            '550000'
           WHEN A.NBJGH LIKE '56%' THEN
            '560000'
           WHEN A.NBJGH LIKE '57%' THEN
            '570000'
           WHEN A.NBJGH LIKE '58%' THEN
            '580000'
           WHEN A.NBJGH LIKE '59%' THEN
            '590000'
           WHEN A.NBJGH LIKE '60%' THEN
            '600000'----20231013王晓彬
           ELSE '990000'
             END FRNBJGH,

      A.CUST_ID,
      A.CUST_NAME
      FROM PBOCD_DATACORE.PBOCD_JS_202_FTYDWC_TMP A --去掉核销数据
      \*LEFT JOIN SYS_OFFICE OFF
      ON OFF.ID=A.NBJGH*\
      LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=A.NBJGH AND OB.DATA_DATE=IS_DATE
      WHERE A.CJRQ = IS_DATE;
    COMMIT;*/
/*--插入久悬户至落地表
    INSERT INTO PBOCD_JS_202_FTYDWC
      SELECT *
        FROM JS_202_FTYDWC_SMH A
       WHERE A.CJRQ = IS_DATE AND (A.FRNBJGH = '990000' OR (A.FRNBJGH >='520000' AND A.FRNBJGH<='600000'))--经磐石业务人员确认不要久悬户
         AND NOT EXISTS
       (SELECT 1 FROM PBOCD_JS_202_FTYDWC B
               WHERE B.CJRQ = IS_DATE
                 AND A.DEP_ACC_CODE = B.DEP_ACC_CODE);
    COMMIT;*/

  VS_STEP := '5.特殊处理';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  
--[2025-07-29] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_三阶段][李楠] 去掉利率特殊处理
/*--修正利率
    UPDATE PBOCD_JS_202_FTYDWC
       SET INT_RATE = 0.05
     WHERE CJRQ = IS_DATE
       AND PRODUCT_TYPE = 'D011'
       AND CURR_CODE = 'CNY'
       AND (INT_RATE = 0 OR INT_RATE IS NULL);
    COMMIT;*/

/*   UPDATE PBOCD_JS_202_FTYDWC
       SET INT_RATE = 4.5
     WHERE CJRQ = IS_DATE
       AND PRODUCT_TYPE = 'D16'
       AND CURR_CODE = 'CNY'
       AND (INT_RATE = 0 OR INT_RATE IS NULL);
    COMMIT;           */


--[2025-07-29] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_三阶段][李楠] 去掉利率特殊处理
/*    MERGE INTO PBOCD_JS_202_FTYDWC A
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
         AND (A.INT_RATE = 0 OR A.INT_RATE IS NULL);
    COMMIT;*/

    /*UPDATE PBOCD_JS_202_FTYDWC
       SET INT_RATE = INT_RATE * 100
     WHERE CJRQ = IS_DATE
       and int_rate > 0
       AND int_rate <= 0.001;
    COMMIT;*/

--注册地址不允许有“无”的、电话号码的、金额的，含特殊字符的已在加工层处理
    UPDATE PBOCD_JS_202_FTYDWC
       SET REG_ADDRESS = ''
     WHERE CJRQ = IS_DATE
       AND (REG_ADDRESS = '无' OR REGEXP_LIKE(REG_ADDRESS, '^[0-9,.]+$'));
     COMMIT;

--[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 直取ID_TYPE、ID_NO
/*--地区代码
--20251230 辉哥要求暂时保留，等数据治理完成后剔除
MERGE INTO PBOCD_JS_202_FTYDWC A
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
MERGE INTO PBOCD_JS_202_FTYDWC A
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

--[2025-07-29] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_三阶段][李楠] 报送D1095
/*--D1095产品不报送，在此删除
DELETE FROM PBOCD_JS_202_FTYDWC 
  WHERE CJRQ = IS_DATE
  AND PRODUCT_TYPE='D1095';
COMMIT;*/

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
/*--公主岭地区代码
UPDATE PBOCD_JS_202_FTYDWC
   SET REG_REGION_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND REG_REGION_CODE = '220381';
COMMIT;

--地区代码 这户经常是有发生，没存量，刷不到
UPDATE PBOCD_JS_202_FTYDWC
   SET REG_REGION_CODE = '220524'--吉林省通化市柳河县柳河大街2008号
 WHERE CJRQ = IS_DATE
   AND FRNBJGH = '990000'
   AND REG_REGION_CODE IS NULL
   AND DEP_ACC_CODE = '828010188900000275_1';
COMMIT;*/

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
--证件类型、证件代码
/*    UPDATE PBOCD_JS_202_FTYDWC
       SET CUST_ID_NO = '91220204660101640X',
           CUST_ID    = '6000417608',
           CUST_NAME  = '吉林市凯晟金属材料经销有限公司'
     WHERE CJRQ = IS_DATE
       AND DEP_ACC_CODE = '0207011000001961'
       AND CUST_ID_NO = '9122010170255776XN';
    COMMIT;*/


--修改证件代码
 UPDATE PBOCD_JS_202_FTYDWC
     SET CUST_ID_NO = '91220105MA159TBH0E',
         CUST_ID_TYPE='A01'
   WHERE CJRQ = IS_DATE
     AND DEP_ACC_CODE = '0101011000012931_1';
  COMMIT;
  UPDATE PBOCD_JS_202_FTYDWC
     SET CUST_ID_NO = '91220103MA0Y4T80XC',
         CUST_ID_TYPE='A01'
   WHERE CJRQ = IS_DATE
     AND DEP_ACC_CODE = '0110261000000066_1';
  COMMIT;
  UPDATE PBOCD_JS_202_FTYDWC
     SET CUST_ID_NO = '522201823099616519',
         CUST_ID_TYPE='A01'
   WHERE CJRQ = IS_DATE
     AND DEP_ACC_CODE = '0123011000001645_1';
  COMMIT;

--[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 楠姐要求去掉
/*    UPDATE PBOCD_JS_202_FTYDWC A
       SET CUST_ID_NO = '', CUST_ID_TYPE = ''
     WHERE A.CJRQ = IS_DATE
       AND (LENGTH(CUST_ID_NO) <= 3 OR CUST_ID_NO = '000000000');
    COMMIT;*/

--[2025-05-13] [周立鹏] [无需求][李楠] 恢复到原逻辑
--20251230 按辉哥要求保留此逻辑
--原逻辑
UPDATE PBOCD_JS_202_FTYDWC SET CUST_ID_TYPE='A03' WHERE CJRQ=IS_DATE AND CUST_ID_TYPE='A01' AND  (SUBSTR(CUST_ID_NO,1,2) NOT IN ('11','12','13','19','21','29','31','32','33','34','35','39','41','49','51','52','53','59','61','62','69','71','72','79','81','89','91','92','93','A1','A9','N1','N2','N3','N9','Y1')
OR NOT REGEXP_LIKE(SUBSTR(CUST_ID_NO,3,6),'^[0-9]+$')
OR SUBSTR(CUST_ID_NO,3,2) NOT IN ('10','11','12','13','14','15','21','22','23','31','32','33','34','35','36','37','41','42','43','44','45','46','50','51','52','53','54','61','62','63','64','65')
OR NOT REGEXP_LIKE(SUBSTR(CUST_ID_NO,9,9),'^[0-9A-Z,_]+$') --  不是数字、大写英文字母和下划线
OR NOT REGEXP_LIKE(SUBSTR(CUST_ID_NO,-1,1),'^[0-9A-Z]+$')--不是数字和大写英文字母
OR SUBSTR(CUST_ID_NO,-1,1)   IN ('I','O','Z','S','V')
);
    COMMIT;
--新逻辑
/*UPDATE PBOCD_JS_202_FTYDWC SET CUST_ID_TYPE='A03' WHERE CJRQ=IS_DATE AND CUST_ID_TYPE='A01' AND  (SUBSTR(CUST_ID_NO,1,2) NOT IN ('11','12','13','19','21','29','31','32','33','34','35','39','41','49','51','52','53','54','55','59','61','62','69','71','72','79','81','89','91','92','93','A1','A9','N1','N2','N3','N9','Y1')
OR NOT REGEXP_LIKE(SUBSTR(CUST_ID_NO,3,6),'^[0-9]+$')
OR SUBSTR(CUST_ID_NO,3,2) NOT IN ('10','11','12','13','14','15','21','22','23','31','32','33','34','35','36','37','41','42','43','44','45','46','50','51','52','53','54','61','62','63','64','65','99')
OR NOT REGEXP_LIKE(SUBSTR(CUST_ID_NO,9,10),'^[0-9A-Z]+$') --  不是数字、大写英文字母和下划线
--OR NOT REGEXP_LIKE(SUBSTR(CUST_ID_NO,-1,1),'^[0-9A-Z]+$')--不是数字和大写英文字母
OR SUBSTR(CUST_ID_NO,-1,1)   IN ('I','O','Z','S','V')
);*/


/*--存款协议到期日期触发_硬校验-存款协议到期日期非空且不是默认值时，应大于等于数据日期
--只有非同业存款的存量，D012产品，协议到期日期往后推一年，其他都不动
UPDATE PBOCD_JS_202_FTYDWC
   SET CON_DUE_DATE = CASE
                        WHEN SUBSTR(CON_DUE_DATE, 6, 5) <
                             SUBSTR(DATA_DATE, 6, 5) THEN
                         CONCAT(SUBSTR(TO_CHAR(ADD_MONTHS(TO_DATE(DATA_DATE,
                                                                  'yyyy-mm-dd'),
                                                          12),
                                               'yyyy-mm-dd'),
                                       1,
                                       5),
                                SUBSTR(CON_DUE_DATE, 6, 5))
                        ELSE
                         CONCAT(SUBSTR(DATA_DATE, 1, 5),
                                SUBSTR(CON_DUE_DATE, 6, 5))
                      END
 WHERE CJRQ = IS_DATE
   AND CON_DUE_DATE < VS_TEXT
   AND CON_DUE_DATE IS NOT NULL
   AND CON_DUE_DATE NOT IN ('9999-12-31', '1999-01-07', '1999-01-01')
   AND PRODUCT_TYPE = 'D012';
COMMIT;
*/


--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
--证件号码是空的，客户号都是一些内部号，按上期刷一下证件类型、证件代码、户名
MERGE INTO PBOCD_JS_202_FTYDWC A
USING (SELECT *
         FROM PBOCD_JS_202_FTYDWC_SQ A
        WHERE A.CJRQ = VS_LAST_TEXT
         -- AND A.FRNBJGH = '990000'
          ) B
ON (A.DEP_ACC_CODE = B.DEP_ACC_CODE)
WHEN MATCHED THEN
  UPDATE
     SET A.CUST_ID_TYPE = B.CUST_ID_TYPE,
         A.CUST_ID_NO   = B.CUST_ID_NO
         --A.CUST_NAME    = B.CUST_NAM
   WHERE A.CJRQ = IS_DATE
     --AND A.FRNBJGH = '990000'
     AND A.CUST_ID_NO IS NULL;
COMMIT;

--[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 直取ID_TYPE、ID_NO
/*--内部户户名穿透的同时，对应的地区代码和地址也穿透一下
--20251230 辉哥要求保留
MERGE INTO PBOCD_JS_202_FTYDWC A
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
