CREATE OR REPLACE PROCEDURE BSP_SP_JS_201_CLZXDK(IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_201_CLZXDK
  -- 业务域: 贷款类
  -- 用途: 生成接口表 SP_JS_201_CLZXDK 存量专项贷款
  -- 引用的监管集市表
  --    SMTMODS.L_ACCT_LOAN                                — 贷款借据信息表
  --    SMTMODS.L_ACCT_POVERTY_RELIF                       — 精准扶贫贷款补充信息
  --    SMTMODS.L_AGRE_LOAN_CONTRACT                       — 贷款合同信息表
  --    SMTMODS.L_CUST_ALL                                 — 全量客户信息表
  --    SMTMODS.L_CUST_C                                   — 对公客户补充信息表
  --    SMTMODS.L_CUST_P                                   — 对私客户补充信息表
  --    SMTMODS.L_PUBL_RATE                                — 汇率表
  -- 修改历史
  --    需求编号：JLBA202502130004_制度升级2025 上线日期：2025-03-27，修改人：周立鹏，提出人：李楠   修改原因：制度升级2025
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  --VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
  NUM               INTEGER;
  VS_LAST_DATE      VARCHAR2(8);

BEGIN
  VS_TEXT      := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  VS_LAST_TEXT := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD') + 1, 'YYYYMMDD');
  VS_LAST_DATE := TO_CHAR(TRUNC(TO_DATE(IS_DATE,'YYYYMMDD'),'MM')-1,'YYYYMMDD');

  -- 记录日志使用
  --SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_201_CLZXDK';

  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------
  --历史移植数据

  --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'JS_201_CLZXDK'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE JS_201_CLZXDK ADD PARTITION P' ||
                      IS_DATE || ' VALUES LESS THAN(' || VS_LAST_TEXT || ')';
  END IF;
  --清除当前分区表的数据
  EXECUTE IMMEDIATE 'ALTER TABLE JS_201_CLZXDK TRUNCATE PARTITION P' ||
                    IS_DATE;

  --金数全量临时表
  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_201_CLZXDK_TMP01';
  --EXECUTE IMMEDIATE 'TRUNCATE TABLE PBOCD_JS_201_CLZXDK';

  ---
  INSERT INTO JS_201_CLZXDK_TMP01
    SELECT DISTINCT T.LOAN_NUM, T.CONTRACT_CODE --存量单位贷款
      FROM PBOCD_JS_201_CLDWDK/*@PBOCD_34*/ T
     WHERE T.DATA_DATE =
           TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD')
    UNION ALL
    SELECT DISTINCT T.LOAN_NUM, T.CONTRACT_CODE --存量个人贷款
      FROM PBOCD_JS_201_CLGRDK/*@PBOCD_34*/ T
     WHERE T.DATA_DATE =
           TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  COMMIT;

  --对私客户表  A 个体工商  B 小微企业主
  EXECUTE IMMEDIATE 'TRUNCATE TABLE L_CUST_P_TMP01';
  ---
  INSERT INTO L_CUST_P_TMP01
    SELECT CUST_ID,OPERATE_CUST_TYPE
      FROM SMTMODS.L_CUST_P P --对私客户补充信息表
     WHERE P.OPERATE_CUST_TYPE IN ('A', 'B') --经营性客户类型
       AND P.CUST_ID IS NOT NULL
       AND P.DATA_DATE = IS_DATE;
  COMMIT;

--20220426 ZHOULP
    INSERT INTO L_CUST_P_TMP01
    SELECT CUST_ID,'A'
      FROM SMTMODS.L_CUST_C P --对私客户补充信息表
     WHERE P.CUST_TYP = '3' --个体工商
       AND P.CUST_ID IS NOT NULL
       AND P.DATA_DATE = IS_DATE;
  COMMIT;

  --绿色贷款数据临时表
  EXECUTE IMMEDIATE 'TRUNCATE TABLE L_AGRE_LOAN_CONTRACT_GREE_TMP01';
  ---
  INSERT INTO L_AGRE_LOAN_CONTRACT_GREE_TMP01
    SELECT DISTINCT CONTRACT_NUM,/*GREE_LOAN*/A.GREEN_LOAN_TYPE
      FROM SMTMODS.L_AGRE_LOAN_CONTRACT T --绿色贷款
    LEFT JOIN SMTMODS.L_ACCT_LOAN A --全量客户信息表
            ON T.CONTRACT_NUM=A.ACCT_NUM
           AND A.DATA_DATE = IS_DATE
     WHERE /*T.GREE_LOAN IS NOT NULL*/A.GREEN_LOAN_TYPE IS NOT NULL ---2022.1.18 夏文博
       AND T.DATA_DATE = IS_DATE
       /*AND T.CONTRACT_NUM NOT IN (------借据表缺少这3条
'051001200012114163',
'051001200012114395',
'051001200012114145'
)*/;
  COMMIT;

  --创业担保数据临时表
  EXECUTE IMMEDIATE 'TRUNCATE TABLE L_ACCT_LOAN_CYDB_TMP01';
  ---
  INSERT INTO L_ACCT_LOAN_CYDB_TMP01 T2
    SELECT LOAN_NUM,UNDERTAK_GUAR_TYPE
      FROM SMTMODS.L_ACCT_LOAN T --创业担保
     WHERE T.UNDERTAK_GUAR_TYPE <> '#' AND T.UNDERTAK_GUAR_TYPE IS NOT NULL--T.UNDERTAK_GUAR_TYPE IS NOT NULL  --MODFIFY BY DW(20220503)
       AND T.DATA_DATE = IS_DATE;
  COMMIT;

  --票据融资数据临时表
  EXECUTE IMMEDIATE 'TRUNCATE TABLE L_ACCT_LOAN_PJRZ_TMP01';
  ---
  INSERT INTO L_ACCT_LOAN_PJRZ_TMP01--贴现数据表
    SELECT LOAN_NUM
      FROM SMTMODS.L_ACCT_LOAN T --票据融资
     --WHERE T.ITEM_CD IN ('12901','12905')
     WHERE T.ITEM_CD IN ('130101','130104')--20220629 夏文博改
     /*AND T.HXRQ IS NULL  --去除核销贷款*/
       AND T.CANCEL_FLG='N'--去掉核销数据
       AND T.LOAN_ACCT_BAL > 0
       AND T.DATA_DATE = IS_DATE
       AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
       ;
  COMMIT;
  --20240604业务通知每月缺少一条贴现数据，不符合上面两个科目号，在此单独插入借据号
  INSERT INTO L_ACCT_LOAN_PJRZ_TMP01--贴现数据表
    SELECT LOAN_NUM
      FROM SMTMODS.L_ACCT_LOAN T --票据融资
     WHERE T.CANCEL_FLG='N'--去掉核销数据
       AND T.LOAN_ACCT_BAL > 0
       AND (T.LOAN_NUM='20240529171621E044000000224298'or T.ACCT_NUM='531330556001920240424001085027')
       AND T.DATA_DATE = IS_DATE
       AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
       ;
  COMMIT;

  --涉农贷款补充信息临时表
  EXECUTE IMMEDIATE 'TRUNCATE TABLE l_acct_loan_farming_tmp01';
  insert into l_acct_loan_farming_tmp01
  select F.DATA_DATE, --数据日期
         F.ACCT_NUM, --合同号
         F.LOAN_NUM, --贷款编号
         F.AGRICULTURE_TYP, --涉农贷款类型
         F.AGREI_P_FLG, --农户贷款标志
         F.AGRICULTURE_LOAN_FLG, --农业综合开发贷款标志
         F.COMP_INT_FLG, --贴息贷款标志
         F.COMP_INT_TYP, --贴息类型
         F.COMP_INT_AMT, --实收收贴息
         F.LOAN_TYP, --贷款性质
         F.COOP_LAON_FLAG, --农民合作社贷款标志
         F.RURAL_RIGNTS_LOAN_TYPE, --农村三权抵押贷款分类
         F.RUR_COLL_ECO_ORG_LOAN_FLG, --农村集体经济组织贷款标志
         F.DEPARTMENTD, --归属部门
         F.DATE_SOURCESD, --数据来源
         CASE
           WHEN P.CUST_ID IS NULL AND C.CUST_ID IS NOT NULL AND
                M.P_SNDKFL IS NOT NULL THEN
            M.P_SNDKFL
           ELSE
            F.SNDKFL
         END AS SNDKFL, --涉农贷款分类
         F.AGR_USE_ADDL
    from smtmods.l_acct_loan t
   inner join smtmods.l_acct_loan_farming f
      on t.data_date = f.data_date
     and t.loan_num = f.loan_num
    left join smtmods.m_index_sndk_mapping m
      on f.sndkfl = m.c_sndkfl --获取对公个体工商户涉农贷款分类转为个人涉农贷款分类
    left join smtmods.l_cust_p p
      on t.data_date = p.data_date
     and t.cust_id = p.cust_id
     and p.OPERATE_CUST_TYPE = 'A'
    left join smtmods.l_cust_c c
      on t.data_date = c.data_date
     and t.cust_id = c.cust_id
     and c.CUST_TYP = '3'
   where t.data_date = IS_DATE;
   COMMIT;

--精准扶贫贷款

 EXECUTE IMMEDIATE 'DELETE PBOCD_DATACORE.JZFPDK WHERE DATA_DATE = '|| IS_DATE ; --删除本期数据，避免重复插入
 COMMIT;
INSERT
INTO PBOCD_DATACORE.JZFPDK(
          DATA_DATE,     --1数据日期
            YSSJKHXM,      --2名单客户名
            WJFL,          --3五级分类
            ORG_CODE,      --4金融机构代码
            JRJGDQ,        --5金融机构地区
            ORG_NUM,       --6机构号
            DATASOURCE,    --7条线
            CUST_ID,       --8客户号
            KHXZ,          --9客户性质
            CUST_NAME,     --10客户名称
            KHSFZH,        --11客户身份证号
            ADDR,          --12客户所在地区编号
            LOAN_NUM,      --13借据号
            DKFFJE,        --14贷款发放金额
            LOAN_ACCT_BAL, --15贷款余额
            DKLL,          --16贷款利率
            DKFKRQ,        --17贷款放款日期
            DKHTDQRQ,      --18贷款合同到期日
            DKSJZZRI,      --19贷款实际终止日
            --DKMD,          --20贷款目的
            DKPZ,          --21贷款品种
            DKZL,          --22贷款质量
            DBFS,          --23担保方式
            XEXD,          --24？
            DKZJLY,        --25贷款资金来源
            FPDDRS,        --26人精准扶贫贷款带动人数
            COD_CC_BRN     --27COD_CC_BRN
                     )
 SELECT /*+parallel(4)*/  IS_DATE,        --1数据日期
           A.YSSJKHXM,       --2名单客户名
           CASE WHEN B.LOAN_GRADE_CD = '1' THEN '正常'
                       WHEN B.LOAN_GRADE_CD = '2' THEN '关注'
                       WHEN B.LOAN_GRADE_CD = '3' THEN '次级'
                       WHEN B.LOAN_GRADE_CD = '4' THEN '可疑'
                       WHEN B.LOAN_GRADE_CD = '5' THEN '损失'
           END as WJFL,           --3五级分类
           A.ORG_CODE,       --4金融机构代码
           A.JRJGDQ,         --5金融机构地区
           B.ORG_NUM,        --6机构号
           A.DATASOURCE,     --7条线
           A.CUST_ID,        --8客户号
           A.KHXZ,           --9客户性质
           A.CUST_NAME,      --10客户名称
           A.KHSFZH,         --11客户身份证号
           A.ADDR,           --12客户所在地区编号
           A.LOAN_NUM,       --13借据号
           B.DRAWDOWN_AMT AS DKFFJE,         --14贷款发放金额
           B.LOAN_ACCT_BAL AS LOAN_ACCT_BAL,  --15贷款余额
           A.DKLL,           --16贷款利率
           A.DKFKRQ,         --17贷款放款日期
           A.DKHTDQRQ,       --18贷款合同到期日
           TO_CHAR(B.ACTUAL_MATURITY_DT,'YYYYMMDD') AS DKSJZZRI,       --19贷款实际终止日
           --A.DKMD,           --20贷款目的
           A.DKPZ,           --21贷款品种
           A.DKZL,           --22贷款质量
           A.DBFS,           --23担保方式
           A.XEXD,           --24小额信贷（暂未启用，留空）
           A.DKZJLY,         --25贷款资金来源
           A.FPDDRS,         --26人精准扶贫贷款带动人数
           A.COD_CC_BRN      --27COD_CC_BRN
    FROM  PBOCD_DATACORE.JZFPDK A
    LEFT JOIN SMTMODS.L_ACCT_LOAN B
    ON A.LOAN_NUM = B.LOAN_NUM AND B.DATA_DATE = IS_DATE
  WHERE A.DATA_DATE = VS_LAST_DATE; --取上期数据和本期数据
COMMIT;
--脚本查询的-16贷款利率与其他类似字段数字格式不同，无法采用UNION的方式简化代码。
INSERT
INTO PBOCD_DATACORE.JZFPDK(
          DATA_DATE,     --1数据日期
            YSSJKHXM,      --2名单客户名
            WJFL,          --3五级分类
            ORG_CODE,      --4金融机构代码
            JRJGDQ,        --5金融机构地区
            ORG_NUM,       --6机构号
            DATASOURCE,    --7条线
            CUST_ID,       --8客户号
            KHXZ,          --9客户性质
            CUST_NAME,     --10客户名称
            KHSFZH,        --11客户身份证号
            ADDR,          --12客户所在地区编号
            LOAN_NUM,      --13借据号
            DKFFJE,        --14贷款发放金额
            LOAN_ACCT_BAL, --15贷款余额
            DKLL,          --16贷款利率
            DKFKRQ,        --17贷款放款日期
            DKHTDQRQ,      --18贷款合同到期日
            DKSJZZRI,      --19贷款实际终止日
            --DKMD,          --20贷款目的
            DKPZ,          --21贷款品种
            DKZL,          --22贷款质量
            DBFS,          --23担保方式
            XEXD,          --24？
            DKZJLY,        --25贷款资金来源
            FPDDRS,        --26人精准扶贫贷款带动人数
            COD_CC_BRN     --27COD_CC_BRN
                     )
  SELECT /*+PARALLEL(4)*/
 IS_DATE,                                                               --1数据日期
 P.COL_13 AS"名单客户名",                                               --2名单客户名
 CASE
   WHEN B.LOAN_GRADE_CD = '1' THEN
    '正常'
   WHEN B.LOAN_GRADE_CD = '2' THEN
    '关注'
   WHEN B.LOAN_GRADE_CD = '3' THEN
    '次级'
   WHEN B.LOAN_GRADE_CD = '4' THEN
    '可疑'
   WHEN B.LOAN_GRADE_CD = '5' THEN
    '损失'
 END "贷款五级分类",                                                  --3五级分类
--D.JRJGBM "金融机构代码",                                             --4金融机构代码
 --D.AREA_ID "金融机构地区",                                            --5金融机构地区
 '' "金融机构代码",                                             --4金融机构代码
 '' "金融机构地区",                                            --5金融机构地区
 B.ORG_NUM "机构号",                                                  --6机构号
 B.DEPARTMENTD "条线",                                                --7条线
 A.CUST_ID "客户编号",                                                --8客户号
 CASE WHEN P.COL_11 = '脱贫' THEN '已脱贫' ELSE  P.COL_11 END  "客户性质",                                                 --9客户性质
 A.CUST_NAM "客户姓名",                                               --10客户名称
 A.ID_NO "客户身份证号",                                              --11客户身份证号
 A.REGION_CD "客户所在地区",                                          --12客户所在地区编号
 B.LOAN_NUM "贷款借据编号",                                           --13借据号
 B.DRAWDOWN_AMT "贷款发放金额",                                       --14贷款发放金额
 B.LOAN_ACCT_BAL "贷款余额",                                          --15贷款余额
 B.REAL_INT_RAT "贷款利率",                                           --16贷款利率
 TO_CHAR(B.DRAWDOWN_DT,'YYYYMMDD')  "贷款放款日期",                   --17贷款放款日期
  TO_CHAR(C.CONTRACT_ORIG_MATURITY_DT,'YYYYMMDD')  "贷款合同到期日",  --18贷款合同到期日
 TO_CHAR( B.ACTUAL_MATURITY_DT,'YYYYMMDD')  "贷款实际终止日",         --19贷款实际终止日
 --B.USEOFUNDS "贷款目的",                                              --20贷款目的
 C.PROD_NAME "贷款品种",                                              --21贷款品种
 NULL "贷款质量",                                                     --22贷款质量
 B.GUARANTY_TYP "担保方式",                                           --23担保方式
 NULL ,                                                               --24小额信贷（暂未启用，留空）
 P.COL_11 "贷款资金来源",                                             --25贷款资金来源
 NULL "人精准扶贫贷款带动人数",                                       --26人精准扶贫贷款带动人数
 B.ORG_NUM "COD_CC_BRN"                                               --27COD_CC_BRN
  FROM CBRC_DATACORE.L_POORHOUSEHOLD P --已脱贫人口名单
 INNER JOIN SMTMODS.L_CUST_ALL A   --全量客户信息表
    ON P.COL_12 = A.ID_NO
   AND A.DATA_DATE = IS_DATE
 INNER JOIN SMTMODS.L_ACCT_LOAN B  --贷款借据信息表
    ON A.CUST_ID = B.CUST_ID
   AND B.DATA_DATE = IS_DATE
  LEFT JOIN SMTMODS.L_AGRE_LOAN_CONTRACT C --贷款合同信息表
    ON B.ACCT_NUM = C.CONTRACT_NUM
   AND C.DATA_DATE = IS_DATE
  /*LEFT JOIN PBOCD_DATACORE.SYS_OFFICE D  --机构表
    ON B.ORG_NUM = D.ID*/
/*  LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=B.ORG_NUM AND OB.DATA_DATE=IS_DATE*/
 WHERE P.PATH LIKE 'D:\zjk\贫困户名录%'
   AND (SUBSTR(TO_CHAR(B.DRAWDOWN_DT, 'YYYYMMDD'),1,6)  = SUBSTR(IS_DATE,1,6)
   -- MODIFY BY ZHOULP 20250115 BEGIN 无需求，王铣发王铭邮件日期20250113 互联网贷款数据晚一天下发，上月末数据当月取
   --[2025-09-18] [周立鹏] [JLBA202507300010关于新一代信贷管理系统新增线上微贷板块的需求][从需求] 新增产品'DK001000100041'
   -- OR (B.INTERNET_LOAN_FLG = 'Y' AND B.DRAWDOWN_DT = TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD'), 'MM') - 1))  ;
    OR ((B.INTERNET_LOAN_FLG = 'Y' OR B.CP_ID = 'DK001000100041') AND B.DRAWDOWN_DT = TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD'), 'MM') - 1))  ;
COMMIT;



/*  DELETE FROM JS_201_CLZXDK WHERE DATA_DATE = IS_DATE;
  COMMIT;*/

  INSERT /*+ APPEND*/
  INTO JS_201_CLZXDK NOLOGGING
    (DATA_DATE, -- 1 数据日期
     ORG_CODE, -- 2 金融机构代码
     LOAN_NUM, -- 3 贷款借据编码
     CONTRACT_CODE, -- 4 贷款合同编码
     INDIVBUSI_FLG, -- 5 是否个体工商户贷款
     SMBUSI_FLG, -- 6 是否小微企业主贷款
     AGRI_FLG, -- 7 是否涉农贷款
     AGRI_TYPE, -- 8 涉农贷款类型
     POORLOAN_FLG, -- 9 是否精准扶贫贷款
     POORPER_FLG, -- 10 是否建档立卡贫困人口贷款
     LGOVFIN_FLG, -- 11 是否地方政府融资平台贷款
     LGOV_TYPE, -- 12 地方融资平台按法律性质分类类型
     LGOV_LEVEL, -- 13 地方融资平台按隶属关系分类类型
     LGOVCAPITAL_TYPE, -- 14 地方融资平台偿债资金来源分类
     LINCOMEHOUSE_FLG, -- 15 是否保障性安居工程贷款
     LINCOMEHOUSE_TYPE, -- 16 保障性安居工程贷款类型
     GREEN_FLG, -- 17 是否绿色贷款
     VENTURE_FLG, -- 18 是否创业担保贷款
     VENTURE_TYPE, -- 19 创业担保贷款类型
     REPORT_ID, -- 20 报送ID
     CJRQ, -- 21 采集日期
     NBJGH, -- 22 内部机构号
     BIZ_LINE_ID, -- 23 业务条线
     VERIFY_STATUS, -- 24 校验状态
     BSCJRQ, -- 25 报送周期
     ORG_NUM, -- 26 内部机构号
     FRNBJGH, -- 27 法人内部机构号
     CURR_CODE, -- 28 币种
     BALANCE, -- 29 余额
     CUST_NAME, -- 30 客户名称
     CUST_ID, -- 31 客户号
     BALANCE_RMB, -- 32 余额折人民币
     --add by dw(20240124) 2024制度升级新增字段，口径同1104
     HIGH_TECH_TYPE, --33 高技术制造业类型
     HIGH_TECH_FLG --34 是否高技术制造业
     )
    SELECT /*+ USE_HASH(T,T3,P,F,C,P1,C1,J,J1,D,B,T1,T2,R) parallel(4)*/

     IS_DATE AS DATA_DATE, -- 1 数据日期

     '',--OFF.JRJGBM AS ORG_CODE, -- 2 金融机构代码

     T.LOAN_NUM AS LOAN_NUM, -- 3 贷款借据编码

     T.ACCT_NUM AS CONTRACT_CODE, -- 4 贷款合同编码

     CASE
       WHEN P.OPERATE_CUST_TYPE = 'A' AND (T.ACCT_TYP = '010299' OR T.ACCT_TYP  LIKE '0102%')  THEN
        '1'
       ELSE
        '0'
     END AS INDIVBUSI_FLG, -- 5 是否个体工商户贷款
         /* CASE
       WHEN P.OPERATE_CUST_TYPE = 'A' AND T.ACCT_TYP IN ('0102', '010299') THEN
        '1'
       ELSE
        '0'
     END AS INDIVBUSI_FLG, -- 5 是否个体工商户贷款*/
     CASE
       WHEN P.OPERATE_CUST_TYPE = 'B' AND (T.ACCT_TYP = '010299' OR T.ACCT_TYP  LIKE '0102%') THEN
        '1'
       ELSE
        '0'
     END AS SMBUSI_FLG, -- 6 是否小微企业主贷款
     /*CASE
       WHEN F.LOAN_NUM IS NULL THEN
        '0'
       WHEN F.SNDKFL IS NULL AND F.LOAN_NUM IS NOT NULL THEN
       '0' --20211213 WXY
       ELSE
        '1'
     END AS AGRI_FLG, -- 7 是否涉农贷款*/
     
     -- 农产品加工贷款不包括精深加工和贷款投向为农产品初加工、林产品初加工的贷款  此逻辑与大集中A1433_12P1R同步  zhoulp20251120
     CASE WHEN F.SNDKFL IS NOT NULL AND (CASE WHEN SUBSTR(F.SNDKFL, 0, 7) IN ('C_10202','C_20202') AND (NVL(F.AGR_USE_ADDL,'#') IN ('05') OR NVL(T.LOAN_PURPOSE_CD,'#') IN('A0514','A0523')) THEN 1 ELSE 0 END)=0
       THEN '1'
          ELSE '0'
     END AS AGRI_FLG, --是否涉农贷款   
     CASE WHEN F.SNDKFL IS NOT NULL AND (CASE WHEN SUBSTR(F.SNDKFL, 0, 7) IN ('C_10202','C_20202') AND (NVL(F.AGR_USE_ADDL,'#') IN ('05') OR NVL(T.LOAN_PURPOSE_CD,'#') IN('A0514','A0523')) THEN 1 ELSE 0 END)=0 THEN
     CASE
       WHEN F.LOAN_NUM IS NOT NULL AND F.SNDKFL LIKE 'P_201%' AND T.LOAN_PURPOSE_CD LIKE 'A%'  THEN
        'N01' --非农户个人农林牧渔业贷款 --贷款投向A农、林、牧、渔业 --AGREI_P_FLG农户贷款标志
       WHEN F.LOAN_NUM IS NOT NULL AND SUBSTR(F.SNDKFL, 1, 5) IN ('P_101', 'P_102', 'P_103') THEN
        'N02' --农户贷款
       WHEN F.LOAN_NUM IS NOT NULL AND F.SNDKFL LIKE 'C_1%' THEN
        'N03' --农村企业贷款
       WHEN F.LOAN_NUM IS NOT NULL AND SUBSTR(F.SNDKFL, 0, 3) = 'C_2'  THEN
        'N04' --农村各类组织贷款
       WHEN F.LOAN_NUM IS NOT NULL AND ((F.SNDKFL LIKE 'C_3%' AND  T.LOAN_PURPOSE_CD LIKE 'A%')OR F.SNDKFL LIKE 'C_302%' OR F.SNDKFL LIKE 'C_301%' ) THEN
        'N05' --城市企业涉农贷款
        WHEN F.LOAN_NUM IS NOT NULL AND F.SNDKFL LIKE 'C_4%'  THEN
        'N06' --城市各类组织涉农贷款
     END END AS AGRI_TYPE, -- 8 涉农贷款类型
    /* CASE
        WHEN F.AGRICULTURE_TYP='1' AND F.AGREI_P_FLG = 'N' THEN 'N01'
        WHEN (C1.CITY_VILLAGE_FLG='Y' AND C1.CUST_TYP='3') OR H.CITY_VILLAGE_FLG='Y' THEN 'N02'
        WHEN C1.CITY_VILLAGE_FLG='Y' AND C1.CUST_TYP IN ('11','12','9','0') THEN 'N03'
        WHEN C1.CITY_VILLAGE_FLG='Y' AND C1.CUST_TYP IN ('21','22','23','24','4','5','6','7','8') THEN 'N04'
        WHEN C1.CITY_VILLAGE_FLG='N' AND C1.CUST_TYP IN ('11','12','9','0') THEN 'N05'
        WHEN C1.CITY_VILLAGE_FLG='N' AND C1.CUST_TYP IN ('21','22','23','24','4','5','6','7','8') THEN 'N06'
        ELSE 'N09'

       END AS AGRI_TYPE, --8涉农贷款类型  ---2022.1.18 夏文博修改 */

     CASE
       WHEN J.LOAN_NUM IS NOT NULL THEN
        '1'
       WHEN J1.LOAN_NUM IS NOT NULL THEN
        '1'
       ELSE
        '0'
     END AS POORLOAN_FLG, -- 9 是否精准扶贫贷款

     --[2025-03-27] [周立鹏] [JLBA202502130004_制度升级2025][李楠] 停报
     /*CASE
       WHEN J.KHXZ IN ('未脱贫', '返贫') THEN
        '1'
       WHEN J1.POV_RE_LOAN_TYPE = 'A01'  AND C1.CUST_ID IS NOT NULL  THEN
        '1'
       ELSE
        '0'
     END AS POORPER_FLG, -- 10 是否建档立卡贫困人口贷款*/
     NULL AS POORPER_FLG, -- 10 是否建档立卡贫困人口贷款*/

    /* CASE
       WHEN D.LOAN_NUM IS NULL THEN
        '0'
       ELSE
        '1'
     END */NULL AS LGOVFIN_FLG, -- 11 是否地方政府融资平台贷款 DEL BY DW(20220804)

    /* CASE
       WHEN D.LOAN_NUM IS NOT NULL THEN
        '03'
     END */ NULL AS LGOV_TYPE, -- 12 地方融资平台按法律性质分类类型 DEL BY DW(20220804)

     /*CASE
       WHEN D.JB = '区县级' THEN
        '03'
       WHEN D.JB = '地市级' THEN
        '02'
       WHEN D.JB = '省级' THEN
        '01'
     END */NULL AS LGOV_LEVEL, -- 13 地方融资平台按隶属关系分类类型 DEL BY DW(20220804)

     /*CASE
       WHEN D.ZCLY = '财政性资金' THEN
        '01'
       WHEN D.ZCLY = '自有资金' THEN
        '02'
     END */NULL AS LGOVCAPITAL_TYPE, -- 14 地方融资平台偿债资金来源分类 DEL BY DW(20220804)

     CASE
       WHEN B.LOAN_NUM IS NULL THEN
        '0'
       ELSE
        '1'
     END AS LINCOMEHOUSE_FLG, -- 15 是否保障性安居工程贷款

     CASE
       WHEN B.BZXAJGCFL = '廉租住房贷款-开发贷款' THEN
        'B011'
       WHEN B.BZXAJGCFL = '廉租住房贷款-收购贷款' THEN
        'B012'
       WHEN B.BZXAJGCFL = '廉租住房贷款-租赁贷款' THEN
        'B013'
       WHEN B.BZXAJGCFL = '公共租赁住房贷款-开发贷款' THEN
        'B021'
       WHEN B.BZXAJGCFL = '公共租赁住房贷款-收购贷款' THEN
        'B022'
       WHEN B.BZXAJGCFL = '公共租赁住房贷款-租赁贷款' THEN
        'B023'
       WHEN B.BZXAJGCFL = '经济适用住房开发贷款' THEN
        'B03'
       WHEN B.BZXAJGCFL = '限价商品住房开发贷款' THEN
        'B04'
       WHEN B.BZXAJGCFL IN ('棚户区改造贷款-城市棚户区改造',
                            '棚户区改造贷款-国有工矿棚户区改造',
                            '棚户区改造贷款-国有林区棚户区改造',
                            '棚户区改造贷款-国有林场危旧房改造',
                            '棚户区改造贷款-国有垦区危房改造',
                            '棚户区改造贷款-中央下放地方煤矿棚户区改造',
                            '棚户区改造贷款-旧住宅小区整治',
                            '棚户区改造贷款-城中村改造',
                            '棚户区改造贷款-棚户区土地收购',
                            '棚户区改造贷款-棚户区拆迁及安置房建设') THEN
        'B05'
       WHEN B.BZXAJGCFL IN ('农村危房改造贷款-整栋危房（D级）',
                            '农村危房改造贷款-局部危险（C级）') THEN
        'B06'
       WHEN B.BZXAJGCFL = '游牧民定居工程贷款' THEN
        'B07'

     END AS LINCOMEHOUSE_TYPE, -- 16 保障性安居工程贷款类型

     --[2025-03-27] [周立鹏] [JLBA202502130004_制度升级2025][李楠] 停报
     /*CASE
       WHEN T1.GREE_LOAN IS NULL THEN
        '0'
       ELSE
        '1'
     END AS GREEN_FLG, -- 17 是否绿色贷款

     CASE
       WHEN T2.UNDERTAK_GUAR_TYPE IS NULL THEN
        '0'
       ELSE
        '1'
     END AS VENTURE_FLG, -- 18 是否创业担保贷款

     CASE
       WHEN T2.UNDERTAK_GUAR_TYPE IN ('A', 'B') THEN
        'C01'
       WHEN T2.UNDERTAK_GUAR_TYPE = 'Z' THEN
        'C02'
     END AS VENTURE_TYPE, -- 19 创业担保贷款类型*/
     NULL AS GREEN_FLG, -- 17 是否绿色贷款
     NULL AS VENTURE_FLG, -- 18 是否创业担保贷款
     NULL AS VENTURE_TYPE, -- 19 创业担保贷款类型

     SYS_GUID() AS REPORT_ID, -- 20 报送ID

     IS_DATE AS CJRQ, -- 21 采集日期

     T.ORG_NUM AS NBJGH, -- 22 内部机构号

     '' AS BIZ_LINE_ID,--业务条线
     '' AS VERIFY_STATUS, -- 24 校验状态

     '' AS BSCJRQ, -- 25 报送周期

     T.ORG_NUM AS ORG_NUM, -- 26 内部机构号

     --'000000' AS FRNBJGH, -- 27 法人内部机构号
    /* CASE WHEN T.ORG_NUM LIKE '5100%' THEN '510000' ELSE '990000' END FRNBJGH,*/
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
             END FRNBJGH,
     T.CURR_CD AS CURR_CODE, -- 28 币种

     T.LOAN_ACCT_BAL AS BALANCE, -- 29 余额

     /*C1.CUST_NAM AS CUST_NAME, -- 30 客户名称*/
     NVL(C1.CUST_NAM,H.CUST_NAM) AS CUST_NAME,-- 30 客户名称

     T.CUST_ID AS CUST_ID, -- 31 客户号

     T.LOAN_ACCT_BAL * R.CCY_RATE AS BALANCE_RMB, -- 32 余额折人民币
     --20240926_ZHOULP_JLBA202406280007_停报高新技术制造业贷款
     /* --add by dw(20240124) 2024制度升级新增字段，口径同1104
     CASE WHEN T.LOAN_PURPOSE_CD IN ('C2710','C2720','C2730','C2740','C2750','C2761','C2762','C2770','C2780') THEN 'HTP01' --医药制造业
                 WHEN T.LOAN_PURPOSE_CD IN ('C3741','C3742','C3743','C3744','C3749','C4343') THEN 'HTP02' --航空、航天器及设备制造业
                 WHEN T.LOAN_PURPOSE_CD IN ('C3562','C3563','C3569','C3832','C3833','C3841','C3921','C3922','C3940','C3931','C3932','C3933','C3934','C3939','C3951','C3952','C3953','C3971','C3972','C3973','C3974','C3975','C3976','C3979','C3981','C3982','C3983','C3984','C3985','C3989','C3961','C3962','C3963','C3969','C3990') THEN 'HTP03' --电子及通信设备制造业
                 WHEN T.LOAN_PURPOSE_CD IN ('C3911','C3912','C3913','C3914','C3915','C3919','C3474','C3475') THEN 'HTP04' --计算机及办公设备制造业
                 WHEN T.LOAN_PURPOSE_CD IN ('C3581','C3582','C3583','C3584','C3585','C3586','C3589','C4011','C4012','C4013','C4014','C4015','C4016','C4019','C4021','C4022','C4023','C4024','C4025','C4026','C4027','C4028','C4029','C4040','C4090') THEN 'HTP05' --医疗仪器设备及仪器仪表制造业
                 WHEN T.LOAN_PURPOSE_CD IN ('C2664','C2665') THEN 'HTP06' --信息化学品制造业
     END HIGH_TECH_TYPE, --33 高技术制造业类型
     CASE WHEN T.LOAN_PURPOSE_CD IN (
       'C2710','C2720','C2730','C2740','C2750','C2761','C2762','C2770','C2780', --医药制造业
       'C3741','C3742','C3743','C3744','C3749','C4343',--航空、航天器及设备制造业
       'C3562','C3563','C3569','C3832','C3833','C3841','C3921','C3922','C3940','C3931','C3932','C3933','C3934','C3939','C3951','C3952','C3953','C3971','C3972','C3973','C3974','C3975','C3976','C3979','C3981','C3982','C3983','C3984','C3985','C3989','C3961','C3962','C3963','C3969','C3990',--电子及通信设备制造业
       'C3911','C3912','C3913','C3914','C3915','C3919','C3474','C3475',--计算机及办公设备制造业
       'C3581','C3582','C3583','C3584','C3585','C3586','C3589','C4011','C4012','C4013','C4014','C4015','C4016','C4019','C4021','C4022','C4023','C4024','C4025','C4026','C4027','C4028','C4029','C4040','C4090',--医疗仪器设备及仪器仪表制造业
       'C2664','C2665'--信息化学品制造业
       ) THEN '1' ELSE '0'
     END HIGH_TECH_FLG --34 是否高技术制造业*/
     '' HIGH_TECH_TYPE, --33 高技术制造业类型
     '' HIGH_TECH_FLG --34 是否高技术制造业
      FROM SMTMODS.L_ACCT_LOAN T -- 贷款借据信息表

     INNER JOIN JS_201_CLZXDK_TMP01 T3 --QUANLIANG
        ON T.LOAN_NUM = T3.LOAN_NUM
      LEFT JOIN L_CUST_P_TMP01 P --对私客户补充信息表
        ON T.CUST_ID = P.CUST_ID
      LEFT JOIN SMTMODS.L_CUST_P H --对私客户补充信息表
        ON T.CUST_ID = H.CUST_ID
       AND H.DATA_DATE = IS_DATE
      LEFT JOIN l_acct_loan_farming_tmp01 F --涉农贷款补充信息
        ON T.LOAN_NUM = F.LOAN_NUM
       AND T.DATA_DATE = F.DATA_DATE
      LEFT JOIN SMTMODS.L_AGRE_LOAN_CONTRACT C --贷款合同信息表
        ON T.ACCT_NUM = C.CONTRACT_NUM
       AND T.DATA_DATE = C.DATA_DATE
      LEFT JOIN SMTMODS.L_CUST_C C1 --对公客户补充信息表
        ON T.CUST_ID = C1.CUST_ID
       AND T.DATA_DATE = C1.DATA_DATE
      LEFT JOIN PBOCD_DATACORE.JZFPDK J --精准扶贫贷款--个人客户精准扶贫
        ON T.LOAN_NUM = J.LOAN_NUM
       AND T.DATA_DATE = J.DATA_DATE
      LEFT JOIN (
           SELECT J1.* FROM SMTMODS.L_ACCT_POVERTY_RELIF J1
           INNER JOIN SMTMODS.L_ACCT_LOAN QQ
           ON J1.LOAN_NUM = QQ.LOAN_NUM AND QQ.DATA_DATE = IS_DATE
           INNER JOIN SMTMODS.L_CUST_C Q1
           ON QQ.CUST_ID = Q1.CUST_ID AND Q1.DATA_DATE = IS_DATE AND Q1.CUST_TYP <> '3' --去除个体工商户
           WHERE J1.DATA_DATE = IS_DATE
      ) J1 --精准扶贫贷款 --对公客户精准扶贫
        ON T.LOAN_NUM = J1.LOAN_NUM
       AND T.DATA_DATE = J1.DATA_DATE
       --del by dw(20220804) begin
       --人行要求字段暂时保留，置空处理
     /* LEFT JOIN DFZFRZPT@PBOCD1 D --地方政府融资平台
        ON T.LOAN_NUM = D.LOAN_NUM
       AND T.DATA_DATE = D.DATA_DATE*/
       --del by dw(20220804) end
      LEFT JOIN BZXAJGCDK/*@PBOCD1*/ B --保障性安居工程贷款
        ON T.LOAN_NUM = B.LOAN_NUM
       AND T.DATA_DATE = B.DATA_DATE
      --[2025-03-27] [周立鹏] [JLBA202502130004_制度升级2025][李楠] 停报
      /*LEFT JOIN L_AGRE_LOAN_CONTRACT_GREE_TMP01 T1 --绿色贷款
        ON T.ACCT_NUM = T1.CONTRACT_NUM
      LEFT JOIN L_ACCT_LOAN_CYDB_TMP01 T2 --创业担保贷款
        ON T.LOAN_NUM = T2.LOAN_NUM*/
      LEFT JOIN SMTMODS.L_PUBL_RATE R
        ON R.DATA_DATE = IS_DATE
       AND R.BASIC_CCY = T.CURR_CD --基准币种
       AND R.FORWARD_CCY = 'CNY' --折算类型
       AND R.DATA_DATE = IS_DATE
     WHERE T.DATA_DATE = IS_DATE;

  COMMIT;

  -----------------------------------票据融资---------------------------------------------
  INSERT /*+ APPEND*/
  INTO JS_201_CLZXDK NOLOGGING
    (DATA_DATE, -- 1 数据日期
     ORG_CODE, -- 2 金融机构代码
     LOAN_NUM, -- 3 贷款借据编码
     CONTRACT_CODE, -- 4 贷款合同编码
     INDIVBUSI_FLG, -- 5 是否个体工商户贷款
     SMBUSI_FLG, -- 6 是否小微企业主贷款
     AGRI_FLG, -- 7 是否涉农贷款
     AGRI_TYPE, -- 8 涉农贷款类型
     POORLOAN_FLG, -- 9 是否精准扶贫贷款
     POORPER_FLG, -- 10 是否建档立卡贫困人口贷款
     LGOVFIN_FLG, -- 11 是否地方政府融资平台贷款
     LGOV_TYPE, -- 12 地方融资平台按法律性质分类类型
     LGOV_LEVEL, -- 13 地方融资平台按隶属关系分类类型
     LGOVCAPITAL_TYPE, -- 14 地方融资平台偿债资金来源分类
     LINCOMEHOUSE_FLG, -- 15 是否保障性安居工程贷款
     LINCOMEHOUSE_TYPE, -- 16 保障性安居工程贷款类型
     GREEN_FLG, -- 17 是否绿色贷款
     VENTURE_FLG, -- 18 是否创业担保贷款
     VENTURE_TYPE, -- 19 创业担保贷款类型
     REPORT_ID, -- 20 报送ID
     CJRQ, -- 21 采集日期
     NBJGH, -- 22 内部机构号
     BIZ_LINE_ID, -- 23 业务条线
     VERIFY_STATUS, -- 24 校验状态
     BSCJRQ, -- 25 报送周期
     ORG_NUM, -- 26 内部机构号
     FRNBJGH, -- 27 法人内部机构号
     CURR_CODE, -- 28 币种
     BALANCE, -- 29 余额
     CUST_NAME, -- 30 客户名称
     CUST_ID, -- 31 客户号
     BALANCE_RMB, -- 32 余额折人民币
     HIGH_TECH_TYPE, --33 高技术制造业贷款类型
     HIGH_TECH_FLG --34 是否高技术制造业贷款
     )
    SELECT /*+ parallel(4)*/

     IS_DATE AS DATA_DATE, -- 1 数据日期

     '',--OFF.JRJGBM AS ORG_CODE, -- 2 金融机构代码

     T.LOAN_NUM AS LOAN_NUM, -- 3 贷款借据编码

     T.ACCT_NUM AS CONTRACT_CODE, -- 4 贷款合同编码

     CASE
       WHEN P.OPERATE_CUST_TYPE = 'A' AND (T.ACCT_TYP = '010299' OR T.ACCT_TYP  LIKE '0102%') THEN
        '1'
       ELSE
        '0'
     END AS INDIVBUSI_FLG, -- 5 是否个体工商户贷款
    /* CASE
       WHEN P.OPERATE_CUST_TYPE = 'A' AND T.ACCT_TYP IN ('0102', '010299') THEN
        '1'
       ELSE
        '0'
     END AS INDIVBUSI_FLG, -- 5 是否个体工商户贷款  */
     CASE
       WHEN P.OPERATE_CUST_TYPE = 'B' AND (T.ACCT_TYP = '010299' OR T.ACCT_TYP  LIKE '0102%') THEN
        '1'
       ELSE
        '0'
     END AS SMBUSI_FLG, -- 6 是否小微企业主贷款
     /*CASE
       WHEN F.LOAN_NUM IS NULL THEN
        '0'
       ELSE
        '1'
     END AS AGRI_FLG, -- 7 是否涉农贷款*/
     -- 农产品加工贷款不包括精深加工和贷款投向为农产品初加工、林产品初加工的贷款  此逻辑与大集中A1433_12P1R同步  zhoulp20251120
     CASE WHEN F.SNDKFL IS NOT NULL AND (CASE WHEN SUBSTR(F.SNDKFL, 0, 7) IN ('C_10202','C_20202') AND (NVL(F.AGR_USE_ADDL,'#') IN ('05') OR NVL(T.LOAN_PURPOSE_CD,'#') IN('A0514','A0523')) THEN 1 ELSE 0 END)=0
       THEN '1'
          ELSE '0'
     END AS AGRI_FLG, --是否涉农贷款
     
     CASE WHEN F.SNDKFL IS NOT NULL AND (CASE WHEN SUBSTR(F.SNDKFL, 0, 7) IN ('C_10202','C_20202') AND (NVL(F.AGR_USE_ADDL,'#') IN ('05') OR NVL(T.LOAN_PURPOSE_CD,'#') IN('A0514','A0523')) THEN 1 ELSE 0 END)=0 THEN
     CASE
       WHEN F.LOAN_NUM IS NOT NULL AND F.SNDKFL LIKE 'P_201%' AND T.LOAN_PURPOSE_CD LIKE 'A%'  THEN
        'N01' --非农户个人农林牧渔业贷款 --贷款投向A农、林、牧、渔业 --AGREI_P_FLG农户贷款标志
       WHEN F.LOAN_NUM IS NOT NULL AND SUBSTR(F.SNDKFL, 1, 5) IN ('P_101', 'P_102', 'P_103') THEN
        'N02' --农户贷款
       WHEN F.LOAN_NUM IS NOT NULL AND F.SNDKFL LIKE 'C_1%' THEN
        'N03' --农村企业贷款
       WHEN F.LOAN_NUM IS NOT NULL AND SUBSTR(F.SNDKFL, 0, 3) = 'C_2'  THEN
        'N04' --农村各类组织贷款
       WHEN F.LOAN_NUM IS NOT NULL AND ((F.SNDKFL LIKE 'C_3%' AND  T.LOAN_PURPOSE_CD LIKE 'A%')OR F.SNDKFL LIKE 'C_302%' OR F.SNDKFL LIKE 'C_301%' ) THEN
        'N05' --城市企业涉农贷款
        WHEN F.LOAN_NUM IS NOT NULL AND F.SNDKFL LIKE 'C_4%'  THEN
        'N06' --城市各类组织涉农贷款
     END END AS AGRI_TYPE, -- 8 涉农贷款类型
/*     CASE
        WHEN F.AGRICULTURE_TYP='1' AND F.AGREI_P_FLG = 'N' THEN 'N01'
        WHEN (C1.CITY_VILLAGE_FLG='Y' AND C1.CUST_TYP='3') OR P1.CITY_VILLAGE_FLG='Y' THEN 'N02'
        WHEN C1.CITY_VILLAGE_FLG='Y' AND C1.CUST_TYP IN ('11','12','9','0') THEN 'N03'
        WHEN C1.CITY_VILLAGE_FLG='Y' AND C1.CUST_TYP IN ('21','22','23','24','4','5','6','7','8') THEN 'N04'
        WHEN C1.CITY_VILLAGE_FLG='N' AND C1.CUST_TYP IN ('11','12','9','0') THEN 'N05'
        WHEN C1.CITY_VILLAGE_FLG='N' AND C1.CUST_TYP IN ('21','22','23','24','4','5','6','7','8') THEN 'N06'
        ELSE 'N09'

       END AS AGRI_TYPE, --8涉农贷款类型  ---2022.1.18 夏文博修改 */

     CASE
       WHEN J.LOAN_NUM IS NOT NULL THEN
        '1'
       WHEN J1.LOAN_NUM IS NOT NULL THEN
        '1'
       ELSE
        '0'
     END AS POORLOAN_FLG, -- 9 是否精准扶贫贷款

     --[2025-03-27] [周立鹏] [JLBA202502130004_制度升级2025][李楠] 停报
     /*CASE
       WHEN J.KHXZ IN ('未脱贫', '返贫') THEN
        '1'
       WHEN J1.POV_RE_LOAN_TYPE = 'A01' AND C1.CUST_ID IS NOT NULL  THEN
        '1'
       ELSE
        '0'
     END AS POORPER_FLG, -- 10 是否建档立卡贫困人口贷款*/
     NULL AS POORPER_FLG, -- 10 是否建档立卡贫困人口贷款

     /*CASE
       WHEN D.LOAN_NUM IS NULL THEN
        '0'
       ELSE
        '1'
     END*/ NULL AS LGOVFIN_FLG, -- 11 是否地方政府融资平台贷款 --20250327_ZHOULP_JLBA202502130004_制度升级2025 之前漏删票据这部分

     /*CASE
       WHEN D.LOAN_NUM IS NOT NULL THEN
        '03'
     END*/ NULL AS LGOV_TYPE, -- 12 地方融资平台按法律性质分类类型 --[2025-03-27] [周立鹏] [JLBA202502130004_制度升级2025][李楠] 之前漏删票据这部分

     /*CASE
       WHEN D.JB = '区县级' THEN
        '03'
       WHEN D.JB = '地市级' THEN
        '02'
       WHEN D.JB = '省级' THEN
        '01'
     END*/ NULL AS LGOV_LEVEL, -- 13 地方融资平台按隶属关系分类类型 --[2025-03-27] [周立鹏] [JLBA202502130004_制度升级2025][李楠] 之前漏删票据这部分

     /*CASE
       WHEN D.ZCLY = '财政性资金' THEN
        '01'
       WHEN D.ZCLY = '自有资金' THEN
        '02'
     END*/ NULL AS LGOVCAPITAL_TYPE, -- 14 地方融资平台偿债资金来源分类 --[2025-03-27] [周立鹏] [JLBA202502130004_制度升级2025][李楠] 之前漏删票据这部分

     CASE
       WHEN B.LOAN_NUM IS NULL THEN
        '0'
       ELSE
        '1'
     END AS LINCOMEHOUSE_FLG, -- 15 是否保障性安居工程贷款

     CASE
       WHEN B.BZXAJGCFL = '廉租住房贷款-开发贷款' THEN
        'B011'
       WHEN B.BZXAJGCFL = '廉租住房贷款-收购贷款' THEN
        'B012'
       WHEN B.BZXAJGCFL = '廉租住房贷款-租赁贷款' THEN
        'B013'
       WHEN B.BZXAJGCFL = '公共租赁住房贷款-开发贷款' THEN
        'B021'
       WHEN B.BZXAJGCFL = '公共租赁住房贷款-收购贷款' THEN
        'B022'
       WHEN B.BZXAJGCFL = '公共租赁住房贷款-租赁贷款' THEN
        'B023'
       WHEN B.BZXAJGCFL = '经济适用住房开发贷款' THEN
        'B03'
       WHEN B.BZXAJGCFL = '限价商品住房开发贷款' THEN
        'B04'
       WHEN B.BZXAJGCFL IN ('棚户区改造贷款-城市棚户区改造',
                            '棚户区改造贷款-国有工矿棚户区改造',
                            '棚户区改造贷款-国有林区棚户区改造',
                            '棚户区改造贷款-国有林场危旧房改造',
                            '棚户区改造贷款-国有垦区危房改造',
                            '棚户区改造贷款-中央下放地方煤矿棚户区改造',
                            '棚户区改造贷款-旧住宅小区整治',
                            '棚户区改造贷款-城中村改造',
                            '棚户区改造贷款-棚户区土地收购',
                            '棚户区改造贷款-棚户区拆迁及安置房建设') THEN
        'B05'
       WHEN B.BZXAJGCFL IN ('农村危房改造贷款-整栋危房（D级）',
                            '农村危房改造贷款-局部危险（C级）') THEN
        'B06'
       WHEN B.BZXAJGCFL = '游牧民定居工程贷款' THEN
        'B07'

     END AS LINCOMEHOUSE_TYPE, -- 16 保障性安居工程贷款类型

     --[2025-03-27] [周立鹏] [JLBA202502130004_制度升级2025][李楠] 停报
     /*CASE
       WHEN T1.GREE_LOAN IS NULL THEN
        '0'
       ELSE
        '1'
     END AS GREEN_FLG, -- 17 是否绿色贷款

     CASE
       WHEN T2.UNDERTAK_GUAR_TYPE IS NULL THEN
        '0'
       ELSE
        '1'
     END AS VENTURE_FLG, -- 18 是否创业担保贷款

     CASE
       WHEN T2.UNDERTAK_GUAR_TYPE IN ('A', 'B') THEN
        'C01'
       WHEN T2.UNDERTAK_GUAR_TYPE = 'Z' THEN
        'C02'
     END AS VENTURE_TYPE, -- 19 创业担保贷款类型*/
     NULL AS GREEN_FLG, -- 17 是否绿色贷款
     NULL AS VENTURE_FLG, -- 18 是否创业担保贷款
     NULL AS VENTURE_TYPE, -- 19 创业担保贷款类型

     SYS_GUID() AS REPORT_ID, -- 20 报送ID

     IS_DATE AS CJRQ, -- 21 采集日期

     T.ORG_NUM AS NBJGH, -- 22 内部机构号

     '' AS BIZ_LINE_ID,--业务条线
     '' AS VERIFY_STATUS, -- 24 校验状态

     '' AS BSCJRQ, -- 25 报送周期

     T.ORG_NUM AS ORG_NUM, -- 26 内部机构号

     --'000000' AS FRNBJGH, -- 27 法人内部机构号
    /* CASE WHEN T.ORG_NUM LIKE '5100%' THEN '510000' ELSE '990000' END FRNBJGH,*/
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
             END FRNBJGH,

     T.CURR_CD AS CURR_CODE, -- 28 币种

     T.LOAN_ACCT_BAL AS BALANCE, -- 29 余额

     C1.CUST_NAM AS CUST_NAME, -- 30 客户名称

     T.CUST_ID AS CUST_ID, -- 31 客户号

     T.LOAN_ACCT_BAL * R.CCY_RATE AS BALANCE_RMB, -- 32 余额折人民币
     --20240926_ZHOULP_JLBA202406280007_停报高新技术制造业贷款
     /*--add by dw(20240124) 2024制度升级新增字段，口径同1104
     CASE WHEN T.LOAN_PURPOSE_CD IN ('C2710','C2720','C2730','C2740','C2750','C2761','C2762','C2770','C2780') THEN 'HTP01' --医药制造业
                 WHEN T.LOAN_PURPOSE_CD IN ('C3741','C3742','C3743','C3744','C3749','C4343') THEN 'HTP02' --航空、航天器及设备制造业
                 WHEN T.LOAN_PURPOSE_CD IN ('C3562','C3563','C3569','C3832','C3833','C3841','C3921','C3922','C3940','C3931','C3932','C3933','C3934','C3939','C3951','C3952','C3953','C3971','C3972','C3973','C3974','C3975','C3976','C3979','C3981','C3982','C3983','C3984','C3985','C3989','C3961','C3962','C3963','C3969','C3990') THEN 'HTP03' --电子及通信设备制造业
                 WHEN T.LOAN_PURPOSE_CD IN ('C3911','C3912','C3913','C3914','C3915','C3919','C3474','C3475') THEN 'HTP04' --计算机及办公设备制造业
                 WHEN T.LOAN_PURPOSE_CD IN ('C3581','C3582','C3583','C3584','C3585','C3586','C3589','C4011','C4012','C4013','C4014','C4015','C4016','C4019','C4021','C4022','C4023','C4024','C4025','C4026','C4027','C4028','C4029','C4040','C4090') THEN 'HTP05' --医疗仪器设备及仪器仪表制造业
                 WHEN T.LOAN_PURPOSE_CD IN ('C2664','C2665') THEN 'HTP06' --信息化学品制造业
     END HIGH_TECH_TYPE, --33 高技术制造业类型
     CASE WHEN T.LOAN_PURPOSE_CD IN (
       'C2710','C2720','C2730','C2740','C2750','C2761','C2762','C2770','C2780', --医药制造业
       'C3741','C3742','C3743','C3744','C3749','C4343',--航空、航天器及设备制造业
       'C3562','C3563','C3569','C3832','C3833','C3841','C3921','C3922','C3940','C3931','C3932','C3933','C3934','C3939','C3951','C3952','C3953','C3971','C3972','C3973','C3974','C3975','C3976','C3979','C3981','C3982','C3983','C3984','C3985','C3989','C3961','C3962','C3963','C3969','C3990',--电子及通信设备制造业
       'C3911','C3912','C3913','C3914','C3915','C3919','C3474','C3475',--计算机及办公设备制造业
       'C3581','C3582','C3583','C3584','C3585','C3586','C3589','C4011','C4012','C4013','C4014','C4015','C4016','C4019','C4021','C4022','C4023','C4024','C4025','C4026','C4027','C4028','C4029','C4040','C4090',--医疗仪器设备及仪器仪表制造业
       'C2664','C2665'--信息化学品制造业
       ) THEN '1' ELSE '0'
     END HIGH_TECH_FLG --34 是否高技术制造业*/
     '' HIGH_TECH_TYPE, --33 高技术制造业类型
     '' HIGH_TECH_FLG --34 是否高技术制造业
      FROM SMTMODS.L_ACCT_LOAN T -- 贷款借据信息表
      LEFT JOIN L_CUST_P_TMP01 P --对私客户补充信息表
        ON T.CUST_ID = P.CUST_ID
      LEFT JOIN l_acct_loan_farming_tmp01 F --涉农贷款补充信息
        ON T.LOAN_NUM = F.LOAN_NUM
       AND T.DATA_DATE = F.DATA_DATE
      LEFT JOIN SMTMODS.L_AGRE_LOAN_CONTRACT C --贷款合同信息表
        ON T.ACCT_NUM = C.CONTRACT_NUM
       AND T.DATA_DATE = C.DATA_DATE
      LEFT JOIN SMTMODS.L_CUST_P P1 --对私客户补充信息表
        ON T.CUST_ID = P1.CUST_ID
       AND T.DATA_DATE = P1.DATA_DATE
      LEFT JOIN SMTMODS.L_CUST_C C1 --对公客户补充信息表
        ON T.CUST_ID = C1.CUST_ID
       AND T.DATA_DATE = C1.DATA_DATE
      LEFT JOIN JZFPDK J --精准扶贫贷款--GEREN
        ON T.LOAN_NUM = J.LOAN_NUM
       AND T.DATA_DATE = J.DATA_DATE
      LEFT JOIN SMTMODS.L_ACCT_POVERTY_RELIF J1 --精准扶贫贷款 --DUIGONG
        ON T.LOAN_NUM = J1.LOAN_NUM
       AND T.DATA_DATE = J1.DATA_DATE
      LEFT JOIN DFZFRZPT D --地方政府融资平台
        ON T.LOAN_NUM = D.LOAN_NUM
       AND T.DATA_DATE = D.DATA_DATE
      LEFT JOIN BZXAJGCDK B --保障性安居工程贷款
        ON T.LOAN_NUM = B.LOAN_NUM
       AND T.DATA_DATE = B.DATA_DATE
      --[2025-03-27] [周立鹏] [JLBA202502130004_制度升级2025][李楠] 停报
      /*LEFT JOIN L_AGRE_LOAN_CONTRACT_GREE_TMP01 T1 --绿色贷款
        ON T.ACCT_NUM = T1.CONTRACT_NUM
      LEFT JOIN L_ACCT_LOAN_CYDB_TMP01 T2 --创业担保贷款
        ON T.LOAN_NUM = T2.LOAN_NUM*/
      LEFT JOIN SMTMODS.L_PUBL_RATE R
        ON R.DATA_DATE = IS_DATE
       AND R.BASIC_CCY = T.CURR_CD --基准币种
       AND R.FORWARD_CCY = 'CNY' --折算类型
 --      AND R.DATA_DATE = IS_DATE
     INNER JOIN L_ACCT_LOAN_PJRZ_TMP01 PJ --票据
        ON T.LOAN_NUM = PJ.LOAN_NUM
     WHERE T.DATA_DATE = IS_DATE;
       --AND T.ORG_NUM NOT LIKE '0215%';
  COMMIT;

  ------------------------------吉林银行目标表数据---------------------------------------


 SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_201_CLZXDK', OI_RETCODE);
 EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_201_CLZXDK TRUNCATE PARTITION P' ||
                    IS_DATE;
  INSERT /*+ APPEND*/
  INTO PBOCD_JS_201_CLZXDK/*@PBOCD_34*/ NOLOGGING
    (DATA_DATE, -- 1 数据日期
     ORG_CODE, -- 2 金融机构代码
     LOAN_NUM, -- 3 贷款借据编码
     CONTRACT_CODE, -- 4 贷款合同编码
     INDIVBUSI_FLG, -- 5 是否个体工商户贷款
     SMBUSI_FLG, -- 6 是否小微企业主贷款
     AGRI_FLG, -- 7 是否涉农贷款
     AGRI_TYPE, -- 8 涉农贷款类型
     POORLOAN_FLG, -- 9 是否精准扶贫贷款
     POORPER_FLG, -- 10 是否建档立卡贫困人口贷款
     LGOVFIN_FLG, -- 11 是否地方政府融资平台贷款
     LGOV_TYPE, -- 12 地方融资平台按法律性质分类类型
     LGOV_LEVEL, -- 13 地方融资平台按隶属关系分类类型
     LGOVCAPITAL_TYPE, -- 14 地方融资平台偿债资金来源分类
     LINCOMEHOUSE_FLG, -- 15 是否保障性安居工程贷款
     LINCOMEHOUSE_TYPE, -- 16 保障性安居工程贷款类型
     GREEN_FLG, -- 17 是否绿色贷款
     VENTURE_FLG, -- 18 是否创业担保贷款
     VENTURE_TYPE, -- 19 创业担保贷款类型
     REPORT_ID, -- 20 报送ID
     CJRQ, -- 21 采集日期
     NBJGH, -- 22 内部机构号
     BIZ_LINE_ID, -- 23 业务条线
     VERIFY_STATUS, -- 24 校验状态
     BSCJRQ, -- 25 报送周期
     ORG_NUM, -- 26 内部机构号
     FRNBJGH, -- 27 法人内部机构号
     CURR_CODE, -- 28 币种
     BALANCE, -- 29 余额
     CUST_NAME, -- 30 客户名称
     CUST_ID, -- 31 客户号
     BALANCE_RMB -- 32 余额折人民币
     )

    SELECT /*+ parallel(4)*/

     VS_TEXT AS DATA_DATE, -- 1 数据日期

     --OFF.JRJGBM, --金融机构代码--T.ORG_CODE AS ORG_CODE, -- 2 金融机构代码
     NVL(OB.ID_NO,OB.UP_ID_NO), --金融机构代码
     T.LOAN_NUM AS LOAN_NUM, -- 3 贷款借据编码

     T.CONTRACT_CODE AS CONTRACT_CODE, -- 4 贷款合同编码

     T.INDIVBUSI_FLG AS INDIVBUSI_FLG, -- 5 是否个体工商户贷款

     T.SMBUSI_FLG AS SMBUSI_FLG, -- 6 是否小微企业主贷款

     T.AGRI_FLG AS AGRI_FLG, -- 7 是否涉农贷款

     T.AGRI_TYPE AS AGRI_TYPE, -- 8 涉农贷款类型

     T.POORLOAN_FLG AS POORLOAN_FLG, -- 9 是否精准扶贫贷款

     T.POORPER_FLG AS POORPER_FLG, -- 10 是否建档立卡贫困人口贷款

     T.LGOVFIN_FLG AS LGOVFIN_FLG, -- 11 是否地方政府融资平台贷款

     T.LGOV_TYPE AS LGOV_TYPE, -- 12 地方融资平台按法律性质分类类型

     T.LGOV_LEVEL AS LGOV_LEVEL, -- 13 地方融资平台按隶属关系分类类型

     T.LGOVCAPITAL_TYPE AS LGOVCAPITAL_TYPE, -- 14 地方融资平台偿债资金来源分类

     T.LINCOMEHOUSE_FLG AS LINCOMEHOUSE_FLG, -- 15 是否保障性安居工程贷款

     T.LINCOMEHOUSE_TYPE AS LINCOMEHOUSE_TYPE, -- 16 保障性安居工程贷款类型

     T.GREEN_FLG AS GREEN_FLG, -- 17 是否绿色贷款

     T.VENTURE_FLG AS VENTURE_FLG, -- 18 是否创业担保贷款

     T.VENTURE_TYPE AS VENTURE_TYPE, -- 19 创业担保贷款类型

     T.REPORT_ID AS REPORT_ID, -- 20 报送ID

     T.CJRQ AS CJRQ, -- 21 采集日期

     T.NBJGH AS NBJGH, -- 22 内部机构号

     '99' AS BIZ_LINE_ID, -- 23 业务条线

     T.VERIFY_STATUS AS VERIFY_STATUS, -- 24 校验状态

     T.BSCJRQ AS BSCJRQ, -- 25 报送周期

     T.ORG_NUM AS ORG_NUM, -- 26 内部机构号

     T.FRNBJGH AS FRNBJGH, -- 27 法人内部机构号

     T.CURR_CODE AS CURR_CODE, -- 28 币种

     T.BALANCE AS BALANCE, -- 29 余额

     T.CUST_NAME AS CUST_NAME, -- 30 客户名称

     T.CUST_ID AS CUST_ID, -- 31 客户号

     T.BALANCE_RMB AS BALANCE_RMB -- 32 余额折人民币

      FROM JS_201_CLZXDK T
      /*LEFT JOIN SYS_OFFICE OFF
      ON OFF.ID =t.NBJGH*/
      LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=t.NBJGH AND OB.DATA_DATE=IS_DATE
     WHERE TRIM(T.DATA_DATE) = IS_DATE;

     COMMIT;


     --ADD BY DW(20240124) end 2024制度升级内容
     SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_201_CLZXYP', OI_RETCODE);
     EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_201_CLZXYP TRUNCATE PARTITION P' || IS_DATE;
     INSERT /*+ APPEND*/
     INTO PBOCD_JS_201_CLZXYP NOLOGGING
    (DATA_DATE, -- 1 数据日期
     ORG_CODE, -- 2 金融机构代码
     LOAN_NUM, -- 3 贷款借据编码
     CONTRACT_CODE, -- 4 贷款合同编码
     INDIVBUSI_FLG, -- 5 是否个体工商户贷款
     SMBUSI_FLG, -- 6 是否小微企业主贷款
     REPORT_ID, -- 7 报送ID
     CJRQ, -- 8 采集日期
     NBJGH, -- 9 内部机构号
     BIZ_LINE_ID, -- 10 业务条线
     VERIFY_STATUS, -- 11 校验状态
     BSCJRQ, -- 12 报送周期
     ORG_NUM, -- 13 内部机构号
     FRNBJGH, -- 14 法人内部机构号
     CUST_ID, -- 15 客户号
     CUST_NAME, -- 16 客户名称
     BALANCE, -- 17 余额
     BALANCE_RMB, -- 18 余额折人民币
     CURR_CODE --19 币种
     )
    SELECT /*+ parallel(4)*/
     VS_TEXT AS DATA_DATE, -- 1 数据日期
     NVL(OB.ID_NO, OB.UP_ID_NO), --金融机构代码
     T.LOAN_NUM AS LOAN_NUM, -- 3 贷款借据编码
     T.CONTRACT_CODE AS CONTRACT_CODE, -- 4 贷款合同编码
     T.INDIVBUSI_FLG AS INDIVBUSI_FLG, -- 5 是否个体工商户贷款
     T.SMBUSI_FLG AS SMBUSI_FLG, -- 6 是否小微企业主贷款
     T.REPORT_ID AS REPORT_ID, -- 7 报送ID
     T.CJRQ AS CJRQ, -- 8 采集日期
     T.NBJGH AS NBJGH, -- 9 内部机构号
     '99' AS BIZ_LINE_ID, -- 10 业务条线
     T.VERIFY_STATUS AS VERIFY_STATUS, -- 11 校验状态
     T.BSCJRQ AS BSCJRQ, -- 12 报送周期
     T.ORG_NUM AS ORG_NUM, -- 13 内部机构号
     T.FRNBJGH AS FRNBJGH, -- 14 法人内部机构号
     T.CUST_ID AS CUST_ID, -- 15 客户号
     T.CUST_NAME AS CUST_NAME, -- 16 客户名称
     T.BALANCE AS BALANCE, -- 17 余额
     T.BALANCE_RMB AS BALANCE_RMB, -- 18 余额折人民币
     T.CURR_CODE --19 币种
      FROM JS_201_CLZXDK T
      LEFT JOIN L_PUBL_ORG_BRA_TMP OB --金数机构表
        ON OB.ORG_NUM = t.NBJGH
       AND OB.DATA_DATE = IS_DATE
     WHERE TRIM(T.DATA_DATE) = IS_DATE;

     COMMIT;


     SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_201_CLZXEP', OI_RETCODE);
 EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_201_CLZXEP TRUNCATE PARTITION P' || IS_DATE;
  INSERT /*+ APPEND*/
  INTO PBOCD_JS_201_CLZXEP NOLOGGING
    (DATA_DATE, -- 1 数据日期
     ORG_CODE, -- 2 金融机构代码
     LOAN_NUM, -- 3 贷款借据编码
     CONTRACT_CODE, -- 4 贷款合同编码
     AGRI_FLG, -- 5 是否涉农贷款
     POORLOAN_FLG, -- 6 是否精准扶贫贷款
     POORPER_FLG, -- 7 是否建档立卡贫困人口贷款
     LINCOMEHOUSE_FLG, -- 8 是否保障性安居工程贷款
     LINCOMEHOUSE_TYPE, -- 9 保障性安居工程贷款类型
     GREEN_FLG, -- 10 是否绿色贷款
     VENTURE_FLG, -- 11 是否创业担保贷款
     VENTURE_TYPE, -- 12 创业担保贷款类型
     REPORT_ID, -- 13 报送ID
     CJRQ, -- 14 采集日期
     NBJGH, -- 15 内部机构号
     BIZ_LINE_ID, -- 16 业务条线
     VERIFY_STATUS, -- 17 校验状态
     BSCJRQ, -- 18 报送周期
     ORG_NUM, -- 19 内部机构号
     FRNBJGH, -- 20 法人内部机构号
     HIGH_TECH_TYPE, --21高技术制造业贷款类型
     HIGH_TECH_FLG,--22是否高技术制造业贷款
     CUST_ID, -- 23 客户号
     CUST_NAME, -- 24 客户名称
     BALANCE, -- 25 余额
     BALANCE_RMB, -- 26 余额折人民币
     CURR_CODE --27币种
     )
    SELECT /*+ parallel(4)*/
     VS_TEXT AS DATA_DATE, -- 1 数据日期
     NVL(OB.ID_NO,OB.UP_ID_NO), --2金融机构代码
     T.LOAN_NUM AS LOAN_NUM, -- 3 贷款借据编码
     T.CONTRACT_CODE AS CONTRACT_CODE, -- 4 贷款合同编码
     T.AGRI_FLG AS AGRI_FLG, -- 5 是否涉农贷款
     T.POORLOAN_FLG AS POORLOAN_FLG, -- 6 是否精准扶贫贷款
     T.POORPER_FLG AS POORPER_FLG, -- 7 是否建档立卡贫困人口贷款
     T.LINCOMEHOUSE_FLG AS LINCOMEHOUSE_FLG, -- 8 是否保障性安居工程贷款
     T.LINCOMEHOUSE_TYPE AS LINCOMEHOUSE_TYPE, -- 9 保障性安居工程贷款类型
     T.GREEN_FLG AS GREEN_FLG, -- 10 是否绿色贷款
     T.VENTURE_FLG AS VENTURE_FLG, -- 11 是否创业担保贷款
     T.VENTURE_TYPE AS VENTURE_TYPE, -- 12 创业担保贷款类型
     T.REPORT_ID AS REPORT_ID, -- 13 报送ID
     T.CJRQ AS CJRQ, -- 14 采集日期
     T.NBJGH AS NBJGH, -- 15 内部机构号
     '99' AS BIZ_LINE_ID, -- 16 业务条线
     T.VERIFY_STATUS AS VERIFY_STATUS, -- 17 校验状态
     T.BSCJRQ AS BSCJRQ, -- 18 报送周期
     T.ORG_NUM AS ORG_NUM, -- 19 内部机构号
     T.FRNBJGH AS FRNBJGH, -- 20 法人内部机构号
     HIGH_TECH_TYPE, --21高技术制造业贷款类型
     HIGH_TECH_FLG,--22是否高技术制造业贷款
     T.CUST_ID AS CUST_ID, -- 23 客户号
     T.CUST_NAME AS CUST_NAME, -- 24 客户名称
     T.BALANCE AS BALANCE, -- 25 余额
     T.BALANCE_RMB AS BALANCE_RMB, -- 26 余额折人民币
     T.CURR_CODE --27币种
      FROM JS_201_CLZXDK T
      LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=t.NBJGH AND OB.DATA_DATE=IS_DATE
     WHERE TRIM(T.DATA_DATE) = IS_DATE;
     --ADD BY DW(20240124) end 2024制度升级内容

--[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
   /*UPDATE PBOCD_JS_201_CLZXDK a
   SET AGRI_TYPE = 'N02'
   where CJRQ = IS_DATE
   and LOAN_NUM = 'RN20220823100073';
   COMMIT;*/
  --------------------------------------------------------------------------------------
  OI_RETCODE := 0; --设置异常状态为0 成功状态
  OI_RETCODE_DEC :='执行成功';
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
