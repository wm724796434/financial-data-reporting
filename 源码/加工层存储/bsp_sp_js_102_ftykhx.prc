CREATE OR REPLACE PROCEDURE BSP_SP_JS_102_FTYKHX(IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  --    SP_JS_102_FTYKHX
  --用途:生成接口表 JS_102_FTYKHX  非同业单位客户信息
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    CAEATE BY USER AT 20200819
  --    MOD BY LIUD AT 20200824
  --    MOD BY DW AT 20230427 修改单位客户统一社会信用码取数规则，优先获取集市数据，补录表次之
  --    MOD BY DW AT 20231027 修改单位客户证件代码、实际控制人证件代码字段取数口径，优先获取L层证件代码，不再从L社会统一信用码字段取数
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段 上线日期：2025-04-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  --    需求编号：无需求 上线日期：2025-05-13，修改人：周立鹏，提出人：李楠   修改原因：恢复到原逻辑
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段 上线日期：2025-05-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  --    需求编号：JLBA202505120009_关于修改金数系统与大集中系统单一客户授信逻辑的需求 上线日期：2025-05-27，修改人：周立鹏，提出人：李楠   修改原因：金数和大集中统一授信额度
  --    需求编号：无需求 上线日期：2025-06-05，修改人：周立鹏，提出人：李楠   修改原因：为避免一个客户多个客户号导致关联不上的情况，改为用证件号码关联
  --    需求编号：JLBA202504160004_关于吉林银行修改单一客户授信逻辑的需求(从需求) 上线日期：2025-07-08，修改人：周立鹏，提出人：   修改原因：统一授信额度
  --    需求编号：JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段 上线日期：2025-12-30，修改人：周立鹏，提出人：李楠   修改原因：剔除特殊处理
  --    需求编号：JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段 上线日期：2026-01-27，修改人：周立鹏，提出人：李楠   修改原因：剔除特殊处理
  --    需求编号：JLBA202604230002_关于修改金融基础数据系统部分逻辑的需求 上线日期：2026-04-29，修改人：周立鹏，提出人：李楠   修改原因：营业收入等4个字段剔除取上期
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT      VARCHAR2(1000) DEFAULT NULL; --字符型  过程描述
  VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
  NUM               INTEGER;
  VS_NMONTH         VARCHAR2(10);
BEGIN
  VS_TEXT := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'),-1), 'YYYYMMDD');

  VS_NMONTH         := TO_CHAR(TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD') + 1),
                               'YYYYMMDD');

  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_102_FTYKHX';

  --开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------

  --历史移植数据
  EXECUTE IMMEDIATE 'TRUNCATE TABLE  JS_102_FTYKHX_TEMP01';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE  JS_102_FTYKHX_TEMP02';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE  JS_102_FTYKHX_TEMP03';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE  JS_102_FTYKHX_TEMP04';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE  JS_102_FTYKHX_TEMP05';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE  JS_102_FTYKHX_TEMP08';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE  JS_102_FTYKHX_TEMP09';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE  CUST_REPEAT_TEMP';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE FTY_SJKZR_01';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE FTY_SJKZR_02';

  --获取首次贷款信息
  INSERT INTO JS_102_FTYKHX_TEMP01
  SELECT /*+parallel(4)*/  T.CUST_ID,
         TO_CHAR(MIN(T.DRAWDOWN_DT), 'YYYY-MM-DD'),
         SUM(T.LOAN_ACCT_BAL),
         SUM(DRAWDOWN_AMT)
  FROM SMTMODS.L_ACCT_LOAN T
  WHERE T.DATA_DATE = IS_DATE
       --AND T.ITEM_CD NOT LIKE '406%'
       AND T.ITEM_CD NOT LIKE '301%'
       AND T.ITEM_CD NOT LIKE '302%'
       AND T.ITEM_CD NOT LIKE '303%'
       AND T.ITEM_CD NOT LIKE '304%'---20220629-夏文博改
  GROUP BY T.CUST_ID;

  COMMIT;


  --[2025-05-27] [周立鹏] [JLBA202505120009_关于修改金数系统与大集中系统单一客户授信逻辑的需求][李楠] 此逻辑会剔除客户下部分借据已核销的客户，经与李楠确认后重写此逻辑
  --历史移植及核销数据
  INSERT INTO /*+ APPEND*/ JS_102_FTYKHX_TEMP03 NOLOGGING (
     CUST_ID
  )
  SELECT DISTINCT A.CUST_ID FROM L_ACCT_LOAN_LSYL_LSYL A
  UNION
  SELECT DISTINCT A.CUST_ID
    FROM SMTMODS.L_ACCT_LOAN A
   WHERE A.DATA_DATE = IS_DATE
     AND (A.CANCEL_FLG = 'Y' OR A.LOAN_STOCKEN_DATE IS NOT NULL) --资产核销或已转让
     AND NOT EXISTS
   (SELECT * FROM SMTMODS.L_ACCT_LOAN B
      WHERE B.DATA_DATE = IS_DATE
        AND (B.CANCEL_FLG = 'N' AND B.LOAN_STOCKEN_DATE IS NULL) --资产未核销未转让
        AND A.CUST_ID = B.CUST_ID);
             
  COMMIT;


  --限制客户取数范围为贷款
  INSERT INTO JS_102_FTYKHX_TEMP04
  SELECT /*+parallel(4)*/  T.CUST_ID, COUNT(1),TO_CHAR(MIN(CONTRACT_EFF_DT),'YYYY-MM-DD') RQ
  from SMTMODS.L_AGRE_LOAN_CONTRACT t
  WHERE DATA_DATE = is_date
  and DATE_SOURCESD in ('贸易融资','普通贷款','委托贷款')
  and (t.acct_typ not like '90' or t.acct_typ is null)
  GROUP BY t.CUST_ID
  ;
  COMMIT;

  --限制客户取数范围为贷款 --保理
  INSERT INTO JS_102_FTYKHX_TEMP04
  SELECT /*+parallel(4)*/  T.CUST_ID, COUNT(1),TO_CHAR(MIN(CONTRACT_EFF_DT),'YYYY-MM-DD') RQ
  from SMTMODS.L_AGRE_LOAN_CONTRACT t
  inner join (select * from SMTMODS.L_ACCT_LOAN T where t.data_date = IS_DATE
       --zhoulp20260105 加入当月放款当月收回的数据
       AND (T.LOAN_ACCT_BAL > 0 OR TRUNC(T.DRAWDOWN_DT, 'MM') = TRUNC(to_date(IS_DATE, 'yyyymmdd'), 'MM'))
     AND (T.ITEM_CD LIKE '1303%' OR T.ITEM_CD LIKE '1305%'
   )
   AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产转让日期
       AND T.CANCEL_FLG = 'N')a ON a.ACCT_NUM = T.CONTRACT_NUM
  WHERE T.DATA_DATE = is_date
  and T.DATE_SOURCESD ='保理'
  and (t.acct_typ not like '90' or t.acct_typ is null)
  AND NOT EXISTS(
  SELECT 1 FROM JS_102_FTYKHX_TEMP04 B WHERE T.CUST_ID=B.CUST_ID
  )
  GROUP BY t.CUST_ID
  ;
  COMMIT;
  
  --限制客户取数范围为贷款 --垫款  20240926_ZHOULP_JLBA202406280007_新增1306垫款科目
  INSERT INTO JS_102_FTYKHX_TEMP04
  SELECT /*+parallel(4)*/  T.CUST_ID, COUNT(1),TO_CHAR(MIN(CONTRACT_EFF_DT),'YYYY-MM-DD') RQ
  from SMTMODS.L_AGRE_LOAN_CONTRACT t
  inner join (select * from SMTMODS.L_ACCT_LOAN T where t.data_date = IS_DATE
     AND T.ITEM_CD LIKE '1306%' AND T.CANCEL_FLG = 'N'
   AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产转让日期
   )a ON a.ACCT_NUM = T.CONTRACT_NUM
  WHERE T.DATA_DATE = is_date
  AND NOT EXISTS(
  SELECT 1 FROM JS_102_FTYKHX_TEMP04 B WHERE T.CUST_ID=B.CUST_ID
  )
  GROUP BY t.CUST_ID
  ;
  COMMIT;


  --获取汇总后的贷款合同金额和贷款余额
  INSERT INTO PBOCD_DATACORE.JS_102_FTYKHX_TEMP05
  SELECT /*+parallel(4)*/  LC.CUST_ID,
         LC.CONTRACT_AMT,
         NVL(AL.LOAN_ACCT_BAL,0)
  FROM JS_102_FTYKHX_TEMP04 T
  INNER JOIN (
       SELECT CUST_ID,
              SUM(CONTRACT_AMT) AS CONTRACT_AMT--合同金额
       FROM (
            SELECT A.CUST_ID,
                   CASE WHEN A.CURR_CD = 'CNY' THEN A.CONTRACT_AMT ELSE A.CONTRACT_AMT * T1.CCY_RATE END AS CONTRACT_AMT --合同金额
            FROM (
                 SELECT CUST_ID,
                        CONTRACT_AMT,
                        CURR_CD
                 FROM SMTMODS.L_AGRE_LOAN_CONTRACT --贷款合同信息表
                 WHERE DATA_DATE = IS_DATE
            )A --剔除委托业务
            LEFT JOIN SMTMODS.L_PUBL_RATE T1
            ON A.CURR_CD = T1.BASIC_CCY
            AND T1.FORWARD_CCY = 'CNY'
            AND T1.DATA_DATE = IS_DATE
       ) GROUP BY CUST_ID
  )LC
  ON T.CUST_ID=LC.CUST_ID
  LEFT JOIN (
       SELECT CUST_ID,SUM(LOAN_ACCT_BAL) AS LOAN_ACCT_BAL--贷款余额
       FROM (
            SELECT A.CUST_ID,
               CASE
                 WHEN A.CURR_CD = 'CNY' THEN A.LOAN_ACCT_BAL
                   ELSE A.LOAN_ACCT_BAL * T1.CCY_RATE
               END AS LOAN_ACCT_BAL
            FROM(
               SELECT CUST_ID,LOAN_ACCT_BAL,CURR_CD
               FROM SMTMODS.L_ACCT_LOAN --贷款借据信息表
               WHERE DATA_DATE = IS_DATE
               AND ACCT_TYP NOT LIKE '90%'
            )A --剔除委托业务
            LEFT JOIN SMTMODS.L_PUBL_RATE T1
            ON A.CURR_CD = T1.BASIC_CCY
            AND T1.FORWARD_CCY = 'CNY'
            AND T1.DATA_DATE = IS_DATE
       ) GROUP BY CUST_ID
  )AL
  ON LC.CUST_ID = AL.CUST_ID;
  COMMIT;

  --获取一个客户多个客户号，关联业务信息，用于过滤掉没有业务的（确认逻辑是否需要修改dw20220731)
  INSERT INTO CUST_REPEAT_TEMP
  SELECT /*+parallel(4)*/  B.CUST_ID_NO, B.CUST_ID, B.CUST_NAME, D.CUST_ID, D.BAL
  FROM JS_102_FTYKHX B --上期客户信息
  INNER JOIN (
        SELECT A.CUST_ID_NO, COUNT(*) CT
        FROM PBOCD_JS_102_FTYKHX_SQ A
        WHERE TRIM(A.DATA_DATE) = VS_LAST_TEXT
        GROUP BY A.CUST_ID_NO
        HAVING COUNT(*) > 1
  ) C
  ON B.CUST_ID_NO = C.CUST_ID_NO
  LEFT JOIN (
       SELECT T.CUST_ID, SUM(T.LOAN_ACCT_BAL) BAL
       FROM SMTMODS.L_ACCT_LOAN T
       WHERE T.DATA_DATE =IS_DATE
       AND T.CANCEL_FLG='N'
     AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产转让日期
       AND T.LOAN_ACCT_BAL > 0
       --AND (T.ITEM_CD LIKE '122%' OR T.ITEM_CD LIKE '132%')
       AND (T.ITEM_CD LIKE '1303%' OR T.ITEM_CD LIKE '1305%')---20220629-夏文博改
       GROUP BY T.CUST_ID
  ) D
  ON B.CUST_ID = D.CUST_ID
  WHERE TRIM(B.DATA_DATE) = VS_LAST_TEXT
  ;
  COMMIT;

  --标记没有业务的重复客户
  UPDATE CUST_REPEAT_TEMP T
  SET T.CUST_ID_1 = 'N'
  WHERE T.CUST_ID_NO IN(
        SELECT T1.CUST_ID_NO
        FROM CUST_REPEAT_TEMP T1
        WHERE T1.BAL IS NOT NULL)
  AND T.BAL IS NULL;
  COMMIT;

  --获取实际控制人证件类型、代码，因为是列表形式，后期不好验证证件代码合规性，所以先处理
  --实际控制人证件类型、证件代码应符合规范
  INSERT INTO FTY_SJKZR_01
   SELECT CUST_ID,
                     CASE WHEN F.P_ID_TYPE = 'X04' AND LENGTH(ID_NO) = 18
                                       AND (DATE_FLG(SUBSTR(ID_NO,7,8)) = 0
                                       OR SUBSTR(ID_NO,7,8) NOT BETWEEN '19000101' AND IS_DATE) THEN 'A01'
                                  WHEN F.P_ID_TYPE = 'X04' AND LENGTH(ID_NO) = 18 THEN 'B01'
                                  WHEN F.P_ID_TYPE = 'X04' AND LENGTH(REPLACE(ID_NO,'-','')) = 9 THEN 'A02'
                                  WHEN F.P_ID_TYPE = 'X04' THEN 'A03'
                             ELSE M1.PBOCD_CODE END P_ID_TYPE,
                     REPLACE(ID_NO,'-','') ID_NO
                FROM SMTMODS.L_CUST_R_SENIORMANAGER F
              LEFT JOIN L_CODE_DICTIONARY M1
                ON TRIM(F.P_ID_TYPE) = M1.L_CODE
                AND M1.CODE_CLMN_NAME ='ID_TYPE2' --实际控制人证件类型--2022.1.10  夏文博添加
               WHERE F.DATA_DATE = IS_DATE
                 AND F.RALATION_TYP = '0' AND P_ID_TYPE IS NOT NULL AND ID_NO IS NOT NULL
                 AND ID_NO <> '无';
  COMMIT;

  --实际控制人证件类型、证件代码应符合规范
  UPDATE FTY_SJKZR_01 A SET ID_NO = UPPER(ID_NO) WHERE P_ID_TYPE = 'A01';
  COMMIT;

--[2025-05-13] [周立鹏] [无需求][李楠] 恢复到原逻辑
--原逻辑
  UPDATE FTY_SJKZR_01 SET P_ID_TYPE='A03' WHERE P_ID_TYPE='A01'
  AND  (SUBSTR(ID_NO,1,2) NOT IN ('11','12','13','19','21','29','31','32','33','34','35','39','41','49','51','52','53','59','61','62','69','71','72','79','81','89','91','92','93','A1','A9','N1','N2','N3','N9','Y1')
  OR NOT REGEXP_LIKE(SUBSTR(ID_NO,3,6),'^[0-9]+$')
  OR SUBSTR(ID_NO,3,2) NOT IN ('10','11','12','13','14','15','21','22','23','31','32','33','34','35','36','37','41','42','43','44','45','46','50','51','52','53','54','61','62','63','64','65')
  OR NOT REGEXP_LIKE(SUBSTR(ID_NO,9,9),'^[0-9A-Z,_]+$') --  不是数字、大写英文字母和下划线
  OR NOT REGEXP_LIKE(SUBSTR(ID_NO,-1,1),'^[0-9A-Z]+$')--不是数字和大写英文字母
  OR SUBSTR(ID_NO,-1,1)   IN ('I','O','Z','S','V')
  );

  COMMIT;

  UPDATE FTY_SJKZR_01
     SET P_ID_TYPE = 'B99'
   WHERE P_ID_TYPE IN ('B01', 'B08')
     AND LENGTH(ID_NO) <> 18;
  COMMIT;
  --合并实际控制人证件类型、证件
  INSERT INTO FTY_SJKZR_02
    SELECT CUST_ID,
           LISTAGG(P_ID_TYPE, ',') P_ID_TYPE,
           LISTAGG(ID_NO, ',') ID_NO
      FROM FTY_SJKZR_01 F
     GROUP BY F.CUST_ID;
  COMMIT;

  --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
  WHERE TABLE_NAME = 'JS_102_FTYKHX'
  AND PARTITION_NAME = 'P' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE JS_102_FTYKHX ADD PARTITION P' ||
                      IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE JS_102_FTYKHX TRUNCATE PARTITION P' ||
                    IS_DATE;

  --落地表，包含吉林银行+磐石数据
  INSERT /*+ APPEND*/ INTO JS_102_FTYKHX NOLOGGING
    (DATA_DATE, --1数据日期
     ORG_CODE, --2金融机构代码
     CUST_NAME, --3客户名称
     CUST_ID_NO, --4客户证件代码
     BASIC_ACCOUNT, --5基本存款账号
     BASIC_ACCOUNT_BANK, --6基本账户开户行名称
     CAPITAL_AMT, --7注册资本
     PAICL_UP_CAP, --8实收资本
     TOTAL_ASSET, --9总资产
     OPERATE_INCOME, --10营业收入
     LIST_FLG, --11是否上市公司
     FIRST_CREDIT_DATA, --12首次建立信贷关系日期
     STAFF_NUM, --13从业人员数
     REG_ADDRESS, --14注册地
     REG_REGION_CODE, --15注册地行政区划代码
     BUSI_STATUS, --16经营状态
     OPEN_DATE, --17成立日期
     INDUSTRY_TYPE, --18所属行业
     ENT_SCALE, --19企业规模
     FACILITY_AMT, --20授信额度
     USED_FACILITY_AMT, --21已用额度
     RELATED_FLG, --22是否关联方
     ACTR_CTRL_ID_TYPE, --23实际控制人证件类型
     ACTR_CTRL_ID_NO, --24实际控制人证件代码
     CUST_ID_TYPE, --25客户证件类型
     BUSI_SCOPE, --26经营范围
     CTRL_ECO_ELEM, --27客户经济成分
     DEPT_TYPE, --28客戶国民经济部门
     CREDIT_RATE_NUM, --29客户信用等级总等级数
     CREDIT_RATING, --30客户信用评级
     BIZ_LINE_ID, --31 业务条线
     CUST_ID, --32 客户号
     NBJGH, --33 内部机构号
     HOSTINGMANAGER, --34主办客户经理
     HOSTINGMANAGER_NAME, --35主办客户经理名称
     HOSTINGMANAGER_APP --36主办客户经理条线
  )
  SELECT /*+parallel(4)*/
           IS_DATE DATA_DATE, --1数据日期
           '' ORG_CODE, --2金融机构代码
           T.CUST_NAM CUST_NAME, --3客户名称

           CASE WHEN T.PBOCD_CODE = 'A02' THEN REPLACE(T.ID_NO,'-') ELSE T.ID_NO END AS CUST_ID_NO, --4客户证件代码

           T.BASE_ACCT BASIC_ACCOUNT, --5基本存款账号
           T.BASE_ACCT_OP_NAME BASIC_ACCOUNT_BANK, --6基本账户开户行名称
           T.CAPITAL_AMT , --7注册资本
           T.PAICL_UP_CAPITAL PAICL_UP_CAP, --8实收资本
           T.TOTAL_ASSET , --9总资产
           T.MAIN_BUSI_INCOME OPERATE_INCOME, --10营业收入
           DECODE(UPPER(T.STOCK_FLG),'Y','1','N','0') LIST_FLG, --11是否上市公司
           --NVL(TO_CHAR(TO_DATE(T.FIRST_CREDIT_DATE,'YYYY-MM-DD'),'YYYY-MM-DD') ,NVL(T.CONTRACT_EFF_DT,HT.RQ)), --12首次建立信贷关系日期
           NVL(TO_CHAR(T.FIRST_CREDIT_DATE,'YYYY-MM-DD') ,NVL(T.CONTRACT_EFF_DT,HT.RQ)) FIRST_CREDIT_DATA, --12首次建立信贷关系日期
           CASE WHEN TO_CHAR(STAFF_NUM) IN (0,1) THEN '' ELSE TO_CHAR(STAFF_NUM) END AS STAFF_NUM, --13从业人员数
           REGEXP_REPLACE(REGEXP_REPLACE(T.REG_ADDRESS,'[!?^？！ |]'),CHR(9)), --14注册地
           NVL(REPLACE(T.REGION_CD,'待治理',''),T.ORG_AREA) REG_REGION_CODE, --15注册地行政区划代码
           T.OPER_TYPE BUSI_STATUS, --16经营状态
           TO_CHAR(BORROWER_BULID_YEAR,'YYYY-MM-DD') OPEN_DATE, --17成立日期
           
           SUBSTRB(TRIM(T.CORP_BUSINSESS_TYPE), 0, 3) INDUSTRY_TYPE, --18所属行业
           
           CASE WHEN SUBSTR(T.CUST_TYP,1,1) IN ('0','1') OR T.CUST_TYP = '9101' THEN
             CASE WHEN T.CORP_SCALE = 'B' THEN 'CS01'
                       WHEN T.CORP_SCALE = 'M' THEN 'CS02'
                       WHEN T.CORP_SCALE = 'S' THEN 'CS03'
                       WHEN T.CORP_SCALE = 'T' THEN 'CS04'
             ELSE 'CS05' END
           ELSE 'CS05' END ENT_SCALE, --19企业规模
           
           --[2025-07-08] [周立鹏] [JLBA202504160004_关于吉林银行修改单一客户授信逻辑的需求(从需求)][] 统一授信额度
           NVL(T1.FACILITY_AMT,0) ,--20授信额度
           NVL(T1.USED_FACILITY_AMT,0),--21已用额度
           
     --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
     --NVL(CASE WHEN GLF.CUST_NAME IS NOT NULL THEN '1' ELSE '0' END ,CASE WHEN T.RELATED_TYP IS NOT NULL THEN '1' ELSE '0' END) RELATED_FLG , --22是否关联方
           CASE WHEN T.RELATED_TYP IS NOT NULL THEN '1' ELSE '0' END AS RELATED_FLG , --22是否关联方
           T.P_ID_TYPE ACTR_CTRL_ID_TYPE, --23实际控制人证件类型
           T.ACTR_CTRL_ID_NO, --24实际控制人证件号码

           T.PBOCD_CODE AS CUST_ID_TYPE, --25证件类型

           REGEXP_REPLACE(REGEXP_REPLACE(NVL(SUBSTR(T.BORROWER_PRODUCT_DESC,1,300),NVL(SUBSTR(TRIM(T.BORROWER_PRODUCT_DESC),1,300), M2.PARAM_NAME)),'[!?^？！ |]'),CHR(9)) BUSI_SCOPE, --26经营范围

           DECODE(T.CORP_HOLD_TYPE,'A01','A0102',
                                   'A02','A0101',
                                   'B01','A0202',
                                   'B02','A0201',
                                   'C01','B0102',
                                   'C02','B0101',
                                   'D01','B0202',
                                   'D02','B0201',
                                   'E01','B0302',
                                   'E02','B0301'
           )  CTRL_ECO_ELEM,  --27客户经济成分*/
           CASE WHEN T.CUST_TYP <>'5' THEN T.DEPT_TYPE ELSE 'A04' END DEPT_TYPE,--28客戶国民经济部门--
           T.CREDIT_RANK_TYPE CREDIT_RATE_NUM , --29客户信用等级总等级数
           CASE WHEN T.CREDIT_RANK LIKE '0%' THEN SUBSTR(TO_CHAR(T.CREDIT_RANK) , 2) ELSE TO_CHAR(T.CREDIT_RANK) END AS CREDIT_RATING, --30客户信用评级
           '' BIZ_LINE_ID, --31  业务条线
           T.CUST_ID, --32 客户号
           T.ORG_NUM NBJGH, --33 内部机构号
           ''HOSTINGMANAGER, --34主办客户经理
           ''HOSTINGMANAGER_NAME, --35主办客户经理名称
           ''HOSTINGMANAGER_APP --36主办客户经理条线
       FROM (
            SELECT T.*,
            
                   --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
                   D1.PBOCD_CODE,
                   MIN( T1.CONTRACT_EFF_DT )OVER(PARTITION BY T.CUST_ID) CONTRACT_EFF_DT,
                   T1.FKJE,
                   --ID_TYPE_TYPE,
                   F.P_ID_TYPE,
                   CASE WHEN T.RELATED_TYP IS NOT NULL THEN '1' ELSE '0' END AS RELATED_FLG,
                   F.ID_NO AS ACTR_CTRL_ID_NO,
                   T.BORROWER_REGISTER_ADDR AS REG_ADDRESS
            FROM L_CUST_C_TMP T
            
            --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
            LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY D1
            ON NVL(T.LEGAL_CARD_TYPE, T.ID_TYPE) = D1.L_CODE
            AND D1.CODE_CLMN_NAME = 'ID_TYPE' --证件类型
            
            LEFT JOIN JS_102_FTYKHX_TEMP01 T1 --获取首次贷款信息
            ON T.CUST_ID = T1.CUST_ID
            LEFT JOIN JS_102_FTYKHX_MAPPING M --客户信息补录表
            ON T.CUST_ID = M.COD_CUST_ID

            LEFT JOIN FTY_SJKZR_02 F
            ON T.CUST_ID = F.CUST_ID
            WHERE T.DATA_DATE = IS_DATE
            AND T.CUST_ID NOT IN(SELECT CUST_ID FROM CUST_ID_REPEAT) --刨除的重复客户，手工维护表
            AND T.CUST_ID NOT IN(SELECT CUST_ID FROM CUST_REPEAT_TEMP WHERE CUST_ID_1 = 'N')
            AND T.CUST_TYP <>'3'
            --[2025-05-27] [周立鹏] [JLBA202505120009_关于修改金数系统与大集中系统单一客户授信逻辑的需求][李楠] 剔除无效客户
            AND T.CUSTSTATUS = '01'
       ) T
       LEFT JOIN (
          SELECT T.CUST_ID,SUM(T.FACILITY_AMT) FACILITY_AMT,SUM(T.USED_FACILITY_AMT) USED_FACILITY_AMT FROM SMTMODS.L_AGRE_CREDITLINE T
              WHERE T.DATA_DATE = IS_DATE AND T.FACILITY_STS = 'Y' GROUP BY T.CUST_ID
          ) T1 --授信信息
       ON T.CUST_ID = T1.CUST_ID

       LEFT JOIN JS_102_FTYKHX_TEMP03 T3 --历史移植及核销数据
       ON T.CUST_ID = T3.CUST_ID

       LEFT JOIN M_EAST_META_FIELD_SCOPE M2
       ON SUBSTRB(TRIM(T.CORP_BUSINSESS_TYPE), 0, 3) = M2.PARAM_CODE
       AND M2.PARAM_TYPE = 'C0012'
       INNER JOIN JS_102_FTYKHX_TEMP04 HT --客户取数范围限制为贷款
       ON T.CUST_ID = HT.CUST_ID
       LEFT JOIN JS_102_FTYKHX_MAPPING M3 --客户信息补录表
       ON T.CUST_ID = M3.COD_CUST_ID
       WHERE (T3.CUST_ID IS NULL OR T.CUST_ID IN( '8000692376','8911498167'))
  ;
  COMMIT;


  --获取客户最后一笔贷款发放时间
  INSERT INTO JS_102_FTYKHX_TEMP08 NOLOGGING
  SELECT /*+ USE_HASH(A,B) parallel(4)*/ A.CUST_ID,MAX(B.DRAWDOWN_DT)
  FROM JS_102_FTYKHX A
  LEFT JOIN SMTMODS.L_ACCT_LOAN B
  ON A.CUST_ID = B.CUST_ID
  AND B.DATA_DATE = IS_DATE
  AND B.DEPARTMENTD IN ('公司金融','普惠金融')
  WHERE TRIM(A.DATA_DATE) = IS_DATE
  GROUP BY A.CUST_ID;
  COMMIT;


  --获取客户最后一笔贷款业务条线
  INSERT INTO JS_102_FTYKHX_TEMP09 NOLOGGING
  SELECT /*+parallel(4)*/ DISTINCT A.CUST_ID,
              CASE WHEN B.DEPARTMENTD= '公司金融' THEN 'E'
                   WHEN B.DEPARTMENTD= '普惠金融' THEN 'S'
                   WHEN B.DEPARTMENTD= '个人信贷' THEN 'P'
                  -- WHEN B.DEPARTMENTD= '磐石村镇' THEN 'V'
                   WHEN B.DEPARTMENTD= '德惠长银' THEN 'E' END
  FROM JS_102_FTYKHX_TEMP08 A
  LEFT JOIN SMTMODS.L_ACCT_LOAN B
  ON A.CUST_ID = B.CUST_ID
  AND A.DRAWDOWN_DT = B.DRAWDOWN_DT
  AND B.DATA_DATE = IS_DATE
  AND B.DEPARTMENTD IN ('公司金融','普惠金融')
  ;
  COMMIT;

  --把同一个客户多个客户号的按同一个证件号汇总授信额度
  INSERT INTO JS_102_FTYKHX_TEMP02
  SELECT /*+parallel(4)*/  T.CUST_ID_NO,
           SUM(T.FACILITY_AMT),
           SUM(T.USED_FACILITY_AMT),

           CASE WHEN T.NBJGH LIKE '51%' THEN '51'
             WHEN T.NBJGH LIKE '52%' THEN '52'
             WHEN T.NBJGH LIKE '53%' THEN '53'
             WHEN T.NBJGH LIKE '54%' THEN '54'
             WHEN T.NBJGH LIKE '55%' THEN '55'
             WHEN T.NBJGH LIKE '56%' THEN '56'
             WHEN T.NBJGH LIKE '57%' THEN '57'
             WHEN T.NBJGH LIKE '58%' THEN '58'
             WHEN T.NBJGH LIKE '59%' THEN '59'
             WHEN T.NBJGH LIKE '60%' THEN '60'----20230620多法人新增
              ELSE '99' END--区分总行和磐石，避免丢客户
  FROM JS_102_FTYKHX T
  WHERE TRIM(T.DATA_DATE) = IS_DATE
  AND T.CUST_ID_NO IS NOT NULL

  GROUP BY T.CUST_ID_NO,CASE WHEN T.NBJGH LIKE '51%' THEN '51'
             WHEN T.NBJGH LIKE '52%' THEN '52'
             WHEN T.NBJGH LIKE '53%' THEN '53'
             WHEN T.NBJGH LIKE '54%' THEN '54'
             WHEN T.NBJGH LIKE '55%' THEN '55'
             WHEN T.NBJGH LIKE '56%' THEN '56'
             WHEN T.NBJGH LIKE '57%' THEN '57'
             WHEN T.NBJGH LIKE '58%' THEN '58'
             WHEN T.NBJGH LIKE '59%' THEN '59'
             WHEN T.NBJGH LIKE '60%' THEN '60'----20230620多法人新增
  ELSE '99' END;
  COMMIT;
  -------------------吉林银行目标表数据--------------------
  SP_PBOCD_PARTITIONS(IS_DATE,'PBOCD_JS_102_FTYKHX_TMP',OI_RETCODE);
  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_102_FTYKHX_TMP TRUNCATE PARTITION P' ||
                    IS_DATE;
  INSERT /*+ APPEND*/ INTO PBOCD_JS_102_FTYKHX_TMP/*@PBOCD_34*/ NOLOGGING
    (DATA_DATE, --1数据日期
     ORG_CODE, --2金融机构代码
     CUST_NAME, --3客户名称
     CUST_ID_NO, --4客户证件代码
     BASIC_ACCOUNT, --5基本存款账号
     BASIC_ACCOUNT_BANK, --6基本账户开户行名称
     CAPITAL_AMT, --7注册资本
     PAICL_UP_CAP, --8实收资本
     TOTAL_ASSET, --9总资产
     OPERATE_INCOME, --10营业收入
     LIST_FLG, --11是否上市公司
     FIRST_CREDIT_DATA, --12首次建立信贷关系日期
     STAFF_NUM, --13从业人员数
     REG_ADDRESS, --14注册地
     REG_REGION_CODE, --15注册地行政区划代码
     BUSI_STATUS, --16经营状态
     OPEN_DATE, --17成立日期
     INDUSTRY_TYPE, --18所属行业
     ENT_SCALE, --19企业规模
     FACILITY_AMT, --20授信额度
     USED_FACILITY_AMT, --21已用额度
     RELATED_FLG, --22是否关联方
     ACTR_CTRL_ID_TYPE, --23实际控制人证件类型
     ACTR_CTRL_ID_NO, --24实际控制人证件代码
     CUST_ID_TYPE, --25客户证件类型
     BUSI_SCOPE, --26经营范围
     CTRL_ECO_ELEM, --27客户经济成分
     DEPT_TYPE, --28客戶国民经济部门
     CREDIT_RATE_NUM, --29客户信用等级总等级数
     CREDIT_RATING, --30客户信用评级
     REPORT_ID, --31 业务条线
     CJRQ, --32 采集日期
     NBJGH, --33 内部机构号
     BIZ_LINE_ID, --34 业务条线
     VERIFY_STATUS, --35
     BSCJRQ, --36
     FRNBJGH ,--37 法人内部机构号
     ORG_NUM,
     CUST_ID
  )
  SELECT /*+parallel(4)*/  DATA_DATE, --1数据日期
     ORG_CODE, --2金融机构代码
     CUST_NAME, --3客户名称
     CUST_ID_NO, --4客户证件代码
     BASIC_ACCOUNT, --5基本存款账号
     BASIC_ACCOUNT_BANK, --6基本账户开户行名称
     CAPITAL_AMT, --7注册资本
     PAICL_UP_CAP, --8实收资本
     TOTAL_ASSET, --9总资产
     OPERATE_INCOME, --10营业收入
     LIST_FLG, --11是否上市公司
     FIRST_CREDIT_DATA, --12首次建立信贷关系日期
     STAFF_NUM, --13从业人员数
     REG_ADDRESS, --14注册地
     REG_REGION_CODE, --15注册地行政区划代码
     BUSI_STATUS, --16经营状态
     OPEN_DATE, --17成立日期
     INDUSTRY_TYPE, --18所属行业
     ENT_SCALE, --19企业规模
     FACILITY_AMT, --20授信额度
     USED_FACILITY_AMT, --21已用额度
     RELATED_FLG, --22是否关联方
     ACTR_CTRL_ID_TYPE, --23实际控制人证件类型
     ACTR_CTRL_ID_NO, --24实际控制人证件代码
     CUST_ID_TYPE, --25客户证件类型
     BUSI_SCOPE, --26经营范围
     CTRL_ECO_ELEM, --27客户经济成分
     DEPT_TYPE, --28客戶国民经济部门
     CREDIT_RATE_NUM, --29客户信用等级总等级数
     CREDIT_RATING, --30客户信用评级
     REPORT_ID, --31业务条线
     CJRQ, --32 采集日期
     NBJGH, --33 内部机构号
     BIZ_LINE_ID, --34
     VERIFY_STATUS, --35
     BSCJRQ, --36
     FRNBJGH, --37 法人内部机构号
     NBJGH,
     CUST_ID
  FROM (
       SELECT
           VS_TEXT DATA_DATE, --1数据日期
           T.ORG_CODE ORG_CODE, --2金融机构代码
           T.CUST_NAME CUST_NAME, --3客户名称
           T.CUST_ID_NO  CUST_ID_NO, --4客户证件代码
           CASE WHEN T.BASIC_ACCOUNT_BANK IS NULL THEN '' ELSE T.BASIC_ACCOUNT END BASIC_ACCOUNT, --5基本存款账号
           CASE WHEN T.BASIC_ACCOUNT IS NULL THEN '' ELSE T.BASIC_ACCOUNT_BANK END BASIC_ACCOUNT_BANK, --6基本账户开户行名称
           T.CAPITAL_AMT CAPITAL_AMT, --7注册资本
           T.PAICL_UP_CAP PAICL_UP_CAP, --8实收资本
           CASE WHEN  T.TOTAL_ASSET = 0 THEN NULL ELSE T.TOTAL_ASSET END TOTAL_ASSET, --9总资产
           CASE WHEN  T.OPERATE_INCOME = 0 THEN NULL ELSE T.OPERATE_INCOME END OPERATE_INCOME, --10营业收入
           T.LIST_FLG LIST_FLG, --11是否上市公司
           T.FIRST_CREDIT_DATA  FIRST_CREDIT_DATA, --12首次建立信贷关系日期
           T.STAFF_NUM STAFF_NUM, --13从业人员数

           T.REG_ADDRESS, --14注册地

           T.REG_REGION_CODE AS REG_REGION_CODE, --15注册地行政区划代码
           
           NVL(T.BUSI_STATUS ,'01') BUSI_STATUS, --16经营状态
           
           CASE WHEN T.OPEN_DATE < NVL(T.FIRST_CREDIT_DATA,'9999-12-31')THEN T.OPEN_DATE ELSE SUBSTRB(T.FIRST_CREDIT_DATA, 1, 5) || '01-01' END OPEN_DATE, --17成立日期
           
           T.INDUSTRY_TYPE, --18所属行业
           T.ENT_SCALE , --19企业规模
           NVL(T2.FACILITY_AMT,0) FACILITY_AMT, --20授信额度
           --NVL(T.FACILITY_AMT,0) FACILITY_AMT, --20授信额度
           NVL(T2.UNDRAW_FACILITY_AMT,0) USED_FACILITY_AMT ,--21已用额度
           --NVL(T.USED_FACILITY_AMT,0) USED_FACILITY_AMT ,--21已用额度
           T.RELATED_FLG RELATED_FLG, --22是否关联方
           T.ACTR_CTRL_ID_TYPE  ACTR_CTRL_ID_TYPE, --23实际控制人证件类型
           T.ACTR_CTRL_ID_NO ACTR_CTRL_ID_NO, --24实际控制人证件代码
           
           --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 直取ECIF的ID_TYPE、ID_NO
           --CASE WHEN  LENGTHB( T.CUST_ID_NO) =18 THEN 'A01' ELSE T.CUST_ID_TYPE END CUST_ID_TYPE,   --25客户证件类型
           T.CUST_ID_TYPE,   --25客户证件类型
               
           REPLACE(SUBSTRB(REPLACE(REPLACE(REPLACE(T.BUSI_SCOPE,',','，'),'|',''),'^',''),1,1000),'?','') BUSI_SCOPE, --26经营范围
           --CASE WHEN T.ENT_SCALE ='CS05' OR  T.CTRL_ECO_ELEM='CS05' THEN '' ELSE T.CTRL_ECO_ELEM END CTRL_ECO_ELEM , --27客户经济成分
           T.CTRL_ECO_ELEM, --27客户经济成分
           --NVL(T.DEPT_TYPE,T1.DEPT_TYPE) DEPT_TYPE,--NVL(T1.DEPT_TYPE, T.DEPT_TYPE), --28客戶国民经济部门
           T.DEPT_TYPE,--28客戶国民经济部门
           T.CREDIT_RATE_NUM CREDIT_RATE_NUM, --29客户信用等级总等级数
           T.CREDIT_RATING CREDIT_RATING, --30客户信用评级
           SYS_GUID() REPORT_ID, --31 业务条线
           IS_DATE CJRQ, --32 采集日期
           T.NBJGH , --33 内部机构号
           CASE WHEN T.NBJGH LIKE '51%' THEN '99'
            WHEN T.NBJGH LIKE '52%' THEN '99'
            WHEN T.NBJGH LIKE '53%' THEN '99'
            WHEN T.NBJGH LIKE '54%' THEN '99'
            WHEN T.NBJGH LIKE '55%' THEN '99'
            WHEN T.NBJGH LIKE '56%' THEN '99'
            WHEN T.NBJGH LIKE '57%' THEN '99'
            WHEN T.NBJGH LIKE '58%' THEN '99'
            WHEN T.NBJGH LIKE '59%' THEN '99'
            WHEN T.NBJGH LIKE '60%' THEN '99'
             ELSE NVL(T9.DATASOURCE,'99') END AS BIZ_LINE_ID, --34----20230620多法人新增

           '' VERIFY_STATUS, --35
           '' BSCJRQ, --36

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
              '600000'----20230620多法人新增
             ELSE '990000' END FRNBJGH, --37 法人内部机构号
           T.CUST_ID,

           ROW_NUMBER()
             OVER (PARTITION BY T.CUST_ID_NO,
            (CASE WHEN T.NBJGH LIKE '51%' THEN '51'
             WHEN T.NBJGH LIKE '52%' THEN '52'
             WHEN T.NBJGH LIKE '53%' THEN '53'
             WHEN T.NBJGH LIKE '54%' THEN '54'
             WHEN T.NBJGH LIKE '55%' THEN '55'
             WHEN T.NBJGH LIKE '56%' THEN '56'
             WHEN T.NBJGH LIKE '57%' THEN '57'
             WHEN T.NBJGH LIKE '58%' THEN '58'
             WHEN T.NBJGH LIKE '59%' THEN '59'
             WHEN T.NBJGH LIKE '60%' THEN '60'----20230620多法人新增
             ELSE '99' END)
                     ORDER BY T.CUST_ID DESC) RN
       FROM JS_102_FTYKHX T
       LEFT JOIN JS_102_FTYKHX_TEMP02 T2  --把同一个客户多个客户号的按同一个证件号汇总授信额度
       ON T.CUST_ID_NO = T2.CUST_ID_NO

       AND (CASE WHEN T.NBJGH LIKE '51%' THEN '51'
             WHEN T.NBJGH LIKE '52%' THEN '52'
             WHEN T.NBJGH LIKE '53%' THEN '53'
             WHEN T.NBJGH LIKE '54%' THEN '54'
             WHEN T.NBJGH LIKE '55%' THEN '55'
             WHEN T.NBJGH LIKE '56%' THEN '56'
             WHEN T.NBJGH LIKE '57%' THEN '57'
             WHEN T.NBJGH LIKE '58%' THEN '58'
             WHEN T.NBJGH LIKE '59%' THEN '59'
             WHEN T.NBJGH LIKE '60%' THEN '60'----20230620多法人新增
       ELSE '99' END) = T2.ORG_FLG--区分总行和磐石，避免丢客户
       LEFT JOIN JS_102_FTYKHX_TEMP09 T9 --客户最后一笔贷款业务条线
       ON T.CUST_ID = T9.CUST_ID
       WHERE  T.DATA_DATE = IS_DATE
       AND (NVL(T.CUST_ID_NO,0) NOT LIKE'L%')
       AND (NVL(T.CUST_ID_NO,0) NOT LIKE'X%')

  )
  WHERE RN = 1;
  COMMIT;
---------------------------------------------------------------------------
--应用层逻辑
  EXECUTE IMMEDIATE 'TRUNCATE TABLE PBOCD_JS_102_FTYKHX_TMP01';

  INSERT INTO PBOCD_JS_102_FTYKHX_TMP01
    (DATA_DATE, --1数据日期
     ORG_CODE, --2金融机构代码
     CUST_NAME, --3客户名称
     CUST_ID_NO, --4客户证件代码
     BASIC_ACCOUNT, --5基本存款账号
     BASIC_ACCOUNT_BANK, --6基本账户开户行名称
     CAPITAL_AMT, --7注册资本
     PAICL_UP_CAP, --8实收资本
     TOTAL_ASSET, --9总资产
     OPERATE_INCOME, --10营业收入
     LIST_FLG, --11是否上市公司
     FIRST_CREDIT_DATA, --12首次建立信贷关系日期
     STAFF_NUM, --13从业人员数
     REG_ADDRESS, --14注册地
     REG_REGION_CODE, --15注册地行政区划代码
     BUSI_STATUS, --16经营状态
     OPEN_DATE, --17成立日期
     INDUSTRY_TYPE, --18所属行业
     ENT_SCALE, --19企业规模
     FACILITY_AMT, --20授信额度
     USED_FACILITY_AMT, --21已用额度
     RELATED_FLG, --22是否关联方
     ACTR_CTRL_ID_TYPE, --23实际控制人证件类型
     ACTR_CTRL_ID_NO, --24实际控制人证件代码
     CUST_ID_TYPE, --25客户证件类型
     BUSI_SCOPE, --26经营范围
     CTRL_ECO_ELEM, --27客户经济成分
     DEPT_TYPE, --28客戶国民经济部门
     CREDIT_RATE_NUM, --29客户信用等级总等级数
     CREDIT_RATING, --30客户信用评级
     REPORT_ID, --31 业务条线
     CJRQ, --32 采集日期
     NBJGH, --33 内部机构号
     BIZ_LINE_ID, --34 业务条线
     VERIFY_STATUS, --35 校验状态
     BSCJRQ, --36
     FRNBJGH ,--37 法人内部机构号
     ORG_NUM, --38内部机构号
     CUST_ID  --39客户号
  )
   SELECT
     VS_TEXT AS DATA_DATE, --1数据日期

           CASE WHEN T.FRNBJGH = '510000' THEN '912202016601010854'
             WHEN T.FRNBJGH = '520000' THEN '91321000564261222Q'
             WHEN T.FRNBJGH = '530000' THEN '91220201584622304Y'
             WHEN T.FRNBJGH = '540000' THEN '91220101586213344F'
             WHEN T.FRNBJGH = '550000' THEN '911309005881693407'
             WHEN T.FRNBJGH = '560000' THEN '91131000589668889D'
             WHEN T.FRNBJGH = '570000' THEN '91222404584629733N'
             WHEN T.FRNBJGH = '580000' THEN '912203005846084148'
             WHEN T.FRNBJGH = '590000' THEN '91220421660100250Y'
             WHEN T.FRNBJGH = '600000' THEN '912202015846358186' ----20230620多法人新增
             ELSE '9122010170255776XN' END AS ORG_CODE,--金融机构代码

     T.CUST_NAME AS CUST_NAME, --3客户名称

     T.CUST_ID_NO, --4客户证件代码

     CASE WHEN T.BASIC_ACCOUNT_BANK IS NULL THEN '' ELSE T.BASIC_ACCOUNT END BASIC_ACCOUNT, --5基本存款账号
     CASE WHEN T.BASIC_ACCOUNT IS NULL THEN  '' ELSE T.BASIC_ACCOUNT_BANK END BASIC_ACCOUNT_BANK, --6基本账户开户行名称
     --[2026-04-29] [周立鹏] [JLBA202604230002_关于修改金融基础数据系统部分逻辑的需求][李楠] 营业收入等4个字段剔除取上期
     /*CASE WHEN NVL(T1.CAPITAL_AMT,T.CAPITAL_AMT) = 0 THEN NULL ELSE NVL(T1.CAPITAL_AMT,T.CAPITAL_AMT) END CAPITAL_AMT, --7注册资本
     CASE WHEN NVL(T1.PAICL_UP_CAP,T.PAICL_UP_CAP) = 0 THEN NULL ELSE NVL(T1.PAICL_UP_CAP,T.PAICL_UP_CAP) END PAICL_UP_CAP, --8实收资本
     CASE WHEN NVL(T1.TOTAL_ASSET,T.TOTAL_ASSET) = 0 THEN NULL ELSE NVL(T1.TOTAL_ASSET,T.TOTAL_ASSET) END TOTAL_ASSET, --9总资产
     CASE WHEN NVL(T1.OPERATE_INCOME,T.OPERATE_INCOME) = 0 THEN NULL ELSE NVL(T1.OPERATE_INCOME,T.OPERATE_INCOME) END OPERATE_INCOME, --10营业收入*/
     CASE WHEN T.CAPITAL_AMT = 0 THEN NULL ELSE T.CAPITAL_AMT END CAPITAL_AMT, --7注册资本
     CASE WHEN T.PAICL_UP_CAP = 0 THEN NULL ELSE T.PAICL_UP_CAP END PAICL_UP_CAP, --8实收资本
     CASE WHEN T.TOTAL_ASSET = 0 THEN NULL ELSE T.TOTAL_ASSET END TOTAL_ASSET, --9总资产
     CASE WHEN T.OPERATE_INCOME = 0 THEN NULL ELSE T.OPERATE_INCOME END OPERATE_INCOME, --10营业收入

     T.LIST_FLG AS LIST_FLG, --11是否上市公司

     T.FIRST_CREDIT_DATA AS FIRST_CREDIT_DATA, --12首次建立信贷关系日期

     T.STAFF_NUM, --13从业人员数
     
     NVL(T.REG_ADDRESS, T1.REG_ADDRESS)REG_ADDRESS, --14注册地

     T.REG_REGION_CODE AS REG_REGION_CODE, --15注册地行政区划代码

     T.BUSI_STATUS , --16经营状态

     T.OPEN_DATE AS OPEN_DATE, --17成立日期

     T.INDUSTRY_TYPE AS INDUSTRY_TYPE , --18所属行业
     
     T.ENT_SCALE , --19企业规模

     T.FACILITY_AMT, --20授信额度
     T.USED_FACILITY_AMT ,--21已用额度

     T.RELATED_FLG AS RELATED_FLG, --22是否关联方
   
     CASE WHEN T.ACTR_CTRL_ID_NO IS NULL THEN NULL ELSE T.ACTR_CTRL_ID_TYPE END AS ACTR_CTRL_ID_TYPE, --23实际控制人证件类型
     CASE WHEN T.ACTR_CTRL_ID_TYPE IS NULL THEN NULL ELSE T.ACTR_CTRL_ID_NO END AS ACTR_CTRL_ID_NO, --24实际控制人证件代码

     T.CUST_ID_TYPE ,   --25客户证件类型

     REPLACE(SUBSTRB(REPLACE(REPLACE(REPLACE(T.BUSI_SCOPE,',', '，'),'|', ''),'^',''),1,1000),'?','') BUSI_SCOPE, --26经营范围
     

     NVL(T.CTRL_ECO_ELEM,T1.CTRL_ECO_ELEM) CTRL_ECO_ELEM, --27客户经济成分
     
     NVL(T.DEPT_TYPE,T1.DEPT_TYPE) AS DEPT_TYPE,--NVL(T1.DEPT_TYPE, T.DEPT_TYPE), --28客戶国民经济部门

     T.CREDIT_RATE_NUM AS CREDIT_RATE_NUM, --29客户信用等级总等级数
     T.CREDIT_RATING AS CREDIT_RATING, --30客户信用评级
     
     SYS_GUID() AS REPORT_ID, --31 业务条线
     IS_DATE AS CJRQ, --32 采集日期
     T.NBJGH , --33 内部机构号
     T.BIZ_LINE_ID, --34 业务条线
     '' VERIFY_STATUS, --35 校验状态
     '' BSCJRQ, --36 报送采集日期
     T.FRNBJGH, --37 法人内部机构号
     T.ORG_NUM,  --38内部机构号
     T.CUST_ID --39客户号
  FROM  PBOCD_JS_102_FTYKHX_TMP T  --本期加工层数据
  LEFT JOIN PBOCD_JS_102_FTYKHX_SQ T1  --上期报送数据
  ON T.CUST_ID_NO = T1.CUST_ID_NO
  AND T1.CJRQ = VS_LAST_TEXT
  WHERE  T.CJRQ = IS_DATE;
  COMMIT;

  SP_PBOCD_PARTITIONS(IS_DATE,'PBOCD_JS_102_FTYKHX',OI_RETCODE);
  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_102_FTYKHX TRUNCATE PARTITION P' ||
                    IS_DATE;
--去重
INSERT INTO PBOCD_JS_102_FTYKHX
  SELECT VS_TEXT DATA_DATE,
         ORG_CODE,
         CUST_NAME,
         CUST_ID_NO,
         BASIC_ACCOUNT,
         BASIC_ACCOUNT_BANK,
         CAPITAL_AMT,
         PAICL_UP_CAP,
         TOTAL_ASSET,
         OPERATE_INCOME,
         LIST_FLG,
         FIRST_CREDIT_DATA,
         STAFF_NUM,
         REG_ADDRESS,
         REG_REGION_CODE,
         BUSI_STATUS,
         OPEN_DATE,
         INDUSTRY_TYPE,
         ENT_SCALE,
         FACILITY_AMT,
         USED_FACILITY_AMT,
         RELATED_FLG,
         ACTR_CTRL_ID_TYPE,
         ACTR_CTRL_ID_NO,
         CUST_ID_TYPE,
         BUSI_SCOPE,
         CTRL_ECO_ELEM,
         DEPT_TYPE,
         CREDIT_RATE_NUM,
         CREDIT_RATING,
         SYS_GUID() REPORT_ID,
         IS_DATE CJRQ,
         NBJGH,
         BIZ_LINE_ID,
         '' VERIFY_STATUS,
         '' BSCJRQ,
         FRNBJGH,
         ORG_NUM,
         CUST_ID
    FROM (SELECT A.*,
                 ROW_NUMBER() OVER(PARTITION BY CUST_ID_TYPE, CUST_ID_NO,FRNBJGH ORDER BY CUST_ID) RN
            FROM PBOCD_JS_102_FTYKHX_TMP01 A
           WHERE A.CJRQ = IS_DATE) A
   WHERE A.RN = 1;
-----------------------------------------------------------------------------------------------------

  --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 这三段对经营状态的操作保留
  --每年一月，判断上一年末经营状态是04当年关闭 05当年破产 06当年注销 07当年吊销 事，将本期经营状态置为停业（歇业）
  IF (SUBSTR(IS_DATE,5,2) = '01') THEN
    UPDATE PBOCD_JS_102_FTYKHX A
       SET A.BUSI_STATUS = '02'
     WHERE A.CJRQ = IS_DATE
       AND A.CUST_ID_NO IN
           (SELECT B.CUST_ID_NO
              FROM PBOCD_JS_102_FTYKHX_SQ B
             WHERE B.CJRQ = VS_LAST_TEXT
               AND B.BUSI_STATUS IN ('04', '05', '06', '07')); --01正常运营 02停业（歇业） 03筹建 04当年关闭 05当年破产 06当年注销 07当年吊销 99其他
    COMMIT;
  END IF;
  --改成02后，以后每期都改成02
    UPDATE PBOCD_JS_102_FTYKHX A SET A.BUSI_STATUS = '02' WHERE A.CJRQ = IS_DATE AND A.BUSI_STATUS IN('04','05','06','07') AND A.CUST_ID_NO IN(
           SELECT B.CUST_ID_NO FROM PBOCD_JS_102_FTYKHX_SQ B WHERE B.CJRQ = VS_LAST_TEXT AND B.BUSI_STATUS ='02'); --01正常运营 02停业（歇业） 03筹建 04当年关闭 05当年破产 06当年注销 07当年吊销 99其他
    COMMIT;

  --经营状态99的置空，然后空值的按上期刷一下
    UPDATE PBOCD_JS_102_FTYKHX SET BUSI_STATUS=''
    WHERE CJRQ =IS_DATE AND BUSI_STATUS='99';
    COMMIT;

--WXY 修改 校验问题
DELETE FROM PBOCD_JS_102_FTYKHX A
  WHERE CJRQ =IS_DATE
  AND CUST_ID IN (SELECT CUST_ID FROM FTY_DEL WHERE CUST_ID IS NOT NULL ); --手工维护表
  COMMIT;

--20251125数据暂未治理，不可切 --SELECT DEPT_TYPE,A.* FROM PBOCD_JS_102_FTYKHX_SQ A WHERE  cust_id='6000851766';  无贷款业务 ，不涉及存量和发生
UPDATE PBOCD_JS_102_FTYKHX SET ENT_SCALE='CS01',DEPT_TYPE='C01',CTRL_ECO_ELEM='A0101'
WHERE CJRQ =IS_DATE AND CUST_NAME = '吉林市歌舞团';
COMMIT;


MERGE INTO PBOCD_JS_102_FTYKHX A
USING (SELECT *
         FROM PBOCD_JS_102_FTYKHX_SQ
        WHERE CJRQ = VS_LAST_TEXT
          AND BUSI_STATUS IS NOT NULL AND FRNBJGH='990000') B
ON (A.CUST_ID_NO = B.CUST_ID_NO)
WHEN MATCHED THEN
  UPDATE
     SET A.BUSI_STATUS = B.BUSI_STATUS
   WHERE A.CJRQ = IS_DATE
     AND A.BUSI_STATUS IS NULL AND A.FRNBJGH='990000';
COMMIT;

--[2026-04-29] [周立鹏] [JLBA202604230002_关于修改金融基础数据系统部分逻辑的需求][李楠] 营业收入等4个字段剔除取上期
/*--注册资本/实收资本/营业收入/资产/从业人员，按上期刷
MERGE INTO PBOCD_JS_102_FTYKHX A
USING (SELECT * FROM PBOCD_JS_102_FTYKHX_SQ WHERE CJRQ = VS_LAST_TEXT AND FRNBJGH='990000') B
ON (A.CUST_ID_NO = B.CUST_ID_NO)
WHEN MATCHED THEN
  UPDATE
     SET A.CAPITAL_AMT    = B.CAPITAL_AMT,
         A.PAICL_UP_CAP   = B.PAICL_UP_CAP,
         A.TOTAL_ASSET    = B.TOTAL_ASSET,
         A.OPERATE_INCOME = B.OPERATE_INCOME
         --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
         --A.STAFF_NUM      = B.STAFF_NUM
   WHERE A.CJRQ = IS_DATE AND A.FRNBJGH='990000';
COMMIT;*/

--注册地址是电话号、问号、无、空、纯数字等，按上期刷
MERGE INTO PBOCD_JS_102_FTYKHX A
USING (SELECT *
         FROM PBOCD_JS_102_FTYKHX_SQ
        WHERE CJRQ = VS_LAST_TEXT
          AND FRNBJGH = '990000') B
ON (A.CUST_ID_NO = B.CUST_ID_NO)
WHEN MATCHED THEN
  UPDATE
     SET A.REG_ADDRESS = B.REG_ADDRESS
   WHERE A.CJRQ = IS_DATE
     AND A.FRNBJGH = '990000'
     AND (REG_ADDRESS IS NULL OR REG_ADDRESS = '无' OR
         REG_ADDRESS LIKE '%?%' OR REG_ADDRESS LIKE '%？%' OR
         REGEXP_LIKE(REG_ADDRESS, '^[0-9,.]+$'))
     AND REG_ADDRESS <> '11';
COMMIT;

--客户国民经济部门需在符合要求的值域范围内且不能为个人和金融机构
MERGE INTO PBOCD_JS_102_FTYKHX A
USING (SELECT *
         FROM PBOCD_JS_102_FTYKHX_SQ A
        WHERE CJRQ = VS_LAST_TEXT
          AND A.FRNBJGH = '990000') B
ON (A.CUST_ID_NO = B.CUST_ID_NO)
WHEN MATCHED THEN
  UPDATE
     SET A.DEPT_TYPE = B.DEPT_TYPE
   WHERE A.CJRQ = IS_DATE
     AND A.FRNBJGH = '990000'
     AND (SUBSTR(A.DEPT_TYPE, 1, 1) IN ('B', 'D') OR A.DEPT_TYPE IS NULL);
COMMIT;

UPDATE PBOCD_JS_102_FTYKHX A
   SET A.DEPT_TYPE = 'C01' --经业务确认，有限公司的国民经济部门都是C01
 WHERE A.CJRQ = IS_DATE
   AND A.FRNBJGH = '990000'
   AND (SUBSTR(A.DEPT_TYPE, 1, 1) IN ('B', 'D') OR A.DEPT_TYPE IS NULL)
   AND (CUST_NAME LIKE '%有限责任公司' OR CUST_NAME LIKE '%有限公司');
COMMIT;

--企业规模为CS01-大型至CS04-微型的，客户国民经济部门应该为C开头的非金融企业部门或者B开头的金融机构
UPDATE PBOCD_JS_102_FTYKHX A
   SET A.DEPT_TYPE = 'C01' --经业务确认，有限公司的国民经济部门都是C01
 WHERE CJRQ = IS_DATE
   AND FRNBJGH = '990000'
   AND ENT_SCALE IN ('CS01', 'CS02', 'CS03', 'CS04')
   AND SUBSTR(DEPT_TYPE, 1, 1) NOT IN ('B', 'C')
   AND (CUST_NAME LIKE '%有限责任公司' OR CUST_NAME LIKE '%有限公司');
COMMIT;

--客户国民经济部门为C开头且不是C99的非金融企业部门，则企业规模应该在CS01至CS04范围内
--刷完之后应该还有下面按人行要求将企业规模置空的49笔报错
MERGE INTO PBOCD_JS_102_FTYKHX A
USING (SELECT *
         FROM PBOCD_JS_102_FTYKHX_SQ B
        WHERE CJRQ = VS_LAST_TEXT
          AND B.FRNBJGH = '990000') B
ON (A.CUST_ID_NO = B.CUST_ID_NO)
WHEN MATCHED THEN
  UPDATE
     SET A.DEPT_TYPE = B.DEPT_TYPE, A.ENT_SCALE = B.ENT_SCALE
   WHERE A.CJRQ = IS_DATE
     AND A.FRNBJGH = '990000'
     AND A.DEPT_TYPE LIKE 'C%'
     AND A.DEPT_TYPE <> 'C99'
     AND (A.ENT_SCALE NOT IN ('CS01', 'CS02', 'CS03', 'CS04') OR
         A.ENT_SCALE IS NULL);
COMMIT;

--改户名是因为校验报错，需要报送总公司；没有对应着改证件号码因为报过的客户要一直报
UPDATE PBOCD_JS_102_FTYKHX A
   SET A.CUST_NAME =
       (SELECT B.CUST_NAME_NEW
          FROM JS_102_FTYKHX_MAPPING1 B
         WHERE A.CUST_NAME = B.CUST_NAME)
 WHERE A.CJRQ = IS_DATE
   AND EXISTS (SELECT B.CUST_NAME_NEW
          FROM JS_102_FTYKHX_MAPPING1 B
         WHERE A.CUST_NAME = B.CUST_NAME);
COMMIT;

--这49笔按人行要求将企业规模置空，历史户  不涉及存量和发生
UPDATE PBOCD_JS_102_FTYKHX A
   SET ENT_SCALE = ''
 WHERE A.CJRQ = IS_DATE
   AND FRNBJGH = '990000'
   AND CUST_ID_NO IN ('91230900684875333M',
                      '91230900728941612P',
                      '92220302MA1548KY2J',
                      '92220303L29027832Q',
                      '244682589',
                      '605430011',
                      '697750775',
                      '944701488',
                      '944715185',
                      '93220181683377332L',
                      '91220102743027546T',
                      '912201055711269937',
                      '9122010469775600X8',
                      '91220102673300737Q',
                      '91220102732561436C',
                      '125150723',
                      '768998349',
                      '52220182E682283458',
                      '723128024',
                      '522201063339142498',
                      '125154759',
                      '125153799',
                      '732552046',
                      '125155751',
                      '125156340',
                      '125156367',
                      '125156949',
                      '125157482',
                      '125164156',
                      '125151136',
                      '12220400578912567H',
                      '125152251',
                      '717171069',
                      '717192505',
                      '729577082',
                      '125208016',
                      '743038827',
                      '825161968',
                      '825250717',
                      '91110114663703807T',
                      '912202010722667721',
                      '91220284594481824Q',
                      '91220284MA1492170X',
                      '91410102870084906E',
                      '93220221555282152F',
                      '067866003',
                      '912104007471125028',
                      '786016871',
                      '220402999');
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
