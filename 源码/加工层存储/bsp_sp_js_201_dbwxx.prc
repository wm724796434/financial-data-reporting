CREATE OR REPLACE PROCEDURE BSP_SP_JS_201_DBWXX(IS_DATE    IN VARCHAR2,
                                            OI_RETCODE OUT INTEGER,
                                            OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  --    SP_JS_201_DBWXX
  -- 用途:生成接口表JS_201_DBWXX--担保物信息
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    CAEATE BY USER AT 20200819
  --    MOD BY USER AT 20200819
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段 上线日期：2025-04-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段 上线日期：2025-05-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  --    需求编号：JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段 上线日期：2025-12-30，修改人：周立鹏，提出人：李楠   修改原因：剔除特殊处理
  --    需求编号：无需求，月初跑批处理 上线日期：2026-04-01，修改人：周立鹏，提出人：李楠   修改原因：按发文要求用逗号分割，截取500位
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(2000) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(100); --存储过程执行步骤标志
  NUM               INTEGER;
  VS_LAST_TEXT      VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  VS_NMONTH         VARCHAR2(10);
BEGIN
  VS_TEXT := to_char(to_date(IS_DATE, 'yyyymmdd'), 'yyyy-mm-dd');
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');
  VS_NMONTH := TO_CHAR(TRUNC(TO_DATE(IS_DATE,'YYYYMMDD') + 1),'YYYYMMDD');
  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_201_DBWXX';

  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------

  --清除临时表数据
  EXECUTE IMMEDIATE 'TRUNCATE TABLE GUARANTEE_DBW_TMP01 ';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_201_DBWXX_TMP01 ';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE  JS_102_FTYKHX_TEMP03 '; --历史移植及核销数据

 --历史移植及核销数据
 INSERT INTO JS_102_FTYKHX_TEMP03 (CUST_ID,BS)
    SELECT T.CUST_ID, COUNT(1) BS
      FROM SMTMODS.L_ACCT_LOAN T
     WHERE T.DATA_DATE = IS_DATE
       AND T.CANCEL_FLG='Y' --核销贷款 :只保留贷款未核销客户

     GROUP BY T.CUST_ID;
  COMMIT;

  INSERT INTO JS_201_DBWXX_TMP01
    SELECT T.ACCT_NUM, SUM(LOAN_ACCT_BAL) LOAN_ACCT_BAL
      FROM SMTMODS.L_ACCT_LOAN T
     WHERE T.DATA_DATE = IS_DATE
     AND T.LOAN_STOCKEN_DATE IS NULL    --add by haorui 20250311 JLBA202408200012 资产未转让
     GROUP BY T.ACCT_NUM
    HAVING SUM(LOAN_ACCT_BAL) > 0;
  COMMIT;

   ---担保物信息
  INSERT /*+ APPEND*/
  INTO GUARANTEE_DBW_TMP01 NOLOGGING
    (ORG_NUM,
     GUAR_CONTRACT_NUM,
     BUSINESSCODE,
     COLLATERAL_SERIAL_NUM,
     COLLATERAL_TYPE,
     WARRANT_CODE,
     FIRST_PRIOR_FLAG,
     ASSESS_TYPE,
     ASSESS_METHOD,
     ASSESS_VALUE,
     ASSESS_BASE_DATE,
     COLLATERAL_VALUE,
     PRIORITY_COMPENSATION,
     VALUATION_PERIOD,
     PGBZ,
     RN,
     DATASOURCE,
     CUST_NAME, --客户名称
     CUST_id
     )
SELECT  /*+ ORDERED */
          T.ORG_NUM AS ORG_NUM, --2  内部机构号
          T3.GUAR_CONTRACT_NUM AS GUAR_CONTRACT_NUM, --3  担保合同编码
          T4.CONTRACT_NUM AS BUSINESSCODE, --4  被担保合同编码
          t.GUARANTEE_SERIAL_NUM AS COLLATERAL_SERIAL_NUM,  --5  担保物编码
          T.COLL_TYP  AS COLLATERAL_TYPE, --6  担保物类别
          --[2026-04-01] [周立鹏] [无需求，月初跑批处理][李楠] 按发文要求用逗号分割，截取500位
          Double_Byte_conversion（REGEXP_REPLACE(T.WARRANT_CODE,'[;；、.]', ','),500) AS WARRANT_CODE ,--7  权证编号
          trim(T3.first_flag) AS FIRST_PRIOR_FLAG, --8  是否第一顺位 无
/*          CASE WHEN t.ASSESS_ORG_TYPE='A' THEN '01'
                 WHEN t.ASSESS_ORG_TYPE='B' THEN '02'
                 WHEN t.ASSESS_ORG_TYPE='C' THEN '03'
            END AS ASSESS_TYPE, --9  评估方式*/
            CASE WHEN t.ASSESS_ORG_TYPE='A' THEN '02'
                 WHEN t.ASSESS_ORG_TYPE='B' THEN '01'
                 WHEN t.ASSESS_ORG_TYPE='C' THEN '03'
            END AS ASSESS_TYPE, --9  评估方式 20231020 wxb
          t.ASSESS_WAY AS ASSESS_METHOD, --10 评估方法
          T.COLL_MK_VAL AS ASSESS_VALUE, --11 评估价值
          to_char(t.NEWLY_ASSESS_DT,'yyyymmdd') AS ASSESS_BASE_DATE, --12 评估基准日  暂未找到
          T.COLL_ORG_VAL AS COLLATERAL_VALUE, --13 担保物账面价值
          T3.priority_amount, --14 优先受偿权数额  待映射？
          T.value_cycle, --15 估值周期  待映射？
          CASE WHEN T.GUARANTEE_SERIAL_NUM = '0000327162' THEN 'CNY'--这笔押品的评估币种录错了，特殊处理一下
            ELSE T.COLL_CCY END,--16 评估币种
          ROW_NUMBER() OVER(PARTITION BY  T.GUARANTEE_SERIAL_NUM, t4.GUAR_CONTRACT_NUM ORDER BY 1 DESC) RN,
          T.date_sourcesd,
          t8.CUST_NAM,
          t5.cust_id

   FROM  SMTMODS.L_AGRE_GUARANTY_INFO T  --抵质押物信息
            inner join  SMTMODS.L_AGRE_GUARANTEE_RELATION T3  ---担保合同与抵质押物关系表
                   on t.GUARANTEE_SERIAL_NUM =t3.GUARANTEE_SERIAL_NUM
                  and t3.data_date =IS_DATE
                  AND T3.REL_STATUS = 'Y'
            inner join SMTMODS.L_AGRE_GUA_RELATION  t4  --业务合同与担保合同对应关系表
                   on t3.GUAR_CONTRACT_NUM=t4.GUAR_CONTRACT_NUM
                  and t4.data_date =IS_DATE
                  AND T4.REL_STATUS = 'Y'
            inner join SMTMODS.L_AGRE_GUARANTEE_CONTRACT T2--担保合同
                   ON T2.GUAR_CONTRACT_NUM = T4.GUAR_CONTRACT_NUM
                  AND T2.DATA_DATE = IS_DATE
                  AND T2.GUAR_CONTRACT_STATUS = 'Y'
            inner join SMTMODS.L_AGRE_LOAN_CONTRACT t5 --业务合同
                    on T4.CONTRACT_NUM =t5.CONTRACT_NUM
                   and t5.data_date=IS_DATE
             INNER JOIN JS_201_DBWXX_TMP01 T6
                  ON T4.CONTRACT_NUM = T6.ACCT_NUM
             LEFT JOIN JS_102_FTYKHX_TEMP03 T7 --历史遗留客户、核销客户 不保留
                    ON T5.CUST_ID = T7.CUST_ID
             INNER JOIN SMTMODS.L_CUST_C T8
                  ON T5.CUST_ID = T8.CUST_ID
                  AND T8.DATA_DATE = IS_DATE --本期报送取对公
                  AND t8.CUST_TYP<>'3'
                where t.data_date=IS_DATE
                  and t.COLL_STATUS='Y'
                and  (T7.CUST_ID IS NULL OR T7.CUST_ID IN( '8000692376','8911498167'))    --历史遗留客户、核销客户 不保留
             AND T6.LOAN_ACCT_BAL > 0
                ;

  COMMIT;

   -----查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'JS_201_DBWXX'
     AND PARTITION_NAME = 'JS_201_DBWXX_' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE JS_201_DBWXX ADD PARTITION JS_201_DBWXX_' ||
                      IS_DATE || ' VALUES LESS THAN(' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE JS_201_DBWXX TRUNCATE PARTITION JS_201_DBWXX_' ||
                    IS_DATE;

  --落地表，包含吉林银行+磐石数据
  INSERT /*+ APPEND*/  INTO JS_201_DBWXX NOLOGGING
    (DATA_DATE, --  数据日期
     ORG_CODE, --1  金融机构代码
     ORG_NUM, --2 内部机构号
     GUAR_CON_NUM, --3  担保合同编码
     CONTRACT_CODE, --4  被担保合同编码
     COLLATERAL_SERIAL_NUM, --5  担保物编码
     COLLATERAL_TYPE, --6  担保物类别
     WARRANT_CODE, --7  权证编号
     FIRST_PRIOR_FLAG, --8  是否第一顺位
     ASSESS_TYPE, --9  评估方式
     ASSESS_METHOD, --10 评估方法
     ASSESS_VALUE, --11 评估价值
     ASSESS_BASE_DATE, --12 评估基准日
     COLLATERAL_VALUE, --13 担保物账面价值
     PRIORITY_COMPENSATION, --14 优先受偿权数额
     VALUATION_PERIOD, --15 估值周期
     BIZ_LINE_ID, --16 业务条线
     CUST_NAME, --户名
     cust_id)
    SELECT /*+parallel(4)*/  IS_DATE as data_date, -- 数据日期
           '',--T4.JRJGBM, --1 金融机构代码 待关联机构表
           T.ORG_NUM, --2  内部机构号
           T.GUAR_CONTRACT_NUM, --3  担保合同编码
           T.BUSINESSCODE, --4  被担保合同编码
           T.COLLATERAL_SERIAL_NUM, --5  担保物编码
           T8.PBOCD_CODE as COLLATERAL_TYPE, --6  担保物类别
           --[2026-04-01] [周立鹏] [无需求，月初跑批处理][李楠] 按发文要求用逗号分割，截取500位
           --SUBSTR(T.WARRANT_CODE, 1, 200), --7  权证编号 --考虑中文占多字节，截取200位  --上一段处理了，此处忽略
           T.WARRANT_CODE, --7  权证编号
           --SUBSTR(COALESCE(T.WARRANT_CODE,T6.WARRANT_CODE), 1, 500), --7  权证编号  20200913  在出结果时补录
           TRIM(T.FIRST_PRIOR_FLAG), --8  是否第一顺位 无
           T.ASSESS_TYPE, --9  评估方式
           case when T.ASSESS_METHOD='01' then '01' --01  收益法
                when T.ASSESS_METHOD='02' then '02' --02  市场法
                when T.ASSESS_METHOD='03' then '03' --03  成本法
                when T.ASSESS_METHOD='04' then '04' --04  组合法
                when T.ASSESS_METHOD='05' then '09' --05  其他
              end as ASSESS_METHOD,--10 评估方法 金数要求：1,收益法;2,市场法;3,成本法;4,组合法;9,其他;但是信贷存放的是5，其他;以金数为准
           (CASE
             WHEN T.RN = 1 THEN
              T.ASSESS_VALUE
             ELSE
              0.00
           END) * T5.CCY_RATE, --11 评估价值  有外币的，折人民币
           TO_CHAR(TO_DATE(T.ASSESS_BASE_DATE, 'YYYY-MM-DD'), 'YYYY-MM-DD'), --12 评估基准日
           CASE
             WHEN T.RN = 1 THEN
              T.COLLATERAL_VALUE
             ELSE
              0.00
           END, --13 担保物账面价值  每个担保物只取一条价值，其他填0
           T.PRIORITY_COMPENSATION, --14 优先受偿权数额  待映射？
           '99' /*T.VALUATION_PERIOD*/ , --15 估值周期  待映射？ 暂定99：其他

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
           T.CUST_NAME, --户名
           t.cust_id
      FROM GUARANTEE_DBW_TMP01 T --担保物信息表
      LEFT JOIN SMTMODS.L_PUBL_RATE T5
        ON T.PGBZ = T5.BASIC_CCY --汇率表
       AND T5.FORWARD_CCY = 'CNY' --折算人民币
       AND T5.DATA_DATE = IS_DATE

     LEFT JOIN L_CODE_DICTIONARY T8  --码值表
        ON TRIM(T.COLLATERAL_TYPE)=TRIM(T8.L_CODE)
       AND T8.CODE_CLMN_NAME='COLL_TYP' --担保物类别
     LEFT JOIN (select ACCT_NUM,LOAN_NUM,DEPARTMENTD,ROW_NUMBER() over(partition by acct_num order by loan_num desc) rn FROM SMTMODS.L_ACCT_LOAN where data_date=IS_DATE) T9
        ON T.BUSINESSCODE = T9.ACCT_NUM
       AND T9.RN = '1'
     WHERE T.COLLATERAL_SERIAL_NUM <> '1100001352' --该条数据 评估基准日  为'2061212' 暂时过滤掉

    ;
  commit;


/*  --机构变更按照老机构报，如果不用了的机构可以把ORG_NEW表EFF_FLAG字段改成'N'
  UPDATE JS_201_DBWXX A SET A.ORG_NUM = (SELECT T.ORG_NUM_BK FROM ORG_NEW T WHERE T.EFF_FLAG = 'Y' AND A.ORG_NUM = T.ORG_NUM_NEW)
  WHERE A.DATA_DATE = IS_DATE AND EXISTS(SELECT 1 FROM ORG_NEW B WHERE A.ORG_NUM = B.ORG_NUM_NEW AND B.EFF_FLAG = 'Y');
  COMMIT;*/


  -------------------吉林银行目标表数据--------------------

  SP_PBOCD_PARTITIONS(IS_DATE,'PBOCD_JS_201_DBWXX_TMP',OI_RETCODE);

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_201_DBWXX_TMP TRUNCATE PARTITION P' ||
                    IS_DATE;
  INSERT /*+ APPEND*/  INTO PBOCD_JS_201_DBWXX_TMP NOLOGGING
    (DATA_DATE, --  数据日期
     ORG_CODE, --1  金融机构代码
     ORG_NUM, --2  内部机构号
     GUAR_CON_NUM, --3  担保合同编码
     CONTRACT_CODE, --4  被担保合同编码
     COLLATERAL_SERIAL_NUM, --5  担保物编码
     COLLATERAL_TYPE, --6  担保物类别
     WARRANT_CODE, --7  权证编号
     FIRST_PRIOR_FLAG, --8  是否第一顺位
     ASSESS_TYPE, --9  评估方式
     ASSESS_METHOD, --10 评估方法
     ASSESS_VALUE, --11 评估价值
     ASSESS_BASE_DATE, --12 评估基准日
     COLLATERAL_VALUE, --13 担保物账面价值
     PRIORITY_COMPENSATION, --14 优先受偿权数额
     VALUATION_PERIOD, --15 估值周期
     CJRQ, --17 采集日期
     NBJGH, --18 内部机构号
     BIZ_LINE_ID, --19 业务条线
     BSCJRQ, --21 报送周期
     FRNBJGH, --法人内部机构号
     CUST_NAME, --借款人名称
     CUST_TYPE  --客户类型
     )

    SELECT /*+parallel(4)*/  VS_TEXT, -- 数据日期
           T.ORG_CODE , --1  金融机构代码
           T.ORG_NUM, --2  内部机构号
           T.GUAR_CON_NUM, --3  担保合同编码
           T.CONTRACT_CODE, --4  被担保合同编码
           T.COLLATERAL_SERIAL_NUM, --5  担保物编码
           T.COLLATERAL_TYPE, --6  担保物类别
           T.WARRANT_CODE, --7  权证编号  --有补录数据取补录数据，补录数据不全取系统数据
           COALESCE(T.FIRST_PRIOR_FLAG,'1'), --8  是否第一顺位
           /*COALESCE(t.assess_type,T.assess_type) , --9  评估方式 --有补录数据取补录数据，补录数据
           COALESCE(t.assess_method,T.assess_method)  , --10 评估方法  --有补录数据取补录数据，补录数据*/
           T.assess_type , --9  评估方式 --有补录数据取补录数据，补录数据
           T.assess_method  , --10 评估方法  --有补录数据取补录数据，补录数据
           T.ASSESS_VALUE , --11 评估价值
           T.ASSESS_BASE_DATE, --12 评估基准日--有补录数据取补录数据，补录数据
           case when t.collateral_type not like 'A%'  then null else  T.COLLATERAL_VALUE end, --13 担保物账面价值
           '0', --14 优先受偿权数额
           T.VALUATION_PERIOD, --15 估值周期
           IS_DATE, --17 采集日期
           T.ORG_NUM, --18 内部机构号
           T.BIZ_LINE_ID , --19 业务条线
           '', --21 报送周期

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

           t.cust_name,  --借款人名称
           '002'CUST_TYPE --客户类型
      FROM JS_201_DBWXX t
       /*left join JS_201_DBWXX\*@PBOCD_34*\   b
       on t.guar_con_num =b.guar_con_num
       and t.contract_code = b.contract_code
       and t.collateral_serial_num = b.collateral_serial_num
       and b.data_date = VS_TEXT*/
       /*left join js_201_dbwxx_bl   b1   --补录表  删除
       on t.guar_con_num =b1.guar_con_num
       and t.contract_code = b1.contract_code
       and t.collateral_serial_num = b1.collateral_serial_num
       and b1.opt_type = 'D'  --删除标识
       left join js_201_dbwxx_bl   b2   --补录表 修改
       on t.guar_con_num =b2.guar_con_num
       and t.contract_code = b2.contract_code
       and t.collateral_serial_num = b2.collateral_serial_num
       and b2.opt_type = 'U'  --删除标识*/
     WHERE T.DATA_DATE = IS_DATE;
       --and b1.opt_type is null  --判断补录删除数据
       --AND T.ORG_NUM NOT LIKE '0215%'; --过滤磐石数据
---------------------------------------------------------------------------
--应用层逻辑
 SP_PBOCD_PARTITIONS(IS_DATE,'PBOCD_JS_201_DBWXX',OI_RETCODE);
  INSERT INTO PBOCD_JS_201_DBWXX
    (DATA_DATE, --  数据日期
     ORG_CODE, --1  金融机构代码
     ORG_NUM, --2  内部机构号
     GUAR_CON_NUM, --3  担保合同编码
     CONTRACT_CODE, --4  被担保合同编码
     COLLATERAL_SERIAL_NUM, --5  担保物编码
     COLLATERAL_TYPE, --6  担保物类别
     WARRANT_CODE, --7  权证编号
     FIRST_PRIOR_FLAG, --8  是否第一顺位
     ASSESS_TYPE, --9  评估方式
     ASSESS_METHOD, --10 评估方法
     ASSESS_VALUE, --11 评估价值
     ASSESS_BASE_DATE, --12 评估基准日
     COLLATERAL_VALUE, --13 担保物账面价值
     PRIORITY_COMPENSATION, --14 优先受偿权数额
     VALUATION_PERIOD, --15 估值周期
     CJRQ, --17 采集日期
     NBJGH, --18 内部机构号
     BIZ_LINE_ID, --19 业务条线
     BSCJRQ, --21 报送周期
     FRNBJGH, --法人内部机构号
     CUST_NAME, --借款人名称
     CUST_TYPE  --客户类型
     )

    SELECT VS_TEXT, -- 数据日期
           NVL( NVL(OB.ID_NO,OB.UP_ID_NO) ,NVL(OB2.ID_NO,OB2.UP_ID_NO) ), --金融机构代码
           --NVL(OB.ID_NO,OB.UP_ID_NO), --金融机构代码
           T.ORG_NUM, --2  内部机构号
           T.GUAR_CON_NUM, --3  担保合同编码
           T.CONTRACT_CODE, --4  被担保合同编码
           T.COLLATERAL_SERIAL_NUM, --5  担保物编码
           T.COLLATERAL_TYPE, --6  担保物类别
     
     --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --COALESCE(b.WARRANT_CODE,t.WARRANT_CODE), --7  权证编号  --有补录数据取补录数据，补录数据不全取系统数据
           t.WARRANT_CODE, --7  权证编号
           
           COALESCE(T.FIRST_PRIOR_FLAG,'1'), --8  是否第一顺位
           
           --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
           --COALESCE(t.assess_type,b2.assess_type) , --9  评估方式 --有补录数据取补录数据，补录数据
           t.assess_type , --9  评估方式
           
           --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
           --COALESCE(t.assess_method,b2.assess_method)  , --10 评估方法  --有补录数据取补录数据，补录数据
           t.assess_method  , --10 评估方法
           T.ASSESS_VALUE , --11 评估价值
     
           --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
           --NVL(b2.ASSESS_BASE_DATE,T.ASSESS_BASE_DATE), --12 评估基准日--有补录数据取补录数据，补录数据
           T.ASSESS_BASE_DATE, --12 评估基准日
           case when t.collateral_type not like 'A%'  then null else  T.COLLATERAL_VALUE end, --13 担保物账面价值
           '0', --14 优先受偿权数额
           T.VALUATION_PERIOD, --15 估值周期
           IS_DATE, --17 采集日期
           T.ORG_NUM, --18 内部机构号
           T.BIZ_LINE_ID, --19 业务条线
           '', --21 报送周期
           T.FRNBJGH, --法人内部机构号
           t.cust_name,  --借款人名称
           '002'CUST_TYPE --客户类型
      FROM PBOCD_JS_201_DBWXX_TMP t
      LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=T.NBJGH AND OB.DATA_DATE=IS_DATE
	  LEFT JOIN L_PUBL_ORG_BRA_TMP OB2  --用于关联出NBJGH的上级机构的机构信息 20251013
      ON OB.UP_ORG_NUM=OB2.ORG_NUM AND OB.DATA_DATE=IS_DATE AND OB2.DATA_DATE=IS_DATE 
      --[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除冗余代码
       /*left join pbocd_Js_201_Dbwxx   b
       on t.guar_con_num =b.guar_con_num
       and t.contract_code = b.contract_code
       and t.collateral_serial_num = b.collateral_serial_num
       and b.data_date = VS_TEXT*/
       --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 20251208日查询配置表中数据已过渡完，可剔除该操作
       /*left join js_201_dbwxx_bl   b1   --补录表  删除
       on t.guar_con_num =b1.guar_con_num
       and t.contract_code = b1.contract_code
       and t.collateral_serial_num = b1.collateral_serial_num
       and b1.opt_type = 'D'  --删除标识*/
       --[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
       /*left join js_201_dbwxx_bl   b2   --补录表 修改
       on t.guar_con_num =b2.guar_con_num
       and t.contract_code = b2.contract_code
       and t.collateral_serial_num = b2.collateral_serial_num
       and b2.opt_type = 'U'  --删除标识*/
     WHERE T.CJRQ = IS_DATE
       --and b1.opt_type is null  --判断补录删除数据
       ;
  COMMIT;

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表
/*--特殊处理
--权证编码为空的按上期刷，刷完之后还有空的反馈给业务补录
MERGE INTO PBOCD_JS_201_DBWXX A
USING (SELECT * FROM PBOCD_JS_201_DBWXX_SQ WHERE CJRQ = VS_LAST_TEXT) B
ON (A.GUAR_CON_NUM = B.GUAR_CON_NUM AND A.CONTRACT_CODE = B.CONTRACT_CODE AND A.COLLATERAL_SERIAL_NUM = B.COLLATERAL_SERIAL_NUM)
WHEN MATCHED THEN
  UPDATE
     SET A.WARRANT_CODE = B.WARRANT_CODE
   WHERE A.CJRQ = IS_DATE
     AND A.WARRANT_CODE IS NULL;
COMMIT;

--担保物类别空时，按上期刷
MERGE INTO PBOCD_JS_201_DBWXX A
USING (SELECT *
         FROM PBOCD_JS_201_DBWXX_SQ A
        WHERE A.CJRQ = VS_LAST_TEXT
          AND COLLATERAL_TYPE IS NOT NULL) B
ON (A.CONTRACT_CODE = B.CONTRACT_CODE AND A.GUAR_CON_NUM = B.GUAR_CON_NUM AND A.COLLATERAL_SERIAL_NUM = B.COLLATERAL_SERIAL_NUM)
WHEN MATCHED THEN
  UPDATE
     SET A.COLLATERAL_TYPE = B.COLLATERAL_TYPE
   WHERE A.CJRQ = IS_DATE
     AND COLLATERAL_TYPE IS NULL;*/

--[2025-04-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_一阶段][李楠] 剔除取上期/配置表     
--按配置表删除权证编码或担保物类别空值的数据(后续业务补录之后还有空值的会在报送层再处理一次)
--  BSP_SP_JS_SPOP(IS_DATE,OI_RETCODE,OI_RETCODE_DEC,'PBOCD_JS_201_DBWXX');
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
/
