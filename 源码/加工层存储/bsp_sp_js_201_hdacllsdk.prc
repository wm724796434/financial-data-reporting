CREATE OR REPLACE PROCEDURE BSP_SP_JS_201_HDACLLSDK(IS_DATE        IN VARCHAR2,
                                                    OI_RETCODE     OUT INTEGER,
                                                    OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_201_HDACLLSDK
  -- 用途:生成接口表 PBOCD_JS_201_HDACLLSDK  存量绿色贷款信息表
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    需求编号：JLBA202502130004_制度升级2025 上线日期：2025-03-27，修改人：周立鹏，提出人：李楠   修改原因：新建
  --    需求编号：无需求 上线日期：2025-05-12，修改人：周立鹏，提出人：李楠   修改原因：绿贷比例改成直取，不除100了
  --    需求编号：JLBA202501210008_关于吉林银行人行大集中报表制度升级的相关需求 上线日期：2025-06-19，修改人：周立鹏，提出人：王铣   修改原因：与3327同步
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
  VS_PROCEDURE_NAME := 'BSP_SP_JS_201_HDACLLSDK';

  --开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------
  --新建/清理分区
  SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_201_HDACLLSDK', OI_RETCODE);
  -------------------------------------------------------------------------

EXECUTE IMMEDIATE 'TRUNCATE TABLE PBOCD_DATACORE.PBOCD_JS_201_HDACLLSDK_LOAN';

INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLLSDK_LOAN
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
   GREEN_CREDIT_FLAG,
   GREEN_CREDIT_USAGE,
   GREEN_CREDIT_RATIO,
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
   T1.GREEN_CREDIT_FLAG,
   T1.GREEN_CREDIT_USAGE,
   T1.GREEN_CREDIT_RATIO,
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
         T.GREEN_CREDIT_FLAG,
         T.GREEN_CREDIT_USAGE,
         T.GREEN_CREDIT_RATIO,
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

-- 20260130 制度升级
 INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLLSDK  
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
 FROM ( SELECT  CASE  WHEN A2.INLANDORRSHORE_FLG = 'N' AND T.GREEN_CREDIT_USAGE IS NOT NULL THEN 'TW00'
                      WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '1' THEN 'TNA01'
                      WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '2' THEN 'TNA02'
                      WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '3' THEN 'TNA03'
                      WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '4' THEN 'TNA04'
                      WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '5' THEN 'TNA05'
                      WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '6' THEN 'TNA06'
                      WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '7' THEN 'TNA07'
                      WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '8' THEN 'TNB'
                      WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '9' THEN 'TNC'
                       END AS FIELD_TYPE , -- 字段类别
                SUM((CASE WHEN T.ACCT_TYP NOT LIKE '0301%' THEN  T.LOAN_ACCT_BAL
                                   ELSE T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                                 END) * U.CCY_RATE) AS BALANCE_SUM, -- 贷款汇总金额
                CASE WHEN SUM(CASE WHEN T.ACCT_TYP NOT LIKE '0301%' THEN T.LOAN_ACCT_BAL
                                          ELSE T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                                        END) = 0 THEN 0
                               ELSE ROUND(SUM((CASE WHEN T.ACCT_TYP NOT LIKE '0301%' THEN  T.LOAN_ACCT_BAL
                                            ELSE T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                                          END) * T.REAL_INT_RAT) /
                                      SUM(CASE WHEN T.ACCT_TYP NOT LIKE '0301%' THEN  T.LOAN_ACCT_BAL
                                            ELSE  T.DRAWDOWN_AMT - NVL(T.DISCOUNT_INTEREST, 0)
                                          END),  5)
                               END INT_RATE_WA, -- 贷款汇总加权平均利率
                COUNT(DISTINCT T.CUST_ID) AS GET_LOAN_NUM, -- 贷款汇总户数
                CASE WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN SUBSTR(T.ORG_NUM, 1, 2)
                     ELSE  '99'
                     END AS NBJGH --内部机构号
               FROM PBOCD_DATACORE.PBOCD_JS_201_HDACLLSDK_LOAN T -- 贷款借据信息表
               --[2025-06-19] [周立鹏] [JLBA202501210008_关于吉林银行人行大集中报表制度升级的相关需求][王铣] 与3327同步
               --LEFT JOIN SMTMODS.L_CUST_ALL A2
              INNER JOIN SMTMODS.L_CUST_ALL A2
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
                AND T.GREEN_CREDIT_FLAG = '1'
                AND T.CANCEL_FLG = 'N' --剔除核销
                AND T.LOAN_ACCT_BAL > 0
                AND T.LOAN_STOCKEN_DATE IS NULL --ADD BY HAORUI 20250228 JLBA202408200012 资产未转让
                GROUP BY  CASE WHEN A2.INLANDORRSHORE_FLG = 'N' AND T.GREEN_CREDIT_USAGE IS NOT NULL THEN 'TW00'
                               WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '1' THEN 'TNA01'
                               WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '2' THEN 'TNA02'
                               WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '3' THEN 'TNA03'
                               WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '4' THEN 'TNA04'
                               WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '5' THEN 'TNA05'
                               WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '6' THEN 'TNA06'
                               WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '7' THEN 'TNA07'
                               WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '8' THEN 'TNB'
                               WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '9' THEN 'TNC'
                            END ,
                          CASE WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN  SUBSTR(T.ORG_NUM, 1, 2)
                               ELSE  '99'
                            END --内部机构号
     UNION ALL
            SELECT FIELD_TYPE,
                   BALANCE_SUM,
                   INT_RATE_WA,
                   GET_LOAN_NUM,
                   ORG_CODE
              FROM PBOCD_DATACORE.KJDK_TMP01
             WHERE FLAG = 'LSDK'        
       )
              GROUP BY NBJGH, FIELD_TYPE
              ORDER BY NBJGH, FIELD_TYPE;
    COMMIT; 
     
     
 INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDACLLSDK
    (DATA_DATE, --数据日期
     ORG_CODE, --金融机构代码
     ORG_NUM, --内部机构号
     CONTRACT_CODE, --贷款合同编码
     LOAN_NUM, --贷款借据编码
     BILL_NUM, --票据编号
     BIZ_TYPE, --业务类别
     GREEN_LOAN_RATIO, --绿色贷款比例
     REPORT_ID, --ID
     CJRQ, --采集日期
     NBJGH, --内部机构号
     BIZ_LINE_ID, --业务条线ID
     VERIFY_STATUS, --校验状态
     BSCJRQ, --报送采集日期
     FRNBJGH, --法人内部机构号
     CUST_ID, --客户号
     CUST_NAME, --客户名
     LOAN_ACCT_BAL, --贷款余额
     CURR_CD, --币种
     LOAN_ACCT_BAL_RMB, --贷款余额折人民币
     DRAWDOWN_AMT, --放款金额
     DISCOUNT_INTEREST, --贴现利息
     FIELD_TYPE,
     GREEN_LOAN_TYPE
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
        T.ACCT_NUM || T.DRAFT_RNG
       ELSE
        '0'
     END, --票据编号
     CASE
     WHEN T.ACCT_TYP LIKE '01%' OR C.CUST_TYP = '3' THEN
        'C02' --个人贷款
       WHEN SUBSTR(T.ITEM_CD, 1, 4) IN ('1303', '1305', '1306') THEN
        'C01' --单位贷款
       WHEN SUBSTR(t.ITEM_CD, 1, 6) IN ('130101', '130104') THEN
        'C03' --票据融资
     END, --业务类别
     
     --[2025-05-12] [周立鹏] [无需求][李楠] 绿贷比例改成直取，不除100了
     --ROUND(T.GREEN_CREDIT_RATIO/100,5), --备用字段1
     T.GREEN_CREDIT_RATIO AS GREEN_LOAN_RATIO, --绿色贷款比例 
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
     'T99' AS FIELD_TYPE,
      CASE WHEN A2.INLANDORRSHORE_FLG = 'N' AND T.GREEN_CREDIT_USAGE IS NOT NULL THEN 'W00'
           WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '1' THEN 'NA01'
           WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '2' THEN 'NA02'
           WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '3' THEN 'NA03'
           WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '4' THEN 'NA04'
           WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '5' THEN 'NA05'
           WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '6' THEN 'NA06'
           WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '7' THEN 'NA07'
           WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '8' THEN 'NB'
           WHEN SUBSTR(T.GREEN_CREDIT_USAGE,1,1) = '9' THEN 'NC'
       END AS GREEN_LOAN_TYPE 
      FROM PBOCD_DATACORE.PBOCD_JS_201_HDACLLSDK_LOAN T -- 贷款借据信息表
      --[2025-06-19] [周立鹏] [JLBA202501210008_关于吉林银行人行大集中报表制度升级的相关需求][王铣] 与3327同步
      --LEFT JOIN SMTMODS.L_CUST_ALL A2
      INNER JOIN SMTMODS.L_CUST_ALL A2
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
       AND T.GREEN_CREDIT_FLAG = '1'
       AND T.CANCEL_FLG = 'N' --剔除核销
       AND T.LOAN_ACCT_BAL > 0
       AND T.LOAN_STOCKEN_DATE IS NULL --ADD BY HAORUI 20250228 JLBA202408200012 资产未转让
       --[2025-06-19] [周立鹏] [JLBA202501210008_关于吉林银行人行大集中报表制度升级的相关需求][王铣] 与3327同步
       /*AND (SUBSTR(T.ITEM_CD, 1, 4) IN ('1303', '1305', '1306') --单位贷款
           OR (T.CURR_CD = 'CNY' AND T.ACCT_TYP LIKE '01%') --个人贷款
           OR (NVL(T.LOAN_ACCT_BAL, 0) + NVL(T.INT_ADJEST_AMT, 0) > 0 AND
           SUBSTR(t.ITEM_CD, 1, 6) IN ('130101', '130104')) --票据直贴
           )*/;
    
  COMMIT;
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
