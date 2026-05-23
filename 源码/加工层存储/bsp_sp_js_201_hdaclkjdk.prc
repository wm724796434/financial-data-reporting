CREATE OR REPLACE PROCEDURE BSP_SP_JS_201_HDACLKJDK(IS_DATE        IN VARCHAR2,
                                                    OI_RETCODE     OUT INTEGER,
                                                    OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_201_HDACLKJDK
  -- 用途:生成接口表 PBOCD_JS_201_HDACLKJDK  存量科技贷款信息表
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    CAEATE BY ZHOULP AT 20240926_JLBA202406280007_关于吉林银行金融基础数据采集平台新增科技贷款数据采集报送的需求
  --    ALTER  BY SHIYU  AT 20241224_JLBA202409030006 关于吉林银行NGI系统优化展示区域增加科技贷款等标识及相关报表改造的需求
  --    需求编号：JLBA202502130004_制度升级2025 上线日期：2025-03-27，修改人：周立鹏，提出人：李楠   修改原因：制度升级2025
  --    需求编号：JLBA202510150005_关于票据系统的票交所票据标识功能改造的需求 上线日期：2025-12-11，修改人：周立鹏，提出人：李楠   修改原因：加入票据 高技术制造业、高技术服务业、知识产权 取数逻辑
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
  VS_PROCEDURE_NAME := 'BSP_SP_JS_201_HDACLKJDK';

  --开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------
  --新建/清理分区
  SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_201_HDACLKJDK', OI_RETCODE);

EXECUTE IMMEDIATE 'TRUNCATE TABLE PBOCD_DATACORE.PBOCD_JS_201_HDACLKJDK_LOAN';

INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLKJDK_LOAN
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

  --插入T01-T12汇总报送数据 改动时需同步修改发生表
  INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLKJDK
    (DATA_DATE, --数据日期
     FIELD_TYPE, --字段类别
     BALANCE_SUM, --贷款汇总金额
     INT_RATE_WA, --贷款汇总加权平均利率
     GET_LOAN_NUM, --贷款汇总获贷企业数量
     REPORT_ID, --ID
     CJRQ, --采集日期
     NBJGH, --内部机构号
     BIZ_LINE_ID, --业务条线ID
     VERIFY_STATUS, --校验状态
     BSCJRQ, --报送采集日期
     FRNBJGH --法人内部机构号
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
      FROM (
            --T08_高技术制造业汇总
            SELECT 'T08' AS FIELD_TYPE, --字段类别
                    SUM((CASE
                          WHEN B.BILL_NUM IS NULL THEN
                           T.LOAN_ACCT_BAL
                          ELSE
                           T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                        END) * TT.CCY_RATE) AS BALANCE_SUM, --贷款汇总金额
                    CASE WHEN SUM(CASE
                                WHEN B.BILL_NUM IS NULL THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END) =0 THEN 0 ELSE
                    ROUND(SUM((CASE
                                WHEN B.BILL_NUM IS NULL THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END) * T.REAL_INT_RAT) /
                          SUM(CASE
                                WHEN B.BILL_NUM IS NULL THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END),
                          5) END INT_RATE_WA, --贷款汇总加权平均利率
                    COUNT(DISTINCT T.CUST_ID) AS GET_LOAN_NUM, --贷款汇总获贷企业数量
                    CASE
                      WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                       SUBSTR(T.ORG_NUM, 1, 2)
                      ELSE
                       '99'
                    END AS NBJGH --内部机构号
              FROM PBOCD_DATACORE.PBOCD_JS_201_HDACLKJDK_LOAN T --贷款借据信息表
             INNER JOIN SMTMODS.L_CUST_C A --对公客户信息表
                ON A.DATA_DATE = IS_DATE
               AND A.CUST_ID = T.CUST_ID
               AND a.CUST_TYP <> '3' --不等于个体工商户
              LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B
                ON T.ACCT_NUM = B.BILL_NUM
               AND B.DATA_DATE = IS_DATE
              LEFT JOIN SMTMODS.L_PUBL_RATE TT --汇率表
                ON TT.DATA_DATE = IS_DATE
               AND TT.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD') --汇率日期
               AND TT.BASIC_CCY = T.CURR_CD --基准币种
               AND TT.FORWARD_CCY = 'CNY' --折算币种
              LEFT JOIN SMTMODS.L_AGRE_LOAN_CONTRACT C
                 ON T.ACCT_NUM =C.CONTRACT_NUM
                 AND C.DATA_DATE = IS_DATE
             WHERE T.DATA_DATE = IS_DATE --取数逻辑参考1104_S7001和一表通T_2_1
               AND T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND (--完全复制S72逻辑 312-403行
                 t.ITEM_CD not like '130102%' --以摊余成本计量的转贴现
                 and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现
                 --[2025-12-11] [周立鹏] [JLBA202510150005_关于票据系统的票交所票据标识功能改造的需求][李楠] 加入票据 高技术制造业、高技术服务业、知识产权 取数逻辑
                 --AND nvl(C.HIGH_TECH_MNFT,'0')<>'0'   --高技术制造业--ALTER BY SHIYU 20241029 JLBA202409030006
                 AND (( NVL(C.HIGH_TECH_MNFT,'0') <>'0'  --高技术制造业  --alter by shiyu 20241028
                        AND T.ITEM_CD NOT  LIKE '1301%' )
                     OR (SUBSTR(T.HIGH_TECH_MNFT,1,2) IN ('01','02','03','04','05','06') AND T.ITEM_CD LIKE '1301%' ))
                 
                 AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
                 AND T.FUND_USE_LOC_CD = 'I'
                 AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
                 AND t.ACCT_TYP NOT LIKE '90%'
                 and t.CANCEL_FLG <> 'Y'
         AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让

       )
             GROUP BY CASE
                         WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                          SUBSTR(T.ORG_NUM, 1, 2)
                         ELSE
                          '99'
                       END
            --T09_高技术服务业汇总
            UNION
            SELECT 'T09' AS FIELD_TYPE, --字段类别
                    SUM((CASE
                          WHEN B.BILL_NUM IS NULL THEN
                           T.LOAN_ACCT_BAL
                          ELSE
                           T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                        END) * TT.CCY_RATE) AS BALANCE_SUM, --贷款汇总金额
                    CASE WHEN SUM(CASE
                                WHEN B.BILL_NUM IS NULL THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END) =0 THEN 0 ELSE
                    ROUND(SUM((CASE
                                WHEN B.BILL_NUM IS NULL THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END) * T.REAL_INT_RAT) /
                          SUM(CASE
                                WHEN B.BILL_NUM IS NULL THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END),
                          5) END INT_RATE_WA, --贷款汇总加权平均利率
                    COUNT(DISTINCT T.CUST_ID) AS GET_LOAN_NUM, --贷款汇总获贷企业数量
                    CASE
                      WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                       SUBSTR(T.ORG_NUM, 1, 2)
                      ELSE
                       '99'
                    END AS NBJGH --内部机构号
              FROM PBOCD_DATACORE.PBOCD_JS_201_HDACLKJDK_LOAN T --贷款借据信息表
             INNER JOIN SMTMODS.L_CUST_C A --对公客户信息表
                ON A.DATA_DATE = IS_DATE
               AND A.CUST_ID = T.CUST_ID
               AND a.CUST_TYP <> '3' --不等于个体工商户
              LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B
                ON T.ACCT_NUM = B.BILL_NUM
               AND B.DATA_DATE = IS_DATE
              LEFT JOIN SMTMODS.L_PUBL_RATE TT --汇率表
                ON TT.DATA_DATE = IS_DATE
               AND TT.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD') --汇率日期
               AND TT.BASIC_CCY = T.CURR_CD --基准币种
               AND TT.FORWARD_CCY = 'CNY' --折算币种
              LEFT JOIN SMTMODS.L_AGRE_LOAN_CONTRACT C
                   ON T.ACCT_NUM =C.CONTRACT_NUM
                   AND C.DATA_DATE = IS_DATE
             WHERE T.DATA_DATE = IS_DATE --取数逻辑参考1104_S7001和一表通T_2_1
               AND T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
         AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
               AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
               AND T.ACCT_TYP NOT LIKE '90%' --不含委托贷款

              --[2025-12-11] [周立鹏] [JLBA202510150005_关于票据系统的票交所票据标识功能改造的需求][李楠] 加入票据 高技术制造业、高技术服务业、知识产权 取数逻辑
              --AND nvl(C.HIGH_TECH_SRVE,'0') <> '0' --高技术服务业  --alter by shiyu 20241029 JLBA202409030006
              AND (( NVL(C.HIGH_TECH_SRVE,'0') <>'0' AND T.ITEM_CD NOT  LIKE '1301%' )
                     OR (SUBSTR(T.HIGH_TECH_SRVE,1,1) IN ('1','2','3','4','5','6','7','8') AND T.ITEM_CD LIKE '1301%' ))--高技术服务业
              
             GROUP BY CASE
                         WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                          SUBSTR(T.ORG_NUM, 1, 2)
                         ELSE
                          '99'
                       END

            --T11_知识产权（专利）密集型产业汇总
            UNION
            SELECT 'T11' AS FIELD_TYPE, --字段类别
                    SUM((CASE
                          WHEN B.BILL_NUM IS NULL THEN
                           T.LOAN_ACCT_BAL
                          ELSE
                           T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                        END) * TT.CCY_RATE) AS BALANCE_SUM, --贷款汇总金额
                    CASE WHEN SUM(CASE
                                WHEN B.BILL_NUM IS NULL THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END) =0 THEN 0 ELSE
                    ROUND(SUM((CASE
                                WHEN B.BILL_NUM IS NULL THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END) * T.REAL_INT_RAT) /
                          SUM(CASE
                                WHEN B.BILL_NUM IS NULL THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END),
                          5) END INT_RATE_WA, --贷款汇总加权平均利率
                    COUNT(DISTINCT T.CUST_ID) AS GET_LOAN_NUM, --贷款汇总获贷企业数量
                    CASE
                      WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                       SUBSTR(T.ORG_NUM, 1, 2)
                      ELSE
                       '99'
                    END AS NBJGH --内部机构号
              FROM PBOCD_DATACORE.PBOCD_JS_201_HDACLKJDK_LOAN T --贷款借据信息表
             INNER JOIN SMTMODS.L_CUST_C A --对公客户信息表
                ON A.DATA_DATE = IS_DATE
               AND A.CUST_ID = T.CUST_ID
               AND a.CUST_TYP <> '3' --不等于个体工商户
              LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B
                ON T.ACCT_NUM = B.BILL_NUM
               AND B.DATA_DATE = IS_DATE
              LEFT JOIN SMTMODS.PUB_KJDK M3
                ON SUBSTR(M3.HYDL, 1, 2) = 'PA'
               AND T.LOAN_PURPOSE_CD = M3.CODE
              LEFT JOIN SMTMODS.L_PUBL_RATE TT --汇率表
                ON TT.DATA_DATE = IS_DATE
               AND TT.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD') --汇率日期
               AND TT.BASIC_CCY = T.CURR_CD --基准币种
               AND TT.FORWARD_CCY = 'CNY' --折算币种
              LEFT JOIN SMTMODS.L_AGRE_LOAN_CONTRACT C
                 ON T.ACCT_NUM = C.CONTRACT_NUM
                 AND C.DATA_DATE = IS_DATE
             WHERE T.DATA_DATE = IS_DATE
               AND T.LOAN_ACCT_BAL > 0 --贷款余额大于0
       AND(--完全复制G0107逻辑 1941-1946行
         (T.FUND_USE_LOC_CD = 'I'
         AND T.ACCT_TYP NOT LIKE '0301%'
         AND T.ACCT_TYP NOT LIKE '90%'
         AND T.ACCT_STS <> '3'
         AND T.CANCEL_FLG = 'N'
     AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
         AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
         AND LENGTHB(T.ACCT_NUM) < 36
         AND T.ACCT_TYP NOT LIKE '0301%' --SHIWENBO BY 20170316-12901 单独取直贴
         AND nvl(C.PANT_DENS_INDU,'0') <>'0'  --知识产权（专利）密集型产业 ALTER BY SHIYU 20241029 JLBA202409030006
          )
         OR
         (T.FUND_USE_LOC_CD = 'I'
         AND T.CANCEL_FLG = 'N'
     AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
         AND LENGTHB(T.ACCT_NUM) < 36
         AND (T.ITEM_CD LIKE '130101%' OR T.ITEM_CD LIKE  '130104%') -- AND ITEM_CD LIKE '130101%'AND ITEM_CD LIKE  '130104%' -- 20221029 UPDATE BY WANGKUI
         
         --[2025-12-11] [周立鹏] [JLBA202510150005_关于票据系统的票交所票据标识功能改造的需求][李楠] 加入票据 高技术制造业、高技术服务业、知识产权 取数逻辑
         --AND nvl(C.PANT_DENS_INDU,'0') <>'0' --知识产权（专利）密集型产业 ALTER BY SHIYU 20241029 JLBA202409030006
         AND SUBSTR(T.PANT_DENS_INDU,1,2) IN ('01','02','03','04','05','06','07') 
          )
        )

             GROUP BY CASE
                         WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                          SUBSTR(T.ORG_NUM, 1, 2)
                         ELSE
                          '99'
                       END
            --T10_战略性新兴产业汇总
            UNION
            SELECT 'T10' AS FIELD_TYPE, --字段类别
                    SUM((CASE
                          WHEN B.BILL_NUM IS NULL THEN
                           T.LOAN_ACCT_BAL
                          ELSE
                           T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                        END) * TT.CCY_RATE) AS BALANCE_SUM, --贷款汇总金额
                    CASE WHEN SUM(CASE
                                WHEN B.BILL_NUM IS NULL THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END) =0 THEN 0 ELSE
                    ROUND(SUM((CASE
                                WHEN B.BILL_NUM IS NULL THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END) * T.REAL_INT_RAT) /
                          SUM(CASE
                                WHEN B.BILL_NUM IS NULL THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END),
                          5) END INT_RATE_WA, --贷款汇总加权平均利率
                    COUNT(DISTINCT T.CUST_ID) AS GET_LOAN_NUM, --贷款汇总获贷企业数量
                    CASE
                      WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                       SUBSTR(T.ORG_NUM, 1, 2)
                      ELSE
                       '99'
                    END AS NBJGH --内部机构号
              FROM PBOCD_DATACORE.PBOCD_JS_201_HDACLKJDK_LOAN T --贷款借据信息表
             INNER JOIN SMTMODS.L_CUST_C A --对公客户信息表
                ON A.DATA_DATE = IS_DATE
               AND A.CUST_ID = T.CUST_ID
               AND a.CUST_TYP <> '3' --不等于个体工商户
              LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B
                ON T.ACCT_NUM = B.BILL_NUM
               AND B.DATA_DATE = IS_DATE
              LEFT JOIN SMTMODS.L_PUBL_RATE TT --汇率表
                ON TT.DATA_DATE = IS_DATE
               AND TT.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD') --汇率日期
               AND TT.BASIC_CCY = T.CURR_CD --基准币种
               AND TT.FORWARD_CCY = 'CNY' --折算币种
             WHERE T.DATA_DATE = IS_DATE --取数逻辑参考1104_S7001和一表通T_2_1
               AND T.LOAN_ACCT_BAL > 0 --贷款余额大于0

               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
         AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
               AND T.ACCT_TYP NOT LIKE '90%' --不含委托贷款
               AND  ( --节能环保

         ( T.INDUST_STG_TYPE ='1' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('C') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('C') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('C') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         --新一代信息技术
         or
           ( T.INDUST_STG_TYPE ='2' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('D') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('D') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('D') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         OR
         --生物产业
           ( T.INDUST_STG_TYPE ='3' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('E') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('E') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('E') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         OR
         --战略性新兴产业:高端装备制造
             ( T.INDUST_STG_TYPE ='4' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('F') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('F') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('F') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         ---战略性新兴产业:新能源
         OR
              ( T.INDUST_STG_TYPE ='5' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('G') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('G') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('G') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         --战略性新兴产业:新材料
         OR( T.INDUST_STG_TYPE ='6' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('H') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('H') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('H') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         -----战略性新兴产业:新能源汽车
        OR  ( T.INDUST_STG_TYPE ='7' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('I') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('I') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('I') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         ---战略性新兴产业:数字创意
         OR ( T.INDUST_STG_TYPE ='8' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('J') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('J') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('J') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         ---战略性新兴产业:相关服务
         OR   ( T.INDUST_STG_TYPE ='9' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('K') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('K') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('K') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         )

             GROUP BY CASE
                         WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                          SUBSTR(T.ORG_NUM, 1, 2)
                         ELSE
                          '99'
                       END

            --T12_科技相关产业贷款汇总 T08-T11之和
            UNION
            SELECT 'T12' AS FIELD_TYPE, --字段类别
                    SUM((CASE
                          WHEN B.BILL_NUM IS NULL THEN
                           T.LOAN_ACCT_BAL
                          ELSE
                           T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                        END) * TT.CCY_RATE) AS BALANCE_SUM, --贷款汇总金额

                    CASE WHEN SUM(CASE
                                WHEN B.BILL_NUM IS NULL THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END) =0 THEN 0 ELSE
                    ROUND(SUM((CASE
                                WHEN B.BILL_NUM IS NULL THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END) * T.REAL_INT_RAT) /
                          SUM(CASE
                                WHEN B.BILL_NUM IS NULL THEN
                                 T.LOAN_ACCT_BAL
                                ELSE
                                 T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                              END),
                          5) END AS INT_RATE_WA, --贷款汇总加权平均利率
                    COUNT(DISTINCT T.CUST_ID) AS GET_LOAN_NUM, --贷款汇总获贷企业数量
                    CASE
                      WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                       SUBSTR(T.ORG_NUM, 1, 2)
                      ELSE
                       '99'
                    END AS NBJGH --内部机构号
              FROM PBOCD_DATACORE.PBOCD_JS_201_HDACLKJDK_LOAN T --贷款借据信息表
             INNER JOIN SMTMODS.L_CUST_C A --对公客户信息表
                ON A.DATA_DATE = IS_DATE
               AND A.CUST_ID = T.CUST_ID
               AND a.CUST_TYP <> '3' --不等于个体工商户
              LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B
                ON T.ACCT_NUM = B.BILL_NUM
               AND B.DATA_DATE = IS_DATE
              LEFT JOIN SMTMODS.PUB_KJDK M2
                ON SUBSTR(M2.HYDL, 1, 3) = 'HTS'
               AND T.LOAN_PURPOSE_CD = M2.CODE
              LEFT JOIN SMTMODS.PUB_KJDK M3
                ON SUBSTR(M3.HYDL, 1, 2) = 'PA'
               AND T.LOAN_PURPOSE_CD = M3.CODE
              LEFT JOIN SMTMODS.L_PUBL_RATE TT --汇率表
                ON TT.DATA_DATE = IS_DATE
               AND TT.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD') --汇率日期
               AND TT.BASIC_CCY = T.CURR_CD --基准币种
               AND TT.FORWARD_CCY = 'CNY' --折算币种
             LEFT JOIN SMTMODS.L_AGRE_LOAN_CONTRACT C
               ON C.CONTRACT_NUM = T.ACCT_NUM
               AND C.DATA_DATE = IS_DATE
             WHERE T.DATA_DATE = IS_DATE --取数逻辑参考1104_S7001和一表通T_2_1
               AND T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND
               (
               (T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
         AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
               AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
               AND T.ACCT_TYP NOT LIKE '90%' --不含委托贷款
               AND 
                  --[2025-12-11] [周立鹏] [JLBA202510150005_关于票据系统的票交所票据标识功能改造的需求][李楠] 加入票据 高技术制造业、高技术服务业、知识产权 取数逻辑
                  --nvl(C.HIGH_TECH_SRVE,'0') <>'0'--高技术服务业--ALTER BY SHIYU 20241029 JLBA202409030006
                  (( NVL(C.HIGH_TECH_SRVE,'0') <>'0' AND T.ITEM_CD NOT  LIKE '1301%' )
                     OR (SUBSTR(T.HIGH_TECH_SRVE,1,1) IN ('1','2','3','4','5','6','7','8') AND T.ITEM_CD LIKE '1301%' ))--高技术服务业
        )
        /*PA-知识产权（专利）密集型产业*/
       OR(--完全复制G0107逻辑 1941-1946行
         (T.FUND_USE_LOC_CD = 'I'
         AND T.ACCT_TYP NOT LIKE '0301%'
         AND T.ACCT_TYP NOT LIKE '90%'
         AND T.ACCT_STS <> '3'
         AND T.CANCEL_FLG = 'N'
     AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
         AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
         AND LENGTHB(T.ACCT_NUM) < 36
         AND T.ACCT_TYP NOT LIKE '0301%' --SHIWENBO BY 20170316-12901 单独取直贴
         AND nvl(C.PANT_DENS_INDU,'0') <>'0' --知识产权（专利）密集型产业--ALTER BY SHIYU 20241029 JLBA202409030006
          )
         OR
         (T.FUND_USE_LOC_CD = 'I'
         AND T.CANCEL_FLG = 'N'
     AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
         AND LENGTHB(T.ACCT_NUM) < 36
         AND (T.ITEM_CD LIKE '130101%' OR T.ITEM_CD LIKE  '130104%') -- AND ITEM_CD LIKE '130101%'AND ITEM_CD LIKE  '130104%' -- 20221029 UPDATE BY WANGKUI
         
         --[2025-12-11] [周立鹏] [JLBA202510150005_关于票据系统的票交所票据标识功能改造的需求][李楠] 加入票据 高技术制造业、高技术服务业、知识产权 取数逻辑
         --AND nvl(C.PANT_DENS_INDU,'0') <>'0' --知识产权（专利）密集型产业--ALTER BY SHIYU 20241029 JLBA202409030006
         AND SUBSTR(T.PANT_DENS_INDU,1,2) IN ('01','02','03','04','05','06','07') --知识产权（专利）密集型产业
         
          )
        )


         /*HTP-高技术制造业*/
        OR (--完全复制S72逻辑 312-403行
                 t.ITEM_CD not like '130102%' --以摊余成本计量的转贴现
                 and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现

                 --[2025-12-11] [周立鹏] [JLBA202510150005_关于票据系统的票交所票据标识功能改造的需求][李楠] 加入票据 高技术制造业、高技术服务业、知识产权 取数逻辑
                 --and nvl(c.HIGH_TECH_MNFT,'0') <>'0' --高技术制造业 --alter by shiy 20241029 JLBA202409030006
                 AND (( NVL(C.HIGH_TECH_MNFT,'0') <>'0'  --高技术制造业  --alter by shiyu 20241028
                        AND T.ITEM_CD NOT  LIKE '1301%' )
                     OR (SUBSTR(T.HIGH_TECH_MNFT,1,2) IN ('01','02','03','04','05','06') AND T.ITEM_CD LIKE '1301%' ))
                 
                 AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
                 AND T.FUND_USE_LOC_CD = 'I'
                 AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
                 AND t.ACCT_TYP NOT LIKE '90%'
                 and t.CANCEL_FLG <> 'Y'
         AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让

       )


       /*战略性新兴产业*/
        OR

        (T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
         AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
               AND T.ACCT_TYP NOT LIKE '90%'
               AND
        ( --节能环保
         ( T.INDUST_STG_TYPE ='1' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('C') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('C') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('C') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         --新一代信息技术
         or
           ( T.INDUST_STG_TYPE ='2' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('D') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('D') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('D') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         OR
         --生物产业
           ( T.INDUST_STG_TYPE ='3' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('E') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('E') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('E') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         OR
         --战略性新兴产业:高端装备制造
             ( T.INDUST_STG_TYPE ='4' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('F') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('F') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('F') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         ---战略性新兴产业:新能源
         OR
              ( T.INDUST_STG_TYPE ='5' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('G') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('G') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('G') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         --战略性新兴产业:新材料
         OR( T.INDUST_STG_TYPE ='6' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('H') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('H') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('H') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         -----战略性新兴产业:新能源汽车
        OR  ( T.INDUST_STG_TYPE ='7' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('I') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('I') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('I') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         ---战略性新兴产业:数字创意
         OR ( T.INDUST_STG_TYPE ='8' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('J') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('J') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('J') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         ---战略性新兴产业:相关服务
         OR   ( T.INDUST_STG_TYPE ='9' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('K') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('K') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('K') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         )
         )

                   )
             GROUP BY CASE
                         WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                          SUBSTR(T.ORG_NUM, 1, 2)
                         ELSE
                          '99'
                       END

            UNION
            SELECT FIELD_TYPE, BALANCE_SUM, INT_RATE_WA, GET_LOAN_NUM, ORG_CODE
              FROM PBOCD_DATACORE.KJDK_TMP01 WHERE FLAG = 'KJDK')
     GROUP BY NBJGH, FIELD_TYPE
     ORDER BY NBJGH, FIELD_TYPE;

  COMMIT;

  --插入T13_逐笔报送数据 改动时需同步修改发生表
  INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLKJDK
    (DATA_DATE, -- 数据日期
     FIELD_TYPE, -- 字段类别
     ORG_CODE, -- 金融机构代码
     ORG_NUM, -- 内部机构号
     CONTRACT_CODE, -- 贷款合同编码
     LOAN_NUM, -- 贷款借据编码
     BILL_NUM, -- 票据编号
     TECH_INNO_FLG, -- 是否国家技术创新示范企业贷款
     MFG_TOP_FLG, -- 是否制造业单项冠军企业贷款
     HIGH_TECH_FLG, -- 是否高技术制造业贷款
     HIGH_TECH_TYPE, -- 高技术制造业贷款类型
     SERVICE_TECH_FLG, -- 是否高技术服务业贷款
     SERVICE_TECH_TYPE, -- 高技术服务业贷款类型
     EMERGING_FLG, -- 是否战略性新兴产业贷款
     EMERGING_TYPE, -- 战略性新兴产业贷款类型
     IP_FLG, -- 是否知识产权（专利）密集型产业贷款
     IP_TYPE, -- 知识产权（专利）密集型产业贷款类型
     BIZ_TYPE, -- 业务类别
     REPORT_ID, -- ID
     CJRQ, -- 采集日期
     NBJGH, -- 内部机构号
     BIZ_LINE_ID, -- 业务条线ID
     VERIFY_STATUS, -- 校验状态
     BSCJRQ, -- 报送采集日期
     FRNBJGH, --法人内部机构号
     CUST_ID, --客户号
     CUST_NAME, --客户名
     LOAN_ACCT_BAL, --贷款余额
     CURR_CD, --币种
     LOAN_ACCT_BAL_RMB, --贷款余额折人民币
     DRAWDOWN_AMT, --放款金额
     DISCOUNT_INTEREST  --贴现利息
     )

    SELECT /*+PARALLEL(4)*/
     VS_TEXT AS DATA_DATE, --数据日期
     'T13', --字段类别
     NVL(OB.ID_NO, OB.UP_ID_NO), --金融机构代码
     T.ORG_NUM, --内部机构号
     CASE
       WHEN B.BILL_NUM IS NULL THEN
        T.ACCT_NUM
       ELSE
        '0'
     END, --贷款合同编码
     CASE
       WHEN B.BILL_NUM IS NULL THEN
        T.LOAN_NUM
       ELSE
        '0'
     END, --贷款借据编码
     CASE
       WHEN B.BILL_NUM IS NOT NULL THEN
        T.ACCT_NUM || T.DRAFT_RNG
       ELSE
        '0'
     END, --票据编号

     NULL, --是否国家技术创新示范企业贷款
     NULL, --是否制造业单项冠军企业贷款

     CASE
       WHEN (--完全复制S72逻辑 312-403行
                 t.ITEM_CD not like '130102%' --以摊余成本计量的转贴现
                 and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现

                 --[2025-12-11] [周立鹏] [JLBA202510150005_关于票据系统的票交所票据标识功能改造的需求][李楠] 加入票据 高技术制造业、高技术服务业、知识产权 取数逻辑
                 --AND nvl(C.HIGH_TECH_MNFT,'0') <>'0' --高技术制造业 --alter by shiyu 20241029  JLBA202409030006
                 AND (( NVL(C.HIGH_TECH_MNFT,'0') <>'0'  --高技术制造业  --alter by shiyu 20241028
                        AND T.ITEM_CD NOT  LIKE '1301%' )
                     OR (SUBSTR(T.HIGH_TECH_MNFT,1,2) IN ('01','02','03','04','05','06') AND T.ITEM_CD LIKE '1301%' ))
                 
                 AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
                 AND T.FUND_USE_LOC_CD = 'I'
                 AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
                 AND t.ACCT_TYP NOT LIKE '90%'
                 and t.CANCEL_FLG <> 'Y'
         AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让

       ) THEN
        '1'
       ELSE
        '0'
     END, --是否高技术制造业贷款
     CASE
       when t.ITEM_CD not like '130102%'     --以摊余成本计量的转贴现
            and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现
            AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
            AND T.FUND_USE_LOC_CD = 'I'
            AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
            AND t.ACCT_TYP NOT LIKE '90%'
            and t.CANCEL_FLG <> 'Y'
      AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
            AND  (C.HIGH_TECH_MNFT ='C01' or substr(t.high_tech_mnft,1,2)='01') then 'HTP01'--医药制造业
       when t.ITEM_CD not like '130102%'     --以摊余成本计量的转贴现
            and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现
            AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
            AND T.FUND_USE_LOC_CD = 'I'
            AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
            AND t.ACCT_TYP NOT LIKE '90%'
            and t.CANCEL_FLG <> 'Y'
      AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
            AND  (C.HIGH_TECH_MNFT ='C02' or substr(t.high_tech_mnft,1,2)='02') then 'HTP02'--2.航空、航天器及设备制造业
       when t.ITEM_CD not like '130102%' --以摊余成本计量的转贴现
            and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现
            AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
            AND T.FUND_USE_LOC_CD = 'I'
            AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
            AND t.ACCT_TYP NOT LIKE '90%'
            and t.CANCEL_FLG <> 'Y'
      AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
            AND  (C.HIGH_TECH_MNFT ='C03' or substr(t.high_tech_mnft,1,2)='03')
                                       then 'HTP03'--3.电子及通信设备制造业
     when t.ITEM_CD not like '130102%' --以摊余成本计量的转贴现
            and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现
            AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
            AND T.FUND_USE_LOC_CD = 'I'
            AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
            AND t.ACCT_TYP NOT LIKE '90%'
            and t.CANCEL_FLG <> 'Y'
      AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
            AND  (C.HIGH_TECH_MNFT ='C04' or substr(t.high_tech_mnft,1,2)='04')
                                       then 'HTP04'--4.计算机及办公设备制造业
     when t.ITEM_CD not like '130102%' --以摊余成本计量的转贴现
            and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现
            AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
            AND T.FUND_USE_LOC_CD = 'I'
            AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
            AND t.ACCT_TYP NOT LIKE '90%'
            and t.CANCEL_FLG <> 'Y'
      AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
            AND  (C.HIGH_TECH_MNFT ='C05' or substr(t.high_tech_mnft,1,2)='05')
                                       then 'HTP05' --5.医疗仪器设备及仪器仪表制造业
     when t.ITEM_CD not like '130102%' --以摊余成本计量的转贴现
            and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现
            AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
            AND T.FUND_USE_LOC_CD = 'I'
            AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
            AND t.ACCT_TYP NOT LIKE '90%'
            and t.CANCEL_FLG <> 'Y'
      AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
            AND  (C.HIGH_TECH_MNFT ='C06'  or substr(t.high_tech_mnft,1,2)='06') then 'HTP06'--6.信息化学品制造业
     END, --高技术制造业贷款类型
     CASE
       WHEN T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
         AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
               AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
               AND T.ACCT_TYP NOT LIKE '90%'
              --[2025-12-11] [周立鹏] [JLBA202510150005_关于票据系统的票交所票据标识功能改造的需求][李楠] 加入票据 高技术制造业、高技术服务业、知识产权 取数逻辑
              --AND NVL(C.HIGH_TECH_SRVE,'0') <>'0'
              AND (( NVL(C.HIGH_TECH_SRVE,'0') <>'0' AND T.ITEM_CD NOT  LIKE '1301%' )
                     OR (SUBSTR(T.HIGH_TECH_SRVE,1,1) IN ('1','2','3','4','5','6','7','8') AND T.ITEM_CD LIKE '1301%' ))--高技术服务业
               THEN
        '1'
       ELSE
        '0'
     END, --是否高技术服务业贷款
     CASE
       WHEN T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
         AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
               AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
               AND T.ACCT_TYP NOT LIKE '90%'
               AND SUBSTR(M2.HYDL, 1, 3) = 'HTS'
                THEN
        M2.HYDL
     END, --高技术服务业贷款类型
     CASE
       WHEN T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
         AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
               AND T.ACCT_TYP NOT LIKE '90%'
               AND( --节能环保

         ( T.INDUST_STG_TYPE ='1' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('C') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('C') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('C') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         --新一代信息技术
         or
           ( T.INDUST_STG_TYPE ='2' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('D') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('D') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('D') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         OR
         --生物产业
           ( T.INDUST_STG_TYPE ='3' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('E') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('E') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('E') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         OR
         --战略性新兴产业:高端装备制造
             ( T.INDUST_STG_TYPE ='4' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('F') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('F') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('F') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         ---战略性新兴产业:新能源
         OR
              ( T.INDUST_STG_TYPE ='5' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('G') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('G') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('G') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         --战略性新兴产业:新材料
         OR( T.INDUST_STG_TYPE ='6' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('H') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('H') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('H') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         -----战略性新兴产业:新能源汽车
        OR  ( T.INDUST_STG_TYPE ='7' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('I') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('I') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('I') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         ---战略性新兴产业:数字创意
         OR ( T.INDUST_STG_TYPE ='8' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('J') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('J') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('J') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         ---战略性新兴产业:相关服务
         OR   ( T.INDUST_STG_TYPE ='9' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('K') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('K') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('K') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         )  THEN
        '1'
       ELSE
        '0'
     END, --是否战略性新兴产业贷款
     CASE WHEN
       T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
         AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
               AND T.ACCT_TYP NOT LIKE '90%'
               AND
       ( --节能环保

         ( T.INDUST_STG_TYPE ='1' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('C') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('C') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('C') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         --新一代信息技术
         or
           ( T.INDUST_STG_TYPE ='2' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('D') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('D') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('D') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         OR
         --生物产业
           ( T.INDUST_STG_TYPE ='3' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('E') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('E') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('E') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         OR
         --战略性新兴产业:高端装备制造
             ( T.INDUST_STG_TYPE ='4' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('F') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('F') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('F') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         ---战略性新兴产业:新能源
         OR
              ( T.INDUST_STG_TYPE ='5' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('G') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('G') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('G') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         --战略性新兴产业:新材料
         OR( T.INDUST_STG_TYPE ='6' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('H') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('H') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('H') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         -----战略性新兴产业:新能源汽车
        OR  ( T.INDUST_STG_TYPE ='7' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('I') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('I') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('I') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         ---战略性新兴产业:数字创意
         OR ( T.INDUST_STG_TYPE ='8' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('J') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('J') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('J') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         ---战略性新兴产业:相关服务
         OR   ( T.INDUST_STG_TYPE ='9' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('K') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('K') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('K') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         ) THEN
     DECODE(NVL(T.INDUST_STG_TYPE, '#'),'1','SE07',
                                        '2','SE01',
                                        '3','SE04',
                                        '4','SE02',
                                        '5','SE06',
                                        '6','SE03',
                                        '7','SE05',
                                        '8','SE08',
                                        '9','SE09') END, --战略性新兴产业贷款类型
     CASE
       WHEN /*PA-知识产权（专利）密集型产业*/
       (--完全复制G0107逻辑 1941-1946行
         (T.FUND_USE_LOC_CD = 'I'
         AND T.ACCT_TYP NOT LIKE '0301%'
         AND T.ACCT_TYP NOT LIKE '90%'
         AND T.ACCT_STS <> '3'
         AND T.CANCEL_FLG = 'N'
     AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
         AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
         AND LENGTHB(T.ACCT_NUM) < 36
         AND T.ACCT_TYP NOT LIKE '0301%' --SHIWENBO BY 20170316-12901 单独取直贴
         AND nvl(C.PANT_DENS_INDU,'0') <> '0' --知识产权（专利）密集型产业 --ALTER BY SHIYU 20241029
          )
         OR
         (T.FUND_USE_LOC_CD = 'I'
         AND T.CANCEL_FLG = 'N'
     AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
         AND LENGTHB(T.ACCT_NUM) < 36
         AND (T.ITEM_CD LIKE '130101%' OR T.ITEM_CD LIKE  '130104%') -- AND ITEM_CD LIKE '130101%'AND ITEM_CD LIKE  '130104%' -- 20221029 UPDATE BY WANGKUI

         --[2025-12-11] [周立鹏] [JLBA202510150005_关于票据系统的票交所票据标识功能改造的需求][李楠] 加入票据 高技术制造业、高技术服务业、知识产权 取数逻辑
         --AND nvl(C.PANT_DENS_INDU,'0') <> '0' --知识产权（专利）密集型产业 --ALTER BY SHIYU 20241029
         AND SUBSTR(T.PANT_DENS_INDU,1,2) IN ('01','02','03','04','05','06','07') --知识产权（专利）密集型产业
         
          )
        ) THEN
        '1'
       ELSE
        '0'
     END, --是否知识产权(专利)密集型产业贷款
     CASE
       WHEN /*PA-知识产权（专利）密集型产业*/
       (--完全复制G0107逻辑 1941-1946行
         (T.FUND_USE_LOC_CD = 'I'
         AND T.ACCT_TYP NOT LIKE '0301%'
         AND T.ACCT_TYP NOT LIKE '90%'
         AND T.ACCT_STS <> '3'
         AND T.CANCEL_FLG = 'N'
     AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
         AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
         AND LENGTHB(T.ACCT_NUM) < 36
         AND T.ACCT_TYP NOT LIKE '0301%' --SHIWENBO BY 20170316-12901 单独取直贴
        AND nvl(C.PANT_DENS_INDU,'0') <> '0' --知识产权（专利）密集型产业 --ALTER BY SHIYU 20241029
          )
         OR
         (T.FUND_USE_LOC_CD = 'I'
         AND T.CANCEL_FLG = 'N'
     AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
         AND LENGTHB(T.ACCT_NUM) < 36
         AND (T.ITEM_CD LIKE '130101%' OR T.ITEM_CD LIKE  '130104%') -- AND ITEM_CD LIKE '130101%'AND ITEM_CD LIKE  '130104%' -- 20221029 UPDATE BY WANGKUI
         --[2025-12-11] [周立鹏] [JLBA202510150005_关于票据系统的票交所票据标识功能改造的需求][李楠] 加入票据 高技术制造业、高技术服务业、知识产权 取数逻辑
         --AND nvl(C.PANT_DENS_INDU,'0') <> '0' --知识产权（专利）密集型产业 --ALTER BY SHIYU 20241029
         AND SUBSTR(T.PANT_DENS_INDU,1,2) IN ('01','02','03','04','05','06','07') --知识产权（专利）密集型产业
         
          )
        )
        AND SUBSTR(M3.HYDL, 1, 2) = 'PA' THEN
        M3.HYDL
     END, --知识产权(专利)密集型产业贷款类型

     --[2025-03-27] [周立鹏] [JLBA202502130004_制度升级2025][李楠] 新增业务类别字段
     CASE
       WHEN B.BILL_NUM IS NULL THEN
        'C01' --单位贷款
       ELSE
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
     T.LOAN_ACCT_BAL * U.CCY_RATE,--贷款余额折人民币
     T.DRAWDOWN_AMT, --放款金额
     T.DISCOUNT_INTEREST --贴现利息
      FROM PBOCD_DATACORE.PBOCD_JS_201_HDACLKJDK_LOAN T --贷款借据信息表
     INNER JOIN SMTMODS.L_CUST_C A --对公客户信息表
        ON A.DATA_DATE = IS_DATE
       AND A.CUST_ID = T.CUST_ID
       AND A.CUST_TYP <> '3' --后面条件剔除个体工商户了
     LEFT JOIN SMTMODS.L_CUST_ALL A2
        ON A2.DATA_DATE = IS_DATE
       AND A2.CUST_ID = T.CUST_ID
      LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B
        ON T.ACCT_NUM = B.BILL_NUM
       AND B.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_PUBL_RATE U --汇率表
        ON U.DATA_DATE = IS_DATE
       AND U.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD')
       AND U.BASIC_CCY = T.CURR_CD --基准币种
       AND U.FORWARD_CCY = 'CNY' --折算币种
      LEFT JOIN SMTMODS.L_AGRE_LOAN_CONTRACT C
        ON T.ACCT_NUM = C.CONTRACT_NUM
        AND C.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.PUB_KJDK M2
        ON SUBSTR(M2.HYDL, 1, 3) = 'HTS' --高技术服务业
       --[2025-12-11] [周立鹏] [JLBA202510150005_关于票据系统的票交所票据标识功能改造的需求][李楠] 加入票据 高技术制造业、高技术服务业、知识产权 取数逻辑
       AND (CASE WHEN NVL(C.HIGH_TECH_SRVE,'0') <>'0' AND T.ITEM_CD NOT  LIKE '1301%' THEN C.HIGH_TECH_SRVE
                 WHEN SUBSTR(T.HIGH_TECH_SRVE,1,1) IN ('1','2','3','4','5','6','7','8') AND T.ITEM_CD LIKE '1301%' THEN SUBSTR(T.HIGH_TECH_SRVE,1,1) END
            ) = M2.CODE
      LEFT JOIN SMTMODS.PUB_KJDK M3
        ON SUBSTR(M3.HYDL, 1, 2) = 'PA'
       AND (CASE WHEN nvl(C.PANT_DENS_INDU,'0') <>'0' AND T.ITEM_CD NOT  LIKE '1301%' THEN C.PANT_DENS_INDU
                 WHEN SUBSTR(T.PANT_DENS_INDU,1,2) IN ('01','02','03','04','05','06','07') AND T.ITEM_CD LIKE '1301%' THEN SUBSTR(T.PANT_DENS_INDU,1,2) END
            ) = M3.CODE --知识产权（专利）密集型产业
      LEFT JOIN L_PUBL_ORG_BRA_TMP OB --金数机构表
        ON OB.ORG_NUM = T.ORG_NUM
       AND OB.DATA_DATE = IS_DATE
     WHERE T.DATA_DATE = IS_DATE
       AND T.LOAN_ACCT_BAL > 0
       AND  (

       (T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
         AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
               AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
               AND T.ACCT_TYP NOT LIKE '90%' --不含委托贷款
               --[2025-12-11] [周立鹏] [JLBA202510150005_关于票据系统的票交所票据标识功能改造的需求][李楠] 加入票据 高技术制造业、高技术服务业、知识产权 取数逻辑
               --AND nvl(C.HIGH_TECH_SRVE,'0') <>'0'  --高技术服务业--ALTER BY SHIYU 20241029 JLBA202409030006
               AND (( NVL(C.HIGH_TECH_SRVE,'0') <>'0' AND T.ITEM_CD NOT  LIKE '1301%' )
                     OR (SUBSTR(T.HIGH_TECH_SRVE,1,1) IN ('1','2','3','4','5','6','7','8') AND T.ITEM_CD LIKE '1301%' ))--高技术服务业
        )
        /*PA-知识产权（专利）密集型产业*/
       OR(--完全复制G0107逻辑 1941-1946行
         (T.FUND_USE_LOC_CD = 'I'
         AND T.ACCT_TYP NOT LIKE '0301%'
         AND T.ACCT_TYP NOT LIKE '90%'
         AND T.ACCT_STS <> '3'
         AND T.CANCEL_FLG = 'N'
     AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
         AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
         AND LENGTHB(T.ACCT_NUM) < 36
         AND T.ACCT_TYP NOT LIKE '0301%' --SHIWENBO BY 20170316-12901 单独取直贴
        AND nvl(C.PANT_DENS_INDU,'0') <>'0' --知识产权（专利）密集型产业 --ALTER BY SHIYU 20241029 JLBA202409030006
          )
         OR
         (T.FUND_USE_LOC_CD = 'I'
         AND T.CANCEL_FLG = 'N'
     AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
         AND LENGTHB(T.ACCT_NUM) < 36
         AND (T.ITEM_CD LIKE '130101%' OR T.ITEM_CD LIKE  '130104%')
         --[2025-12-11] [周立鹏] [JLBA202510150005_关于票据系统的票交所票据标识功能改造的需求][李楠] 加入票据 高技术制造业、高技术服务业、知识产权 取数逻辑
         --AND nvl(C.PANT_DENS_INDU,'0') <>'0'--知识产权（专利）密集型产业 --ALTER BY SHIYU 20241029 JLBA202409030006
         AND SUBSTR(T.PANT_DENS_INDU,1,2) IN ('01','02','03','04','05','06','07') --知识产权（专利）密集型产业
          )
        )


         /*HTP-高技术制造业*/
        OR (--完全复制S72逻辑 312-403行
                 t.ITEM_CD not like '130102%' --以摊余成本计量的转贴现
                 and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现
                 --[2025-12-11] [周立鹏] [JLBA202510150005_关于票据系统的票交所票据标识功能改造的需求][李楠] 加入票据 高技术制造业、高技术服务业、知识产权 取数逻辑
                 --AND nvl(C.HIGH_TECH_MNFT,'0') <>'0' --高技术制造业 --alter by shiyu 20241029 JLBA202409030006
                 AND (( NVL(C.HIGH_TECH_MNFT,'0') <>'0'  --高技术制造业  --alter by shiyu 20241028
                        AND T.ITEM_CD NOT  LIKE '1301%' )
                     OR (SUBSTR(T.HIGH_TECH_MNFT,1,2) IN ('01','02','03','04','05','06') AND T.ITEM_CD LIKE '1301%' ))
                     
                 AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
                 AND T.FUND_USE_LOC_CD = 'I'
                 AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
                 AND t.ACCT_TYP NOT LIKE '90%'
                 and t.CANCEL_FLG <> 'Y'
         AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让

       )


       /*战略性新兴产业*/
        OR

        (T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
         AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
               AND T.ACCT_TYP NOT LIKE '90%'
               AND
        ( --节能环保
         ( T.INDUST_STG_TYPE ='1' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('C') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('C') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('C') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         --新一代信息技术
         or
           ( T.INDUST_STG_TYPE ='2' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('D') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('D') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('D') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         OR
         --生物产业
           ( T.INDUST_STG_TYPE ='3' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('E') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('E') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('E') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         OR
         --战略性新兴产业:高端装备制造
             ( T.INDUST_STG_TYPE ='4' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('F') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('F') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('F') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         ---战略性新兴产业:新能源
         OR
              ( T.INDUST_STG_TYPE ='5' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('G') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('G') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('G') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         --战略性新兴产业:新材料
         OR( T.INDUST_STG_TYPE ='6' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('H') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('H') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('H') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         -----战略性新兴产业:新能源汽车
        OR  ( T.INDUST_STG_TYPE ='7' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('I') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('I') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('I') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         ---战略性新兴产业:数字创意
         OR ( T.INDUST_STG_TYPE ='8' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('J') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('J') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('J') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         ---战略性新兴产业:相关服务
         OR   ( T.INDUST_STG_TYPE ='9' AND
         ( T.LOAN_PURPOSE_CD in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('K') AND LENGTH(LOAN_PURPOSE_CD)=5)
           or substr(T.LOAN_PURPOSE_CD,1,4) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('K') AND LENGTH(LOAN_PURPOSE_CD)=4)
           or substr(T.LOAN_PURPOSE_CD,1,3) in (select distinct LOAN_PURPOSE_CD from SMTMODS.INTO_FIELD_INDEX where COLUMN_OODE in ('K') AND LENGTH(LOAN_PURPOSE_CD)=3))
         )
         )
         )

                   );

  COMMIT;

--[2025-03-27] [周立鹏] [JLBA202502130004_制度升级2025][李楠] 已经在前面注释掉了T01-T07的加工逻辑，此处没用了
  /*--以下类别暂缓报送
  UPDATE PBOCD_DATACORE.PBOCD_JS_201_HDACLKJDK
     SET BALANCE_SUM = NULL, INT_RATE_WA = NULL, GET_LOAN_NUM = NULL
   WHERE CJRQ = IS_DATE
     AND FIELD_TYPE IN ('T01', 'T02', 'T03', 'T04', 'T07');
  COMMIT;*/
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
