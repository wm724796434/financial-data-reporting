CREATE OR REPLACE PROCEDURE BSP_SP_JS_201_DWDKFS(IS_DATE        IN VARCHAR2,
                                                                OI_RETCODE     OUT INTEGER,
                                                                OI_RETCODE_DEC OUT VARCHAR2) AS  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_201_DWDKFS
  -- 业务域: 贷款类
  -- 用途: 生成接口表 JS_201_DWDKFS 单位贷款发生额信息
  -- 参数
  --    IS_DATE 输入，传入跑批日期
  --    OI_RETCODE 输出，用来标识存储过程执行过程中是否出现异常
  -- 引用的监管集市表
  --    SMTMODS.L_ACCT_LOAN                                — 贷款借据信息表
  --    SMTMODS.L_ACCT_WRITE_OFF                           — 资产核销
  --    SMTMODS.L_AGRE_LOAN_CONTRACT                       — 贷款合同信息表
  --    SMTMODS.L_CUST_ALL                                 — 全量客户信息表
  --    SMTMODS.L_PUBL_RATE                                — 汇率表
  --    SMTMODS.L_TRAN_LOAN_PAYM                           — 贷款还款明细信息表
  -- 修改历史
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段 上线日期：2025-04-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_TEXT8          VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
  NUM INTEGER;
  VS_NMONTH VARCHAR2(10);

BEGIN
  VS_TEXT  := to_char(to_date(IS_DATE, 'yyyymmdd'), 'yyyy-mm-dd');
  VS_TEXT8 := to_char(to_date(IS_DATE, 'yyyymmdd'), 'yyyymmdd');
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');

  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_201_DWDKFS';
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
   WHERE TABLE_NAME = 'JS_201_DWDKFS'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE JS_201_DWDKFS ADD PARTITION P' ||
                      IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE JS_201_DWDKFS TRUNCATE PARTITION P' ||
                    IS_DATE;

  --本月新发放贷款
  INSERT /*+append*/
  INTO JS_201_DWDKFS NOLOGGING -----发放！2022.1.13 夏文博修改
    (DATA_DATE, --数据日期  1
     ORG_CODE, --金融机构代码  2
     ORG_NUM, --内部机构号  3
     ORG_AREA_COD, --金融机构地区代码  4
     CUST_ID_TYPE, --借款人证件类型  5
     CUST_ID_NO, --借款人证件代码  6
     DEPT_TYPE, --借款人国民经济部门  7
     INDUSTRY_TYPE, --借款人行业  8
     REG_AREA_CODE, --借款人地区代码  9
     ENT_CON_ECO_ELEM, --借款人经济成分  10
     ENT_SCALE, --借款人企业规模  11
     LOAN_NUM, --贷款借据编码  12
     CONTRACT_CODE, --贷款合同编码  13
     PRODUCT_TYPE, --贷款产品类别  14
     LOAN_PURPOSE_CD, --贷款实际投向  15
     LOAN_GRANT_DATE, --贷款发放日期  16
     LOAN_DUE_DATE, --贷款到期日期  17
     LOAN_ACTUAL_DUE_DATE, --贷款实际终止日期  18
     CURR_CODE, --币种  19
     TRANS_AMT, --贷款发生金额  20
     TRANS_AMT_RMB, --贷款发生金额折人民币  21
     INT_RATE_TYPE, --利率是否固定  22
     INT_RATE, --利率水平  23
     PRI_BENCH_MARK, --贷款定价基准类型  24
     BASE_INT_RAT, --基准利率  25
     FINA_SUPPORT_FLG, --贷款财政扶持方式  26
     INT_REPRICE_DATE, --贷款利率重新定价日  27
     GUAR_TYPE, --贷款担保方式  28
     FIRST_LOAN_FLG, --是否首次贷款  29
     LOAN_STATUS, --贷款状态  30
     ASS_SEC_PRO_TYPE, --资产证券化产品代码  31
     LOAN_TYPE, --贷款重组方式  32
     TRANS_TYPE, --发放/收回标识  33
     SERIAL_NO, --交易流水号  34
     USEOFUNDS, --贷款用途  35
     BIZ_LINE_ID, --业务条线  38
     CUST_NAME, -- 客户名称  41
     CUST_ID)
    SELECT /*+ parallel(4)*/ IS_DATE AS DATA_DATE, --数据日期  1
     '', --OFF.JRJGBM AS ORG_CODE, --金融机构代码 2
     A.ORG_NUM AS ORG_NUM, --内部机构号3
     '', --OFF.AREA_ID AS ORG_AREA_COD, --金融机构地区代码4

            --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 直取ECIF的ID_TYPE、ID_NO
            /*CASE WHEN C.ID_TYPE IN ('236','239','2X','24') AND LENGTH(C.ID_NO) = 18 AND C.ID_NO NOT LIKE  '00000%' AND C.ID_NO NOT LIKE '%000000' THEN 'A01'
                        WHEN M.CUST_ID_NO_NEW IS NOT NULL THEN 'A01' --手工表中的证件代码
                        WHEN C.ORGANIZATIONCODE IS NOT NULL AND LENGTH(REPLACE(C.ORGANIZATIONCODE ,'-','')) = 9 THEN 'A02'
            ELSE 'A03'
            END AS CUST_ID_TYPE, --借款人证件类型5

              CASE WHEN C.ID_TYPE IN ('236','239','2X','24') AND LENGTH(C.ID_NO) = 18 AND C.ID_NO NOT LIKE  '00000%' AND C.ID_NO NOT LIKE '%000000' THEN C.ID_NO
                        WHEN M.CUST_ID_NO_NEW IS NOT NULL THEN UPPER(M.CUST_ID_NO_NEW)  --手工表中的证件代码
                        WHEN C.ORGANIZATIONCODE IS NOT NULL AND LENGTH(REPLACE(C.ORGANIZATIONCODE ,'-','')) = 9 THEN REPLACE(C.ORGANIZATIONCODE,'-','')
            ELSE C.ID_NO
            END AS CUST_ID_NO, --借款人证件代码6*/
            D1.PBOCD_CODE AS CUST_ID_TYPE, --借款人证件类型5
            CASE WHEN D1.PBOCD_CODE = 'A02' THEN REPLACE(C.ID_NO,'-') ELSE C.ID_NO END AS CUST_ID_NO, --借款人证件代码6
            
           --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 与客户表同步
           --CASE WHEN C.CUST_TYP = '5' THEN 'A04' ELSE C.DEPT_TYPE END AS DEPT_TYPE, --借款人国民经济部门7  --MODIFY BY DW(20220809)
           CASE WHEN C.CUST_TYP <> '5' THEN C.DEPT_TYPE ELSE 'A04' END AS DEPT_TYPE, --借款人国民经济部门7  --MODIFY BY DW(20220809)
     
     --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 与存量同步
     /*CASE
       WHEN B.INLANDORRSHORE_FLG = 'Y' THEN
        SUBSTR(C.CORP_BUSINSESS_TYPE, 1, 3)
       ELSE
        '200'
     END AS INDUSTRY_TYPE, --借款人行业8*/
     SUBSTRB(TRIM(C.CORP_BUSINSESS_TYPE), 0, 3) AS INDUSTRY_TYPE, --借款人行业

     NVL(REPLACE(C.REGION_CD, '待治理', ''), C.ORG_AREA), --借款人地区代码9  --modify by dw(20220809) 修改同存量单位贷款
     DECODE(C.CORP_HOLD_TYPE,'A01','A0102','A02','A0101', 'B01','A0202','B02','A0201','C01','B0102', 'C02','B0101', 'D01','B0202', 'D02','B0201','E01','B0302', 'E02','B0301')  AS ENT_CON_ECO_ELEM, --借款人经济成分10
     
     --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 与存量同步  
     /*CASE
       WHEN B.INLANDORRSHORE_FLG = 'Y' THEN*/
        CASE
          WHEN SUBSTR(C.CUST_TYP, 1, 1) IN ('1', '0') OR C.CUST_TYP = '9101' THEN
           CASE
             WHEN C.CORP_SCALE = 'B' THEN
              'CS01'
             WHEN C.CORP_SCALE = 'M' THEN
              'CS02'
             WHEN C.CORP_SCALE = 'S' THEN
              'CS03'
             WHEN C.CORP_SCALE = 'T' THEN
              'CS04'
             ELSE
              'CS05'
           END
          ELSE
                 'CS05'  END/*
              ELSE 'CS05'
     END*/ AS ENT_SCALE, --借款人企业规模11
     A.LOAN_NUM AS LOAN_NUM, --11  贷款借据编码12
     A.ACCT_NUM AS CONTRACT_CODE, --贷款合同编码13
     CASE
             WHEN  A.LOAN_NUM in ('01260120001203330801','01260120001203330802','01260120001203330803','02100119001190853001') then
        'F12' /*并购贷款无标识,临时处理*/
       WHEN (A.ITEM_CD LIKE '1305%' AND A.CURR_CD <> 'CNY') THEN
        'F081'
       WHEN (A.ITEM_CD LIKE '1305%' AND A.CURR_CD = 'CNY') THEN --20220705-夏文博
        'F082'
       WHEN (A.ACCT_TYP = '0202' AND A.USEOFUNDS LIKE '%并购%') THEN
        'F12'
       WHEN (A.ACCT_TYP = '0202' AND A.loan_business_typ = '1') OR
    (A.ACCT_TYP LIKE '0202%' AND Q.PROD_NAME IN ('商业房开发贷款','法人商用房按揭贷款(企业名)')) OR
     (A.ACCT_TYP = '0202' AND Q.PROD_NAME IN ('银团贷款(牵头行)','银团贷款(参与行)','票据置换')) THEN
        'F023'

     ---20220521
/*             WHEN ((A.ACCT_TYP like '0201%' AND A.loan_business_typ = '4' ) OR (A.ACCT_TYP LIKE '0201%' AND Q.PROD_NAME IN ( '全额房产抵押贷款(企业名)','项目贷款','固定资产支持融资')) )THEN
        'F022'*/--注释掉，与大集中同步 zhoulp20231207
       WHEN A.ACCT_TYP LIKE '0101%' THEN
        'F0211'
       WHEN A.ACCT_TYP = '010301' THEN
        'F0212'
       WHEN A.ACCT_TYP IN ('010402', '010403', '010404') THEN
        'F02131'
       WHEN A.ACCT_TYP IN ('010401', '010405', '010499') THEN
        'F02132'
       WHEN A.ACCT_TYP = '010399' THEN
        'F0219'
             WHEN A.ACCT_TYP = '0202' OR A.ACCT_TYP LIKE '0102%' OR (A.ACCT_TYP = '070101' AND A.ONLENDING_USAGE = 'A') THEN
        'F022'
             WHEN A.ACCT_TYP LIKE '0201%' OR (A.ACCT_TYP = '070101' AND A.ONLENDING_USAGE = 'B') THEN
        'F023'
       WHEN A.ACCT_TYP = '0801' THEN
        'F041'
       WHEN A.ACCT_TYP = '05' THEN
        'F09'
             WHEN A.ACCT_TYP = '0203' OR (A.ACCT_TYP = '070101' AND A.ONLENDING_USAGE = 'C') THEN
        'F12'
       WHEN SUBSTR(A.ITEM_CD,1,4) IN ('1306') THEN
               CASE WHEN A.ACCT_TYP = '0901' THEN 'F052'
                    WHEN A.ACCT_TYP = '0903' THEN 'F051'
                    WHEN A.ACCT_TYP = '0904' THEN 'F053'
                    WHEN A.ACCT_TYP = '0999' THEN 'F059'
               END
     END AS PRODUCT_TYPE, --贷款产品类别14
     CASE
       WHEN B.INLANDORRSHORE_FLG = 'Y' THEN
        SUBSTR(A.LOAN_PURPOSE_CD, 1, 4)
       WHEN B.INLANDORRSHORE_FLG = 'N' THEN
        '2000'
     END AS LOAN_PURPOSE_CD, --贷款实际投向15
     CASE
       WHEN A.LOAN_BUY_INT = 'N' THEN
        TO_CHAR(A.DRAWDOWN_DT, 'YYYY-MM-DD')
       WHEN A.LOAN_BUY_INT = 'Y' THEN
        TO_CHAR(A.IN_DRAWDOWN_DT, 'YYYY-MM-DD')
     END AS LOAN_GRANT_DATE, --贷款发放日期16
     
     --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 加入缩期逻辑
     TO_CHAR(A.MATURITY_DT, 'YYYY-MM-DD') AS LOAN_DUE_DATE, --贷款到期日期17
     /*CASE 
             WHEN A.MATURITY_DT_BEFORE > A.MATURITY_DT THEN --缩期
               TO_CHAR(A.MATURITY_DT_BEFORE, 'YYYY-MM-DD')
             ELSE 
             -- 正常/展期/延期都取T.MATURITY_DT
             -- 集市对T.MATURITY_DT的取数逻辑是有展期的从展期协议表里取原贷款终止日期，无展期的从各台账取原贷款终止日期
               TO_CHAR(A.MATURITY_DT, 'YYYY-MM-DD')
           END  LOAN_DUE_DATE, --贷款到期日期17*/

     TO_CHAR(A.FINISH_DT, 'YYYY-MM-DD') AS DEFER_END_DATE, --18  结清日期
     A.CURR_CD AS CURR_CODE, --币种19
     A.DRAWDOWN_AMT AS TRANS_AMT, --贷款发生金额20
     CASE
       WHEN A.CURR_CD = 'CNY' THEN
        NVL(A.DRAWDOWN_AMT, 0)
       ELSE
        NVL(A.DRAWDOWN_AMT, 0) * U.CCY_RATE
     END AS TRANS_AMT_RMB, --贷款发生金额折人民币21
     CASE
       WHEN A.INT_RATE_TYP = 'F' THEN
        'RF01'
       WHEN A.INT_RATE_TYP LIKE 'L%' THEN
        'RF02'
     END AS INT_RATE_TYPE, --利率是否固定22
     A.DRAWDOWN_REAL_INT_RAT AS INT_RATE, --利率水平23
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
     END AS PRI_BENCH_MARK, --贷款定价基准类型24
     CASE
       WHEN A.INT_RATE_TYP = 'F' THEN
        NULL
       ELSE
        A.BASE_INT_RAT
     END AS BASE_INT_RAT, --基准利率25
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
     END AS FINA_SUPPORT_FLG, --贷款财政扶持方式26
     CASE
       /*--[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 加入缩期逻辑
             WHEN A.MATURITY_DT_BEFORE > A.MATURITY_DT THEN --缩期
              TO_CHAR(A.MATURITY_DT, 'YYYY-MM-DD')*/
             WHEN A.INT_RATE_TYP = 'F' AND A.EXTENDTERM_FLG = 'Y' THEN
              TO_CHAR(A.ACTUAL_MATURITY_DT, 'YYYY-MM-DD') --固定利率，有展期，重定价日是展期到期日
             WHEN A.INT_RATE_TYP = 'F' THEN
              TO_CHAR(A.MATURITY_DT, 'YYYY-MM-DD') --固定利率，无展期，重定价日是到期日
              WHEN A.NEXT_REPRICING_DT < A.DRAWDOWN_DT THEN -- 重定价日小于贷款发放日期取放款日期
               TO_CHAR(A.DRAWDOWN_DT, 'YYYY-MM-DD')
             WHEN A.NEXT_REPRICING_DT > A.ACTUAL_MATURITY_DT THEN-- 重定价日大于贷款到期日期取到期日期
               TO_CHAR(A.ACTUAL_MATURITY_DT, 'YYYY-MM-DD')
             ELSE
              NVL(TO_CHAR(A.NEXT_REPRICING_DT, 'YYYY-MM-DD'),
                  TO_CHAR(A.ACTUAL_MATURITY_DT, 'YYYY-MM-DD'))
           END as INT_REPRICE_DATE, --贷款利率重新定价日27  修改同存量单位贷款逻辑
     TP7.GUAR_TYPE AS GUAR_TYPE, --贷款担保方式 28
     CASE
       WHEN LA.RN = 1 THEN
        '1'
       WHEN LA.RN >= 2 THEN
        '0'
     END AS FIRST_LOAN_FLG, --是否首次贷款29
     CASE
       WHEN A.LOAN_BUY_INT = 'Y' THEN
        'LF04'
       WHEN A.LOAN_KIND_CD = '91' /*1-新增贷款 2- 收回再贷 3-借新还旧 9-其他  91-资产重组 92-其他机构转入 93-其他情况 */
                         /*A.RESCHED_FLG = 'Y' OR A.RENEW_FLG = 'Y' OR A.REPAY_FLG = 'Y' */ THEN
        'LF05'
       ELSE
        'LF01'
     END AS LOAN_STATUS, --贷款状态30
     NULL AS ASS_SEC_PRO_TYPE, --资产证券化产品代码31
           CASE WHEN A.LOAN_KIND_CD = '91'   THEN  --资产重组
        CASE
          WHEN A.RENEW_FLG = 'Y' THEN
           '01' --无还本续贷
          WHEN A.REPAY_FLG = 'Y' THEN
           '02' --借新还旧
          WHEN A.RESCHED_FLG = 'Y' THEN
           '09' --其他
           END END AS LOAN_TYPE, --贷款重组方式32
     '1' AS TRANS_TYPE, --发放/收回标识33
     '1' AS SERIAL_NO, --交易流水号34
     
     --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊字符
     --A.USEOFUNDS AS USEOFUNDS, --贷款用途35
     REGEXP_REPLACE(REGEXP_REPLACE(A.USEOFUNDS,'[!?^？！ |]'),CHR(9)) AS USEOFUNDS, --贷款用途35
     
     NVL(CASE
           WHEN A.ORG_NUM LIKE '51%' THEN
            '99'
           WHEN A.ORG_NUM LIKE '52%' THEN
            '99'
           WHEN A.ORG_NUM LIKE '53%' THEN
            '99'
           WHEN A.ORG_NUM LIKE '54%' THEN
            '99'
           WHEN A.ORG_NUM LIKE '55%' THEN
            '99'
           WHEN A.ORG_NUM LIKE '56%' THEN
            '99'
           WHEN A.ORG_NUM LIKE '57%' THEN
            '99'
           WHEN A.ORG_NUM LIKE '58%' THEN
            '99'
           WHEN A.ORG_NUM LIKE '59%' THEN
            '99'
           WHEN A.ORG_NUM LIKE '60%' THEN
            '99'
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
         END,
         '99') BIZ_LINE_ID, --业务条线38 20230919王晓彬
     C.CUST_NAM, -- 客户名称41
     A.cust_id --客户号
      FROM SMTMODS.L_ACCT_LOAN A --贷款借据信息表
     INNER JOIN SMTMODS.L_CUST_ALL B --全量客户信息表
        ON A.CUST_ID = B.CUST_ID
       AND B.DATA_DATE = IS_DATE
     INNER JOIN PBOCD_DATACORE.L_CUST_C_TMP C --对公客户补充信息表
        ON A.CUST_ID = C.CUST_ID
       AND C.DATA_DATE = IS_DATE

      --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
      LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY D1
        ON C.ID_TYPE = D1.L_CODE
        AND D1.CODE_CLMN_NAME = 'ID_TYPE' --证件类型
        
      LEFT JOIN JS_102_FTYKHX_MAPPING M
        ON A.CUST_ID = M.COD_CUST_ID

     INNER JOIN L_PUBL_ORG_BRA_TMP D --机构表
        ON A.ORG_NUM = D.ORG_NUM
       AND D.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_AGRE_LOAN_CONTRACT Q
    ON A.ACCT_NUM = Q.CONTRACT_NUM AND A.DATA_DATE = Q.DATA_DATE

      LEFT JOIN DBFS_TMP TP7 --贷款担保方式中间表--在总调里加工
        ON A.LOAN_NUM = TP7.LOAN_NUM
      LEFT JOIN M_DICT_REMAPPING E --映射表
        ON C.NATION_CD = E.ORI_VALUES
       AND E.DICT_CODE = 'COUNTRY_CODE_3_TO_NUM' --国别代码三位转数字代码

      LEFT JOIN SMTMODS.L_PUBL_RATE U
    ON U.CCY_DATE =  TO_DATE(TO_CHAR(A.DRAWDOWN_DT, 'YYYYMMDD'), 'YYYYMMDD')
       AND U.BASIC_CCY = A.CURR_CD --基准币种
       AND U.FORWARD_CCY = 'CNY' --折算币种
    LEFT JOIN (
         SELECT T.LOAN_NUM,
                        ROW_NUMBER() OVER(PARTITION BY T.CUST_ID ORDER BY T.DRAWDOWN_DT ASC, LOAN_NUM) RN
                   FROM SMTMODS.L_ACCT_LOAN T
                  where t.data_date = IS_DATE) LA --是否首次贷款
        ON A.LOAN_NUM = LA.LOAN_NUM
     WHERE A.DATA_DATE = IS_DATE
     AND TRUNC(A.DRAWDOWN_DT, 'MM') = TRUNC(to_date(IS_DATE, 'yyyymmdd'), 'MM')
     AND SUBSTR(A.ITEM_CD,1,4) IN ('1303','1305','7120','1306') --1303-正常贷款，1305-贸易融资，7120-核销贷款 -- 20240926_ZHOULP_JLBA202406280007_新增1306垫款科目
       AND A.CANCEL_FLG = 'N' --去掉核销数据 -- add by wjb 20211124 过滤掉已核销贷款
          --垫款不取临时处理
       AND D.NATION_CD = 'CHN' ----20220829  夏文博  为测试跑出数据 先注释掉
       -- 20240926_ZHOULP_JLBA202406280007_新增1306垫款科目 09
       AND (SUBSTR(A.ACCT_TYP, 1, 2) IN ('02', '04', '05', '08', '09') OR A.ACCT_TYP = '070101') --02普通贷款 04贸易融资 05融资租赁 08协议透支  070101境外筹资转贷款
       AND (B.CUST_TYPE = '11' OR SUBSTR(C.FINA_CODE, 1, 1) IN ('A', 'B'))
       AND C.CUST_TYP <> '3' --去除个体工商户
       AND A.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
     AND NOT EXISTS(-- 剔除当天发生当天收回的垫款
         SELECT 1 FROM SMTMODS.L_ACCT_LOAN A2
                     WHERE A2.DATA_DATE = IS_DATE
                       AND SUBSTR(A2.ITEM_CD, 1, 4) IN ('1306')
                       AND SUBSTR(TO_CHAR(A2.DRAWDOWN_DT, 'YYYYMMDD'), 1, 6) = SUBSTR(IS_DATE, 1, 6)
                       AND A2.DRAWDOWN_DT = A2.FINISH_DT
                       AND A2.LOAN_ACCT_BAL = 0
                       AND A.LOAN_NUM=A2.LOAN_NUM)
    ;
  COMMIT;

  --本月收回贷款
  INSERT /*+append*/
  INTO JS_201_DWDKFS NOLOGGING ----收回
    (DATA_DATE, --数据日期 1
     ORG_CODE, --金融机构代码2
     ORG_NUM, --内部机构号3
     ORG_AREA_COD, --金融机构地区代码4
     CUST_ID_TYPE, --借款人证件类型5
     CUST_ID_NO, --借款人证件代码6
     DEPT_TYPE, --借款人国民经济部门7
     INDUSTRY_TYPE, --借款人行业8
     REG_AREA_CODE, --借款人地区代码9
     ENT_CON_ECO_ELEM, --借款人经济成分10
     ENT_SCALE, --借款人企业规模11
     LOAN_NUM, --贷款借据编码12
     CONTRACT_CODE, --贷款合同编码13
     PRODUCT_TYPE, --贷款产品类别14
     LOAN_PURPOSE_CD, --贷款实际投向15
     LOAN_GRANT_DATE, --贷款发放日期16
     LOAN_DUE_DATE, --贷款到期日期17
     LOAN_ACTUAL_DUE_DATE, --贷款实际终止日期18
     CURR_CODE, --币种19
     TRANS_AMT, --贷款发生金额20
     TRANS_AMT_RMB, --贷款发生金额折人民币21
     INT_RATE_TYPE, --利率是否固定22
     INT_RATE, --利率水平23
     PRI_BENCH_MARK, --贷款定价基准类型24
     BASE_INT_RAT, --基准利率25
     FINA_SUPPORT_FLG, --贷款财政扶持方式26
     INT_REPRICE_DATE, --贷款利率重新定价日27
     GUAR_TYPE, --贷款担保方式28
     FIRST_LOAN_FLG, --是否首次贷款29
     LOAN_STATUS, --贷款状态30
     ASS_SEC_PRO_TYPE, --资产证券化产品代码31
     LOAN_TYPE, --贷款重组方式32
     TRANS_TYPE, --发放/收回标识33
     SERIAL_NO, --交易流水号34
     USEOFUNDS, --贷款用途35
     BIZ_LINE_ID, --业务条线38
     CUST_ID, --41
     CUST_NAME -- 客户名称   42
     )
    SELECT /*+ parallel(4)*/ IS_DATE AS DATA_DATE, --数据日期1
     '', --OFF.JRJGBM AS ORG_CODE, --金融机构代码2
     D.ORG_NUM AS ORG_NUM, --内部机构号3
     '', --OFF.AREA_ID AS ORG_AREA_COD, --金融机构地区代码4

            --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 直取ECIF的ID_TYPE、ID_NO
            /*  CASE WHEN C.ID_TYPE IN ('236','239','2X','24') AND LENGTH(C.ID_NO) = 18 AND C.ID_NO NOT LIKE  '00000%' AND C.ID_NO NOT LIKE '%000000' THEN 'A01'
                        WHEN M.CUST_ID_NO_NEW IS NOT NULL THEN 'A01' --手工表中的证件代码
                        WHEN C.ORGANIZATIONCODE IS NOT NULL AND LENGTH(REPLACE(C.ORGANIZATIONCODE ,'-','')) = 9 THEN 'A02'
            ELSE 'A03'
            END AS CUST_ID_TYPE, --借款人证件类型5

              CASE WHEN C.ID_TYPE IN ('236','239','2X','24') AND LENGTH(C.ID_NO) = 18 AND C.ID_NO NOT LIKE  '00000%' AND C.ID_NO NOT LIKE '%000000' THEN C.ID_NO
                        WHEN M.CUST_ID_NO_NEW IS NOT NULL THEN UPPER(M.CUST_ID_NO_NEW)  --手工表中的证件代码
                        WHEN C.ORGANIZATIONCODE IS NOT NULL AND LENGTH(REPLACE(C.ORGANIZATIONCODE ,'-','')) = 9 THEN REPLACE(C.ORGANIZATIONCODE,'-','')
            ELSE C.ID_NO
            END AS CUST_ID_NO, --借款人证件代码6*/
            D1.PBOCD_CODE AS CUST_ID_TYPE, --借款人证件类型5
            CASE WHEN D1.PBOCD_CODE = 'A02' THEN REPLACE(C.ID_NO,'-') ELSE C.ID_NO END AS CUST_ID_NO, --借款人证件代码6
            
           --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 与客户表同步
           --CASE WHEN C.CUST_TYP = '5' THEN 'A04' ELSE C.DEPT_TYPE END AS DEPT_TYPE, --借款人国民经济部门7
           CASE WHEN C.CUST_TYP <> '5' THEN C.DEPT_TYPE ELSE 'A04' END AS DEPT_TYPE, --借款人国民经济部门7
           
           --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 与存量同步
           --CASE WHEN B.INLANDORRSHORE_FLG = 'Y' THEN SUBSTR(C.CORP_BUSINSESS_TYPE, 1, 3) ELSE '200' END AS INDUSTRY_TYPE, --借款人行业8
           SUBSTR(C.CORP_BUSINSESS_TYPE, 1, 3) AS INDUSTRY_TYPE, --借款人行业8
           
     NVL(REPLACE(C.REGION_CD, '待治理', ''), C.ORG_AREA) AS REG_AREA_CODE, --借款人地区代码9
     
     --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 与客户表同步
     /*CASE
       WHEN C.CORP_HOLD_TYPE = 'A' THEN
        'A01'
       WHEN C.CORP_HOLD_TYPE = 'A01' THEN
        'A0102'
       WHEN C.CORP_HOLD_TYPE = 'A02' THEN
        'A0101'
       WHEN C.CORP_HOLD_TYPE = 'B' THEN
        'A02'
       WHEN C.CORP_HOLD_TYPE = 'B01' THEN
        'A0202'
       WHEN C.CORP_HOLD_TYPE = 'B02' THEN
        'A0201'
       WHEN C.CORP_HOLD_TYPE = 'C' THEN
        'B01'
       WHEN C.CORP_HOLD_TYPE = 'C01' THEN
        'B0102'
       WHEN C.CORP_HOLD_TYPE = 'C02' THEN
        'B0101'
       WHEN C.CORP_HOLD_TYPE = 'D' THEN
        'B02'
       WHEN C.CORP_HOLD_TYPE = 'D01' THEN
        'B0202'
       WHEN C.CORP_HOLD_TYPE = 'D02' THEN
        'B0201'
       WHEN C.CORP_HOLD_TYPE = 'E' THEN
        'B03'
       WHEN C.CORP_HOLD_TYPE = 'E01' THEN
        'B0302'
       WHEN C.CORP_HOLD_TYPE = 'E02' THEN
        'B0301'
     END AS ENT_CON_ECO_ELEM, --借款人经济成分10*/
     DECODE(C.CORP_HOLD_TYPE,'A01','A0102','A02','A0101', 'B01','A0202','B02','A0201','C01','B0102', 'C02','B0101', 'D01','B0202', 'D02','B0201','E01','B0302', 'E02','B0301')  AS ENT_CON_ECO_ELEM, --借款人经济成分10
     
     --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 与存量同步
     /*CASE
       WHEN B.INLANDORRSHORE_FLG = 'Y' THEN*/
        CASE
          WHEN SUBSTR(C.CUST_TYP, 1, 1) IN ('1', '0') OR C.CUST_TYP = '9101' THEN
           CASE
             WHEN C.CORP_SCALE = 'B' THEN
              'CS01'
             WHEN C.CORP_SCALE = 'M' THEN
              'CS02'
             WHEN C.CORP_SCALE = 'S' THEN
              'CS03'
             WHEN C.CORP_SCALE = 'T' THEN
              'CS04'
                 ELSE 'CS05' END
          /*ELSE
           'CS05'
        END*/
     END AS ENT_SCALE, --借款人企业规模11
     A.LOAN_NUM AS LOAN_NUM, --贷款借据编码12
     A.ACCT_NUM AS CONTRACT_CODE, --贷款合同编码13
     CASE
             WHEN  D.LOAN_NUM in ('01260120001203330801','01260120001203330802','01260120001203330803','02100119001190853001') then
        'F12' /*并购贷款无标识,临时处理*/
       WHEN (D.ITEM_CD LIKE '1305%' AND D.CURR_CD <> 'CNY') THEN
        'F081'
       WHEN (D.ITEM_CD LIKE '1305%' AND D.CURR_CD = 'CNY') THEN --20220705-夏文博
        'F082'
       WHEN (D.ACCT_TYP = '0202' AND D.USEOFUNDS LIKE '%并购%') THEN
        'F12'
       WHEN (D.ACCT_TYP = '0202' AND D.loan_business_typ = '1') OR
                         (D.ACCT_TYP LIKE '0202%' AND Q.PROD_NAME IN ('商业房开发贷款','法人商用房按揭贷款(企业名)')) OR
                         (D.ACCT_TYP = '0202' AND Q.PROD_NAME IN ('银团贷款(牵头行)','银团贷款(参与行)','票据置换')) THEN
        'F023'
/*       WHEN ((D.ACCT_TYP like '0201%' AND D.loan_business_typ = '4')) THEN
        'F022'*/--注释掉，与大集中同步 zhoulp20231207
       WHEN D.ACCT_TYP LIKE '0101%' THEN
        'F0211'
       WHEN D.ACCT_TYP = '010301' THEN
        'F0212'
       WHEN D.ACCT_TYP IN ('010402', '010403', '010404') THEN
        'F02131'
       WHEN D.ACCT_TYP IN ('010401', '010405', '010499') THEN
        'F02132'
       WHEN D.ACCT_TYP = '010399' THEN
        'F0219'
             WHEN D.ACCT_TYP = '0202' OR D.ACCT_TYP LIKE '0102%' OR (D.ACCT_TYP = '070101' AND D.ONLENDING_USAGE = 'A') THEN
        'F022'
             WHEN D.ACCT_TYP LIKE '0201%' OR (D.ACCT_TYP = '070101' AND D.ONLENDING_USAGE = 'B') THEN
        'F023'
       WHEN D.ACCT_TYP = '0801' THEN
        'F041'
       WHEN D.ACCT_TYP = '05' THEN
        'F09'
             WHEN D.ACCT_TYP = '0203' OR (D.ACCT_TYP = '070101' AND D.ONLENDING_USAGE = 'C') THEN
        'F12'
       WHEN SUBSTR(D.ITEM_CD,1,4) IN ('1306') THEN
               CASE WHEN D.ACCT_TYP = '0901' THEN 'F052'
                    WHEN D.ACCT_TYP = '0903' THEN 'F051'
                    WHEN D.ACCT_TYP = '0904' THEN 'F053'
                    WHEN D.ACCT_TYP = '0999' THEN 'F059'
               END
     END AS PRODUCT_TYPE, --贷款产品类别14
     CASE
       WHEN B.INLANDORRSHORE_FLG = 'Y' THEN
        SUBSTR(D.LOAN_PURPOSE_CD, 1, 4)
       WHEN B.INLANDORRSHORE_FLG = 'N' THEN
        '2000'
     END AS LOAN_PURPOSE_CD, --贷款实际投向15
     CASE
       WHEN D.LOAN_BUY_INT = 'N' THEN
        TO_CHAR(D.DRAWDOWN_DT, 'YYYY-MM-DD')
       WHEN D.LOAN_BUY_INT = 'Y' THEN
        TO_CHAR(D.IN_DRAWDOWN_DT, 'YYYY-MM-DD')
     END AS LOAN_GRANT_DATE, --贷款发放日期16
     
     --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 加入缩期逻辑
     TO_CHAR(D.MATURITY_DT, 'YYYY-MM-DD') AS LOAN_DUE_DATE, --贷款到期日期17
     /*CASE 
             WHEN D.MATURITY_DT_BEFORE > D.MATURITY_DT THEN --缩期
               TO_CHAR(D.MATURITY_DT_BEFORE, 'YYYY-MM-DD')
             ELSE 
             -- 正常/展期/延期都取T.MATURITY_DT
             -- 集市对T.MATURITY_DT的取数逻辑是有展期的从展期协议表里取原贷款终止日期，无展期的从各台账取原贷款终止日期
               TO_CHAR(D.MATURITY_DT, 'YYYY-MM-DD')
           END  LOAN_DUE_DATE, --贷款到期日期17*/
     
     --TO_CHAR(D.FINISH_DT, 'YYYY-MM-DD') AS    LOAN_ACTUAL_DUE_DATE, --贷款实际终止日期18
     ---BY CH 20231023当月有多笔还款,最后一笔才结清时,仅最后一笔取贷款终止日期,其他几笔为空
     CASE
       WHEN A.RN = 1 THEN
        TO_CHAR(D.FINISH_DT, 'YYYY-MM-DD')
       ELSE
        ''
     END AS LOAN_ACTUAL_DUE_DATE, --贷款实际终止日期18
     D.CURR_CD AS CURR_CODE, --币种19
     --[2026-03-19] [周立鹏] [JLBA202412040002_关于在金融基础数据修改部分业务取数逻辑的需求][李楠] 贷款发生额负值调整
     ABS(A.PAY_AMT) AS TRANS_AMT, --贷款发生金额20
     CASE
       WHEN D.CURR_CD = 'CNY' THEN
        ABS(NVL(A.PAY_AMT, 0))
       ELSE
        ABS(NVL(A.PAY_AMT, 0)) * U.CCY_RATE
     END AS TRANS_AMT_RMB, --贷款发生金额折人民币21
     CASE
       WHEN D.INT_RATE_TYP = 'F' THEN
        'RF01'
       WHEN D.INT_RATE_TYP LIKE 'L%' THEN
        'RF02'
     END AS INT_RATE_TYPE, --利率是否固定22
           CASE WHEN A.REPAY_REAL_INT_RAT IS NOT NULL AND A.REPAY_REAL_INT_RAT <> 0 THEN A.REPAY_REAL_INT_RAT ELSE D.REAL_INT_RAT END AS INT_RATE, --利率水平23

     CASE
       WHEN D.PRICING_BASE_TYPE = 'A01' THEN
        'TR01'
       WHEN D.PRICING_BASE_TYPE = 'A0201' THEN
        'TR02'
       WHEN D.PRICING_BASE_TYPE = 'A0202' THEN
        'TR03'
       WHEN D.PRICING_BASE_TYPE = 'A0203' THEN
        'TR04'
       WHEN D.PRICING_BASE_TYPE = 'C' THEN
        'TR05'
       WHEN D.PRICING_BASE_TYPE = 'D' THEN
        'TR06'
       WHEN D.PRICING_BASE_TYPE = 'B01' THEN
        'TR07'
       WHEN D.PRICING_BASE_TYPE = 'B02' THEN
        'TR08'
       WHEN D.PRICING_BASE_TYPE = 'E' THEN
        'TR09'
       ELSE
        'TR99'
     END AS PRI_BENCH_MARK, --贷款定价基准类型24
     CASE
       WHEN D.INT_RATE_TYP = 'F' THEN
        NULL
       ELSE
        D.BASE_INT_RAT
     END AS BASE_INT_RAT, --基准利率25
     CASE
       WHEN D.COMP_INT_TYP = '110' THEN
        'A0101'
       WHEN D.COMP_INT_TYP = '120' THEN
        'A0102'
       WHEN D.COMP_INT_TYP = '210' THEN
        'A0201'
       WHEN D.COMP_INT_TYP = '220' THEN
        'A0202'
       WHEN D.COMP_INT_TYP = '300' THEN
        'B'
       WHEN D.COMP_INT_TYP = '500' THEN
        'C'
       WHEN D.COMP_INT_TYP = '400' THEN
        'Z'
     END AS FINA_SUPPORT_FLG, --贷款财政扶持方式26
  CASE
             /*--[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 加入缩期逻辑
             WHEN D.MATURITY_DT_BEFORE > D.MATURITY_DT THEN --缩期
              TO_CHAR(D.MATURITY_DT, 'YYYY-MM-DD')*/
             WHEN D.INT_RATE_TYP = 'F' AND D.EXTENDTERM_FLG = 'Y' THEN
              TO_CHAR(D.ACTUAL_MATURITY_DT, 'YYYY-MM-DD') --固定利率，有展期，重定价日是展期到期日
             WHEN D.INT_RATE_TYP = 'F' THEN
              TO_CHAR(D.MATURITY_DT, 'YYYY-MM-DD') --固定利率，无展期，重定价日是到期日
              WHEN D.NEXT_REPRICING_DT < D.DRAWDOWN_DT THEN -- 重定价日小于贷款发放日期取放款日期
               TO_CHAR(D.DRAWDOWN_DT, 'YYYY-MM-DD')
             WHEN D.NEXT_REPRICING_DT > D.ACTUAL_MATURITY_DT THEN-- 重定价日大于贷款到期日期取到期日期
               TO_CHAR(D.ACTUAL_MATURITY_DT, 'YYYY-MM-DD')
             ELSE
              NVL(TO_CHAR(D.NEXT_REPRICING_DT, 'YYYY-MM-DD'),
                  TO_CHAR(D.ACTUAL_MATURITY_DT, 'YYYY-MM-DD'))
           END as INT_REPRICE_DATE, --贷款利率重新定价日27  修改同存量单位贷款逻辑
     TP7.GUAR_TYPE AS GUAR_TYPE, --贷款担保方式 28
     CASE
       WHEN LA.RN = 1 THEN
        '1'
       WHEN LA.RN >= 2 THEN
        '0'
     END AS FIRST_LOAN_FLG, --是否首次贷款29,
     CASE
       WHEN A.PAY_TYPE IN ('01', '02', '03', '07', '09') THEN
        'LF01'
       WHEN A.PAY_TYPE = '08' THEN
        'LF02'
       WHEN A.PAY_TYPE = '05' THEN
        'LF03'
       WHEN A.PAY_TYPE = '11' THEN
        'LF04'
       WHEN A.PAY_TYPE IN ('04', '12')
       -- OR A.RENEW_FLG = 'Y'
        THEN
        'LF05'
       WHEN A.PAY_TYPE = '06' THEN
        'LF06'
       WHEN A.ABS_TRANS_FLG = 'Y' THEN
        'LF07'
       WHEN A.PAY_TYPE = '10' THEN
        'LF08'
       ELSE
        'LF99'
     END AS LOAN_STATUS, --贷款状态 30
     NULL ASS_SEC_PRO_TYPE, --资产证券化产品代码31

           CASE WHEN A.PAY_TYPE  IN ('04', '12') THEN
        CASE
          WHEN A.RENEW_FLG = 'Y' THEN
           '01'
          WHEN A.PAY_TYPE = '12' THEN
           '02'
          WHEN A.PAY_TYPE = '04' THEN
           '09'
           END END AS LOAN_TYPE, --贷款重组方式32
           
     --[2026-03-19] [周立鹏] [JLBA202412040002_关于在金融基础数据修改部分业务取数逻辑的需求][李楠] 贷款发生额负值调整
     CASE WHEN A.PAY_AMT < 0 THEN '1' ELSE '0' END AS TRANS_TYPE, --发放/收回标识33
     
     A.TX_NO AS SERIAL_NO, --交易流水号34
     
     --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊字符
     --D.USEOFUNDS AS USEOFUNDS, --贷款用途35
     REGEXP_REPLACE(REGEXP_REPLACE(D.USEOFUNDS,'[!?^？！ |]'),CHR(9)) AS USEOFUNDS, --贷款用途35
     
     NVL(CASE
                 WHEN D.ORG_NUM LIKE '5100%' THEN '99'
                 WHEN D.DEPARTMENTD= '公司金融' THEN 'E'
                 WHEN D.DEPARTMENTD= '普惠金融' THEN 'S'
                 WHEN D.DEPARTMENTD= '个人信贷' THEN 'P'
                 --WHEN D.DEPARTMENTD= '磐石村镇' THEN 'V'
                 WHEN D.DEPARTMENTD= '德惠长银' THEN 'E' END,'99') BIZ_LINE_ID, --业务条线38

     D.CUST_ID, --41
     C.CUST_NAM -- 客户名称   42
      FROM (SELECT X.*,
                   ROW_NUMBER() OVER(PARTITION BY X.LOAN_NUM ORDER BY REPAY_DT DESC, TX_NO DESC) RN
              FROM SMTMODS.L_TRAN_LOAN_PAYM X
              WHERE X.PAY_AMT <> 0
              AND TRUNC(X.REPAY_DT, 'MM') = TRUNC(to_date(IS_DATE, 'yyyymmdd'), 'MM')  --取本月
              ) A --贷款还款明细信息表
    ---BY CH 20231023当月有多笔还款,最后一笔才结清时,仅最后一笔取贷款终止日期,其他几笔为空
     INNER JOIN SMTMODS.L_ACCT_LOAN D --贷款借据信息表
        ON A.LOAN_NUM = D.LOAN_NUM
       AND D.DATA_DATE = IS_DATE
      LEFT JOIN JS_102_FTYKHX_MAPPING M --手工维护表
        ON D.CUST_ID = M.COD_CUST_ID
     INNER JOIN SMTMODS.L_CUST_ALL B --全量客户信息表
        ON D.CUST_ID = B.CUST_ID
       AND B.DATA_DATE = IS_DATE
     INNER JOIN PBOCD_DATACORE.L_CUST_C_TMP C --对公客户补充信息表
        ON D.CUST_ID = C.CUST_ID
       AND C.DATA_DATE = IS_DATE
     INNER JOIN L_PUBL_ORG_BRA_TMP E --机构表
        ON A.ORG_NUM = E.ORG_NUM
       AND E.DATA_DATE = IS_DATE
     
     --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
     LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY D1
        ON C.ID_TYPE = D1.L_CODE
        AND D1.CODE_CLMN_NAME = 'ID_TYPE' --证件类型
        
      LEFT JOIN SMTMODS.L_AGRE_LOAN_CONTRACT Q --贷款合同信息表
    ON D.ACCT_NUM = Q.CONTRACT_NUM AND D.DATA_DATE = Q.DATA_DATE

      LEFT JOIN M_DICT_REMAPPING G --映射表
        ON B.NATION_CD = G.ORI_VALUES
       AND G.DICT_CODE = 'COUNTRY_CODE_3_TO_NUM' --国别代码三位转数字代码
      LEFT JOIN SMTMODS.L_PUBL_RATE U
    ON U.CCY_DATE = TO_DATE(TO_CHAR(A.REPAY_DT, 'YYYYMMDD'), 'YYYYMMDD')
       AND U.BASIC_CCY = D.CURR_CD --基准币种
       AND U.FORWARD_CCY = 'CNY' --折算币种
      LEFT JOIN (
                 --是否首次贷款
                 SELECT T.LOAN_NUM,
                         ROW_NUMBER() OVER(PARTITION BY T.CUST_ID ORDER BY T.DRAWDOWN_DT ASC, LOAN_NUM) RN
                   FROM SMTMODS.L_ACCT_LOAN T
         where t.data_date = IS_DATE
     ) LA --取是否首次贷款
        ON A.LOAN_NUM = LA.LOAN_NUM

      LEFT JOIN DBFS_TMP TP7 --贷款担保方式中间表--在总调里加工
        ON A.LOAN_NUM = TP7.LOAN_NUM
    WHERE
        SUBSTR(D.ITEM_CD,1,4) IN ('1303','1305','7120','1306') --1303-正常贷款，1305-贸易融资，7120-核销贷款 -- 20240926_ZHOULP_JLBA202406280007_新增1306垫款科目

       AND (
       D.CANCEL_FLG = 'N' --去掉核销数据 -- add by wjb 20211124 过滤掉已核销贷款
       OR ( D.CANCEL_FLG='Y' --当月核销
       AND EXISTS(
       SELECT 1 FROM SMTMODS.L_ACCT_WRITE_OFF XX WHERE  XX.DATA_DATE = IS_DATE
         AND substr(TO_CHAR(XX.WRITE_OFF_DATE,'yyyymmdd'),1,6)=substr(IS_DATE,1,6)
         AND D.LOAN_NUM = XX.LOAN_NUM))
       )
       
       AND D.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250228 JLBA202408200012 资产未转让
          --垫款不取临时处理
       AND E.NATION_CD = 'CHN' --境内----20220829  夏文博  为测试跑出数据 先注释掉
       -- 20240926_ZHOULP_JLBA202406280007_新增1306垫款科目 09
       AND (SUBSTR(D.ACCT_TYP, 1, 2) IN ('02', '04', '05', '08', '09') OR D.ACCT_TYP = '070101') --02普通贷款 04贸易融资 05融资租赁 08协议透支  070101境外筹资转贷款
       AND (B.CUST_TYPE = '11' OR SUBSTR(C.FINA_CODE, 1, 1) IN ('A', 'B'))
       AND C.CUST_TYP <> '3' --去除个体工商户
     AND NOT EXISTS(-- 剔除当天发生当天收回的垫款
         SELECT 1 FROM SMTMODS.L_ACCT_LOAN A2
                     WHERE A2.DATA_DATE = IS_DATE
                       AND SUBSTR(A2.ITEM_CD, 1, 4) IN ('1306')
                       AND SUBSTR(TO_CHAR(A2.DRAWDOWN_DT, 'YYYYMMDD'), 1, 6) = SUBSTR(IS_DATE, 1, 6)
                       AND A2.DRAWDOWN_DT = A2.FINISH_DT
                       AND A2.LOAN_ACCT_BAL = 0
                       AND D.LOAN_NUM=A2.LOAN_NUM)
    ;
  COMMIT;

  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_201_DWDKFS_TEMP02';
  INSERT  /*+ append*/ INTO JS_201_DWDKFS_TEMP02
    (SERIAL_NO, COUNTS)
    SELECT T.SERIAL_NO, COUNT(1)
      FROM JS_201_DWDKFS T
     WHERE DATA_DATE = VS_TEXT8
     GROUP BY T.SERIAL_NO
    HAVING COUNT(1) >= 2;
  COMMIT;



  SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_201_DWDKFS_TMP', OI_RETCODE);

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_201_DWDKFS_TMP TRUNCATE PARTITION P' || IS_DATE;


  --插入目标表
  INSERT /*+ append*/ INTO PBOCD_JS_201_DWDKFS_TMP /*@PBOCD_34*/
    (DATA_DATE, -- 数据日期
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
     LOAN_ACTUAL_DUE_DATE, --17  贷款实际终止日期
     CURR_CODE, --18  币种
     TRANS_AMT, --19  贷款发生金额
     TRANS_AMT_RMB, --20  贷款发生金额折人民币
     INT_RATE_TYPE, --21  利率是否固定
     INT_RATE, --22  利率水平
     PRI_BENCH_MARK, --23  贷款定价基准类型
     BASE_INT_RAT, --24  基准利率
     FINA_SUPPORT_FLG, --25  贷款财政扶持方式
     INT_REPRICE_DATE, --26  贷款利率重新定价日
     GUAR_TYPE, --27  贷款担保方式
     FIRST_LOAN_FLG, --28  是否首次贷款
     LOAN_STATUS, --29  贷款状态
     ASS_SEC_PRO_TYPE, --30  资产证券化产品代码
     LOAN_TYPE, --31  贷款重组方式
     TRANS_TYPE, --32  发放/收回标识
     SERIAL_NO, --33  交易流水号
     USEOFUNDS, --34  贷款用途
     REPORT_ID, --35  报送ID
     CJRQ, --36  采集日期
     NBJGH, --37  内部机构号
     BIZ_LINE_ID, --38  业务条线
     VERIFY_STATUS, --39  校验状态
     BSCJRQ, --40 报送周期
     FRNBJGH, --法人内部机构号
     CUST_NAME, --35 客户名称
     CUST_ID --客户号
     )
    SELECT /*+ parallel(4)*/ VS_TEXT DATA_DATE, -- 数据日期
     T.ORG_CODE, --1 金融机构代码
     T.ORG_NUM, --2 内部机构号
     T.ORG_AREA_COD, --3 金融机构地区代码
     T.CUST_ID_TYPE, --4 借款人证件类型
     T.CUST_ID_NO, --5 借款人证件代码
     T.DEPT_TYPE, --6 借款人国民经济部门
     T.INDUSTRY_TYPE, --7 借款人行业
     T.REG_AREA_CODE REG_AREA_CODE, --8 借款人地区代码
     T.ENT_CON_ECO_ELEM, --9 借款人经济成分
     T.ENT_SCALE, --10  借款人企业规模
     T.LOAN_NUM, --11  贷款借据编码
     T.CONTRACT_CODE, --12  贷款合同编码
     T.PRODUCT_TYPE, --13  贷款产品类别
     T.LOAN_PURPOSE_CD, --14  贷款实际投向
     T.LOAN_GRANT_DATE, --15  贷款发放日期
     T.LOAN_DUE_DATE, --16  贷款到期日期
           CASE WHEN TRUNC(TO_DATE(T.LOAN_GRANT_DATE,'YYYY-MM-DD'),'MM') = TRUNC(TO_DATE(LOAN_ACTUAL_DUE_DATE,'YYYY-MM-DD'),'MM') AND
                                  T.TRANS_TYPE = '1' AND
                                  TRUNC(TO_DATE(LOAN_ACTUAL_DUE_DATE,'YYYY-MM-DD'),'MM') = TRUNC(TO_DATE(IS_DATE,'YYYYMMDD'),'MM')  THEN ''
           ELSE T.LOAN_ACTUAL_DUE_DATE END, --17  贷款实际终止日期 UPPDATE BY  20220718 YFXR.GIN
     T.CURR_CODE, --18  币种
     T.TRANS_AMT, --19  贷款发生金额
     T.TRANS_AMT_RMB, --20  贷款发生金额折人民币
     T.INT_RATE_TYPE, --21  利率是否固定
     T.INT_RATE, --22  利率水平
     T.PRI_BENCH_MARK, --23  贷款定价基准类型
     T.BASE_INT_RAT, --24  基准利率
     T.FINA_SUPPORT_FLG, --25  贷款财政扶持方式
     T.INT_REPRICE_DATE, --26  贷款利率重新定价日
     T.GUAR_TYPE, --27  贷款担保方式
     T.FIRST_LOAN_FLG, --28  是否首次贷款
     --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除转股债的判断
           CASE --WHEN TT.JJBH IS NOT NULL THEN  'LF08'
                WHEN T.LOAN_STATUS = 'LF05' THEN 'LF01'--贷款状态是LF05的 改成LF01，贷款重组方式清空
                ELSE T.LOAN_STATUS END, --29  贷款状态
     ASS_SEC_PRO_TYPE, --30  资产证券化产品代码
           CASE WHEN T.LOAN_STATUS = 'LF05' THEN NULL ELSE LOAN_TYPE END, --31  贷款重组方式

     T.TRANS_TYPE, --32  发放/收回标识
     --T.SERIAL_NO || CASE WHEN T2.SERIAL_NO IS NOT NULL THEN TRANS_TYPE END, --33  交易流水号
     T.SERIAL_NO, --33  交易流水号
     T.USEOFUNDS USEOFUNDS, --34  贷款用途
     SYS_GUID() REPORT_ID, --35  报送ID
     VS_TEXT8 CJRQ, --36  采集日期
     T.ORG_NUM NBJGH, --37  内部机构号
     T.BIZ_LINE_ID, --38  业务条线
     NULL VERIFY_STATUS, --39  校验状态
     NULL BSCJRQ, --40 报送周期
     --'000000' FRNBJGH, --法人内部机构号
     /*CASE WHEN T.ORG_NUM LIKE '5100%' THEN '510000' ELSE '990000' END FRNBJGH,*/
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

     T.CUST_NAME, --35 客户名称
     T.CUST_ID --客户号
      FROM JS_201_DWDKFS T
      LEFT JOIN JS_201_DWDKFS_TEMP02 T2
        ON T.SERIAL_NO = T2.SERIAL_NO

      LEFT JOIN TMP_DWDKFS_TS TT --手工维护表
        ON T.LOAN_NUM = TT.JJBH
       AND TT.STATUS = '债转股'
     WHERE T.DATA_DATE = IS_DATE;

  COMMIT;

  ---以下包含原应用层加工逻辑，现都放在加工层处理
  SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_201_DWDKFS', OI_RETCODE);

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_201_DWDKFS TRUNCATE PARTITION P' || IS_DATE;


  INSERT INTO PBOCD_JS_201_DWDKFS
    (DATA_DATE, -- 数据日期
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
     LOAN_ACTUAL_DUE_DATE, --17  贷款实际终止日期
     CURR_CODE, --18  币种
     TRANS_AMT, --19  贷款发生金额
     TRANS_AMT_RMB, --20  贷款发生金额折人民币
     INT_RATE_TYPE, --21  利率是否固定
     INT_RATE, --22  利率水平
     PRI_BENCH_MARK, --23  贷款定价基准类型
     BASE_INT_RAT, --24  基准利率
     FINA_SUPPORT_FLG, --25  贷款财政扶持方式
     INT_REPRICE_DATE, --26  贷款利率重新定价日
     GUAR_TYPE, --27  贷款担保方式
     FIRST_LOAN_FLG, --28  是否首次贷款
     LOAN_STATUS, --29  贷款状态
     ASS_SEC_PRO_TYPE, --30  资产证券化产品代码
     LOAN_TYPE, --31  贷款重组方式
     TRANS_TYPE, --32  发放/收回标识
     SERIAL_NO, --33  交易流水号
     USEOFUNDS, --34  贷款用途
     REPORT_ID, --35  报送ID
     CJRQ, --36  采集日期
     NBJGH, --37  内部机构号
     BIZ_LINE_ID, --38  业务条线
     VERIFY_STATUS, --39  校验状态
     BSCJRQ, --40 报送周期
     FRNBJGH, --法人内部机构号
     CUST_NAME, --35 客户名称
     CUST_ID --客户号
     )
    SELECT VS_TEXT, -- 数据日期
           NVL(OB.ID_NO, OB.UP_ID_NO), --金融机构代码
           T.ORG_NUM, --2 内部机构号
           OB.REGION_CD, --3  金融机构地区代码
           
           --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 直取ECIF的ID_TYPE、ID_NO
           /*NVL(NVL(T3.CUST_ID_TYPE, BU.CUST_ID_TYPE), T.CUST_ID_TYPE), --4 借款人证件类型
           NVL(NVL(T3.CUST_ID_NO, BU.CUST_ID_NO), T.CUST_ID_NO), --5 借款人证件代码   */       
           T.CUST_ID_TYPE, --4 借款人证件类型
           T.CUST_ID_NO, --5 借款人证件代码 
           
           NVL(T3.DEPT_TYPE, T.DEPT_TYPE), --6 借款人国民经济部门
           
           --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 剔除特殊处理
           --NVL(BU.INDUSTRY_TYPE, T.INDUSTRY_TYPE), --7 借款人行业
           T.INDUSTRY_TYPE, --7 借款人行业
           
           --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 剔除特殊处理
           --GET_AREA_CODE(NVL(BU.REG_AREA_CODE, T.REG_AREA_CODE)) REG_AREA_CODE, --8 借款人地区代码
           T.REG_AREA_CODE AS REG_AREA_CODE, --8 借款人地区代码
           
           --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 与存量同步
           --NVL(BU.ENT_CON_ECO_ELEM, T.ENT_CON_ECO_ELEM), --9 借款人经济成分
           NVL(T.ENT_CON_ECO_ELEM, BU.ENT_CON_ECO_ELEM), --9 借款人经济成分
           
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --NVL(T.ENT_SCALE, BU.ENT_SCALE), --10  借款人企业规模
           T.ENT_SCALE, --10  借款人企业规模
           
           T.LOAN_NUM, --11  贷款借据编码
           T.CONTRACT_CODE, --12  贷款合同编码
           
           --20251218 在线文档标记无法治理
           CASE WHEN T.TRANS_TYPE = '1' AND BQ.PRODUCT_TYPE IS NOT NULL /*add by dw(20231206) 处理本期发放且本期收回时产品类型为空问题*/ THEN BQ.PRODUCT_TYPE
                WHEN T.TRANS_TYPE = '0' AND SUBSTR(T.LOAN_GRANT_DATE,1,7) <> SUBSTR(VS_TEXT,1,7)  THEN BU.PRODUCT_TYPE
           ELSE T.PRODUCT_TYPE END PRODUCT_TYPE, --13  贷款产品类别
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --DECODE(T.LOAN_PURPOSE_CD,'C595','G595','C593','G593',T.LOAN_PURPOSE_CD), --14  贷款实际投向
           T.LOAN_PURPOSE_CD, --14  贷款实际投向
           
           T.LOAN_GRANT_DATE, --15  贷款发放日期
           T.LOAN_DUE_DATE, --16  贷款到期日期
           T.LOAN_ACTUAL_DUE_DATE, --17  贷款实际终止日期
           T.CURR_CODE, --18  币种
           T.TRANS_AMT, --19  贷款发生金额
           T.TRANS_AMT_RMB, --20  贷款发生金额折人民币
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --NVL(BU.INT_RATE_TYPE, T.INT_RATE_TYPE), --21  利率是否固定
           T.INT_RATE_TYPE, --21  利率是否固定
     
           --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
           --NVL(BU.INT_RATE, T.INT_RATE), --22  利率水平
           T.INT_RATE, --22  利率水平
     
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --NVL(BU.PRI_BENCH_MARK, T.PRI_BENCH_MARK), --23  贷款定价基准类型
           T.PRI_BENCH_MARK, --23  贷款定价基准类型
           
           --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
           --CASE WHEN NVL(BU.INT_RATE_TYPE, T.INT_RATE_TYPE) = 'RF01' THEN NULL
           --  ELSE NVL(BU.BASE_INT_RAT, T.BASE_INT_RAT) END , --24  基准利率
           CASE WHEN T.INT_RATE_TYPE = 'RF01' THEN NULL ELSE T.BASE_INT_RAT END , --24  基准利率
     
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --NVL(BU.FINA_SUPPORT_FLG, T.FINA_SUPPORT_FLG), --25  贷款财政扶持方式
           T.FINA_SUPPORT_FLG, --25  贷款财政扶持方式
           
           T.INT_REPRICE_DATE, --26  贷款利率重新定价日
           CASE WHEN TRANS_TYPE = '0' THEN NVL(BU.GUAR_TYPE,T.GUAR_TYPE) ELSE T.GUAR_TYPE END,--27  贷款担保方式

           T.FIRST_LOAN_FLG, --28  是否首次贷款
           T.LOAN_STATUS, --29  贷款状态
           ASS_SEC_PRO_TYPE, --30  资产证券化产品代码
           LOAN_TYPE, --31  贷款重组方式
           TRANS_TYPE, --32  发放/收回标识
           T.SERIAL_NO, --33  交易流水号
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --NVL(BU.USEOFUNDS, T.USEOFUNDS) USEOFUNDS, --34  贷款用途
           T.USEOFUNDS AS USEOFUNDS, --34  贷款用途
           
           SYS_GUID() REPORT_ID, --35  报送ID
           VS_TEXT8 CJRQ, --36  采集日期
           T.ORG_NUM NBJGH, --37  内部机构号
           T.BIZ_LINE_ID, --'99' /*T.BIZ_LINE_ID*/ BIZ_LINE_ID, --38  业务条线
           NULL VERIFY_STATUS, --39  校验状态
           NULL BSCJRQ, --40 报送周期
           T.FRNBJGH, --法人内部机构号
           T.CUST_NAME, --35 客户名称
           T.CUST_ID --客户号
      FROM PBOCD_JS_201_DWDKFS_TMP T
      LEFT JOIN L_PUBL_ORG_BRA_TMP OB --金数机构表
      ON OB.ORG_NUM=T.NBJGH AND OB.DATA_DATE=IS_DATE
      LEFT JOIN PBOCD_JS_201_CLDWDK BQ
        ON T.LOAN_NUM = BQ.LOAN_NUM
       AND BQ.CJRQ = IS_DATE
      LEFT JOIN PBOCD_JS_201_CLDWDK_SQ BU
        ON T.LOAN_NUM = BU.LOAN_NUM
       AND BU.CJRQ = VS_LAST_TEXT
      LEFT JOIN PBOCD_JS_102_FTYKHX T3
        ON T.CUST_ID = T3.CUST_ID
       AND T.FRNBJGH = T3.FRNBJGH
       AND T3.CJRQ = IS_DATE
     WHERE T.CJRQ = IS_DATE
     ;

  COMMIT;
  
--[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 直取ECIF的ID_TYPE、ID_NO
/*  UPDATE PBOCD_JS_201_DWDKFS SET CUST_ID_NO='91220201664271460T' WHERE CJRQ =IS_DATE
     AND CUST_ID_NO = 'G10220211002103306';
  COMMIT;
  UPDATE PBOCD_JS_201_DWDKFS SET CUST_ID_TYPE='A01',CUST_ID_NO='912202827171441161'
  WHERE CJRQ =IS_DATE AND CUST_NAME='桦甸市吉元土产有限公司';
  COMMIT;
  UPDATE PBOCD_JS_201_DWDKFS SET CUST_ID_TYPE='A01',CUST_ID_NO='912202216914715997'
  WHERE CJRQ =IS_DATE AND CUST_NAME='吉林博大农林生物科技有限公司';
  COMMIT;
  UPDATE PBOCD_JS_201_DWDKFS SET CUST_ID_TYPE='A01',CUST_ID_NO='912204005504910788'
  WHERE CJRQ =IS_DATE AND CUST_NAME='吉林省博大伟业制药有限公司';
  COMMIT;*/
  
  --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除借款人名称的修改逻辑
  --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 与客户表同步 集市就是C99，剔除逻辑后无影响
  /*UPDATE PBOCD_JS_201_DWDKFS SET \*CUST_NAME = '长春北湖学校',*\DEPT_TYPE='C99'
  WHERE CJRQ=IS_DATE AND CUST_NAME = '长春市十一高中北湖学校';
  COMMIT;*/
  
  --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 与客户表同步 以上游C99 CS03 为准
  /*UPDATE PBOCD_JS_201_DWDKFS SET DEPT_TYPE='C99',ENT_CON_ECO_ELEM=''
  WHERE CJRQ=IS_DATE AND CUST_ID_NO='52220100MJ3759353Y';
  COMMIT;*/
  
  --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除金融机构地区代码的修改逻辑
  --公主岭地区代码
  /*UPDATE PBOCD_JS_201_DWDKFS
     SET ORG_AREA_COD = '220184'
   WHERE CJRQ = IS_DATE
     AND ORG_AREA_COD = '220381';
  COMMIT;*/
  
  --    需求编号：JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段 上线日期：2025-12-30，修改人：周立鹏，提出人：李楠   修改原因：剔除特殊处理
  /*UPDATE PBOCD_JS_201_DWDKFS
     SET REG_AREA_CODE = '220184'
   WHERE CJRQ = IS_DATE
     AND REG_AREA_CODE = '220381';
  COMMIT;*/
  
  
--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 与客户信息同步
--客户国民经济部门需在符合要求的值域范围内且不能为个人和金融机构
MERGE INTO PBOCD_JS_201_DWDKFS A
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

UPDATE PBOCD_JS_201_DWDKFS A
   SET A.DEPT_TYPE = 'C01' --经业务确认，有限公司的国民经济部门都是C01
 WHERE A.CJRQ = IS_DATE
   AND A.FRNBJGH = '990000'
   AND (SUBSTR(A.DEPT_TYPE, 1, 1) IN ('B', 'D') OR A.DEPT_TYPE IS NULL)
   AND (CUST_NAME LIKE '%有限责任公司' OR CUST_NAME LIKE '%有限公司');
COMMIT;

--企业规模为CS01-大型至CS04-微型的，客户国民经济部门应该为C开头的非金融企业部门或者B开头的金融机构
UPDATE PBOCD_JS_201_DWDKFS A
   SET A.DEPT_TYPE = 'C01' --经业务确认，有限公司的国民经济部门都是C01
 WHERE CJRQ = IS_DATE
   AND FRNBJGH = '990000'
   AND ENT_SCALE IN ('CS01', 'CS02', 'CS03', 'CS04')
   AND SUBSTR(DEPT_TYPE, 1, 1) NOT IN ('B', 'C')
   AND (CUST_NAME LIKE '%有限责任公司' OR CUST_NAME LIKE '%有限公司');
COMMIT;

--客户国民经济部门为C开头且不是C99的非金融企业部门，则企业规模应该在CS01至CS04范围内
--刷完之后应该还有下面按人行要求将企业规模置空的49笔报错
MERGE INTO PBOCD_JS_201_DWDKFS A
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

  --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 已过渡完，配置表中已改为失效状态
  --插入4笔福费廷贷款'20230412070919001','JLKDFFT2023000001001','JLKDFFT2023000002001','JLKDFFT2023000003001'
  --BSP_SP_JS_SPOP(IS_DATE,OI_RETCODE,OI_RETCODE_DEC,'PBOCD_JS_201_DWDKFS');

  -------------------------------------------------------------------------
  OI_RETCODE     := 0; --设置异常状态为0 成功状态
  OI_RETCODE_DEC := '执行成功';

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
    OI_RETCODE     := -1; --设置异常状态为-1
    OI_RETCODE_DEC := SQLCODE || ':' || SUBSTR(SQLERRM, 1, 50); --系统错误描述
    --插入日志表，记录错误
    SP_PBOCD_LOG(VS_PROCEDURE_NAME, 'ERROR', VI_ERRORCODE, VS_TEXT, IS_DATE);

END;