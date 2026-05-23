CREATE OR REPLACE PROCEDURE BSP_SP_JS_201_CLDWDK(IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_201_CLDWDK
  -- 业务域: 贷款类
  -- 用途: 生成接口表 JS_201_CLDWDK 存量单位贷款信息
  -- 参数
  --    IS_DATE 输入，传入跑批日期
  --    OI_RETCODE 输出，用来标识存储过程执行过程中是否出现异常
  -- 引用的监管集市表
  --    SMTMODS.L_ACCT_LOAN                                — 贷款借据信息表
  --    SMTMODS.L_AGRE_LOAN_CONTRACT                       — 贷款合同信息表
  --    SMTMODS.L_CODE_DICTIONARY                          — L_CODE_DICTIONARY
  --    SMTMODS.L_PUBL_RATE                                — 汇率表
  --    SMTMODS.v_pub_idx_dk_zqdqrjj                       — v_pub_idx_dk_zqdqrjj
  -- 修改历史
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段 上线日期：2025-04-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT                  VARCHAR2(1000) DEFAULT NULL; --字符型  过程描述
  VS_LAST_TEXT       VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  VS_OWNER             VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
  NUM               INTEGER;
  VS_NMONTH         VARCHAR2(10);
BEGIN
  VS_TEXT      := to_char(to_date(IS_DATE, 'yyyymmdd'), 'yyyy-mm-dd');
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');

  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_201_CLDWDK';
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
   WHERE TABLE_NAME = 'JS_201_CLDWDK'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE JS_201_CLDWDK ADD PARTITION P' ||
                      IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE JS_201_CLDWDK TRUNCATE PARTITION P' ||
                    IS_DATE;

  INSERT /*+ APPEND*/ INTO JS_201_CLDWDK NOLOGGING
    (DATA_DATE, --  数据日期
     ORG_CODE, --1 金融机构代码
     ORG_NUM, --2 内部机构号
     ORG_AREA_COD, --3 金融机构地区代码
     CUST_ID_TYPE, --4 借款人证件类型
     CUST_ID_NO, --5 借款人证件代码
     DEPT_TYPE, --6 借款人国民经济部门
     INDUSTRY_TYPE, --7 借款人行业
     REG_AREA_CODE, --8 借款人地区代码
     ENT_CON_ECO_ELEM, --9 借款人经济成分
     ENT_SCALE, --10  借款人企业规模
     LOAN_NUM, --11  贷款借据编码
     CONTRACT_CODE, --12  贷款合同编码
     PRODUCT_TYPE, --13  贷款产品类别
     LOAN_PURPOSE_CD, --14  贷款实际投向
     LOAN_GRANT_DATE, --15  贷款发放日期
     LOAN_DUE_DATE, --16  贷款到期日期
     DEFER_END_DATE, --17  贷款展期到期日期
     CURR_CODE, --18  币种
     BALANCE, --19  贷款余额
     BALANCE_RMB, --20  贷款余额折人民币
     INT_RATE_TYPE, --21  利率是否固定
     INT_RATE, --22  利率水平
     PRI_BENCH_MARK, --23  贷款定价基准类型
     BASE_INT_RAT, --24  基准利率
     FINA_SUPPORT_FLG, --25  贷款财政扶持方式
     INT_REPRICE_DATE, --26  贷款利率重新定价日
     GUAR_TYPE, --27  贷款担保方式
     FIRST_LOAN_FLG, --28  是否首次贷款
     LOAN_CLASSIFY, --29  贷款质量
     LOAN_STATUS, --30  贷款状态
     OD_TYPE, --31  逾期类型
     USEOFUNDS, --32  贷款用途
     BIZ_LINE_ID, --33  业务条线
     CUST_ID, --34 客户号
     CUST_NAME --35 客户名称
     )
    SELECT  /*+parallel(4)*/  IS_DATE as data_date, --  数据日期
           '',--OFF.JRJGBM ORG_CODE, --1  金融机构代码
           T.ORG_NUM ORG_NUM, --2  内部机构号
           '',--OFF.AREA_ID ORG_AREA_COD, --3  金融机构地区代码

           --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 直取ECIF的ID_TYPE、ID_NO
           /*CASE WHEN G.ID_TYPE IN ('236','239','2X','24') AND LENGTH(G.ID_NO) = 18 AND G.ID_NO NOT LIKE  '00000%' AND G.ID_NO NOT LIKE '%000000' THEN 'A01'
                        WHEN M.CUST_ID_NO_NEW IS NOT NULL THEN 'A01' --手工表中的证件代码
                        WHEN G.ORGANIZATIONCODE IS NOT NULL AND LENGTH(REPLACE(G.ORGANIZATIONCODE ,'-','')) = 9 THEN 'A02'
            ELSE 'A03'
            END  CUST_ID_TYPE,--4 借款人证件类型

           CASE WHEN G.ID_TYPE IN ('236','239','2X','24') AND LENGTH(G.ID_NO) = 18 AND G.ID_NO NOT LIKE  '00000%' AND G.ID_NO NOT LIKE '%000000' THEN G.ID_NO
                        WHEN M.CUST_ID_NO_NEW IS NOT NULL THEN UPPER(M.CUST_ID_NO_NEW)  --手工表中的证件代码
                        WHEN G.ORGANIZATIONCODE IS NOT NULL AND LENGTH(REPLACE(G.ORGANIZATIONCODE ,'-','')) = 9 THEN REPLACE(G.ORGANIZATIONCODE,'-','')
            ELSE G.ID_NO
            END  CUST_ID_NO, --5 借款人证件代码*/
           D1.PBOCD_CODE AS CUST_ID_TYPE,--4 借款人证件类型
           CASE WHEN D1.PBOCD_CODE = 'A02' THEN REPLACE(G.ID_NO,'-') ELSE G.ID_NO END AS CUST_ID_NO, --5 借款人证件代码
           
           --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 与客户表同步
           --CASE WHEN G.CUST_TYP = '5' THEN 'A04' ELSE G.DEPT_TYPE END DEPT_TYPE , --6 借款人国民经济部门 --MODIFY BY DW(20220809)
           CASE WHEN G.CUST_TYP <> '5' THEN G.DEPT_TYPE ELSE 'A04' END DEPT_TYPE , --6 借款人国民经济部门 --MODIFY BY DW(20220809)

           SUBSTRB(TRIM(G.CORP_BUSINSESS_TYPE), 0, 3), --7 借款人行业  modify by dw(20220805)

           NVL(REPLACE(G.REGION_CD,'待治理',''),G.ORG_AREA) AS REG_AREA_CODE, --8 借款人地区代码   modify by dw(20220805)

           DECODE(G.CORP_HOLD_TYPE,'A01','A0102','A02','A0101', 'B01','A0202','B02','A0201','C01','B0102', 'C02','B0101', 'D01','B0202', 'D02','B0201','E01','B0302', 'E02','B0301') , --9 借款人经济成分  modify by dw(20220805)

           CASE WHEN SUBSTR(G.CUST_TYP,1,1) IN ('0','1') OR G.CUST_TYP = '9101' THEN
             CASE WHEN G.CORP_SCALE = 'B' THEN 'CS01'
                       WHEN G.CORP_SCALE = 'M' THEN 'CS02'
                       WHEN G.CORP_SCALE = 'S' THEN 'CS03'
                       WHEN G.CORP_SCALE = 'T' THEN 'CS04'
             ELSE 'CS05' END
           ELSE 'CS05' END , --10  借款人企业规模 modify by dw(20220805) 如果客户类型是企业客户，取企业规模大中小微型，否则均为其他
           ---modify by dw(20220805) end
           T.LOAN_NUM LOAN_NUM, --11  贷款借据编码
           T.ACCT_NUM CONTRACT_CODE, --12  贷款合同编码
           CASE
             WHEN  T.LOAN_NUM in ('01260120001203330801','01260120001203330802','01260120001203330803','02100119001190853001') then
               'F12' /*并购贷款无标识,临时处理*/
             WHEN /*T.ACCT_TYP LIKE '0401%'
               OR (T.ACCT_TYP='070101' AND T.ONLENDING_USAGE='D')
               OR */
               --(T.ITEM_CD LIKE '132%' AND T.CURR_CD <> 'CNY') THEN
                (T.ITEM_CD LIKE '1305%' AND T.CURR_CD <> 'CNY') THEN---20220629-夏文博改
                 'F081'
             WHEN /*T.ACCT_TYP LIKE '0402%'
               OR (T.ACCT_TYP='070101' AND T.ONLENDING_USAGE='E')
               OR*/
               --(T.ITEM_CD LIKE '132%' AND T.CURR_CD = 'CNY') THEN
                (T.ITEM_CD LIKE '1305%' AND T.CURR_CD = 'CNY') THEN  ---20220629-夏文博改
                 'F082'
             WHEN (T.ACCT_TYP = '0202' AND T.USEOFUNDS LIKE '%并购%') THEN
               'F12'
             WHEN (T.ACCT_TYP = '0202' AND T.loan_business_typ = '1') OR
                         (T.ACCT_TYP LIKE '0202%' AND Q.PROD_NAME IN ('商业房开发贷款','法人商用房按揭贷款(企业名)')) OR
                         (T.ACCT_TYP = '0202' AND Q.PROD_NAME IN ('银团贷款(牵头行)','银团贷款(参与行)','票据置换')) THEN
              'F023'
/*             WHEN T.ACCT_TYP like '0201%' AND T.loan_business_typ = '4' THEN
              'F022'*/--注释掉，与大集中同步zhoulp20231207
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
             WHEN T.ACCT_TYP = '0202' OR T.ACCT_TYP LIKE '0102%' OR (T.ACCT_TYP = '070101' AND T.ONLENDING_USAGE = 'A') THEN
              'F022'
             WHEN T.ACCT_TYP LIKE '0201%' OR (T.ACCT_TYP = '070101' AND T.ONLENDING_USAGE = 'B') THEN
              'F023'
             WHEN T.ACCT_TYP = '0801' THEN
              'F041'
             WHEN T.ACCT_TYP = '05' THEN
              'F09'
             WHEN T.ACCT_TYP = '0203' OR (T.ACCT_TYP = '070101' AND T.ONLENDING_USAGE = 'C') THEN
              'F12'
             WHEN SUBSTR(T.ITEM_CD,1,4) IN ('1306') THEN
               CASE WHEN T.ACCT_TYP = '0901' THEN 'F052'
                    WHEN T.ACCT_TYP = '0903' THEN 'F051'
                    WHEN T.ACCT_TYP = '0904' THEN 'F053'
                    WHEN T.ACCT_TYP = '0999' THEN 'F059'
               END
           END AS PRODUCT_TYPE, --13  贷款产品类别
           SUBSTRB(T.LOAN_PURPOSE_CD, 1, 4) LOAN_PURPOSE_CD, --14  贷款实际投向
           TO_CHAR(T.DRAWDOWN_DT, 'YYYY-MM-DD') LOAN_GRANT_DATE, --15  贷款发放日期
           
           --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 加入缩期逻辑
           TO_CHAR(T.MATURITY_DT, 'YYYY-MM-DD') as LOAN_DUE_DATE, --16  贷款到期日期
           /*CASE 
             WHEN T.MATURITY_DT_BEFORE > T.MATURITY_DT THEN --缩期
               TO_CHAR(T.MATURITY_DT_BEFORE, 'YYYY-MM-DD')
             ELSE 
             -- 正常/展期/延期都取T.MATURITY_DT
             -- 集市对T.MATURITY_DT的取数逻辑是有展期的从展期协议表里取原贷款终止日期，无展期的从各台账取原贷款终止日期
               TO_CHAR(T.MATURITY_DT, 'YYYY-MM-DD')
           END  LOAN_DUE_DATE, --16  贷款到期日期*/
           
           --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 加入缩期逻辑
           CASE WHEN ZQ.EXTENDTERM_FLG = 'Y' /*展期标志*/ THEN TO_CHAR(ZQ.ACTUAL_MATURITY_DT, 'YYYY-MM-DD') END DEFER_END_DATE, --17  贷款展期到期日期
           /*CASE
           --延期无展期到期日；先展后延取展期后到期日，有名单的按名单取
             WHEN ZQ.EXTENDTERM_FLG = 'Y' THEN
               TO_CHAR(ZQ.ACTUAL_MATURITY_DT, 'YYYY-MM-DD') --展期
             WHEN T.MATURITY_DT_BEFORE > T.MATURITY_DT THEN --缩期
               TO_CHAR(T.MATURITY_DT, 'YYYY-MM-DD')
           END DEFER_END_DATE, --17  贷款展期到期日期*/
           
           
           T.CURR_CD CURR_CODE, --18  币种
           T.LOAN_ACCT_BAL BALANCE, --19  贷款余额
           T.LOAN_ACCT_BAL * R.CCY_RATE BALANCE_RMB, --20  贷款余额折人民币
           CASE WHEN T.INT_RATE_TYP = 'F' THEN 'RF01' ELSE  'RF02' END INT_RATE_TYPE, --21  利率是否固定
           T.REAL_INT_RAT INT_RATE, --22  利率水平
           /*CASE WHEN T.BENM_INRAT_TYPE='10' then 'TR08'
              WHEN T.BENM_INRAT_TYPE='30' then 'TR05'
                ELSE 'TR99' END
           PRI_BENCH_MARK,*/
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
           END AS PRI_BENCH_MARK, --23  贷款定价基准类型  (1-),10：基准利率 20：公积金贷款利率（吉林银行暂时没有）30：LPR利率
           CASE
             WHEN T.INT_RATE_TYP = 'F' THEN
              NULL
             ELSE
              T.BASE_INT_RAT
           END BASE_INT_RAT, --24  基准利率
           /*t.FINA_SUPPORT_FLG, --25  贷款财政扶持方式*/
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
           END AS TFINA_SUPPORT_FLG, --25  贷款财政扶持方式
           CASE
             /*--[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 加入缩期逻辑
             WHEN T.MATURITY_DT_BEFORE > T.MATURITY_DT THEN --缩期
              TO_CHAR(T.MATURITY_DT, 'YYYY-MM-DD')*/
             WHEN T.INT_RATE_TYP = 'F' AND T.EXTENDTERM_FLG = 'Y' THEN
              TO_CHAR(T.ACTUAL_MATURITY_DT, 'YYYY-MM-DD') --固定利率，有展期，重定价日是展期到期日
             WHEN T.INT_RATE_TYP = 'F' THEN
              TO_CHAR(T.MATURITY_DT, 'YYYY-MM-DD') --固定利率，无展期，重定价日是到期日
              WHEN T.NEXT_REPRICING_DT < T.DRAWDOWN_DT THEN -- 重定价日小于贷款发放日期取放款日期
               TO_CHAR(T.DRAWDOWN_DT, 'YYYY-MM-DD')
             WHEN T.NEXT_REPRICING_DT > T.ACTUAL_MATURITY_DT THEN-- 重定价日大于贷款到期日期取到期日期
               TO_CHAR(T.ACTUAL_MATURITY_DT, 'YYYY-MM-DD')
             ELSE
              NVL(TO_CHAR(T.NEXT_REPRICING_DT, 'YYYY-MM-DD'),
                  TO_CHAR(T.ACTUAL_MATURITY_DT, 'YYYY-MM-DD'))
           END as INT_REPRICE_DATE, --26  贷款利率重新定价日

           TP7.GUAR_TYPE AS GUARANTY_TYP, --27  贷款担保方式
           CASE WHEN LA.RN = 1 THEN '1' WHEN LA.RN >= 2 THEN '0' END FIRST_LOAN_FLG, --28  是否首次贷款
           CASE
             WHEN T.LOAN_GRADE_CD = '1'  THEN 'FQ01'  --正常
             WHEN T.LOAN_GRADE_CD = '2'  THEN 'FQ02'  --关注
             WHEN T.LOAN_GRADE_CD = '3'  THEN 'FQ03'  --次级
             WHEN T.LOAN_GRADE_CD = '4'  THEN 'FQ04'  --可疑
             WHEN T.LOAN_GRADE_CD = '5'  THEN 'FQ05'  --损失
           END LOAN_CLASSIFY, --29  贷款质量
           CASE
             WHEN T.OD_FLG = 'Y' THEN  'LS03' --逾期标志
             WHEN T.EXTENDTERM_FLG = 'Y' THEN 'LS02' --展期标志
             /*--[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 加入缩期逻辑
             WHEN T.MATURITY_DT_BEFORE > T.MATURITY_DT THEN 'LS04' --缩期*/
           ELSE 'LS01'  --正常
           END LOAN_STATUS, --30  贷款状态
           CASE
             WHEN T.P_OD_DT IS NOT NULL AND T.I_OD_DT IS NOT NULL AND
                  TO_CHAR(T.P_OD_DT, 'YYYYMMDD') <> '99991231' AND
                  TO_CHAR(T.I_OD_DT, 'YYYYMMDD') <> '99991231' and
                  T.OD_FLG = 'Y' THEN
              '03'
             WHEN T.P_OD_DT IS NOT NULL AND
                  TO_CHAR(T.P_OD_DT, 'YYYYMMDD') <> '99991231' and
                  T.OD_FLG = 'Y' THEN
              '01' /*本金逾期日期*/
             WHEN T.I_OD_DT IS NOT NULL AND
                  TO_CHAR(T.I_OD_DT, 'YYYYMMDD') <> '99991231' and
                  T.OD_FLG = 'Y' THEN
              '02' /*利息逾期日期*/
           END OD_TYPE, --31  逾期类型
           
           --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊字符
           --T.USEOFUNDS, --32  贷款用途
           REGEXP_REPLACE(REGEXP_REPLACE(T.USEOFUNDS,'[!?^？！ |]'),CHR(9)) AS USEOFUNDS, --贷款用途35
           
           NVL(CASE
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
               END,
               '99'), --33  业务条线
           T.CUST_ID, --34 客户号
          G.CUST_NAM --35 客户名称
      FROM SMTMODS.L_ACCT_LOAN T --贷款借据表
     INNER JOIN L_CUST_C_TMP G ---对公客户表
        ON T.CUST_ID = G.CUST_ID
        AND G.CUST_TYP<>'3' --去除个体工商户
       AND G.DATA_DATE = IS_DATE
      LEFT JOIN JS_102_FTYKHX_MAPPING M --手工维护表
        ON T.CUST_ID = M.COD_CUST_ID

      LEFT JOIN SMTMODS.L_AGRE_LOAN_CONTRACT Q  --贷款合同信息表
      ON T.ACCT_NUM = Q.CONTRACT_NUM AND T.DATA_DATE = Q.DATA_DATE

      LEFT JOIN SMTMODS.L_PUBL_RATE R --汇率信息表
        ON R.DATA_DATE = IS_DATE
       AND R.BASIC_CCY = T.CURR_CD
       AND R.FORWARD_CCY = 'CNY'
       AND R.DATA_DATE = IS_DATE

      LEFT JOIN DBFS_TMP TP7 --贷款担保方式中间表--在总调里加工
        ON T.LOAN_NUM = TP7.LOAN_NUM
      
      --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
      LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY D1
        ON G.ID_TYPE = D1.L_CODE
       AND D1.CODE_CLMN_NAME = 'ID_TYPE' --证件类型
       
      LEFT JOIN SMTMODS.L_CODE_DICTIONARY D2
        ON G.CORP_HOLD_TYPE = D2.CODE
       AND D2.CODE_CLMN_NAME = 'CORP_HOLD_TYPE' --企业控股类型
      /*LEFT JOIN SMTMODS.L_CODE_DICTIONARY D3
        ON trim(G.DEPT_TYPE) = D3.CODE
       AND D3.CODE_CLMN_NAME = 'DEPT_TYPE' --国民经济部门*/
      LEFT JOIN (SELECT T.LOAN_NUM,
                --20211027 SHIYU  已与业务确认当同一客户下借据放款日期相同，比对借据表取小的借据号
                ROW_NUMBER() OVER(PARTITION BY T.CUST_ID ORDER BY T.DRAWDOWN_DT ASC,LOAN_NUM ) RN
           FROM smtmods.L_ACCT_LOAN T
          where t.data_date = IS_DATE) LA
        ON T.LOAN_NUM = LA.LOAN_NUM
     LEFT JOIN SMTMODS.v_pub_idx_dk_zqdqrjj ZQ
        ON T.LOAN_NUM = ZQ.LOAN_NUM AND T.DATA_DATE = ZQ.DATA_DATE
     where t.data_date = IS_DATE
       AND T.LOAN_ACCT_BAL > 0
       AND SUBSTR(T.ITEM_CD,1,4) IN ('1303','1305','1306') -- 20240926_ZHOULP_JLBA202406280007_新增1306垫款科目
       AND T.CANCEL_FLG = 'N' --去掉核销数据
     AND T.LOAN_STOCKEN_DATE IS NULL  ;  --add by haorui 20250311 JLBA202408200012 资产未转让
  COMMIT;


  SP_PBOCD_PARTITIONS(IS_DATE,'PBOCD_JS_201_CLDWDK',OI_RETCODE);

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_201_CLDWDK TRUNCATE PARTITION P' ||
                    IS_DATE;
  --补录的数据
  INSERT /*+ APPEND*/ INTO PBOCD_JS_201_CLDWDK /*@PBOCD_34*/ NOLOGGING
    (DATA_DATE, --  数据日期
     ORG_CODE, --1 金融机构代码
     ORG_NUM, --2 内部机构号
     ORG_AREA_COD, --3 金融机构地区代码
     CUST_ID_TYPE, --4 借款人证件类型
     CUST_ID_NO, --5 借款人证件代码
     DEPT_TYPE, --6 借款人国民经济部门
     INDUSTRY_TYPE, --7 借款人行业
     REG_AREA_CODE, --8 借款人地区代码
     ENT_CON_ECO_ELEM, --9 借款人经济成分
     ENT_SCALE, --10  借款人企业规模
     LOAN_NUM, --11  贷款借据编码
     CONTRACT_CODE, --12  贷款合同编码
     PRODUCT_TYPE, --13  贷款产品类别
     LOAN_PURPOSE_CD, --14  贷款实际投向
     LOAN_GRANT_DATE, --15  贷款发放日期
     LOAN_DUE_DATE, --16  贷款到期日期
     DEFER_END_DATE, --17  贷款展期到期日期
     CURR_CODE, --18  币种
     BALANCE, --19  贷款余额
     BALANCE_RMB, --20  贷款余额折人民币
     INT_RATE_TYPE, --21  利率是否固定
     INT_RATE, --22  利率水平
     PRI_BENCH_MARK, --23  贷款定价基准类型
     BASE_INT_RAT, --24  基准利率
     FINA_SUPPORT_FLG, --25  贷款财政扶持方式
     INT_REPRICE_DATE, --26  贷款利率重新定价日
     GUAR_TYPE, --27  贷款担保方式
     FIRST_LOAN_FLG, --28  是否首次贷款
     LOAN_CLASSIFY, --29  贷款质量
     LOAN_STATUS, --30  贷款状态
     OD_TYPE, --31  逾期类型
     USEOFUNDS, --32  贷款用途
     REPORT_ID, --33  报送ID
     CJRQ, --34  采集日期
     NBJGH, --35  内部机构号
     BIZ_LINE_ID, --36  业务条线
     VERIFY_STATUS, --37  校验状态
     BSCJRQ, --38 报送周期
     FRNBJGH, --39 法人内部机构号
     CUST_NAME, --借款人名称
     CUST_ID --客户号
     )
    SELECT /*+parallel(4)*/  VS_TEXT DATA_DATE, --  数据日期
           NVL(OB.ID_NO,OB.UP_ID_NO), --金融机构代码
           T.ORG_NUM ORG_NUM, --2 内部机构号
           OB.REGION_CD, --3  金融机构地区代码
           
           --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 直取ECIF的ID_TYPE、ID_NO
           /*CASE WHEN LENGTH(T4.CUST_ID_NO) = 18 THEN 'A01'
                WHEN LENGTH(BU.CUST_ID_NO) = 18 THEN 'A01'
                WHEN LENGTH(T.CUST_ID_NO) NOT IN (9,18) AND LENGTH(BU.CUST_ID_NO) = 9 THEN 'A02'
           ELSE T.CUST_ID_TYPE END CUST_ID_TYPE, --4 借款人证件类型
           CASE WHEN LENGTH(T4.CUST_ID_NO) = 18 THEN T4.CUST_ID_NO
                WHEN LENGTH(BU.CUST_ID_NO) = 18 THEN BU.CUST_ID_NO
                WHEN LENGTH(T.CUST_ID_NO) NOT IN (9,18) AND LENGTH(BU.CUST_ID_NO) = 9 THEN BU.CUST_ID_NO
           ELSE T.CUST_ID_NO END CUST_ID_NO , --5 借款人证件代码*/
           T.CUST_ID_TYPE AS CUST_ID_TYPE, --4 借款人证件类型
           T.CUST_ID_NO AS CUST_ID_NO , --5 借款人证件代码   
          
           --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 与客户表同步
           --NVL(T.DEPT_TYPE,BU.DEPT_TYPE), --6 借款人国民经济部门
           NVL(T4.DEPT_TYPE,T.DEPT_TYPE), --6 借款人国民经济部门
           
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           /*NVL(T.INDUSTRY_TYPE,BU.INDUSTRY_TYPE), --7 借款人行业
           NVL(T.REG_AREA_CODE,BU.REG_AREA_CODE), --8 借款人地区代码*/
           T.INDUSTRY_TYPE, --7 借款人行业
           T.REG_AREA_CODE, --8 借款人地区代码
           

           NVL(T.ENT_CON_ECO_ELEM,BU.ENT_CON_ECO_ELEM) , --9 借款人经济成分
           
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --NVL(T.ENT_SCALE,BU.ENT_SCALE), --10  借款人企业规模
           T.ENT_SCALE, --10  借款人企业规模
           T.LOAN_NUM, --11  贷款借据编码
           T.CONTRACT_CODE, --12  贷款合同编码
           T.PRODUCT_TYPE, --13  贷款产品类别
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --DECODE(T.LOAN_PURPOSE_CD,'C595','G595','C593','G593',T.LOAN_PURPOSE_CD), --14  贷款实际投向
           T.LOAN_PURPOSE_CD, --14  贷款实际投向
           T.LOAN_GRANT_DATE, --15  贷款发放日期
           T.LOAN_DUE_DATE, --16  贷款到期日期
           T.DEFER_END_DATE, --17  贷款展期到期日期
           T.CURR_CODE, --18  币种
           T.BALANCE, --19  贷款余额
           T.BALANCE_RMB, --20  贷款余额折人民币
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           T.INT_RATE_TYPE, --21  利率是否固定
           T.INT_RATE, --22  利率水平
           T.PRI_BENCH_MARK, --23  贷款定价基准类型
           CASE WHEN T.INT_RATE_TYPE = 'RF01' THEN NULL
             ELSE T.BASE_INT_RAT END , --24  基准利率
           t.FINA_SUPPORT_FLG, --25  贷款财政扶持方式
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           /*NVL(T.INT_RATE_TYPE,BU.INT_RATE_TYPE), --21  利率是否固定
           NVL(T.INT_RATE,BU.INT_RATE), --22  利率水平
           CASE WHEN T.LOAN_NUM ='05100118001105466801'  THEN 'TR05' ELSE NVL(T.PRI_BENCH_MARK,BU.PRI_BENCH_MARK) END, --23  贷款定价基准类型
           CASE WHEN NVL(T.INT_RATE_TYPE,BU.INT_RATE_TYPE) = 'RF01' THEN NULL
             ELSE NVL(T.BASE_INT_RAT,BU.BASE_INT_RAT) END , --24  基准利率
           NVL(T.FINA_SUPPORT_FLG,BU.FINA_SUPPORT_FLG), --25  贷款财政扶持方式*/

           T.INT_REPRICE_DATE, --26  贷款利率重新定价日
           T.GUAR_TYPE, --27  贷款担保方式
           T.FIRST_LOAN_FLG, --28  是否首次贷款
           T.LOAN_CLASSIFY, --29  贷款质量
           T.LOAN_STATUS, --30  贷款状态
           T.OD_TYPE, --31  逾期类型
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           T.USEOFUNDS, --32  贷款用途
           --NVL(T.USEOFUNDS, BU.USEOFUNDS), --32  贷款用途
           SYS_GUID(), --33  报送ID
           IS_DATE, --34  采集日期
           T.ORG_NUM , --35  内部机构号
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
          WHEN T.ORG_NUM LIKE '60%' THEN '99' ----20230620多法人新增
             WHEN T.CURR_CODE <> 'CNY' THEN 'G'
           ELSE T.BIZ_LINE_ID END BIZ_LINE_ID, --36  业务条线
           '', --37  校验状态
           '', --38 报送周期
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
             END FRNBJGH,--39 法人内部机构号
           T.CUST_NAME, --客户名称
           T.CUST_ID --客户号
    FROM JS_201_CLDWDK T --去掉核销数据
    LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
    ON OB.ORG_NUM=T.ORG_NUM AND OB.DATA_DATE=IS_DATE
    LEFT JOIN PBOCD_JS_201_CLDWDK_SQ BU --上期数据
    ON T.LOAN_NUM = BU.LOAN_NUM
    AND BU.CJRQ = VS_LAST_TEXT
    LEFT JOIN PBOCD_JS_102_FTYKHX T4 --非同业单位客户，确保证件号码与客户信息一致
        ON T.CUST_ID = T4.CUST_ID
       AND T4.CJRQ = IS_DATE
      WHERE T.DATA_DATE = IS_DATE;

  COMMIT;

--20251218 在线文档标记无法治理
    MERGE INTO  PBOCD_JS_201_CLDWDK   T
    USING DWDK_PRO_TYPE_WXY F
    ON (T.LOAN_NUM=F.LOAN_NUM)
    WHEN MATCHED THEN UPDATE SET
    T.PRODUCT_TYPE=F.OLD
    WHERE T.CJRQ= IS_DATE;
    COMMIT;
    
    --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
    /*MERGE INTO PBOCD_JS_201_CLDWDK T
    USING ENT_SCALE_20211208 F
    ON(T.CUST_ID_NO=F.CUST_ID_NO)
    WHEN MATCHED THEN UPDATE SET
    T.ENT_SCALE=TRIM(F.OLD)
    WHERE T.CJRQ =IS_DATE ;*/

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 上面优先取客户表了，此处可删
    /*MERGE INTO PBOCD_JS_201_CLDWDK T
    USING DEPT_TYPE_20211208 F
    ON(T.CUST_ID_NO=F.CUST_ID_NO)
    WHEN MATCHED THEN UPDATE SET
    T.DEPT_TYPE=TRIM(F.DEPT_TYPE)
    WHERE T.CJRQ =IS_DATE ;*/
    
    --业务要求去掉特殊处理 ZHOULP_20251030
    /*UPDATE  PBOCD_JS_201_CLDWDK SET  ENT_CON_ECO_ELEM ='A0102'
    WHERE CJRQ =IS_DATE
    AND CUST_ID_NO ='91220722677318619F' ;
    COMMIT;*/

    --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 直取ECIF的ID_TYPE、ID_NO
    /*UPDATE PBOCD_JS_201_CLDWDK A SET CUST_ID_NO='91220201702407382A' ,CUST_ID_TYPE ='A01'
    WHERE  CUST_ID_NO = '702407382'
    AND CJRQ=IS_DATE;
    COMMIT;
    UPDATE PBOCD_JS_201_CLDWDK SET CUST_ID_NO='91220201664271460T' WHERE CJRQ =IS_DATE
    AND CUST_ID_NO='G10220211002103306';
    COMMIT;
    UPDATE PBOCD_JS_201_CLDWDK SET CUST_ID_TYPE='A01',CUST_ID_NO='912202827171441161'
    WHERE CJRQ =IS_DATE AND CUST_NAME='桦甸市吉元土产有限公司';
    COMMIT;
    UPDATE PBOCD_JS_201_CLDWDK SET CUST_ID_TYPE='A01',CUST_ID_NO='912202216914715997'
    WHERE CJRQ =IS_DATE AND CUST_NAME='吉林博大农林生物科技有限公司';
    COMMIT;
    UPDATE PBOCD_JS_201_CLDWDK SET CUST_ID_TYPE='A01',CUST_ID_NO='912204005504910788'
    WHERE CJRQ =IS_DATE AND CUST_NAME='吉林省博大伟业制药有限公司';
    COMMIT;*/
    
    
    --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
    /*UPDATE PBOCD_JS_201_CLDWDK SET CUST_NAME = '长春北湖学校',DEPT_TYPE='C99'
    WHERE CJRQ=IS_DATE AND CUST_NAME = '长春市十一高中北湖学校';
    COMMIT;*/

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
/*--存量的利率水平是0的刷上期
MERGE INTO PBOCD_JS_201_CLDWDK A
USING (SELECT *
         FROM PBOCD_JS_201_CLDWDK_SQ B
        WHERE B.CJRQ = VS_LAST_TEXT
          AND B.FRNBJGH = '990000') B
ON (A.LOAN_NUM = B.LOAN_NUM)
WHEN MATCHED THEN
  UPDATE
     SET A.INT_RATE = B.INT_RATE
   WHERE A.CJRQ = IS_DATE
     AND A.FRNBJGH = '990000'
     AND A.INT_RATE = 0;
COMMIT;

--公主岭地区代码
UPDATE PBOCD_JS_201_CLDWDK
   SET ORG_AREA_COD = '220184'
 WHERE CJRQ = IS_DATE
   AND ORG_AREA_COD = '220381';
COMMIT;

UPDATE PBOCD_JS_201_CLDWDK
   SET REG_AREA_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND REG_AREA_CODE = '220381';
COMMIT;*/

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 与客户信息同步
--客户国民经济部门需在符合要求的值域范围内且不能为个人和金融机构
MERGE INTO PBOCD_JS_201_CLDWDK A
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

UPDATE PBOCD_JS_201_CLDWDK A
   SET A.DEPT_TYPE = 'C01' --经业务确认，有限公司的国民经济部门都是C01
 WHERE A.CJRQ = IS_DATE
   AND A.FRNBJGH = '990000'
   AND (SUBSTR(A.DEPT_TYPE, 1, 1) IN ('B', 'D') OR A.DEPT_TYPE IS NULL)
   AND (CUST_NAME LIKE '%有限责任公司' OR CUST_NAME LIKE '%有限公司');
COMMIT;

--企业规模为CS01-大型至CS04-微型的，客户国民经济部门应该为C开头的非金融企业部门或者B开头的金融机构
UPDATE PBOCD_JS_201_CLDWDK A
   SET A.DEPT_TYPE = 'C01' --经业务确认，有限公司的国民经济部门都是C01
 WHERE CJRQ = IS_DATE
   AND FRNBJGH = '990000'
   AND ENT_SCALE IN ('CS01', 'CS02', 'CS03', 'CS04')
   AND SUBSTR(DEPT_TYPE, 1, 1) NOT IN ('B', 'C')
   AND (CUST_NAME LIKE '%有限责任公司' OR CUST_NAME LIKE '%有限公司');
COMMIT;

--客户国民经济部门为C开头且不是C99的非金融企业部门，则企业规模应该在CS01至CS04范围内
--刷完之后应该还有下面按人行要求将企业规模置空的49笔报错
MERGE INTO PBOCD_JS_201_CLDWDK A
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

--调用特殊处理程序
--当贷款展期到期日期不为空且为固定利率贷款时，贷款利率重新定价日应等于贷款展期到期日期--20251226经楠姐确认保留
--当贷款展期到期日期不为空且为浮动利率贷款时，贷款利率重新定价日应小于等于贷款展期到期日期--20251226经楠姐确认保留
--当贷款展期到期日期不为空且贷款状态为LS02-展期时，贷款到期日期应小于贷款展期到期日期--已过渡完，配置表中已改为失效状态
--插入4笔福费廷贷款'20230412070919001','JLKDFFT2023000001001','JLKDFFT2023000002001','JLKDFFT2023000003001'--已过渡完，配置表中已改为失效状态
  BSP_SP_JS_SPOP(IS_DATE,OI_RETCODE,OI_RETCODE_DEC,'PBOCD_JS_201_CLDWDK');
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