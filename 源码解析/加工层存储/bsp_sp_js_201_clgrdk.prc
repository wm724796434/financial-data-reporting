CREATE OR REPLACE PROCEDURE BSP_SP_JS_201_CLGRDK(IS_DATE        IN VARCHAR2,
                                                 OI_RETCODE     OUT INTEGER,
                                                 OI_RETCODE_DEC OUT VARCHAR2) AS  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_201_CLGRDK
  -- 业务域: 贷款类
  -- 用途: 生成接口表 JS_201_CLGRDK 存量个人贷款
  -- 参数
  --    IS_DATE 输入，传入跑批日期
  --    OI_RETCODE 输出，用来标识存储过程执行过程中是否出现异常
  -- 引用的监管集市表
  --    SMTMODS.L_ACCT_LOAN                                — 贷款借据信息表
  --    SMTMODS.L_PUBL_RATE                                — 汇率表
  --    SMTMODS.v_pub_idx_dk_zqdqrjj                       — v_pub_idx_dk_zqdqrjj
  -- 修改历史
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段 上线日期：2025-04-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
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
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');

  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_201_CLGRDK';
  VS_NMONTH         := TO_CHAR(TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD') + 1),
                               'YYYYMMDD');
  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

  -------------------------------------------------------------------------

  --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'PBOCD_JS_201_CLGRDK_TMP'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --查看分区是否存在，如果不存在创建分区，反之清空分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE  PBOCD_JS_201_CLGRDK_TMP ADD PARTITION P' ||
                      IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE  PBOCD_JS_201_CLGRDK_TMP TRUNCATE PARTITION P' ||
                    IS_DATE;

  --插入存量个人贷款
  INSERT INTO PBOCD_JS_201_CLGRDK_TMP
    (DATA_DATE, --1 数据日期
     ORG_CODE, --2 金融机构代码
     ORG_NUM, --3 内部机构号
     ORG_AREA_COD, --4 金融机构地区代码
     CUST_ID_TYPE, --5 客户证件类型
     CUST_ID_NO, --6 客户证件号
     REG_AREA_CODE, --7 借款人地区代码
     LOAN_NUM, --8 贷款借据编码
     CONTRACT_CODE, --9 贷款合同编码
     PRODUCT_TYPE, --10 贷款产品类别
     LOAN_GRANT_DATE, --11 贷款发放日期
     LOAN_DUE_DATE, --12 贷款到期日期
     DEFER_END_DATE, --13 贷款展期到期日期
     CURR_CODE, --14 贷款币种
     BALANCE, --15 贷款余额
     BALANCE_RMB, --16 贷款余额折人民币
     INT_RATE_TYPE, --17 利率是否固定
     INT_RATE, --18 利率水平
     PRI_BENCH_MARK, --19 贷款定价基准类型
     BASE_INT_RAT, --20 基准利率
     FINA_SUPPORT_FLG, --21 贷款财政扶持方式
     INT_REPRICE_DATE, --22 贷款利率重新定价日
     GUAR_TYPE, --23 贷款担保方式
     FIRST_LOAN_FLG, --24 是否首次贷款
     LOAN_CLASSIFY, --25 贷款质量
     LOAN_STATUS, --26 贷款状态
     OD_TYPE, --27 逾期类型
     USEOFUNDS, --28 贷款用途
     REPORT_ID, --29 报表ID
     CJRQ, --30 采集日期
     NBJGH, --31 内部机构号
     BIZ_LINE_ID, --32 业务条线
     VERIFY_STATUS, --33 校验状态
     BSCJRQ, --34 报送采集日期
     FRNBJGH, --35 法人内部机构号
     CUST_ID, --36 客户号
     CUST_NAME --37 客户名称
     )
    SELECT /*+parallel(4)*/
     VS_TEXT DATA_DATE, --1 数据日期
     '', --OFF.JRJGBM ORG_CODE, --2 金融机构代码
     T.ORG_NUM ORG_NUM, --3 内部机构号
     '', --OFF.AREA_ID ORG_AREA_COD, --4 金融机构地区代码
     C.CUST_ID_TYPE CUST_ID_TYPE, --5 客户证件类型
     C.CUST_ID_NO CUST_ID_NO, --6 客户证件号
     C.REG_REGION_CODE REG_AREA_CODE, --7 借款人地区代码
     T.LOAN_NUM LOAN_NUM, --8 贷款借据编码
     T.ACCT_NUM CONTRACT_CODE, --9 贷款合同编码
     CASE
       WHEN T.ACCT_TYP LIKE '0401%' OR
            (T.ACCT_TYP = '070101' AND T.ONLENDING_USAGE = 'D') OR
            (T.ITEM_CD LIKE '1305%' AND T.CURR_CD <> 'CNY') THEN
        'F081'
       WHEN T.ACCT_TYP LIKE '0402%' OR
            (T.ACCT_TYP = '070101' AND T.ONLENDING_USAGE = 'E') OR
            (T.ITEM_CD LIKE '1305%' AND T.CURR_CD = 'CNY') THEN
        'F082'
       WHEN T.ACCT_TYP LIKE '0101%' THEN
        'F0211'
       WHEN T.ACCT_TYP = '010301' THEN
        'F0212'
       WHEN T.ACCT_TYP IN ('010402', '010403', '010404') THEN
        'F02131'
       WHEN T.ACCT_TYP IN ('010401', '010405', '010499') THEN
        'F02132'
       WHEN T.ACCT_TYP = '010399' THEN
        'F0219'
       WHEN T.ACCT_TYP = '019999' THEN
        'F0219'
       WHEN T.ACCT_TYP = '0202' OR T.ACCT_TYP LIKE '0102%' OR
            (T.ACCT_TYP = '070101' AND T.ONLENDING_USAGE = 'A') THEN
        'F022'
       WHEN T.ACCT_TYP LIKE '0201%' OR
            (T.ACCT_TYP = '070101' AND T.ONLENDING_USAGE = 'B') THEN
        'F023'
       WHEN T.ACCT_TYP = '0801' THEN
        'F041'
       WHEN T.ACCT_TYP = '05' THEN
        'F09'
       WHEN T.ACCT_TYP = '0203' OR
            (T.ACCT_TYP = '070101' AND T.ONLENDING_USAGE = 'C') THEN
        'F12'
       WHEN T.ACCT_TYP = '010302' THEN
        'F0219'
     END AS PRODUCT_TYPE, --10 贷款产品类别
     TO_CHAR(T.DRAWDOWN_DT, 'YYYY-MM-DD') LOAN_GRANT_DATE, --11 贷款发放日期
     --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 处理缩期
     /*CASE 
       WHEN T.MATURITY_DT_BEFORE > T.MATURITY_DT AND T1.LOAN_NUM IS NULL THEN --处理缩期 zhoulp 20241217
         TO_CHAR(T.MATURITY_DT_BEFORE, 'YYYY-MM-DD')
       ELSE 
         TO_CHAR(T.MATURITY_DT, 'YYYY-MM-DD')
     END  LOAN_DUE_DATE, --12 贷款到期日期*/
     CASE 
       WHEN T.MATURITY_DT_BEFORE > T.MATURITY_DT THEN --缩期
         TO_CHAR(T.MATURITY_DT_BEFORE, 'YYYY-MM-DD')
       ELSE 
       -- 正常/展期/延期都取T.MATURITY_DT
       -- 集市对T.MATURITY_DT的取数逻辑是有展期的从展期协议表里取原贷款终止日期，无展期的从各台账取原贷款终止日期
         TO_CHAR(T.MATURITY_DT, 'YYYY-MM-DD')
     END  LOAN_DUE_DATE, --12 贷款到期日期
       
     CASE
       --延期无展期到期日；先展后延取展期后到期日，有名单的按名单取
       WHEN ZQ.EXTENDTERM_FLG = 'Y' THEN
        TO_CHAR(ZQ.ACTUAL_MATURITY_DT, 'YYYY-MM-DD') --展期
       WHEN T.MATURITY_DT_BEFORE > T.MATURITY_DT THEN --缩期
        TO_CHAR(T.MATURITY_DT, 'YYYY-MM-DD')
     END DEFER_END_DATE, --13 贷款展期到期日期
     
     
     T.CURR_CD CURR_CODE, --14 贷款币种
     T.LOAN_ACCT_BAL BALANCE, --15 贷款余额
     T.LOAN_ACCT_BAL * R.CCY_RATE BALANCE_RMB, --16 贷款余额折人民币
     CASE
       WHEN T.INT_RATE_TYP = 'F' THEN
        'RF01'
       ELSE
        'RF02'
     END INT_RATE_TYPE, --17 利率是否固定
     T.REAL_INT_RAT INT_RATE, --18 利率水平
     CASE
       WHEN T.PRICING_BASE_TYPE = 'A01' THEN
        'TR01'
       WHEN T.PRICING_BASE_TYPE = 'A0201' THEN
        'TR02'
       WHEN T.PRICING_BASE_TYPE = 'A0202' THEN
        'TR03'
       WHEN T.PRICING_BASE_TYPE = 'A0203' THEN
        'TR04'
       WHEN T.PRICING_BASE_TYPE = 'C' THEN
        'TR05'
       WHEN T.PRICING_BASE_TYPE = 'D' THEN
        'TR06'
       WHEN T.PRICING_BASE_TYPE = 'B01' THEN
        'TR07'
       WHEN T.PRICING_BASE_TYPE = 'B02' THEN
        'TR08'
       WHEN T.PRICING_BASE_TYPE = 'E' THEN
        'TR09'
       ELSE
        'TR99'
     END AS PRI_BENCH_MARK, --19 贷款定价基准类型
     CASE
       WHEN T.INT_RATE_TYP = 'F' THEN
        NULL
       ELSE
        CASE
          WHEN T.INT_RATE_TYP = 'F' THEN
           NULL
          ELSE
           T.BASE_INT_RAT
        END
     END BASE_INT_RAT, --20 基准利率
     CASE
       WHEN T.COMP_INT_TYP = '110' THEN
        'A0101'
       WHEN T.COMP_INT_TYP = '120' THEN
        'A0102'
       WHEN T.COMP_INT_TYP = '210' THEN
        'A0201'
       WHEN T.COMP_INT_TYP = '220' THEN
        'A0202'
       WHEN T.COMP_INT_TYP = '300' THEN
        'B'
       WHEN T.COMP_INT_TYP = '500' THEN
        'C'
       WHEN T.COMP_INT_TYP = '400' THEN
        'Z'
     END AS FINA_SUPPORT_FLG, --21 贷款财政扶持方式
     
     CASE
       WHEN T.MATURITY_DT_BEFORE > T.MATURITY_DT THEN --缩期
        TO_CHAR(T.MATURITY_DT, 'YYYY-MM-DD')
       WHEN T.INT_RATE_TYP = 'F' AND T.EXTENDTERM_FLG = 'Y' THEN
        TO_CHAR(T.ACTUAL_MATURITY_DT, 'YYYY-MM-DD') --固定利率，有展期，重定价日是展期到期日
       WHEN T.INT_RATE_TYP = 'F' THEN
        TO_CHAR(T.MATURITY_DT, 'YYYY-MM-DD') --固定利率，无展期，重定价日是到期日
       WHEN T.NEXT_REPRICING_DT < T.DRAWDOWN_DT THEN -- 重定价日小于贷款发放日期取放款日期
        TO_CHAR(T.DRAWDOWN_DT, 'YYYY-MM-DD')
       WHEN T.NEXT_REPRICING_DT > T.ACTUAL_MATURITY_DT THEN -- 重定价日大于贷款到期日期取到期日期
        TO_CHAR(T.ACTUAL_MATURITY_DT, 'YYYY-MM-DD')
       ELSE
        NVL(TO_CHAR(T.NEXT_REPRICING_DT, 'YYYY-MM-DD'),
            TO_CHAR(T.ACTUAL_MATURITY_DT, 'YYYY-MM-DD'))
     END INT_REPRICE_DATE, --22 --贷款利率重新定价日
     TP7.GUAR_TYPE AS GUAR_TYPE, --贷款担保方式
     NULL FIRST_LOAN_FLG, --24 是否首次贷款
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
     END LOAN_CLASSIFY, --25 贷款质量
     CASE
       WHEN T.OD_FLG = 'Y' THEN
        'LS03' /*逾期*/
       WHEN T.EXTENDTERM_FLG = 'Y' THEN /*展期*/
        'LS02'
       WHEN T.MATURITY_DT_BEFORE > T.MATURITY_DT THEN --缩期
        'LS04'
       ELSE
        'LS01' --正常
     END LOAN_STATUS, --26 贷款状态
     CASE
       WHEN T.OD_FLG <> 'Y' AND T.EXTENDTERM_FLG = 'Y' THEN
        '' --未逾期且展期
       ELSE
        CASE
          WHEN T.P_OD_DT IS NOT NULL AND T.I_OD_DT IS NOT NULL THEN
           '03' --本金利息逾期
          WHEN T.P_OD_DT IS NOT NULL THEN
           '01' /*本金逾期*/
          WHEN T.I_OD_DT IS NOT NULL THEN
           '02' /*利息逾期*/
        END
     END OD_TYPE, --27 逾期类型
     NVL(REPLACE(T.USEOFUNDS, CHR(09), ''), T.USEOFUNDS), --28 贷款用途
     SYS_GUID() REPORT_ID, --29 报表ID
     IS_DATE CJRQ, --30 采集日期
     T.ORG_NUM NBJGH, --31 内部机构号
     CASE
       WHEN T.ORG_NUM LIKE '51%' THEN
        '99'
       WHEN T.ORG_NUM LIKE '52%' THEN
        '99'
       WHEN T.ORG_NUM LIKE '53%' THEN
        '99'
       WHEN T.ORG_NUM LIKE '54%' THEN
        '99'
       WHEN T.ORG_NUM LIKE '55%' THEN
        '99'
       WHEN T.ORG_NUM LIKE '56%' THEN
        '99'
       WHEN T.ORG_NUM LIKE '57%' THEN
        '99'
       WHEN T.ORG_NUM LIKE '58%' THEN
        '99'
       WHEN T.ORG_NUM LIKE '59%' THEN
        '99'
       WHEN T.ORG_NUM LIKE '60%' THEN
        '99'
       WHEN T.DEPARTMENTD = '公司金融' THEN
        'E'
       WHEN T.DEPARTMENTD = '普惠金融' THEN
        'S'
       WHEN T.DEPARTMENTD = '个人信贷' THEN
        'P'
       /*WHEN T.DEPARTMENTD = '磐石村镇' THEN
        'V'*/
       WHEN T.DEPARTMENTD = '德惠长银' THEN
        'E'
       ELSE
        '99'
     END BIZ_LINE_ID, --32 业务条线 20230919王晓彬
     null VERIFY_STATUS, --33 校验状态
     '', --34 报送采集日期
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
        '600000' ----20230620多法人新增
       ELSE
        '990000'
     END FRNBJGH,
     T.CUST_ID CUST_ID, --36 客户号
     C.CUST_NAME CUST_NAME --37 客户名称
      FROM SMTMODS.L_ACCT_LOAN T --贷款借据信息
     INNER JOIN (SELECT ROW_NUMBER() OVER(PARTITION BY T.CUST_ID ORDER BY T.CUST_ID DESC) RN,
                        T.*
                   FROM JS_102_GRKHXX T
                  WHERE T.DATA_DATE = IS_DATE
                 --AND T.NBJGH NOT LIKE '0215%' --过滤磐石数据
                 ) C --个人客户基础信息
        ON T.CUST_ID = C.CUST_ID
       AND C.CJRQ = IS_DATE
       AND C.RN = 1
      LEFT JOIN SMTMODS.L_PUBL_RATE R --汇率表
        ON R.DATA_DATE = IS_DATE
       AND R.BASIC_CCY = T.CURR_CD
       AND R.FORWARD_CCY = 'CNY'
       AND R.DATA_DATE = IS_DATE
      LEFT JOIN DBFS_TMP TP7 --贷款担保方式中间表--在总调里加工
        ON T.LOAN_NUM = TP7.LOAN_NUM
      LEFT JOIN SMTMODS.v_pub_idx_dk_zqdqrjj ZQ --展期到期日期
        ON T.LOAN_NUM = ZQ.LOAN_NUM
       AND T.DATA_DATE = ZQ.DATA_DATE
      LEFT JOIN L_ACCT_LOAN_SUOQI T1 --L_ACCT_LOAN表20241031数据 以此判断办理缩期时点
        ON T.LOAN_NUM = T1.LOAN_NUM
       AND T.MATURITY_DT_BEFORE = T1.MATURITY_DT_BEFORE
       AND T.MATURITY_DT = T1.MATURITY_DT
     WHERE T.DATA_DATE = IS_DATE
       AND T.LOAN_ACCT_BAL > 0
       AND T.CURR_CD = 'CNY' --人民币
          --AND SUBSTR(T.ITEM_CD, 1, 3) IN ('122', '132') --122 个人贷款
       AND T.ACCT_TYP LIKE '01%' --个人贷款
       AND T.CANCEL_FLG = 'N' --核销标志为否
     AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
     ; 
  COMMIT;

  /*  --机构变更按照老机构报，如果不用了的机构可以把ORG_NEW表EFF_FLAG字段改成'N'
  UPDATE PBOCD_JS_201_CLGRDK_TMP A
  SET A.ORG_NUM = (SELECT T.ORG_NUM_BK FROM ORG_NEW T WHERE T.EFF_FLAG = 'Y' AND A.ORG_NUM = T.ORG_NUM_NEW)
  WHERE A.DATA_DATE = IS_DATE
  AND EXISTS(SELECT 1 FROM ORG_NEW B WHERE A.ORG_NUM = B.ORG_NUM_NEW AND B.EFF_FLAG = 'Y');
  COMMIT;*/

  --以下为原应用层逻辑
  SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_201_CLGRDK', OI_RETCODE);
  INSERT INTO PBOCD_JS_201_CLGRDK
    (DATA_DATE, --数据日期
     ORG_CODE, --金融机构代码
     ORG_NUM, --内部机构号
     ORG_AREA_COD, --金融机构地区代码
     CUST_ID_TYPE, --客户证件类型
     CUST_ID_NO, --客户证件号
     REG_AREA_CODE, --借款人注册地区代码
     LOAN_NUM, --贷款借据编码
     CONTRACT_CODE, --贷款合同编码
     PRODUCT_TYPE, --贷款产品类别
     LOAN_GRANT_DATE, --贷款发放日期
     LOAN_DUE_DATE, --贷款到期日期
     DEFER_END_DATE, --贷款展期到期日期
     CURR_CODE, --贷款币种
     BALANCE, --贷款余额
     BALANCE_RMB, --贷款余额折人民币
     INT_RATE_TYPE, --利率是否固定
     INT_RATE, --利率水平
     PRI_BENCH_MARK, --贷款定价基准类型
     BASE_INT_RAT, --基准利率
     FINA_SUPPORT_FLG, --贷款财政扶持方式
     INT_REPRICE_DATE, --贷款利率重新定价日
     GUAR_TYPE, --贷款担保方式
     FIRST_LOAN_FLG, --是否首次贷款
     LOAN_CLASSIFY, --贷款质量
     LOAN_STATUS, --贷款状态
     OD_TYPE, --逾期类型
     USEOFUNDS, --贷款用途
     REPORT_ID, --
     CJRQ, --采集日期
     NBJGH, --内部机构号
     BIZ_LINE_ID, --业务条线
     VERIFY_STATUS, --
     BSCJRQ, --??????
     FRNBJGH, --法人内部机构号
     CUST_ID, --客户号
     CUST_NAME --客户名称
     )
    SELECT VS_TEXT DATA_DATE, --  数据日期
           --OFF.JRJGBM, --金融机构代码
           NVL(OB.ID_NO, OB.UP_ID_NO), --金融机构代码
           T.ORG_NUM, --内部机构号
           --OFF.AREA_ID ORG_AREA_COD, --3  金融机构地区代码
           OB.REGION_CD, --3  金融机构地区代码
           
           --[2025-12-03] [周立鹏] [无需求][李楠] 调整证件类型、证件代码、担保方式取数逻辑
           --NVL(T.CUST_ID_TYPE, BK.CUST_ID_TYPE), --客户证件类型
           --NVL(T.CUST_ID_NO, BK.CUST_ID_NO), --客户证件号
           T.CUST_ID_TYPE, --客户证件类型
           T.CUST_ID_NO, --客户证件号
           
           --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
           --NVL(BK.REG_AREA_CODE, T.REG_AREA_CODE), --借款人地区代码
           T.REG_AREA_CODE, --借款人地区代码
           
           T.LOAN_NUM, --贷款借据编码
           T.CONTRACT_CODE, --贷款合同编码
           
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           /*NVL(T.PRODUCT_TYPE, BK.PRODUCT_TYPE), --贷款产品类别
           NVL(T.LOAN_GRANT_DATE, BK.LOAN_GRANT_DATE), --贷款发放日期
           NVL(T.LOAN_DUE_DATE, BK.LOAN_DUE_DATE), --贷款到期日期*/
           T.PRODUCT_TYPE, --贷款产品类别
           T.LOAN_GRANT_DATE, --贷款发放日期
           T.LOAN_DUE_DATE, --贷款到期日期
           
           --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 缩期处理
           --NVL(T.DEFER_END_DATE, BK.DEFER_END_DATE), --贷款展期到期日期
           T.DEFER_END_DATE, --贷款展期到期日期
           
           T.CURR_CODE, --贷款币种
           T.BALANCE, --贷款余额
           T.BALANCE_RMB, --贷款余额折人民币
           
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --NVL(T.INT_RATE_TYPE, BK.INT_RATE_TYPE), --利率是否固定
           T.INT_RATE_TYPE, --利率是否固定
           
           NVL(T.INT_RATE, BK.INT_RATE), --利率水平
           
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --NVL(T.PRI_BENCH_MARK, BK.PRI_BENCH_MARK), --贷款定价基准类型
           T.PRI_BENCH_MARK, --贷款定价基准类型
           
           CASE
             WHEN T.INT_RATE_TYPE = 'RF01' THEN
              NULL
             ELSE
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
              --NVL(T.BASE_INT_RAT, BK.BASE_INT_RAT)
              T.BASE_INT_RAT
           END, --基准利率
           
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --NVL(T.FINA_SUPPORT_FLG, BK.FINA_SUPPORT_FLG), --贷款财政扶持方式
           T.FINA_SUPPORT_FLG, --贷款财政扶持方式
           
           --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 缩期处理
           --NVL(T.INT_REPRICE_DATE, BK.INT_REPRICE_DATE), --贷款利率重新定价日
           T.INT_REPRICE_DATE, --贷款利率重新定价日
           
     --[2025-12-03] [周立鹏] [无需求][李楠] 调整证件类型、证件代码、担保方式取数逻辑
           --NVL(BK.GUAR_TYPE, T.GUAR_TYPE), --贷款担保方式
     T.GUAR_TYPE, --贷款担保方式
           
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --NVL(T.FIRST_LOAN_FLG, BK.FIRST_LOAN_FLG), --是否首次贷款
           --NVL(T.LOAN_CLASSIFY, BK.LOAN_CLASSIFY), --贷款质量
           T.FIRST_LOAN_FLG, --是否首次贷款
           T.LOAN_CLASSIFY, --贷款质量

           --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 缩期处理
           --NVL(T.LOAN_STATUS, BK.LOAN_STATUS), --贷款状态
           T.LOAN_STATUS, --贷款状态
           
           T.OD_TYPE, --逾期类型
           
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --NVL(REPLACE(T.USEOFUNDS, CHR(09), ''), BK.USEOFUNDS), --贷款用途
           REPLACE(T.USEOFUNDS, CHR(09), ''), --贷款用途
           T.REPORT_ID, --
           T.CJRQ, --采集日期
           T.NBJGH, --内部机构号
           T.BIZ_LINE_ID, --业务条线
           T.VERIFY_STATUS, --
           T.BSCJRQ, --
           T.FRNBJGH, --法人内部机构号
           T.CUST_ID, --客户号
           T.CUST_NAME --客户名称
      FROM PBOCD_JS_201_CLGRDK_TMP T --存量个人贷款
    /*LEFT JOIN SYS_OFFICE OFF
    ON OFF.ID =t.NBJGH*/
      LEFT JOIN L_PUBL_ORG_BRA_TMP OB --金数机构表
        ON OB.ORG_NUM = T.ORG_NUM
       AND OB.DATA_DATE = IS_DATE
      LEFT JOIN PBOCD_JS_201_CLGRDK_SQ BK
        ON T.LOAN_NUM = BK.LOAN_NUM
       AND BK.CJRQ = VS_LAST_TEXT
     WHERE TRIM(T.DATA_DATE) = VS_TEXT;

  COMMIT;

  --插入信用卡数据
  INSERT INTO PBOCD_JS_201_CLGRDK
    (DATA_DATE, --数据日期
     ORG_CODE, --金融机构代码
     ORG_NUM, --内部机构号
     ORG_AREA_COD, --金融机构地区代码
     CUST_ID_TYPE, --借款人证件类型
     CUST_ID_NO, --借款人证件号码
     REG_AREA_CODE, --借款人地区代码
     LOAN_NUM, --贷款借据编码
     CONTRACT_CODE, --贷款合同编码
     PRODUCT_TYPE, --贷款产品类别
     LOAN_GRANT_DATE, --贷款发放日期
     LOAN_DUE_DATE, --贷款到期日期
     DEFER_END_DATE, --贷款展期到期日期
     CURR_CODE, --贷款币种
     BALANCE, --贷款余额
     BALANCE_RMB, --贷款余额折人民币
     INT_RATE_TYPE, --利率是否固定
     INT_RATE, --利率水平
     PRI_BENCH_MARK, --贷款定价基准类型
     BASE_INT_RAT, --基准利率
     FINA_SUPPORT_FLG, --贷款财政扶持方式
     INT_REPRICE_DATE, --贷款利率重新定价日
     GUAR_TYPE, --贷款担保方式
     FIRST_LOAN_FLG, --是否首次贷款
     LOAN_CLASSIFY, --贷款质量
     LOAN_STATUS, --贷款状态
     OD_TYPE, --逾期类型
     USEOFUNDS, --贷款用途
     REPORT_ID, --报送ID
     CJRQ, --采集日期
     NBJGH, --内部机构号
     BIZ_LINE_ID, --业务条线
     FRNBJGH --法人内部机构号
     )
    SELECT VS_TEXT DATA_DATE --数据日期
          ,
           TRIM(T.ORG_CODE) --金融机构代码
          ,
           '009803' --内部机构号
          ,
           SUBSTR(TRIM(T.ORG_AREA_COD), 1, 6) --金融机构地区代码
          ,
           TRIM(NVL(AA.CUST_ID_TYPE, T.CUST_ID_TYPE)) --借款人证件类型
          ,
           TRIM(T.CUST_ID_NO) --借款人证件号码
          ,
           TRIM(T.REG_AREA_CODE) --借款人地区代码
          ,
           TRIM(T.LOAN_NUM) --贷款借据编码
          ,
           TRIM(T.CONTRACT_CODE) --贷款合同编码
          ,
           TRIM(T.PRODUCT_TYPE) --贷款产品类别
          ,
           '' --贷款发放日期
          ,
           '' --贷款到期日期
          ,
           NVL2(TRIM(T.DEFER_END_DATE),
                SUBSTR(TRIM(T.DEFER_END_DATE), 1, 4) || '-' ||
                SUBSTR(TRIM(T.DEFER_END_DATE), 5, 2) || '-' ||
                SUBSTR(TRIM(T.DEFER_END_DATE), 7, 2),
                '') --贷款展期到期日期
          ,
           TRIM(T.CURR_CODE) --贷款币种
          ,
           TRIM(T.BALANCE) --贷款余额
          ,
           TRIM(T.BALANCE_RMB) --贷款余额折人民币
          ,
           TRIM(T.INT_RATE_TYPE) --利率是否固定
          ,
           TRIM(T.INT_RATE) --利率水平
          ,
           TRIM(T.PRI_BENCH_MARK) --贷款定价基准类型
          ,
           CASE
             WHEN TRIM(T.INT_RATE_TYPE) = 'RF02' THEN
              TRIM(T.BASE_INT_RAT)
             ELSE
              NULL
           END --基准利率
          ,
           TRIM(T.FINA_SUPPORT_FLG) --贷款财政扶持方式
          ,
           NVL2(TRIM(T.INT_REPRICE_DATE),
                SUBSTR(TRIM(T.INT_REPRICE_DATE), 1, 4) || '-' ||
                SUBSTR(TRIM(T.INT_REPRICE_DATE), 5, 2) || '-' ||
                SUBSTR(TRIM(T.INT_REPRICE_DATE), 7, 2),
                '') --贷款利率重新定价日
          ,
           TRIM(T.GUAR_TYPE) --贷款担保方式
          ,
           '' --TRIM(T.FIRST_LOAN_FLG) --是否首次贷款
          ,
           TRIM(T.LOAN_CLASSIFY) --贷款质量
          ,
           TRIM(T.LOAN_STATUS) --贷款状态
          ,
           TRIM(T.OD_TYPE) --逾期类型
          ,
           '消费' --NVL(TRIM(REPLACE(T.USEOFUNDS,CHR(13),'')),T1.USEOFUNDS) --贷款用途
          ,
           SYS_GUID() REPORT_ID --报送ID
          ,
           IS_DATE --采集日期
          ,
           '009803' --内部机构号
          ,
           '99' --业务条线
          ,
           '990000' --法人内部机构号
      FROM PBOCD_DATACORE.JS_201_CLGRDK_XYK T
      LEFT JOIN PBOCD_JS_102_GRKHXX AA
        ON T.CUST_ID_NO = AA.CUST_ID_NO
       AND AA.CJRQ = IS_DATE
       AND AA.FRNBJGH = '990000'
     WHERE T.DATA_DATE = IS_DATE;

  COMMIT;
  
--------------------------------------处理缩期开始-------------------------------------------------------------------------------
/*
20250822梳理缩期字段取数逻辑：--20251230弃用
如果20241031之后，如果L层借据表延期前到期日大于原始到期日，贷款到期日期取取延期前到期日，贷款展期到期日期、贷款利率重新定价日取取原始到期日,贷款状态取LS04-缩期
如果20241031报送层结果表为缩期(到期日大于展期到日期或贷款状态为LS04-缩期)或20241031L层借据表延期前到期日大于原始到期日，以上字段按20241031报送层结果表刷
*/

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 缩期处理
/*
20251230梳理缩期字段取数逻辑：
t1-清单到期日    t2-L层到期日       t3-展期后到期日

t1>t2
到期日=t1  展期到期日/利率重新定价日=t2  状态=LS04-缩期

t1<t2 and 展期=N
到期日=t2  展期到期日/利率重新定价日=空  状态=逾期/正常

t1<t2 and 展期=Y and not in 展/延名单
到期日=t2  展期到期日/利率重新定价日=t3  状态=逾期/展期

t1<t2 and 展期=Y and in 展/延名单
到期日=t2  展期到期日/利率重新定价日=t3(最终日期)  状态=逾期/展期  --这条与上一条实际一样
*/
    
    EXECUTE IMMEDIATE 'TRUNCATE TABLE PBOCD_JS_201_CLGRDK_20251215';
    INSERT INTO PBOCD_JS_201_CLGRDK_20251215 SELECT * FROM PBOCD_JS_201_CLGRDK WHERE CJRQ = IS_DATE;
    COMMIT;
    
    MERGE INTO PBOCD_JS_201_CLGRDK A
    USING (SELECT t1.LOAN_NUM,T1.MATURITY_DT AS MATURITY_DT_T1,T2.MATURITY_DT AS MATURITY_DT_T2,T2.MATURITY_DT_BEFORE,T2.EXTENDTERM_FLG, 
                  t2.OD_FLG, t2.P_OD_DT, t2.I_OD_DT
             --缩期处理 zhoulp20251215 辉哥要求弃用20241031清单，改用20251215清单
             FROM SUOQI_LIST_20251215 t1
             INNER JOIN SMTMODS.L_ACCT_LOAN t2
               ON t1.LOAN_NUM = t2.LOAN_NUM
              AND t2.DATA_DATE = IS_DATE
             WHERE T1.MATURITY_DT>T2.MATURITY_DT
              ) D
    ON (A.LOAN_NUM = D.LOAN_NUM)
    WHEN MATCHED THEN
      UPDATE
         SET A.LOAN_DUE_DATE    = TO_CHAR(D.MATURITY_DT_T1,'YYYY-MM-DD'),
             A.DEFER_END_DATE   = TO_CHAR(D.MATURITY_DT_T2,'YYYY-MM-DD'),
             A.INT_REPRICE_DATE = TO_CHAR(D.MATURITY_DT_T2,'YYYY-MM-DD'),
             A.LOAN_STATUS      = (CASE WHEN D.OD_FLG = 'Y' THEN 'LS03'/*逾期*/ ELSE 'LS04'/*缩期*/END),
             A.OD_TYPE          =
             (CASE
               WHEN D.OD_FLG = 'Y' AND D.P_OD_DT IS NOT NULL AND
                    D.I_OD_DT IS NOT NULL THEN
                '03' --本金利息逾期
               WHEN D.OD_FLG = 'Y' AND D.P_OD_DT IS NOT NULL THEN
                '01' /*本金逾期*/
               WHEN D.OD_FLG = 'Y' AND D.I_OD_DT IS NOT NULL THEN
                '02' /*利息逾期*/
             END)
       WHERE A.CJRQ = IS_DATE;
  COMMIT;
  

    MERGE INTO PBOCD_JS_201_CLGRDK A
    USING (SELECT t1.LOAN_NUM,T1.MATURITY_DT AS MATURITY_DT_T1,T2.MATURITY_DT AS MATURITY_DT_T2,T2.MATURITY_DT_BEFORE,T2.EXTENDTERM_FLG, 
                  t2.OD_FLG, t2.P_OD_DT, t2.I_OD_DT
             --缩期处理 zhoulp20251215 辉哥要求弃用20241031清单，改用20251215清单
             FROM SUOQI_LIST_20251215 t1
             INNER JOIN SMTMODS.L_ACCT_LOAN t2
               ON t1.LOAN_NUM = t2.LOAN_NUM
              AND t2.DATA_DATE = IS_DATE
             WHERE T1.MATURITY_DT<T2.MATURITY_DT AND T2.EXTENDTERM_FLG <> 'Y'
              ) D
    ON (A.LOAN_NUM = D.LOAN_NUM)
    WHEN MATCHED THEN
      UPDATE
         SET A.LOAN_DUE_DATE    = TO_CHAR(D.MATURITY_DT_T2,'YYYY-MM-DD'),
             A.DEFER_END_DATE   = '',
             A.INT_REPRICE_DATE = '',
             A.LOAN_STATUS      = (CASE WHEN D.OD_FLG = 'Y' THEN 'LS03'/*逾期*/ ELSE 'LS01'/*正常*/END),
             A.OD_TYPE          =
             (CASE
               WHEN D.OD_FLG = 'Y' AND D.P_OD_DT IS NOT NULL AND
                    D.I_OD_DT IS NOT NULL THEN
                '03' --本金利息逾期
               WHEN D.OD_FLG = 'Y' AND D.P_OD_DT IS NOT NULL THEN
                '01' /*本金逾期*/
               WHEN D.OD_FLG = 'Y' AND D.I_OD_DT IS NOT NULL THEN
                '02' /*利息逾期*/
             END)
       WHERE A.CJRQ = IS_DATE;
  COMMIT;



    MERGE INTO PBOCD_JS_201_CLGRDK A
    USING (SELECT t1.LOAN_NUM,T1.MATURITY_DT AS MATURITY_DT_T1,T2.MATURITY_DT AS MATURITY_DT_T2,T2.MATURITY_DT_BEFORE,T2.EXTENDTERM_FLG, 
                  t2.OD_FLG, t2.P_OD_DT, t2.I_OD_DT
             --缩期处理 zhoulp20251215 辉哥要求弃用20241031清单，改用20251215清单
             FROM SUOQI_LIST_20251215 t1
             INNER JOIN SMTMODS.L_ACCT_LOAN t2
               ON t1.LOAN_NUM = t2.LOAN_NUM
              AND t2.DATA_DATE = IS_DATE
             --这里可以left join 展/延名单
             WHERE T1.MATURITY_DT<T2.MATURITY_DT AND T2.EXTENDTERM_FLG = 'Y'
              ) D
    ON (A.LOAN_NUM = D.LOAN_NUM)
    WHEN MATCHED THEN
      UPDATE
         SET A.LOAN_DUE_DATE    = TO_CHAR(D.MATURITY_DT_T2,'YYYY-MM-DD'),
             A.DEFER_END_DATE   = TO_CHAR(D.MATURITY_DT_BEFORE,'YYYY-MM-DD'),
             A.INT_REPRICE_DATE = TO_CHAR(D.MATURITY_DT_BEFORE,'YYYY-MM-DD'),
             A.LOAN_STATUS      = (CASE WHEN D.OD_FLG = 'Y' THEN 'LS03'/*逾期*/ WHEN D.EXTENDTERM_FLG = 'Y' THEN 'LS02'/*展期*/ END),
             A.OD_TYPE          =
             (CASE
               WHEN D.OD_FLG = 'Y' AND D.P_OD_DT IS NOT NULL AND
                    D.I_OD_DT IS NOT NULL THEN
                '03' --本金利息逾期
               WHEN D.OD_FLG = 'Y' AND D.P_OD_DT IS NOT NULL THEN
                '01' /*本金逾期*/
               WHEN D.OD_FLG = 'Y' AND D.I_OD_DT IS NOT NULL THEN
                '02' /*利息逾期*/
             END)
       WHERE A.CJRQ = IS_DATE;
  COMMIT;

  

/*  --处理缩期 ZHOULP 20241217 按20241031表刷到期日变化了的数据。这类数据是当初某期按合同表取了到期日，导致以后每期都要刷
  MERGE INTO PBOCD_JS_201_CLGRDK A
  USING JS_201_CLGRDK_SUOQI D --报送层20241031数据
  ON (A.LOAN_NUM = D.LOAN_NUM)
  WHEN MATCHED THEN
    UPDATE
       SET A.LOAN_DUE_DATE    = D.LOAN_DUE_DATE
     WHERE A.CJRQ = IS_DATE
    ;
COMMIT;

update pbocd_js_201_clgrdk SET INT_REPRICE_DATE = LOAN_DUE_DATE 
WHERE CJRQ=IS_DATE AND LOAN_DUE_DATE IS NOT NULL AND INT_REPRICE_DATE IS NOT NULL 
AND DEFER_END_DATE IS NULL  AND INT_RATE_TYPE  ='RF02' and INT_REPRICE_DATE>LOAN_DUE_DATE;
COMMIT;

update pbocd_js_201_clgrdk SET INT_REPRICE_DATE = LOAN_DUE_DATE 
WHERE CJRQ=IS_DATE AND INT_REPRICE_DATE IS NOT NULL 
AND DEFER_END_DATE IS NULL  AND INT_RATE_TYPE  ='RF01' and INT_REPRICE_DATE<>LOAN_DUE_DATE;
COMMIT;

update pbocd_js_201_clgrdk SET loan_status  ='LS04' 
WHERE CJRQ=IS_DATE AND LOAN_DUE_DATE IS NOT NULL 
AND DEFER_END_DATE IS NOT NULL  AND loan_status  ='LS02' and LOAN_DUE_DATE>=DEFER_END_DATE;
COMMIT;

update pbocd_js_201_clgrdk SET INT_REPRICE_DATE = DEFER_END_DATE WHERE CJRQ=IS_DATE AND INT_REPRICE_DATE IS NOT NULL 
AND DEFER_END_DATE IS NOT NULL  AND INT_RATE_TYPE  ='RF01' and INT_REPRICE_DATE<>DEFER_END_DATE;
COMMIT;

update pbocd_js_201_clgrdk SET loan_status  =(case when LOAN_DUE_DATE>DEFER_END_DATE then 'LS04'
when LOAN_DUE_DATE<DEFER_END_DATE then 'LS02'
when LOAN_DUE_DATE=DEFER_END_DATE then 'LS01' end
),
DEFER_END_DATE=(case when LOAN_DUE_DATE=DEFER_END_DATE then null else DEFER_END_DATE END)
WHERE CJRQ=IS_DATE AND DEFER_END_DATE IS NOT NULL  AND nvl(loan_status,'#') not in ('LS02','LS04','LS03');
COMMIT;*/
--------------------------------------处理缩期结束-------------------------------------------------------------------------------

--[2025-12-03] [周立鹏] [无需求][李楠] 调整证件类型、证件代码、担保方式取数逻辑
/*  --证件类型客户信息表刷
  MERGE INTO PBOCD_JS_201_CLGRDK A
  USING (SELECT * FROM PBOCD_JS_102_GRKHXX WHERE CJRQ = IS_DATE) b
  on (A.CUST_ID_NO = B.CUST_ID_NO AND A.FRNBJGH=B.FRNBJGH)
  WHEN MATCHED THEN
    UPDATE SET A.CUST_ID_TYPE = B.CUST_ID_TYPE WHERE A.CJRQ = IS_DATE;
  COMMIT;*/

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
/*--[2025-12-03] [周立鹏] [无需求][李楠] 调整证件类型、证件代码、担保方式取数逻辑
  --JS_102_GRKHXX_BL 个人客户信息
  MERGE INTO PBOCD_JS_201_CLGRDK A
  USING JS_102_GRKHXX_BL B
  ON (A.CUST_ID = B.CUST_ID AND A.CJRQ = IS_DATE)
  WHEN MATCHED THEN
    UPDATE
       SET \*A.CUST_ID_TYPE  = B.CUST_ID_TYPE,
           A.CUST_ID_NO    = B.CUST_ID_NO_NEW,*\
           A.REG_AREA_CODE = B.REG_REGION_CODE \*,
             A.ORG_NUM       = B.NBJGH*\
    ;
  COMMIT;*/

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
  --公主岭地区代码
/*  UPDATE PBOCD_JS_201_CLGRDK
     SET ORG_AREA_COD = '220184'
   WHERE CJRQ = IS_DATE
     AND ORG_AREA_COD = '220381';
  COMMIT;*/

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
/*  UPDATE PBOCD_JS_201_CLGRDK
     SET REG_AREA_CODE = '220184'
   WHERE CJRQ = IS_DATE
     AND REG_AREA_CODE = '220381';
  COMMIT;

  UPDATE PBOCD_JS_201_CLGRDK
     SET \*CUST_ID_TYPE = 'B99',*\ REG_AREA_CODE = '220105'
   WHERE CJRQ = IS_DATE
     AND CUST_ID_NO = 'KOR110064032206';
  COMMIT;*/

  --信用卡以外数据，如果利率是0改成空，只是存量改，发生不改
  UPDATE PBOCD_JS_201_CLGRDK A
     SET INT_RATE = ''
   WHERE CJRQ = IS_DATE
     AND INT_RATE = 0
     AND ORG_NUM <> '009803';
  COMMIT;

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
/*  --调用特殊处理程序
  --地区代码999999、空、000开头的数据，先按本期客户表刷，刷不到再按上期客户表刷
  BSP_SP_JS_SPOP(IS_DATE,OI_RETCODE,OI_RETCODE_DEC,'PBOCD_JS_201_CLGRDK');*/
  -------------------------------------------------------------------------

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
    OI_RETCODE     := -1; --设置异常状态为-1
    OI_RETCODE_DEC := SQLCODE || ':' || SUBSTR(SQLERRM, 1, 50); --系统错误描述
    --插入日志表，记录错误
    SP_PBOCD_LOG(VS_PROCEDURE_NAME,
                 'ERROR',
                 VI_ERRORCODE,
                 VS_TEXT,
                 IS_DATE);
END;