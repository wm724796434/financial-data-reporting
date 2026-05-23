CREATE OR REPLACE PROCEDURE BSP_SP_JS_201_HDACLKJDK_HIS(IS_DATE        IN VARCHAR2,
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
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT           VARCHAR2(10) DEFAULT NULL; --字符型  过程描述
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
BEGIN
  VS_TEXT := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');

  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'BSP_SP_JS_201_HDACLKJDK';

  --开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------
  --新建/清理分区
  SP_PBOCD_PARTITIONS(IS_DATE, 'PBOCD_JS_201_HDACLKJDK', OI_RETCODE);

delete from pbocd_datacore.L_PUBL_ORG_BRA_TMP;
INSERT INTO pbocd_datacore.L_PUBL_ORG_BRA_TMP
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
   commit;

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
            --T01_高新技术企业汇总
            SELECT 'T01' AS FIELD_TYPE, --字段类别
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
            
              FROM SMTMODS.L_ACCT_LOAN T --贷款借据信息表
             INNER JOIN SMTMODS.L_CUST_C A --对公客户信息表
                ON A.DATA_DATE = T.DATA_DATE
               AND A.CUST_ID = T.CUST_ID
               AND a.CUST_TYP <> '3' --不等于个体工商户
              LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B
                ON T.ACCT_NUM = B.BILL_NUM
               AND B.DATA_DATE = IS_DATE
              LEFT JOIN SMTMODS.L_PUBL_RATE TT --汇率表
                ON TT.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD') --汇率日期
               AND TT.BASIC_CCY = T.CURR_CD --基准币种
               AND TT.FORWARD_CCY = 'CNY' --折算币种
             WHERE T.DATA_DATE = IS_DATE --取数逻辑参考1104_S7001和一表通T_2_1
               AND T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
               AND T.ACCT_TYP NOT LIKE '90%' --不含委托贷款
               AND A.IF_HIGH_SALA_CORP = 'Y' --Y 是高新技术企业
               AND SUBSTR(T.ITEM_CD,1,4) NOT IN ('1306')
             GROUP BY CASE
                         WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                          SUBSTR(T.ORG_NUM, 1, 2)
                         ELSE
                          '99'
                       END
            
            --T02_科技型中小企业汇总
            UNION
            SELECT 'T02' AS FIELD_TYPE, --字段类别
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
              FROM SMTMODS.L_ACCT_LOAN T --贷款借据信息表
             INNER JOIN SMTMODS.L_CUST_C A --对公客户信息表
                ON A.DATA_DATE = T.DATA_DATE
               AND A.CUST_ID = T.CUST_ID
               AND a.CUST_TYP <> '3' --不等于个体工商户
              LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B
                ON T.ACCT_NUM = B.BILL_NUM
               AND B.DATA_DATE = IS_DATE
              LEFT JOIN SMTMODS.L_PUBL_RATE TT --汇率表
                ON TT.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD') --汇率日期
               AND TT.BASIC_CCY = T.CURR_CD --基准币种
               AND TT.FORWARD_CCY = 'CNY' --折算币种
             WHERE T.DATA_DATE = IS_DATE --取数逻辑参考1104_S7001和一表通T_2_1
               AND T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
               AND T.ACCT_TYP NOT LIKE '90%' --不含委托贷款
               AND A.CORP_SCALE IN ('S', 'M', 'T')
               AND A.TECH_CORP_TYPE IN ('C01', 'C02') --C01 科技型企业-科创企业  C02 科技型企业-非科创企业
               AND SUBSTR(T.ITEM_CD,1,4) NOT IN ('1306')
             GROUP BY CASE
                         WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                          SUBSTR(T.ORG_NUM, 1, 2)
                         ELSE
                          '99'
                       END
            
            --T03_“专精特新”中小企业汇总、T04_专精特新“小巨人”企业汇总、T05_国家技术创新示范企业汇总、T06_制造业单项冠军企业汇总
            UNION
            SELECT CASE
                      WHEN A.TECH_CORP_TYPE = 'E' THEN
                       'T03' --“专精特新”中小企业汇总
                      WHEN A.TECH_CORP_TYPE = 'F' THEN
                       'T04' --专精特新“小巨人”企业汇总
                      WHEN A.TECH_CORP_TYPE = 'H' THEN
                       'T05' --国家技术创新示范企业汇总
                      WHEN A.TECH_CORP_TYPE = 'J' THEN
                       'T06' --制造业单项冠军企业汇总
                    END AS FIELD_TYPE, --字段类别
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
              FROM SMTMODS.L_ACCT_LOAN T --贷款借据信息表
             INNER JOIN SMTMODS.L_CUST_C A --对公客户信息表
                ON A.DATA_DATE = T.DATA_DATE
               AND A.CUST_ID = T.CUST_ID
               AND a.CUST_TYP <> '3' --不等于个体工商户
              LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B
                ON T.ACCT_NUM = B.BILL_NUM
               AND B.DATA_DATE = IS_DATE
              LEFT JOIN SMTMODS.L_PUBL_RATE TT --汇率表
                ON TT.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD') --汇率日期
               AND TT.BASIC_CCY = T.CURR_CD --基准币种
               AND TT.FORWARD_CCY = 'CNY' --折算币种
             WHERE T.DATA_DATE = IS_DATE --取数逻辑参考1104_S7001和一表通T_2_1
               AND T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
               AND T.ACCT_TYP NOT LIKE '90%' --不含委托贷款
               AND A.TECH_CORP_TYPE IN ('E', 'F', 'H', 'J') --“专精特新”中小企业汇总、专精特新“小巨人”企业汇总、国家技术创新示范企业汇总、制造业单项冠军企业汇总
               AND SUBSTR(T.ITEM_CD,1,4) NOT IN ('1306')
             GROUP BY CASE
                         WHEN A.TECH_CORP_TYPE = 'E' THEN
                          'T03' --“专精特新”中小企业汇总
                         WHEN A.TECH_CORP_TYPE = 'F' THEN
                          'T04' --专精特新“小巨人”企业汇总
                         WHEN A.TECH_CORP_TYPE = 'H' THEN
                          'T05' --国家技术创新示范企业汇总
                         WHEN A.TECH_CORP_TYPE = 'J' THEN
                          'T06' --制造业单项冠军企业汇总
                       END,
                       CASE
                         WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                          SUBSTR(T.ORG_NUM, 1, 2)
                         ELSE
                          '99'
                       END
            
            --T07_科技型企业贷款汇总 T01-T06之和
            UNION
            SELECT 'T07' AS FIELD_TYPE, --字段类别
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
              FROM SMTMODS.L_ACCT_LOAN T --贷款借据信息表
             INNER JOIN SMTMODS.L_CUST_C A --对公客户信息表
                ON A.DATA_DATE = T.DATA_DATE
               AND A.CUST_ID = T.CUST_ID
               AND a.CUST_TYP <> '3' --不等于个体工商户
              LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B
                ON T.ACCT_NUM = B.BILL_NUM
               AND B.DATA_DATE = IS_DATE
              LEFT JOIN SMTMODS.L_PUBL_RATE TT --汇率表
                ON TT.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD') --汇率日期
               AND TT.BASIC_CCY = T.CURR_CD --基准币种
               AND TT.FORWARD_CCY = 'CNY' --折算币种
             WHERE T.DATA_DATE = IS_DATE --取数逻辑参考1104_S7001和一表通T_2_1
               AND T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
               AND T.ACCT_TYP NOT LIKE '90%' --不含委托贷款
               AND (/*A.IF_HIGH_SALA_CORP = 'Y' OR --Y 是高新技术企业
                   (A.CORP_SCALE IN ('S', 'M', 'T') AND
                   A.TECH_CORP_TYPE IN ('C01', 'C02')) OR --C01 科技型企业-科创企业  C02 科技型企业-非科创企业
                   A.TECH_CORP_TYPE = 'E' OR --“专精特新”中小企业标识
                   A.TECH_CORP_TYPE = 'F' OR --专精特新“小巨人”企业标识*/
                   A.TECH_CORP_TYPE = 'H' OR --国家技术创新示范企业标识
                   A.TECH_CORP_TYPE = 'J') --制造业单项冠军企业标识
                   AND SUBSTR(T.ITEM_CD,1,4) NOT IN ('1306')
             GROUP BY CASE
                         WHEN SUBSTR(T.ORG_NUM, 1, 2) BETWEEN '51' AND '60' THEN
                          SUBSTR(T.ORG_NUM, 1, 2)
                         ELSE
                          '99'
                       END
            
            --T08_高技术制造业汇总
            UNION
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
              FROM SMTMODS.L_ACCT_LOAN T --贷款借据信息表
             INNER JOIN SMTMODS.L_CUST_C A --对公客户信息表
                ON A.DATA_DATE = T.DATA_DATE
               AND A.CUST_ID = T.CUST_ID
               AND a.CUST_TYP <> '3' --不等于个体工商户
              LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B
                ON T.ACCT_NUM = B.BILL_NUM
               AND B.DATA_DATE = IS_DATE
              LEFT JOIN SMTMODS.PUB_KJDK M1
                ON SUBSTR(M1.HYDL, 1, 3) = 'HTP'
               AND T.LOAN_PURPOSE_CD = M1.CODE
              LEFT JOIN SMTMODS.L_PUBL_RATE TT --汇率表
                ON TT.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD') --汇率日期
               AND TT.BASIC_CCY = T.CURR_CD --基准币种
               AND TT.FORWARD_CCY = 'CNY' --折算币种
             WHERE T.DATA_DATE = IS_DATE --取数逻辑参考1104_S7001和一表通T_2_1
             AND SUBSTR(T.ITEM_CD,1,4) NOT IN ('1306')
               AND T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               /*AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
               AND T.ACCT_TYP NOT LIKE '90%' --不含委托贷款*/
               --AND SUBSTR(M1.HYDL, 1, 3) = 'HTP' --HTP-高技术制造业
               AND (--完全复制S72逻辑 312-403行
                 t.ITEM_CD not like '130102%' --以摊余成本计量的转贴现
                 and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现
                 and t.loan_purpose_cd in ('C2710',
                                           'C2720',
                                           'C2730',
                                           'C2740',
                                           'C2750',
                                           'C2761',
                                           'C2762',
                                           'C2770',
                                           'C2780',
                                           'C3741',
                                           'C3742',
                                           'C3743',
                                           'C3744',
                                           'C3749',
                                           'C4343',
                                           'C3562',
                                           'C3563',
                                           'C3569',
                                           'C3832',
                                           'C3833',
                                           'C3841',
                                           'C3921',
                                           'C3922',
                                           'C3940',
                                           'C3931',
                                           'C3932',
                                           'C3933',
                                           'C3934',
                                           'C3939',
                                           'C3951',
                                           'C3952',
                                           'C3953',
                                           'C3971',
                                           'C3972',
                                           'C3973',
                                           'C3974',
                                           'C3975',
                                           'C3976',
                                           'C3979',
                                           'C3981',
                                           'C3982',
                                           'C3983',
                                           'C3984',
                                           'C3985',
                                           'C3989',
                                           'C3961',
                                           'C3962',
                                           'C3963',
                                           'C3969',
                                           'C3990',
                                           'C3911',
                                           'C3912',
                                           'C3913',
                                           'C3914',
                                           'C3915',
                                           'C3919',
                                           'C3474',
                                           'C3475',
                                           'C3581',
                                           'C3582',
                                           'C3583',
                                           'C3584',
                                           'C3585',
                                           'C3586',
                                           'C3589',
                                           'C4011',
                                           'C4012',
                                           'C4013',
                                           'C4014',
                                           'C4015',
                                           'C4016',
                                           'C4019',
                                           'C4021',
                                           'C4022',
                                           'C4023',
                                           'C4024',
                                           'C4025',
                                           'C4026',
                                           'C4027',
                                           'C4028',
                                           'C4029',
                                           'C4040',
                                           'C4090',
                                           'C2664',
                                           'C2665')
                 AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
                 AND T.FUND_USE_LOC_CD = 'I'
                 AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
                 AND t.ACCT_TYP NOT LIKE '90%'
                 and t.CANCEL_FLG <> 'Y'
       
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
              FROM SMTMODS.L_ACCT_LOAN T --贷款借据信息表
             INNER JOIN SMTMODS.L_CUST_C A --对公客户信息表
                ON A.DATA_DATE = T.DATA_DATE
               AND A.CUST_ID = T.CUST_ID
               AND a.CUST_TYP <> '3' --不等于个体工商户
              LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B
                ON T.ACCT_NUM = B.BILL_NUM
               AND B.DATA_DATE = IS_DATE
              LEFT JOIN SMTMODS.PUB_KJDK M2
                ON SUBSTR(M2.HYDL, 1, 3) = 'HTS'
               AND T.LOAN_PURPOSE_CD = M2.CODE
              LEFT JOIN SMTMODS.L_PUBL_RATE TT --汇率表
                ON TT.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD') --汇率日期
               AND TT.BASIC_CCY = T.CURR_CD --基准币种
               AND TT.FORWARD_CCY = 'CNY' --折算币种
             WHERE T.DATA_DATE = IS_DATE --取数逻辑参考1104_S7001和一表通T_2_1
               AND T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
               AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
               AND T.ACCT_TYP NOT LIKE '90%' --不含委托贷款
               AND SUBSTR(M2.HYDL, 1, 3) = 'HTS' --HTS-高技术服务业
               AND SUBSTR(T.ITEM_CD,1,4) NOT IN ('1306')
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
              FROM SMTMODS.L_ACCT_LOAN T --贷款借据信息表
             INNER JOIN SMTMODS.L_CUST_C A --对公客户信息表
                ON A.DATA_DATE = T.DATA_DATE
               AND A.CUST_ID = T.CUST_ID
               AND a.CUST_TYP <> '3' --不等于个体工商户
              LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B
                ON T.ACCT_NUM = B.BILL_NUM
               AND B.DATA_DATE = IS_DATE
              LEFT JOIN SMTMODS.PUB_KJDK M3
                ON SUBSTR(M3.HYDL, 1, 2) = 'PA'
               AND T.LOAN_PURPOSE_CD = M3.CODE
              LEFT JOIN SMTMODS.L_PUBL_RATE TT --汇率表
                ON TT.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD') --汇率日期
               AND TT.BASIC_CCY = T.CURR_CD --基准币种
               AND TT.FORWARD_CCY = 'CNY' --折算币种
             WHERE T.DATA_DATE = IS_DATE
               AND T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               /*AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
               AND T.ACCT_TYP NOT LIKE '90%' --不含委托贷款*/
               --AND SUBSTR(M3.HYDL, 1, 2) = 'PA' --PA-知识产权（专利）密集型产业
               /*PA-知识产权（专利）密集型产业*/
               AND SUBSTR(T.ITEM_CD,1,4) NOT IN ('1306')
       AND(--完全复制G0107逻辑 1941-1946行
         (T.FUND_USE_LOC_CD = 'I'
         AND T.ACCT_TYP NOT LIKE '0301%'
         AND T.ACCT_TYP NOT LIKE '90%'
         AND T.ACCT_STS <> '3'
         AND T.CANCEL_FLG = 'N'
         AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
         AND LENGTHB(T.ACCT_NUM) < 36
         AND T.ACCT_TYP NOT LIKE '0301%' --SHIWENBO BY 20170316-12901 单独取直贴
         --AND T.ORG_NUM NOT LIKE '5100%'
         AND T.LOAN_PURPOSE_CD IN
             (SELECT CODE FROM SMTMODS.PUB_KJDK WHERE FLAG = '6')
          )
         OR
         (T.FUND_USE_LOC_CD = 'I'
         AND T.CANCEL_FLG = 'N'
         AND LENGTHB(T.ACCT_NUM) < 36
         AND (T.ITEM_CD LIKE '130101%' OR T.ITEM_CD LIKE  '130104%') -- AND ITEM_CD LIKE '130101%'AND ITEM_CD LIKE  '130104%' -- 20221029 UPDATE BY WANGKUI
         AND T.LOAN_PURPOSE_CD IN
             (SELECT CODE FROM SMTMODS.PUB_KJDK WHERE FLAG = '6')
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
              FROM SMTMODS.L_ACCT_LOAN T --贷款借据信息表
             INNER JOIN SMTMODS.L_CUST_C A --对公客户信息表
                ON A.DATA_DATE = T.DATA_DATE
               AND A.CUST_ID = T.CUST_ID
               AND a.CUST_TYP <> '3' --不等于个体工商户
              LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B
                ON T.ACCT_NUM = B.BILL_NUM
               AND B.DATA_DATE = IS_DATE
              LEFT JOIN SMTMODS.L_PUBL_RATE TT --汇率表
                ON TT.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD') --汇率日期
               AND TT.BASIC_CCY = T.CURR_CD --基准币种
               AND TT.FORWARD_CCY = 'CNY' --折算币种
             WHERE T.DATA_DATE = IS_DATE --取数逻辑参考1104_S7001和一表通T_2_1
               AND T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND SUBSTR(T.ITEM_CD,1,4) NOT IN ('1306')
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
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
              FROM SMTMODS.L_ACCT_LOAN T --贷款借据信息表
             INNER JOIN SMTMODS.L_CUST_C A --对公客户信息表
                ON A.DATA_DATE = T.DATA_DATE
               AND A.CUST_ID = T.CUST_ID
               AND a.CUST_TYP <> '3' --不等于个体工商户
              LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B
                ON T.ACCT_NUM = B.BILL_NUM
               AND B.DATA_DATE = IS_DATE
              LEFT JOIN SMTMODS.PUB_KJDK M1
                ON SUBSTR(M1.HYDL, 1, 3) = 'HTP'
               AND T.LOAN_PURPOSE_CD = M1.CODE
              LEFT JOIN SMTMODS.PUB_KJDK M2
                ON SUBSTR(M2.HYDL, 1, 3) = 'HTS'
               AND T.LOAN_PURPOSE_CD = M2.CODE
              LEFT JOIN SMTMODS.PUB_KJDK M3
                ON SUBSTR(M3.HYDL, 1, 2) = 'PA'
               AND T.LOAN_PURPOSE_CD = M3.CODE
              LEFT JOIN SMTMODS.L_PUBL_RATE TT --汇率表
                ON TT.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD') --汇率日期
               AND TT.BASIC_CCY = T.CURR_CD --基准币种
               AND TT.FORWARD_CCY = 'CNY' --折算币种
             WHERE T.DATA_DATE = IS_DATE --取数逻辑参考1104_S7001和一表通T_2_1
             AND SUBSTR(T.ITEM_CD,1,4) NOT IN ('1306')
             AND T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND 
               (
               (T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
               AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
               AND T.ACCT_TYP NOT LIKE '90%' --不含委托贷款
               AND --SUBSTR(M1.HYDL, 1, 3) = 'HTP' OR
                   SUBSTR(M2.HYDL, 1, 3) = 'HTS' /*OR
                   SUBSTR(M3.HYDL, 1, 2) = 'PA'*/ --HTP-高技术制造业 HTS-高技术服务业 PA-知识产权（专利）密集型产业
        )
        /*PA-知识产权（专利）密集型产业*/
       OR(--完全复制G0107逻辑 1941-1946行
         (T.FUND_USE_LOC_CD = 'I'
         AND T.ACCT_TYP NOT LIKE '0301%'
         AND T.ACCT_TYP NOT LIKE '90%'
         AND T.ACCT_STS <> '3'
         AND T.CANCEL_FLG = 'N'
         AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
         AND LENGTHB(T.ACCT_NUM) < 36
         AND T.ACCT_TYP NOT LIKE '0301%' --SHIWENBO BY 20170316-12901 单独取直贴
         --AND T.ORG_NUM NOT LIKE '5100%'
         AND T.LOAN_PURPOSE_CD IN
             (SELECT CODE FROM SMTMODS.PUB_KJDK WHERE FLAG = '6')
          )
         OR
         (T.FUND_USE_LOC_CD = 'I'
         AND T.CANCEL_FLG = 'N'
         AND LENGTHB(T.ACCT_NUM) < 36
         AND (T.ITEM_CD LIKE '130101%' OR T.ITEM_CD LIKE  '130104%') -- AND ITEM_CD LIKE '130101%'AND ITEM_CD LIKE  '130104%' -- 20221029 UPDATE BY WANGKUI
         AND T.LOAN_PURPOSE_CD IN
             (SELECT CODE FROM SMTMODS.PUB_KJDK WHERE FLAG = '6')
          )
        )
        
        
         /*HTP-高技术制造业*/         
        OR (--完全复制S72逻辑 312-403行
                 t.ITEM_CD not like '130102%' --以摊余成本计量的转贴现
                 and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现
                 and t.loan_purpose_cd in ('C2710',
                                           'C2720',
                                           'C2730',
                                           'C2740',
                                           'C2750',
                                           'C2761',
                                           'C2762',
                                           'C2770',
                                           'C2780',
                                           'C3741',
                                           'C3742',
                                           'C3743',
                                           'C3744',
                                           'C3749',
                                           'C4343',
                                           'C3562',
                                           'C3563',
                                           'C3569',
                                           'C3832',
                                           'C3833',
                                           'C3841',
                                           'C3921',
                                           'C3922',
                                           'C3940',
                                           'C3931',
                                           'C3932',
                                           'C3933',
                                           'C3934',
                                           'C3939',
                                           'C3951',
                                           'C3952',
                                           'C3953',
                                           'C3971',
                                           'C3972',
                                           'C3973',
                                           'C3974',
                                           'C3975',
                                           'C3976',
                                           'C3979',
                                           'C3981',
                                           'C3982',
                                           'C3983',
                                           'C3984',
                                           'C3985',
                                           'C3989',
                                           'C3961',
                                           'C3962',
                                           'C3963',
                                           'C3969',
                                           'C3990',
                                           'C3911',
                                           'C3912',
                                           'C3913',
                                           'C3914',
                                           'C3915',
                                           'C3919',
                                           'C3474',
                                           'C3475',
                                           'C3581',
                                           'C3582',
                                           'C3583',
                                           'C3584',
                                           'C3585',
                                           'C3586',
                                           'C3589',
                                           'C4011',
                                           'C4012',
                                           'C4013',
                                           'C4014',
                                           'C4015',
                                           'C4016',
                                           'C4019',
                                           'C4021',
                                           'C4022',
                                           'C4023',
                                           'C4024',
                                           'C4025',
                                           'C4026',
                                           'C4027',
                                           'C4028',
                                           'C4029',
                                           'C4040',
                                           'C4090',
                                           'C2664',
                                           'C2665')
                 AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
                 AND T.FUND_USE_LOC_CD = 'I'
                 AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
                 AND t.ACCT_TYP NOT LIKE '90%'
                 and t.CANCEL_FLG <> 'Y'
       
       )
         
       
       /*战略性新兴产业*/
        OR 
        
        (T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
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
            SELECT *
              FROM PBOCD_DATACORE.KJDK_TMP01)
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
     DISCOUNT_INTEREST --贴现利息
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
        T.ACCT_NUM
       ELSE
        '0'
     END, --票据编号
     CASE
       WHEN T.LOAN_ACCT_BAL > 0 --贷款余额大于0
       AND T.ACCT_STS <> '3'
       AND T.CANCEL_FLG <> 'Y'
       AND T.ACCT_TYP NOT LIKE '90%' --不含委托贷款
       AND A.TECH_CORP_TYPE = 'H' THEN
        '1'
       ELSE
        '0'
     END, --是否国家技术创新示范企业贷款
     CASE
       WHEN T.LOAN_ACCT_BAL > 0 --贷款余额大于0
       AND T.ACCT_STS <> '3'
       AND T.CANCEL_FLG <> 'Y'
       AND T.ACCT_TYP NOT LIKE '90%' --不含委托贷款
       AND A.TECH_CORP_TYPE = 'J' THEN
        '1'
       ELSE
        '0'
     END, --是否制造业单项冠军企业贷款
     CASE
       WHEN (--完全复制S72逻辑 312-403行
                 t.ITEM_CD not like '130102%' --以摊余成本计量的转贴现
                 and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现
                 and t.loan_purpose_cd in ('C2710',
                                           'C2720',
                                           'C2730',
                                           'C2740',
                                           'C2750',
                                           'C2761',
                                           'C2762',
                                           'C2770',
                                           'C2780',
                                           'C3741',
                                           'C3742',
                                           'C3743',
                                           'C3744',
                                           'C3749',
                                           'C4343',
                                           'C3562',
                                           'C3563',
                                           'C3569',
                                           'C3832',
                                           'C3833',
                                           'C3841',
                                           'C3921',
                                           'C3922',
                                           'C3940',
                                           'C3931',
                                           'C3932',
                                           'C3933',
                                           'C3934',
                                           'C3939',
                                           'C3951',
                                           'C3952',
                                           'C3953',
                                           'C3971',
                                           'C3972',
                                           'C3973',
                                           'C3974',
                                           'C3975',
                                           'C3976',
                                           'C3979',
                                           'C3981',
                                           'C3982',
                                           'C3983',
                                           'C3984',
                                           'C3985',
                                           'C3989',
                                           'C3961',
                                           'C3962',
                                           'C3963',
                                           'C3969',
                                           'C3990',
                                           'C3911',
                                           'C3912',
                                           'C3913',
                                           'C3914',
                                           'C3915',
                                           'C3919',
                                           'C3474',
                                           'C3475',
                                           'C3581',
                                           'C3582',
                                           'C3583',
                                           'C3584',
                                           'C3585',
                                           'C3586',
                                           'C3589',
                                           'C4011',
                                           'C4012',
                                           'C4013',
                                           'C4014',
                                           'C4015',
                                           'C4016',
                                           'C4019',
                                           'C4021',
                                           'C4022',
                                           'C4023',
                                           'C4024',
                                           'C4025',
                                           'C4026',
                                           'C4027',
                                           'C4028',
                                           'C4029',
                                           'C4040',
                                           'C4090',
                                           'C2664',
                                           'C2665')
                 AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
                 AND T.FUND_USE_LOC_CD = 'I'
                 AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
                 AND t.ACCT_TYP NOT LIKE '90%'
                 and t.CANCEL_FLG <> 'Y'
       
       ) THEN
        '1'
       ELSE
        '0'
     END, --是否高技术制造业贷款
     CASE
       --WHEN SUBSTR(M1.HYDL, 1, 3) = 'HTP' THEN
       -- M1.HYDL
       when t.ITEM_CD not like '130102%' --以摊余成本计量的转贴现
            and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现
            AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
            AND T.FUND_USE_LOC_CD = 'I'
            AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
            AND t.ACCT_TYP NOT LIKE '90%'
            and t.CANCEL_FLG <> 'Y'
            AND T.loan_purpose_cd in ('C2710',
                                          'C2720',
                                          'C2730',
                                          'C2740',
                                          'C2750',
                                          'C2761',
                                          'C2762',
                                          'C2770',
                                          'C2780') then 'HTP01'--医药制造业
       when t.ITEM_CD not like '130102%' --以摊余成本计量的转贴现
            and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现
            AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
            AND T.FUND_USE_LOC_CD = 'I'
            AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
            AND t.ACCT_TYP NOT LIKE '90%'
            and t.CANCEL_FLG <> 'Y'
            AND T.loan_purpose_cd in
                    ('C3741', 'C3742', 'C3743', 'C3744', 'C3749', 'C4343') then 'HTP02'--2.航空、航天器及设备制造业                                   
       when t.ITEM_CD not like '130102%' --以摊余成本计量的转贴现
            and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现
            AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
            AND T.FUND_USE_LOC_CD = 'I'
            AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
            AND t.ACCT_TYP NOT LIKE '90%'
            and t.CANCEL_FLG <> 'Y'
            AND T.loan_purpose_cd in ('C3562',
                                          'C3563',
                                          'C3569',
                                          'C3832',
                                          'C3833',
                                          'C3841',
                                          'C3921',
                                          'C3922',
                                          'C3940',
                                          'C3931',
                                          'C3932',
                                          'C3933',
                                          'C3934',
                                          'C3939',
                                          'C3951',
                                          'C3952',
                                          'C3953',
                                          'C3971',
                                          'C3972',
                                          'C3973',
                                          'C3974',
                                          'C3975',
                                          'C3976',
                                          'C3979',
                                          'C3981',
                                          'C3982',
                                          'C3983',
                                          'C3984',
                                          'C3985',
                                          'C3989',
                                          'C3961',
                                          'C3962',
                                          'C3963',
                                          'C3969',
                                          'C3990') then 'HTP03'--3.电子及通信设备制造业
     when t.ITEM_CD not like '130102%' --以摊余成本计量的转贴现
            and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现
            AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
            AND T.FUND_USE_LOC_CD = 'I'
            AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
            AND t.ACCT_TYP NOT LIKE '90%'
            and t.CANCEL_FLG <> 'Y'
            AND T.loan_purpose_cd in ('C3911',
                                          'C3912',
                                          'C3913',
                                          'C3914',
                                          'C3915',
                                          'C3919',
                                          'C3474',
                                          'C3475') then 'HTP04'--4.计算机及办公设备制造业                                     
     when t.ITEM_CD not like '130102%' --以摊余成本计量的转贴现
            and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现
            AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
            AND T.FUND_USE_LOC_CD = 'I'
            AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
            AND t.ACCT_TYP NOT LIKE '90%'
            and t.CANCEL_FLG <> 'Y'
            AND T.loan_purpose_cd in ('C3581',
                                          'C3582',
                                          'C3583',
                                          'C3584',
                                          'C3585',
                                          'C3586',
                                          'C3589',
                                          'C4011',
                                          'C4012',
                                          'C4013',
                                          'C4014',
                                          'C4015',
                                          'C4016',
                                          'C4019',
                                          'C4021',
                                          'C4022',
                                          'C4023',
                                          'C4024',
                                          'C4025',
                                          'C4026',
                                          'C4027',
                                          'C4028',
                                          'C4029',
                                          'C4040',
                                          'C4090') then 'HTP05' --5.医疗仪器设备及仪器仪表制造业
     when t.ITEM_CD not like '130102%' --以摊余成本计量的转贴现
            and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现
            AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
            AND T.FUND_USE_LOC_CD = 'I'
            AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
            AND t.ACCT_TYP NOT LIKE '90%'
            and t.CANCEL_FLG <> 'Y'
            AND T.loan_purpose_cd in ('C2664', 'C2665') then 'HTP06'--6.信息化学品制造业                                     
     END, --高技术制造业贷款类型
     CASE
       WHEN T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
               AND T.ACCT_TYP NOT LIKE '90%'
               AND SUBSTR(M2.HYDL, 1, 3) = 'HTS' THEN
        '1'
       ELSE
        '0'
     END, --是否高技术服务业贷款
     CASE
       WHEN T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
               AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
               AND T.ACCT_TYP NOT LIKE '90%'
               AND SUBSTR(M2.HYDL, 1, 3) = 'HTS' THEN
        M2.HYDL
     END, --高技术服务业贷款类型
     CASE
       WHEN T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
               AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
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
     DECODE(NVL(T.INDUST_STG_TYPE, '#'),
            '1',
            'SE07',
            '2',
            'SE01',
            '3',
            'SE04',
            '4',
            'SE02',
            '5',
            'SE06',
            '6',
            'SE03',
            '7',
            'SE05',
            '8',
            'SE08',
            '9',
            'SE09') END, --战略性新兴产业贷款类型
     CASE
       WHEN /*PA-知识产权（专利）密集型产业*/
       (--完全复制G0107逻辑 1941-1946行
         (T.FUND_USE_LOC_CD = 'I'
         AND T.ACCT_TYP NOT LIKE '0301%'
         AND T.ACCT_TYP NOT LIKE '90%'
         AND T.ACCT_STS <> '3'
         AND T.CANCEL_FLG = 'N'
         AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
         AND LENGTHB(T.ACCT_NUM) < 36
         AND T.ACCT_TYP NOT LIKE '0301%' --SHIWENBO BY 20170316-12901 单独取直贴
         --AND T.ORG_NUM NOT LIKE '5100%'
         AND T.LOAN_PURPOSE_CD IN
             (SELECT CODE FROM SMTMODS.PUB_KJDK WHERE FLAG = '6')
          )
         OR
         (T.FUND_USE_LOC_CD = 'I'
         AND T.CANCEL_FLG = 'N'
         AND LENGTHB(T.ACCT_NUM) < 36
         AND (T.ITEM_CD LIKE '130101%' OR T.ITEM_CD LIKE  '130104%') -- AND ITEM_CD LIKE '130101%'AND ITEM_CD LIKE  '130104%' -- 20221029 UPDATE BY WANGKUI
         AND T.LOAN_PURPOSE_CD IN
             (SELECT CODE FROM SMTMODS.PUB_KJDK WHERE FLAG = '6')
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
         AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
         AND LENGTHB(T.ACCT_NUM) < 36
         AND T.ACCT_TYP NOT LIKE '0301%' --SHIWENBO BY 20170316-12901 单独取直贴
         --AND T.ORG_NUM NOT LIKE '5100%'
         AND T.LOAN_PURPOSE_CD IN
             (SELECT CODE FROM SMTMODS.PUB_KJDK WHERE FLAG = '6')
          )
         OR
         (T.FUND_USE_LOC_CD = 'I'
         AND T.CANCEL_FLG = 'N'
         AND LENGTHB(T.ACCT_NUM) < 36
         AND (T.ITEM_CD LIKE '130101%' OR T.ITEM_CD LIKE  '130104%') -- AND ITEM_CD LIKE '130101%'AND ITEM_CD LIKE  '130104%' -- 20221029 UPDATE BY WANGKUI
         AND T.LOAN_PURPOSE_CD IN
             (SELECT CODE FROM SMTMODS.PUB_KJDK WHERE FLAG = '6')
          )
        )
        AND SUBSTR(M3.HYDL, 1, 2) = 'PA' THEN
        M3.HYDL
     END, --知识产权(专利)密集型产业贷款类型
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
      FROM SMTMODS.L_ACCT_LOAN T --贷款借据信息表
     INNER JOIN SMTMODS.L_CUST_C A --对公客户信息表
        ON A.DATA_DATE = IS_DATE
       AND A.CUST_ID = T.CUST_ID
       AND A.CUST_TYP <> '3' --后面条件剔除个体工商户了
      LEFT JOIN SMTMODS.L_CUST_ALL A2 --对公客户信息表
        ON A2.DATA_DATE = IS_DATE
       AND A2.CUST_ID = T.CUST_ID
      LEFT JOIN SMTMODS.L_AGRE_BILL_INFO B
        ON T.ACCT_NUM = B.BILL_NUM
       AND B.DATA_DATE = IS_DATE
      LEFT JOIN SMTMODS.L_PUBL_RATE U --汇率表
        ON U.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD')
       AND U.BASIC_CCY = T.CURR_CD --基准币种
       AND U.FORWARD_CCY = 'CNY' --折算币种
      LEFT JOIN SMTMODS.PUB_KJDK M1
        ON SUBSTR(M1.HYDL, 1, 3) = 'HTP'
       AND T.LOAN_PURPOSE_CD = M1.CODE
      LEFT JOIN SMTMODS.PUB_KJDK M2
        ON SUBSTR(M2.HYDL, 1, 3) = 'HTS'
       AND T.LOAN_PURPOSE_CD = M2.CODE
      LEFT JOIN SMTMODS.PUB_KJDK M3
        ON SUBSTR(M3.HYDL, 1, 2) = 'PA'
       AND T.LOAN_PURPOSE_CD = M3.CODE
      LEFT JOIN L_PUBL_ORG_BRA_TMP OB --金数机构表
        ON OB.ORG_NUM = T.ORG_NUM
       AND OB.DATA_DATE = IS_DATE
     WHERE T.DATA_DATE = IS_DATE
     AND T.LOAN_ACCT_BAL > 0
     AND SUBSTR(T.ITEM_CD,1,4) NOT IN ('1306')
       AND 
               (
               
        (T.LOAN_ACCT_BAL > 0 --贷款余额大于0
       AND T.ACCT_STS <> '3'
       AND T.CANCEL_FLG <> 'Y'
       AND T.ACCT_TYP NOT LIKE '90%' --不含委托贷款
       AND A.TECH_CORP_TYPE IN ('H', 'J')
               )     
               
        OR(T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
               AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
               AND T.ACCT_TYP NOT LIKE '90%' --不含委托贷款
               AND --SUBSTR(M1.HYDL, 1, 3) = 'HTP' OR
                   SUBSTR(M2.HYDL, 1, 3) = 'HTS' /*OR
                   SUBSTR(M3.HYDL, 1, 2) = 'PA'*/ --HTP-高技术制造业 HTS-高技术服务业 PA-知识产权（专利）密集型产业
        )
        /*PA-知识产权（专利）密集型产业*/
       OR(--完全复制G0107逻辑 1941-1946行
         (T.FUND_USE_LOC_CD = 'I'
         AND T.ACCT_TYP NOT LIKE '0301%'
         AND T.ACCT_TYP NOT LIKE '90%'
         AND T.ACCT_STS <> '3'
         AND T.CANCEL_FLG = 'N'
         AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
         AND LENGTHB(T.ACCT_NUM) < 36
         AND T.ACCT_TYP NOT LIKE '0301%' --SHIWENBO BY 20170316-12901 单独取直贴
         --AND T.ORG_NUM NOT LIKE '5100%'
         AND T.LOAN_PURPOSE_CD IN
             (SELECT CODE FROM SMTMODS.PUB_KJDK WHERE FLAG = '6')
          )
         OR
         (T.FUND_USE_LOC_CD = 'I'
         AND T.CANCEL_FLG = 'N'
         AND LENGTHB(T.ACCT_NUM) < 36
         AND (T.ITEM_CD LIKE '130101%' OR T.ITEM_CD LIKE  '130104%') -- AND ITEM_CD LIKE '130101%'AND ITEM_CD LIKE  '130104%' -- 20221029 UPDATE BY WANGKUI
         AND T.LOAN_PURPOSE_CD IN
             (SELECT CODE FROM SMTMODS.PUB_KJDK WHERE FLAG = '6')
          )
        )
        
        
         /*HTP-高技术制造业*/         
        OR (--完全复制S72逻辑 312-403行
                 t.ITEM_CD not like '130102%' --以摊余成本计量的转贴现
                 and t.ITEM_CD not like '130105%' --以公允价值计量变动计入权益的转贴现
                 and t.loan_purpose_cd in ('C2710',
                                           'C2720',
                                           'C2730',
                                           'C2740',
                                           'C2750',
                                           'C2761',
                                           'C2762',
                                           'C2770',
                                           'C2780',
                                           'C3741',
                                           'C3742',
                                           'C3743',
                                           'C3744',
                                           'C3749',
                                           'C4343',
                                           'C3562',
                                           'C3563',
                                           'C3569',
                                           'C3832',
                                           'C3833',
                                           'C3841',
                                           'C3921',
                                           'C3922',
                                           'C3940',
                                           'C3931',
                                           'C3932',
                                           'C3933',
                                           'C3934',
                                           'C3939',
                                           'C3951',
                                           'C3952',
                                           'C3953',
                                           'C3971',
                                           'C3972',
                                           'C3973',
                                           'C3974',
                                           'C3975',
                                           'C3976',
                                           'C3979',
                                           'C3981',
                                           'C3982',
                                           'C3983',
                                           'C3984',
                                           'C3985',
                                           'C3989',
                                           'C3961',
                                           'C3962',
                                           'C3963',
                                           'C3969',
                                           'C3990',
                                           'C3911',
                                           'C3912',
                                           'C3913',
                                           'C3914',
                                           'C3915',
                                           'C3919',
                                           'C3474',
                                           'C3475',
                                           'C3581',
                                           'C3582',
                                           'C3583',
                                           'C3584',
                                           'C3585',
                                           'C3586',
                                           'C3589',
                                           'C4011',
                                           'C4012',
                                           'C4013',
                                           'C4014',
                                           'C4015',
                                           'C4016',
                                           'C4019',
                                           'C4021',
                                           'C4022',
                                           'C4023',
                                           'C4024',
                                           'C4025',
                                           'C4026',
                                           'C4027',
                                           'C4028',
                                           'C4029',
                                           'C4040',
                                           'C4090',
                                           'C2664',
                                           'C2665')
                 AND t.ACCT_TYP NOT IN ('C01', 'D01', 'E01', 'E02')
                 AND T.FUND_USE_LOC_CD = 'I'
                 AND (T.ACCT_TYP NOT LIKE '01%' OR T.ACCT_TYP LIKE '0102%')
                 AND t.ACCT_TYP NOT LIKE '90%'
                 and t.CANCEL_FLG <> 'Y'
       
       )
         
       
       /*战略性新兴产业*/
        OR 
        
        (T.LOAN_ACCT_BAL > 0 --贷款余额大于0
               AND T.ACCT_STS <> '3'
               AND T.CANCEL_FLG <> 'Y'
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

  --以下类别暂缓报送
  UPDATE PBOCD_DATACORE.PBOCD_JS_201_HDACLKJDK
     SET BALANCE_SUM = NULL, INT_RATE_WA = NULL, GET_LOAN_NUM = NULL
   WHERE CJRQ = IS_DATE
     AND FIELD_TYPE IN ('T01', 'T02', 'T03', 'T04', 'T07');
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

