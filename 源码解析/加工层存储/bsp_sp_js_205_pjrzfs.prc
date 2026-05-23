CREATE OR REPLACE PROCEDURE BSP_SP_JS_205_PJRZFS(IS_DATE    IN VARCHAR2,
                                                  OI_RETCODE OUT INTEGER,
                                                  OI_RETCODE_DEC OUT VARCHAR2) AS  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- BSP_SP_JS_205_PJRZFS
  -- 业务域: 票据类
  -- 用途: 生成接口表 JS_205_PJRZFS 存量票据融资
  -- 参数
  --    IS_DATE 输入，传入跑批日期
  --    OI_RETCODE 输出，用来标识存储过程执行过程中是否出现异常
  -- 引用的监管集市表
  --    SMTMODS.L_ACCT_LOAN                                — 贷款借据信息表
  --    SMTMODS.L_AGRE_BILL_INFO                           — 商业汇票票面信息表
  --    SMTMODS.L_CUST_ALL                                 — 全量客户信息表
  --    SMTMODS.L_CUST_BILL_TY                             — 同业客户补充信息表
  --    SMTMODS.L_CUST_C                                   — 对公客户补充信息表
  --    SMTMODS.L_CUST_P                                   — 对私客户补充信息表
  --    SMTMODS.L_PUBL_RATE                                — 汇率表
  --    SMTMODS.L_TRAN_LOAN_PAYM                           — 贷款还款明细信息表
  -- 修改历史
  --    需求编号：JLBA202502130004_制度升级2025 上线日期：2025-03-27，修改人：周立鹏，提出人：李楠   修改原因：制度升级2025
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
  NUM               INTEGER;

BEGIN
  VS_TEXT      := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');

  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_205_PJRZFS';
  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------



  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_205_PJRZFS_TMP1';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_205_PJRZFS_TMP2';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_205_PJRZFS_TMP3';


--存在行内直转交易的票据
INSERT INTO JS_205_PJRZFS_TMP3
  SELECT /*+ PARALLEL(8)*/
   T1.acct_Num,
   T1.draft_rng,
   T1.org_num,
   T1.LOAN_ACCT_BAL  AS LOAN_ACCT_BAL_ZHITIE,
   T1.INT_ADJEST_AMT AS INT_ADJEST_AMT_ZHITIE,
   T2.LOAN_ACCT_BAL  AS LOAN_ACCT_BAL_ZHUANTIE,
   T2.INT_ADJEST_AMT AS INT_ADJEST_AMT_ZHUANTIE
    FROM SMTMODS.L_ACCT_LOAN T1
   INNER JOIN SMTMODS.L_ACCT_LOAN T2
      ON T2.DATA_DATE = IS_DATE
     AND SUBSTR(T2.ITEM_CD, 1, 6) IN ('130102', '130105')
     AND T1.acct_Num || T1.draft_rng = T2.acct_Num || T2.draft_rng
   WHERE T1.DATA_DATE = IS_DATE
     AND SUBSTR(T1.ITEM_CD, 1, 6) IN ('130101', '130104');
COMMIT;


  INSERT INTO JS_205_PJRZFS_TMP2 (
                ID,
                DATA_DATE,
                ORG_CODE,
                ORG_NUM,
                REG_REGION_CODE,
                DISCOUNT_TYPE,
                BILL_TYPE,
                BILL_MEDIUM,
                BILL_NUM,
                DISCOUNT_ID_TYPE,
                DISCOUNT_ID_NO,
                DISCOUNT_DEPT_TYPE,
                DISCOUNT_INDUSTRY_TYPE,
                DISCOUNT_REG_AREA_CODE,
                DISCOUNT_ENT_CON_ECO_ELEM,
                DISCOUNT_ENT_SCALE,
                ACCEPT_NAME,
                ACCEPT_ID_TYPE,
                ACCEPT_ID_NO,
                DRAWER_NAME,
                DRAWER_ID_TYPE,
                DRAWER_ID_NO,
                OPEN_DATE,
                BILL_DUE_DATE,
                TRANS_DATE,
                BILL_CURR_CODE,
                BILL_AMT,
                BILL_AMT_RMB,
                DISCOUNT_CURR_CODE,
                DISCOUNT_BAL,
                DISCOUNT_BAL_RMB,
                INT_RATE,
                REPORT_ID,
                CJRQ,
                BIZ_LINE_ID,
                VERIFY_STATUS,
                BSCJRQ,
                FRNBJGH,
                NBJGH,
                LOAN_CLASSIFY,
                LOAN_STATUS)
   SELECT /*+ parallel(4)*/
                1 AS ID,
                IS_DATE AS DATA_DATE,
                ORG_CODE,
                ORG_NUM,
                REG_REGION_CODE,
                DISCOUNT_TYPE,
                BILL_TYPE,
                BILL_MEDIUM,
                BILL_NUM,
                DISCOUNT_ID_TYPE,
                DISCOUNT_ID_NO,
                DISCOUNT_DEPT_TYPE,
                DISCOUNT_INDUSTRY_TYPE,
                DISCOUNT_REG_AREA_CODE,
                DISCOUNT_ENT_CON_ECO_ELEM,
                DISCOUNT_ENT_SCALE,
                ACCEPT_NAME,
                ACCEPT_ID_TYPE,
                ACCEPT_ID_NO,
                DRAWER_NAME,
                DRAWER_ID_TYPE,
                DRAWER_ID_NO,
                OPEN_DATE,
                BILL_DUE_DATE,
                TRANS_DATE,
                BILL_CURR_CODE,
                BILL_AMT,
                BILL_AMT_RMB,
                DISCOUNT_CURR_CODE,
                DISCOUNT_BAL,
                DISCOUNT_BAL_RMB,
                INT_RATE,
                REPORT_ID,
                IS_DATE AS CJRQ,
                BIZ_LINE_ID,
                VERIFY_STATUS,
                BSCJRQ,
                FRNBJGH,
                NBJGH,
                LOAN_CLASSIFY,
                LOAN_STATUS
   FROM PBOCD_DATACORE.PBOCD_JS_205_CLPJRZ T
   WHERE T.CJRQ = IS_DATE
   AND NOT EXISTS (SELECT 1
          FROM PBOCD_JS_205_CLPJRZ_SQ F--上期
         WHERE F.CJRQ = VS_LAST_TEXT
           AND T.BILL_NUM = F.BILL_NUM
           AND T.DISCOUNT_TYPE = F.DISCOUNT_TYPE
           --遇到过一种从总行变更到磐石的情况，加机构判断可以产生一笔原机构收回、新机构发生，从而解决连续性不平的问题。--zhoulp20221229
           AND (CASE WHEN T.ORG_NUM LIKE '51%' THEN 1 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '51%' THEN 1 ELSE 99 END)
           AND (CASE WHEN T.ORG_NUM LIKE '52%' THEN 2 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '52%' THEN 2 ELSE 99 END)
           AND (CASE WHEN T.ORG_NUM LIKE '53%' THEN 3 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '53%' THEN 3 ELSE 99 END)
           AND (CASE WHEN T.ORG_NUM LIKE '54%' THEN 4 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '54%' THEN 4 ELSE 99 END)
           AND (CASE WHEN T.ORG_NUM LIKE '55%' THEN 5 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '55%' THEN 5 ELSE 99 END)
           AND (CASE WHEN T.ORG_NUM LIKE '56%' THEN 6 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '56%' THEN 6 ELSE 99 END)
           AND (CASE WHEN T.ORG_NUM LIKE '57%' THEN 7 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '57%' THEN 7 ELSE 99 END)
           AND (CASE WHEN T.ORG_NUM LIKE '58%' THEN 8 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '58%' THEN 8 ELSE 99 END)
           AND (CASE WHEN T.ORG_NUM LIKE '59%' THEN 9 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '59%' THEN 9 ELSE 99 END)
           AND (CASE WHEN T.ORG_NUM LIKE '60%' THEN 10 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '60%' THEN 10 ELSE 99 END)--20231013王晓彬
           )
   UNION
   SELECT /*+ parallel(4)*/ 0,
                IS_DATE AS DATA_DATE,
                ORG_CODE,
                ORG_NUM,
                REG_REGION_CODE,
                DISCOUNT_TYPE,
                BILL_TYPE,
                BILL_MEDIUM,
                BILL_NUM,
                DISCOUNT_ID_TYPE,
                DISCOUNT_ID_NO,
                DISCOUNT_DEPT_TYPE,
                DISCOUNT_INDUSTRY_TYPE,
                DISCOUNT_REG_AREA_CODE,
                DISCOUNT_ENT_CON_ECO_ELEM,
                DISCOUNT_ENT_SCALE,
                ACCEPT_NAME,
                ACCEPT_ID_TYPE,
                ACCEPT_ID_NO,
                DRAWER_NAME,
                DRAWER_ID_TYPE,
                DRAWER_ID_NO,
                OPEN_DATE,
                BILL_DUE_DATE,
                TRANS_DATE,
                BILL_CURR_CODE,
                BILL_AMT,
                BILL_AMT_RMB,
                DISCOUNT_CURR_CODE,
                DISCOUNT_BAL,
                DISCOUNT_BAL_RMB,
                INT_RATE,
                REPORT_ID,
                IS_DATE AS CJRQ,
                BIZ_LINE_ID,
                VERIFY_STATUS,
                BSCJRQ,
                FRNBJGH,
                NBJGH,
                LOAN_CLASSIFY,
                LOAN_STATUS
  FROM (
       SELECT
T.data_date,
T.org_code,
T.org_num,
T.reg_region_code,
T.discount_type,
T.bill_type,
T.bill_medium,
T.bill_num,
T.discount_id_type,
T.discount_id_no,
T.discount_dept_type,
T.discount_industry_type,
T.discount_reg_area_code,
T.discount_ent_con_eco_elem,
T.discount_ent_scale,
T.accept_name,
T.accept_id_type,
T.accept_id_no,
T.drawer_name,
T.drawer_id_type,
T.drawer_id_no,
T.open_date,
T.bill_due_date,
T.trans_date,
T.bill_curr_code,
T.bill_amt,
T.bill_amt_rmb,
T.discount_curr_code,
T.discount_bal,
T.discount_bal_rmb,
T.int_rate,
T.report_id,
T.cjrq,
T.biz_line_id,
T.verify_status,
T.bscjrq,
T.frnbjgh,
T.nbjgh,
T.loan_classify,
T.loan_status

       FROM PBOCD_JS_205_CLPJRZ_SQ T  --上期
       WHERE T.CJRQ = VS_LAST_TEXT --总行上期报送数据
  )  T
 WHERE T.CJRQ = VS_LAST_TEXT
   AND NOT EXISTS (SELECT 1
          FROM PBOCD_DATACORE.PBOCD_JS_205_CLPJRZ F
         WHERE F.CJRQ = IS_DATE
           AND T.BILL_NUM = F.BILL_NUM
           AND T.DISCOUNT_TYPE = F.DISCOUNT_TYPE

           AND (CASE WHEN T.ORG_NUM LIKE '51%' THEN 1 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '51%' THEN 1 ELSE 99 END)
           AND (CASE WHEN T.ORG_NUM LIKE '52%' THEN 2 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '52%' THEN 2 ELSE 99 END)
           AND (CASE WHEN T.ORG_NUM LIKE '53%' THEN 3 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '53%' THEN 3 ELSE 99 END)
           AND (CASE WHEN T.ORG_NUM LIKE '54%' THEN 4 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '54%' THEN 4 ELSE 99 END)
           AND (CASE WHEN T.ORG_NUM LIKE '55%' THEN 5 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '55%' THEN 5 ELSE 99 END)
           AND (CASE WHEN T.ORG_NUM LIKE '56%' THEN 6 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '56%' THEN 6 ELSE 99 END)
           AND (CASE WHEN T.ORG_NUM LIKE '57%' THEN 7 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '57%' THEN 7 ELSE 99 END)
           AND (CASE WHEN T.ORG_NUM LIKE '58%' THEN 8 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '58%' THEN 8 ELSE 99 END)
           AND (CASE WHEN T.ORG_NUM LIKE '59%' THEN 9 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '59%' THEN 9 ELSE 99 END)
           AND (CASE WHEN T.ORG_NUM LIKE '60%' THEN 10 ELSE 99 END)=(CASE WHEN F.ORG_NUM LIKE '60%' THEN 10 ELSE 99 END)
           )
-- ZHOULP20251201 分行卖入总行后，总行卖出的，剔除分行卖出和总行买入的记录，至于总行卖出的记录会在“当月发生当月收回”的收回方向出数
   AND NOT EXISTS (SELECT 1 FROM JS_205_PJRZFS_TMP3 T3 WHERE T3.acct_Num||T3.draft_rng=T.bill_num AND T.ORG_NUM<>'009804')
           ;
commit;

    --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'JS_205_PJRZFS'
     AND PARTITION_NAME = 'JS_205_PJRZFS_' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE JS_205_PJRZFS ADD PARTITION JS_205_PJRZFS_' ||
                      IS_DATE || ' VALUES (' || IS_DATE || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE JS_205_PJRZFS TRUNCATE PARTITION JS_205_PJRZFS_' ||
                    IS_DATE;

  VS_STEP := '2';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

   INSERT INTO JS_205_PJRZFS
  (DATA_DATE --数据日期
  ,ORG_CODE --金融机构代码
  ,ORG_NUM --内部机构号
  ,REG_REGION_CODE --金融机构地区代码
  ,DISCOUNT_TYPE --贴现方式
  ,BILL_TYPE ---票据种类
  ,BILL_MEDIUM --票据介质
  ,BILL_NUM --票据编号
  ,DISCOUNT_ID_TYPE --贴现申请人证件类型
  ,DISCOUNT_ID_NO --贴现申请人证件代码
  ,DISCOUNT_DEPT_TYPE --贴现申请人国民经济部门
  ,DISCOUNT_INDUSTRY_TYPE --贴现申请人行业
  ,DISCOUNT_REG_AREA_CODE --贴现申请人地区代码
  ,DISCOUNT_ENT_CON_ECO_ELEM --贴现申请人经济成分
  ,DISCOUNT_ENT_SCALE --贴现申请人企业规模
  ,ACCEPT_NAME --承兑人名称
  ,ACCEPT_ID_TYPE --承兑人证件类型
  ,ACCEPT_ID_NO --承兑人证件代码
  ,AFF_NAME --出票人名称
  ,AFF_ID_TYPE --出票人证件类型
  ,AFF_ID_NO --出票人证件代码
  ,OPEN_DATE --出票日期
  ,BILL_DUE_DATE --票据到期日期
  ,TRANS_DATE --交易日期
  ,BILL_CURR_CODE --币种
  ,BILL_AMT --票面金额
  ,BILL_AMT_RMB --票面金额折人民币
  ,DISCOUNT_CURR_CODE --贴现币种
  ,DISCOUNT_AMT --贴现金额
  ,DISCOUNT_AMT_RMB --贴现金额折人民币
  ,INT_RATE --贴现利率
  ,TRANS_TYPE --交易类型
  ,SERIAL_NO --交易流水号
  --[2026-02-06] [周立鹏] [无需求][李楠] 调整流水号与五大篇章一致
  ,REPORT_ID
  ,CJRQ)
  SELECT /*+ parallel(4)*/  VS_TEXT DATA_DATE,
         ORG_CODE,
         NVL(T3.ORG_NUM,A.ORG_NUM),
         REG_REGION_CODE,
         DISCOUNT_TYPE,
         BILL_TYPE,
         BILL_MEDIUM,
         BILL_NUM,
         DISCOUNT_ID_TYPE,
         DISCOUNT_ID_NO,
         DISCOUNT_DEPT_TYPE,
         DISCOUNT_INDUSTRY_TYPE,
         DISCOUNT_REG_AREA_CODE,
         DISCOUNT_ENT_CON_ECO_ELEM,
         DISCOUNT_ENT_SCALE,
         ACCEPT_NAME,
         ACCEPT_ID_TYPE,
         ACCEPT_ID_NO,
         DRAWER_NAME AFF_NAME,
         DRAWER_ID_TYPE AFF_ID_TYPE,
         DRAWER_ID_NO AFF_ID_NO,
         OPEN_DATE,
         BILL_DUE_DATE,
         TRANS_DATE,
         BILL_CURR_CODE,
         BILL_AMT,
         BILL_AMT_RMB,
         DISCOUNT_CURR_CODE,
         
         --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 贴现金额：发生方向与存量一致，收回方向=票面金额
         /*DISCOUNT_BAL DISCOUNT_AMT,
         A.DISCOUNT_BAL_RMB DISCOUNT_AMT_RMB,*/
         CASE WHEN ID = '1' THEN DISCOUNT_BAL ELSE BILL_AMT END AS DISCOUNT_AMT,--贴现金额
         CASE WHEN ID = '1' THEN DISCOUNT_BAL_RMB ELSE BILL_AMT_RMB END AS DISCOUNT_AMT_RMB,--贴现金额折人民币
         
         INT_RATE,
         CASE
           WHEN ID = '1' THEN
            CASE
              WHEN DISCOUNT_TYPE = '01' THEN
               'A01'
              WHEN DISCOUNT_TYPE = '02' THEN
               'A02'
            END
           ELSE
            'B01'
         END TRANS_TYPE,
         --SYS_GUID() SERIAL_NO,
         --[2026-02-06] [周立鹏] [无需求][李楠] 调整流水号与五大篇章一致  因为剔除了直转流水，所以不需要1和11确保唯一了
         /*CASE
           WHEN ID = '1' THEN
            CASE--避免流水号不唯一
              WHEN DISCOUNT_TYPE = '01' THEN
               '1'
              WHEN DISCOUNT_TYPE = '02' THEN
               '11'
            END
           ELSE
            CASE--避免流水号不唯一
              WHEN DISCOUNT_TYPE = '01' THEN
               '0'
              WHEN DISCOUNT_TYPE = '02' THEN
               '00'
            END
         END SERIAL_NO, -- 1-发生 0-收回*/
         
         ID AS SERIAL_NO, -- 1-发生 0-收回
         CASE
           WHEN ID = '1' THEN
            CASE--避免流水号不唯一
              WHEN DISCOUNT_TYPE = '01' THEN
               '01MRKY'
              WHEN DISCOUNT_TYPE = '02' THEN
               '02MRKY'
            END
           ELSE
            CASE--避免流水号不唯一
              WHEN DISCOUNT_TYPE = '01' THEN
               '01MCKY'
              WHEN DISCOUNT_TYPE = '02' THEN
               '02MCKY'
            END
         END || SYS_GUID() AS REPORT_ID,
         IS_DATE CJRQ
    FROM JS_205_PJRZFS_TMP2 A
    LEFT JOIN JS_205_PJRZFS_TMP3 T3 ON A.BILL_NUM = T3.acct_Num||T3.draft_rng
    WHERE CJRQ = IS_DATE
    ;COMMIT;

  VS_STEP := '3';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

-------------------吉林银行目标表数据--------------------
---清除历史数据
DELETE FROM PBOCD_JS_205_PJRZFS WHERE DATA_DATE = VS_TEXT;
COMMIT;
 ---以下包含原应用层加工逻辑，现都放在加工层处理
 INSERT INTO PBOCD_JS_205_PJRZFS
  (DATA_DATE --数据日期
  ,ORG_CODE --金融机构代码
  ,ORG_NUM --内部机构号
  ,REG_REGION_CODE --金融机构地区代码
  ,DISCOUNT_TYPE --贴现方式
  ,BILL_TYPE ---票据种类
  ,BILL_MEDIUM --票据介质
  ,BILL_NUM --票据编号
  ,DISCOUNT_ID_TYPE --贴现申请人证件类型
  ,DISCOUNT_ID_NO --贴现申请人证件代码
  ,DISCOUNT_DEPT_TYPE --贴现申请人国民经济部门
  ,DISCOUNT_INDUSTRY_TYPE --贴现申请人行业
  ,DISCOUNT_REG_AREA_CODE --贴现申请人地区代码
  ,DISCOUNT_ENT_CON_ECO_ELEM --贴现申请人经济成分
  ,DISCOUNT_ENT_SCALE --贴现申请人企业规模
  ,ACCEPT_NAME --承兑人名称
  ,ACCEPT_ID_TYPE --承兑人证件类型
  ,ACCEPT_ID_NO --承兑人证件代码
  ,AFF_NAME --出票人名称
  ,AFF_ID_TYPE --出票人证件类型
  ,AFF_ID_NO --出票人证件代码
  ,OPEN_DATE --出票日期
  ,BILL_DUE_DATE --票据到期日期
  ,TRANS_DATE --交易日期
  ,BILL_CURR_CODE --币种
  ,BILL_AMT --票面金额
  ,BILL_AMT_RMB --票面金额折人民币
  ,DISCOUNT_CURR_CODE --贴现币种
  ,DISCOUNT_AMT --贴现金额
  ,DISCOUNT_AMT_RMB --贴现金额折人民币
  ,INT_RATE --贴现利率
  ,TRANS_TYPE --交易类型
  ,SERIAL_NO --交易流水号
  ,REPORT_ID
  ,CJRQ
  ,BIZ_LINE_ID
  ,VERIFY_STATUS
  ,BSCJRQ
  ,FRNBJGH
  ,NBJGH
  )
  SELECT VS_TEXT --数据日期
        ,NVL(OB.ID_NO,OB.UP_ID_NO) --金融机构代码
        ,T.ORG_NUM --内部机构号
        ,OB.REGION_CD --3  金融机构地区代码
        ,DISCOUNT_TYPE --贴现方式
        ,BILL_TYPE ---票据种类
        ,BILL_MEDIUM --票据介质
        ,BILL_NUM --票据编号
        ,DISCOUNT_ID_TYPE --贴现申请人证件类型
        ,DISCOUNT_ID_NO --贴现申请人证件代码
        ,DISCOUNT_DEPT_TYPE --贴现申请人国民经济部门
        ,DISCOUNT_INDUSTRY_TYPE --贴现申请人行业
        ,DISCOUNT_REG_AREA_CODE --贴现申请人地区代码
        ,DISCOUNT_ENT_CON_ECO_ELEM --贴现申请人经济成分
        ,DISCOUNT_ENT_SCALE --贴现申请人企业规模
        ,ACCEPT_NAME --承兑人名称
        ,ACCEPT_ID_TYPE --承兑人证件类型
        ,ACCEPT_ID_NO --承兑人证件代码
        ,AFF_NAME --出票人名称
        ,AFF_ID_TYPE --出票人证件类型
        ,AFF_ID_NO --出票人证件代码
        ,OPEN_DATE --出票日期
        ,BILL_DUE_DATE --票据到期日期
        ,TRANS_DATE --交易日期
        ,BILL_CURR_CODE --币种
        ,BILL_AMT --票面金额
        ,BILL_AMT_RMB --票面金额折人民币
        ,DISCOUNT_CURR_CODE --贴现币种
        ,DISCOUNT_AMT --贴现金额
        ,DISCOUNT_AMT_RMB --贴现金额折人民币
        ,INT_RATE --贴现利率
        ,TRANS_TYPE --交易类型
        ,SERIAL_NO --交易流水号
        ,REPORT_ID 
    ,IS_DATE
    ,
      CASE WHEN T.ORG_NUM LIKE '51%' THEN '99'
          WHEN T.ORG_NUM LIKE '52%' THEN '99'
          WHEN T.ORG_NUM LIKE '53%' THEN '99'
          WHEN T.ORG_NUM LIKE '54%' THEN '99'
          WHEN T.ORG_NUM LIKE '55%' THEN '99'
          WHEN T.ORG_NUM LIKE '56%' THEN '99'
          WHEN T.ORG_NUM LIKE '57%' THEN '99'
          WHEN T.ORG_NUM LIKE '58%' THEN '99'
          WHEN T.ORG_NUM LIKE '59%' THEN '99'
          WHEN T.ORG_NUM LIKE '60%' THEN '99'
          WHEN T.ORG_NUM = '009804' THEN 'SC'
          WHEN T.discount_type='02' THEN 'SC'
    --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 把贴现方式是01，票据种类是02的改到公司条线
          WHEN T.DISCOUNT_TYPE = '01' AND T.BILL_TYPE = '02' THEN 'E'
          ELSE '99' END  --业务条线 20231013 王晓彬
    ,''
    ,''
         ,
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
             END FRNBJGH
      ,T.ORG_NUM
    FROM JS_205_PJRZFS T
     LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=T.ORG_NUM AND OB.DATA_DATE=IS_DATE
   WHERE CJRQ = IS_DATE;
   COMMIT;


---------------------------------------------------------------------------
--插入票据融资发生当月发生当月收回数据
--发生方向
INSERT INTO PBOCD_JS_205_PJRZFS
(DATA_DATE --数据日期
  ,ORG_CODE --金融机构代码
  ,ORG_NUM --内部机构号
  ,REG_REGION_CODE --金融机构地区代码
  ,DISCOUNT_TYPE --贴现方式
  ,BILL_TYPE ---票据种类
  ,BILL_MEDIUM --票据介质
  ,BILL_NUM --票据编号
  ,DISCOUNT_ID_TYPE --贴现申请人证件类型
  ,DISCOUNT_ID_NO --贴现申请人证件代码
  ,DISCOUNT_DEPT_TYPE --贴现申请人国民经济部门
  ,DISCOUNT_INDUSTRY_TYPE --贴现申请人行业
  ,DISCOUNT_REG_AREA_CODE --贴现申请人地区代码
  ,DISCOUNT_ENT_CON_ECO_ELEM --贴现申请人经济成分
  ,DISCOUNT_ENT_SCALE --贴现申请人企业规模
  ,ACCEPT_NAME --承兑人名称
  ,ACCEPT_ID_TYPE --承兑人证件类型
  ,ACCEPT_ID_NO --承兑人证件代码
  ,AFF_NAME --出票人名称
  ,AFF_ID_TYPE --出票人证件类型
  ,AFF_ID_NO --出票人证件代码
  ,OPEN_DATE --出票日期
  ,BILL_DUE_DATE --票据到期日期
  ,TRANS_DATE --交易日期
  ,BILL_CURR_CODE --币种
  ,BILL_AMT --票面金额
  ,BILL_AMT_RMB --票面金额折人民币
  ,DISCOUNT_CURR_CODE --贴现币种
  ,DISCOUNT_AMT --贴现金额
  ,DISCOUNT_AMT_RMB --贴现金额折人民币
  ,INT_RATE --贴现利率
  ,TRANS_TYPE --交易类型
  ,SERIAL_NO --交易流水号
  ,REPORT_ID
  ,CJRQ
  ,BIZ_LINE_ID
  ,VERIFY_STATUS
  ,BSCJRQ
  ,FRNBJGH
  ,NBJGH
)
select /*+ PARALLEL(8)*/
 TO_CHAR(TO_DATE(IS_DATE,'YYYY-MM-DD'),'YYYY-MM-DD')     --数据日期
,NVL(OB.ID_NO,OB.UP_ID_NO) --金融机构代码
-- ZHOULP20251201 分行买入后当月直转到总行的，取分行直贴买入那笔作为发生方向，机构取总行；取总行卖出那笔作为收回方向，贴现方式改为直贴
,A.ORG_NUM   --机构号
--,NVL(T1.ORG_NUM,A.ORG_NUM)   --机构号
,OB.REGION_CD --金融机构地区代码
,CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) THEN '01'
       WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130102','130105' ) THEN '02'  ---20220701-夏文博
       ELSE NULL END         --贴现方式 直贴
,CASE WHEN TRIM(B.BILL_TYPE) = '1' THEN '01' --银行承兑汇票
      WHEN B.BILL_TYPE = '2' THEN '02' --商业承兑汇票
       END AS BILL_TYPE  --票据种类
,CASE WHEN B.IS_P_BILL = 'Y' THEN '01'
      ELSE '02' END AS BILL_MEDIUM --票据介质 01 纸票 02 电票
,a.acct_Num||A.draft_rng --票据编号

/*,CASE WHEN H.TYSHXYDM IS NOT NULL THEN 'A01'
      WHEN LENGTH(H.ID_NO) = 18 THEN 'A01'
      WHEN H.ORGANIZATIONCODE IS NOT NULL THEN 'A02'
 ELSE NVL(CD1.PBOCD_CODE,CD2.PBOCD_CODE) END --贴现申请人证件类型*/
,CASE WHEN SUBSTR(A.ITEM_CD,1,6) IN ('130101','130104' ) AND  B.BILL_TYPE = '1' THEN 'A01'
  ELSE CASE WHEN H.TYSHXYDM IS NOT NULL THEN 'A01'
        WHEN LENGTH(H.ID_NO) = 18 THEN 'A01'
        WHEN H.ORGANIZATIONCODE IS NOT NULL THEN 'A02'
        ELSE NVL(CD1.PBOCD_CODE,CD2.PBOCD_CODE) END
  END  --贴现申请人证件类型 --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖] 银票直贴改成默认值'A01'
/*,CASE WHEN H.TYSHXYDM IS NOT NULL THEN H.TYSHXYDM
      WHEN LENGTH(H.ID_NO) = 18 THEN H.ID_NO
      WHEN H.ORGANIZATIONCODE IS NOT NULL THEN REPLACE(H.ORGANIZATIONCODE,'-','')
 ELSE NVL2(D.CUST_ID,D.ID_NO, F.id_no) END --贴现申请人证件代码*/
 
,CASE WHEN (SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) AND TRIM(B.BILL_TYPE) = '1') THEN
 NVL( CASE WHEN H.TYSHXYDM IS NOT NULL THEN H.TYSHXYDM
      WHEN LENGTH(H.ID_NO) = 18 THEN H.ID_NO
      WHEN H.ORGANIZATIONCODE IS NOT NULL THEN REPLACE(H.ORGANIZATIONCODE,'-','')
 ELSE NVL2(D.CUST_ID,D.ID_NO, F.id_no) END,H3.TYSHXYDM ) 
 ELSE CASE WHEN H.TYSHXYDM IS NOT NULL THEN H.TYSHXYDM
      WHEN LENGTH(H.ID_NO) = 18 THEN H.ID_NO
      WHEN H.ORGANIZATIONCODE IS NOT NULL THEN REPLACE(H.ORGANIZATIONCODE,'-','')
 ELSE NVL2(D.CUST_ID,D.ID_NO, F.id_no) END END --贴现申请人证件代码   --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖]  改直贴

/*,NVL2(D.CUST_ID, 'D01', F.DEPT_TYPE)--贴现申请人国民经济部门*/
/*,CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104') AND TRIM(B.BILL_TYPE) = '1'THEN 'C01'
  ELSE NVL2(D.CUST_ID, 'D01', F.DEPT_TYPE) END--贴现申请人国民经济部门  --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖] 银票直贴改成默认值'C01'
*/
--[2025-09-18] [周立鹏] [JLBA202508260006_金融基础数据票据融资信息表逻辑变更][李楠] 直贴或直转默认C01
,CASE WHEN T.CUST_ID IS NOT NULL THEN 'C01' END --贴现申请人国民经济部门 

/*,NVL2(D.CUST_ID,'100',SUBSTRB(TRIM(H.CORP_BUSINSESS_TYPE), 0, 3))--贴现申请人行业*/
,CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) AND TRIM(B.BILL_TYPE) = '1' THEN NVL(NVL2(D.CUST_ID,'100',SUBSTRB(TRIM(H.CORP_BUSINSESS_TYPE), 0, 3)),SUBSTRB(TRIM(H3.CORP_BUSINSESS_TYPE), 0, 3))
       ELSE NVL2(D.CUST_ID,'100',SUBSTRB(TRIM(H.CORP_BUSINSESS_TYPE), 0, 3)) END --贴现申请人行业 --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖] 银票直贴改成票据系统对公客户管理，取前三位

--[2025-09-18] [周立鹏] [票据转贴贴现申请人需求][李楠] 取行内转贴的贴现申请人信息
--,CASE WHEN NVL(D.REGION_CD,F.REGION_CD) = '999999' THEN H.ORG_AREA ELSE NVL(D.REGION_CD,F.REGION_CD) END --贴现申请人地区代码
,H.ORG_AREA --贴现申请人地区代码

,CD4.PBOCD_CODE--贴现申请人经济成分
/*,NVL2(H.CUST_ID,DECODE(H.CORP_SCALE, 'B','CS01',
                                       'M','CS02',
                                       'S','CS03',
                                       'T','CS04',
                                           'CS05'),'')--贴现人情人企业规模*/
,CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) AND TRIM(B.BILL_TYPE) = '1' THEN
NVL(NVL2(H.CUST_ID,DECODE(H.CORP_SCALE, 'B','CS01',
                                         'M','CS02',
                                         'S','CS03',
                                         'T','CS04',
                                             'CS05'),''),NVL2(H3.CUST_ID,DECODE(H3.CORP_SCALE, 'B','CS01',
                                                                                                 'M','CS02',
                                                                                                 'S','CS03',
                                                                                                 'T','CS04',
                                                                                                     'CS05'),''))
 ELSE NVL2(H.CUST_ID,DECODE(H.CORP_SCALE, 'B','CS01',
                                            'M','CS02',
                                            'S','CS03',
                                            'T','CS04',
                                                'CS05'),'') END--[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖]
,NVL(CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130102','130105' ) AND  B.BILL_TYPE = '2' THEN B.AFF_NAME ELSE  H2.CUST_NAM END,
NVL2(FR.FINA_ORG_NAME_FR,FR.FINA_ORG_NAME_FR,B.PAY_BANK_NAME)) --承兑人名称
--,CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130102','130105' ) AND  B.BILL_TYPE = '2' THEN B.AFF_NAME ELSE  H2.CUST_NAM END--承兑人名称  --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖] --承兑人名称 --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖]
,'A01'--承兑人证件类型
,NVL(CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130102','130105' ) AND  B.BILL_TYPE = '2' THEN H1.ID_NO ELSE H2.ID_NO END,
NVL2(FR.FINA_ORG_NAME_FR,FR.LEGAL_TYSHXYDM_FR,B.PAY_BANK_CODE))--承兑人证件代码 --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖]

/*,B.AFF_NAME --出票人名称*/
,B.AFF_NAME --出票人名称  --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖]
/*,''--CD5.PBOCD_CODE--出票人证件类型*/
,'A01'--出票人证件类型--[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖] 空值改成默认值'A01'

--[2026-04-21] [周立鹏] [JLBA202510210010_关于金数平台银承部分报表取数规则及展示的优化的需求][孙平刚] 优化出票人证件类型、号码取数口径
,B.AFF_ID_NO--B.ID_NO--出票人证件代码--20250703_zhoulp 刘洋：按下面这个口径取出来的不对，还原回去
--, H1.ID_NO--出票人证件代码  --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖] 默认空值改成统一社会信用代码
,TO_CHAR(B.OPEN_DATE, 'YYYY-MM-DD')--出票日期
,TO_CHAR(B.MATU_DATE, 'YYYY-MM-DD')--票据到期日期
,CASE WHEN A.LOAN_BUY_INT = 'N' THEN TO_CHAR(A.DRAWDOWN_DT, 'YYYY-MM-DD')
      WHEN A.LOAN_BUY_INT = 'Y' THEN TO_CHAR(A.IN_DRAWDOWN_DT, 'YYYY-MM-DD')
      ELSE TO_CHAR(A.DRAWDOWN_DT, 'YYYY-MM-DD') END AS TRANS_DATE  --交易日期 全是N 全是空
,trim(B.CURR_CD)  --币种
,A.DRAWDOWN_AMT --B.AMOUNT--票面金额
,A.DRAWDOWN_AMT * R.CCY_RATE--B.AMOUNT --票面金额折人民币
,A.CURR_CD--贴现币种
--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 贴现金额：发生方向与存量一致，收回方向=票面金额 实际无改动
,A.DRAWDOWN_AMT - nvl(A.DISCOUNT_INTEREST,0)  --B.AMOUNT - B.INT --贴现金额
,trunc((A.DRAWDOWN_AMT - nvl(A.DISCOUNT_INTEREST,0))* R.CCY_RATE,2)   --trunc((B.AMOUNT - B.INT)* R.CCY_RATE,2) --贴现金额折人民币
,A.REAL_INT_RAT--贴现利率
,CASE
              WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) THEN
               'A01'
              WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130102','130105' ) THEN
               'A02'
            END AS TRANS_TYPE --交易类型
--[2026-02-06] [周立鹏] [无需求][李楠] 调整流水号与五大篇章一致  因为剔除了直转流水，所以不需要1和11确保唯一了
/*,CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) THEN '1'
      WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130102','130105' ) THEN '11'  ---20220701-夏文博
 END AS SERIAL_NO --交易流水号*/
,'1' AS SERIAL_NO --交易流水号
,CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) THEN '01MRDY'
      WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130102','130105' ) THEN '02MRDY'  ---20220701-夏文博
 END || sys_guid() AS REPORT_ID
,IS_DATE

--优化条线 zhoulp_20251011 
/*,CASE WHEN A.ORG_NUM LIKE '5100%' THEN '99'
      WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130102','130105' ) THEN 'SC'
      ELSE '99' END AS BIZ_LINE_ID   --条线*/
,CASE WHEN A.ORG_NUM LIKE '51%' THEN '99'
          WHEN A.ORG_NUM LIKE '52%' THEN '99'
          WHEN A.ORG_NUM LIKE '53%' THEN '99'
          WHEN A.ORG_NUM LIKE '54%' THEN '99'
          WHEN A.ORG_NUM LIKE '55%' THEN '99'
          WHEN A.ORG_NUM LIKE '56%' THEN '99'
          WHEN A.ORG_NUM LIKE '57%' THEN '99'
          WHEN A.ORG_NUM LIKE '58%' THEN '99'
          WHEN A.ORG_NUM LIKE '59%' THEN '99'
          WHEN A.ORG_NUM LIKE '60%' THEN '99'
          --WHEN T.acct_Num IS NOT NULL AND T1.acct_Num IS NOT NULL THEN 'SC'  --直转的归归金市
          WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130102','130105' ) THEN 'SC'  --转贴全归金市
          WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) AND B.BILL_TYPE = '2' THEN 'E'--直贴商票归公司
          ELSE '99' END AS BIZ_LINE_ID --业务条线

,'' AS VERIFY_STATUS
,IS_DATE AS BSCJRQ
,CASE
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
            '600000'----20231013王晓彬
           ELSE '990000'
END FRNBJGH
-- ZHOULP20251201 分行买入后当月直转到总行的，取分行直贴买入那笔作为发生方向，机构取总行；取总行卖出那笔作为收回方向，贴现方式改为直贴
,A.ORG_NUM AS NBJGH 
--,NVL(T1.ORG_NUM,A.ORG_NUM) AS NBJGH 
FROM SMTMODS.L_ACCT_LOAN A --贷款借据信息表
LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B --商业汇票票面信息表
  ON A.ACCT_NUM = B.BILL_NUM
 AND B.DATA_DATE = IS_DATE

LEFT JOIN (SELECT * FROM(
SELECT A.CUST_ID,A.FINA_ORG_CODE,A.FINA_ORG_NAME,B.FINA_ORG_NAME FINA_ORG_NAME_FR,B.LEGAL_TYSHXYDM LEGAL_TYSHXYDM_FR ,
ROW_NUMBER()OVER(PARTITION BY A.FINA_ORG_NAME,A.FINA_ORG_CODE ORDER BY A.FINA_ORG_NAME) RN
FROM (SELECT * FROM (
SELECT CUST_ID,FINA_ORG_CODE,FINA_ORG_NAME,TYSHXYDM,LEGAL_TYSHXYDM,ROW_NUMBER() OVER(PARTITION BY FINA_ORG_NAME,FINA_ORG_CODE ORDER BY TYSHXYDM) RN
FROM SMTMODS.L_CUST_BILL_TY A WHERE A.DATA_DATE=IS_DATE)A WHERE A.RN=1)A

LEFT JOIN (SELECT * FROM (
SELECT A.*,ROW_NUMBER() OVER(PARTITION BY TYSHXYDM ORDER BY FINA_ORG_NAME) RN
FROM SMTMODS.L_CUST_BILL_TY A WHERE DATA_DATE=IS_DATE AND LEGAL_FLAG='Y'
AND TYSHXYDM IS NOT NULL AND TYSHXYDM<>'000000000000000000'
AND FINA_ORG_NAME NOT LIKE '%存托%' AND FINA_ORG_NAME NOT LIKE '%资管%' AND FINA_ORG_NAME NOT LIKE '%禁用%'
) A WHERE A.RN=1) B
ON A.LEGAL_TYSHXYDM=B.TYSHXYDM) WHERE RN = 1)FR
ON B.PAY_BANK_ID = FR.FINA_ORG_CODE

-- ZHOULP20251201 分行买入后当月直转到总行的，取分行直贴买入那笔作为发生方向，机构取总行；取总行卖出那笔作为收回方向，贴现方式改为直贴
LEFT JOIN SMTMODS.L_ACCT_LOAN T1
  ON T1.DATA_DATE=IS_DATE 
 AND a.acct_Num||A.draft_rng=T1.acct_Num||T1.draft_rng 
 AND SUBSTR(T1.ITEM_CD,1,6)  IN ('130102','130105')

--[2025-09-18] [周立鹏] [票据转贴贴现申请人需求][李楠] 取行内转贴的贴现申请人信息
LEFT JOIN SMTMODS.L_ACCT_LOAN T
  ON T.DATA_DATE=IS_DATE 
 AND a.acct_Num||A.draft_rng=T.acct_Num||T.draft_rng 
 AND SUBSTR(T.ITEM_CD,1,6)  IN ('130101','130104')

LEFT JOIN SMTMODS.L_CUST_P D --对私客户补充信息表
  ON T.CUST_ID = D.CUST_ID
 AND D.DATA_DATE = IS_DATE
LEFT JOIN SMTMODS.L_CUST_ALL F
  ON T.CUST_ID = F.CUST_ID
 AND F.DATA_DATE = IS_DATE
LEFT JOIN SMTMODS.L_CUST_C H --对公客户补充信息表
  ON T.CUST_ID = H.CUST_ID
 AND H.DATA_DATE = IS_DATE
LEFT JOIN SMTMODS.L_CUST_C H1 --对公客户补充信息表
  ON B.AFF_CODE = H1.CUST_ID  --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖] 贷款借据信息表0000开头的客户号与cust_c表关联不上
 AND H1.DATA_DATE = IS_DATE
LEFT JOIN SMTMODS.L_CUST_C H2 --对公客户补充信息表
  ON B.PAY_CUSID = H2.CUST_ID
  AND H2.DATA_DATE = IS_DATE  --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖]
LEFT JOIN L_CODE_DICTIONARY CD1
  ON D.id_type = CD1.L_CODE
 AND CD1.CODE_CLMN_NAME = 'ID_TYPE'
LEFT JOIN L_CODE_DICTIONARY CD2
  ON F.ID_TYPE = CD2.L_CODE
 AND CD2.CODE_CLMN_NAME = 'BZR_ID_TYPE'
LEFT JOIN L_CODE_DICTIONARY CD4
  ON H.CORP_HOLD_TYPE = CD4.L_CODE
 AND CD4.CODE_CLMN_NAME = 'CORP_HOLD_TYPE' --企业控股类型
LEFT JOIN SMTMODS.L_PUBL_RATE R --汇率信息表
  ON R.DATA_DATE = IS_DATE
 AND R.BASIC_CCY = A.CURR_CD
 AND R.FORWARD_CCY = 'CNY'
 AND R.DATA_DATE = IS_DATE
LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
-- ZHOULP20251201 分行买入后当月直转到总行的，取分行直贴买入那笔作为发生方向，机构取总行；取总行卖出那笔作为收回方向，贴现方式改为直贴
      ON OB.ORG_NUM=A.ORG_NUM AND OB.DATA_DATE=IS_DATE
      --ON OB.ORG_NUM=NVL(T1.ORG_NUM,A.ORG_NUM) AND OB.DATA_DATE=IS_DATE

LEFT JOIN SMTMODS.L_CUST_BILL_TY TY
  ON TY.CUST_ID = A.CUST_ID
 AND TY.DATA_DATE = IS_DATE
LEFT JOIN (SELECT * FROM (SELECT DATA_DATE,ID_NO,TYSHXYDM,CORP_BUSINSESS_TYPE,CUST_ID,CORP_SCALE,CUSTSTATUS,
  ROW_NUMBER() OVER(PARTITION BY ID_NO,TYSHXYDM,CORP_BUSINSESS_TYPE,CUST_ID,CORP_SCALE ORDER BY ID_NO,TYSHXYDM ) RN FROM SMTMODS.L_CUST_C 
      WHERE DATA_DATE=IS_DATE) WHERE DATA_DATE=IS_DATE AND RN='1') H3
  ON H3.ID_NO = TY.TYSHXYDM AND  H3.CUSTSTATUS='01'
  AND H3.DATA_DATE = IS_DATE  --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖] 贷款借据信息表0000开头的客户号与cust_c表关联不上

WHERE A.DATA_DATE = IS_DATE
  AND SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104','130102','130105' ) --直贴科目号--20220701-夏文博改
  AND TO_CHAR(A.DRAWDOWN_DT,'YYYYMM') = SUBSTR(IS_DATE,1,6)
  --AND TO_CHAR(A.MATURITY_DT,'YYYYMM') = SUBSTR(IS_DATE,1,6)
  AND (NVL(A.LOAN_ACCT_BAL,0) + NVL(A.INT_ADJEST_AMT,0) = 0 OR (NVL(A.LOAN_ACCT_BAL,0) + NVL(A.INT_ADJEST_AMT,0)) * R.CCY_RATE = 0)
  AND NOT EXISTS (-- ZHOULP20251201 分行买入后当月直转到总行的，取分行直贴买入那笔作为发生方向，机构取总行；取总行卖出那笔作为收回方向，贴现方式改为直贴
  SELECT 1 FROM JS_205_PJRZFS_TMP3 T3 
  WHERE T3.acct_Num||T3.draft_rng=A.acct_Num||A.draft_rng 
  AND (SUBSTR(A.ITEM_CD,1,6)  in ('130102','130105') OR 
       (NVL(T3.LOAN_ACCT_BAL_ZHITIE,0) + NVL(T3.INT_ADJEST_AMT_ZHITIE,0) = 0 AND NVL(T3.LOAN_ACCT_BAL_ZHUANTIE,0) + NVL(T3.INT_ADJEST_AMT_ZHUANTIE,0) <> 0))
  )
;
COMMIT;

--收回方向
INSERT INTO PBOCD_JS_205_PJRZFS
(DATA_DATE --数据日期
  ,ORG_CODE --金融机构代码
  ,ORG_NUM --内部机构号
  ,REG_REGION_CODE --金融机构地区代码
  ,DISCOUNT_TYPE --贴现方式
  ,BILL_TYPE ---票据种类
  ,BILL_MEDIUM --票据介质
  ,BILL_NUM --票据编号
  ,DISCOUNT_ID_TYPE --贴现申请人证件类型
  ,DISCOUNT_ID_NO --贴现申请人证件代码
  ,DISCOUNT_DEPT_TYPE --贴现申请人国民经济部门
  ,DISCOUNT_INDUSTRY_TYPE --贴现申请人行业
  ,DISCOUNT_REG_AREA_CODE --贴现申请人地区代码
  ,DISCOUNT_ENT_CON_ECO_ELEM --贴现申请人经济成分
  ,DISCOUNT_ENT_SCALE --贴现申请人企业规模
  ,ACCEPT_NAME --承兑人名称
  ,ACCEPT_ID_TYPE --承兑人证件类型
  ,ACCEPT_ID_NO --承兑人证件代码
  ,AFF_NAME --出票人名称
  ,AFF_ID_TYPE --出票人证件类型
  ,AFF_ID_NO --出票人证件代码
  ,OPEN_DATE --出票日期
  ,BILL_DUE_DATE --票据到期日期
  ,TRANS_DATE --交易日期
  ,BILL_CURR_CODE --币种
  ,BILL_AMT --票面金额
  ,BILL_AMT_RMB --票面金额折人民币
  ,DISCOUNT_CURR_CODE --贴现币种
  ,DISCOUNT_AMT --贴现金额
  ,DISCOUNT_AMT_RMB --贴现金额折人民币
  ,INT_RATE --贴现利率
  ,TRANS_TYPE --交易类型
  ,SERIAL_NO --交易流水号
  ,REPORT_ID
  ,CJRQ
  ,BIZ_LINE_ID
  ,VERIFY_STATUS
  ,BSCJRQ
  ,FRNBJGH
  ,NBJGH
)
select /*+ PARALLEL(8)*/
 TO_CHAR(TO_DATE(IS_DATE,'YYYY-MM-DD'),'YYYY-MM-DD')     --数据日期
,NVL(OB.ID_NO,OB.UP_ID_NO) --金融机构代码
,A.ORG_NUM   --机构号
,OB.REGION_CD --金融机构地区代码
-- ZHOULP20251201 分行买入后当月直转到总行的，取分行直贴买入那笔作为发生方向，机构取总行；取总行卖出那笔作为收回方向，贴现方式改为直贴
,CASE WHEN T.acct_Num IS NOT NULL THEN '01'
      WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) THEN '01'
      WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130102','130105' ) THEN '02'  ---20220701-夏文博
      ELSE NULL END         --贴现方式 直贴
,CASE WHEN TRIM(B.BILL_TYPE) = '1' THEN '01' --银行承兑汇票
      WHEN B.BILL_TYPE = '2' THEN '02' --商业承兑汇票
       END AS BILL_TYPE  --票据种类
,CASE WHEN B.IS_P_BILL = 'Y' THEN '01'
      ELSE '02' END AS BILL_MEDIUM --票据介质 01 纸票 02 电票
,a.acct_Num||A.draft_rng --票据编号
/*,CASE WHEN H.TYSHXYDM IS NOT NULL THEN 'A01'
      WHEN LENGTH(H.ID_NO) = 18 THEN 'A01'
      WHEN H.ORGANIZATIONCODE IS NOT NULL THEN 'A02'
 ELSE NVL(CD1.PBOCD_CODE,CD2.PBOCD_CODE) END --贴现申请人证件类型*/
,CASE WHEN SUBSTR(A.ITEM_CD,1,6) IN ('130101','130104' ) AND  B.BILL_TYPE = '1' THEN 'A01'
  ELSE CASE WHEN H.TYSHXYDM IS NOT NULL THEN 'A01'
        WHEN LENGTH(H.ID_NO) = 18 THEN 'A01'
        WHEN H.ORGANIZATIONCODE IS NOT NULL THEN 'A02'
        ELSE NVL(CD1.PBOCD_CODE,CD2.PBOCD_CODE) END
  END  --贴现申请人证件类型 --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖] 银票直贴改成默认值'A01'
/*,CASE WHEN H.TYSHXYDM IS NOT NULL THEN H.TYSHXYDM
      WHEN LENGTH(H.ID_NO) = 18 THEN H.ID_NO
      WHEN H.ORGANIZATIONCODE IS NOT NULL THEN REPLACE(H.ORGANIZATIONCODE,'-','')
 ELSE NVL2(D.CUST_ID,D.ID_NO, F.id_no) END --贴现申请人证件代码*/
,CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) AND  B.BILL_TYPE = '1'THEN
 NVL( CASE WHEN H.TYSHXYDM IS NOT NULL THEN H.TYSHXYDM
      WHEN LENGTH(H.ID_NO) = 18 THEN H.ID_NO
      WHEN H.ORGANIZATIONCODE IS NOT NULL THEN REPLACE(H.ORGANIZATIONCODE,'-','')
 ELSE NVL2(D.CUST_ID,D.ID_NO, F.id_no) END,H3.TYSHXYDM ) 
 ELSE CASE WHEN H.TYSHXYDM IS NOT NULL THEN H.TYSHXYDM
      WHEN LENGTH(H.ID_NO) = 18 THEN H.ID_NO
      WHEN H.ORGANIZATIONCODE IS NOT NULL THEN REPLACE(H.ORGANIZATIONCODE,'-','')
 ELSE NVL2(D.CUST_ID,D.ID_NO, F.id_no) END END --贴现申请人证件代码   --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖]  改直贴

/*,NVL2(D.CUST_ID, 'D01', F.DEPT_TYPE)--贴现申请人国民经济部门*/
/*, CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104') AND TRIM(B.BILL_TYPE) = '1'THEN 'C01'
  ELSE NVL2(D.CUST_ID, 'D01', F.DEPT_TYPE) END --贴现申请人国民经济部门 --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖] 银票直贴改成默认值'C01'
*/
--[2025-09-18] [周立鹏] [JLBA202508260006_金融基础数据票据融资信息表逻辑变更][李楠] 直贴或直转默认C01
,CASE WHEN T.CUST_ID IS NOT NULL THEN 'C01' END --贴现申请人国民经济部门 

/*,NVL2(D.CUST_ID,'100',SUBSTRB(TRIM(H.CORP_BUSINSESS_TYPE), 0, 3))--贴现申请人行业*/
,CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) AND TRIM(B.BILL_TYPE) = '1' THEN NVL(NVL2(D.CUST_ID,'100',SUBSTRB(TRIM(H.CORP_BUSINSESS_TYPE), 0, 3)),SUBSTRB(TRIM(H3.CORP_BUSINSESS_TYPE), 0, 3))
       ELSE NVL2(D.CUST_ID,'100',SUBSTRB(TRIM(H.CORP_BUSINSESS_TYPE), 0, 3)) END --贴现申请人行业 --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖] 银票直贴改成票据系统对公客户管理，取前三位

--[2025-09-18] [周立鹏] [票据转贴贴现申请人需求][李楠] 取行内转贴的贴现申请人信息
--,CASE WHEN NVL(D.REGION_CD,F.REGION_CD) = '999999' THEN H.ORG_AREA ELSE NVL(D.REGION_CD,F.REGION_CD) END --贴现申请人地区代码
,H.ORG_AREA --贴现申请人地区代码

,CD4.PBOCD_CODE--贴现申请人经济成分
/*,NVL2(H.CUST_ID,DECODE(H.CORP_SCALE, 'B','CS01',
                                       'M','CS02',
                                       'S','CS03',
                                       'T','CS04',
                                           'CS05'),'')--贴现人情人企业规模*/
,CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) AND TRIM(B.BILL_TYPE) = '1' THEN
NVL(NVL2(H.CUST_ID,DECODE(H.CORP_SCALE, 'B','CS01',
                                          'M','CS02',
                                          'S','CS03',
                                          'T','CS04',
                                              'CS05'),''),NVL2(H3.CUST_ID,DECODE(H3.CORP_SCALE, 'B','CS01',
                                                                                                'M','CS02',
                                                                                                'S','CS03',
                                                                                                'T','CS04',
                                                                                                    'CS05'),''))
 ELSE NVL2(H.CUST_ID,DECODE(H.CORP_SCALE, 'B','CS01',
                                            'M','CS02',
                                            'S','CS03',
                                            'T','CS04',
                                                'CS05'),'') END--[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖]
/*,NVL2(FR.FINA_ORG_NAME_FR,FR.FINA_ORG_NAME_FR,B.PAY_BANK_NAME) --承兑人名称*/
,NVL(CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130102','130105' ) AND  B.BILL_TYPE = '2' THEN B.AFF_NAME ELSE  H2.CUST_NAM END,
NVL2(FR.FINA_ORG_NAME_FR,FR.FINA_ORG_NAME_FR,B.PAY_BANK_NAME))--承兑人名称  --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖] --承兑人名称 --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖]
,'A01'--承兑人证件类型
/*,NVL2(FR.FINA_ORG_NAME_FR,FR.LEGAL_TYSHXYDM_FR,B.PAY_BANK_CODE) --承兑人证件代码*/
,NVL(CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130102','130105' ) AND  B.BILL_TYPE = '2' THEN H1.ID_NO ELSE H2.ID_NO END,
NVL2(FR.FINA_ORG_NAME_FR,FR.LEGAL_TYSHXYDM_FR,B.PAY_BANK_CODE))--承兑人证件代码 --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖]

/*,B.AFF_NAME --出票人名称*/
,B.AFF_NAME --出票人名称  --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖]
/*,''--CD5.PBOCD_CODE--出票人证件类型*/
,'A01' --出票人证件类型  --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖]

--[2026-04-21] [周立鹏] [JLBA202510210010_关于金数平台银承部分报表取数规则及展示的优化的需求][孙平刚] 优化出票人证件类型、号码取数口径
,B.AFF_ID_NO--B.ID_NO--出票人证件代码--20250703_zhoulp 刘洋：按下面这个口径取出来的不对，还原回去
--, H1.ID_NO--出票人证件代码  --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖] 默认空值改成统一社会信用代码
,TO_CHAR(B.OPEN_DATE, 'YYYY-MM-DD')--出票日期
,TO_CHAR(B.MATU_DATE, 'YYYY-MM-DD')--票据到期日期
,TO_CHAR(A.MATURITY_DT, 'YYYY-MM-DD') AS TRANS_DATE  --交易日期 全是N 全是空
,trim(B.CURR_CD)  --币种
,A.DRAWDOWN_AMT --B.AMOUNT--票面金额
,A.DRAWDOWN_AMT * R.CCY_RATE--B.AMOUNT --票面金额折人民币
,A.CURR_CD--贴现币种

--[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 贴现金额：发生方向与存量一致，收回方向=票面金额
/*,A.DRAWDOWN_AMT - nvl(A.DISCOUNT_INTEREST,0)  --B.AMOUNT - B.INT --贴现金额

--[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
--,trunc((B.AMOUNT - B.INT)* R.CCY_RATE,2) --贴现金额折人民币
,trunc((A.DRAWDOWN_AMT - nvl(A.DISCOUNT_INTEREST,0))* R.CCY_RATE,2) --贴现金额折人民币*/
,A.DRAWDOWN_AMT AS DISCOUNT_AMT--贴现金额
,A.DRAWDOWN_AMT * R.CCY_RATE AS DISCOUNT_AMT_RMB--贴现金额折人民币


,A.REAL_INT_RAT--贴现利率
,'B01' AS TRANS_TYPE --交易类型

--[2026-02-06] [周立鹏] [无需求][李楠] 调整流水号与五大篇章一致  因为剔除了直转流水，所以不需要0和00确保唯一了
/*,CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) THEN '0'
      WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130102','130105' ) THEN '00'  ---20220701-夏文博
 END AS SERIAL_NO --交易流水号*/
,'0' AS SERIAL_NO --交易流水号
,CASE WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) THEN '01MCDY'
      WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130102','130105' ) THEN '02MCDY'  ---20220701-夏文博
 END || sys_guid() AS REPORT_ID
,IS_DATE

--优化条线 zhoulp_20251011 
/*,CASE WHEN A.ORG_NUM LIKE '5100%' THEN '99'
      WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130102','130105' ) THEN 'SC'
      ELSE '99' END AS BIZ_LINE_ID   --条线*/
,CASE WHEN A.ORG_NUM LIKE '51%' THEN '99'
          WHEN A.ORG_NUM LIKE '52%' THEN '99'
          WHEN A.ORG_NUM LIKE '53%' THEN '99'
          WHEN A.ORG_NUM LIKE '54%' THEN '99'
          WHEN A.ORG_NUM LIKE '55%' THEN '99'
          WHEN A.ORG_NUM LIKE '56%' THEN '99'
          WHEN A.ORG_NUM LIKE '57%' THEN '99'
          WHEN A.ORG_NUM LIKE '58%' THEN '99'
          WHEN A.ORG_NUM LIKE '59%' THEN '99'
          WHEN A.ORG_NUM LIKE '60%' THEN '99'
          WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130102','130105' ) THEN 'SC'  --转贴全归金市
          WHEN SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104' ) AND B.BILL_TYPE = '2' THEN 'E'--直贴商票归公司
          ELSE '99' END AS BIZ_LINE_ID --业务条线
      
,'' AS VERIFY_STATUS
,IS_DATE AS BSCJRQ
,CASE
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
            '600000'----20231013王晓彬
           ELSE '990000'
END FRNBJGH
,A.ORG_NUM AS NBJGH
FROM SMTMODS.L_ACCT_LOAN A --贷款借据信息表
LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B --商业汇票票面信息表
  ON A.ACCT_NUM = B.BILL_NUM
 AND B.DATA_DATE = IS_DATE

LEFT JOIN (SELECT * FROM(
SELECT A.CUST_ID,A.FINA_ORG_CODE,A.FINA_ORG_NAME,B.FINA_ORG_NAME FINA_ORG_NAME_FR,B.LEGAL_TYSHXYDM LEGAL_TYSHXYDM_FR ,
ROW_NUMBER()OVER(PARTITION BY A.FINA_ORG_NAME,A.FINA_ORG_CODE ORDER BY A.FINA_ORG_NAME) RN
FROM (SELECT * FROM (
SELECT CUST_ID,FINA_ORG_CODE,FINA_ORG_NAME,TYSHXYDM,LEGAL_TYSHXYDM,ROW_NUMBER() OVER(PARTITION BY FINA_ORG_NAME,FINA_ORG_CODE ORDER BY TYSHXYDM) RN
FROM SMTMODS.L_CUST_BILL_TY A WHERE A.DATA_DATE=IS_DATE)A WHERE A.RN=1)A

LEFT JOIN (SELECT * FROM (
SELECT A.*,ROW_NUMBER() OVER(PARTITION BY TYSHXYDM ORDER BY FINA_ORG_NAME) RN
FROM SMTMODS.L_CUST_BILL_TY A WHERE DATA_DATE=IS_DATE AND LEGAL_FLAG='Y'
AND TYSHXYDM IS NOT NULL AND TYSHXYDM<>'000000000000000000'
AND FINA_ORG_NAME NOT LIKE '%存托%' AND FINA_ORG_NAME NOT LIKE '%资管%' AND FINA_ORG_NAME NOT LIKE '%禁用%'
) A WHERE A.RN=1) B
ON A.LEGAL_TYSHXYDM=B.TYSHXYDM) WHERE RN = 1)FR
ON B.PAY_BANK_ID = FR.FINA_ORG_CODE

--[2025-09-18] [周立鹏] [票据转贴贴现申请人需求][李楠] 取行内转贴的贴现申请人信息
LEFT JOIN SMTMODS.L_ACCT_LOAN T
  ON T.DATA_DATE=IS_DATE 
 AND a.acct_Num||A.draft_rng=T.acct_Num||T.draft_rng 
 AND SUBSTR(T.ITEM_CD,1,6)  IN ('130101','130104')
 
LEFT JOIN SMTMODS.L_CUST_P D --对私客户补充信息表
  ON T.CUST_ID = D.CUST_ID
 AND D.DATA_DATE = IS_DATE
LEFT JOIN SMTMODS.L_CUST_ALL F
  ON T.CUST_ID = F.CUST_ID
 AND F.DATA_DATE = IS_DATE
LEFT JOIN SMTMODS.L_CUST_C H --对公客户补充信息表
  ON T.CUST_ID = H.CUST_ID
 AND H.DATA_DATE = IS_DATE
LEFT JOIN SMTMODS.L_CUST_C H1 --对公客户补充信息表
  ON B.AFF_CODE = H1.CUST_ID  --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖] 贷款借据信息表0000开头的客户号与cust_c表关联不上
 AND H1.DATA_DATE = IS_DATE
LEFT JOIN SMTMODS.L_CUST_C H2 --对公客户补充信息表
  ON B.PAY_CUSID = H2.CUST_ID
  AND H2.DATA_DATE = IS_DATE  --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖]
LEFT JOIN L_CODE_DICTIONARY CD1
  ON D.id_type = CD1.L_CODE
 AND CD1.CODE_CLMN_NAME = 'ID_TYPE'
LEFT JOIN L_CODE_DICTIONARY CD2
  ON F.ID_TYPE = CD2.L_CODE
 AND CD2.CODE_CLMN_NAME = 'BZR_ID_TYPE'
LEFT JOIN L_CODE_DICTIONARY CD4
  ON H.CORP_HOLD_TYPE = CD4.L_CODE
 AND CD4.CODE_CLMN_NAME = 'CORP_HOLD_TYPE' --企业控股类型
LEFT JOIN SMTMODS.L_PUBL_RATE R --汇率信息表
  ON R.DATA_DATE = IS_DATE
 AND R.BASIC_CCY = A.CURR_CD
 AND R.FORWARD_CCY = 'CNY'
 AND R.DATA_DATE = IS_DATE
LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=A.ORG_NUM AND OB.DATA_DATE=IS_DATE

LEFT JOIN SMTMODS.L_CUST_BILL_TY TY
  ON TY.CUST_ID = A.CUST_ID
 AND TY.DATA_DATE = IS_DATE
LEFT JOIN (SELECT * FROM (SELECT DATA_DATE,ID_NO,TYSHXYDM,CORP_BUSINSESS_TYPE,CUST_ID,CORP_SCALE,CUSTSTATUS,
  ROW_NUMBER() OVER(PARTITION BY ID_NO,TYSHXYDM,CORP_BUSINSESS_TYPE,CUST_ID,CORP_SCALE ORDER BY ID_NO,TYSHXYDM ) RN FROM SMTMODS.L_CUST_C 
      WHERE DATA_DATE=IS_DATE) WHERE DATA_DATE=IS_DATE AND RN='1')  H3
  ON H3.ID_NO = TY.TYSHXYDM AND  H3.CUSTSTATUS='01'
  AND H3.DATA_DATE = IS_DATE  --[2025-06-19] [白杨] [JLBA202504090006_关于金融市场部金融基础数据票据融资信息表需求变更的需求 ][徐晖] 贷款借据信息表0000开头的客户号与cust_c表关联不上

WHERE A.DATA_DATE = IS_DATE
  AND SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104','130102','130105' ) --直贴科目号--20220701-夏文博改
  AND TO_CHAR(A.DRAWDOWN_DT,'YYYYMM') = SUBSTR(IS_DATE,1,6)
  --AND TO_CHAR(A.MATURITY_DT,'YYYYMM') = SUBSTR(IS_DATE,1,6)
  AND (NVL(A.LOAN_ACCT_BAL,0) + NVL(A.INT_ADJEST_AMT,0) = 0 OR (NVL(A.LOAN_ACCT_BAL,0) + NVL(A.INT_ADJEST_AMT,0)) * R.CCY_RATE = 0)
  AND NOT EXISTS (-- ZHOULP20251201 分行买入后当月直转到总行的，取分行直贴买入那笔作为发生方向，机构取总行；取总行卖出那笔作为收回方向，贴现方式改为直贴
  SELECT 1 FROM JS_205_PJRZFS_TMP3 T3 
  WHERE SUBSTR(A.ITEM_CD,1,6)  in ('130101','130104') AND T3.acct_Num||T3.draft_rng=A.acct_Num||A.draft_rng 
  )
;
COMMIT;
---------------------------------------------------------------------------

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 移到前面去了
  --把贴现方式是01，票据种类是02的改到公司条线
/*UPDATE PBOCD_JS_205_PJRZFS
   SET BIZ_LINE_ID = 'E'
 WHERE CJRQ = IS_DATE AND FRNBJGH = '990000'
   AND DISCOUNT_TYPE = '01'
   AND BILL_TYPE = '02';
COMMIT;*/

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
/*UPDATE PBOCD_JS_205_PJRZFS SET AFF_NAME='吉林省通用机械(集团)有限责任公司'
WHERE CJRQ=IS_DATE AND AFF_NAME='吉林省通用机械（集团）有限责任公司';
COMMIT;
UPDATE PBOCD_JS_205_PJRZFS SET AFF_NAME='陕西延长石油(集团)有限责任公司'
WHERE CJRQ=IS_DATE AND AFF_NAME='陕西延长石油（集团）有限责任公司';
COMMIT;
UPDATE PBOCD_JS_205_PJRZFS SET AFF_NAME='双胞胎(集团)股份有限公司'
WHERE CJRQ=IS_DATE AND AFF_NAME='双胞胎（集团）股份有限公司';
COMMIT;
UPDATE PBOCD_JS_205_PJRZFS SET AFF_NAME='山西潞安矿业(集团)有限责任公司'
WHERE CJRQ=IS_DATE AND AFF_NAME='山西潞安矿业（集团）有限责任公司';
COMMIT;
UPDATE PBOCD_JS_205_PJRZFS SET AFF_NAME='大连福佳·大化石油化工有限公司'
WHERE CJRQ=IS_DATE AND AFF_NAME='大连福佳.大化石油化工有限公司';
COMMIT;*/

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
/*--在L_CUST_BILL_TY中个人转不了的，写死，同存量逻辑
UPDATE PBOCD_JS_205_PJRZFS SET ACCEPT_NAME='上海浦东发展银行股份有限公司'
WHERE CJRQ=IS_DATE AND ACCEPT_NAME LIKE '上海浦东发展银行%' AND ACCEPT_ID_NO='9131000013221158XC';
COMMIT;

--票据种类是02的，承兑人名称、证件代码、证件类型按出票人刷
UPDATE PBOCD_JS_205_PJRZFS
   SET ACCEPT_NAME    = AFF_NAME,
       ACCEPT_ID_TYPE = AFF_ID_TYPE,
       ACCEPT_ID_NO   = AFF_ID_NO
 WHERE CJRQ = IS_DATE
   AND BILL_TYPE = '02';
COMMIT;*/

--[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
/*--地区代码
UPDATE PBOCD_JS_205_PJRZFS
   SET DISCOUNT_REG_AREA_CODE = '220200'
 WHERE CJRQ = IS_DATE
   AND DISCOUNT_REG_AREA_CODE = '220271';
COMMIT;

UPDATE PBOCD_JS_205_PJRZFS
   SET DISCOUNT_REG_AREA_CODE = '220201'
 WHERE CJRQ = IS_DATE
   AND DISCOUNT_REG_AREA_CODE = '220272';
COMMIT;

UPDATE PBOCD_JS_205_PJRZFS
   SET DISCOUNT_REG_AREA_CODE = '220104'
 WHERE CJRQ = IS_DATE
   AND DISCOUNT_REG_AREA_CODE = '220172';
COMMIT;*/

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
--公主岭地区代码
/*UPDATE PBOCD_JS_205_PJRZFS
   SET REG_REGION_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND REG_REGION_CODE = '220381';
COMMIT;*/

--[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
/*UPDATE PBOCD_JS_205_PJRZFS
   SET DISCOUNT_REG_AREA_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND DISCOUNT_REG_AREA_CODE = '220381';
COMMIT;*/


--交易日期应该在当月范围内
/*--1、先去还款明细里面查一下
MERGE INTO PBOCD_JS_205_PJRZFS A
USING (SELECT DISTINCT ACCT_NUM, DATE_SOURCESD, REPAY_DT
         FROM SMTMODS.L_TRAN_LOAN_PAYM
        WHERE DATA_DATE BETWEEN SUBSTR(IS_DATE,1,6)||'01' AND IS_DATE AND ACCT_NUM IS NOT NULL) B
ON (A.BILL_NUM = B.ACCT_NUM AND A.DISCOUNT_TYPE = (CASE
WHEN B.DATE_SOURCESD = '票据直贴' THEN '01' ELSE '02' END))
WHEN MATCHED THEN
  UPDATE
     SET A.TRANS_DATE = TO_CHAR(B.REPAY_DT, 'yyyy-mm-dd')
   WHERE A.CJRQ = IS_DATE
     AND SUBSTR(A.TRANS_DATE,1,7) <> SUBSTR(VS_TEXT,1,7);
COMMIT;*/
--2、还款明细里面没有的去借据表取余额变为0的最小日期
INSERT INTO JS_205_PJRZFS_TMP1
  (LOAN_ACCT_BAL,
   ACCT_NUM,
   DRAFT_RNG,
   DATA_DATE)
  SELECT /*+parallel(4)*/
   LOAN_ACCT_BAL,
   ACCT_NUM,
   DRAFT_RNG,
   DATA_DATE
    FROM SMTMODS.L_ACCT_LOAN T
   WHERE T.DATA_DATE BETWEEN SUBSTR(IS_DATE,1,6)||'01' AND IS_DATE
     AND SUBSTR(ITEM_CD, 1, 6) IN ('130101', '130104', '130102', '130105')
     AND EXISTS (SELECT *
            FROM PBOCD_JS_205_PJRZFS A
           WHERE A.CJRQ = IS_DATE
             AND SUBSTR(A.TRANS_DATE,1,7) <> SUBSTR(VS_TEXT,1,7)
             AND A.BILL_NUM = T.ACCT_NUM||T.DRAFT_RNG);
COMMIT;

MERGE INTO PBOCD_JS_205_PJRZFS A
USING (SELECT *
         FROM (SELECT A.*,
                      ROW_NUMBER() OVER(PARTITION BY ACCT_NUM||DRAFT_RNG ORDER BY DATA_DATE) RN
                 FROM JS_205_PJRZFS_TMP1 A
                WHERE LOAN_ACCT_BAL = 0 AND ACCT_NUM IS NOT NULL) B
        WHERE B.RN = 1) B
ON (A.BILL_NUM = B.ACCT_NUM||B.DRAFT_RNG)
WHEN MATCHED THEN
  UPDATE
     SET A.TRANS_DATE = TO_CHAR(TO_DATE(B.DATA_DATE, 'yyyy-mm-dd'),
                                'yyyy-mm-dd')
   WHERE A.CJRQ = IS_DATE
     AND SUBSTR(A.TRANS_DATE,1,7) <> SUBSTR(VS_TEXT,1,7);
COMMIT;

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
