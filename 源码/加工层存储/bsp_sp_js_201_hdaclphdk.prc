CREATE OR REPLACE PROCEDURE BSP_SP_JS_201_HDACLPHDK(IS_DATE        IN VARCHAR2,
                                                    OI_RETCODE     OUT INTEGER,
                                                    OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_201_HDACLPHDK
  -- 用途:生成接口表 PBOCD_JS_201_HDACLPHDK  存量普惠贷款信息  --逻辑拷贝自大集中A3302
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    需求编号：JLBA202502130004_制度升级2025 上线日期：2025-03-27，修改人：周立鹏，提出人：李楠   修改原因：新建
  --    需求编号：无需求 上线日期：2025-05-08，修改人：周立鹏，提出人：李楠   修改原因：与3302同步 剔除消费类授信
  --    需求编号：无需求 上线日期：2025-05-12，修改人：周立鹏，提出人：李楠   修改原因：是否建档立卡消费贷款，逻辑要卡消费(个人贷款中LIKE 'F021%')
  --    需求编号：JLBA202505120009_关于修改金数系统与大集中系统单一客户授信逻辑的需求 上线日期：2025-05-27，修改人：周立鹏，提出人：李楠   修改原因：金数和大集中统一授信额度
  --    需求编号：JLBA202504160004_关于吉林银行修改单一客户授信逻辑的需求(从需求) 上线日期：2025-07-08，修改人：周立鹏，提出人：   修改原因：统一授信额度
  --    需求编号：无需求 上线日期：2026-02-04，修改人：周立鹏，提出人：李楠   修改原因：精确取数范围，过滤掉扶贫贷款数据
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  --VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
BEGIN
  VS_TEXT := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');

  -- 记录日志使用
  --SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'BSP_SP_JS_201_HDACLPHDK';

  --开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  VS_STEP := 0;
  -------------------------------------------------------------------------
  --新建/清理分区
  SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_201_HDACLPHDK', OI_RETCODE);

  EXECUTE IMMEDIATE 'TRUNCATE TABLE PBOCD_DATACORE.A_REPT_ITEM_VAL_A3302_TMP3'; --个体工商户和小微企业主客户中间表
  EXECUTE IMMEDIATE 'TRUNCATE TABLE PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_TMP1'; --各项贷款标识临时表
  -------------------------------------------------------------------------

EXECUTE IMMEDIATE 'TRUNCATE TABLE PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_LOAN';

INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_LOAN
  (data_date,
   acct_num,
   loan_num,
   book_type,
   acct_typ,
   cust_id,
   curr_cd,
   acct_sts,
   org_num,
   drawdown_dt,
   FINISH_DT,
   drawdown_amt,
   fund_use_loc_cd,
   loan_purpose_cd,
   loan_acct_bal,
   INT_ADJEST_AMT,
   item_cd,
   discount_interest,
   loan_stocken_date,
   cancel_flg,
   real_int_rat,
   draft_rng,
   indust_stg_type,
   high_tech_mnft,
   high_tech_srve,
   pant_dens_indu,
   UNDERTAK_GUAR_TYPE,
   FLAG)
  SELECT /*+PARALLEL(4)*/
   T1.data_date,
   T1.acct_num,
   T1.loan_num,
   T1.book_type,
   T1.acct_typ,
   T1.cust_id,
   T1.curr_cd,
   T.acct_sts,
   T.org_num,
   T.drawdown_dt,
   T.FINISH_DT,
   T1.drawdown_amt,
   T1.fund_use_loc_cd,
   T1.loan_purpose_cd,
   T.loan_acct_bal,
   T.INT_ADJEST_AMT,
   T1.item_cd,
   T1.discount_interest,
   T.loan_stocken_date,
   T.cancel_flg,
   T1.real_int_rat,
   T1.draft_rng,
   T1.indust_stg_type,
   T1.high_tech_mnft,
   T1.high_tech_srve,
   T1.pant_dens_indu,
   T1.UNDERTAK_GUAR_TYPE,
   '直转'
    FROM SMTMODS.L_ACCT_LOAN T --贷款借据信息表
   INNER JOIN SMTMODS.L_ACCT_LOAN T1 --判断直转票据
      ON T1.DATA_DATE = IS_DATE
     AND T.ACCT_NUM || T.DRAFT_RNG = T1.ACCT_NUM || T1.DRAFT_RNG
     AND SUBSTR(T1.ITEM_CD, 1, 6) IN ('130101', '130104')
     AND SUBSTR(T.ITEM_CD, 1, 6) IN ('130102', '130105')
   WHERE T.DATA_DATE = IS_DATE
     AND T.LOAN_ACCT_BAL > 0
     AND T.ACCT_STS <> '3'
     AND T.CANCEL_FLG <> 'Y'
     AND T.LOAN_STOCKEN_DATE IS NULL
  
  UNION ALL
  SELECT T.data_date,
         T.acct_num,
         T.loan_num,
         T.book_type,
         T.acct_typ,
         T.cust_id,
         T.curr_cd,
         T.acct_sts,
         T.org_num,
         T.drawdown_dt,
         T.FINISH_DT,
         T.drawdown_amt,
         T.fund_use_loc_cd,
         T.loan_purpose_cd,
         T.loan_acct_bal,
         T.INT_ADJEST_AMT,
         T.item_cd,
         T.discount_interest,
         T.loan_stocken_date,
         T.cancel_flg,
         T.real_int_rat,
         T.draft_rng,
         T.indust_stg_type,
         T.high_tech_mnft,
         T.high_tech_srve,
         T.pant_dens_indu,
         T.UNDERTAK_GUAR_TYPE,
         '非直转'
    FROM SMTMODS.L_ACCT_LOAN T
   WHERE DATA_DATE = IS_DATE
     AND T.LOAN_ACCT_BAL > 0
     AND T.ACCT_STS <> '3'
     AND T.CANCEL_FLG <> 'Y'
     AND T.LOAN_STOCKEN_DATE IS NULL
     AND NOT EXISTS
   (SELECT 1
            FROM (SELECT T.ACCT_NUM, T.DRAFT_RNG
                    FROM SMTMODS.L_ACCT_LOAN T --贷款借据信息表
                   INNER JOIN SMTMODS.L_ACCT_LOAN T1 --判断直转票据
                      ON T1.DATA_DATE = IS_DATE
                     AND T.ACCT_NUM || T.DRAFT_RNG =
                         T1.ACCT_NUM || T1.DRAFT_RNG
                     AND SUBSTR(T1.ITEM_CD, 1, 6) IN ('130101', '130104')
                     AND SUBSTR(T.ITEM_CD, 1, 6) IN ('130102', '130105')
                   WHERE T.DATA_DATE = IS_DATE) A
           WHERE T.ACCT_NUM || T.DRAFT_RNG = A.ACCT_NUM || A.DRAFT_RNG);
   COMMIT;

  -----------------------------个体工商户和小微企业主----参照大集中A3302--------------------
  VS_STEP := VS_STEP + 1;
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

  INSERT /*+append*/
  INTO A_REPT_ITEM_VAL_A3302_TMP3 NOLOGGING
    (CUST_ID, OPERATE_CUST_TYPE)
  --个人名个体工商户和小微企业主
    SELECT T.CUST_ID, T.OPERATE_CUST_TYPE
      FROM SMTMODS.L_CUST_P T --对私客户补充信息表
     WHERE T.DATA_DATE = IS_DATE
       AND T.OPERATE_CUST_TYPE IN ('A', 'B') --A-个体工商户 B-小微企业主
    UNION ALL
    --对公名个体工商户
    SELECT Y.CUST_ID, 'A' AS OPERATE_CUST_TYPE
      FROM SMTMODS.L_CUST_C Y --对公客户补充信息表
     WHERE Y.DATA_DATE = IS_DATE
       AND Y.CUST_TYP = '3' --3-个体工商户
    ;
  COMMIT;

  -------------------------插入各项贷款标识到临时表  开始----------------------------------------------------------------------------------------
  --单户授信小于1000万元的小微型企业贷款  参照大集中，将A3302的贷款和票据加工逻辑进行合并
  INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_TMP1
    (ACCT_NUM, LOAN_NUM, FLAG)
    SELECT /*+ parallel(4)*/
     A.ACCT_NUM, A.LOAN_NUM, '1XW' AS FLAG
      FROM PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_LOAN A
     INNER JOIN SMTMODS.L_CUST_C B
        ON A.CUST_ID = B.CUST_ID
       AND B.DATA_DATE = IS_DATE
       AND (SUBSTR(B.CUST_TYP, 1, 1) IN ('0', '1') OR B.CUST_TYP = '9101') --0-农民专业合作社 1-企业 --MODIFY BY DW(20220128 )应辉哥要求，农民专业合作社也属于企业
       AND B.CUST_TYP <> '14' --MODIFY BY ZY(20230220 )应董伟姐要求，客户分类14 的去掉
       AND B.CORP_SCALE IN ('S', 'T')

     INNER JOIN SMTMODS.AGRE_CREDITLINE_INFO C
        ON C.DATA_DATE = IS_DATE
       AND A.CUST_ID = C.CUST_ID
       AND C.FACILITY_AMT <= 10000000
       
     WHERE A.DATA_DATE = IS_DATE
       AND A.LOAN_ACCT_BAL > 0
       AND A.ACCT_TYP NOT IN
           ( /*'030101', '030102', */ 'B01', 'C01', 'D01', '90') --去除委托贷款  大集中的贷款和票据是分开写的，所以这里去掉'030101', '030102'，金数合在一起
          --ADD BY DW(20220719)
       AND A.CANCEL_FLG = 'N'
          --modify by shiyu 20240223 剔除福费廷二级市场数据
       AND A.LOAN_NUM NOT IN (SELECT TT.Loan_Num
                                FROM SMTMODS.L_ACCT_TRAD_FIN TT
                               WHERE TT.DATA_DATE = IS_DATE
                                 AND TT.TRAD_FIN_TYPE IN ('12', '13') --12-福费庭/13-福费廷(离岸)
                                 AND TT.FORF_TYPE IN ('2') --2-转卖
                              )
       AND A.LOAN_STOCKEN_DATE IS NULL; --add by haorui 20250228 JLBA202408200012 资产未转让
  COMMIT;

  --单户授信小于1000万元的个体工商户经营性贷款  参照大集中A3302
  --单户授信小于1000万元的小微企业主经营性贷款  参照大集中A3302
  INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_TMP1
    (ACCT_NUM, LOAN_NUM, FLAG)
    SELECT /*+ USE_HASH(A,B,C) parallel(4)*/
     A.ACCT_NUM,
     A.LOAN_NUM,
     CASE
       WHEN B.OPERATE_CUST_TYPE = 'A' THEN
        '2GTJY' -- 个体工商户
       WHEN B.OPERATE_CUST_TYPE = 'B' THEN
        '3XWJY' -- 小微企业主
     END AS FLAG
      FROM PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_LOAN A
     INNER JOIN A_REPT_ITEM_VAL_A3302_TMP3 B
        ON A.CUST_ID = B.CUST_ID

     INNER JOIN SMTMODS.AGRE_CREDITLINE_INFO C
        ON C.DATA_DATE = IS_DATE
       AND A.CUST_ID = C.CUST_ID
       AND C.FACILITY_AMT <= 10000000  
       
     WHERE A.DATA_DATE = IS_DATE
       AND A.ACCT_TYP IN ('0102', '010201', '010299')
       AND A.LOAN_ACCT_BAL > 0
       AND A.CANCEL_FLG = 'N'
          --modify by shiyu 20240223 剔除福费廷二级市场数据
       AND A.LOAN_NUM NOT IN (SELECT TT.Loan_Num
                                FROM SMTMODS.L_ACCT_TRAD_FIN TT
                               WHERE TT.DATA_DATE = IS_DATE
                                 AND TT.TRAD_FIN_TYPE IN ('12', '13') --12-福费庭/13-福费廷(离岸)
                                 AND TT.FORF_TYPE IN ('2') --2-转卖
                              )
       AND A.LOAN_STOCKEN_DATE IS NULL; --add by haorui 20250228 JLBA202408200012 资产未转让
  COMMIT;

  --单户授信小于500万元的农户经营性贷款  参照大集中1433_12P1I
  INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_TMP1
    (ACCT_NUM, LOAN_NUM, FLAG)
    SELECT /*+ parallel(4)*/
     A.ACCT_NUM, A.LOAN_NUM, '4NHJY' AS FLAG
     FROM (
        SELECT * FROM SMTMODS.V_PUB_IDX_DK_GRSNDK  T --个人涉农贷款
             WHERE T.DATA_DATE = IS_DATE
             AND SUBSTR(T.SNDKFL, 1, 5) IN ('P_101', 'P_103')
             UNION ALL
             SELECT * FROM SMTMODS.V_PUB_IDX_DK_GTGSHSNDK T --个体工商户涉农贷款
             WHERE T.DATA_DATE = IS_DATE
             AND SUBSTR(T.SNDKFL, 1, 5) IN ('P_101', 'P_103')
        ) A
       INNER JOIN PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_LOAN B --贷款借据信息表
          ON A.LOAN_NUM = B.LOAN_NUM
         AND B.DATA_DATE = IS_DATE

       INNER JOIN SMTMODS.AGRE_CREDITLINE_INFO C
        ON C.DATA_DATE = IS_DATE
       AND A.CUST_ID = C.CUST_ID
       AND C.FACILITY_AMT <= 5000000
       
       WHERE B.ACCT_TYP NOT LIKE '90%' --去除委托贷款
         AND B.ACCT_STS <> 3 --账户状态非注销
         AND B.CANCEL_FLG = 'N' --核销标识为否
         AND SUBSTR(A.SNDKFL, 1, 5) IN ('P_101', 'P_103')
         and b.acct_typ like '0102%'
     AND B.LOAN_STOCKEN_DATE IS NULL;    --add by haorui 20250311 JLBA202408200012 资产未转让
  COMMIT;

  -------------------------插入各项贷款标识到临时表  结束----------------------------------------------------------------------------------------

  -------------------------加工结果表  开始----------------------------------------------------------------------------------------

  -- 20260130 制度升级 单户授信小于1000万元的小微型企业贷款  
 
 INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK  
(DATA_DATE,
FIELD_TYPE,
BALANCE_SUM,
INT_RATE_WA,
GET_LOAN_NUM,
REPORT_ID,
CJRQ,
NBJGH,
BIZ_LINE_ID,
VERIFY_STATUS,
BSCJRQ,
FRNBJGH
)
 SELECT /*+PARALLEL(4)*/
     VS_TEXT AS DATA_DATE, --数据日期 
     FIELD_TYPE, --字段类别
     SUM(BALANCE_SUM), --贷款汇总金额
     SUM(INT_RATE_WA), --贷款汇总加权平均利率
     SUM(GET_LOAN_NUM), --贷款汇总获贷企业数量
     SYS_GUID() AS REPORT_ID, --ID
     IS_DATE AS CJRQ, --采集日期
     NBJGH || '0000', --内部机构号
     '99' BIZ_LINE_ID, --业务条线ID
     NULL VERIFY_STATUS, --校验状态
     IS_DATE AS BSCJRQ, --报送采集日期
     NBJGH || '0000' --法人内部机构号
 FROM ( SELECT /*+ parallel(4)*/
        'T01' AS FIELD_TYPE,
           SUM((CASE WHEN A.ACCT_TYP NOT LIKE '0301%' THEN  A.LOAN_ACCT_BAL
                                   ELSE A.DRAWDOWN_AMT - NVL(A.DISCOUNT_INTEREST, 0)
                                 END) * U.CCY_RATE) AS BALANCE_SUM, -- 贷款汇总金额
                CASE WHEN SUM(CASE WHEN A.ACCT_TYP NOT LIKE '0301%' THEN A.LOAN_ACCT_BAL
                                          ELSE A.DRAWDOWN_AMT - NVL(A.DISCOUNT_INTEREST, 0)
                                        END) = 0 THEN 0
                               ELSE ROUND(SUM((CASE WHEN A.ACCT_TYP NOT LIKE '0301%' THEN  A.LOAN_ACCT_BAL
                                            ELSE A.DRAWDOWN_AMT - NVL(A.DISCOUNT_INTEREST, 0)
                                          END) * A.REAL_INT_RAT) /
                                      SUM(CASE WHEN A.ACCT_TYP NOT LIKE '0301%' THEN A.LOAN_ACCT_BAL
                                            ELSE  A.DRAWDOWN_AMT - NVL(A.DISCOUNT_INTEREST, 0)
                                          END),  5)
                               END INT_RATE_WA, -- 贷款汇总加权平均利率
                COUNT(DISTINCT A.CUST_ID) AS GET_LOAN_NUM, -- 贷款汇总户数
                CASE WHEN SUBSTR(A.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN SUBSTR(A.ORG_NUM, 1, 2)
                     ELSE  '99'
                     END AS NBJGH --内部机构号
      FROM PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_LOAN A
     INNER JOIN SMTMODS.L_CUST_C B
        ON A.CUST_ID = B.CUST_ID
       AND B.DATA_DATE = IS_DATE
       AND (SUBSTR(B.CUST_TYP, 1, 1) IN ('0', '1') OR B.CUST_TYP = '9101') 
       AND B.CUST_TYP <> '14' 
       AND B.CORP_SCALE IN ('S', 'T')
     INNER JOIN SMTMODS.AGRE_CREDITLINE_INFO C
        ON C.DATA_DATE = IS_DATE
       AND A.CUST_ID = C.CUST_ID
       AND C.FACILITY_AMT <= 10000000
      LEFT JOIN SMTMODS.L_PUBL_RATE U --汇率表
        ON U.DATA_DATE = IS_DATE
       AND U.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD')
       AND U.BASIC_CCY = a.CURR_CD --基准币种
       AND U.FORWARD_CCY = 'CNY' --折算币种
     WHERE A.DATA_DATE = IS_DATE
       AND A.LOAN_ACCT_BAL > 0
       AND A.ACCT_TYP NOT IN ('B01', 'C01', 'D01', '90') --去除委托贷款  大集中的贷款和票据是分开写的，所以这里去掉'030101', '030102'，金数合在一起
       AND A.CANCEL_FLG = 'N'
       AND A.LOAN_NUM NOT IN (SELECT TT.Loan_Num
                                FROM SMTMODS.L_ACCT_TRAD_FIN TT
                               WHERE TT.DATA_DATE = IS_DATE
                                 AND TT.TRAD_FIN_TYPE IN ('12', '13') --12-福费庭/13-福费廷(离岸)
                                 AND TT.FORF_TYPE IN ('2')) --2-转卖
       AND A.LOAN_STOCKEN_DATE IS NULL  --add by haorui 20250228 JLBA202408200012 资产未转让
     GROUP BY  CASE WHEN SUBSTR(A.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN SUBSTR(A.ORG_NUM, 1, 2)
                    ELSE  '99'
                     END
                 UNION ALL 
            SELECT FIELD_TYPE,
                   BALANCE_SUM,
                   INT_RATE_WA,
                   GET_LOAN_NUM,
                   ORG_CODE
              FROM PBOCD_DATACORE.KJDK_TMP01
             WHERE FLAG = 'PUDK'     
               AND FIELD_TYPE='T01'
             )
              GROUP BY NBJGH, FIELD_TYPE
              ORDER BY NBJGH, FIELD_TYPE;  


 -- 20260130  制度升级 单户授信小于1000万元的小微企业主经营性贷款
 
 INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK  
(DATA_DATE,
FIELD_TYPE,
BALANCE_SUM,
INT_RATE_WA,
GET_LOAN_NUM,
REPORT_ID,
CJRQ,
NBJGH,
BIZ_LINE_ID,
VERIFY_STATUS,
BSCJRQ,
FRNBJGH
)
 SELECT /*+PARALLEL(4)*/
     VS_TEXT AS DATA_DATE, --数据日期 
     FIELD_TYPE, --字段类别
     SUM(BALANCE_SUM), --贷款汇总金额
     SUM(INT_RATE_WA), --贷款汇总加权平均利率
     SUM(GET_LOAN_NUM), --贷款汇总获贷企业数量
     SYS_GUID() AS REPORT_ID, --ID
     IS_DATE AS CJRQ, --采集日期
     NBJGH || '0000', --内部机构号
     '99' BIZ_LINE_ID, --业务条线ID
     NULL VERIFY_STATUS, --校验状态
     IS_DATE AS BSCJRQ, --报送采集日期
     NBJGH || '0000' --法人内部机构号
 FROM ( SELECT /*+ parallel(4)*/
         CASE WHEN B.OPERATE_CUST_TYPE = 'A' THEN 'T02' -- 个体工商户
              WHEN B.OPERATE_CUST_TYPE = 'B' THEN 'T03' -- 小微企业主
            END  AS FIELD_TYPE,
           SUM((CASE WHEN A.ACCT_TYP NOT LIKE '0301%' THEN  A.LOAN_ACCT_BAL
                                   ELSE A.DRAWDOWN_AMT - NVL(A.DISCOUNT_INTEREST, 0)
                                 END) * U.CCY_RATE) AS BALANCE_SUM, -- 贷款汇总金额
                CASE WHEN SUM(CASE WHEN A.ACCT_TYP NOT LIKE '0301%' THEN A.LOAN_ACCT_BAL
                                          ELSE A.DRAWDOWN_AMT - NVL(A.DISCOUNT_INTEREST, 0)
                                        END) = 0 THEN 0
                               ELSE ROUND(SUM((CASE WHEN A.ACCT_TYP NOT LIKE '0301%' THEN  A.LOAN_ACCT_BAL
                                            ELSE A.DRAWDOWN_AMT - NVL(A.DISCOUNT_INTEREST, 0)
                                          END) * A.REAL_INT_RAT) /
                                      SUM(CASE WHEN A.ACCT_TYP NOT LIKE '0301%' THEN A.LOAN_ACCT_BAL
                                            ELSE  A.DRAWDOWN_AMT - NVL(A.DISCOUNT_INTEREST, 0)
                                          END),  5)
                               END INT_RATE_WA, -- 贷款汇总加权平均利率
                COUNT(DISTINCT A.CUST_ID) AS GET_LOAN_NUM, -- 贷款汇总户数
                CASE WHEN SUBSTR(A.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN SUBSTR(A.ORG_NUM, 1, 2)
                     ELSE  '99'
                     END AS NBJGH --内部机构号 
      FROM PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_LOAN A
     INNER JOIN A_REPT_ITEM_VAL_A3302_TMP3 B
        ON A.CUST_ID = B.CUST_ID 
     INNER JOIN SMTMODS.AGRE_CREDITLINE_INFO C
        ON C.DATA_DATE = IS_DATE
       AND A.CUST_ID = C.CUST_ID
       AND C.FACILITY_AMT <= 10000000 
      LEFT JOIN SMTMODS.L_PUBL_RATE U --汇率表
        ON U.DATA_DATE = IS_DATE
       AND U.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD')
       AND U.BASIC_CCY = a.CURR_CD --基准币种
       AND U.FORWARD_CCY = 'CNY' --折算币种 
     WHERE A.DATA_DATE = IS_DATE
       AND A.ACCT_TYP IN ('0102', '010201', '010299')
       AND A.LOAN_ACCT_BAL > 0
       AND A.CANCEL_FLG = 'N' 
       AND A.LOAN_NUM NOT IN (SELECT TT.Loan_Num
                                FROM SMTMODS.L_ACCT_TRAD_FIN TT
                               WHERE TT.DATA_DATE = IS_DATE
                                 AND TT.TRAD_FIN_TYPE IN ('12', '13') --12-福费庭/13-福费廷(离岸)
                                 AND TT.FORF_TYPE IN ('2') --2-转卖
                              )
       AND A.LOAN_STOCKEN_DATE IS NULL  
     GROUP BY  
         CASE WHEN B.OPERATE_CUST_TYPE = 'A' THEN 'T02' -- 个体工商户
              WHEN B.OPERATE_CUST_TYPE = 'B' THEN 'T03' -- 小微企业主
              END,
         CASE WHEN SUBSTR(A.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN SUBSTR(A.ORG_NUM, 1, 2)
              ELSE  '99'
              END
                 UNION ALL 
            SELECT FIELD_TYPE,
                   BALANCE_SUM,
                   INT_RATE_WA,
                   GET_LOAN_NUM,
                   ORG_CODE
              FROM PBOCD_DATACORE.KJDK_TMP01
             WHERE FLAG = 'PUDK'     
               AND FIELD_TYPE IN ('T02','T03')
             )
              GROUP BY NBJGH, FIELD_TYPE
              ORDER BY NBJGH, FIELD_TYPE;            



 -- 20260130 制度升级 单户授信小于500万元的农户经营性贷款 
INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK
  (DATA_DATE,
   FIELD_TYPE,
   BALANCE_SUM,
   INT_RATE_WA,
   GET_LOAN_NUM,
   REPORT_ID,
   CJRQ,
   NBJGH,
   BIZ_LINE_ID,
   VERIFY_STATUS,
   BSCJRQ,
   FRNBJGH)
  SELECT /*+PARALLEL(4)*/
   VS_TEXT AS DATA_DATE, --数据日期 
   FIELD_TYPE, --字段类别
   SUM(BALANCE_SUM), --贷款汇总金额
   SUM(INT_RATE_WA), --贷款汇总加权平均利率
   SUM(GET_LOAN_NUM), --贷款汇总获贷企业数量
   SYS_GUID() AS REPORT_ID, --ID
   IS_DATE AS CJRQ, --采集日期
   NBJGH || '0000', --内部机构号
   '99' BIZ_LINE_ID, --业务条线ID
   NULL VERIFY_STATUS, --校验状态
   IS_DATE AS BSCJRQ, --报送采集日期
   NBJGH || '0000' --法人内部机构号
    FROM (SELECT /*+ parallel(4)*/
           'T04' AS FIELD_TYPE,
           SUM((CASE
                 WHEN B.ACCT_TYP NOT LIKE '0301%' THEN
                  B.LOAN_ACCT_BAL
                 ELSE
                  B.DRAWDOWN_AMT - NVL(B.DISCOUNT_INTEREST, 0)
               END) * U.CCY_RATE) AS BALANCE_SUM, -- 贷款汇总金额
           CASE
             WHEN SUM(CASE
                        WHEN B.ACCT_TYP NOT LIKE '0301%' THEN
                         B.LOAN_ACCT_BAL
                        ELSE
                         B.DRAWDOWN_AMT - NVL(B.DISCOUNT_INTEREST, 0)
                      END) = 0 THEN
              0
             ELSE
              ROUND(SUM((CASE
                          WHEN B.ACCT_TYP NOT LIKE '0301%' THEN
                           B.LOAN_ACCT_BAL
                          ELSE
                           B.DRAWDOWN_AMT - NVL(B.DISCOUNT_INTEREST, 0)
                        END) * B.REAL_INT_RAT) /
                    SUM(CASE
                          WHEN B.ACCT_TYP NOT LIKE '0301%' THEN
                           B.LOAN_ACCT_BAL
                          ELSE
                           B.DRAWDOWN_AMT - NVL(B.DISCOUNT_INTEREST, 0)
                        END),
                    5)
           END INT_RATE_WA, -- 贷款汇总加权平均利率
           COUNT(DISTINCT B.CUST_ID) AS GET_LOAN_NUM, -- 贷款汇总户数
           CASE
             WHEN SUBSTR(B.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
              SUBSTR(B.ORG_NUM, 1, 2)
             ELSE
              '99'
           END AS NBJGH --内部机构号     
            FROM (SELECT *
                    FROM SMTMODS.V_PUB_IDX_DK_GRSNDK T --个人涉农贷款
                   WHERE T.DATA_DATE = IS_DATE
                     AND SUBSTR(T.SNDKFL, 1, 5) IN ('P_101', 'P_103')
                  UNION ALL
                  SELECT *
                    FROM SMTMODS.V_PUB_IDX_DK_GTGSHSNDK T --个体工商户涉农贷款
                   WHERE T.DATA_DATE = IS_DATE
                     AND SUBSTR(T.SNDKFL, 1, 5) IN ('P_101', 'P_103')) A
           INNER JOIN PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_LOAN B --贷款借据信息表
              ON A.LOAN_NUM = B.LOAN_NUM
             AND B.DATA_DATE = IS_DATE
           INNER JOIN SMTMODS.AGRE_CREDITLINE_INFO C
              ON C.DATA_DATE = IS_DATE
             AND A.CUST_ID = C.CUST_ID
             AND C.FACILITY_AMT <= 5000000
            LEFT JOIN SMTMODS.L_PUBL_RATE U --汇率表
              ON U.DATA_DATE = IS_DATE
             AND U.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD')
             AND U.BASIC_CCY = B.CURR_CD --基准币种
             AND U.FORWARD_CCY = 'CNY' --折算币种 
           WHERE B.ACCT_TYP NOT LIKE '90%' --去除委托贷款
             AND B.ACCT_STS <> 3 --账户状态非注销
             AND B.CANCEL_FLG = 'N' --核销标识为否
             AND SUBSTR(A.SNDKFL, 1, 5) IN ('P_101', 'P_103')
             AND B.ACCT_TYP LIKE '0102%'
             AND B.LOAN_STOCKEN_DATE IS NULL
           GROUP BY CASE
                      WHEN SUBSTR(B.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                       SUBSTR(B.ORG_NUM, 1, 2)
                      ELSE
                       '99'
                    END
          UNION ALL
          SELECT FIELD_TYPE,
                 BALANCE_SUM,
                 INT_RATE_WA,
                 GET_LOAN_NUM,
                 ORG_CODE
            FROM PBOCD_DATACORE.KJDK_TMP01
           WHERE FLAG = 'PUDK'
             AND FIELD_TYPE = 'T04')
   GROUP BY NBJGH, FIELD_TYPE
   ORDER BY NBJGH, FIELD_TYPE;    


-- 20260130 制度升级 创业担保贷款  助学贷款  可通过L_ACCT_LOAN.ACCT_TYP='0104'判断，目前无业务

INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK
  (DATA_DATE,
   FIELD_TYPE,
   BALANCE_SUM,
   INT_RATE_WA,
   GET_LOAN_NUM,
   REPORT_ID,
   CJRQ,
   NBJGH,
   BIZ_LINE_ID,
   VERIFY_STATUS,
   BSCJRQ,
   FRNBJGH)
  SELECT /*+PARALLEL(4)*/
   VS_TEXT AS DATA_DATE, --数据日期 
   FIELD_TYPE, --字段类别
   SUM(BALANCE_SUM), --贷款汇总金额
   SUM(INT_RATE_WA), --贷款汇总加权平均利率
   SUM(GET_LOAN_NUM), --贷款汇总获贷企业数量
   SYS_GUID() AS REPORT_ID, --ID
   IS_DATE AS CJRQ, --采集日期
   NBJGH || '0000', --内部机构号
   '99' BIZ_LINE_ID, --业务条线ID
   NULL VERIFY_STATUS, --校验状态
   IS_DATE AS BSCJRQ, --报送采集日期
   NBJGH || '0000' --法人内部机构号
    FROM (SELECT /*+ parallel(4)*/
           CASE
             WHEN (A.UNDERTAK_GUAR_TYPE <> '#' AND
                  A.UNDERTAK_GUAR_TYPE IS NOT NULL) THEN
              'T05'
             WHEN A.ACCT_TYP = '0104' THEN
              'T06'
           END AS FIELD_TYPE,
           SUM((CASE
                 WHEN A.ACCT_TYP NOT LIKE '0301%' THEN
                  A.LOAN_ACCT_BAL
                 ELSE
                  A.DRAWDOWN_AMT - NVL(A.DISCOUNT_INTEREST, 0)
               END) * U.CCY_RATE) AS BALANCE_SUM, -- 贷款汇总金额
           CASE
             WHEN SUM(CASE
                        WHEN A.ACCT_TYP NOT LIKE '0301%' THEN
                         A.LOAN_ACCT_BAL
                        ELSE
                         A.DRAWDOWN_AMT - NVL(A.DISCOUNT_INTEREST, 0)
                      END) = 0 THEN
              0
             ELSE
              ROUND(SUM((CASE
                          WHEN A.ACCT_TYP NOT LIKE '0301%' THEN
                           A.LOAN_ACCT_BAL
                          ELSE
                           A.DRAWDOWN_AMT - NVL(A.DISCOUNT_INTEREST, 0)
                        END) * A.REAL_INT_RAT) /
                    SUM(CASE
                          WHEN A.ACCT_TYP NOT LIKE '0301%' THEN
                           A.LOAN_ACCT_BAL
                          ELSE
                           A.DRAWDOWN_AMT - NVL(A.DISCOUNT_INTEREST, 0)
                        END),
                    5)
           END INT_RATE_WA, -- 贷款汇总加权平均利率
           COUNT(DISTINCT A.CUST_ID) AS GET_LOAN_NUM, -- 贷款汇总户数
           CASE
             WHEN SUBSTR(A.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
              SUBSTR(A.ORG_NUM, 1, 2)
             ELSE
              '99'
           END AS NBJGH --内部机构号
          
            FROM PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_LOAN A -- 贷款借据信息表
            LEFT JOIN SMTMODS.L_PUBL_RATE U --汇率表
              ON U.DATA_DATE = IS_DATE
             AND U.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD')
             AND U.BASIC_CCY = A.CURR_CD --基准币种
             AND U.FORWARD_CCY = 'CNY' --折算币种 
           WHERE A.DATA_DATE = IS_DATE
             AND A.CANCEL_FLG = 'N' --剔除核销
             AND A.LOAN_ACCT_BAL > 0
             AND A.LOAN_STOCKEN_DATE IS NULL --ADD BY HAORUI 20250228 JLBA202408200012 资产未转让
             AND (SUBSTR(A.ITEM_CD, 1, 4) IN ('1303', '1305', '1306') --单位贷款
                 OR (A.CURR_CD = 'CNY' AND A.ACCT_TYP LIKE '01%') --个人贷款
                 OR (NVL(A.LOAN_ACCT_BAL, 0) + NVL(A.INT_ADJEST_AMT, 0) > 0 AND
                 SUBSTR(A.ITEM_CD, 1, 6) IN ('130101', '130104'))) --票据直贴
             AND ((A.UNDERTAK_GUAR_TYPE <> '#' AND
                 A.UNDERTAK_GUAR_TYPE IS NOT NULL) OR A.ACCT_TYP = '0104')
           GROUP BY CASE
                      WHEN (A.UNDERTAK_GUAR_TYPE <> '#' AND
                           A.UNDERTAK_GUAR_TYPE IS NOT NULL) THEN
                       'T05'
                      WHEN A.ACCT_TYP = '0104' THEN
                       'T06'
                    END,
                    CASE
                      WHEN SUBSTR(A.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                       SUBSTR(A.ORG_NUM, 1, 2)
                      ELSE
                       '99'
                    END
          UNION ALL
          SELECT FIELD_TYPE,
                 BALANCE_SUM,
                 INT_RATE_WA,
                 GET_LOAN_NUM,
                 ORG_CODE
            FROM PBOCD_DATACORE.KJDK_TMP01
           WHERE FLAG = 'PUDK'
             AND FIELD_TYPE IN ('T05', 'T06'))
   GROUP BY NBJGH, FIELD_TYPE
   ORDER BY NBJGH, FIELD_TYPE;
   

  INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK
    (DATA_DATE, -- 数据日期
     ORG_CODE, -- 金融机构代码
     ORG_NUM, -- 内部机构号
     CONTRACT_CODE, -- 贷款合同编码
     LOAN_NUM, -- 贷款借据编码
     BILL_NUM, -- 票据编号
     SME_LOAN_FLG, -- 是否单户授信小于1000万元的小微型企业贷款
     INDIBUS_LOAN_FLG, -- 是否单户授信小于1000万元的个体工商户经营性贷款
     SMEOWNER_LOAN_FLG, -- 是否单户授信小于1000万元的小微企业主经营性贷款
     FARMER_LOAN_FLG, -- 是否单户授信小于500万元的农户经营贷款
     VENTURE_FLG, -- 是否创业担保贷款
     STUDENT_LOAN_FLG, -- 是否助学贷款
     POVERTY_LOAN_FLG, -- 是否原建档立卡贫困人口消费贷款
     BIZ_TYPE, -- 业务类别
     REPORT_ID, -- ID
     CJRQ, -- 采集日期
     NBJGH, -- 内部机构号
     BIZ_LINE_ID, -- 业务条线ID
     VERIFY_STATUS, -- 校验状态
     BSCJRQ, -- 报送采集日期
     FRNBJGH, -- 法人内部机构号
     CUST_ID, --客户号
     CUST_NAME, --客户名
     LOAN_ACCT_BAL, --贷款余额
     CURR_CD, --币种
     LOAN_ACCT_BAL_RMB, --贷款余额折人民币
     DRAWDOWN_AMT, --放款金额
     DISCOUNT_INTEREST, --贴现利息
     FIELD_TYPE
     )
    SELECT /*+PARALLEL(4)*/
     VS_TEXT AS DATA_DATE, --数据日期
     NVL(OB.ID_NO, OB.UP_ID_NO), --金融机构代码
     T.ORG_NUM, --内部机构号
     CASE
       WHEN SUBSTR(t.ITEM_CD, 1, 6) not IN ('130101', '130104') THEN
        T.ACCT_NUM
       ELSE
        '0'
     END, --贷款合同编码
     CASE
       WHEN SUBSTR(t.ITEM_CD, 1, 6) not IN ('130101', '130104') THEN
        T.LOAN_NUM
       ELSE
        '0'
     END, --贷款借据编码
     CASE
       WHEN SUBSTR(t.ITEM_CD, 1, 6) IN ('130101', '130104') THEN
        CASE WHEN IS_DATE < '20240331' THEN T.ACCT_NUM ELSE T.ACCT_NUM || T.DRAFT_RNG END -- 20240331之前的票号没有拼子票区间，待补报历史数据结束后可剔除此判断
       ELSE
        '0'
     END, --票据编号
     CASE
       WHEN XW.LOAN_NUM IS NOT NULL THEN
        '1'
       ELSE
        '0'
     END, --单户授信小于1000万元的小微型企业贷款
     CASE
       WHEN GTJY.LOAN_NUM IS NOT NULL THEN
        '1'
       ELSE
        '0'
     END, --单户授信小于1000万元的个体工商户经营性贷款
     CASE
       WHEN XWJY.LOAN_NUM IS NOT NULL THEN
        '1'
       ELSE
        '0'
     END, --单户授信小于1000万元的小微企业主经营性贷款
     CASE
       WHEN NHJY.LOAN_NUM IS NOT NULL THEN
        '1'
       ELSE
        '0'
     END, --单户授信小于500万元的农户经营性贷款
     CASE
       WHEN CYDB.LOAN_NUM IS NOT NULL THEN
        '1'
       ELSE
        '0'
     END, --创业担保贷款  参照金数专项贷款
     '0', --助学贷款  可通过L_ACCT_LOAN.ACCT_TYP='0104'判断，目前无业务

     NULL AS POVERTY_LOAN_FLG, -- 是否原建档立卡贫困人口消费贷款 20260130 制度升级 终止报送“是否原建档立卡贫困人口消费贷款”，字段保留，报送空值
     CASE
     WHEN T.ACCT_TYP LIKE '01%' OR C1.CUST_TYP = '3' THEN
        'C02' --个人贷款
       WHEN SUBSTR(T.ITEM_CD, 1, 4) IN ('1303', '1305', '1306') AND GTJY.LOAN_NUM IS NOT NULL THEN --个体工商户
        'C02' --个人贷款
       WHEN SUBSTR(T.ITEM_CD, 1, 4) IN ('1303', '1305', '1306') AND XWJY.LOAN_NUM IS NOT NULL THEN --小微企业主
        'C02' --个人贷款
       WHEN SUBSTR(T.ITEM_CD, 1, 4) IN ('1303', '1305', '1306') AND NHJY.LOAN_NUM IS NOT NULL THEN --农户经营性贷款
        'C02' --个人贷款
       WHEN SUBSTR(T.ITEM_CD, 1, 4) IN ('1303', '1305', '1306') THEN
        'C01' --单位贷款
       WHEN SUBSTR(t.ITEM_CD, 1, 6) IN ('130101', '130104') THEN
        'C03' --票据融资
     END, --业务类别
     SYS_GUID() AS REPORT_ID, --ID
     IS_DATE AS CJRQ, --采集日期
     T.ORG_NUM AS NBJGH, --内部机构号
     '99' BIZ_LINE_ID, --业务条线ID
     NULL VERIFY_STATUS, --校验状态
     IS_DATE AS BSCJRQ, --报送采集日期
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
       ELSE
        '990000'
     END FRNBJGH, --法人内部机构号
     T.CUST_ID, --客户号
     A2.CUST_NAM, --客户名
     T.LOAN_ACCT_BAL, --贷款余额
     T.CURR_CD, -- 币种
     T.LOAN_ACCT_BAL * U.CCY_RATE, --贷款余额折人民币
     T.DRAWDOWN_AMT, --放款金额
     T.DISCOUNT_INTEREST , --贴现利息
     'T99' AS FIELD_TYPE -- 字段类别 
      FROM PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_LOAN T -- 贷款借据信息表
      LEFT JOIN PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_TMP1 XW --单户授信小于1000万元的小微型企业贷款
        ON XW.LOAN_NUM = T.LOAN_NUM
       AND XW.FLAG = '1XW'
      LEFT JOIN PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_TMP1 GTJY --单户授信小于1000万元的个体工商户经营性贷款
        ON GTJY.LOAN_NUM = T.LOAN_NUM
       AND GTJY.FLAG = '2GTJY'
      LEFT JOIN PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_TMP1 XWJY --单户授信小于1000万元的小微企业主经营性贷款
        ON XWJY.LOAN_NUM = T.LOAN_NUM
       AND XWJY.FLAG = '3XWJY'
      LEFT JOIN PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_TMP1 NHJY --单户授信小于500万元的农户经营性贷款
        ON NHJY.LOAN_NUM = T.LOAN_NUM
       AND NHJY.FLAG = '4NHJY'
      LEFT JOIN PBOCD_DATACORE.PBOCD_JS_201_HDACLPHDK_LOAN CYDB --创业担保贷款  参照金数专项贷款
        ON CYDB.LOAN_NUM = T.LOAN_NUM
       AND CYDB.UNDERTAK_GUAR_TYPE <> '#'
       AND CYDB.UNDERTAK_GUAR_TYPE IS NOT NULL
       AND CYDB.DATA_DATE = IS_DATE

      LEFT JOIN SMTMODS.L_CUST_C C1 --对公客户补充信息表
        ON T.CUST_ID = C1.CUST_ID
       AND C1.DATA_DATE = IS_DATE

      LEFT JOIN SMTMODS.L_CUST_ALL A2
        ON A2.DATA_DATE = IS_DATE
       AND A2.CUST_ID = T.CUST_ID
      LEFT JOIN L_PUBL_ORG_BRA_TMP OB --金数机构表
        ON OB.ORG_NUM = T.ORG_NUM
       AND OB.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_PUBL_RATE U --汇率表
        ON U.DATA_DATE = IS_DATE
       AND U.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD')
       AND U.BASIC_CCY = T.CURR_CD --基准币种
       AND U.FORWARD_CCY = 'CNY' --折算币种
     WHERE T.DATA_DATE = IS_DATE
       AND (XW.LOAN_NUM IS NOT NULL OR GTJY.LOAN_NUM IS NOT NULL OR
           XWJY.LOAN_NUM IS NOT NULL OR NHJY.LOAN_NUM IS NOT NULL OR
           CYDB.LOAN_NUM IS NOT NULL)
       AND T.CANCEL_FLG = 'N' --剔除核销
       AND T.LOAN_ACCT_BAL > 0
       AND T.LOAN_STOCKEN_DATE IS NULL --ADD BY HAORUI 20250228 JLBA202408200012 资产未转让
       AND (SUBSTR(T.ITEM_CD, 1, 4) IN ('1303', '1305', '1306') --单位贷款
           OR (T.CURR_CD = 'CNY' AND T.ACCT_TYP LIKE '01%') --个人贷款
           OR (NVL(T.LOAN_ACCT_BAL, 0) + NVL(T.INT_ADJEST_AMT, 0) > 0 AND
           SUBSTR(t.ITEM_CD, 1, 6) IN ('130101', '130104')) --票据直贴
           );
  COMMIT;
  -------------------------加工结果表  结束----------------------------------------------------------------------------------------

  -------------------------------------------------------------------------
  OI_RETCODE     := 0; --设置异常状态为0 成功状态
  OI_RETCODE_DEC := '执行成功';
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
/
