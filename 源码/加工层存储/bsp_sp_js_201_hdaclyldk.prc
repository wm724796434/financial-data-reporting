CREATE OR REPLACE PROCEDURE BSP_SP_JS_201_HDACLYLDK(IS_DATE        IN VARCHAR2,
                                                    OI_RETCODE     OUT INTEGER,
                                                    OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_201_HDACLYLDK
  -- 用途:生成接口表 PBOCD_JS_201_HDACLYLDK  存量养老贷款信息表  对应1104 S73
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    需求编号：JLBA202502130004_制度升级2025 上线日期：2025-03-27，修改人：周立鹏，提出人：李楠   修改原因：新建
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
  VS_PROCEDURE_NAME := 'BSP_SP_JS_201_HDACLYLDK';

  --开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------
  --新建/清理分区
  SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_201_HDACLYLDK', OI_RETCODE);
  -------------------------------------------------------------------------

EXECUTE IMMEDIATE 'TRUNCATE TABLE PBOCD_DATACORE.PBOCD_JS_201_HDACLYLDK_LOAN';

INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLYLDK_LOAN
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
   PENSION_INDUSTRY,
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
   T1.PENSION_INDUSTRY,
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
         T.PENSION_INDUSTRY,
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


  --插入T01汇总报送数据 改动时需同步修改发生表
  INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLYLDK
    (DATA_DATE, -- 数据日期
     FIELD_TYPE, -- 字段类别
     BALANCE_SUM, -- 贷款汇总金额
     INT_RATE_WA, -- 贷款汇总加权平均利率
     GET_LOAN_NUM, -- 贷款汇总户数
     REPORT_ID, -- ID
     CJRQ, -- 采集日期
     NBJGH, -- 内部机构号
     BIZ_LINE_ID, -- 业务条线ID
     VERIFY_STATUS, -- 校验状态
     BSCJRQ, -- 报送采集日期
     FRNBJGH -- 法人内部机构号
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
      FROM (SELECT 'T01' AS FIELD_TYPE, --字段类别
                   SUM((CASE
                         WHEN T.ACCT_TYP NOT LIKE '0301%' THEN
                          T.LOAN_ACCT_BAL
                         ELSE
                          T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                       END) * U.CCY_RATE) AS BALANCE_SUM, --贷款汇总金额
                   CASE
                     WHEN SUM(CASE
                                WHEN T.ACCT_TYP NOT LIKE '0301%' THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END) = 0 THEN
                      0
                     ELSE
                      ROUND(SUM((CASE
                                  WHEN T.ACCT_TYP NOT LIKE '0301%' THEN
                                   T.LOAN_ACCT_BAL
                                  ELSE
                                   T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                                END) * T.REAL_INT_RAT) /
                            SUM(CASE
                                  WHEN T.ACCT_TYP NOT LIKE '0301%' THEN
                                   T.LOAN_ACCT_BAL
                                  ELSE
                                   T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                                END),
                            5)
                   END INT_RATE_WA, --贷款汇总加权平均利率
                   COUNT(DISTINCT T.CUST_ID) AS GET_LOAN_NUM, --贷款汇总获贷企业数量
                   CASE
                     WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                      SUBSTR(T.ORG_NUM, 1, 2)
                     ELSE
                      '99'
                   END AS NBJGH --内部机构号
              FROM PBOCD_DATACORE.PBOCD_JS_201_HDACLYLDK_LOAN T -- 贷款借据信息表
              LEFT JOIN SMTMODS.L_AGRE_LOAN_CONTRACT D
                ON D.DATA_DATE = IS_DATE
               AND T.ACCT_NUM = D.CONTRACT_NUM
               AND SUBSTR(D.PENSION_INDUSTRY, 1, 2) IN
                   ('01',
                    '02',
                    '03',
                    '04',
                    '05',
                    '06',
                    '07',
                    '08',
                    '09',
                    '10',
                    '11',
                    '12')
              /*LEFT JOIN SMTMODS.L_AGRE_BILL_CONTRACT E
                ON E.DATA_DATE = IS_DATE
               AND T.ACCT_NUM = E.BILL_NUM
               AND SUBSTR(E.PENSION_INDUSTRY, 1, 2) IN
                   ('01',
                    '02',
                    '03',
                    '04',
                    '05',
                    '06',
                    '07',
                    '08',
                    '09',
                    '10',
                    '11',
                    '12')*/
              LEFT JOIN SMTMODS.L_PUBL_RATE U --汇率表
                ON U.DATA_DATE = IS_DATE
               AND U.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD')
               AND U.BASIC_CCY = T.CURR_CD --基准币种
               AND U.FORWARD_CCY = 'CNY' --折算币种
             WHERE T.DATA_DATE = IS_DATE
               AND T.CANCEL_FLG = 'N' --剔除核销
               AND T.LOAN_ACCT_BAL > 0
               AND T.LOAN_STOCKEN_DATE IS NULL --ADD BY HAORUI 20250228 JLBA202408200012 资产未转让
               AND ((D.PENSION_INDUSTRY IS NOT NULL AND --养老产业
                   (SUBSTR(T.ITEM_CD, 1, 4) IN ('1303', '1305', '1306') OR --单位贷款
                   (T.CURR_CD = 'CNY' AND T.ACCT_TYP LIKE '01%'))) --个人贷款
                   OR (NVL(T.LOAN_ACCT_BAL, 0) + NVL(T.INT_ADJEST_AMT, 0) > 0 AND --票据表新增字段判断票据
                   T.PENSION_INDUSTRY IS NOT NULL AND --养老产业
                   SUBSTR(T.ITEM_CD, 1, 6) IN ('130101', '130104')) --票据直贴
                   )
             GROUP BY CASE
                        WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                         SUBSTR(T.ORG_NUM, 1, 2)
                        ELSE
                         '99'
                      END --内部机构号
            
            UNION ALL
            SELECT FIELD_TYPE,
                   BALANCE_SUM,
                   INT_RATE_WA,
                   GET_LOAN_NUM,
                   ORG_CODE
              FROM PBOCD_DATACORE.KJDK_TMP01
             WHERE FLAG = 'YLDK'
               AND FIELD_TYPE = 'T01'
            
            )
     GROUP BY NBJGH, FIELD_TYPE
     ORDER BY NBJGH, FIELD_TYPE;
  COMMIT;

  --插入T02汇总报送数据 改动时需同步修改发生表
  INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLYLDK
    (DATA_DATE, -- 数据日期
     FIELD_TYPE, -- 字段类别
     BALANCE_SUM, -- 贷款汇总金额
     INT_RATE_WA, -- 贷款汇总加权平均利率
     GET_LOAN_NUM, -- 贷款汇总户数
     REPORT_ID, -- ID
     CJRQ, -- 采集日期
     NBJGH, -- 内部机构号
     BIZ_LINE_ID, -- 业务条线ID
     VERIFY_STATUS, -- 校验状态
     BSCJRQ, -- 报送采集日期
     FRNBJGH -- 法人内部机构号
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
      FROM (SELECT 'T02' AS FIELD_TYPE, --字段类别
                   SUM((CASE
                         WHEN T.ACCT_TYP NOT LIKE '0301%' THEN
                          T.LOAN_ACCT_BAL
                         ELSE
                          T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                       END) * U.CCY_RATE) AS BALANCE_SUM, --贷款汇总金额
                   CASE
                     WHEN SUM(CASE
                                WHEN T.ACCT_TYP NOT LIKE '0301%' THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END) = 0 THEN
                      0
                     ELSE
                      ROUND(SUM((CASE
                                  WHEN T.ACCT_TYP NOT LIKE '0301%' THEN
                                   T.LOAN_ACCT_BAL
                                  ELSE
                                   T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                                END) * T.REAL_INT_RAT) /
                            SUM(CASE
                                  WHEN T.ACCT_TYP NOT LIKE '0301%' THEN
                                   T.LOAN_ACCT_BAL
                                  ELSE
                                   T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                                END),
                            5)
                   END INT_RATE_WA, --贷款汇总加权平均利率
                   COUNT(DISTINCT T.CUST_ID) AS GET_LOAN_NUM, --贷款汇总获贷企业数量
                   CASE
                     WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                      SUBSTR(T.ORG_NUM, 1, 2)
                     ELSE
                      '99'
                   END AS NBJGH --内部机构号
              FROM PBOCD_DATACORE.PBOCD_JS_201_HDACLYLDK_LOAN T -- 贷款借据信息表
              LEFT JOIN SMTMODS.L_PUBL_RATE U --汇率表
                ON U.DATA_DATE = IS_DATE
               AND U.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD')
               AND U.BASIC_CCY = T.CURR_CD --基准币种
               AND U.FORWARD_CCY = 'CNY' --折算币种
             WHERE T.DATA_DATE = IS_DATE
               AND T.CANCEL_FLG = 'N' --剔除核销
               AND T.LOAN_ACCT_BAL > 0
               AND T.LOAN_STOCKEN_DATE IS NULL --ADD BY HAORUI 20250228 JLBA202408200012 资产未转让
               AND (SUBSTR(T.ITEM_CD, 1, 4) IN ('1303', '1305', '1306') --单位贷款
                   OR (T.CURR_CD = 'CNY' AND T.ACCT_TYP LIKE '01%') --个人贷款
                   OR (NVL(T.LOAN_ACCT_BAL, 0) + NVL(T.INT_ADJEST_AMT, 0) > 0 AND --票据表新增字段判断票据
                   SUBSTR(T.ITEM_CD, 1, 6) IN ('130101', '130104')) --票据直贴
                   )
               AND EXISTS (SELECT 1 FROM SMTMODS.QGYL_LIST X WHERE X.LOAN_NUM=T.LOAN_NUM)
            
             GROUP BY CASE
                        WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                         SUBSTR(T.ORG_NUM, 1, 2)
                        ELSE
                         '99'
                      END --内部机构号
            
            UNION ALL
            SELECT FIELD_TYPE,
                   BALANCE_SUM,
                   INT_RATE_WA,
                   GET_LOAN_NUM,
                   ORG_CODE
              FROM PBOCD_DATACORE.KJDK_TMP01
             WHERE FLAG = 'YLDK'
               AND FIELD_TYPE = 'T02'
            
            )
     GROUP BY NBJGH, FIELD_TYPE
     ORDER BY NBJGH, FIELD_TYPE;
  COMMIT;



-- 20260130 存量养老产业贷款信息/养老产业贷款发生额信息修订内容
INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLYLDK
  (DATA_DATE, -- 数据日期
   FIELD_TYPE, -- 字段类别
   BALANCE_SUM, -- 贷款汇总金额
   INT_RATE_WA, -- 贷款汇总加权平均利率
   GET_LOAN_NUM, -- 贷款汇总户数
   REPORT_ID, -- ID
   CJRQ, -- 采集日期
   NBJGH, -- 内部机构号
   BIZ_LINE_ID, -- 业务条线ID
   VERIFY_STATUS, -- 校验状态
   BSCJRQ, -- 报送采集日期
   FRNBJGH -- 法人内部机构号
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
    FROM (SELECT CASE
                   WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '01' THEN
                    'T03'
                   WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '02' THEN
                    'T04'
                   WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '03' THEN
                    'T05'
                   WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '04' THEN
                    'T06'
                   WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '05' THEN
                    'T07'
                   WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '06' THEN
                    'T08'
                   WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '07' THEN
                    'T09'
                   WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '08' THEN
                    'T10'
                   WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '09' THEN
                    'T11'
                   WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '10' THEN
                    'T12'
                   WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '11' THEN
                    'T13'
                   WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '12' THEN
                    'T14'
                 END AS FIELD_TYPE, --字段类别
                 SUM((CASE
                       WHEN T.ACCT_TYP NOT LIKE '0301%' THEN
                        T.LOAN_ACCT_BAL
                       ELSE
                        T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                     END) * U.CCY_RATE) AS BALANCE_SUM, --贷款汇总金额
                 CASE
                   WHEN SUM(CASE
                              WHEN T.ACCT_TYP NOT LIKE '0301%' THEN
                               T.LOAN_ACCT_BAL
                              ELSE
                               T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                            END) = 0 THEN
                    0
                   ELSE
                    ROUND(SUM((CASE
                                WHEN T.ACCT_TYP NOT LIKE '0301%' THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END) * T.REAL_INT_RAT) /
                          SUM(CASE
                                WHEN T.ACCT_TYP NOT LIKE '0301%' THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END),
                          5)
                 END INT_RATE_WA, --贷款汇总加权平均利率
                 COUNT(DISTINCT T.CUST_ID) AS GET_LOAN_NUM, --贷款汇总获贷企业数量
                 CASE
                   WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                    SUBSTR(T.ORG_NUM, 1, 2)
                   ELSE
                    '99'
                 END AS NBJGH --内部机构号
            FROM PBOCD_DATACORE.PBOCD_JS_201_HDACLYLDK_LOAN T -- 贷款借据信息表
            LEFT JOIN SMTMODS.L_AGRE_LOAN_CONTRACT D
              ON D.DATA_DATE = IS_DATE
             AND T.ACCT_NUM = D.CONTRACT_NUM
             AND SUBSTR(D.PENSION_INDUSTRY, 1, 2) IN
                 ('01',
                  '02',
                  '03',
                  '04',
                  '05',
                  '06',
                  '07',
                  '08',
                  '09',
                  '10',
                  '11',
                  '12')
            LEFT JOIN SMTMODS.L_PUBL_RATE U --汇率表
              ON U.DATA_DATE = IS_DATE
             AND U.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD')
             AND U.BASIC_CCY = T.CURR_CD --基准币种
             AND U.FORWARD_CCY = 'CNY' --折算币种
           WHERE T.DATA_DATE = IS_DATE
             AND T.CANCEL_FLG = 'N' --剔除核销
             AND T.LOAN_ACCT_BAL > 0
             AND T.LOAN_STOCKEN_DATE IS NULL --ADD BY HAORUI 20250228 JLBA202408200012 资产未转让
             AND ((D.PENSION_INDUSTRY IS NOT NULL AND --养老产业
                 (SUBSTR(T.ITEM_CD, 1, 4) IN ('1303', '1305', '1306') OR --单位贷款
                 (T.CURR_CD = 'CNY' AND T.ACCT_TYP LIKE '01%'))) --个人贷款
                 OR (NVL(T.LOAN_ACCT_BAL, 0) + NVL(T.INT_ADJEST_AMT, 0) > 0 AND --票据表新增字段判断票据
                 T.PENSION_INDUSTRY IS NOT NULL AND --养老产业
                 SUBSTR(T.ITEM_CD, 1, 6) IN ('130101', '130104')) --票据直贴
                 )
           GROUP BY CASE
                      WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '01' THEN
                       'T03'
                      WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '02' THEN
                       'T04'
                      WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '03' THEN
                       'T05'
                      WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '04' THEN
                       'T06'
                      WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '05' THEN
                       'T07'
                      WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '06' THEN
                       'T08'
                      WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '07' THEN
                       'T09'
                      WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '08' THEN
                       'T10'
                      WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '09' THEN
                       'T11'
                      WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '10' THEN
                       'T12'
                      WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '11' THEN
                       'T13'
                      WHEN SUBSTR(D.PENSION_INDUSTRY, 1, 2) = '12' THEN
                       'T14'
                    END,
                    CASE
                      WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                       SUBSTR(T.ORG_NUM, 1, 2)
                      ELSE
                       '99'
                    END --内部机构号
          
          UNION ALL
          SELECT FIELD_TYPE,
                 BALANCE_SUM,
                 INT_RATE_WA,
                 GET_LOAN_NUM,
                 ORG_CODE
            FROM PBOCD_DATACORE.KJDK_TMP01
           WHERE FLAG = 'YLDK'
             AND FIELD_TYPE NOT IN ('T01', 'T02')
          
          )
   GROUP BY NBJGH, FIELD_TYPE
   ORDER BY NBJGH, FIELD_TYPE;
   COMMIT;

  --插入T99_逐笔报送数据 改动时需同步修改发生表
  INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLYLDK
    (DATA_DATE, -- 数据日期
     FIELD_TYPE, -- 字段类别
     ORG_CODE, -- 金融机构代码
     ORG_NUM, -- 内部机构号
     CONTRACT_CODE, -- 贷款合同编码
     LOAN_NUM, -- 贷款借据编码
     BILL_NUM, -- 票据编号
     PENSIDY_TYPE, -- 养老产业贷款类型
     NURSING_FLG, -- 是否全国养老机构贷款
     BIZ_TYPE, -- 业务类别
     REPORT_ID, -- ID
     CJRQ, -- 采集日期
     NBJGH, -- 内部机构号
     BIZ_LINE_ID, -- 业务条线ID
     VERIFY_STATUS, -- 校验状态
     BSCJRQ, -- 报送采集日期
     FRNBJGH, -- 法人内部机构号
     CUST_ID, -- 客户号
     CUST_NAME, -- 客户名
     LOAN_ACCT_BAL, -- 贷款余额
     CURR_CD, -- 币种
     LOAN_ACCT_BAL_RMB, -- 贷款余额折人民币
     DRAWDOWN_AMT, -- 放款金额
     DISCOUNT_INTEREST -- 贴现利息
     )
    SELECT /*+PARALLEL(4)*/
     VS_TEXT AS DATA_DATE, --数据日期
     'T99', --字段类别
     NVL(OB.ID_NO, OB.UP_ID_NO), --金融机构代码
     T.ORG_NUM, --内部机构号
     CASE
       WHEN SUBSTR(T.ITEM_CD, 1, 6) NOT IN ('130101', '130104') THEN
        T.ACCT_NUM
       ELSE
        '0'
     END, --贷款合同编码
     CASE
       WHEN SUBSTR(T.ITEM_CD, 1, 6) NOT IN ('130101', '130104') THEN
        T.LOAN_NUM
       ELSE
        '0'
     END, --贷款借据编码
     CASE
       WHEN SUBSTR(T.ITEM_CD, 1, 6) IN ('130101', '130104') THEN
        T.ACCT_NUM || T.DRAFT_RNG
       ELSE
        '0'
     END, --票据编号
     'EC' || SUBSTR(D.PENSION_INDUSTRY, 1, 2), --养老产业贷款类型
     CASE WHEN F.LOAN_NUM IS NOT NULL THEN '1' ELSE '0' END, --是否全国养老机构贷款
     CASE
     WHEN T.ACCT_TYP LIKE '01%' OR C.CUST_TYP = '3' THEN
        'C02' --个人贷款
       WHEN SUBSTR(T.ITEM_CD, 1, 4) IN ('1303', '1305', '1306') THEN
        'C01' --单位贷款
       WHEN SUBSTR(T.ITEM_CD, 1, 6) IN ('130101', '130104') THEN
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
     T.DISCOUNT_INTEREST --贴现利息
      FROM PBOCD_DATACORE.PBOCD_JS_201_HDACLYLDK_LOAN T -- 贷款借据信息表
      LEFT JOIN SMTMODS.L_AGRE_LOAN_CONTRACT D
        ON D.DATA_DATE = IS_DATE
       AND T.ACCT_NUM = D.CONTRACT_NUM
       AND SUBSTR(D.PENSION_INDUSTRY, 1, 2) IN
           ('01',
            '02',
            '03',
            '04',
            '05',
            '06',
            '07',
            '08',
            '09',
            '10',
            '11',
            '12')
      LEFT JOIN SMTMODS.QGYL_LIST F -- 全国养老按清单出数
        ON T.LOAN_NUM = F.LOAN_NUM
      /*LEFT JOIN SMTMODS.L_AGRE_BILL_CONTRACT E
        ON E.DATA_DATE = IS_DATE
       AND T.ACCT_NUM = E.BILL_NUM
       AND SUBSTR(E.PENSION_INDUSTRY, 1, 2) IN
           ('01',
            '02',
            '03',
            '04',
            '05',
            '06',
            '07',
            '08',
            '09',
            '10',
            '11',
            '12')*/
      LEFT JOIN SMTMODS.L_CUST_ALL A2
        ON A2.DATA_DATE = IS_DATE
       AND A2.CUST_ID = T.CUST_ID
    LEFT JOIN SMTMODS.L_CUST_C C
        ON C.DATA_DATE = IS_DATE
       AND C.CUST_ID = T.CUST_ID
      LEFT JOIN L_PUBL_ORG_BRA_TMP OB --金数机构表
        ON OB.ORG_NUM = T.ORG_NUM
       AND OB.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_PUBL_RATE U --汇率表
        ON U.DATA_DATE = IS_DATE
       AND U.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD')
       AND U.BASIC_CCY = T.CURR_CD --基准币种
       AND U.FORWARD_CCY = 'CNY' --折算币种
     WHERE T.DATA_DATE = IS_DATE
       AND T.CANCEL_FLG = 'N' --剔除核销
       AND T.LOAN_ACCT_BAL > 0
       AND T.LOAN_STOCKEN_DATE IS NULL --ADD BY HAORUI 20250228 JLBA202408200012 资产未转让
       AND (F.LOAN_NUM IS NOT NULL
       
           OR (D.PENSION_INDUSTRY IS NOT NULL AND --养老产业
           (SUBSTR(T.ITEM_CD, 1, 4) IN ('1303', '1305', '1306') OR --单位贷款
           (T.CURR_CD = 'CNY' AND T.ACCT_TYP LIKE '01%'))) --个人贷款
              
           OR (NVL(T.LOAN_ACCT_BAL, 0) + NVL(T.INT_ADJEST_AMT, 0) > 0 AND --票据表新增字段判断票据
           T.PENSION_INDUSTRY IS NOT NULL AND --养老产业
           SUBSTR(T.ITEM_CD, 1, 6) IN ('130101', '130104')) --票据直贴
           );
  COMMIT;
/*
key: '0110', value: '居家养老照护服务'
key: '0120', value: '社区养老照护服务'
key: '0130', value: '机构养老照护服务'
key: '0210', value: '老年预防保健和健康管理'
key: '0220', value: '老年人疾病诊疗服务'
key: '0231', value: '老年康复和医疗护理服务'
key: '0232', value: '老年康复辅具配置服务'
key: '0240', value: '安宁疗护服务'
key: '0290', value: '其他未列明老年医疗卫生服务'
key: '0311', value: '老年运动休闲和群众体育活动'
key: '0312', value: '老年体育健康服务'
key: '0320', value: '老年文化娱乐活动'
key: '0330', value: '老年旅游服务'
key: '0341', value: '老年养生保健服务'
key: '0342', value: '老年心理健康服务'
key: '0350', value: '老年志愿服务'
key: '0411', value: '基本养老保险'
key: '0412', value: '老年基本医疗保险'
key: '0413', value: '老年长期护理保险'
key: '0414', value: '老年补充保险'
key: '0420', value: '老年人社会救助'
key: '0430', value: '老年人慈善服务'
key: '0440', value: '老年人社会福利'
key: '0450', value: '养老彩票公益金服务'
key: '0511', value: '养老相关专业教育'
key: '0512', value: '养老职业技能培训'
key: '0513', value: '养老教育和技能培训
key: '0520', value: '老年教育'
key: '0531', value: '养老职业技能服务'
key: '0532', value: '养老就业服务'
key: '0533', value: '老年人人力资源开发服务'
key: '0611', value: '老年商业保险-老年人寿保险'
key: '0612', value: '老年商业保险-老年健康保险'
key: '0613', value: '老年商业保险-老年人意外伤害保险'
key: '0614', value: '老年商业保险-养老机构责任保险'
key: '0621', value: '养老年金保险'
key: '0622', value: '住房反向抵押养老保险'
key: '0629', value: '其他商业养老保险'
key: '0630', value: '养老理财服务'
key: '0640', value: '养老金信托'
key: '0650', value: '养老债券'
key: '0690', value: '其他养老金融服务'
key: '0711', value: '养老科技服务-养老科学研究和试验发展'
key: '0712', value: '养老科技服务-养老科技推广和应用服务'
key: '0713', value: '养老科技服务-养老产品质检技术服务'
key: '0721', value: '智慧养老服务-互联网养老服务平台'
key: '0722', value: '智慧养老服务-养老大数据与云计算服务'
key: '0723', value: '智慧养老服务-物联网养老技术服务'
key: '0729', value: '智慧养老服务-其他智慧养老技术服务'
key: '0810', value: '政府养老管理服务'
key: '0820', value: '养老社会组织服务'
key: '0910', value: '养老传媒服务'
key: '0921', value: '老年司法援助服务'
key: '0930', value: '养老相关展览服务'
key: '0940', value: '老年婚姻服务'
key: '0950', value: '养老代理服务'
key: '0990', value: '其他未列明的养老服务'
key: '1010', value: '老年食品制造'
key: '1020', value: '老年日用品及辅助产品制造'
key: '1030', value: '老年健身产品制造'
key: '1040', value: '老年休闲娱乐产品制造'
key: '1050', value: '老年保健用品制造'
key: '1060', value: '老年药品制造'
key: '1070', value: '老年医疗器械和康复辅具制造'
key: '1080', value: '老年智能与可穿戴装备制造'
key: '1090', value: '老年代步车制造'
key: '1111', value: '老年营养和保健品销售'
key: '1112', value: '老年日用品及辅助产品销售'
key: '1113', value: '老年保健用品销售'
key: '1114', value: '老年文体产品销售'
key: '1115', value: '老年药品销售'
key: '1116', value: '老年医疗器械和康复辅具销售'
key: '1117', value: '老年智能与可穿戴装备销售'
key: '1118', value: '老年代步车销售'
key: '1120', value: '老年相关产品租赁'
key: '1210', value: '养老设施建设、改造及装修维修'
key: '1220', value: '住宅适老化及无障碍改造'
key: '1230', value: '公共设施适老化及无障碍改造'
*/
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
