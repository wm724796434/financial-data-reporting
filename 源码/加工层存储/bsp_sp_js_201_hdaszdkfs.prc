CREATE OR REPLACE PROCEDURE BSP_SP_JS_201_HDASZDKFS(IS_DATE        IN VARCHAR2,
                                                    OI_RETCODE     OUT INTEGER,
                                                    OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_201_HDASZDKFS
  -- 用途:生成接口表 PBOCD_JS_201_HDASZDKFS  存量数字贷款信息表
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
  VS_PROCEDURE_NAME := 'BSP_SP_JS_201_HDASZDKFS';

  --开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------
  --新建/清理分区
  SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_201_HDASZDKFS', OI_RETCODE);
  -------------------------------------------------------------------------

  EXECUTE IMMEDIATE 'TRUNCATE TABLE PBOCD_DATACORE.PBOCD_JS_201_HDASZDKFS_TMP1';

  --将数字贷款插入到临时表 改动时需同步修改发生表
  INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDASZDKFS_TMP1
    SELECT A.LOAN_NUM,
           A.ACCT_NUM,
           A.DRAFT_RNG,
           A.ACCT_TYP,
           A.LOAN_ACCT_BAL,
           A.DRAWDOWN_AMT,
           A.DISCOUNT_INTEREST,
           A.CUST_ID,
           A.ORG_NUM,
           A.DATA_DATE,
           A.CURR_CD,
           A.REAL_INT_RAT,
           D.DIGITAL_ECONOMY_INDUSTRY
      FROM SMTMODS.L_ACCT_LOAN A
     INNER JOIN SMTMODS.L_CUST_C C
        ON A.CUST_ID = C.CUST_ID
       AND C.DATA_DATE = IS_DATE
       AND C.CUST_TYP <> '3' --去除个体工商户
     INNER JOIN SMTMODS.L_AGRE_LOAN_CONTRACT D
        ON D.DATA_DATE = IS_DATE
       AND A.ACCT_NUM = D.CONTRACT_NUM
       AND SUBSTR(D.DIGITAL_ECONOMY_INDUSTRY, 1, 2) IN
           ('01', '02', '03', '04')
     WHERE A.FUND_USE_LOC_CD = 'I'
       AND A.ACCT_TYP NOT LIKE '0301%'
       AND A.ACCT_TYP NOT LIKE '90%'
       AND A.DATA_DATE = IS_DATE
       --AND A.ACCT_STS <> '3'
       --AND A.CANCEL_FLG = 'N'
       AND (A.ACCT_TYP NOT LIKE '01%' OR A.ACCT_TYP LIKE '0102%')
       AND LENGTHB(A.ACCT_NUM) < 36
       AND A.ACCT_TYP NOT LIKE '0301%' --SHIWENBO BY 20170316-12901 单独取直贴
       --AND A.LOAN_STOCKEN_DATE IS NULL --add by haorui 20250228 JLBA202408200012 资产未转让
       AND TO_CHAR(A.DRAWDOWN_DT, 'YYYYMM') = SUBSTR(IS_DATE, 1, 6)
    AND NOT EXISTS(-- 剔除当天发生当天收回的垫款
         SELECT 1 FROM SMTMODS.L_ACCT_LOAN A2
                     WHERE A2.DATA_DATE = IS_DATE
                       AND SUBSTR(A2.ITEM_CD, 1, 4) IN ('1306')
                       AND SUBSTR(TO_CHAR(A2.DRAWDOWN_DT, 'YYYYMMDD'), 1, 6) = SUBSTR(IS_DATE, 1, 6)
                       AND A2.DRAWDOWN_DT = A2.FINISH_DT
                       AND A2.LOAN_ACCT_BAL = 0
                       AND A.LOAN_NUM=A2.LOAN_NUM)
    UNION ALL
    SELECT A.LOAN_NUM,
           A.ACCT_NUM,
           A.DRAFT_RNG,
           A.ACCT_TYP,
           A.LOAN_ACCT_BAL,
           A.DRAWDOWN_AMT,
           A.DISCOUNT_INTEREST,
           A.CUST_ID,
           A.ORG_NUM,
           A.DATA_DATE,
           A.CURR_CD,
           A.REAL_INT_RAT,
           A.DIGITAL_ECONOMY_INDUSTRY
      FROM SMTMODS.L_ACCT_LOAN A
     INNER JOIN SMTMODS.L_CUST_C C
        ON A.CUST_ID = C.CUST_ID
       AND C.DATA_DATE = IS_DATE
       AND C.CUST_TYP <> '3' --去除个体工商户
     WHERE FUND_USE_LOC_CD = 'I'
       AND A.DATA_DATE = IS_DATE
       AND LENGTHB(A.ACCT_NUM) < 360
       --AND A.CANCEL_FLG = 'N'
       AND SUBSTR(A.ITEM_CD, 1, 6) IN ('130101', '130104') --直贴
       --AND A.LOAN_STOCKEN_DATE IS NULL --add by haorui 20250228 JLBA202408200012 资产未转让
       AND TO_CHAR(A.DRAWDOWN_DT, 'YYYYMM') = SUBSTR(IS_DATE, 1, 6)
       AND SUBSTR(A.DIGITAL_ECONOMY_INDUSTRY, 1, 2) IN
           ('01', '02', '03', '04')
     
    UNION ALL
    SELECT A1.LOAN_NUM,
           A1.ACCT_NUM,
           A1.DRAFT_RNG,
           A1.ACCT_TYP,
           A.LOAN_ACCT_BAL,
           A.DRAWDOWN_AMT,
           A.DISCOUNT_INTEREST,
           A1.CUST_ID,
           A.ORG_NUM,
           A1.DATA_DATE,
           A1.CURR_CD,
           A1.REAL_INT_RAT,
           A1.DIGITAL_ECONOMY_INDUSTRY
      FROM SMTMODS.L_ACCT_LOAN A
      INNER JOIN SMTMODS.L_ACCT_LOAN A1
        ON A1.DATA_DATE = IS_DATE
       AND A.ACCT_NUM || A.DRAFT_RNG = A1.ACCT_NUM || A1.DRAFT_RNG
       AND SUBSTR(A1.ITEM_CD, 1, 6) IN ('130101', '130104')
     INNER JOIN SMTMODS.L_CUST_C C
        ON A.CUST_ID = C.CUST_ID
       AND C.DATA_DATE = IS_DATE
       AND C.CUST_TYP <> '3' --去除个体工商户
     
     WHERE A1.FUND_USE_LOC_CD = 'I'
       AND A1.DATA_DATE = IS_DATE
       AND LENGTHB(A1.ACCT_NUM) < 360
       --AND A1.CANCEL_FLG = 'N'
       AND SUBSTR(A.ITEM_CD, 1, 6) IN ('130102', '130105') --直转
       --AND A1.LOAN_STOCKEN_DATE IS NULL --add by haorui 20250228 JLBA202408200012 资产未转让
       AND TO_CHAR(A.DRAWDOWN_DT, 'YYYYMM') = SUBSTR(IS_DATE, 1, 6)
       AND SUBSTR(A1.DIGITAL_ECONOMY_INDUSTRY, 1, 2) IN
           ('01', '02', '03', '04');
  COMMIT;

  --插入T01汇总报送数据 改动时需同步修改发生表
  INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDASZDKFS
    (DATA_DATE, -- 数据日期
     FIELD_TYPE, -- 字段类别
     BALANCE_SUM, -- 贷款汇总金额
     INT_RATE_WA, -- 贷款汇总加权平均利率
     GET_LOAN_NUM, -- 贷款汇总获贷企业数量
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
      FROM (SELECT 'T01' AS FIELD_TYPE, --字段类别 --数字经济核心产业贷款汇总
                   SUM((CASE
                         WHEN A.ACCT_TYP NOT LIKE '0301%' THEN
                          A.LOAN_ACCT_BAL
                         ELSE
                          A.DRAWDOWN_AMT - NVL(A.DISCOUNT_INTEREST, 0)
                       END) * B.CCY_RATE) AS BALANCE_SUM, --贷款汇总金额
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
                   END INT_RATE_WA, --贷款汇总加权平均利率
                   COUNT(DISTINCT A.CUST_ID) AS GET_LOAN_NUM, --贷款汇总获贷企业数量
                   CASE
                     WHEN SUBSTR(A.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                      SUBSTR(A.ORG_NUM, 1, 2)
                     ELSE
                      '99'
                   END AS NBJGH --内部机构号
              FROM PBOCD_DATACORE.PBOCD_JS_201_HDASZDKFS_TMP1 A
              LEFT JOIN SMTMODS.L_PUBL_RATE B
                ON B.DATA_DATE = IS_DATE
               AND B.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD')
               AND A.CURR_CD = B.BASIC_CCY
               AND B.FORWARD_CCY = 'CNY'
            
             GROUP BY CASE
                        WHEN SUBSTR(A.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                         SUBSTR(A.ORG_NUM, 1, 2)
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
             WHERE FLAG = 'SZDK'
               AND FIELD_TYPE = 'T01'
            
            )
     GROUP BY NBJGH, FIELD_TYPE
     ORDER BY NBJGH, FIELD_TYPE;
  COMMIT;

  --插入T02-T05汇总报送数据 改动时需同步修改发生表
  INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDASZDKFS
    (DATA_DATE, -- 数据日期
     FIELD_TYPE, -- 字段类别
     BALANCE_SUM, -- 贷款汇总金额
     INT_RATE_WA, -- 贷款汇总加权平均利率
     GET_LOAN_NUM, -- 贷款汇总获贷企业数量
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
                     WHEN /*A.FLAG = '5.1' OR */
                      SUBSTR(A.FLAG, 1, 2) = '01' THEN
                      'T02' --数字产品制造业贷款汇总
                     WHEN /*A.FLAG = '5.2' OR */
                      SUBSTR(A.FLAG, 1, 2) = '02' THEN
                      'T03' --数字产品服务业贷款汇总
                     WHEN /*A.FLAG = '5.3' OR */
                      SUBSTR(A.FLAG, 1, 2) = '03' THEN
                      'T04' --数字技术应用业贷款汇总
                     WHEN /*A.FLAG = '5.4' OR */
                      SUBSTR(A.FLAG, 1, 2) = '04' THEN
                      'T05' --数字要素驱动业贷款汇总
                   END AS FIELD_TYPE, --字段类别
                   SUM((CASE
                         WHEN A.ACCT_TYP NOT LIKE '0301%' THEN
                          A.LOAN_ACCT_BAL
                         ELSE
                          A.DRAWDOWN_AMT - NVL(A.DISCOUNT_INTEREST, 0)
                       END) * B.CCY_RATE) AS BALANCE_SUM, --贷款汇总金额
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
                   END INT_RATE_WA, --贷款汇总加权平均利率
                   COUNT(DISTINCT A.CUST_ID) AS GET_LOAN_NUM, --贷款汇总获贷企业数量
                   CASE
                     WHEN SUBSTR(A.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                      SUBSTR(A.ORG_NUM, 1, 2)
                     ELSE
                      '99'
                   END AS NBJGH --内部机构号
              FROM PBOCD_DATACORE.PBOCD_JS_201_HDASZDKFS_TMP1 A
              LEFT JOIN SMTMODS.L_PUBL_RATE B
                ON B.DATA_DATE = IS_DATE
               AND B.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD')
               AND A.CURR_CD = B.BASIC_CCY
               AND B.FORWARD_CCY = 'CNY'
            
             GROUP BY CASE
                        WHEN SUBSTR(A.FLAG, 1, 2) = '01' THEN
                         'T02' --数字产品制造业贷款汇总
                        WHEN SUBSTR(A.FLAG, 1, 2) = '02' THEN
                         'T03' --数字产品服务业贷款汇总
                        WHEN SUBSTR(A.FLAG, 1, 2) = '03' THEN
                         'T04' --数字技术应用业贷款汇总
                        WHEN SUBSTR(A.FLAG, 1, 2) = '04' THEN
                         'T05' --数字要素驱动业贷款汇总
                      END, --字段类别
                      CASE
                        WHEN SUBSTR(A.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                         SUBSTR(A.ORG_NUM, 1, 2)
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
             WHERE FLAG = 'SZDK'
               AND FIELD_TYPE IN ('T02','T03','T04','T05','T06')
            
            )
     GROUP BY NBJGH, FIELD_TYPE
     ORDER BY NBJGH, FIELD_TYPE;
  COMMIT;

  --插入T99_逐笔报送数据 改动时需同步修改发生表
  INSERT INTO PBOCD_DATACORE.PBOCD_JS_201_HDASZDKFS
    (DATA_DATE, -- 数据日期
     FIELD_TYPE, -- 字段类别
     ORG_CODE, -- 金融机构代码
     ORG_NUM, -- 内部机构号
     CONTRACT_CODE, -- 贷款合同编码
     LOAN_NUM, -- 贷款借据编码
     BILL_NUM, -- 票据编号
     SERIAL_NO, -- 交易流水号
     DEIDY_LOAN_FLG, -- 是否数字经济核心产业贷款
     DEIDY_LOAN_TYPE, -- 数字经济核心产业贷款类型
     DIGI_EFF_FLG, -- 是否数字化效率提升业贷款
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
       WHEN T.ACCT_TYP NOT LIKE '0301%' THEN
        T.ACCT_NUM
       ELSE
        '0'
     END, --贷款合同编码
     CASE
       WHEN T.ACCT_TYP NOT LIKE '0301%' THEN
        T.LOAN_NUM
       ELSE
        '0'
     END, --贷款借据编码
     CASE
       WHEN T.ACCT_TYP LIKE '0301%' THEN
        T.ACCT_NUM || T.DRAFT_RNG
       ELSE
        '0'
     END, --票据编号
     '1', --交易流水号
     CASE
       WHEN /*T.FLAG IN ('5.1', '5.2', '5.3', '5.4') OR*/
            SUBSTR(T.FLAG, 1, 2) IN ('01', '02', '03', '04') THEN
        '1'
       ELSE
        '0'
     END, --是否数字经济核心产业贷款
     CASE
       WHEN SUBSTR(T.FLAG, 1, 2) = '01' THEN
        'DE01' --数字产品制造业
       WHEN SUBSTR(T.FLAG, 1, 2) = '02' THEN
        'DE02' --数字产品服务业
       WHEN SUBSTR(T.FLAG, 1, 2) = '03' THEN
        'DE03' --数字技术应用业
       WHEN SUBSTR(T.FLAG, 1, 2) = '04' THEN
        'DE04' --数字要素驱动业
     END, --数字经济核心产业贷款类型
     '0', --是否数字化效率提升业贷款  带*行业
     CASE
       WHEN T.ACCT_TYP NOT LIKE '0301%' THEN
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
     T.LOAN_ACCT_BAL * U.CCY_RATE, --贷款余额折人民币
     T.DRAWDOWN_AMT, --放款金额
     T.DISCOUNT_INTEREST --贴现利息
      FROM PBOCD_DATACORE.PBOCD_JS_201_HDASZDKFS_TMP1 T
      LEFT JOIN SMTMODS.L_CUST_ALL A2
        ON A2.DATA_DATE = IS_DATE
       AND A2.CUST_ID = T.CUST_ID
      LEFT JOIN SMTMODS.L_PUBL_RATE U --汇率表
        ON U.DATA_DATE = IS_DATE
       AND U.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD')
       AND U.BASIC_CCY = T.CURR_CD --基准币种
       AND U.FORWARD_CCY = 'CNY' --折算币种
      LEFT JOIN L_PUBL_ORG_BRA_TMP OB --金数机构表
        ON OB.ORG_NUM = T.ORG_NUM
       AND OB.DATA_DATE = IS_DATE;
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
