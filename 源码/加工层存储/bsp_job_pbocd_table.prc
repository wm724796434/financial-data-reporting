CREATE OR REPLACE PROCEDURE BSP_JOB_PBOCD_TABLE(IS_DATE IN VARCHAR2,
                                            
                                            OI_RETCODE OUT INTEGER,
                                            OI_RETCODE_DEC OUT VARCHAR2) IS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- JOB_PBOCD_TABLE   DATACORE.JOB_PBOCD_TABLE 的存储跑批
  -- 用途:处理共用临时表
  -- 参数
  -- IS_DATE 输入变量，传入跑批日期
  -- OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  -- 中软融鑫
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段 上线日期：2025-05-27，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  --    需求编号：JLBA202505120009_关于修改金数系统与大集中系统单一客户授信逻辑的需求 上线日期：2025-05-27，修改人：周立鹏，提出人：李楠   修改原因：金数和大集中统一授信额度
  ------------------------------------------------------------------------------------------------------
  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(250) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(8); --存储过程执行步骤标志
  NUM               INTEGER;
  VS_NMONTH         VARCHAR2(10);

BEGIN
  VS_TEXT   := IS_DATE;
  VS_NMONTH := TO_CHAR(TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD') + 1), 'YYYYMMDD');
  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'JOB_PBOCD_TABLE';
  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------

  --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'L_CUST_C_TMP'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE L_CUST_C_TMP ADD PARTITION P' || IS_DATE ||
                      ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE L_CUST_C_TMP TRUNCATE PARTITION P' ||
                    IS_DATE;

--客户信息临时表                    
  VS_STEP := '1';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  insert into l_Cust_c_tmp
    (BASE_ACCT,
     BASE_ACCT_OP_NAME,
     CUST_TYP,
     BORROWER_BULID_YEAR,
     BORROWER_PRODUCT_DESC,
     BORROWER_REGISTER_ADDR,
     CAPITAL_AMT,
     CORP_BUSINSESS_TYPE,
     CORP_HOLD_TYPE,
     CORP_SCALE,
     CUST_ID,
     CUST_NAM,
     DATA_DATE,
     FIRST_CREDIT_DATE,
     ID_NO,
     ID_TYPE,
     MAIN_BUSI_INCOME,
     OPER_TYPE,
     ORG_NUM,
     PAICL_UP_CAPITAL,
     REGION_CD,
     TOTAL_ASSET,
     FINA_CODE,
     LEI_CODE,
     SPECIAL_CODE,
     DEPT_TYPE， RELATED_TYP,
     STOCK_FLG,
     ORGANIZATIONCODE,
     TYSHXYDM,
     staff_num,
     credit_rank_type,
     credit_rank,
     ORG_AREA,
     --[2025-05-27] [周立鹏] [JLBA202505120009_关于修改金数系统与大集中系统单一客户授信逻辑的需求][李楠] 金数和大集中统一授信额度
     CLOSED_DATE,
     CUSTSTATUS
     )
    select A.BASE_ACCT,
           A.BASE_ACCT_OP_NAME,
           A.CUST_TYP,
           A.BORROWER_BULID_YEAR,
           A.BORROWER_PRODUCT_DESC,
           A.BORROWER_REGISTER_ADDR,
           A.CAPITAL_AMT,
           A.CORP_BUSINSESS_TYPE,
           A.CORP_HOLD_TYPE,
           A.CORP_SCALE,
           A.CUST_ID,
           A.CUST_NAM,
           A.DATA_DATE,
           A.FIRST_CREDIT_DATE,
           A.ID_NO,
           A.ID_TYPE,
           A.MAIN_BUSI_INCOME,
           A.OPER_TYPE,
           A.ORG_NUM,
           A.PAICL_UP_CAPITAL,
           A.REGION_CD,
           A.TOTAL_ASSET,
           A.FINA_CODE,
           A.LEI_CODE,
           A.SPECIAL_CODE,
           b.DEPT_TYPE， b.RELATED_TYP,
           A.STOCK_FLG,
           a.ORGANIZATIONCODE,
           a.TYSHXYDM,
           a.staff_num,
           b.credit_rank_type,
           b.credit_rank,
           a.ORG_AREA,
           --[2025-05-27] [周立鹏] [JLBA202505120009_关于修改金数系统与大集中系统单一客户授信逻辑的需求][李楠] 金数和大集中统一授信额度
           A.CLOSED_DATE,
           A.CUSTSTATUS
      from SMTMODS.l_cust_c a
      left join SMTMODS.l_cust_all b
        on a.cust_id = b.cust_id
       and b.data_date = is_date
     WHERE A.DATA_DATE = is_date;
  COMMIT;

  --贷款担保方式中间表
  VS_STEP := '2';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  EXECUTE IMMEDIATE 'TRUNCATE TABLE YAPIN_TMP'; --贷款与押品信息中间表
  EXECUTE IMMEDIATE 'TRUNCATE TABLE DBFS_TMP'; --贷款担保方式中间表

  --贷款借据与押品信息中间表
  INSERT INTO YAPIN_TMP
  SELECT
       A.LOAN_NUM, --借据编号
       A.ACCT_NUM, --合同编号
       A.CUST_ID,  --客户号
       A.ORG_NUM,  --机构号
       A.GUARANTY_TYP, --借据表主担保方式
       to_char(a.drawdown_dt,'yyyymmdd') FKRQ, --放款日期
       to_char(a.maturity_dt,'yyyymmdd') DQRQ, --到期日期
       B.PROD_NAME, --贷款产品名称
       B.GUAR_CONTRACT_NUM, --担保合同编号
       B.GUARANTEE_SERIAL_NUM, --押品编号
       B.COLL_TYP, --押品类型
       B.COLL_STATUS, --押品状态
       b.guar_typ GUAR_TYP, --担保合同担保类型
       b.ple_cert_id as DYWWYSBH, --抵押物唯一识别号
       YWYDBGLZT,--业务合同与担保合同关联状态
       DBYDYWGLZT,--担保合同与抵押物关联状态
       guar_contract_status
  FROM SMTMODS.L_ACCT_LOAN A --借据信息表
  LEFT JOIN (
       SELECT
            B.CONTRACT_NUM,
            B.PROD_NAME,
            C.GUAR_CONTRACT_NUM,
            C.GUAR_START_DT,
            C.GUAR_EXPIRY_DT,
            D.GUARANTEE_SERIAL_NUM,
            D.GUARANTEE_TYPE,
            E.COLL_TYP,
            E.COLL_STATUS,
            E.COLL_START_DT,
            E.COLL_END_DT,
            E.COLL_STATUS_SUB_DESC,
            q.guar_typ,
            e.ple_cert_id,
            c.REL_STATUS AS YWYDBGLZT,--业务合同与担保合同关联状态
            D.REL_STATUS AS DBYDYWGLZT, --担保合同与抵押物关联状态
            q.guar_contract_status --担保合同状态
       FROM SMTMODS.L_AGRE_LOAN_CONTRACT B --贷款合同信息表
       LEFT JOIN SMTMODS.L_AGRE_GUA_RELATION C --业务合同与担保合同对应关系表
       ON B.CONTRACT_NUM = C.CONTRACT_NUM
       AND C.DATA_DATE = IS_DATE
       LEFT JOIN SMTMODS.L_AGRE_GUARANTEE_RELATION D --担保合同与担保信息对应关系表
       ON C.GUAR_CONTRACT_NUM = D.GUAR_CONTRACT_NUM
       AND D.DATA_DATE = IS_DATE
       left join smtmods.l_agre_guarantee_contract q
       on c.guar_contract_num = q.guar_contract_num and q.data_date = IS_DATE
       left JOIN SMTMODS.L_AGRE_GUARANTY_INFO E --抵质押物详细信息
       ON D.GUARANTEE_SERIAL_NUM = E.GUARANTEE_SERIAL_NUM
       AND E.DATA_DATE = IS_DATE
       WHERE B.DATA_DATE = IS_DATE) B
  ON A.ACCT_NUM = B.CONTRACT_NUM
  WHERE A.DATA_DATE = IS_DATE
  --AND A.ACCT_TYP LIKE '01%' --个人贷款
  /* AND A.CANCEL_FLG = 'N' --核销标识为否
  AND A.LOAN_ACCT_BAL <> 0*/--去掉这个条件，否则当月核销的担保方式跑不出来 20230306zhoulp
  ;
  COMMIT;
    
  INSERT INTO DBFS_TMP
  SELECT
       T.LOAN_NUM,
       T.ACCT_NUM,
       T.GUARANTY_TYP JJBDBFS,
       B.CN CDYWDBFS, --除抵押外担保方式合计
       C.CN DBFSHJ,  --担保方式合计
       CASE
         WHEN (T.GUARANTY_TYP LIKE 'B01%' OR A.ACCT_NUM IS NOT NULL) AND B.CN >=1 THEN 'E01' --房地产抵押+去除抵押后的担保方式计数大于1 = 含房地产抵押的组合担保
         WHEN T.GUARANTY_TYP LIKE 'B%' AND B.CN >= 1 THEN 'E' --其他组合
         WHEN B.CN>=2  THEN 'E' --其他组合（质押+保证）
         WHEN A.ACCT_NUM IS NOT NULL THEN 'B01'
         WHEN T.GUARANTY_TYP LIKE 'B%' AND A.ACCT_NUM IS NOT NULL THEN 'B01' --
         WHEN T.GUARANTY_TYP LIKE 'B%' AND A1.ACCT_NUM IS NOT NULL THEN T.GUARANTY_TYP --房地产抵押+其他抵押，以主担保方式为主
         WHEN T.GUARANTY_TYP LIKE 'D%' THEN
           CASE WHEN A.ACCT_NUM IS NOT NULL THEN 'B01'
             WHEN SUBSTR(C.GUAR_TYP,1,1) = 'A' THEN 'A'
                   WHEN SUBSTR(C.GUAR_TYP,1,1) = 'B' THEN 'B99'
                   WHEN SUBSTR(C.GUAR_TYP,1,1) = 'C' THEN 'C99'
           ELSE 'D' END
         when c.cn >= 2 then 'E'
         WHEN T.GUARANTY_TYP LIKE 'C%' THEN 'C99'
         WHEN T.GUARANTY_TYP LIKE 'A%' THEN 'A'
         WHEN C.CN = 1 OR C.CN IS NULL THEN T.GUARANTY_TYP
       END GUAR_TYPE --金数担保方式
  FROM SMTMODS.L_ACCT_LOAN T
  LEFT JOIN (
     SELECT DISTINCT A.ACCT_NUM FROM YAPIN_TMP A
     WHERE A.COLL_STATUS = 'Y'
     AND A.GUAR_CONTRACT_STATUS = 'Y'
     AND A.DBYDYWGLZT = 'Y'
     AND A.YWYDBGLZT = 'Y'
     AND TRIM(A.COLL_TYP) IN( 'B01','B0101','B0102','B02','B0201','B0209','B03','B0301','B0302','B0501','B0502','B0509')
  ) A ON T.ACCT_NUM = A.ACCT_NUM  --房地产抵押物
  LEFT JOIN (
     SELECT DISTINCT A.ACCT_NUM
     FROM YAPIN_TMP A
     WHERE A.COLL_STATUS = 'Y'
     AND A.GUAR_CONTRACT_STATUS = 'Y'
     AND A.DBYDYWGLZT = 'Y'
     AND A.YWYDBGLZT = 'Y'
     AND TRIM(A.COLL_TYP) NOT IN( 'B01','B0101','B0102','B02','B0201','B0209','B03','B0301','B0302','B0501','B0502','B0509')
  ) A1 ON T.ACCT_NUM = A1.ACCT_NUM  --其他抵押
  LEFT JOIN (
     SELECT A.ACCT_NUM,
            MAX(CASE WHEN SUBSTR(A.GUAR_TYP,1,1) = 'A' THEN 'B'
                     WHEN SUBSTR(A.GUAR_TYP,1,1) = 'B' THEN 'A'
                     WHEN SUBSTR(A.GUAR_TYP,1,1) = 'C' THEN 'C'
                     WHEN SUBSTR(A.GUAR_TYP,1,1) = 'D' THEN 'D' ELSE SUBSTR(A.GUAR_TYP,1,1) END) GUAR_TYP,
            COUNT(DISTINCT CASE WHEN SUBSTR(A.GUAR_TYP,1,1) IN ('A','B' ) THEN A.GUAR_TYP ELSE SUBSTR(A.GUAR_TYP,1,1) END) CN
     FROM YAPIN_TMP A
     WHERE A.GUAR_CONTRACT_STATUS = 'Y'
     AND A.DBYDYWGLZT = 'Y'
     AND A.YWYDBGLZT = 'Y'
     AND A.GUAR_TYP <> 'A0101'  --
     AND A.GUAR_TYP IS NOT NULL
     GROUP BY ACCT_NUM
  ) B  --去除抵押贷款后的担保方式借据
  ON T.ACCT_NUM = B.ACCT_NUM
  LEFT JOIN (
     SELECT A.ACCT_NUM,
            MAX(CASE WHEN SUBSTR(A.GUAR_TYP,1,1) = 'A' THEN 'B'
                       WHEN SUBSTR(A.GUAR_TYP,1,1) = 'B' THEN 'A'
                       WHEN SUBSTR(A.GUAR_TYP,1,1) = 'C' THEN 'C'
                       WHEN SUBSTR(A.GUAR_TYP,1,1) = 'D' THEN 'D' ELSE SUBSTR(A.GUAR_TYP,1,1) END ) GUAR_TYP,
            COUNT(DISTINCT CASE WHEN SUBSTR(A.GUAR_TYP,1,1) IN ('A','B' ) THEN A.GUAR_TYP ELSE SUBSTR(A.GUAR_TYP,1,1) END) CN
     FROM YAPIN_TMP A
     WHERE A.GUAR_CONTRACT_STATUS = 'Y'
     AND A.DBYDYWGLZT = 'Y'
     AND A.YWYDBGLZT = 'Y'
     AND A.GUAR_TYP IS NOT NULL
     GROUP BY ACCT_NUM
  ) C  --所有担保方式
  ON T.ACCT_NUM = C.ACCT_NUM
  WHERE T.DATA_DATE = IS_DATE
 -- AND T.ACCT_TYP LIKE '01%' --个人贷款
/*  AND T.CANCEL_FLG = 'N' --核销标识为否
  AND T.LOAN_ACCT_BAL <> 0*/--去掉这个条件，否则当月核销的担保方式跑不出来 20230306zhoulp
  ;
  COMMIT;

--机构临时表
  VS_STEP := '3';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  --EXECUTE IMMEDIATE 'TRUNCATE TABLE L_PUBL_ORG_BRA_TMP'; --机构临时表
  DELETE FROM L_PUBL_ORG_BRA_TMP WHERE DATA_DATE = IS_DATE;
  
  INSERT INTO L_PUBL_ORG_BRA_TMP
  (DATA_DATE, --数据日期
   ORG_NUM, --机构号
   ORG_NAM, --机构名称
   ORG_NAM_ENG, --机构英文名称
   ORG_TYP, --机构类型
   ORG_STATUS, --机构状态
   REGION_CD, --区域代码_2002
   UP_ORG_NUM, --上级机构号
   ORG_OWNLEVEL, --机构所属层级
   NATION_CD, --国别代码
   ID_TYP, --证件类别
   ID_NO, --证件号码
   EC_TYP, --经济类型
   THELEAD_DEPARMENT, --牵头部门
   THELEAD_DEPARMENT_CONTACTS, --牵头部门联系人
   THELEAD_DEPARMENT_TEL, --牵头部门联系电话
   BANK_CD, --银行机构代码
   FIN_LIN_NUM, --金融许可证号
   ACCOUNTBANK, --金融机构编码
   BANK_TYPE, --机构类别
   ZIP_CD, --邮政编码
   BUSI_STATE, --营业状态
   BEGAN_TIME, --成立时间
   OPEN_TIME, --机构工作开始时间
   CLOSE_TIME, --机构工作终止时间
   ORG_ADD, --机构地址
   LEADER_NAME, --负责人姓名
   LEADER_POST, --负责人职务
   LEADER_TEL, --负责人联系电话
   CBRC_CODE, --非现场监管编码
   IS_ENTITY, --是否实体机构
   IS_LEGAL, --是否法人行
   FINA_TECH_TYPE, --科技金融机构类型
   IS_SERVICE_CENTER, --是否业务中心
   ORG_TYP_SUB, --机构类型细类
   IS_VIRTUAL, --是否虚拟汇总机构
   BANK_TYPE2, --机构分类
   LIST_FLG, --上市标志
   IS_REPORT, --是否主报送行
   FINA_ORG_CODE, --金融机构类型代码
   REGION_CD_NEW, --最新区域代码
   REG_CAPITAL, --注册资本
   CORP_HOLD_TYPE, --控股类型
   CORP_SCALE, --企业规模
   ACTR_CTRL_TYPE, --实际控制人身份类别
   ACTR_CTRL_NAME, --实际控制人名称
   ACTR_CTRL_ID, --实际控制人代码
   HEAD_OFFIC_FLG, --是否总行本部
   BUSI_UNIT_FLG, --是否事业部
   DISTRICT_CODE, --机构行政区划代码
   DEPARTMENTD, --归属部门
   DATE_SOURCESD, --数据来源
   VILLAGE_FLG, --是否归属乡镇
   SWIFT_CODE, --SWIFT代码
   LEGAL_ORG_NUM, --法人机构号
   LCZGS_FLAG, --理财子公司标志
   ORGAN_PHONE, --机构联系电话
   BUS_LICENSE_NO, --营业执照号
   UP_ID_NO)
  SELECT A.DATA_DATE, --数据日期
         A.ORG_NUM, --机构号
         A.ORG_NAM, --机构名称
         A.ORG_NAM_ENG, --机构英文名称
         A.ORG_TYP, --机构类型
         A.ORG_STATUS, --机构状态
         A.REGION_CD, --区域代码_2002
         A.UP_ORG_NUM, --上级机构号
         A.ORG_OWNLEVEL, --机构所属层级
         A.NATION_CD, --国别代码
         A.ID_TYP, --证件类别
         A.ID_NO, --证件号码
         A.EC_TYP, --经济类型
         A.THELEAD_DEPARMENT, --牵头部门
         A.THELEAD_DEPARMENT_CONTACTS, --牵头部门联系人
         A.THELEAD_DEPARMENT_TEL, --牵头部门联系电话
         A.BANK_CD, --银行机构代码
         A.FIN_LIN_NUM, --金融许可证号
         A.ACCOUNTBANK, --金融机构编码
         A.BANK_TYPE, --机构类别
         A.ZIP_CD, --邮政编码
         TRIM(A.BUSI_STATE), --营业状态
         A.BEGAN_TIME, --成立时间
         A.OPEN_TIME, --机构工作开始时间
         A.CLOSE_TIME, --机构工作终止时间
         A.ORG_ADD, --机构地址
         A.LEADER_NAME, --负责人姓名
         A.LEADER_POST, --负责人职务
         A.LEADER_TEL, --负责人联系电话
         A.CBRC_CODE, --非现场监管编码
         A.IS_ENTITY, --是否实体机构
         A.IS_LEGAL, --是否法人行
         A.FINA_TECH_TYPE, --科技金融机构类型
         A.IS_SERVICE_CENTER, --是否业务中心
         A.ORG_TYP_SUB, --机构类型细类
         A.IS_VIRTUAL, --是否虚拟汇总机构
         A.BANK_TYPE2, --机构分类
         A.LIST_FLG, --上市标志
         A.IS_REPORT, --是否主报送行
         A.FINA_ORG_CODE, --金融机构类型代码
         A.REGION_CD_NEW, --最新区域代码
         A.REG_CAPITAL, --注册资本
         A.CORP_HOLD_TYPE, --控股类型
         A.CORP_SCALE, --企业规模
         A.ACTR_CTRL_TYPE, --实际控制人身份类别
         A.ACTR_CTRL_NAME, --实际控制人名称
         A.ACTR_CTRL_ID, --实际控制人代码
         A.HEAD_OFFIC_FLG, --是否总行本部
         A.BUSI_UNIT_FLG, --是否事业部
         A.DISTRICT_CODE, --机构行政区划代码
         A.DEPARTMENTD, --归属部门
         A.DATE_SOURCESD, --数据来源
         A.VILLAGE_FLG, --是否归属乡镇
         A.SWIFT_CODE, --SWIFT代码
         A.LEGAL_ORG_NUM, --法人机构号
         A.LCZGS_FLAG, --理财子公司标志
         A.ORGAN_PHONE, --机构联系电话
         A.BUS_LICENSE_NO, --营业执照号, 
         B.ID_NO
    FROM SMTMODS.L_PUBL_ORG_BRA A
    LEFT JOIN (SELECT *
                 FROM SMTMODS.L_PUBL_ORG_BRA
                WHERE DATA_DATE = IS_DATE) B
      ON A.UP_ORG_NUM = B.ORG_NUM
   WHERE A.DATA_DATE = IS_DATE;
  COMMIT;

--[2025-05-27] [周立鹏] [JLBA202505120009_关于修改金数系统与大集中系统单一客户授信逻辑的需求][李楠] 金数和大集中统一授信额度
----------------------------开始 授信临时表------------------------------------------------

  --加工对公授信数据
    DELETE FROM PBOCD_AGRE_CREDITLINE_INFO_GYL WHERE DATA_DATE = IS_DATE;
  COMMIT;

   INSERT INTO PBOCD_AGRE_CREDITLINE_INFO_GYL
      (DATA_DATE ,CUST_ID, FACILITY_AMT)
       --ALTER BY SHIYU 20241105 新增国内保理（无追索权保理）、吉信链产品授信、吉运链
              SELECT  IS_DATE DATA_DATE,
                     T.CUST_ID,
                     SUM(T.CONTRACT_AMT * TT.CCY_RATE) AS FACILITY_AMT
                FROM SMTMODS.L_AGRE_LOAN_CONTRACT T
                LEFT JOIN SMTMODS.L_PUBL_RATE TT
                  ON TT.DATA_DATE = T.DATA_DATE
                 AND TT.BASIC_CCY = T.CURR_CD
                 AND TT.FORWARD_CCY = 'CNY'
               WHERE T.DATA_DATE = IS_DATE
                 AND T.CP_ID IN ('BL004000100005', --国内保理（公司）
                                 'BL004000100002', --国内保理（普惠）
                                 'BL004000100010', --吉信链 （公司）
                                 'BL004000100009', --吉运链
                                 'BL004000100011') --吉信链 （普惠）
                 AND SUBSTR(T.ORG_NUM, 1, 1) NOT IN ('5', '6') --剔除村镇
                 AND T.ACCT_STS = '1' --合同状态：有效
                 AND T.QUOTE_LMT_PTY = '0' --引用额度方：0单占核心
                 GROUP BY T.CUST_ID;
            COMMIT;


  DELETE FROM PBOCD_AGRE_CREDITLINE_INFO_TMPE1 WHERE DATA_DATE = IS_DATE;
  COMMIT;

   INSERT INTO PBOCD_AGRE_CREDITLINE_INFO_TMPE1 --统一授信临时表
      (DATA_DATE, CUST_ID, FACILITY_AMT)
    --单位客户及单位名称的个体工商户取客户授信协议金额，不考虑授信协议状态，判断客户下的合同是有效的或者有销的借据
      SELECT IS_DATE, CUST_ID, SUM(FACILITY_AMT)
        FROM (SELECT t.CUST_ID,
                     SUM(T.FACILITY_AMT * TT.CCY_RATE) AS FACILITY_AMT --ADD BY YHY 20211229
                FROM SMTMODS.L_AGRE_CREDITLINE T
                LEFT JOIN SMTMODS.L_PUBL_RATE TT --汇率表
                  ON TT.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD')
                 AND TT.BASIC_CCY = T.CURR_CD
                 AND TT.FORWARD_CCY = 'CNY'
               INNER JOIN SMTMODS.L_CUST_C C
                  ON T.CUST_ID = C.CUST_ID
                 AND C.DATA_DATE = IS_DATE
               WHERE T.DATA_DATE = IS_DATE
                 AND T.FACILITY_TYP IN ('2', '4') --2单一法人、4集团成员
                 AND ( EXISTS (SELECT  1
                         FROM SMTMODS.L_AGRE_LOAN_CONTRACT  TT
                        WHERE TT.DATA_DATE = IS_DATE
                          AND T.CUST_ID = TT.CUST_ID
                          AND TT.ACCT_STS = '1' --有效
                          /*BL004000100005国内保理_公司、BL004000100002国内保理_普惠、BL004000100010吉信链——公司、BL004000100009吉运链、BL004000100011吉信链_普惠*/

                          and ( Tt.CP_ID  not  IN ('BL004000100005','BL004000100002','BL004000100010','BL004000100009','BL004000100011')
                            or (Tt.CP_ID  IN ('BL004000100005','BL004000100002','BL004000100010','BL004000100009','BL004000100011')
                                  and QUOTE_LMT_PTY <>'0') --引用额度方：0单占核心
                                  )
                        )   ---取客户名下有效合同的客户授信
                           or FACILITY_STS ='Y')
               GROUP BY t.CUST_ID
               union all
                 select  CUST_ID, FACILITY_AMT from PBOCD_AGRE_CREDITLINE_INFO_GYL
                  WHERE DATA_DATE = IS_DATE

              )
       GROUP BY CUST_ID;
    COMMIT;

    DELETE FROM PBOCD_AGRE_CREDITLINE_INFO_TMPE2 WHERE DATA_DATE = IS_DATE;
    COMMIT;

     --插入对公授信，比较有效借据的合同金额是否大于或等于授信额度。
     INSERT INTO PBOCD_AGRE_CREDITLINE_INFO_TMPE2
      (CUST_ID, FACILITY_AMT, DATA_DATE)

      SELECT /*+ parallel(4) */ NVL(a.CUST_ID,B.CUST_ID),
       CASE WHEN  CASE WHEN NVL(B.FACILITY_AMT,0) <NVL(A.CONTRACT_AMT,0) THEN NVL(A.CONTRACT_AMT,0)
                ELSE NVL(B.FACILITY_AMT,0) END  <NVL(C.LOAN_ACCT_BAL,0) THEN NVL(C.LOAN_ACCT_BAL,0)
                  ELSE CASE WHEN NVL(B.FACILITY_AMT,0) <NVL(A.CONTRACT_AMT,0) THEN NVL(A.CONTRACT_AMT,0)
                ELSE NVL(B.FACILITY_AMT,0) END END AS FACILITY_AMT ,
         IS_DATE
         
         --按辉哥要求，没有授信协议的，取有效合同金额
         
    FROM (SELECT C.CUST_ID,
                       SUM(C.CONTRACT_AMT * U.CCY_RATE) CONTRACT_AMT
                 FROM SMTMODS.L_AGRE_LOAN_CONTRACT C
                 LEFT JOIN SMTMODS.L_PUBL_RATE U --汇率表
                   ON U.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD')
                  AND U.BASIC_CCY = C.CURR_CD
                  AND U.FORWARD_CCY = 'CNY'
                INNER JOIN SMTMODS.L_CUST_C C1
                   ON C.DATA_DATE = C1.DATA_DATE
                  AND C.CUST_ID = C1.CUST_ID
                WHERE C.DATA_DATE = IS_DATE
                  AND C.ACCT_STS = '1' --有效
                  AND (EXISTS
                      (SELECT 1
                         FROM SMTMODS.L_ACCT_LOAN T
                        WHERE T.DATA_DATE = IS_DATE
                          AND T.CANCEL_FLG = 'N'
                       --   AND T.ACCT_TYP NOT IN ('030101','030102') -- 不取银行承兑汇票  商业承兑汇票
                          AND T.LOAN_ACCT_BAL <> 0
                          AND T.LOAN_STOCKEN_DATE IS NULL    -- ADD BY HAORUI 20250311 JLBA202408200012 资产未转让
                          AND T.ACCT_STS <> '3'
                          AND T.ACCT_TYP NOT LIKE '90%' --剔除委托贷款
                          AND T.ITEM_CD NOT IN ('130102','130105') --剔除转贴现
                          AND T.ACCT_NUM = C.CONTRACT_NUM)
                   OR EXISTS
                       (SELECT 1 FROM SMTMODS.L_ACCT_OBS_LOAN T1
                            WHERE T1.DATA_DATE = IS_DATE
                            AND T1.BALANCE <> 0
                            AND (SUBSTR(T1.GL_ITEM_CODE, 1, 4) IN ('7010', '7020', '7040') OR
                            T1.GL_ITEM_CODE = '70300201') -- [20250513][狄家卉][JLBA202504060003][吴大为]: 表外用信余额 字段  调整数据范围为 7010开出信用证, 7020承兑汇票, 7040开出保函, 70300201不可撤销贷款承诺
                            AND T1.ACCT_NO=C.CONTRACT_NUM)
                          )
                GROUP BY C.CUST_ID) A
    FULL JOIN (SELECT * FROM PBOCD_AGRE_CREDITLINE_INFO_TMPE1 WHERE DATA_DATE = IS_DATE) B
      ON A.CUST_ID = B.CUST_ID AND B.DATA_DATE = IS_DATE
      left join (
               --票据部分:因票据没有合同，避免授信小于贷款余额，单独判断
             SELECT  T.DATA_DATE,T.CUST_ID,SUM(T.LOAN_ACCT_BAL *TT.CCY_RATE) AS LOAN_ACCT_BAL
                    FROM  SMTMODS.L_ACCT_LOAN T
              INNER JOIN SMTMODS.L_CUST_C C
                      ON T.DATA_DATE =C.DATA_DATE
                     AND T.CUST_ID =C.CUST_ID
               LEFT JOIN SMTMODS.L_PUBL_RATE TT --汇率表
                      ON TT.DATA_DATE = T.DATA_DATE
                     AND TT.BASIC_CCY = T.CURR_CD
                     AND TT.FORWARD_CCY = 'CNY'
                   WHERE  T.ACCT_STS <> '3'
                      AND T.CANCEL_FLG <> 'Y'
                     -- AND T.ITEM_CD LIKE '1301%' --票据融资
                      AND T.ITEM_CD NOT IN ('130102','130105') /*剔除转贴现*/
                      AND T.LOAN_STOCKEN_DATE IS NULL    -- ADD BY HAORUI 20250311 JLBA202408200012 资产未转让
                      AND T.ACCT_TYP NOT LIKE '90%' --剔除委托贷款
                      AND T.LOAN_ACCT_BAL <>0
                 GROUP BY T.CUST_ID , T.DATA_DATE)C
                       ON A.CUST_ID = C.CUST_ID
                      AND C.DATA_DATE = IS_DATE
   ;
   COMMIT;
 
    ---插入票据业务在信贷未做授信的业务

     INSERT INTO PBOCD_AGRE_CREDITLINE_INFO_TMPE2
      (DATA_DATE ,CUST_ID, FACILITY_AMT)
        --票据部分:客户在ngi未有授信记录，单独判断
           SELECT /*+ parallel(4) */
           T.DATA_DATE,
           T.CUST_ID,
           SUM(T.LOAN_ACCT_BAL *TT.CCY_RATE) AS LOAN_ACCT_BAL
                    FROM  SMTMODS.L_ACCT_LOAN T
              INNER JOIN SMTMODS.L_CUST_C C
                      ON T.DATA_DATE =C.DATA_DATE
                     AND T.CUST_ID =C.CUST_ID
               LEFT JOIN SMTMODS.L_PUBL_RATE TT --汇率表
                      ON TT.DATA_DATE = T.DATA_DATE
                     AND TT.BASIC_CCY = T.CURR_CD
                     AND TT.FORWARD_CCY = 'CNY'
                   WHERE  T.ACCT_STS <> '3'
                      AND T.CANCEL_FLG <> 'Y'
                      AND T.ITEM_CD LIKE '1301%' --票据融资
                      AND T.ITEM_CD NOT IN ('130102','130105') /*剔除转贴现*/
                      AND T.LOAN_ACCT_BAL <>0
                      and t.data_date =IS_DATE
                     AND NOT EXISTS (SELECT 1
                        FROM PBOCD_AGRE_CREDITLINE_INFO_TMPE2 A
                       WHERE A.CUST_ID = t.CUST_ID
                         AND A.DATA_DATE = IS_DATE)
                 GROUP BY T.CUST_ID , T.DATA_DATE;
             COMMIT;


        DELETE FROM PBOCD_AGRE_CREDITLINE_INFO_DG WHERE DATA_DATE = IS_DATE;
        COMMIT;

      INSERT INTO PBOCD_AGRE_CREDITLINE_INFO_DG (DATA_DATE ,CUST_ID, FACILITY_AMT)
        SELECT  DATA_DATE ,CUST_ID, FACILITY_AMT FROM PBOCD_AGRE_CREDITLINE_INFO_TMPE2
         WHERE DATA_DATE =IS_DATE ;
         COMMIT;


      INSERT INTO PBOCD_AGRE_CREDITLINE_INFO_DG
      (DATA_DATE ,CUST_ID, FACILITY_AMT)
                SELECT
                    IS_DATE ,
                    AA.CUST_ID ,
                    SUM(AA.BAL) BAL
                 FROM  (
               --ALTER BY SHIYU 20241105 新增表内银行承兑汇票余额授信；因为借据表部分贴票存的是同业客户号
              SELECT /*+ PARALLEL(4) */
               T.CUST_ID, SUM(T.LOAN_ACCT_BAL * TT.CCY_RATE) BAL
                FROM SMTMODS.L_ACCT_LOAN T
                LEFT JOIN SMTMODS.L_PUBL_RATE TT
                  ON TT.DATA_DATE = T.DATA_DATE
                 AND TT.BASIC_CCY = T.CURR_CD
                 AND TT.FORWARD_CCY = 'CNY'
               WHERE T.DATA_DATE = IS_DATE
                 AND T.CANCEL_FLG <> 'Y'
                 AND T.LOAN_ACCT_BAL <> 0
                 AND T.ACCT_TYP = '030101' --030101 银行承兑汇票
                 AND T.LOAN_STOCKEN_DATE IS NULL --ADD BY HAORUI 20250228 JLBA202408200012 资产未转让
               GROUP BY T.CUST_ID,T.ITEM_CD
              UNION ALL
              --因为借据表部分贴票存的是同业客户号,有一部分在ECIF有客户号，避免ECIF客户统计业务缺失加入这部分授信
              SELECT /*+ PARALLEL(4) */
               TY.ECIF_CUST_ID, SUM(T.LOAN_ACCT_BAL * TT.CCY_RATE) BAL
                FROM SMTMODS.L_ACCT_LOAN T
                LEFT JOIN SMTMODS.L_PUBL_RATE TT
                  ON TT.DATA_DATE = T.DATA_DATE
                 AND TT.BASIC_CCY = T.CURR_CD
                 AND TT.FORWARD_CCY = 'CNY'
               INNER JOIN SMTMODS.L_CUST_BILL_TY TY
                  ON T.CUST_ID = TY.CUST_ID
                 AND TY.DATA_DATE = IS_DATE
               WHERE T.DATA_DATE = IS_DATE
                 AND T.CANCEL_FLG <> 'Y'
                 AND T.LOAN_ACCT_BAL <> 0
                 AND T.ACCT_TYP = '030101' --030101 银行承兑汇票
                 AND T.LOAN_STOCKEN_DATE IS NULL --ADD BY HAORUI 20250228 JLBA202408200012 资产未转让
                 AND TY.ECIF_CUST_ID IS NOT NULL
               GROUP BY TY.ECIF_CUST_ID ,T.ITEM_CD
              )  AA
               WHERE   NOT EXISTS (SELECT 1
                        FROM PBOCD_AGRE_CREDITLINE_INFO_TMPE2 A
                       WHERE A.CUST_ID = AA.CUST_ID
                         AND A.DATA_DATE = IS_DATE)
                  GROUP BY AA.CUST_ID ;
            COMMIT;

--在前面
/*--表外授信
DELETE FROM PBOCD_AGRE_CREDITLINE_INFO_BW WHERE DATA_DATE = IS_DATE;
        COMMIT;
 INSERT INTO PBOCD_AGRE_CREDITLINE_INFO_BW
   (CUST_ID, FACILITY_AMT, DATA_DATE)
   SELECT T1.CUST_ID AS CUST_ID,
       SUM(NVL(T1.TRAN_AMT * T3.CCY_RATE, 0)) AS FACILITY_AMT,
       IS_DATE AS DATA_DATE
  FROM SMTMODS.L_ACCT_OBS_LOAN T1
  LEFT JOIN SMTMODS.L_PUBL_RATE T3
    ON T3.DATA_DATE = IS_DATE
   AND T3.BASIC_CCY = T1.CURR_CD -- 表外余额折币
   AND T3.FORWARD_CCY = 'CNY'
 WHERE T1.DATA_DATE = IS_DATE
   AND T1.BALANCE <> 0
   AND (SUBSTR(T1.GL_ITEM_CODE, 1, 4) IN ('7010', '7020', '7040') OR
       T1.GL_ITEM_CODE = '70300201') -- [20250513][狄家卉][JLBA202504060003][吴大为]: 表外用信余额 字段  调整数据范围为 7010开出信用证, 7020承兑汇票, 7040开出保函, 70300201不可撤销贷款承诺
 GROUP BY T1.CUST_ID;
*/

     --加工个人授信数据

     DELETE FROM PBOCD_AGRE_CREDITLINE_INFO_GR WHERE DATA_DATE = IS_DATE;
    COMMIT;

     INSERT INTO PBOCD_AGRE_CREDITLINE_INFO_GR --统一授信临时表
      (DATA_DATE, CUST_ID, FACILITY_AMT)
      SELECT IS_DATE AS DATA_DATE,
             C.CUST_ID,
             SUM(C.CONTRACT_AMT * R.CCY_RATE) AS FACILITY_AMT
        FROM SMTMODS.L_AGRE_LOAN_CONTRACT C
        
       /*INNER JOIN (SELECT T.ACCT_NUM, SUM(T.LOAN_ACCT_BAL)
                     FROM SMTMODS.L_ACCT_LOAN T
                     left JOIN SMTMODS.L_CUST_P T2
                       ON T.CUST_ID = T2.CUST_ID
                      AND T.DATA_DATE = T2.DATA_DATE
                    WHERE T.DATA_DATE = IS_DATE
                      \*AND (T.ACCT_TYP LIKE '0102%' --个人经营性标识
                          OR (SUBSTR(T.ACCT_TYP, 1, 4) = '0199' --0199其他个人贷款
                          AND T.ITEM_CD LIKE '1305%'))*\
                      AND T.ACCT_TYP LIKE '01%' --金数个贷也报消费类
                    GROUP BY T.ACCT_NUM) TT
          ON C.CONTRACT_NUM = TT.ACCT_NUM*/
        INNER JOIN SMTMODS.L_CUST_P P
                      ON P.DATA_DATE =C.DATA_DATE
                     AND P.CUST_ID =C.CUST_ID
        
       
        LEFT JOIN SMTMODS.L_PUBL_RATE R --汇率表
          ON R.DATA_DATE = C.DATA_DATE
         AND R.BASIC_CCY = C.CURR_CD
         AND R.FORWARD_CCY = 'CNY'
       WHERE C.DATA_DATE = IS_DATE
         AND C.ACCT_STS = '1'
         AND C.CONTRACT_NUM IN
                      (SELECT T.ACCT_NUM
                         FROM SMTMODS.L_ACCT_LOAN T
                        WHERE T.DATA_DATE = IS_DATE
                          AND T.CANCEL_FLG = 'N'
                          AND T.ACCT_TYP NOT IN ('030101','030102') -- 不取银行承兑汇票  商业承兑汇票
                          AND T.LOAN_ACCT_BAL <> 0
                          AND T.LOAN_STOCKEN_DATE IS NULL    -- ADD BY HAORUI 20250311 JLBA202408200012 资产未转让
                          AND T.ACCT_STS <> '3'
                          AND T.ACCT_TYP NOT LIKE '90%' --剔除委托贷款
                          AND T.ITEM_CD NOT IN ('130102','130105') --剔除转贴现
                          
                        GROUP BY T.ACCT_NUM)
       GROUP BY C.CUST_ID;
    COMMIT;


     --加工信用卡授信数据

     DELETE FROM PBOCD_AGRE_CREDITLINE_INFO_XYK WHERE DATA_DATE = IS_DATE;
    COMMIT;
    
INSERT INTO PBOCD_AGRE_CREDITLINE_INFO_XYK
  (CUST_ID, FACILITY_AMT, DATA_DATE)
  SELECT T1.CUST_ID,
         SUM(CASE
               WHEN NVL(T1.QUANTUM_CNY, 0) >
                    NVL(T1.M0, 0) + NVL(T1.M1, 0) + NVL(T1.M2, 0) +
                    NVL(T1.M3, 0) + NVL(T1.M4, 0) + NVL(T1.M5, 0) +
                    NVL(T1.M6, 0) + NVL(T1.M6_UP, 0) THEN
                NVL(T1.QUANTUM_CNY, 0)
               ELSE
                NVL(T1.M0, 0) + NVL(T1.M1, 0) + NVL(T1.M2, 0) + NVL(T1.M3, 0) +
                NVL(T1.M4, 0) + NVL(T1.M5, 0) + NVL(T1.M6, 0) + NVL(T1.M6_UP, 0)
             END) AS FACILITY_AMT,
         IS_DATE
    FROM SMTMODS.L_ACCT_CARD_CREDIT T1 -- 信用卡账户信息表
   WHERE T1.DATA_DATE = IS_DATE
     AND (T1.DEALDATE = IS_DATE OR T1.DEALDATE = '00000000')
     AND (T1.EDSQRQ <= IS_DATE OR T1.EDSQRQ IS NULL) -- [20250415][姜俐锋][JLBA202502210009][吴大为]: 合同起始日大于采集日期，去掉，不取数了
     AND NOT EXISTS (SELECT 1
            FROM SMTMODS.L_ACCT_WRITE_OFF W
           WHERE W.DATA_DATE = IS_DATE
             AND W.DATE_SOURCESD = '信用卡核销'
             AND T1.ACCT_NUM = W.ACCT_NUM) -- [20250415][姜俐锋][JLBA202502200003][李逊昂,吴大为]: 去掉核销部分  
   GROUP BY T1.CUST_ID;
    COMMIT;

INSERT INTO PBOCD_AGRE_CREDITLINE_INFO_XYK
  (CUST_ID, FACILITY_AMT, DATA_DATE)
  SELECT T1.CUST_ID,
         SUM(CASE
               WHEN NVL(T1.QUANTUM_CNY, 0) >
                    NVL(T1.M0, 0) + NVL(T1.M1, 0) + NVL(T1.M2, 0) +
                    NVL(T1.M3, 0) + NVL(T1.M4, 0) + NVL(T1.M5, 0) +
                    NVL(T1.M6, 0) + NVL(T1.M6_UP, 0) THEN
                NVL(T1.QUANTUM_CNY, 0)
               ELSE
                NVL(T1.M0, 0) + NVL(T1.M1, 0) + NVL(T1.M2, 0) + NVL(T1.M3, 0) +
                NVL(T1.M4, 0) + NVL(T1.M5, 0) + NVL(T1.M6, 0) + NVL(T1.M6_UP, 0)
             END) AS FACILITY_AMT,
         IS_DATE
    FROM SMTMODS.L_ACCT_CARD_CREDIT T1 -- 信用卡账户信息表
    LEFT JOIN SMTMODS.L_ACCT_DEPOSIT TD
      ON T1.DATA_DATE = TD.DATA_DATE
     AND T1.ACCT_NUM = TD.ACCT_NUM
     AND TD.GL_ITEM_CODE = '20110111'
    /*LEFT JOIN SMTMODS.L_ACCT_DEPOSIT T4
      ON T1.ACCT_NUM = T4.ACCT_NUM
     AND T4.DATA_DATE = LAST_DT
     AND T4.GL_ITEM_CODE = '20110111'*/
   WHERE T1.DATA_DATE = IS_DATE
     AND T1.DEALDATE <> '00000000'
     AND (/*T4.ACCT_NUM IS NOT NULL OR
         T4.ACCT_NUM IS NULL AND */TD.ACCT_NUM IS NOT NULL) -- 前一天有溢款款 或 前一天无溢缴款当有有溢缴款
     AND (T1.EDSQRQ <= IS_DATE OR T1.EDSQRQ IS NULL) -- [20250415][姜俐锋][JLBA202502210009][吴大为]: 合同起始日大于采集日期，去掉，不取数了
     AND NOT EXISTS (SELECT 1
            FROM SMTMODS.L_ACCT_WRITE_OFF W
           WHERE W.DATA_DATE = IS_DATE
             AND W.DATE_SOURCESD = '信用卡核销'
             AND T1.ACCT_NUM = W.ACCT_NUM) -- [20250415][姜俐锋][JLBA202502200003][李逊昂,吴大为]: 去掉核销部分  
   GROUP BY T1.CUST_ID;
COMMIT;



  --加工最终授信结果数据
  
    --查看此表是否已经建立分区
    SELECT COUNT(1)
      INTO NUM
      FROM USER_TAB_PARTITIONS
     WHERE TABLE_NAME = 'PBOCD_AGRE_CREDITLINE_INFO'
       AND PARTITION_NAME = 'P' || IS_DATE;
    --如果没有建立分区，则增加分区
    IF (NUM = 0) THEN
      EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_AGRE_CREDITLINE_INFO ADD PARTITION P' ||
                        IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
    END IF;

    --清除当前分区表的数据
    EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_AGRE_CREDITLINE_INFO TRUNCATE PARTITION P' ||
                      IS_DATE;
INSERT INTO PBOCD_AGRE_CREDITLINE_INFO --统一授信临时表
  (DATA_DATE, CUST_ID, FACILITY_AMT)
  SELECT T.DATA_DATE, T.CUST_ID, SUM(T.FACILITY_AMT)
    FROM (SELECT *
            FROM PBOCD_AGRE_CREDITLINE_INFO_DG T
           WHERE T.DATA_DATE = IS_DATE
          /*UNION ALL
          SELECT *
            FROM PBOCD_AGRE_CREDITLINE_INFO_BW T
           WHERE T.DATA_DATE = IS_DATE*/
          UNION ALL
          SELECT *
            FROM PBOCD_AGRE_CREDITLINE_INFO_GR T
           WHERE T.DATA_DATE = IS_DATE
          UNION ALL
          SELECT *
            FROM PBOCD_AGRE_CREDITLINE_INFO_XYK T
           WHERE T.DATA_DATE = IS_DATE) T
   GROUP BY T.DATA_DATE, T.CUST_ID;
COMMIT;
----------------------------结束 授信临时表------------------------------------------------
  
----------------------------------------------------------------------------
--更正L_PUBL_ORG_BRA_TMP表中的金融机构代码 91660201682608864C更正成91220201682608864C
--[2025-05-27] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_二阶段][李楠] 剔除取上期/配置表
--BSP_SP_JS_SPOP(IS_DATE,OI_RETCODE,OI_RETCODE_DEC,'L_PUBL_ORG_BRA_TMP');

-------------------------------------------------------------------------------------
  OI_RETCODE := 0; --设置成功状态为0
  OI_RETCODE_DEC :='执行成功';

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
    SP_PBOCD_LOG(VS_PROCEDURE_NAME,
                 'ERROR',
                 VI_ERRORCODE,
                 VS_TEXT,
                 IS_DATE);
END;
/
