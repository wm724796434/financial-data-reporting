CREATE OR REPLACE PROCEDURE BSP_SP_JS_201_GRDKFS(IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  --    SP_JS_201_GRDKFS
  -- 用途:生成接口表 JS_201_GRDKFS 个人贷款发生额信息
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    CAEATE BY USER AT 20200819
  --    MOD BY yanlingbo AT 20200819
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段 上线日期：2025-04-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  --    需求编号：JLBA202507300010关于新一代信贷管理系统新增线上微贷板块的需求 上线日期：2025-09-18，修改人：周立鹏，提出人：从需求   修改原因：NGI系统新增吉惠贷数据
  --    需求编号：无 上线日期：2025-12-03，修改人：周立鹏，提出人：李楠   修改原因：调整证件类型、证件代码、担保方式取数逻辑，剔除取上期/配置表
  --    需求编号：JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段 上线日期：2025-12-30，修改人：周立鹏，提出人：李楠   修改原因：剔除特殊处理
  --    需求编号：JLBA202412040002_关于在金融基础数据修改部分业务取数逻辑的需求 上线日期：2026-03-19，修改人：周立鹏，提出人：李楠   修改原因：贷款发生额负值调整
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT      VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
  --VS_FIRST          VARCHAR2(10); --存储过程执行步骤标志
  NUM               INTEGER;
  D_DATADATE        DATE; --数据日期(日期型)
  VS_NMONTH         VARCHAR2(10);

BEGIN
  VS_TEXT    := to_char(to_date(IS_DATE, 'yyyymmdd'), 'yyyy-mm-dd');
  --VS_FIRST   := to_char(to_date(SUBSTR(IS_DATE, 1, 6) || '01', 'yyyymmdd'),'yyyymmdd');
  D_DATADATE := TO_DATE(IS_DATE, 'YYYYMMDD');

  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');

    -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_201_GRDKFS';
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
   WHERE TABLE_NAME = 'JS_201_GRDKFS'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE  JS_201_GRDKFS ADD PARTITION P' ||
                      IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE  JS_201_GRDKFS TRUNCATE PARTITION P' ||
                    IS_DATE;

  VS_STEP := '1';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  INSERT /*+ append*/
  INTO JS_201_GRDKFS /*@PBOCD_34*/
  NOLOGGING -----'生成数据-过滤条件一发放';
    (DATA_DATE, --数据日期
     ORG_CODE, --金融机构代码
     ORG_NUM, --内部机构号
     ORG_AREA_COD, --金融机构地区代码
     CUST_ID_TYPE, --借款人证件类型
     CUST_ID_NO, --借款人证件代码
     REG_AREA_CODE, --借款人地区代码
     LOAN_NUM, --贷款借据编码
     CONTRACT_CODE, --贷款合同编码
     PRODUCT_TYPE, --贷款产品类别
     LOAN_GRANT_DATE, --贷款发放日期
     LOAN_DUE_DATE, --贷款到期日期
     LOAN_ACTUAL_DUE_DATE, --贷款实际终止日期
     CURR_CODE, --币种
     TRANS_AMT, --贷款发生金额
     TRANS_AMT_RMB, --贷款发生金额折人民币
     INT_RATE_TYPE, --利率是否固定
     INT_RATE, --利率水平
     PRI_BENCH_MARK, --贷款定价基准类型
     BASE_INT_RAT, --基准利率
     FINA_SUPPORT_FLG, --贷款财政扶持方式
     INT_REPRICE_DATE, --贷款利率重新定价日
     GUAR_TYPE, --贷款担保方式
     FIRST_LOAN_FLG, --是否首次贷款
     LOAN_STATUS, --贷款状态
     ASS_SEC_PRO_TYPE, --资产证券化产品代码
     LOAN_TYPE, --贷款重组方式
     TRANS_TYPE, --发放/收回标识
     SERIAL_NO,  --交易流水号
     USEOFUNDS, --贷款用途
     CJRQ, --采集日期
     NBJGH, --内部机构号
     BIZ_LINE_ID, --业务条线
     VERIFY_STATUS, --校验状态
     FRNBJGH, --法人内部机构号
     CUST_ID,
     CUST_NAME
     )
    SELECT/*+ parallel(4)*/ IS_DATE AS DATA_DATE, --数据日期
          null, --应用接口层使用系统机构数据
           A.ORG_NUM AS ORG_NUM, --内部机构号
         null, --应用接口层使用系统机构数据
           KH.CUST_ID_TYPE, --借款人证件类型
           
           --[2025-12-03] [周立鹏] [无需求][李楠] 调整证件类型、证件代码、担保方式取数逻辑
           /*CASE
             WHEN E.CUST_TYP='3' THEN
               nvl(E.LEGAL_CARD_NO,E.ID_NO)
             ELSE
              B.ID_NO
              END AS CUST_ID_NO,--借款人证件号码*/
           KH.CUST_ID_NO AS CUST_ID_NO,--借款人证件号码
           
           KH.REG_REGION_CODE , --借款人地区代码
           A.LOAN_NUM AS LOAN_NUM, --贷款借据编码
           A.ACCT_NUM AS CONTRACT_CODE, --贷款合同编码
           CASE
             WHEN A.ACCT_TYP LIKE '0401%' OR (A.ACCT_TYP='070101' AND A.ONLENDING_USAGE='D') OR (A.ITEM_CD LIKE '1305%' AND A.CURR_CD <> 'CNY') THEN 'F081'
             WHEN A.ACCT_TYP LIKE '0402%' OR (A.ACCT_TYP='070101' AND A.ONLENDING_USAGE='E')  OR (A.ITEM_CD LIKE '1305%' AND A.CURR_CD = 'CNY') THEN 'F082'
             WHEN A.ACCT_TYP LIKE '0101%' THEN
              'F0211'
             WHEN A.ACCT_TYP = '010301' THEN
              'F0212'
             WHEN A.ACCT_TYP IN ('010402', '010403', '010404') THEN
              'F02131'
             WHEN A.ACCT_TYP IN ('010401', '010405', '010499') THEN
              'F02132'
             WHEN A.ACCT_TYP IN ('010399','019999') THEN
              'F0219'
             WHEN A.ACCT_TYP = '0202' OR A.ACCT_TYP LIKE '0102%' OR
                  (A.ACCT_TYP = '070101' AND A.ONLENDING_USAGE = 'A') THEN
              'F022'
             WHEN A.ACCT_TYP LIKE '0201%' OR
                  (A.ACCT_TYP = '070101' AND A.ONLENDING_USAGE = 'B') THEN
              'F023'
             WHEN A.ACCT_TYP = '0801' THEN
              'F041'
             WHEN A.ACCT_TYP = '05' THEN
              'F09'
             WHEN A.ACCT_TYP = '0203' OR
                  (A.ACCT_TYP = '070101' AND A.ONLENDING_USAGE = 'C') THEN
              'F12'
             WHEN A.ACCT_TYP = '010302' THEN
               'F0219'

           END AS PRODUCT_TYPE, --贷款产品类别
           CASE
             WHEN A.LOAN_BUY_INT = 'N' THEN
              TO_CHAR(A.DRAWDOWN_DT, 'YYYY-MM-DD')
             WHEN A.LOAN_BUY_INT = 'Y' THEN
              TO_CHAR(A.IN_DRAWDOWN_DT, 'YYYY-MM-DD')
           END AS LOAN_GRANT_DATE, --贷款发放日期
          -- TO_CHAR(A.MATURITY_DT, 'YYYY-MM-DD') AS LOAN_DUE_DATE, --贷款到期日期
          
          --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 处理缩期
          CASE
             WHEN A.MATURITY_DT_BEFORE > A.MATURITY_DT  /*AND T1.LOAN_NUM IS NULL */THEN --处理缩期 zhoulp 20241217
               TO_CHAR(A.MATURITY_DT_BEFORE, 'YYYY-MM-DD')
             ELSE
               TO_CHAR(A.MATURITY_DT, 'YYYY-MM-DD')
           END  LOAN_DUE_DATE, --12 贷款到期日期
           
           
          ''AS LOAN_ACTUAL_DUE_DATE, --贷款实际终止日期
           A.CURR_CD AS CURR_CODE, --币种
           A.DRAWDOWN_AMT AS TRANS_AMT, --贷款发生金额
           CASE
             WHEN A.CURR_CD = 'CNY' THEN
              A.DRAWDOWN_AMT
             ELSE
              A.DRAWDOWN_AMT * U.CCY_RATE
           END AS TRANS_AMT_RMB, --贷款发生金额折人民币
           CASE
             WHEN A.INT_RATE_TYP = 'F' THEN
              'RF01'
             WHEN A.INT_RATE_TYP LIKE 'L%' THEN
              'RF02'
           END AS INT_RATE_TYPE,--利率是否固定
           A.REAL_INT_RAT AS INT_RATE, --利率水平
           CASE
             WHEN A.PRICING_BASE_TYPE = 'A01' THEN
              'TR01'
             WHEN A.PRICING_BASE_TYPE = 'A0201' THEN
              'TR02'
             WHEN A.PRICING_BASE_TYPE = 'A0202' THEN
              'TR03'
             WHEN A.PRICING_BASE_TYPE = 'A0203' THEN
              'TR04'
             WHEN A.PRICING_BASE_TYPE = 'C' THEN
              'TR05'
             WHEN A.PRICING_BASE_TYPE = 'D' THEN
              'TR06'
             WHEN A.PRICING_BASE_TYPE = 'B01' THEN
              'TR07'
             WHEN A.PRICING_BASE_TYPE = 'B02' THEN
              'TR08'
             WHEN A.PRICING_BASE_TYPE = 'E' THEN
              'TR09'
             ELSE
              'TR99'
           END AS PRI_BENCH_MARK, --贷款定价基准类型
           CASE
              WHEN A.INT_RATE_TYP='F'   THEN
                NULL
                ELSE A.BASE_INT_RAT END BASE_INT_RAT , --基准利率
           CASE
             WHEN A.COMP_INT_TYP = '110' THEN
              'A0101'
             WHEN A.COMP_INT_TYP = '120' THEN
              'A0102'
             WHEN A.COMP_INT_TYP = '210' THEN
              'A0201'
             WHEN A.COMP_INT_TYP = '220' THEN
              'A0202'
             WHEN A.COMP_INT_TYP = '300' THEN
              'B'
             WHEN A.COMP_INT_TYP = '500' THEN
              'C'
             WHEN A.COMP_INT_TYP = '400' THEN
              'Z'
           END AS FINA_SUPPORT_FLG, --贷款财政扶持方式
           
           --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 处理缩期
           CASE
               WHEN A.MATURITY_DT_BEFORE > A.MATURITY_DT /*AND T1.LOAN_NUM IS NULL */THEN --处理缩期 zhoulp 20241217
                TO_CHAR(A.MATURITY_DT, 'YYYY-MM-DD')
               WHEN A.INT_RATE_TYP = 'F' AND A.EXTENDTERM_FLG = 'Y' THEN
                TO_CHAR(A.ACTUAL_MATURITY_DT, 'YYYY-MM-DD') --固定利率，有展期，重定价日是展期到期日
               WHEN A.INT_RATE_TYP = 'F' THEN
                TO_CHAR(A.MATURITY_DT, 'YYYY-MM-DD') --固定利率，无展期，重定价日是到期日
               WHEN A.NEXT_REPRICING_DT < A.DRAWDOWN_DT THEN -- 重定价日小于贷款发放日期取放款日期
                TO_CHAR(A.DRAWDOWN_DT, 'YYYY-MM-DD')
               WHEN A.NEXT_REPRICING_DT > A.ACTUAL_MATURITY_DT THEN -- 重定价日大于贷款到期日期取到期日期
                TO_CHAR(A.ACTUAL_MATURITY_DT, 'YYYY-MM-DD')
               ELSE
                NVL(TO_CHAR(A.NEXT_REPRICING_DT, 'YYYY-MM-DD'),
                    TO_CHAR(A.ACTUAL_MATURITY_DT, 'YYYY-MM-DD'))
             END INT_REPRICE_DATE, --贷款利率重新定价日 修改同存量个人贷款
           TP7.GUAR_TYPE AS GUAR_TYPE, --贷款担保方式
           CASE WHEN LA.RN = 1 THEN '1' WHEN LA.RN >= 2 THEN '0' END FIRST_LOAN_FLG,  --28  是否首次贷款
           CASE
             WHEN A.LOAN_BUY_INT = 'Y' THEN
              'LF04' --转让：是否转入贷款
             WHEN A.RESCHED_FLG = 'Y' /*OR A.RENEW_FLG = 'Y' OR
                  A.REPAY_FLG = 'Y'*/ THEN
              'LF05' --重组方式：重组标志、无还本续贷标志、借新还旧标志
             ELSE
              'LF01' --正常
           END AS LOAN_STATUS, --贷款状态
           NULL AS ASS_SEC_PRO_TYPE, --资产证券化产品代码

           CASE WHEN A.LOAN_KIND_CD = '91'   THEN  --资产重组
             CASE
             WHEN A.RENEW_FLG = 'Y' THEN
              '01' --无还本续贷
             WHEN A.REPAY_FLG = 'Y' THEN
              '02'--借新还旧
             WHEN A.RESCHED_FLG = 'Y' THEN
              '09'--其他
           END END AS LOAN_TYPE, --贷款重组方式

           '1' AS TRANS_TYPE, --发放/收回标识
           '1' AS SERIAL_NO, --交易流水号
           CASE WHEN A.ACCT_TYP = '010302' THEN '线上联合消费贷款'
             ELSE A.USEOFUNDS END AS USEOFUNDS, --贷款用途
          IS_DATE AS CJRQ, --采集日期
           A.ORG_NUM AS NBJGH, --内部机构号

        CASE
               WHEN A.DEPARTMENTD = '公司金融' THEN
                'E'
               WHEN A.DEPARTMENTD = '普惠金融' THEN
                'S'
               WHEN A.DEPARTMENTD = '个人信贷' THEN
                'P'
               /*WHEN A.DEPARTMENTD = '磐石村镇' THEN
                'V'*/
               WHEN A.DEPARTMENTD = '德惠长银' THEN
                'E'
           ELSE'99'  END BIZ_LINE_ID, -- 业务条线
           'unVerify' AS VERIFY_STATUS, --校验状态
           --'000000' FRNBJGH, --法人内部机构号
         /*CASE WHEN A.ORG_NUM LIKE '5100%' THEN '510000' ELSE '990000' END FRNBJGH,*/
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
            '600000'----20230620多法人新增
           ELSE '990000'
             END FRNBJGH,
               kh.cust_id,
           KH.CUST_NAME
      FROM SMTMODS.L_ACCT_LOAN A --贷款借据信息表
      LEFT JOIN SMTMODS.L_CUST_ALL B --全量客户信息表
        ON A.CUST_ID = B.CUST_ID
       AND B.DATA_DATE = IS_DATE
     INNER JOIN L_PUBL_ORG_BRA_TMP C --机构表
        ON A.ORG_NUM = C.ORG_NUM
       AND C.DATA_DATE = IS_DATE
     INNER JOIN (
       SELECT ROW_NUMBER() OVER(PARTITION BY T.CUST_ID ORDER BY T.CUST_ID DESC) RN,
              T.*
       FROM JS_102_GRKHXX T
       WHERE T.DATA_DATE = IS_DATE
       --AND T.NBJGH NOT LIKE '0215%' --过滤磐石数据
  ) KH  --个人客户信息
        ON A.CUST_ID = KH.CUST_ID
        AND KH.DATA_DATE = IS_DATE
        AND KH.RN=1
      LEFT JOIN SMTMODS.L_CUST_IDENTIFY D --客户证件信息表
        ON B.CUST_ID = D.CUST_ID
       AND B.ID_TYPE = D.ID_TYPE
       AND B.ID_NO = D.ID_NO
       AND D.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_CUST_C E --对公客户补充信息表
        ON A.CUST_ID = E.CUST_ID
       AND E.DATA_DATE = IS_DATE
      LEFT JOIN M_DICT_REMAPPING X --映射表
        ON B.NATION_CD1 = X.ORI_VALUES
       AND X.DICT_CODE = 'COUNTRY_CODE_3_TO_NUM'
      LEFT JOIN DBFS_TMP TP7 --贷款担保方式中间表--在总调加工
        ON a.LOAN_NUM = TP7.LOAN_NUM
      LEFT JOIN SMTMODS.L_PUBL_RATE U
        ON U.CCY_DATE =
           TO_DATE(TO_CHAR(A.DRAWDOWN_DT, 'YYYYMMDD'), 'YYYYMMDD')
       AND U.BASIC_CCY = A.CURR_CD --????
       AND U.FORWARD_CCY = 'CNY' --????
       LEFT JOIN (SELECT T.LOAN_NUM,
                  --20211027 SHIYU  已与业务确认当同一客户下借据放款日期相同，比对借据表取小的借据号
                  ROW_NUMBER() OVER(PARTITION BY T.CUST_ID ORDER BY T.DRAWDOWN_DT ASC,LOAN_NUM ) RN
             FROM SMTMODS.L_ACCT_LOAN T
            where t.data_date = IS_DATE) LA
      ON A.LOAN_NUM = LA.LOAN_NUM
      LEFT JOIN L_ACCT_LOAN_SUOQI T1 --L_ACCT_LOAN表20241031数据 以此判断办理缩期时点
        ON A.LOAN_NUM = T1.LOAN_NUM
       AND A.MATURITY_DT_BEFORE = T1.MATURITY_DT_BEFORE
       AND A.MATURITY_DT = T1.MATURITY_DT

     WHERE (TRUNC(A.DRAWDOWN_DT, 'MM') = TRUNC(D_DATADATE, 'MM') OR
            --[2025-09-18] [周立鹏] [JLBA202507300010关于新一代信贷管理系统新增线上微贷板块的需求][从需求] 新增产品'DK001000100041'
            --(A.INTERNET_LOAN_FLG = 'Y' AND A.DRAWDOWN_DT = (TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD'), 'MM') - 1)) --modify by 87v : 互联网贷款数据晚一天下发，上月末数据当月取
            ((A.INTERNET_LOAN_FLG = 'Y' OR A.CP_ID = 'DK001000100041') AND A.DRAWDOWN_DT = (TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD'), 'MM') - 1)) --modify by 87v : 互联网贷款数据晚一天下发，上月末数据当月取
            )
       AND C.NATION_CD = 'CHN'
       AND (SUBSTR(A.ACCT_TYP, 1, 2) IN ('01', '02', '04', '05', '08') OR
            A.ACCT_TYP = '070101')
       --AND SUBSTR(A.ACCT_TYP, 1, 4) <> '0199'
       AND (B.CUST_TYPE = '00' OR E.CUST_TYP = '3')
      -- AND (A.CIRCLE_LOAN_FLG = 'N' OR A.CIRCLE_LOAN_FLG IS NULL)
       AND A.DATA_DATE=IS_DATE
       AND A.CANCEL_FLG='N'
	   AND A.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250228 JLBA202408200012 资产未转让
	   ; --核销标志为否
  COMMIT; -----'生成数据-过滤条件一发放';



  VS_STEP := '2';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  INSERT /*+ append*/
  INTO JS_201_GRDKFS /*@PBOCD_34*/
  NOLOGGING --------'生成数据-过滤条件二收回';
    (DATA_DATE, --数据日期
     ORG_CODE, --金融机构代码
     ORG_NUM, --内部机构号
     ORG_AREA_COD, --金融机构地区代码
     CUST_ID_TYPE, --借款人证件类型
     CUST_ID_NO, --借款人证件代码
     REG_AREA_CODE, --借款人地区代码
     LOAN_NUM, --贷款借据编码
     CONTRACT_CODE, --贷款合同编码
     PRODUCT_TYPE, --贷款产品类别
     LOAN_GRANT_DATE, --贷款发放日期
     LOAN_DUE_DATE, --贷款到期日期
     LOAN_ACTUAL_DUE_DATE, --贷款实际终止日期
     CURR_CODE, --币种
     TRANS_AMT, --贷款发生金额
     TRANS_AMT_RMB, --贷款发生金额折人民币
     INT_RATE_TYPE, --利率是否固定
     INT_RATE, --利率水平
     PRI_BENCH_MARK, --贷款定价基准类型
     BASE_INT_RAT, --基准利率
     FINA_SUPPORT_FLG, --贷款财政扶持方式
     INT_REPRICE_DATE, --贷款利率重新定价日
     GUAR_TYPE, --贷款担保方式
     FIRST_LOAN_FLG, --是否首次贷款
     LOAN_STATUS, --贷款状态
     ASS_SEC_PRO_TYPE, --资产证券化产品代码
     LOAN_TYPE, --贷款重组方式
     TRANS_TYPE, --发放/收回标识
     SERIAL_NO, --交易流水号
     USEOFUNDS, --贷款用途
     CJRQ, --采集日期
     NBJGH, --内部机构号
     BIZ_LINE_ID, --业务条线
     VERIFY_STATUS, --校验状态
     FRNBJGH, --法人内部机构号
     CUST_ID,
     CUST_NAME
     )
    SELECT/*+ parallel(4)*/ IS_DATE AS DATA_DATE, --数据日期
            null AS ORG_CODE, --金融机构代码
           A.ORG_NUM AS ORG_NUM, --内部机构号
           null AS ORG_AREA_COD, --金融机构地区代码
           KH.CUST_ID_TYPE, --借款人证件类型
           
           --[2025-12-03] [周立鹏] [无需求][李楠] 调整证件类型、证件代码、担保方式取数逻辑
            /*CASE
             WHEN E.CUST_TYP='3' THEN
               NVL(E.LEGAL_CARD_NO,E.ID_NO)
             ELSE
              B.ID_NO
              END AS CUST_ID_NO, --借款人证件号码*/
           KH.CUST_ID_NO AS CUST_ID_NO, --借款人证件号码
           
           KH.REG_REGION_CODE AS CONTRACT_CODE,--借款人地区代码
           A.LOAN_NUM AS LOAN_NUM, --贷款借据编码
           A.ACCT_NUM AS CONTRACT_CODE, --贷款合同编码
           CASE
             WHEN F.ACCT_TYP LIKE '0401%' OR (F.ACCT_TYP='070101' AND F.ONLENDING_USAGE='D') OR (F.ITEM_CD LIKE '1305%' AND F.CURR_CD <> 'CNY') THEN 'F081'
             WHEN F.ACCT_TYP LIKE '0402%' OR (F.ACCT_TYP='070101' AND F.ONLENDING_USAGE='E')  OR (F.ITEM_CD LIKE '1305%' AND F.CURR_CD = 'CNY') THEN 'F082'
             WHEN F.ACCT_TYP LIKE '0101%' THEN
              'F0211'
             WHEN F.ACCT_TYP = '010301' THEN
              'F0212'
             WHEN F.ACCT_TYP IN ('010402', '010403', '010404') THEN
              'F02131'
             WHEN F.ACCT_TYP IN ('010401', '010405', '010499') THEN
              'F02132'
             WHEN F.ACCT_TYP = '010399' THEN
               'F0219'
             /*WHEN F.ACCT_TYP = '019999' THEN
                CASE WHEN F.ORG_NUM LIKE  '5100%' THEN
                    'F0211'
                ELSE
                    'F0219'
                END*/
             WHEN F.ACCT_TYP = '019999' THEN 'F0219'
             WHEN F.ACCT_TYP = '0202' OR F.ACCT_TYP LIKE '0102%' OR
                  (F.ACCT_TYP = '070101' AND F.ONLENDING_USAGE = 'A') THEN
              'F022'
             WHEN F.ACCT_TYP LIKE '0201%' OR
                  (F.ACCT_TYP = '070101' AND F.ONLENDING_USAGE = 'B') THEN
              'F023'
             WHEN F.ACCT_TYP = '0801' THEN
              'F041'
             WHEN F.ACCT_TYP = '05' THEN
              'F09'
             WHEN F.ACCT_TYP = '0203' OR
                  (F.ACCT_TYP = '070101' AND F.ONLENDING_USAGE = 'C') THEN
              'F12'
             WHEN F.ACCT_TYP = '010302' THEN
               'F0219'
          END AS PRODUCT_TYPE, --贷款产品类别
           CASE
             WHEN F.LOAN_BUY_INT = 'N' THEN
              TO_CHAR(F.DRAWDOWN_DT, 'YYYY-MM-DD')
             WHEN F.LOAN_BUY_INT = 'Y' THEN
              TO_CHAR(F.IN_DRAWDOWN_DT, 'YYYY-MM-DD')
           END AS LOAN_GRANT_DATE, --贷款发放日期
           --TO_CHAR(F.MATURITY_DT, 'YYYY-MM-DD') AS LOAN_DUE_DATE, --贷款到期日期
           
           --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 处理缩期
           CASE
             WHEN F.MATURITY_DT_BEFORE > F.MATURITY_DT  /*AND T1.LOAN_NUM IS NULL */THEN --处理缩期 zhoulp 20241217
               TO_CHAR(F.MATURITY_DT_BEFORE, 'YYYY-MM-DD')
             ELSE
               TO_CHAR(F.MATURITY_DT, 'YYYY-MM-DD')
           END  LOAN_DUE_DATE, --12 贷款到期日期

           TO_CHAR(F.FINISH_DT, 'YYYY-MM-DD' )LOAN_ACTUAL_DUE_DATE, --贷款实际终止日期
           F.CURR_CD AS CURR_CODE,  --币种
           
           --[2026-03-19] [周立鹏] [JLBA202412040002_关于在金融基础数据修改部分业务取数逻辑的需求][李楠] 贷款发生额负值调整
           ABS(A.PAY_AMT) AS TRANS_AMT, --贷款发生金额
           CASE
             WHEN F.CURR_CD = 'CNY' THEN
              ABS(A.PAY_AMT)
             ELSE
              ABS(A.PAY_AMT) * U.CCY_RATE
           END AS TRANS_AMT_RMB, --贷款发生金额折人民币
           CASE
             WHEN F.INT_RATE_TYP = 'F' THEN
              'RF01'
             WHEN F.INT_RATE_TYP LIKE 'L%' THEN
              'RF02'
           END AS INT_RATE_TYPE, --利率是否固定
           F.REAL_INT_RAT AS INT_RATE,--利率水平
           CASE
             WHEN F.PRICING_BASE_TYPE = 'A01' THEN
              'TR01'
             WHEN F.PRICING_BASE_TYPE = 'A0201' THEN
              'TR02'
             WHEN F.PRICING_BASE_TYPE = 'A0202' THEN
              'TR03'
             WHEN F.PRICING_BASE_TYPE = 'A0203' THEN
              'TR04'
             WHEN F.PRICING_BASE_TYPE = 'C' THEN
              'TR05'
             WHEN F.PRICING_BASE_TYPE = 'D' THEN
              'TR06'
             WHEN F.PRICING_BASE_TYPE = 'B01' THEN
              'TR07'
             WHEN F.PRICING_BASE_TYPE = 'B02' THEN
              'TR08'
             WHEN F.PRICING_BASE_TYPE = 'E' THEN
              'TR09'
             ELSE
              'TR99'
           END AS PRI_BENCH_MARK, --贷款定价基准类型
          CASE
          WHEN F.INT_RATE_TYP='F'   THEN
            NULL
            ELSE F.BASE_INT_RAT END BASE_INT_RAT ,  --基准利率
           CASE
             WHEN F.COMP_INT_TYP = '110' THEN
              'A0101'
             WHEN F.COMP_INT_TYP = '120' THEN
              'A0102'
             WHEN F.COMP_INT_TYP = '210' THEN
              'A0201'
             WHEN F.COMP_INT_TYP = '220' THEN
              'A0202'
             WHEN F.COMP_INT_TYP = '300' THEN
              'B'
             WHEN F.COMP_INT_TYP = '500' THEN
              'C'
             WHEN F.COMP_INT_TYP = '400' THEN
              'Z'
           END AS FINA_SUPPORT_FLG, --贷款财政扶持方式
           --NVL(TO_CHAR(F.NEXT_REPRICING_DT, 'YYYY-MM-DD'),TO_CHAR(F.ACTUAL_MATURITY_DT, 'YYYY-MM-DD')) AS INT_REPRICE_DATE, --贷款利率重新定价日
           
           --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 处理缩期
           CASE
               WHEN F.MATURITY_DT_BEFORE > F.MATURITY_DT /*AND T1.LOAN_NUM IS NULL */THEN --处理缩期 zhoulp 20241217
                TO_CHAR(F.MATURITY_DT, 'YYYY-MM-DD')
               WHEN F.INT_RATE_TYP = 'F' AND F.EXTENDTERM_FLG = 'Y' THEN
                TO_CHAR(F.ACTUAL_MATURITY_DT, 'YYYY-MM-DD') --固定利率，有展期，重定价日是展期到期日
               WHEN F.INT_RATE_TYP = 'F' THEN
                TO_CHAR(F.MATURITY_DT, 'YYYY-MM-DD') --固定利率，无展期，重定价日是到期日
               WHEN F.NEXT_REPRICING_DT < F.DRAWDOWN_DT THEN -- 重定价日小于贷款发放日期取放款日期
                TO_CHAR(F.DRAWDOWN_DT, 'YYYY-MM-DD')
               WHEN F.NEXT_REPRICING_DT > F.ACTUAL_MATURITY_DT THEN -- 重定价日大于贷款到期日期取到期日期
                TO_CHAR(F.ACTUAL_MATURITY_DT, 'YYYY-MM-DD')
               ELSE
                NVL(TO_CHAR(F.NEXT_REPRICING_DT, 'YYYY-MM-DD'),
                    TO_CHAR(F.ACTUAL_MATURITY_DT, 'YYYY-MM-DD'))
             END INT_REPRICE_DATE, --贷款利率重新定价日 修改同存量个人贷款
           --[2025-12-03] [周立鹏] [无需求][李楠] 调整证件类型、证件代码、担保方式取数逻辑
           --NVL(SQ.GUAR_TYPE,TP7.GUAR_TYPE) AS GUAR_TYPE, --27  担保方式
           TP7.GUAR_TYPE AS GUAR_TYPE, --27  担保方式
           CASE WHEN LA.RN = 1 THEN '1' WHEN LA.RN >= 2 THEN '0' END FIRST_LOAN_FLG, --28  是否首次贷款
           CASE
             WHEN A.PAY_TYPE IN ('01', '02', '03', '07', '09') THEN
              'LF01'
             WHEN A.PAY_TYPE = '08' THEN
              'LF02'
             WHEN A.PAY_TYPE = '05' THEN
              'LF03'
             WHEN A.PAY_TYPE = '11' THEN
              'LF04'
             WHEN A.PAY_TYPE IN ('04', '12') OR A.RENEW_FLG = 'Y' THEN
              'LF05'
             WHEN A.PAY_TYPE = '06' THEN
              'LF06'
             WHEN A.ABS_TRANS_FLG = 'Y' THEN
              'LF07'
             WHEN A.PAY_TYPE = '10' THEN
              'LF08'
             ELSE
              'LF99'
           END AS LOAN_STATUS, --贷款状态
           null AS ASS_SEC_PRO_TYPE,  --资产证券化产品代码
           CASE WHEN A.PAY_TYPE  IN ('04', '12') THEN
               CASE
             WHEN A.RENEW_FLG = 'Y' THEN
              '01'
             WHEN A.PAY_TYPE = '12' THEN
              '02'
             WHEN A.PAY_TYPE = '04' THEN
              '09'
           END END AS LOAN_TYPE, --贷款重组方式
           
           --[2026-03-19] [周立鹏] [JLBA202412040002_关于在金融基础数据修改部分业务取数逻辑的需求][李楠] 贷款发生额负值调整
           CASE WHEN A.PAY_AMT < 0 THEN '1' ELSE '0' END AS TRANS_TYPE, --发放/收回标识
           A.TX_NO AS SERIAL_NO, --交易流水号
           CASE WHEN F.ACCT_TYP = '010302' THEN '线上联合消费贷款'
             ELSE F.USEOFUNDS END AS USEOFUNDS, --贷款用途
           IS_DATE AS CJRQ, --采集日期
           A.ORG_NUM AS NBJGH, --内部机构号

       CASE
               WHEN A.DEPARTMENTD = '公司金融' THEN
                'E'
               WHEN A.DEPARTMENTD = '普惠金融' THEN
                'S'
               WHEN A.DEPARTMENTD = '个人信贷' THEN
                'P'
               /*WHEN A.DEPARTMENTD = '磐石村镇' THEN
                'V'*/
               WHEN A.DEPARTMENTD = '德惠长银' THEN
                'E'
           ELSE'99'  END BIZ_LINE_ID, --32 业务条线
           'unVerify' AS VERIFY_STATUS, --校验状态

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
            '600000'----20230620多法人新增
           ELSE '990000'
             END FRNBJGH,
           kh.cust_id,
           KH.CUST_NAME
 FROM SMTMODS.L_TRAN_LOAN_PAYM A --贷款还款明细信息表
     INNER JOIN SMTMODS.L_ACCT_LOAN F --贷款借据信息表
        ON A.LOAN_NUM = F.LOAN_NUM
       AND F.DATA_DATE = IS_DATE
     INNER JOIN SMTMODS.L_CUST_ALL B --全量客户信息表
        ON F.CUST_ID = B.CUST_ID
       AND B.DATA_DATE = IS_DATE
     INNER JOIN L_PUBL_ORG_BRA_TMP C --机构表
        ON A.ORG_NUM = C.ORG_NUM
       AND C.DATA_DATE = IS_DATE
       INNER JOIN (
       SELECT ROW_NUMBER() OVER(PARTITION BY T.CUST_ID ORDER BY T.CUST_ID DESC) RN,
              T.*
       FROM JS_102_GRKHXX T
       WHERE T.DATA_DATE = IS_DATE
  ) KH --个人客户信息
        ON F.CUST_ID = KH.CUST_ID
        AND KH.DATA_DATE = IS_DATE
        AND KH.RN=1

      LEFT JOIN SMTMODS.L_CUST_IDENTIFY D --客户证件信息表
        ON B.CUST_ID = D.CUST_ID
       AND B.ID_TYPE = D.ID_TYPE
       AND B.ID_NO = D.ID_NO
       AND D.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_CUST_C E --对公客户补充信息表
        ON F.CUST_ID = E.CUST_ID
       AND E.DATA_DATE = IS_DATE
      LEFT JOIN M_DICT_REMAPPING X --映射表
        ON B.NATION_CD1 = X.ORI_VALUES
       AND X.DICT_CODE = 'COUNTRY_CODE_3_TO_NUM'
      LEFT JOIN SMTMODS.L_PUBL_RATE U
        ON U.CCY_DATE =
           TO_DATE(TO_CHAR(A.REPAY_DT, 'YYYYMMDD'), 'YYYYMMDD')
       AND U.BASIC_CCY = F.CURR_CD --基准币种
       AND U.FORWARD_CCY = 'CNY' --折算币种
       LEFT JOIN (SELECT T.LOAN_NUM,
                  --20211027 SHIYU  已与业务确认当同一客户下借据放款日期相同，比对借据表取小的借据号
                  ROW_NUMBER() OVER(PARTITION BY T.CUST_ID ORDER BY T.DRAWDOWN_DT ASC,LOAN_NUM ) RN
             FROM SMTMODS.L_ACCT_LOAN T
            where t.data_date = IS_DATE) LA
       ON A.LOAN_NUM = LA.LOAN_NUM
     LEFT JOIN PBOCD_JS_201_CLGRDK_SQ SQ --收回方向优先取上期，有当月放款当月收回的取不到上期，则取贷款担保方式中间表
        ON a.LOAN_NUM = SQ.LOAN_NUM AND SQ.CJRQ=VS_LAST_TEXT
     LEFT JOIN DBFS_TMP TP7 --贷款担保方式中间表--在总调加工
        ON a.LOAN_NUM = TP7.LOAN_NUM
     LEFT JOIN L_ACCT_LOAN_SUOQI T1 --L_ACCT_LOAN表20241031数据 以此判断办理缩期时点
        ON F.LOAN_NUM = T1.LOAN_NUM
       AND F.MATURITY_DT_BEFORE = T1.MATURITY_DT_BEFORE
       AND F.MATURITY_DT = T1.MATURITY_DT

     WHERE (TRUNC(A.REPAY_DT, 'MM') = TRUNC(D_DATADATE, 'MM') OR
           --[2025-09-18] [周立鹏] [JLBA202507300010关于新一代信贷管理系统新增线上微贷板块的需求][从需求] 新增产品'DK001000100041'
           --(F.INTERNET_LOAN_FLG = 'Y' AND
           ((F.INTERNET_LOAN_FLG = 'Y' OR F.CP_ID = 'DK001000100041' )AND
           A.REPAY_DT = (TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD'), 'MM') - 1)) --modify by 87v : 互联网贷款数据晚一天下发，上月末数据当月取
     )  AND   TRUNC(TO_DATE(A.DATA_DATE, 'YYYYMMDD'), 'MM')=TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD'), 'MM')  --支持重跑，取不到下个月的还款
       AND C.NATION_CD = 'CHN'
       AND A.PAY_AMT <> 0
       AND (SUBSTR(F.ACCT_TYP, 1, 2) IN ('01', '02', '04', '05', '08') OR
            F.ACCT_TYP = '070101')
      -- AND SUBSTR(F.ACCT_TYP, 1, 4) <> '0199'
       AND (B.CUST_TYPE = '00' OR E.CUST_TYP = '3')
       AND (
         F.CANCEL_FLG='N' --未核销
     AND F.LOAN_STOCKEN_DATE IS NULL  --add by haorui 20250228 JLBA202408200012 资产未转让
       OR ( F.CANCEL_FLG='Y' --当月核销
       AND EXISTS(
       SELECT 1 FROM SMTMODS.L_ACCT_WRITE_OFF XX WHERE  XX.DATA_DATE = IS_DATE
         AND substr(TO_CHAR(XX.WRITE_OFF_DATE,'yyyymmdd'),1,6)=substr(IS_DATE,1,6)
         AND A.LOAN_NUM = XX.LOAN_NUM))
      );
  COMMIT;  -----------'生成数据-过滤条件二收回';


   VS_STEP := '3';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
/*  --机构变更按照老机构报，如果不用了的机构可以把ORG_NEW表EFF_FLAG字段改成'N'
  UPDATE JS_201_GRDKFS A
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

   VS_STEP := '4';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_201_GRDKFS_TMP', OI_RETCODE);
  INSERT INTO PBOCD_JS_201_GRDKFS_TMP
      (DATA_DATE, --  数据日期
     ORG_CODE, --1  金融机构代码
     ORG_NUM, --2  内部机构号
     ORG_AREA_COD, --3  金融机构地区代码
     CUST_ID_TYPE, --4  借款人证件类型
     CUST_ID_NO, --5  借款人证件代码
     REG_AREA_CODE, --6  借款人地区代码
     LOAN_NUM, --7  贷款借据编码
     CONTRACT_CODE, --8  贷款合同编码
     PRODUCT_TYPE, --9  贷款产品类别
     LOAN_GRANT_DATE, --10  贷款发放日期
     LOAN_DUE_DATE, --11  贷款到期日期
     LOAN_ACTUAL_DUE_DATE, --12  贷款实际终止日期
     CURR_CODE, --13  币种
     TRANS_AMT, --14  贷款发生金额
     TRANS_AMT_RMB, --15  贷款发生金额折人民币
     INT_RATE_TYPE, --16  利率是否固定
     INT_RATE, --17  利率水平
     PRI_BENCH_MARK, --18  贷款定价基准类型
     BASE_INT_RAT, --19  基准利率
     FINA_SUPPORT_FLG, --20  贷款财政扶持方式
     INT_REPRICE_DATE, --21  贷款利率重新定价日
     GUAR_TYPE, --22  贷款担保方式
     FIRST_LOAN_FLG, --23  是否首次贷款
     LOAN_STATUS, --24  贷款状态
     ASS_SEC_PRO_TYPE, --25  资产证券化产品代码
     LOAN_TYPE, --26  贷款重组方式
     TRANS_TYPE, --27  发放/收回标识
     REPORT_ID, --28
     CJRQ, --29
     NBJGH, --30
     BIZ_LINE_ID, --31
     VERIFY_STATUS, --32
     BSCJRQ, --33
     SERIAL_NO, --34  交易流水号
     USEOFUNDS, --35  贷款用途
     FRNBJGH, --36  法人内部机构号
     CUST_ID, --37 客户号
     CUST_NAME --38 客户名称
     )
    SELECT VS_TEXT, -- 数据日期
           T.ORG_CODE, --1  金融机构代码
           T.ORG_NUM, --2  内部机构号
           T.ORG_AREA_COD, --3  金融机构地区代码
           T.CUST_ID_TYPE, --4  借款人证件类型
           T.CUST_ID_NO, --5  借款人证件代码
           T.REG_AREA_CODE, --6  借款人地区代码
           T.LOAN_NUM, --7  贷款借据编码
           T.CONTRACT_CODE, --8  贷款合同编码
           T.PRODUCT_TYPE, --9  贷款产品类别
           T.LOAN_GRANT_DATE, --10  贷款发放日期
           T.LOAN_DUE_DATE, --11  贷款到期日期
           T.LOAN_ACTUAL_DUE_DATE, --12  贷款实际终止日期
           T.CURR_CODE, --13  币种
           T.TRANS_AMT, --14  贷款发生金额
           T.TRANS_AMT_RMB, --15  贷款发生金额折人民币
           T.INT_RATE_TYPE, --16  利率是否固定
           T.INT_RATE, --17  利率水平
           T.PRI_BENCH_MARK, --18  贷款定价基准类型
           CASE
             WHEN T.INT_RATE_TYPE = 'RF01' THEN
              NULL
             ELSE
              NVL(T.BASE_INT_RAT, T.BASE_INT_RAT)
            END, --19  基准利率
           T.FINA_SUPPORT_FLG, --20  贷款财政扶持方式
           T.INT_REPRICE_DATE, --21  贷款利率重新定价日
           T.GUAR_TYPE, --22  贷款担保方式
           T.FIRST_LOAN_FLG, --23  是否首次贷款
           T.LOAN_STATUS, --24  贷款状态
           T.ASS_SEC_PRO_TYPE, --25  资产证券化产品代码
           T.LOAN_TYPE, --26  贷款重组方式
           T.TRANS_TYPE, --27  发放/收回标识
           SYS_GUID() REPORT_ID, --28  报送ID
           IS_DATE CJRQ, --29  采集日期
           T.ORG_NUM, --30
           T.BIZ_LINE_ID, --31  业务条线
           T.VERIFY_STATUS, --32
           T.BSCJRQ, --33
           T.SERIAL_NO, --34  交易流水号
           NVL(REPLACE(T.USEOFUNDS, CHR(09), ''), T.USEOFUNDS), --35  贷款用途
           T.FRNBJGH,
           T.CUST_ID, --37 客户号
           T.CUST_NAME --38 客户名称
      FROM JS_201_GRDKFS T
     WHERE TRIM(T.DATA_DATE) = IS_DATE;

  COMMIT;

--[2025-04-18] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠]经辉哥确认，此逻辑可保留(记录在发给楠姐的一阶段提测清单反馈里面)
--除透支类、线上联合消费贷款类业务以外的贷款，当贷款状态为核销、剥离、转让、重组、
--以物抵债、债转股且发放/收回标识为收回时，贷款实际终止日期不能为空
merge into PBOCD_JS_201_GRDKFS_TMP A
using (select loan_num, max(repay_dt) as repay_dt
         from SMTMODS.L_TRAN_LOAN_PAYM a
        where substr(data_date,1,6) = substr(IS_DATE,1,6)
        group by loan_num) b
on (a.loan_num = b.loan_num)
when matched then
  update
     set a.loan_actual_due_date = to_char(b.repay_dt, 'yyyy-mm-dd')
   where cjrq = IS_DATE
     and loan_actual_due_date is null
     and (loan_status in ('LF02', 'LF03', 'LF04', 'LF07', 'LF08', 'LF06') or
         (loan_status = 'LF05' and loan_type in ('01', '02')))
     and trans_type = '0'
     and product_type not like 'F04%'
     and (useofunds not like '%线上联合消费贷款%' or USEOFUNDS is null);
COMMIT;

-------以下为原应用层逻辑

  SP_PBOCD_PARTITIONS(IS_DATE,'PBOCD_JS_201_GRDKFS',OI_RETCODE);
  INSERT INTO PBOCD_JS_201_GRDKFS
       (DATA_DATE,  --  数据日期
        ORG_CODE,  --1  金融机构代码
        ORG_NUM,  --2  内部机构号
        ORG_AREA_COD,  --3  金融机构地区代码
        CUST_ID_TYPE,  --4  借款人证件类型
        CUST_ID_NO,  --5  借款人证件代码
        REG_AREA_CODE,  --6  借款人地区代码
        LOAN_NUM,  --7  贷款借据编码
        CONTRACT_CODE,  --8  贷款合同编码
        PRODUCT_TYPE,  --9  贷款产品类别
        LOAN_GRANT_DATE,  --10  贷款发放日期
        LOAN_DUE_DATE,  --11  贷款到期日期
        LOAN_ACTUAL_DUE_DATE,  --12  贷款实际终止日期
        CURR_CODE,  --13  币种
        TRANS_AMT,  --14  贷款发生金额
        TRANS_AMT_RMB,  --15  贷款发生金额折人民币
        INT_RATE_TYPE,  --16  利率是否固定
        INT_RATE,  --17  利率水平
        PRI_BENCH_MARK,  --18  贷款定价基准类型
        BASE_INT_RAT,  --19  基准利率
        FINA_SUPPORT_FLG,  --20  贷款财政扶持方式
        INT_REPRICE_DATE,  --21  贷款利率重新定价日
        GUAR_TYPE,  --22  贷款担保方式
        FIRST_LOAN_FLG,  --23  是否首次贷款
        LOAN_STATUS,  --24  贷款状态
        ASS_SEC_PRO_TYPE,  --25  资产证券化产品代码
        LOAN_TYPE,  --26  贷款重组方式
        TRANS_TYPE,  --27  发放/收回标识
        REPORT_ID,  --28
        CJRQ,  --29
        NBJGH,  --30
        BIZ_LINE_ID,  --31
        VERIFY_STATUS,  --32
        BSCJRQ,  --33
        SERIAL_NO,  --34  交易流水号
        USEOFUNDS,  --35  贷款用途
        FRNBJGH,  --36  法人内部机构号
        CUST_ID, --37 客户号
        CUST_NAME --38 客户名称
        )
         SELECT VS_TEXT, -- 数据日期

        NVL(OB.ID_NO,OB.UP_ID_NO), --金融机构代码
        T.ORG_NUM,  --2  内部机构号

        OB.REGION_CD, --3  金融机构地区代码
  --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 优化冗余加工逻辑
        --NVL(T.CUST_ID_TYPE,T.CUST_ID_TYPE),  --4  借款人证件类型
        T.CUST_ID_TYPE,  --4  借款人证件类型
        T.CUST_ID_NO,  --5  借款人证件代码
        
        --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
        --NVL(BK.REG_AREA_CODE,T.REG_AREA_CODE),  --6  借款人地区代码
        T.REG_AREA_CODE,  --6  借款人地区代码
        
        T.LOAN_NUM,  --7  贷款借据编码
        T.CONTRACT_CODE,  --8  贷款合同编码
  --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 优化冗余加工逻辑
        --NVL(T.PRODUCT_TYPE,T.PRODUCT_TYPE),  --9  贷款产品类别
        --NVL(T.LOAN_GRANT_DATE,T.LOAN_GRANT_DATE),  --10  贷款发放日期
        --NVL(T.LOAN_DUE_DATE,T.LOAN_DUE_DATE),  --11  贷款到期日期
        T.PRODUCT_TYPE,  --9  贷款产品类别
        T.LOAN_GRANT_DATE,  --10  贷款发放日期
        T.LOAN_DUE_DATE,  --11  贷款到期日期
        T.LOAN_ACTUAL_DUE_DATE,  --12  贷款实际终止日期
        T.CURR_CODE,  --13  币种
        T.TRANS_AMT,  --14  贷款发生金额
        T.TRANS_AMT_RMB,  --15  贷款发生金额折人民币
  
  --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 优化冗余加工逻辑
        /*NVL(T.INT_RATE_TYPE,T.INT_RATE_TYPE),  --16  利率是否固定
        NVL(T.INT_RATE,T.INT_RATE),  --17  利率水平
        NVL(T.PRI_BENCH_MARK,T.PRI_BENCH_MARK),  --18  贷款定价基准类型
        CASE WHEN T.INT_RATE_TYPE = 'RF01' THEN NULL ELSE NVL(T.BASE_INT_RAT,T.BASE_INT_RAT) END,  --19  基准利率
        NVL(T.FINA_SUPPORT_FLG,T.FINA_SUPPORT_FLG),  --20  贷款财政扶持方式
        NVL(T.INT_REPRICE_DATE,T.INT_REPRICE_DATE),  --21  贷款利率重新定价日*/
  T.INT_RATE_TYPE,  --16  利率是否固定
        T.INT_RATE,  --17  利率水平
        T.PRI_BENCH_MARK,  --18  贷款定价基准类型
        CASE WHEN T.INT_RATE_TYPE = 'RF01' THEN NULL ELSE T.BASE_INT_RAT END,  --19  基准利率
        T.FINA_SUPPORT_FLG,  --20  贷款财政扶持方式
        T.INT_REPRICE_DATE,  --21  贷款利率重新定价日
  
        --[2025-12-03] [周立鹏] [无需求][李楠] 调整证件类型、证件代码、担保方式取数逻辑
        --NVL(BK.GUAR_TYPE,T.GUAR_TYPE),  --22  贷款担保方式
        T.GUAR_TYPE,  --22  贷款担保方式
        T.FIRST_LOAN_FLG,  --23  是否首次贷款
        --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 优化冗余加工逻辑
        --NVL(T.LOAN_STATUS,T.LOAN_STATUS),  --24  贷款状态
        T.LOAN_STATUS,  --24  贷款状态
        T.ASS_SEC_PRO_TYPE,  --25  资产证券化产品代码
        T.LOAN_TYPE,  --26  贷款重组方式
        T.TRANS_TYPE,  --27  发放/收回标识
        SYS_GUID() REPORT_ID,  --28  报送ID
        IS_DATE CJRQ,  --29  采集日期
        T.ORG_NUM,  --30
        '99' BIZ_LINE_ID,  --31  业务条线
        T.VERIFY_STATUS,  --32
        T.BSCJRQ,  --33
        T.SERIAL_NO||CASE WHEN T2.SERIAL_NO IS NOT NULL THEN TRANS_TYPE END,  --34  交易流水号
        --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 优化冗余加工逻辑
        --NVL(REPLACE(T.USEOFUNDS,CHR(09),''),T.USEOFUNDS),  --35  贷款用途
        REPLACE(T.USEOFUNDS,CHR(09),''),  --35  贷款用途
        T.FRNBJGH,  --36  法人内部机构号
        T.CUST_ID, --37 客户号
        T.CUST_NAME --38 客户名称
     FROM PBOCD_JS_201_GRDKFS_TMP T
     LEFT JOIN JS_201_GRDKFS_TEMP02 T2
     ON T.SERIAL_NO = T2.SERIAL_NO
     LEFT JOIN PBOCD_JS_201_CLGRDK_SQ BK
     ON T.LOAN_NUM = BK.LOAN_NUM
     AND BK.CJRQ = VS_LAST_TEXT

     LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=T.NBJGH AND OB.DATA_DATE=IS_DATE
     WHERE TRIM(T.DATA_DATE) = VS_TEXT;

  COMMIT;

--插入信用卡数据
INSERT  INTO PBOCD_JS_201_GRDKFS NOLOGGING
       (DATA_DATE,  --  数据日期
        ORG_CODE,  --1  金融机构代码
        ORG_NUM,  --2  内部机构号
        ORG_AREA_COD,  --3  金融机构地区代码
        CUST_ID_TYPE,  --4  借款人证件类型
        CUST_ID_NO,  --5  借款人证件代码
        REG_AREA_CODE,  --6  借款人地区代码
        LOAN_NUM,  --7  贷款借据编码
        CONTRACT_CODE,  --8  贷款合同编码
        PRODUCT_TYPE,  --9  贷款产品类别
        LOAN_GRANT_DATE,  --10  贷款发放日期
        LOAN_DUE_DATE,  --11  贷款到期日期
        LOAN_ACTUAL_DUE_DATE,  --12  贷款实际终止日期
        CURR_CODE,  --13  币种
        TRANS_AMT,  --14  贷款发生金额
        TRANS_AMT_RMB,  --15  贷款发生金额折人民币
        INT_RATE_TYPE,  --16  利率是否固定
        INT_RATE,  --17  利率水平
        PRI_BENCH_MARK,  --18  贷款定价基准类型
        BASE_INT_RAT,  --19  基准利率
        FINA_SUPPORT_FLG,  --20  贷款财政扶持方式
        INT_REPRICE_DATE,  --21  贷款利率重新定价日
        GUAR_TYPE,  --22  贷款担保方式
        FIRST_LOAN_FLG,  --23  是否首次贷款
        LOAN_STATUS,  --24  贷款状态
        ASS_SEC_PRO_TYPE,  --25  资产证券化产品代码
        LOAN_TYPE,  --26  贷款重组方式
        TRANS_TYPE,  --27  发放/收回标识
        REPORT_ID,  --28 报送ID
        CJRQ,  --29  采集日期
        NBJGH,  --30  内部机构
        BIZ_LINE_ID,  --31  业务条线
        SERIAL_NO,  --32  交易流水号
        USEOFUNDS,  --33  贷款用途
        FRNBJGH  --34  法人内部机构号
        )
SELECT
        VS_TEXT --  数据日期
        ,TRIM(T.ORG_CODE) --1  金融机构代码
        ,'009803' --2  内部机构号
        ,SUBSTR(TRIM(T.ORG_AREA_COD),1,6) --3  金融机构地区代码
        ,TRIM(NVL(AA.CUST_ID_TYPE,T.CUST_ID_TYPE)) --4  借款人证件类型
        ,TRIM(T.CUST_ID_NO) --5  借款人证件代码
        ,TRIM(T.REG_AREA_CODE) --6  借款人地区代码
        ,TRIM(T.LOAN_NUM) --7  贷款借据编码
        ,TRIM(T.CONTRACT_CODE) --8  贷款合同编码
        ,TRIM(T.PRODUCT_TYPE) --9  贷款产品类别
        ,'' --10  贷款发放日期
        --,NVL2(TRIM(T.LOAN_DUE_DATE),CASE WHEN SUBSTR(TRIM(T.LOAN_DUE_DATE),5,2) = '02' THEN SUBSTR(TRIM(T.LOAN_DUE_DATE),1,4)||'-'||SUBSTR(TRIM(T.LOAN_DUE_DATE),5,2)||'-'||'28' WHEN SUBSTR(TRIM(T.LOAN_DUE_DATE),5,2) IN('04','06','09','11') THEN SUBSTR(TRIM(T.LOAN_DUE_DATE),1,4)||'-'||SUBSTR(TRIM(T.LOAN_DUE_DATE),5,2)||'-'||'30' ELSE SUBSTR(TRIM(T.LOAN_DUE_DATE),1,4)||'-'||SUBSTR(TRIM(T.LOAN_DUE_DATE),5,2)||'-'||'31' END,T1.LOAN_DUE_DATE)  --11  贷款到期日期
        ,'' --11  贷款到期日期
        ,'' --12  贷款实际终止日期
        ,TRIM(T.CURR_CODE) --13  币种
        ,TRIM(T.TRANS_AMT) --14  贷款发生金额
        ,TRIM(T.TRANS_AMT_RMB) --15  贷款发生金额折人民币
        ,TRIM(T.INT_RATE_TYPE) --16  利率是否固定
        ,case when TRIM(T.TRANS_TYPE)='1' then 18 else to_number(TRIM(T.INT_RATE)) end --17  利率水平
        ,TRIM(T.PRI_BENCH_MARK) --18  贷款定价基准类型
        ,CASE WHEN TRIM(T.INT_RATE_TYPE) = 'RF02' THEN TRIM(T.BASE_INT_RAT) ELSE NULL END --19  基准利率
        ,TRIM(T.FINA_SUPPORT_FLG) --20  贷款财政扶持方式
        ,'' --21  贷款利率重新定价日
        ,TRIM(T.GUAR_TYPE) --22  贷款担保方式
        ,'' --TRIM(T.FIRST_LOAN_FLG) --23  是否首次贷款
        ,TRIM(T.LOAN_STATUS) --24  贷款状态
        ,TRIM(T.ASS_SEC_PRO_TYPE) --25  资产证券化产品代码
        ,TRIM(T.LOAN_TYPE) --26  贷款重组方式
        ,TRIM(T.TRANS_TYPE) --27  发放/收回标识
        ,SYS_GUID() REPORT_ID  --28  报送ID
        ,IS_DATE   --29  采集日期
        ,'009803' --30 内部机构
        ,'99'  ----31  业务条线
        ,TRIM(T.SERIAL_NO)||TRIM(T.TRANS_TYPE)  --32  交易流水号
        ,'消费' --NVL(TRIM(REPLACE(T.USEOFUNDS,CHR(13),'')),T1.USEOFUNDS)  --33  贷款用途
        ,'990000'
FROM PBOCD_DATACORE.JS_201_GRDKFS_XYK T
LEFT JOIN PBOCD_JS_102_GRKHXX AA ON T.CUST_ID_NO=AA.CUST_ID_NO AND AA.CJRQ=IS_DATE AND AA.FRNBJGH='990000'
WHERE T.TRANS_AMT<>0 AND T.DATA_DATE=IS_DATE;

COMMIT;

--------------------------处理缩期开始-------------------------------------------------------------------------------------------------
--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 处理缩期 规则同存量
    EXECUTE IMMEDIATE 'TRUNCATE TABLE PBOCD_JS_201_GRDKFS_20251215';
    INSERT INTO PBOCD_JS_201_GRDKFS_20251215 SELECT * FROM PBOCD_JS_201_GRDKFS WHERE CJRQ = IS_DATE;
    COMMIT;
    
    MERGE INTO PBOCD_JS_201_GRDKFS A
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
             A.INT_REPRICE_DATE = TO_CHAR(D.MATURITY_DT_T2,'YYYY-MM-DD')
       WHERE A.CJRQ = IS_DATE;
  COMMIT;
  

    MERGE INTO PBOCD_JS_201_GRDKFS A
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
             A.INT_REPRICE_DATE = ''
       WHERE A.CJRQ = IS_DATE;
  COMMIT;



    MERGE INTO PBOCD_JS_201_GRDKFS A
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
             A.INT_REPRICE_DATE = TO_CHAR(D.MATURITY_DT_BEFORE,'YYYY-MM-DD')
       WHERE A.CJRQ = IS_DATE;
  COMMIT;


/*  --处理缩期 ZHOULP 20241217 按20241031表刷缩期状态的数据。会忽略掉之后的变化，比如之后又做了展期
  MERGE INTO PBOCD_JS_201_GRDKFS A
  USING (SELECT B.*
           FROM JS_201_CLGRDK_SUOQI B
          INNER JOIN L_ACCT_LOAN_SUOQI C
             ON B.LOAN_NUM = C.LOAN_NUM
            AND (C.MATURITY_DT_BEFORE > C.MATURITY_DT OR B.LOAN_STATUS = 'LS04')
         ) D --报送层20241031数据
  ON (A.LOAN_NUM = D.LOAN_NUM)
  WHEN MATCHED THEN
    UPDATE
       SET A.LOAN_DUE_DATE    = D.LOAN_DUE_DATE,
           A.INT_REPRICE_DATE = D.INT_REPRICE_DATE
     WHERE A.CJRQ = IS_DATE
    ;
COMMIT;
  --处理缩期 ZHOULP 20241217 按20241031表刷到期日变化了的数据。这类数据是当初某期按合同表取了到期日，导致以后每期都要刷
  MERGE INTO PBOCD_JS_201_GRDKFS A
  USING JS_201_CLGRDK_SUOQI D --报送层20241031数据
  ON (A.LOAN_NUM = D.LOAN_NUM)
  WHEN MATCHED THEN
    UPDATE
       SET A.LOAN_DUE_DATE    = D.LOAN_DUE_DATE
     WHERE A.CJRQ = IS_DATE
    ;
COMMIT;*/
---------------------------处理缩期结束--------------------------------------------------------------------------------------------------------------

--[2025-12-03] [周立鹏] [无需求][李楠] 调整证件类型、证件代码、担保方式取数逻辑
/*--证件类型客户信息表刷
MERGE INTO PBOCD_JS_201_GRDKFS A
USING (SELECT * FROM PBOCD_JS_102_GRKHXX WHERE CJRQ = IS_DATE) b
on (A.CUST_ID_NO = B.CUST_ID_NO AND A.FRNBJGH=B.FRNBJGH)
WHEN MATCHED THEN
  UPDATE SET A.CUST_ID_TYPE = B.CUST_ID_TYPE WHERE A.CJRQ = IS_DATE;
COMMIT;*/

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
/*--[2025-12-03] [周立鹏] [无需求][李楠] 调整证件类型、证件代码、担保方式取数逻辑
  --JS_102_GRKHXX_BL 个人客户信息
   MERGE INTO PBOCD_JS_201_GRDKFS A
  USING JS_102_GRKHXX_BL B
  ON (A.CUST_ID = B.CUST_ID AND A.CJRQ = IS_DATE)
  WHEN MATCHED THEN
  UPDATE SET
  \*A.CUST_ID_TYPE = B.CUST_ID_TYPE
  ,A.CUST_ID_NO = B.CUST_ID_NO_NEW
  ,*\A.REG_AREA_CODE = B.REG_REGION_CODE;
  COMMIT;*/

--[2025-12-03] [周立鹏] [无需求][李楠] 调整证件类型、证件代码、担保方式取数逻辑
/*MERGE INTO  PBOCD_JS_201_GRDKFS T
USING (SELECT * FROM  PBOCD_JS_201_CLGRDK_SQ WHERE CJRQ = VS_LAST_TEXT ) F
ON (T.LOAN_NUM=F.LOAN_NUM)
WHEN MATCHED THEN UPDATE SET
T.GUAR_TYPE=F.GUAR_TYPE
WHERE T.CJRQ= IS_DATE
AND T.TRANS_TYPE ='0'
;
COMMIT;*/


--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
--公主岭地区代码
/*UPDATE PBOCD_JS_201_GRDKFS
   SET ORG_AREA_COD = '220184'
 WHERE CJRQ = IS_DATE
   AND ORG_AREA_COD = '220381';
COMMIT;*/

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
/*UPDATE PBOCD_JS_201_GRDKFS
   SET REG_AREA_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND REG_AREA_CODE = '220381';
COMMIT;

--[2025-12-03] [周立鹏] [无需求][李楠] 调整证件类型、证件代码、担保方式取数逻辑
UPDATE PBOCD_JS_201_GRDKFS
   SET \*CUST_ID_TYPE = 'B99',*\ REG_AREA_CODE = '220105'
 WHERE CJRQ = IS_DATE
   AND CUST_ID_NO = 'KOR110064032206';
COMMIT;*/

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
/*--调用特殊处理程序
--地区代码999999、空、000开头的数据，先按本期客户表刷，刷不到再按上期客户表刷
  BSP_SP_JS_SPOP(IS_DATE,OI_RETCODE,OI_RETCODE_DEC,'PBOCD_JS_201_GRDKFS');*/
  -------------------------------------------------------------------------


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
