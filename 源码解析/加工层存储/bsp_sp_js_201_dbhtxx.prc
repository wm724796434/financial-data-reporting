CREATE OR REPLACE PROCEDURE BSP_SP_JS_201_DBHTXX(IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_201_DBHTXX
  -- 业务域: 贷款类
  -- 用途: 生成接口表JS_201_DBHTXX--担保合同信息
  -- 参数
  --    IS_DATE 输入，传入跑批日期
  --    OI_RETCODE 输出，用来标识存储过程执行过程中是否出现异常
  -- 引用的监管集市表
  --    SMTMODS.L_ACCT_LOAN                                — 贷款借据信息表
  --    SMTMODS.L_AGRE_GUARANTEE_CONTRACT                  — 担保合同信息
  --    SMTMODS.L_AGRE_GUARANTEE_RELATION                  — 担保合同与担保信息对应关系表
  --    SMTMODS.L_AGRE_GUARANTY_INFO                       — 抵质押物详细信息
  --    SMTMODS.L_AGRE_GUA_RELATION                        — 业务合同与担保合同对应关系表
  --    SMTMODS.L_AGRE_LOAN_CONTRACT                       — 贷款合同信息表
  --    SMTMODS.L_CODE_DICTIONARY                          — L_CODE_DICTIONARY
  --    SMTMODS.L_CUST_ALL                                 — 全量客户信息表
  --    SMTMODS.L_CUST_C                                   — 对公客户补充信息表
  --    SMTMODS.L_CUST_P                                   — 对私客户补充信息表
  --    SMTMODS.L_PUBL_RATE                                — 汇率表
  -- 修改历史
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段 上线日期：2025-04-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(2000) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(100); --存储过程执行步骤标志
  VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  NUM               INTEGER;
  VS_NMONTH         varchar2(10);
BEGIN
  VS_TEXT := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_201_DBHTXX';
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');

  VS_NMONTH         := TO_CHAR(TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD') + 1),
                             'YYYYMMDD');
  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

  -------------------------------------------------------------------------

  ---清除历史数据

  EXECUTE IMMEDIATE 'TRUNCATE TABLE GUAR_CONTRACT_TMP01';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE DBHTXX_BZR_TMP01';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ACCT_LOAN_TMP01';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE  JS_102_FTYKHX_TEMP03 '; --历史移植及核销数据
  EXECUTE IMMEDIATE 'TRUNCATE TABLE DBHTXX_PLED_TEMP1';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE DBHTXX_PLED_TEMP2';

  COMMIT;

 --历史移植及核销数据
  INSERT INTO JS_102_FTYKHX_TEMP03
    (CUST_ID, BS)
    SELECT T.CUST_ID, COUNT(1) BS
      FROM SMTMODS.L_ACCT_LOAN T
     WHERE T.DATA_DATE = IS_DATE
       --AND T.ACCT_TYP NOT LIKE '90%' --不取委贷--原逻辑
       /*AND  T.HXRQ IS NOT NULL --核销贷款*/
       AND T.CANCEL_FLG='Y'--去掉核销数据
     GROUP BY T.CUST_ID;
  COMMIT;
  ---担保合同下押品总价值
  INSERT INTO DBHTXX_PLED_TEMP1(
      GUAR_CONTRACT_NUM ,  --担保合同编号
       COLL_VALUE_SUM    --押品价值总额
        )

SELECT GR.GUAR_CONTRACT_NUM,
        SUM(GI.COLL_MK_VAL) AS COLL_VALUE
       FROM SMTMODS.L_AGRE_GUARANTY_INFO GI --抵押物
     INNER join SMTMODS.L_AGRE_GUARANTEE_RELATION GR --担保合同与担保信息对应关系表
           ON GI.GUARANTEE_SERIAL_NUM = GR.GUARANTEE_SERIAL_NUM
          AND GR.DATA_DATE = IS_DATE AND GR.REL_STATUS = 'Y'
        WHERE GI.DATA_DATE = IS_DATE AND GI.COLL_STATUS = 'Y'
    GROUP BY GR.GUAR_CONTRACT_NUM;
      COMMIT;
---贷款合同下余额

INSERT INTO  DBHTXX_PLED_TEMP2
(CONTRACT_NUM , --贷款合同编号
  LOAN_ACCT_BAL_SUM ---贷款余额总额
)

SELECT D.ACCT_NUM,
       SUM(D.LOAN_ACCT_BAL) AS LOAN_ACCT_BAL_SUM
FROM   SMTMODS.L_ACCT_LOAN D --贷款借据信息表
       where  D.DATA_DATE = IS_DATE
       AND D.LOAN_ACCT_BAL > 0
       /*AND D.HX_FLAG='0'*/
       AND D.CANCEL_FLG='N'--去掉核销数据-2022.1.18 夏文博
     AND D.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
GROUP BY D.ACCT_NUM;
COMMIT;


  ----为了处理一个担保人证件号码对应两个不同的客户编码,确保保证人唯一
  INSERT /*+ APPEND*/
  INTO DBHTXX_BZR_TMP01 NOLOGGING
    (DATE_SOURCESD,
     GUAR_CONTRACT_NUM,
     DEPT_TYPE,
     GUAR_ID_NO,
     GUAR_ID_TYPE,
     CORP_SCALE,
     INDUSTRY_TYPE,
     REGION_CD,
     DATA_DATE,
     GUAR_CUSTNAME,
     guar_cust_id)
    SELECT /*+parallel(4)*/  t4.DATE_SOURCESD,
           T4.GUAR_CONTRACT_NUM, --系统担保编号
           T4.DEPT_TYPE, --担保人国民经济部门
           T4.ID_NO, --担保人证件号码
           T4.ID_TYPE, --担保人证件类型
           T4.CORP_SCALE, --担保人企业规模
           T4.INDUSTRY_TYPE, --担保人行业
           CASE
             WHEN LENGTHB(T4.REG_AREA_CODE) = 6 THEN
              T4.REG_AREA_CODE
           END REG_AREA_CODE, --存在地区代码含汉字的情况
           T4.DATA_DATE,
           T4.GUARANTEE_NAME, --担保人名称
           t4.GUAR_CUST_ID  --担保人客户编号
      FROM (SELECT  T2.DATE_SOURCESD,
                    T2.GUAR_CONTRACT_NUM,  --担保合同号
                    /*D3.PBOCD_CODE AS DEPT_TYPE, --担保人国民经济部门*/
                    CASE WHEN M.DEPT_TYPE IN ('D01','D80') THEN 'D01'
                         WHEN M.DEPT_TYPE IN ('E02','E021','E022') THEN 'E02'
                         WHEN M.DEPT_TYPE IN ('E03','E032') THEN 'E03'
                         WHEN M.DEPT_TYPE IN ('E05','E051') THEN 'E05'
                       ELSE TRIM(M.DEPT_TYPE)
                     END AS DEPT_TYPE, --担保人国民经济部门
                    CASE 
                        WHEN F.CUST_ID IS NOT NULL THEN F.CUST_ID_NO
                        -- WHEN C.TYSHXYDM IS NOT NULL THEN  C.TYSHXYDM
                        --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 如果担保人是个体工商户取法人信息
                         WHEN C.CUST_TYP='3' THEN C.LEGAL_CARD_NO
                         WHEN C.ID_NO IS NOT NULL THEN C.ID_NO
                         WHEN P.ID_NO IS NOT NULL THEN P.ID_NO
                       ELSE
                          t2.GUARANTEE_ID_NO
                     END AS ID_NO,  --担保人证件号码
                     --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 如果担保人是个体工商户取法人信息
                  CASE --WHEN C2.CUST_TYP='3' THEN D5.PBOCD_CODE--下面的D1.PBOCD_CODE可以区分个体工商户
                       WHEN F.CUST_ID IS NOT NULL THEN CASE WHEN LENGTH(F.CUST_ID_NO)=18  THEN 'A01' else f.CUST_ID_TYPE end
                     --  WHEN C.TYSHXYDM IS NOT NULL THEN   'A01'
                       WHEN C.ID_NO IS NOT NULL THEN D1.PBOCD_CODE
                       WHEN P.ID_NO IS NOT NULL THEN D2.PBOCD_CODE
                     ELSE
                    D4.PBOCD_CODE END AS ID_TYPE,  --担保人证件类别
                  NVL(F.ENT_SCALE,DECODE(c.CORP_SCALE,'B', 'CS01',
                                        'M', 'CS02',
                                        'S', 'CS03',
                                        'T', 'CS04',
                                        'Z', 'CS05'))AS CORP_SCALE,--担保人企业规模
                    /* nvl(SUBSTR(c.CORP_BUSINSESS_TYPE,1,3)  , --担保人行业
                     SUBSTR(T2.CORP_BUSINSESS_TYPE,1,3) ) AS INDUSTRY_TYPE, --担保人行业 alter by wjb 20211124*/
                   CASE WHEN M.CUST_TYPE IN ('11','12') AND C.CUST_TYP<>'3' AND M.INLANDORRSHORE_FLG='Y' THEN SUBSTR(C.CORP_BUSINSESS_TYPE,1,3)
                        WHEN (M.CUST_TYPE = '00' OR C.CUST_TYP='3') AND M.INLANDORRSHORE_FLG='Y' THEN '100'
                     ELSE '200'
                    END AS INDUSTRY_TYPE, --担保人行业
                    CASE WHEN P.CUST_ID IS NOT NULL AND P.REGION_CD IS NULL AND SUBSTR(P.ID_TYPE,1,2) IN ('10','17') THEN SUBSTR(P.ID_NO,1,6)
                         ELSE NVL(C.REGION_CD,P.REGION_CD) END AS REG_AREA_CODE, --担保人地区代码
                    T2.DATA_DATE,
                    T2.GUARANTEE_NAME,
                    T2.GUAR_CUST_ID
                   ,ROW_NUMBER() OVER(PARTITION BY nvl(NVL(C.ID_NO,P.ID_NO),t2.GUARANTEE_ID_NO), T2.GUAR_CONTRACT_NUM ORDER BY T2.GUAR_CUST_ID DESC) RN
            FROM SMTMODS.L_AGRE_GUARANTEE_RELATION T2  --担保合同与担保信息对应关系表
           INNER JOIN SMTMODS.L_AGRE_GUARANTEE_CONTRACT T --担保合同
                   ON T2.GUAR_CONTRACT_NUM=T.GUAR_CONTRACT_NUM
                  AND T.DATA_DATE =IS_DATE
                  AND SUBSTR(T.GUAR_TYP,1,1) ='C'--担保形式为保证

            LEFT JOIN JS_102_FTYKHX F
                   ON t2.GUAR_CUST_ID =F.CUST_ID
                  AND F.DATA_DATE =IS_DATE

            LEFT JOIN SMTMODS.L_CUST_C C   --对公客户
                   ON t2.GUAR_CUST_ID=C.CUST_ID
                  AND C.DATA_DATE=IS_DATE
                  --AND C.CUST_TYP!=3
            --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 如果担保人是个体工商户取法人信息
           /* LEFT JOIN SMTMODS.L_CUST_C C2   --个体工商户
                   ON t2.GUAR_CUST_ID=C2.CUST_ID
                  AND C2.DATA_DATE=IS_DATE
                  AND C2.CUST_TYP=3*/
            LEFT JOIN SMTMODS.L_CUST_ALL M --对公客户补充信息表
                   ON t2.GUAR_CUST_ID = M.CUST_ID
                   AND M.DATA_DATE = IS_DATE
            LEFT JOIN SMTMODS.L_CUST_P P   --对私客户
                   ON t2.GUAR_CUST_ID=P.CUST_ID
                  AND P.DATA_DATE=IS_DATE
            LEFT JOIN L_CODE_DICTIONARY D1 --码值表：证件类型:担保人对公--金数将担保人证件类型为营业执照的转换成A01
            --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 如果担保人是个体工商户取法人信息
            --       ON TRIM(C.ID_TYPE END)= D1.L_CODE
                   ON TRIM(CASE WHEN C.CUST_TYP=3 THEN C.LEGAL_CARD_TYPE ELSE C.ID_TYPE END)= D1.L_CODE
                  AND D1.CODE_CLMN_NAME ='BZR_ID_TYPE'
            LEFT JOIN L_CODE_DICTIONARY D2 --码值表：证件类型:担保人个人
                   ON trim(P.ID_TYPE)= D2.L_CODE
                   AND D2.CODE_CLMN_NAME ='BZR_ID_TYPE'
            LEFT JOIN L_CODE_DICTIONARY D4 --码值表：证件类型:担保人个人
                   ON trim(T2.GUARANTEE_ID_TPYE)= D4.L_CODE
                      AND D4.CODE_CLMN_NAME ='BZR_ID_TYPE'
            /*LEFT JOIN L_CODE_DICTIONARY D3
                   ON trim(C.DEPT_TYPE) = D3.L_CODE
                  AND D3.CODE_CLMN_NAME ='DEPT_TYPE' --国民经济部门*/
            LEFT JOIN L_CUST_C_tmp G  ---2022.1.14 --夏文博修改
                   ON t2.GUAR_CUST_ID=G.CUST_ID
                      AND G.DATA_DATE=IS_DATE
            LEFT JOIN SMTMODS.L_CODE_DICTIONARY D3
                   ON trim(G.DEPT_TYPE) = D3.CODE
                     AND D3.CODE_CLMN_NAME ='DEPT_TYPE' --国民经济部门*/
            --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 如果担保人是个体工商户取法人信息
            /*LEFT JOIN L_CODE_DICTIONARY D5 --码值表：证件类型  如果担保人是个体工商户取法人信息
                   ON trim(C2.LEGAL_CARD_TYPE)= D5.L_CODE
                      AND D5.CODE_CLMN_NAME ='BZR_ID_TYPE'*/
               WHERE T2.DATA_DATE=IS_DATE AND T2.REL_STATUS = 'Y'
                  ) T4
           WHERE t4.RN = 1
         ;

  COMMIT;

  ---取每个贷款合同号的贷款余额;存在一个贷款合同存在多笔借据，此处只取一条，取贷款余额的和

  INSERT INTO ACCT_LOAN_TMP01
    (ACCT_NUM, LOAN_ACCT_BAL)
    SELECT T.ACCT_NUM, SUM(NVL(LOAN_ACCT_BAL,0)) LOAN_ACCT_BAL
      FROM SMTMODS.L_ACCT_LOAN T
     WHERE T.DATA_DATE = IS_DATE
     GROUP BY T.ACCT_NUM;
  COMMIT;

  --取担保合同信息表
  INSERT /*+ APPEND*/  INTO  GUAR_CONTRACT_TMP01 NOLOGGING
    (DATE_SOURCESD, --数据来源
     GUAR_CONTRACT_NUM, --担保合同
     CONTRACT_NUM, --被担保合同
     CURR_CD, --币种
     GUAR_CON_AMT, --担保合同金额
     COLL_VALUE, --担保物总计
     ORG_NUM, --内部机构号
     GUAR_CONTRACT_START_DT, --担保合同起始日期
     GUAR_CONTRACT_END_DT, --担保合同到期日期
     COLLATERAL_RATIO, --抵质押率
     GUAR_CONTRACT_STATUS, --担保合同有效状态
     GUAR_TYP, --担保形式
     dept_type, --担保人国民经济部门
     guar_id_no, --担保人证件代码
     guar_id_type, --担保人证件类型
     ent_scale, --担保人企业规模
     industry_type, --担保人行业
     reg_area_code, --担保人地区代码
     rn, --排序
     GUAR_CONTRACT_TYP, --担保合同类型
     cust_id, --客户号
     cust_name, --客户名称
     GUAR_CUST_ID, --担保人客户号
     GUAR_CUST_NAME --担保人客户名称
     )

    SELECT /*+parallel(4)*/  T.DATE_SOURCESD, --系统条线
           T.GUAR_CONTRACT_NUM, --担保合同编号
           T1.CONTRACT_NUM, --被担保合同编号
           T.CURR_CD, --币种
           T.GURA_CONTRACT_AMT, --担保合同金额
           T3.COLL_VALUE,--担保物总计
           T.ORG_NUM, --内部机构号
           TO_CHAR(T.GUAR_CONTRACT_START_DT, 'YYYY-MM-DD'), --担保合同起始日期
           TO_CHAR(T.GUAR_CONTRACT_END_DT, 'YYYY-MM-DD'), --担保合同到期日期

           ROUND((T3.DZYL*100 ),2) DZYL, --抵质押率
           T.GUAR_CONTRACT_STATUS, --合同状态
           T.GUAR_TYP, -- 担保形式
           T5.DEPT_TYPE, --担保人国民经济部门
           T5.GUAR_ID_NO, --担保人证件代码
           T5.GUAR_ID_TYPE, --担保人证件类型
           T5.CORP_SCALE, --担保人企业规模
           CASE
                    WHEN T5.INDUSTRY_TYPE = '100' THEN
                     '100'
                    ELSE
                     T5.INDUSTRY_TYPE
                  END , --担保人行业
           T5.REGION_CD, --担保人地区代码
           ROW_NUMBER() OVER(PARTITION BY T.GUAR_CONTRACT_NUM ORDER BY 1 DESC) RN,
           CASE
             WHEN T.GUAR_CONTRACT_TYP = 'A' THEN
              '01' --一般担保合同
             WHEN T.GUAR_CONTRACT_TYP = 'B' THEN
              '02' --最高额担保合同
           END GUAR_CON_TYPE, --担保合同类型
           T4.CUST_ID, --客户号
           T8.CUST_NAM, --客户名称
           T5.GUAR_CUST_ID, --担保人客户号
           T5.GUAR_CUSTNAME --担保人名称
      FROM SMTMODS.L_AGRE_GUARANTEE_CONTRACT T --担保合同
      INNER JOIN (SELECT * FROM SMTMODS.L_AGRE_GUA_RELATION T1
                   WHERE T1.DATA_DATE = IS_DATE AND REL_STATUS = 'Y')T1--业务合同与担保合同对应关系表
        ON T.GUAR_CONTRACT_NUM = T1.GUAR_CONTRACT_NUM

      LEFT JOIN (SELECT   DISTINCT T.GUAR_CONTRACT_NUM,t1.CONTRACT_NUM,
      CASE
                  WHEN T.COLL_VALUE_SUM = '0' THEN
                   NULL
                  ELSE
                (T2.LOAN_ACCT_BAL_SUM / T.COLL_VALUE_SUM) END DZYL,
                T.COLL_VALUE_SUM AS COLL_VALUE
                             FROM DBHTXX_PLED_TEMP1  T
                                LEFT JOIN (SELECT * FROM SMTMODS.L_AGRE_GUA_RELATION T1
                   WHERE T1.DATA_DATE = IS_DATE AND REL_STATUS = 'Y')  T1  --担保合同与业务合同
                                       ON T.GUAR_CONTRACT_NUM=T1.GUAR_CONTRACT_NUM
                                LEFT JOIN DBHTXX_PLED_TEMP2 T2
                       ON T1.CONTRACT_NUM=T2.CONTRACT_NUM) T3
        ON T.GUAR_CONTRACT_NUM = T3.GUAR_CONTRACT_NUM
        and t1.CONTRACT_NUM=t3.CONTRACT_NUM
      INNER JOIN SMTMODS.L_AGRE_LOAN_CONTRACT T4
        ON T1.CONTRACT_NUM = T4.CONTRACT_NUM
       AND T4.DATA_DATE = IS_DATE
      left join DBHTXX_BZR_TMP01 t5  ---担保人信息
        on T.GUAR_CONTRACT_NUM = t5.GUAR_CONTRACT_NUM
      INNER JOIN ACCT_LOAN_TMP01 T7
        ON T1.CONTRACT_NUM = T7.ACCT_NUM
      INNER JOIN SMTMODS.L_CUST_C T8
            ON T4.CUST_ID=T8.CUST_ID
            AND T8.DATA_DATE=IS_DATE
     WHERE T.DATA_DATE = IS_DATE
        AND T8.CUST_TYP!=3
        AND T.GUAR_CONTRACT_STATUS='Y'
        AND T7.LOAN_ACCT_BAL > 0 --经业务确认，不卡这个条件了
        AND T.GUAR_CONTRACT_END_DT IS NOT NULL
     /*AND ((T7.LOAN_ACCT_BAL > 0 AND TO_CHAR(T.GUAR_CONTRACT_END_DT, 'YYYYMMDD') <= IS_DATE) OR --留逾期、展期 ； 合同到期 并且贷款余额大于0
          (TO_CHAR(T.GUAR_CONTRACT_END_DT, 'YYYYMMDD')> IS_DATE AND T.GUAR_CONTRACT_STATUS='Y'))--过滤掉失效延期的担保合同*/

     AND (EXISTS (SELECT 1--抵质押担保合同需要有状态正常的担保物
           FROM SMTMODS.L_AGRE_GUARANTEE_RELATION S1--担保合同与担保信息对应关系表
           INNER JOIN (SELECT *
                       FROM SMTMODS.L_AGRE_GUARANTY_INFO
                      WHERE DATA_DATE = IS_DATE AND COLL_STATUS = 'Y') S2
             ON S1.GUARANTEE_SERIAL_NUM = S2.GUARANTEE_SERIAL_NUM
          WHERE S1.DATA_DATE = IS_DATE
            AND S1.REL_STATUS = 'Y'
            AND T.GUAR_CONTRACT_NUM = S1.GUAR_CONTRACT_NUM AND T.GUAR_TYP IN('A0101','B0101')--A0101抵押、B0101质押
            )

        OR EXISTS (SELECT 1--保证担保合同需要有状态正常的关联关系
                     FROM SMTMODS.L_AGRE_GUARANTEE_RELATION S1--担保合同与担保信息对应关系表
                    WHERE S1.DATA_DATE = IS_DATE
                      AND S1.REL_STATUS = 'Y'
                      AND T.GUAR_CONTRACT_NUM = S1.GUAR_CONTRACT_NUM AND T.GUAR_TYP LIKE 'C%')--C保证担保
           );

  COMMIT;

  -----查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'JS_201_DBHTXX'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE JS_201_DBHTXX ADD PARTITION P' ||
                       IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE JS_201_DBHTXX TRUNCATE PARTITION P' ||
                    IS_DATE;

  INSERT /*+ APPEND*/ INTO JS_201_DBHTXX NOLOGGING
    (DATA_DATE, -- 数据日期
     ORG_CODE, --1 金融机构代码
     ORG_NUM, --2 内部机构号
     GUAR_CON_NUM, --3 担保合同编码
     CONTRACT_CODE, --4 被担保合同编码
     GUAR_CON_TYPE, --5 担保合同类型
     BUSINESS_TYPE, --6 交易类型
     GUAR_CON_SIGN_DATE, --7 担保合同起始日期
     GUAR_CON_DUE_DATE, --8 担保合同到期日期
     CURR_CODE, --9 币种
     GUAR_CON_AMT, --10  担保合同金额
     GURA_CON_AMT_RMB, --11  担保合同金额折人民币
     COLLATERAL_RATIO, --12  抵质押率
     GUAR_ID_TYPE, --13  担保人证件类型
     GUAR_ID_NO, --14  担保人证件代码
     DEPT_TYPE, --15  担保人国民经济部门
     INDUSTRY_TYPE, --16  担保人行业
     REG_AREA_CODE, --17  担保人地区代码
     ENT_SCALE, --18  担保人企业规模
     NBJGH,
     CJRQ, --20  采集日期
     BIZ_LINE_ID, --21  业务条线
     CUST_ID, --客户号
     CUST_NAME, --客户名称
     CUSTNAME --担保人名称
     )
    SELECT
           /*+ parallel(4)*/
           IS_DATE, -- 数据日期
           '',--T6.JRJGBM, --1 金融机构代码 待关联机构表
           T.ORG_NUM, --2 内部机构号
           T.GUAR_CONTRACT_NUM DBHTBH, --3 担保合同编码
           SUBSTR(T.CONTRACT_NUM, 1, 100), --4 被担保合同编号 长度要求100
           T.GUAR_CONTRACT_TYP , --5 担保合同类型
           '02', --6 交易类型  02 信贷交易
           T.GUAR_CONTRACT_START_DT, --7 担保合同起始日期
           T.GUAR_CONTRACT_END_DT, --8 担保合同到期日期
           T.CURR_CD, --9 币种
           CASE
             WHEN T.RN = 1 THEN
              T.GUAR_CON_AMT
             ELSE
              0.00
           END, --10 担保合同金额  金数采集规范
           (CASE
             WHEN T.RN = 1 THEN
              T.GUAR_CON_AMT
             ELSE
              0.00
           END) * T2.CCY_RATE, --11 担保合同金额折人民币  金数采集规范
           T.COLLATERAL_RATIO , --12 抵质押率
           T.GUAR_ID_TYPE, --13 担保人证件类型
           SUBSTR(T.GUAR_ID_NO, 1, 60), --14 担保人证件代码
           TRIM(T.DEPT_TYPE), --15 担保人国民经济部门 待映射
           T.INDUSTRY_TYPE , --16 担保人行业 取大类 个人填报100
           T.REG_AREA_CODE, --17 担保人地区代码
           T.ENT_SCALE, --18 担保人企业规模
           T.ORG_NUM,  --内部机构号
           IS_DATE, --20 采集日期

             NVL(CASE
                   WHEN T.ORG_NUM LIKE '51%' THEN '99'
                   WHEN T.ORG_NUM LIKE '52%' THEN '99'
                   WHEN T.ORG_NUM LIKE '53%' THEN '99'
                   WHEN T.ORG_NUM LIKE '54%' THEN '99'
                   WHEN T.ORG_NUM LIKE '55%' THEN '99'
                   WHEN T.ORG_NUM LIKE '56%' THEN '99'
                   WHEN T.ORG_NUM LIKE '57%' THEN '99'
                   WHEN T.ORG_NUM LIKE '58%' THEN '99'
                   WHEN T.ORG_NUM LIKE '59%' THEN '99'
                   WHEN T.ORG_NUM LIKE '60%' THEN '99'
                   WHEN T9.DEPARTMENTD= '公司金融' THEN 'E'
                   WHEN T9.DEPARTMENTD= '普惠金融' THEN 'S'
                   WHEN T9.DEPARTMENTD= '个人信贷' THEN 'P'
                   --WHEN T9.DEPARTMENTD= '磐石村镇' THEN 'V'
                   WHEN T9.DEPARTMENTD= '德惠长银' THEN 'E' END,'99'),--业务条线 20230919王晓彬
           T.CUST_ID, --客户号
           T.CUST_NAME, --客户名称
           T.GUAR_CUST_NAME --担保人名称
      FROM GUAR_CONTRACT_TMP01 T --担保合同信息表

      LEFT JOIN SMTMODS.L_PUBL_RATE T2
        ON T.CURR_CD = T2.BASIC_CCY --汇率表
       AND T2.FORWARD_CCY = 'CNY' --折算人民币
       AND T2.DATA_DATE = IS_DATE

      LEFT JOIN JS_102_FTYKHX_TEMP03 T7 --历史遗留客户、核销客户 不保留
        ON T.CUST_ID = T7.CUST_ID
      LEFT JOIN (select ACCT_NUM,LOAN_NUM,DEPARTMENTD,ROW_NUMBER() over(partition by acct_num order by loan_num desc) rn FROM SMTMODS.L_ACCT_LOAN where data_date=IS_DATE) T9
        ON T.CONTRACT_NUM = T9.ACCT_NUM
       AND T9.RN = '1'
     WHERE
           LENGTHB(TRUNC(NVL(T.COLLATERAL_RATIO,0)))<9 AND  --存在抵质押率大于8的异常数据，导致插入报错，暂时过滤掉！
        (T7.CUST_ID is null or
           SUBSTR(T.CONTRACT_NUM, 1, 100) in
           ('100101140010104624',
             '012201160010266600',
             '010301170010357407',
             '010301170010360672',
             '010301170010363236',
             '010301170010364393',
             '010301170010364938',
             '010301170010364371',
             '010301170010364402',
             '82601250806150221')); --历史遗留客户、核销客户 不保留

  COMMIT;


 -------------------吉林银行目标表数据--------------------
  ---清除历史数据

  SP_PBOCD_PARTITIONS(IS_DATE,'PBOCD_JS_201_DBHTXX_TMP',OI_RETCODE);

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_201_DBHTXX_TMP TRUNCATE PARTITION P' ||
                    IS_DATE;

/* --机构变更按照老机构报，如果不用了的机构可以把ORG_NEW表EFF_FLAG字段改成'N'
  UPDATE JS_201_DBHTXX A SET A.ORG_NUM = (SELECT T.ORG_NUM_BK FROM ORG_NEW T WHERE T.EFF_FLAG = 'Y' AND A.ORG_NUM = T.ORG_NUM_NEW)
  WHERE A.DATA_DATE = IS_DATE AND EXISTS(SELECT 1 FROM ORG_NEW B WHERE A.ORG_NUM = B.ORG_NUM_NEW AND B.EFF_FLAG = 'Y');
  COMMIT;*/

  INSERT /*+ APPEND*/  INTO PBOCD_JS_201_DBHTXX_TMP/*@PBOCD_34*/ NOLOGGING
    (DATA_DATE, --1 数据日期
     ORG_CODE, --2 金融机构代码
     ORG_NUM, --3 内部机构号
     GUAR_CON_NUM, --4 担保合同编码
     CONTRACT_CODE, --5 被担保合同编码
     GUAR_CON_TYPE, --6 担保合同类型
     BUSINESS_TYPE, --7 交易类型
     GUAR_CON_SIGN_DATE, --8 担保合同起始日期
     GUAR_CON_DUE_DATE, --9 担保合同到期日期
     CURR_CODE, --10 币种
     GUAR_CON_AMT, --11 担保合同金额
     GURA_CON_AMT_RMB, --12 担保合同金额折人民币
     COLLATERAL_RATIO, --13 抵质押率
     GUAR_ID_TYPE, --14 担保人证件类型
     GUAR_ID_NO, --15 担保人证件代码
     DEPT_TYPE, --16 担保人国民经济部门
     INDUSTRY_TYPE, --17 担保人行业
     REG_AREA_CODE, --18 担保人地区代码
     ENT_SCALE, --19 担保人企业规模
     CJRQ, --21 采集日期
     NBJGH, --22 内部机构号
     BIZ_LINE_ID, --23 业务条线
     BSCJRQ, --25 报送周期
     FRNBJGH, --法人内部机构号
     CUST_NAME, --借款人名称
     CUST_TYPE, --客户类型
     GUARANTEE_NAME --   担保人名称

     )
    SELECT /*+parallel(4)*/  VS_TEXT, --1 数据日期
           t.ORG_CODE, --2 金融机构代码
           t.ORG_NUM, --3 内部机构号
           t.GUAR_CON_NUM, --4 担保合同编码
           t.CONTRACT_CODE, --5 被担保合同编码
           t.GUAR_CON_TYPE, --6 担保合同类型
           t.BUSINESS_TYPE, --7 交易类型
           t.GUAR_CON_SIGN_DATE, --8 担保合同起始日期
           t.GUAR_CON_DUE_DATE, --9 担保合同到期日期
           t.CURR_CODE, --10 币种
           t.GUAR_CON_AMT, --11 担保合同金额
           t.GURA_CON_AMT_RMB, --12 担保合同金额折人民币
           t.COLLATERAL_RATIO, --13 抵质押率
           
           --[2025-07-29] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_三阶段][李楠] 优化冗余代码
           /*COALESCE(T.GUAR_ID_TYPE,
                    COALESCE(T.GUAR_ID_TYPE, t.GUAR_ID_TYPE)), --14 取补录担保人证件类型
           COALESCE(T.GUAR_ID_NO, COALESCE(T.GUAR_ID_NO, t.GUAR_ID_NO)), --15 取补录担保人证件代码
           COALESCE(t.DEPT_TYPE, COALESCE(T.DEPT_TYPE, T.DEPT_TYPE)), --16 担保人国民经济部门  (使用补录数据)
           COALESCE(T.INDUSTRY_TYPE,
                    COALESCE(T.INDUSTRY_TYPE, t.INDUSTRY_TYPE)), --17取补录担保人行业
           COALESCE(T.REG_AREA_CODE,
                    COALESCE(T.REG_AREA_CODE, t.REG_AREA_CODE)), --18 担保人地区代码   先去补录  补录没有取原系统
           CASE WHEN COALESCE(t.DEPT_TYPE, COALESCE(T.DEPT_TYPE, T.DEPT_TYPE)) = 'D01' THEN 'CS05' ELSE COALESCE(T.ENT_SCALE, COALESCE(T.ENT_SCALE, t.ENT_SCALE)) END, --19 取补录担保人企业规模
           */
           T.GUAR_ID_TYPE, --14 担保人证件类型
           T.GUAR_ID_NO, --15 担保人证件代码
           T.DEPT_TYPE, --16 担保人国民经济部门
           T.INDUSTRY_TYPE, --17担保人行业
           T.REG_AREA_CODE, --18 担保人地区代码
           CASE WHEN T.DEPT_TYPE = 'D01' THEN 'CS05' ELSE T.ENT_SCALE END, --19 担保人企业规模
           
           t.CJRQ, --21 采集日期
           t.NBJGH, --22 内部机构号
           T.BIZ_LINE_ID, --23 业务条线
           '', --25 报送周期

         CASE
           WHEN T.NBJGH LIKE '51%' THEN
           '510000'
           WHEN T.NBJGH LIKE '52%' THEN
            '520000'
           WHEN T.NBJGH LIKE '53%' THEN
            '530000'
           WHEN T.NBJGH LIKE '54%' THEN
            '540000'
           WHEN T.NBJGH LIKE '55%' THEN
            '550000'
           WHEN T.NBJGH LIKE '56%' THEN
            '560000'
           WHEN T.NBJGH LIKE '57%' THEN
            '570000'
           WHEN T.NBJGH LIKE '58%' THEN
            '580000'
           WHEN T.NBJGH LIKE '59%' THEN
            '590000'
           WHEN T.NBJGH LIKE '60%' THEN
            '600000'----20230620多法人新增
           ELSE '990000'
             END FRNBJGH,
           t.cust_name, --借款人名称
           '002' CUST_TYPE, --客户类型
           t.CUSTNAME GUARANTEE_NAME --    担保人名称
      FROM JS_201_DBHTXX T
      left join JS_201_DBHTXX_BL t2 -- 担保合同补录表   （如有补录字段信息修改此表）
        on t.guar_con_num = t2.guar_con_num
       and t.contract_code = t2.contract_code
       and nvl(t.guar_id_no, 'kkk') = nvl(t2.guar_id_no, 'kkk')
       and t2.opt_type = 'D' --删除标识
       
      --[2025-07-29] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_三阶段][李楠] 优化冗余代码
      /*left join JS_201_DBHTXX_MAPPING t1 --担保人证件号关系表
        on t1.guar_con_num = t.guar_con_num
       and t1.contract_code = t.contract_code
       AND (NVL(t1.cust_id_no, 'UUU') = NVL(t.guar_id_no, 'UUU') OR
           NVL(t1.cust_id_no_new, 'UUU') = NVL(t.guar_id_no, 'UUU'))*/

     WHERE T.DATA_DATE = IS_DATE
       and t2.opt_type is null; --删除补录表内要求删除数据
  COMMIT;
------------------------------------------------------------------------------
--应用层逻辑
  SP_PBOCD_PARTITIONS(IS_DATE,'PBOCD_JS_201_DBHTXX',OI_RETCODE);

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_201_DBHTXX TRUNCATE PARTITION P' ||
                    IS_DATE;
  VS_STEP := '应用层逻辑';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  INSERT INTO PBOCD_JS_201_DBHTXX NOLOGGING
    (DATA_DATE, --1 数据日期
     ORG_CODE, --2 金融机构代码
     ORG_NUM, --3 内部机构号
     GUAR_CON_NUM, --4 担保合同编码
     CONTRACT_CODE, --5 被担保合同编码
     GUAR_CON_TYPE, --6 担保合同类型
     BUSINESS_TYPE, --7 交易类型
     GUAR_CON_SIGN_DATE, --8 担保合同起始日期
     GUAR_CON_DUE_DATE, --9 担保合同到期日期
     CURR_CODE, --10 币种
     GUAR_CON_AMT, --11 担保合同金额
     GURA_CON_AMT_RMB, --12 担保合同金额折人民币
     COLLATERAL_RATIO, --13 抵质押率
     GUAR_ID_TYPE, --14 担保人证件类型
     GUAR_ID_NO, --15 担保人证件代码
     DEPT_TYPE, --16 担保人国民经济部门
     INDUSTRY_TYPE, --17 担保人行业
     REG_AREA_CODE, --18 担保人地区代码
     ENT_SCALE, --19 担保人企业规模
     CJRQ, --21 采集日期
     NBJGH, --22 内部机构号
     BIZ_LINE_ID, --23 业务条线
     BSCJRQ, --25 报送周期
     FRNBJGH, --法人内部机构号
     CUST_NAME, --借款人名称
     CUST_TYPE, --客户类型
     GUARANTEE_NAME --   担保人名称

     )
    SELECT VS_TEXT, --1 数据日期

           NVL( NVL(OB.ID_NO,OB.UP_ID_NO) ,NVL(OB2.ID_NO,OB2.UP_ID_NO) ), --金融机构代码
           --NVL(OB.ID_NO,OB.UP_ID_NO), --金融机构代码
           t.ORG_NUM, --3 内部机构号
           t.GUAR_CON_NUM, --4 担保合同编码
           t.CONTRACT_CODE, --5 被担保合同编码
           t.GUAR_CON_TYPE, --6 担保合同类型
           t.BUSINESS_TYPE, --7 交易类型
           t.GUAR_CON_SIGN_DATE, --8 担保合同起始日期
           t.GUAR_CON_DUE_DATE, --9 担保合同到期日期
           t.CURR_CODE, --10 币种
           t.GUAR_CON_AMT, --11 担保合同金额
           t.GURA_CON_AMT_RMB, --12 担保合同金额折人民币
           t.COLLATERAL_RATIO, --13 抵质押率
           COALESCE(T3.GUAR_ID_TYPE,
                    COALESCE(T4.GUAR_ID_TYPE, t.GUAR_ID_TYPE)), --14 取补录担保人证件类型
           
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --COALESCE(T3.GUAR_ID_NO, COALESCE(T4.GUAR_ID_NO, t.GUAR_ID_NO)), --15 取补录担保人证件代码
           t.GUAR_ID_NO, --15 担保人证件代码
           
           COALESCE(t.DEPT_TYPE, COALESCE(t3.DEPT_TYPE, t4.DEPT_TYPE)), --16 担保人国民经济部门  (使用补录数据)
           COALESCE(t3.INDUSTRY_TYPE,
                    COALESCE(t4.INDUSTRY_TYPE, t.INDUSTRY_TYPE)), --17取补录担保人行业
           COALESCE(t3.REG_AREA_CODE,
                    COALESCE(t4.REG_AREA_CODE, t.REG_AREA_CODE)), --18 担保人地区代码   先去补录  补录没有取原系统
           COALESCE(t3.ENT_SCALE, COALESCE(t4.ENT_SCALE, t.ENT_SCALE)), --19 取补录担保人企业规模
           
           t.CJRQ, --21 采集日期
           t.NBJGH, --22 内部机构号
           T.BIZ_LINE_ID, --23 业务条线
           '', --25 报送周期

           T.FRNBJGH, --法人内部机构号
           t.cust_name, --借款人名称
           '002' CUST_TYPE, --客户类型
           t.GUARANTEE_NAME --    担保人名称
      FROM PBOCD_JS_201_DBHTXX_TMP T

      LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=T.NBJGH AND OB.DATA_DATE=IS_DATE
    LEFT JOIN L_PUBL_ORG_BRA_TMP OB2--用于关联出NBJGH的上级机构的机构信息 20251013
      ON OB.UP_ORG_NUM=OB2.ORG_NUM AND OB.DATA_DATE=IS_DATE AND OB2.DATA_DATE=IS_DATE 
      left join JS_201_DBHTXX_BL t2 -- 担保合同补录表   （如有补录字段信息修改此表）
        on t.guar_con_num = t2.guar_con_num
       and t.contract_code = t2.contract_code
       and nvl(t.guar_id_no, 'kkk') = nvl(t2.guar_id_no, 'kkk')
       and t2.opt_type = 'D' --删除标识
      left join JS_201_DBHTXX_MAPPING t1 --担保人证件号关系表
        on t1.guar_con_num = t.guar_con_num
       and t1.contract_code = t.contract_code
       AND (NVL(t1.cust_id_no, 'UUU') = NVL(t.guar_id_no, 'UUU') OR
           NVL(t1.cust_id_no_new, 'UUU') = NVL(t.guar_id_no, 'UUU'))
      left join JS_201_DBHTXX_BL t3 -- 担保合同补录表   （如有补录字段信息修改此表）  修改
        on t1.guar_con_num = t3.guar_con_num
       and t1.contract_code = t3.contract_code
       AND NVL(t1.cust_id_no_new, 'UUU') = NVL(t3.guar_id_no, 'UUU')
       and t3.opt_type = 'U' --修改标识
      left join PBOCD_JS_201_DBHTXX_SQ t4 -- 如果mapping 关联不上 直接关联补录表
        on t.guar_con_num = t4.guar_con_num
       and t.contract_code = t4.contract_code
       AND NVL(t.guar_id_no, 'UUU') = NVL(t4.guar_id_no, 'UUU')
       and t4.data_date =
           to_char(add_months(to_date(IS_DATE, 'yyyymmdd'), -1),
                   'yyyy-mm-dd')
     WHERE T.DATA_DATE = VS_TEXT
       and t2.opt_type is null; --删除补录表内要求删除数据
  COMMIT;

  DELETE FROM PBOCD_JS_201_DBHTXX A
   WHERE A.CJRQ = IS_DATE
     AND GUARANTEE_NAME = '吉林市就业服务局';
  COMMIT;

  UPDATE PBOCD_JS_201_DBHTXX
     SET ENT_SCALE = 'CS05'
   WHERE CJRQ = IS_DATE
     AND DEPT_TYPE = 'D01';
  COMMIT;

  --取上期,有担保人
  MERGE INTO PBOCD_JS_201_DBHTXX A
  USING(
  SELECT * FROM (
  SELECT DISTINCT B.GUAR_CON_NUM,B.CONTRACT_CODE,B.GUAR_CON_TYPE,B.GUAR_ID_NO,
        B.GUAR_ID_TYPE,B.COLLATERAL_RATIO,B.DEPT_TYPE,B.INDUSTRY_TYPE,
        B.REG_AREA_CODE,B.ENT_SCALE,B.GUARANTEE_NAME,
        ROW_NUMBER() OVER(PARTITION BY GUAR_CON_NUM,CONTRACT_CODE,GUAR_CON_TYPE,GUAR_ID_NO ORDER BY DATA_DATE) RN
        FROM PBOCD_JS_201_DBHTXX_SQ B WHERE B.CJRQ = VS_LAST_TEXT AND TRIM(B.GUAR_ID_NO) IS NOT NULL)C
        WHERE C.RN=1
        ) C
  ON(A.GUAR_CON_NUM = C.GUAR_CON_NUM AND A.CONTRACT_CODE = C.CONTRACT_CODE AND A.GUAR_CON_TYPE = C.GUAR_CON_TYPE
     AND A.GUAR_ID_NO = C.GUAR_ID_NO AND A.CJRQ = IS_DATE AND TRIM(A.GUAR_ID_NO) IS NOT NULL)
  --[2025-07-29] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_三阶段][李楠] 抵质押率取消特殊处理
  WHEN MATCHED THEN UPDATE SET A.GUAR_ID_TYPE = C.GUAR_ID_TYPE, /*A.COLLATERAL_RATIO = C.COLLATERAL_RATIO,*/
  A.DEPT_TYPE = C.DEPT_TYPE, A.INDUSTRY_TYPE = C.INDUSTRY_TYPE, A.REG_AREA_CODE = C.REG_AREA_CODE,
  A.ENT_SCALE = C.ENT_SCALE, A.GUARANTEE_NAME = C.GUARANTEE_NAME;
  COMMIT;


  --取上期,无担保人
  MERGE INTO PBOCD_JS_201_DBHTXX A
  USING(
  SELECT * FROM (
  SELECT DISTINCT B.GUAR_CON_NUM,B.CONTRACT_CODE,B.GUAR_CON_TYPE,
        B.GUAR_ID_TYPE,B.COLLATERAL_RATIO,B.DEPT_TYPE,B.INDUSTRY_TYPE,
        B.REG_AREA_CODE,B.ENT_SCALE,B.GUARANTEE_NAME,
        ROW_NUMBER() OVER(PARTITION BY GUAR_CON_NUM,CONTRACT_CODE,GUAR_CON_TYPE ORDER BY DATA_DATE) RN
        FROM PBOCD_JS_201_DBHTXX_SQ B WHERE B.CJRQ = VS_LAST_TEXT AND TRIM(B.GUAR_ID_NO) IS NULL)C
        WHERE C.RN=1
        ) C
  ON(A.GUAR_CON_NUM = C.GUAR_CON_NUM AND A.CONTRACT_CODE = C.CONTRACT_CODE AND A.GUAR_CON_TYPE = C.GUAR_CON_TYPE
     AND A.CJRQ = IS_DATE AND TRIM(A.GUAR_ID_NO) IS NULL)
  --[2025-07-29] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_三阶段][李楠] 抵质押率取消特殊处理
  WHEN MATCHED THEN UPDATE SET A.GUAR_ID_TYPE = C.GUAR_ID_TYPE, /*A.COLLATERAL_RATIO = C.COLLATERAL_RATIO,*/
  A.DEPT_TYPE = C.DEPT_TYPE, A.INDUSTRY_TYPE = C.INDUSTRY_TYPE, A.REG_AREA_CODE = C.REG_AREA_CODE,
  A.ENT_SCALE = C.ENT_SCALE, A.GUARANTEE_NAME = C.GUARANTEE_NAME;
  COMMIT;

  --截取担保人证件代码补担保人地区代码
  UPDATE PBOCD_JS_201_DBHTXX T
     SET T.REG_AREA_CODE = SUBSTR(T.GUAR_ID_NO, 1, 6)
   WHERE T.CJRQ = IS_DATE
     AND TRIM(T.REG_AREA_CODE) IS NULL
     AND T.GUAR_ID_TYPE IN ('B01', 'B02', 'B08');
  COMMIT;
  --企业客户取所在机构地区码
  UPDATE PBOCD_JS_201_DBHTXX A
     SET A.REG_AREA_CODE =
         (SELECT B.REGION_CD FROM L_PUBL_ORG_BRA_TMP B WHERE B.DATA_DATE=IS_DATE AND A.NBJGH = B.ORG_NUM)
   WHERE A.CJRQ = IS_DATE
     AND TRIM(A.REG_AREA_CODE) IS NULL
     AND (A.GUAR_ID_TYPE IS NOT NULL OR A.GUAR_ID_NO IS NOT NULL)
     AND EXISTS (SELECT 1 FROM L_PUBL_ORG_BRA_TMP C WHERE C.DATA_DATE=IS_DATE AND A.NBJGH = C.ORG_NUM);
  COMMIT;

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除金融机构代码的刷数逻辑
/*  --小企业金融这个13开头的机构号现在取不到了
  UPDATE PBOCD_JS_201_DBHTXX
     SET ORG_CODE = '91220101691455409H'
   WHERE CJRQ = IS_DATE
     AND ORG_NUM = '130101' AND ORG_CODE IS NULL;
  COMMIT;*/

  --公主岭地区代码
  UPDATE PBOCD_JS_201_DBHTXX
     SET REG_AREA_CODE = '220184'
   WHERE CJRQ = IS_DATE
     AND REG_AREA_CODE = '220381';
  COMMIT;

  --个人担保行业为100
  UPDATE PBOCD_JS_201_DBHTXX A SET A.INDUSTRY_TYPE = '100' WHERE A.CJRQ = IS_DATE
  AND TRIM(A.GUAR_ID_TYPE) IN('B01','B02','B03','B04','B05','B99');

  --个人担保国民经济部门为D01
  UPDATE PBOCD_JS_201_DBHTXX A SET A.DEPT_TYPE = 'D01' WHERE A.CJRQ = IS_DATE
  AND TRIM(A.GUAR_ID_TYPE) IN('B01','B02','B04','B05','B08','B10');
  COMMIT;
  --国民经济部门为空的企业担保
  UPDATE PBOCD_JS_201_DBHTXX A SET A.DEPT_TYPE = 'C01' WHERE A.CJRQ = IS_DATE
  AND TRIM(A.DEPT_TYPE) IS NULL AND A.GUAR_ID_TYPE = 'A01';
  COMMIT;
  -------------------------------------------------------------------------
  OI_RETCODE := 0; --设置异常状态为0 成功状态
  OI_RETCODE_DEC :='执行成功';

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
