CREATE OR REPLACE PROCEDURE PBOCD_DATACORE.BSP_SP_JS_202_WQYBJY (IS_DATE    IN VARCHAR2,
                                    OI_RETCODE OUT INTEGER,
                                    OI_RETCODE_DEC OUT VARCHAR2
                  )  ------------------------------------------------------------------------------------------------------
  -- 程序名
  -- PBOCD_DATACORE
  -- 业务域: 其他
  -- 用途: 加工代发工资数据，包括工资、福利、社保等
  -- 参数
  --    IS_DATE 输入，传入跑批日期
  --    OI_RETCODE 输出，用来标识存储过程执行过程中是否出现异常
  -- 引用的监管集市表
  --    SMTMODS.L_ACCT_DEPOSIT                             — 存款账户信息表
  --    SMTMODS.L_CUST_C                                   — 对公客户补充信息表
  --    SMTMODS.L_CUST_P                                   — 对私客户补充信息表
  --    SMTMODS.L_TRAN_TX                                  — 交易信息表
  ------------------------------------------------------------------------------------------------------
AS
  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
  NUM               INTEGER;
  VS_NMONTH         VARCHAR2(10);
  VS_ORDERDATE      VARCHAR2(8); --循环日期
  VS_LAST_TEXT      VARCHAR2(8);

BEGIN
  VS_TEXT      := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  VS_NMONTH    := TO_CHAR(TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD') + 1), 'YYYYMMDD');
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), -1),'YYYYMMDD');

  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'BSP_SP_JS_202_WQYBJY';
  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------


  --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'JS_202_WQYBJY'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE JS_202_WQYBJY ADD PARTITION P' ||
                      IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE JS_202_WQYBJY TRUNCATE PARTITION P' ||
                    IS_DATE;

  --清空临时表数据
  VS_STEP := '1';
  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_202_WQYBJY_TMP1'; --流水数据中间表
  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_202_WQYBJY_TMP2'; --企业信息中间表
  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_202_WQYBJY_TMP5'; --对公存款账户中间表
  EXECUTE IMMEDIATE 'TRUNCATE TABLE JS_202_WQYBJY_TMP7'; --对公存款账户中间表

  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

  --插入中间表数据
  VS_STEP := VS_STEP + 1;
  VS_ORDERDATE := SUBSTR(IS_DATE, 1, 6) || '01';
  --循环开始
  LOOP
  --插入本月流水数据至中间表
  insert into JS_202_WQYBJY_TMP1(
         data_date, --数据日期
         tx_dt,     --交易日期
         key_trans_no, --核心交易流水号
         sub_trans_no, --子交易流水号
         reference_num, --交易流水号/业务标识号
         cd_type, --借贷标志
         currency, --交易币种
         tran_code, --交易代码
         tran_code_describe, --交易代码中文描述
         us_age, ---资金用途
         summary, --摘要
         tran_sts, --交易状态
         trans_flg, --现转标志
         org_num, --交易机构
         cust_id, --客户号
         account_code,--账号
         oppo_acct_num, --对方账号
         oppo_acct_nam, --对方账户名称
         trans_amt, --交易金额
         OPPO_ACCT_NAM1
  )
  SELECT /*+PARALLEL(4)*/
     A.DATA_DATE,
     to_char(A.TX_DT,'yyyymmdd') TX_DT,--7交易日期
     A.KEY_TRANS_NO,--核心交易流水号
     a.sub_trans_no,--子交易流水号
     A.REFERENCE_NUM,--1交易流水号
     a.CD_TYPE,--借贷标志
     A.CURRENCY,--币种
     a.tran_code,--交易代码
     a.tran_code_describe,--交易代码中文描述
     a.us_age,--资金用途
     a.summary,--摘要
     a.tran_sts,--交易状态
     a.trans_flg,--现转标志
     a.ORG_NUM,--6机构号
     A.CUST_ID,--3客户号
     A.ACCOUNT_CODE,--5账号
     A.OPPO_ACCT_NUM,--24对方账户账号
     A.OPPO_ACCT_NAM,--4对方账户名称
     A.TRANS_AMT,--8交易金额
     REPLACE(REPLACE(A.OPPO_ACCT_NAM,'吉林银行代发工资专户-',''),'吉林银行其他代发-','') OPPO_ACCT_NAM1
  FROM SMTMODS.L_TRAN_TX A --交易信息表
  WHERE A.DATA_DATE  =  VS_ORDERDATE
  AND ISWAGES='Y'--是否代发工资Y是N否
  AND TRANS_CHANNEL<>'EIBS';--去除企业网银代发

  COMMIT;

  VS_ORDERDATE := VS_ORDERDATE + 1;
  EXIT WHEN VS_ORDERDATE = IS_DATE + 1;
  END LOOP;

  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

  VS_STEP := VS_STEP + 1;
  --插入对公社会统一信用码数据至临时表
  INSERT INTO JS_202_WQYBJY_TMP7
  SELECT /*+PARALLEL(4)*/* FROM (
         SELECT T.* ,COUNT(1) JLS FROM (
                SELECT DISTINCT a.cust_nam,a.id_no,REPLACE(A.ORGANIZATIONCODE,'-','')ORGANIZATIONCODE
                FROM SMTMODS.L_CUST_C A
                WHERE A.DATA_DATE = IS_DATE
                --AND A.CUST_NAM = '白山市浑江区鲜盛蔬菜水果店'
                and (length(replace(a.id_no,'-','')) in (18) )
                AND A.ID_TYPE ='236'

                UNION
                SELECT DISTINCT a.cust_nam,a.tyshxydM,REPLACE(A.ORGANIZATIONCODE,'-','')
                FROM SMTMODS.L_CUST_C
                A WHERE A.DATA_DATE = IS_DATE
                and LENGTH(A.TYSHXYDM ) = 18 AND A.TYSHXYDM NOT LIKE '%000000%'
                AND SUBSTR(A.TYSHXYDM ,1,1) NOT IN ('B','G')
                AND (length(replace(a.id_no,'-','')) NOT in (18) )
                AND NOT EXISTS(
                        SELECT 1 FROM SMTMODS.L_CUST_C   A1
                        WHERE A.CUST_NAM = A1.CUST_NAM AND A.DATA_DATE = A1.DATA_DATE
                )
                --AND A.CUST_NAM = '白山市浑江区鲜盛蔬菜水果店'

         ) T GROUP BY T.cust_nam,id_no,ORGANIZATIONCODE
  ) WHERE JLS = 1;
  COMMIT;

  --删除对公客户存在多个社会统一信用码的数据
  DELETE /*+PARALLEL(4)*/FROM JS_202_WQYBJY_TMP7 Q
  WHERE Q.CUST_NAM IN (
        SELECT CUST_NAM FROM (
               SELECT T.CUST_NAM,COUNT(1) FROM  JS_202_WQYBJY_TMP7 T
               GROUP BY CUST_NAM HAVING COUNT(1) > 1
        )
  );

  COMMIT;
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);


  VS_STEP := VS_STEP + 1;
  --加工对公存款客户中间表
  INSERT INTO JS_202_WQYBJY_TMP5
  SELECT /*+PARALLEL(4)*/
         SUBSTR(A.ACCT_NUM, 1, INSTR(A.ACCT_NUM, '_') - 1) ACCT_NUM1, --账号（新）
         A.ACCT_NUM, --账号
         A.PASSBOOK_ACCT_NUM, --原账号
         A.CUST_ID, --客户号
         A.ACCT_NAM, --账户名
         A.ORG_NUM, --机构号
         A.FIRST_ISWAGES_DT, --首次代发日期
         b.cust_nam, --客户名称
         b.tyshxydm, --统一社会信用代码
         --b.organizationcode, --组织机构代码
         REPLACE(b.organizationcode,'-',''), --组织机构代码 zlp20250714
         b.id_no,--证件号码
         b.id_type,--证件类型
         case when b.tyshxydm is not null and SUBSTR(b.tyshxydm,1,1) not in ('B','G') then b.tyshxydm
              when length(b.id_no) = 18 then b.id_no
              when b.organizationcode is not null then REPLACE(b.organizationcode,'-','') else b.id_no end zjhm,--证件号（新）
         case when b.tyshxydm is not null and SUBSTR(b.tyshxydm,1,1) not in ('B','G') then 'A01'
              when length(b.id_no) = 18 then 'A01'
              when b.organizationcode is not null then 'A02' else 'A03' end zjlx--证件类型（新）
  FROM (
       SELECT A.ACCT_NUM,A.CUST_ID,A.PASSBOOK_ACCT_NUM,A.FIRST_ISWAGES_DT,A.ORG_NUM,ACCT_NAM,
              ROW_NUMBER() OVER(PARTITION BY A.ACCT_NUM ORDER BY A.ST_INT_DT ASC) RN
       FROM SMTMODS.L_ACCT_DEPOSIT A
       WHERE A.DATA_DATE = IS_DATE
  ) A --存款账户信息表
  INNER JOIN PBOCD_DATACORE.L_CUST_C_TMP B --对公客户补充信息中间表
  ON A.CUST_ID = B.CUST_ID AND B.DATA_DATE = IS_DATE AND B.CUST_TYP <> '3' --去除个体工商户
  WHERE A.RN =1
  ;

  COMMIT;
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);


  VS_STEP := VS_STEP + 1;
  --插入代发企业信息
  INSERT INTO JS_202_WQYBJY_TMP2(
         data_date, --数据日期
         tx_dt,  --交易日期
         key_trans_no, --核心交易流水号
         sub_trans_no, --子交易流水号
         reference_num, --交易流水号
         cd_type, --借贷标识
         currency, --交易币种
         tran_code, --交易代码
         tran_code_describe, --交易代码描述
         us_age,  --交易用途
         summary, --摘要
         tran_sts, --交易状态
         trans_flg, --现转标识
         org_num,  --机构号
         cust_id, --客户号
         cust_nam, --客户名
         id_no, --证件号
         id_type, --证件类型
         account_code, --账号
         oppo_acct_num, --对方账号
         oppo_acct_nam,--对方账户名称
         oppo_cust_id, --对方客户号
         oppo_cust_nam,--对方客户名
         oppo_TYSHXYDM,--对方社会统一信用码
         oppo_ORGANIZATIONCODE,--对方组织机构码
         oppo_ID_NO,--对方证件号
         oppo_ID_TYPE,--对方证件类型
         trans_amt, --交易金额
         sfgr--是否个人
  )
  SELECT /*+PARALLEL(4)*/
         T.data_date,  --数据日期
         T.tx_dt,  --交易日期
         T.key_trans_no, --核心交易流水号
         T.sub_trans_no, --子交易流水号
         T.reference_num, --交易流水号
         T.cd_type, --借贷标识
         T.currency, --交易币种
         T.tran_code, --交易代码
         T.tran_code_describe, --交易代码中文描述
         T.us_age,  --交易用途
         T.summary, --摘要
         T.tran_sts, --交易状态
         T.trans_flg, --现转标识
         T.org_num, --机构
         T.cust_id, --客户号
         A.CUST_NAM, --客户名
         A.id_no, --证件号
         A.id_type, --证件类型
         t.account_code, --账号
         t.oppo_acct_num,--单位账号
         t.oppo_acct_nam,--单位名称
         B.CUST_ID AS oppo_cust_id, --单位客户号
         NVL(B1.CUST_NAM,B.CUST_NAM) AS oppo_cust_nam, --单位客户名
         NVL(B1.ID_NO,B.TYSHXYDM) as oppo_TYSHXYDM, --单位客户社会统一信用码
         NVL(B1.ORGANIZATIONCODE,B.ORGANIZATIONCODE) as oppo_ORGANIZATIONCODE,--单位客户组织机构代码
         B.ZJHM as oppo_ID_NO,--单位客户证件号
         CASE WHEN B1.ID_NO IS NOT NULL THEN 'A01' ELSE B.ZJLX END as oppo_ID_TYPE,--单位客户证件类型
         t.trans_amt,
         t.sfgr
  FROM JS_202_WQYBJY_TMP1 T --代发工资流水中间表
  INNER JOIN SMTMODS.L_CUST_P A --对私客户补充信息表
  ON T.CUST_ID = A.CUST_ID AND A.DATA_DATE = IS_DATE
  LEFT JOIN JS_202_WQYBJY_TMP5 b --代发对公中间表5,获取单位客户信息
  on (t.oppo_acct_num = b.acct_num  )
  LEFT JOIN JS_202_WQYBJY_TMP7 B1
  ON T.OPPO_ACCT_NAM1 = B1.CUST_NAM
  ;
  COMMIT;
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

  VS_STEP := VS_STEP + 1;
  INSERT INTO JS_202_WQYBJY_TMP2
  SELECT /*+PARALLEL(4)*/
         T.data_date,  --数据日期
         T.tx_dt,  --交易日期
         T.key_trans_no, --核心交易流水号
         T.sub_trans_no, --子交易流水号
         T.reference_num, --交易流水号
         T.cd_type, --借贷标识
         T.currency, --交易币种
         T.tran_code, --交易代码
         T.tran_code_describe, --交易代码中文描述
         T.us_age,  --交易用途
         T.summary, --摘要
         T.tran_sts, --交易状态
         T.trans_flg, --现转标识
         T.org_num, --机构
         T.cust_id, --客户号
         A.CUST_NAM, --客户名
         A.id_no, --证件号
         A.id_type, --证件类型
         t.account_code, --账号
         t.oppo_acct_num,--单位账号
         t.oppo_acct_nam,--单位名称
         B.CUST_ID AS oppo_cust_id, --单位客户号
         NVL(B1.CUST_NAM,B.CUST_NAM) AS oppo_cust_nam, --单位客户名
         NVL(B1.ID_NO,B.TYSHXYDM) as oppo_TYSHXYDM, --单位客户社会统一信用码
         NVL(B1.ORGANIZATIONCODE,B.ORGANIZATIONCODE) as oppo_ORGANIZATIONCODE,--单位客户组织机构代码
         B.ZJHM as oppo_ID_NO,--单位客户证件号
         CASE WHEN B1.ID_NO IS NOT NULL THEN 'A01' ELSE B.ZJLX END as oppo_ID_TYPE,--单位客户证件类型
         t.trans_amt,
         t.sfgr
  FROM JS_202_WQYBJY_TMP1 T --代发工资流水中间表
  INNER JOIN SMTMODS.L_CUST_P A --对私客户补充信息表
  ON T.CUST_ID = A.CUST_ID AND A.DATA_DATE = IS_DATE
  LEFT JOIN JS_202_WQYBJY_TMP5 b --代发对公中间表5,获取单位客户信息
  on (t.oppo_acct_num = b.passbook_acct_num)
  LEFT JOIN JS_202_WQYBJY_TMP7 B1
  ON T.OPPO_ACCT_NAM1 = B1.CUST_NAM
  WHERE NOT EXISTS(
        SELECT 1 FROM JS_202_WQYBJY_TMP2 T WHERE T.KEY_TRANS_NO || T.REFERENCE_NUM = T.KEY_TRANS_NO || T.REFERENCE_NUM
  )
  ;
  COMMIT;
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);



  --加工稳企业保就业数据
  VS_STEP := VS_STEP + 1;
  INSERT INTO  JS_202_WQYBJY (
         DATA_DATE,           --1数据日期
         ORG_CODE,            --2机构号
         CUST_ID_TYPE,        --3客户证件类型
         CUST_ID_NO,          --4客户证件号
         TRANS_BGN_DATE,      --5
         STAFF_ID_TYPE,       --6员工证件类型
         STAFF_ID_NO,         --7员工证件号
         TRANS_AMT,           --8交易金额
         TRANS_DATE,          --9交易日期
         REPORT_ID,           --10
         CJRQ,                --11数据采集日期
         NBJGH,               --12内部机构号
         BIZ_LINE_ID,         --13业务条线
         VERIFY_STATUS,       --14
         BSCJRQ,              --15
         FRNBJGH,             --16法人内部机构号
         SERIAL_NUM,          --17交易流水号
         ORG_NUM,             --18机构号
         OPPO_ACCT_NUM,       --19对方账户账号
         OPPO_ACCT_NAM,       --20对方账户名称
         ACCOUNT_CODE,        --21账号
         CUST_ID,             --22客户号
         CUST_NAM,             --23客户名称
         OPPO_CUST_ID,         --单位客户号
         OPPO_CUST_NAM         --单位名称
  )
 SELECT /*+PARALLEL(4)*/
        IS_DATE DATA_DATE,--1数据日期
        A.ORG_NUM ORG_CODE,--2机构号
        CASE WHEN A.OPPO_TYSHXYDM IS NOT NULL THEN 'A01'
             WHEN LENGTH(a.oppo_id_no) = 18 then 'A01'
             WHEN A.OPPO_ORGANIZATIONCODE IS NOT NULL THEN 'A02'
        --ELSE F1.PBOCD_CODE END CUST_ID_TYPE,--3客户证件类型
        ELSE A.OPPO_ID_TYPE END CUST_ID_TYPE,--3客户证件类型
        
        CASE WHEN A.OPPO_TYSHXYDM IS NOT NULL THEN A.OPPO_TYSHXYDM
             WHEN LENGTH(a.oppo_id_no) = 18 then a.oppo_id_no
             WHEN A.OPPO_ORGANIZATIONCODE IS NOT NULL THEN A.OPPO_ORGANIZATIONCODE
        ELSE A.OPPO_ID_NO END CUST_ID_NO, --4客户证件号
        TO_CHAR(TO_DATE(D.SIGN_DATE,'YYYYMMDD'),'YYYY-MM-DD'), --5代发开始日期
        F.PBOCD_CODE AS STAFF_ID_TYPE,      --6员工证件类型
        A.ID_NO as STAFF_ID_NO, --7员工证件号
        A.TRANS_AMT,--8交易金额
        TO_CHAR(TO_DATE(A.TX_DT,'yyyymmdd'),'YYYY-MM-DD') AS TRANS_DATE,--9交易日期
        SYS_GUID() REPORT_ID, --10
        IS_DATE CJRQ, --11数据采集日期
        A.ORG_NUM AS NBJGH, --12内部机构号
        '99' AS BIZ_LINE_ID,--13业务条线
        '' AS VERIFY_STATUS,--14校验状态
        '' AS BSCJRQ, --15报送采集日期
/*        CASE WHEN A.ORG_NUM LIKE '51%' THEN '510000' 
          ELSE '990000' END FRNBJGH,--16法人内部机构号*/
          CASE WHEN A.ORG_NUM LIKE '51%' THEN
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
        '600000'----20231101多法人新增
        ELSE '990000' END FRNBJGH,--16法人内部机构号
        A.KEY_TRANS_NO||A.REFERENCE_NUM AS SERIAL_NUM,--17交易流水号
        A.ORG_NUM,--18机构号
        A.OPPO_ACCT_NUM,--19单位账号
        A.OPPO_ACCT_NAM,--20单位账户名称
        A.ACCOUNT_CODE,--21员工账号
        A.CUST_ID, --22员工客户号
        A.CUST_NAM, --23员工名称
        A.OPPO_CUST_ID, --单位客户号
        A.OPPO_CUST_NAM --单位客户名
  FROM PBOCD_DATACORE.JS_202_WQYBJY_TMP2 A --稳企业保就业中间表2
  LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY F --加工员工证件类型
  ON a.ID_TYPE = F.L_CODE AND F.CODE_CLMN_NAME = 'ID_TYPE'
  LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY F1 --加工员工证件类型
  ON A.OPPO_ID_TYPE = F1.L_CODE AND F1.CODE_CLMN_NAME = 'ID_TYPE'
  LEFT JOIN (
       SELECT D.*,ROW_NUMBER() OVER(PARTITION BY CUST_NAM ORDER BY D.SIGN_DATE DESC) RN
       FROM JS_202_WQYBJY_TMP4 D  --代发工资维护表
  ) D
  ON (A.OPPO_ACCT_NAM = D.CUST_NAM )  AND D.RN = 1
  WHERE A.TRAN_CODE_DESCRIBE NOT IN ('水费','其他','补贴','乙醇代发','助学金','奖金','报销款','支公积金','网银批量','批量代发其他','补偿','批量转账贷方入账失败 借方回冲','差旅费','占地款')
  ;
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  COMMIT;

  --查看落地表是否已经建立分区
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'PBOCD_JS_202_WQYBJY'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --如果没有建立分区，则增加分区
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_202_WQYBJY ADD PARTITION P' || IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

  EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_JS_202_WQYBJY TRUNCATE PARTITION P' || IS_DATE;


 VS_STEP := '2';
 --插入目标表
  INSERT INTO PBOCD_JS_202_WQYBJY(
         DATA_DATE,  --数据日期
           ORG_CODE, --金融机构分支机构统一社会信用代码
           CUST_ID_TYPE,-- 单位证件类型
           CUST_ID_NO, --单位证件代码
           TRANS_BGN_DATE,-- 代发业务开始时间
           STAFF_ID_TYPE, --员工证件类型
           STAFF_ID_NO, --员工证件代码
           TRANS_AMT, --员工工资金额
           TRANS_DATE, --代发工资日期
           REPORT_ID, --报表ID
           CJRQ, --采集日期
           NBJGH, --内部机构号
           BIZ_LINE_ID,--业务条线
           VERIFY_STATUS,-- 校验状态
           BSCJRQ, --报送采集日期
           FRNBJGH, --法人内部机构号
           SERIAL_NUM, --流水号
           ORG_NUM,--内部机构号
           OPPO_ACCT_NUM,--对方账号
           OPPO_ACCT_NAM,--对方户名
           ACCOUNT_CODE,--账号
           CUST_ID,--客户号
           CUST_NAM--客户号
  )
 SELECT/*+PARALLEL(4)*/
      VS_TEXT AS DATA_DATE,  --数据日期
      --SYS.JRJGBM AS ORG_CODE,  --金融机构分支机构统一社会信用代码
      NVL(OB.ID_NO,OB.UP_ID_NO), --金融机构分支机构统一社会信用代码
      CUST_ID_TYPE,  --单位证件类型
      A.CUST_ID_NO,   --单位证件代码
      A.TRANS_BGN_DATE,  --单位证件代码
      A.STAFF_ID_TYPE,  --员工证件类型
      A.STAFF_ID_NO,  --员工证件代码
      A.TRANS_AMT,  --员工工资金额
      A.TRANS_DATE,  --代发工资日期
      SYS_GUID() REPORT_ID,
      IS_DATE CJRQ,
      A.NBJGH,
      '99' BIZ_LINE_ID,
      '' VERIFY_STATUS,
      '' BSCJRQ,
      /*CASE WHEN A.ORG_NUM LIKE '51%' THEN '510000' ELSE '990000' END FRNBJGH,   --法人内部机构号*/
      CASE WHEN A.ORG_NUM LIKE '51%' THEN
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
        '600000'----20231101多法人新增
      ELSE '990000' END FRNBJGH,
      MAX(SERIAL_NUM) SERIAL_NUM,  --流水号
      A.ORG_NUM,  --内部机构号
      MAX(A.OPPO_ACCT_NUM),--对方账号
      MAX(A.OPPO_ACCT_NAM),--对方户名
      MAX(A.ACCOUNT_CODE),--账号
      MAX(A.CUST_ID),--客户号
      MAX(A.CUST_NAM)--客户号
  FROM PBOCD_DATACORE.JS_202_WQYBJY A --稳企业保就业
  /*LEFT JOIN SYS_OFFICE SYS --机构表
  ON A.NBJGH = SYS.ID*/
  LEFT JOIN L_PUBL_ORG_BRA_TMP OB--金数机构表
      ON OB.ORG_NUM=A.NBJGH AND OB.DATA_DATE=IS_DATE
  WHERE A.CJRQ = IS_DATE
  AND A.OPPO_ACCT_NAM NOT LIKE '%居民委员会%' AND A.OPPO_ACCT_NAM NOT LIKE '%村民委员会%'
  GROUP BY --SYS.JRJGBM,  --金融机构分支机构统一社会信用代码
      NVL(OB.ID_NO,OB.UP_ID_NO),  --金融机构分支机构统一社会信用代码
      CUST_ID_TYPE,  --单位证件类型
      A.CUST_ID_NO,   --单位证件代码
      A.TRANS_BGN_DATE,  --单位证件代码
      A.STAFF_ID_TYPE,  --员工证件类型
      A.STAFF_ID_NO,  --员工证件代码
      A.TRANS_AMT,  --员工工资金额
      A.TRANS_DATE,  --代发工资日期
      A.NBJGH,
      CASE WHEN A.ORG_NUM LIKE '51%' THEN
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
        '600000'----20231101多法人新增 
        ELSE '990000' END,
      A.ORG_NUM
  ;
 COMMIT;
 SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
 COMMIT;
 
 VS_STEP := '99';
 MERGE INTO PBOCD_JS_202_WQYBJY  AA
 USING (
       SELECT /*+PARALLEL(4)*/A.OPPO_ACCT_NAM,
              CASE WHEN B.TYSHXYDM IS NOT NULL THEN B.TYSHXYDM 
                   WHEN LENGTH(B.ID_NO ) = 18 THEN B.ID_NO 
                   WHEN B.ORGANIZATIONCODE IS NOT NULL THEN REPLACE(B.ORGANIZATIONCODE,'-','')
              ELSE B.ID_NO END ZJHM,
              CASE WHEN B.TYSHXYDM IS NOT NULL THEN 'A01' 
                   WHEN LENGTH(B.ID_NO ) = 18 THEN 'A01'
                   WHEN B.ORGANIZATIONCODE IS NOT NULL THEN 'A02'
              ELSE 'A03' END ZJLX,
              ROW_NUMBER() OVER(PARTITION BY A.OPPO_ACCT_NAM ORDER BY CJRQ DESC)  RN
       FROM PBOCD_JS_202_WQYBJY A
       INNER JOIN (
             SELECT B.CUST_NAM,B.TYSHXYDM,B.ORGANIZATIONCODE,B.ID_NO,
                    ROW_NUMBER() OVER(PARTITION BY CUST_NAM ORDER BY B.ID_NO DESC) RN 
             FROM SMTMODS.L_CUST_C B
             WHERE B.DATA_DATE = IS_DATE
        ) B ON REPLACE(A.OPPO_ACCT_NAM,'吉林银行其他代发-','') = B.CUST_NAM AND B.RN =  1
        WHERE A.CUST_ID_NO IS NULL
 ) A ON (AA.OPPO_ACCT_NAM = A.OPPO_ACCT_NAM AND AA.CJRQ = IS_DATE AND A.RN = 1)
 WHEN MATCHED THEN UPDATE SET AA.CUST_ID_TYPE = A.ZJLX ,AA.CUST_ID_NO = A.ZJHM
 WHERE AA.CJRQ  = IS_DATE
 AND AA.CUST_ID_NO IS NULL
 ;
 COMMIT;
 
 MERGE INTO PBOCD_JS_202_WQYBJY  AA
 USING (
       SELECT /*+PARALLEL(4)*/A.OPPO_ACCT_NAM,
              CASE WHEN B.TYSHXYDM IS NOT NULL THEN B.TYSHXYDM 
                   WHEN LENGTH(B.ID_NO ) = 18 THEN B.ID_NO 
                   WHEN B.ORGANIZATIONCODE IS NOT NULL THEN REPLACE(B.ORGANIZATIONCODE,'-','')
              ELSE B.ID_NO END ZJHM,
              CASE WHEN B.TYSHXYDM IS NOT NULL THEN 'A01' 
                   WHEN LENGTH(B.ID_NO ) = 18 THEN 'A01'
                   WHEN B.ORGANIZATIONCODE IS NOT NULL THEN 'A02'
              ELSE 'A03' END ZJLX,
              ROW_NUMBER() OVER(PARTITION BY A.OPPO_ACCT_NAM ORDER BY CJRQ DESC)  RN
       FROM PBOCD_JS_202_WQYBJY A
       INNER JOIN (
             SELECT B.CUST_NAM,B.TYSHXYDM,B.ORGANIZATIONCODE,B.ID_NO,
                    ROW_NUMBER() OVER(PARTITION BY CUST_NAM ORDER BY B.ID_NO DESC) RN 
             FROM SMTMODS.L_CUST_C B
             WHERE B.DATA_DATE = IS_DATE
       ) B ON REPLACE(A.OPPO_ACCT_NAM,'吉林银行代发工资专户-','') = B.CUST_NAM AND B.RN =  1
       WHERE A.CUST_ID_NO IS NULL
 ) A ON (AA.OPPO_ACCT_NAM = A.OPPO_ACCT_NAM AND AA.CJRQ = IS_DATE AND A.RN = 1)
 WHEN MATCHED THEN UPDATE SET AA.CUST_ID_TYPE = A.ZJLX ,AA.CUST_ID_NO = A.ZJHM
 WHERE AA.CJRQ  = IS_DATE
 AND AA.CUST_ID_NO IS NULL
 ;
 COMMIT;
 
 MERGE  INTO PBOCD_JS_202_WQYBJY AA 
 USING (
       SELECT /*+PARALLEL(4)*/REPORT_ID,
              A.OPPO_ACCT_NUM,
              B.KEY_TRANS_NO,
              B.CUST_ID,
              C.CUST_NAM,
              CASE WHEN C.TYSHXYDM IS NOT NULL THEN C.TYSHXYDM 
                   WHEN C.ID_NO IS NOT NULL AND LENGTH(C.ID_NO ) = 18 THEN C.ID_NO
                   WHEN C.ORGANIZATIONCODE IS NOT NULL THEN C.ORGANIZATIONCODE ELSE C.ID_NO END ID_NO,
              CASE WHEN C.TYSHXYDM IS NOT NULL THEN 'A01'
                   WHEN C.ORGANIZATIONCODE IS NOT NULL THEN 'A02'
              ELSE CASE WHEN LENGTH(C.ID_NO) = 18 THEN 'A01' WHEN LENGTH(C.ID_NO) = 9 THEN 'A02' ELSE 'A03' END 
              END ZJLX  ,
              ROW_NUMBER() OVER(PARTITION BY A.OPPO_ACCT_NUM ORDER BY A.CJRQ DESC ) RN 
       FROM PBOCD_JS_202_WQYBJY A
       INNER JOIN JS_202_WQYBJY_TMP1 B
       ON SUBSTR(A.OPPO_ACCT_NUM,6) = B.KEY_TRANS_NO 
       AND A.TRANS_DATE = TO_CHAR(TO_DATE(B.TX_DT,'yyyymmdd'),'yyyy-mm-dd') 
       AND A.SERIAL_NUM = B.KEY_TRANS_NO||B.REFERENCE_NUM
       AND B.CD_TYPE = '1'
       LEFT JOIN SMTMODS.L_CUST_C C
       ON B.CUST_ID = C.CUST_ID AND C.DATA_DATE = IS_DATE
       WHERE A.CJRQ = IS_DATE
       AND A.CUST_ID_NO IS NULL AND A.OPPO_ACCT_NAM  LIKE '%代收代扣%'

 ) A
 ON (AA.OPPO_ACCT_NUM = A.OPPO_ACCT_NUM AND AA.CJRQ = IS_DATE AND A.RN = 1)
 WHEN MATCHED THEN UPDATE SET AA.CUST_ID_NO = A.ID_NO ,AA.CUST_ID_TYPE = A.ZJLX
 WHERE AA.CJRQ = IS_DATE
 AND AA.CUST_ID_NO IS NULL
 ;
 COMMIT;
 
 
 MERGE INTO PBOCD_JS_202_WQYBJY AA
 USING (
       SELECT /*+PARALLEL(4)*/A.OPPO_ACCT_NAM,
              A.TRANS_BGN_DATE,
              ROW_NUMBER () OVER(PARTITION BY A.OPPO_ACCT_NAM ORDER BY TRANS_BGN_DATE ASC) RN
       FROM PBOCD_JS_202_WQYBJY_SQ A 
       WHERE A.CJRQ = VS_LAST_TEXT AND A.TRANS_BGN_DATE IS NOT NULL
 ) A
 ON (AA.OPPO_ACCT_NAM = A.OPPO_ACCT_NAM AND AA.CJRQ = IS_DATE AND A.RN = 1 )
 WHEN MATCHED THEN UPDATE SET AA.TRANS_BGN_DATE = A.TRANS_BGN_DATE
 WHERE AA.CJRQ = IS_DATE AND AA.TRANS_BGN_DATE IS NULL
 ;
 COMMIT;
 
 
  
 MERGE INTO PBOCD_JS_202_WQYBJY AA
 USING (
       SELECT /*+PARALLEL(4)*/A.OPPO_ACCT_NAM,
              A.CUST_ID_TYPE,
              A.CUST_ID_NO,
              ROW_NUMBER () OVER(PARTITION BY A.OPPO_ACCT_NAM ORDER BY TRANS_BGN_DATE ASC) RN
       FROM PBOCD_JS_202_WQYBJY_SQ A 
       WHERE A.CJRQ = VS_LAST_TEXT AND A.CUST_ID_NO IS NOT NULL
 ) A
 ON (AA.OPPO_ACCT_NAM = A.OPPO_ACCT_NAM AND AA.CJRQ = IS_DATE AND A.RN = 1 )
 WHEN MATCHED THEN UPDATE SET AA.CUST_ID_NO = A.CUST_ID_NO,AA.CUST_ID_TYPE = A.CUST_ID_TYPE
 WHERE AA.CJRQ = IS_DATE AND AA.CUST_ID_NO IS NULL
 ;
COMMIT;

--A01变成A02/A03按上期刷
MERGE INTO PBOCD_JS_202_WQYBJY AA
USING (SELECT /*+PARALLEL(4)*/
        A.OPPO_ACCT_NAM,
        A.CUST_ID_TYPE,
        A.CUST_ID_NO,
        ROW_NUMBER() OVER(PARTITION BY A.OPPO_ACCT_NAM ORDER BY TRANS_BGN_DATE ASC) RN
         FROM PBOCD_JS_202_WQYBJY_SQ A
        WHERE A.CJRQ = VS_LAST_TEXT
          AND A.CUST_ID_TYPE = 'A01') A
ON (AA.OPPO_ACCT_NAM = A.OPPO_ACCT_NAM AND AA.CJRQ = IS_DATE AND A.RN = 1)
WHEN MATCHED THEN
  UPDATE
     SET AA.CUST_ID_NO = A.CUST_ID_NO, AA.CUST_ID_TYPE = A.CUST_ID_TYPE
   WHERE AA.CJRQ = IS_DATE
     AND AA.CUST_ID_TYPE IN ('A02', 'A03');
COMMIT;

--A02变成A03按上期刷
MERGE INTO PBOCD_JS_202_WQYBJY AA
USING (SELECT /*+PARALLEL(4)*/
        A.OPPO_ACCT_NAM,
        A.CUST_ID_TYPE,
        A.CUST_ID_NO,
        ROW_NUMBER() OVER(PARTITION BY A.OPPO_ACCT_NAM ORDER BY TRANS_BGN_DATE ASC) RN
         FROM PBOCD_JS_202_WQYBJY_SQ A
        WHERE A.CJRQ = VS_LAST_TEXT
          AND A.CUST_ID_TYPE = 'A02') A
ON (AA.OPPO_ACCT_NAM = A.OPPO_ACCT_NAM AND AA.CJRQ = IS_DATE AND A.RN = 1)
WHEN MATCHED THEN
  UPDATE
     SET AA.CUST_ID_NO = A.CUST_ID_NO, AA.CUST_ID_TYPE = A.CUST_ID_TYPE
   WHERE AA.CJRQ = IS_DATE
     AND AA.CUST_ID_TYPE IN ('A03');
COMMIT;
      
 --更新证件类型为B01且不满足个人证件号码的证件类型为B99
 UPDATE /*+PARALLEL(4)*/PBOCD_JS_202_WQYBJY A
 SET A.STAFF_ID_TYPE = 'B99'
 WHERE (F_ISDATE(SUBSTR(A.STAFF_ID_NO,7,8),'YYYYMMDD') IS NULL OR LENGTH(STAFF_ID_NO) <> 18 )
 AND A.CJRQ = IS_DATE AND A.STAFF_ID_TYPE IN ('B01','B08')
 ;
 COMMIT;

--删除证件号码空值的
DELETE /*+PARALLEL(4)*/FROM PBOCD_JS_202_WQYBJY A WHERE CJRQ = IS_DATE
AND CUST_ID_NO IS NULL;
COMMIT;

--删除起始日期空值的
DELETE /*+PARALLEL(4)*/FROM PBOCD_JS_202_WQYBJY A WHERE CJRQ = IS_DATE
AND TRANS_BGN_DATE IS NULL;
COMMIT;

--删除工资社保福利以外的
DELETE /*+PARALLEL(4)*/FROM PBOCD_JS_202_WQYBJY AA
WHERE AA.CJRQ = IS_DATE
AND EXISTS (
SELECT 1 FROM PBOCD_JS_202_WQYBJY A
INNER JOIN JS_202_WQYBJY_TMP1 B
ON A.SERIAL_NUM = B.KEY_TRANS_NO||B.REFERENCE_NUM
WHERE A.CJRQ = IS_DATE AND AA.SERIAL_NUM = A.SERIAL_NUM
--除了工资社保福利，其他都不要
AND B.TRAN_CODE_DESCRIBE NOT LIKE '%社保%'
AND B.TRAN_CODE_DESCRIBE NOT LIKE '%采暖%'
AND B.TRAN_CODE_DESCRIBE NOT LIKE '%车补%'
AND B.TRAN_CODE_DESCRIBE NOT LIKE '%工资%'
AND B.TRAN_CODE_DESCRIBE NOT LIKE '%油补%'
AND B.TRAN_CODE_DESCRIBE NOT LIKE '%养老金%'
AND B.TRAN_CODE_DESCRIBE NOT LIKE '%绩效%'
/*
AND B.TRAN_CODE_DESCRIBE IN ('学费','其他','补贴'
,'乙醇代发','助学金','奖金','报销款','支公积金','网银批量','批量代发其他'
,'补偿','批量转账贷方入账失败 借方回冲','差旅费','占地款'
,'通讯费','托儿费','网银转账')
*/
) ;
COMMIT;

--删除企业客户社会统一信用码不合规的
DELETE /*+PARALLEL(4)*/FROM PBOCD_JS_202_WQYBJY  A 
WHERE A.CJRQ=IS_DATE AND A.CUST_ID_NO IS NOT NULL
AND  (SUBSTR(A.CUST_ID_NO,1,2) NOT IN ('11','12','13','19','21','29','31','32','33','34','35','39','41','49','51','52','53','59','61','62','69','71','72','79','81','89','91','92','93','A1','A9','N1','N2','N3','N9','Y1')
OR NOT REGEXP_LIKE(SUBSTR(A.CUST_ID_NO,3,6),'^[0-9]+$')
OR SUBSTR(A.CUST_ID_NO,3,2) NOT IN ('10','11','12','13','14','15','21','22','23','31','32','33','34','35','36','37','41','42','43','44','45','46','50','51','52','53','54','61','62','63','64','65')
OR (NOT REGEXP_LIKE(SUBSTR(A.CUST_ID_NO,9,9),'^[0-9A-Z]+$') AND SUBSTR(A.CUST_ID_NO,9,9)<>'_')--  不是数字、大写英文字母和下划线
OR NOT REGEXP_LIKE(SUBSTR(A.CUST_ID_NO,-1,1),'^[0-9A-Z]+$')--不是数字和大写英文字母
OR SUBSTR(A.CUST_ID_NO,-1,1)   IN ('I','O','Z','S','V')
) AND A.CUST_ID_TYPE = 'A01' ;
COMMIT;

--删除个人证件号码不合规的
DELETE /*+PARALLEL(4)*/FROM PBOCD_JS_202_WQYBJY AA
 WHERE AA.CJRQ = IS_DATE  AND AA.STAFF_ID_TYPE IN ( 'B01','B08') 
 AND EXISTS(
 SELECT  *
 FROM PBOCD_JS_202_WQYBJY A
WHERE A.CJRQ = IS_DATE
AND A.STAFF_ID_TYPE IN ( 'B01','B08') 
AND (TRUNC(MONTHS_BETWEEN (TO_DATE(IS_DATE,'yyyymmdd'),TO_DATE(SUBSTR(A.STAFF_ID_NO ,7,8)  ,'yyyymmdd')    ) /12 ) >90 OR 
TRUNC(MONTHS_BETWEEN (TO_DATE(IS_DATE,'yyyymmdd'),TO_DATE(SUBSTR(A.STAFF_ID_NO ,7,8)  ,'yyyymmdd')) /12 ) <= 18)
 AND AA.CUST_ID_NO = A.CUST_ID_NO AND AA.STAFF_ID_NO = A.STAFF_ID_NO 
 );
COMMIT;

DELETE  /*+PARALLEL(4)*/FROM PBOCD_JS_202_WQYBJY AA
 WHERE AA.CJRQ = IS_DATE  AND AA.STAFF_ID_TYPE = 'B01' 
 AND EXISTS(
 SELECT  1
 FROM PBOCD_JS_202_WQYBJY A
 INNER JOIN JS_202_WQYBJY_TMP6 B
 ON (A.OPPO_ACCT_NAM = B.CUST_NAM OR A.CUST_ID_NO = B.CUST_ID_NO ) 
WHERE A.CJRQ = IS_DATE
AND A.STAFF_ID_TYPE = 'B01'
AND (TRUNC(MONTHS_BETWEEN (TO_DATE(IS_DATE,'yyyymmdd'),TO_DATE(SUBSTR(A.STAFF_ID_NO ,7,8)  ,'yyyymmdd')    ) /12 ) >60 )
 AND AA.CUST_ID_NO = A.CUST_ID_NO AND AA.STAFF_ID_NO = A.STAFF_ID_NO 
 );
COMMIT;

DELETE/*+PARALLEL(4)*/ FROM PBOCD_JS_202_WQYBJY A
WHERE A.CJRQ = IS_DATE
AND A.STAFF_ID_TYPE IN ( 'B01','B08') 
AND (TRUNC(MONTHS_BETWEEN (TO_DATE(IS_DATE,'yyyymmdd'),TO_DATE(SUBSTR(A.STAFF_ID_NO ,7,8)  ,'yyyymmdd')) /12 ) <= 18 );
COMMIT;

--
MERGE INTO PBOCD_JS_202_WQYBJY AA
USING(
      SELECT /*+PARALLEL(4)*/T.CUST_NAM,T.SIGN_ORG_NUM,T1.JRJGBM ,
             ROW_NUMBER() OVER(PARTITION BY T.CUST_NAM ORDER BY T.SIGN_DATE DESC) RN
      FROM JS_202_WQYBJY_TMP4 T
      LEFT JOIN SYS_OFFICE T1
      ON T.SIGN_ORG_NUM = T1.ID
      
) T ON (AA.OPPO_ACCT_NAM = T.CUST_NAM AND AA.CJRQ = IS_DATE AND RN = 1)
WHEN MATCHED THEN UPDATE SET AA.ORG_NUM = T.SIGN_ORG_NUM,AA.NBJGH = T.SIGN_ORG_NUM ,AA.ORG_CODE = T.JRJGBM
  WHERE AA.CJRQ = IS_DATE
  AND AA.ORG_NUM = '009801';
COMMIT;

-------------------------------------------------------------------------------------------  
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

 OI_RETCODE := 0; --设置异常状态为0 成功状态
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
    SP_PBOCD_LOG(VS_PROCEDURE_NAME, 'ERROR', VI_ERRORCODE, VS_TEXT, IS_DATE);
 END;
/
