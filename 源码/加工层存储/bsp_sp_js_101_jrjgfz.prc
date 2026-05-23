CREATE OR REPLACE PROCEDURE BSP_SP_JS_101_JRJGFZ(IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名
  --    SP_JS_101_JRJGFZ
  -- 用途:生成接口表 JS_101_JRJGFZ  金融机构（分支机构）基础信息
  -- 参数
  --    IS_DATE 输入变量，传入跑批日期
  --    OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常
  --    CAEATE BY USER AT 20230427
  --    需求编号：JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_四阶段 上线日期：2025-09-18，修改人：周立鹏，提出人：李楠   修改原因：剔除取上期/配置表
  --    需求编号：JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段 上线日期：2025-12-30，修改人：周立鹏，提出人：李楠   修改原因：剔除特殊处理
  --    需求编号：JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段 上线日期：2026-01-27，修改人：周立鹏，提出人：李楠   修改原因：剔除特殊处理
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE NUMBER DEFAULT 0; --数值型  异常代码
  VS_TEXT      VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_LAST_TEXT      VARCHAR2(500) DEFAULT NULL; --字符型  过程描述

  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --字符型  存储过程调用用户
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --字符型  存储过程名称
  VS_STEP           VARCHAR2(10); --存储过程执行步骤标志
BEGIN
  VS_TEXT := TO_CHAR(TO_DATE(IS_DATE, 'yyyymmdd'), 'yyyy-mm-dd');
  VS_LAST_TEXT := TO_CHAR(ADD_MONTHS(TO_DATE(IS_DATE, 'yyyymmdd'),-3), 'yyyymmdd');


  -- 记录日志使用
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_101_JRJGFZ';

  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------



  IF SUBSTR(IS_DATE,5,2) IN ('03','06','09','12') THEN

  DELETE FROM PBOCD_JS_101_JRJGFZ WHERE CJRQ = IS_DATE ;
  COMMIT;

INSERT INTO PBOCD_JS_101_JRJGFZ
  SELECT /*+PARALLEL(4)*/
         VS_TEXT, --数据日期
         A.ORG_NAM, --金融机构名称
         --NVL(SQ1.ORG_CODE, A.ID_NO), --金融机构代码--不优先取上期，有问题找L层更正
         NVL(A.ID_NO, B.ID_NO), --金融机构代码
         
         --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 取上级，此处直接取了分行
         --NVL(A.ACCOUNTBANK, SQ1.ORG_ID), --金融机构编码
         NVL(A.ACCOUNTBANK, B.ACCOUNTBANK), --金融机构编码
         
         A.ORG_NUM, --内部机构号
         CASE
           WHEN A.ORG_TYP = '0' THEN
            '01' --总行
           WHEN A.ORG_TYP = '2' THEN
            '02' --分行
           WHEN A.ORG_TYP IN ('3', --针对0098开头的机构，其他ORG_TYP='3'的数据没报
                              '1', --目前只涉及磐石
                              '4' --支行没报，网点定义成支行
                              ) THEN
            '03' --支行
           ELSE
            '99' --其他
         END, --机构级别
         B.ORG_NAM, --直属上级管理机构名称
         
         --[2025-12-30] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_一阶段][李楠] 取上级，此处不用取上级了，分行应该非空
         --NVL(B.ACCOUNTBANK, SQ2.UPPER_MANAGE_ORG_ID), --直属上级管理机构金融机构编码
         B.ACCOUNTBANK, --直属上级管理机构金融机构编码
         
         B.ORG_NUM, --直属上级管理机构内部机构号
         A.ORG_ADD, --注册地址
         --NVL(SQ1.REG_REGION_CODE, A.REGION_CD), --地区代码--不优先取上期，有问题找L层更正
         A.REGION_CD, --地区代码
         
         --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 剔除取上期/配置表
         --NVL(TO_CHAR(A.BEGAN_TIME, 'yyyy-mm-dd'), SQ1.BEGAN_TIME), --成立时间
         TO_CHAR(A.BEGAN_TIME, 'yyyy-mm-dd'), --成立时间
         
         /*CASE
           WHEN A.BUSI_STATE = '1' THEN
            '01' --正常运营
           WHEN A.BUSI_STATE = '2' THEN
            '02' --停业（歇业）
           WHEN A.BUSI_STATE = '4' THEN
            '03' --筹建
           WHEN A.BUSI_STATE = '5' THEN
            '04' --当年关闭
           WHEN A.BUSI_STATE = '6' THEN
            '05' --当年破产
           WHEN A.BUSI_STATE = '7' THEN
            '06' --当年注销
           WHEN A.BUSI_STATE = '8' THEN
            '07' --当年吊销
           ELSE
            '99' --其他
         END, --营业状态 */
         NVL(A.BUSI_STATE,'99'), --营业状态 20231214JLF
         
         --[2025-09-18] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_四阶段][李楠] 剔除取上期/配置表
         /*NVL(SQ1.FIN_LICENSE_NUM, A.FIN_LIN_NUM), --许可证号
         NVL(SQ1.ORG_PAY_NUM, A.BANK_CD), --支付行号*/
         A.FIN_LIN_NUM, --许可证号
         
         --[2026-01-27] [周立鹏] [JLBA202509240002_关于金融基础数据系统取数逻辑改造及治理常态化建设的需求_二阶段][李楠] 取不到取上级
         --A.BANK_CD, --支付行号
         NVL(A.BANK_CD,B.BANK_CD), --支付行号
         
         SYS_GUID() AS REPORT_ID, --REPORT_ID
         IS_DATE AS CJRQ, --采集日期
         A.ORG_NUM AS NBJGH, --内部机构号
         '99' AS BIZ_LINE_ID, --业务条线
         '' AS VERIFY_STATUS, --校验状态
         '' AS BSCJRQ, --报送采集日期

         CASE
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
            '600000'----20230620多法人新增
           ELSE
            '990000'
         END AS FRNBJGH --法人内部机构号
    FROM SMTMODS.L_PUBL_ORG_BRA A
    LEFT JOIN SMTMODS.L_PUBL_ORG_BRA B
      ON SUBSTR(A.UP_ORG_NUM, 1, 2) || '0000' = B.ORG_NUM
     AND B.DATA_DATE = IS_DATE
    LEFT JOIN PBOCD_JS_101_JRJGFZ_SQ SQ1
      ON A.ORG_NUM = SQ1.ORG_NUM
     AND SQ1.CJRQ = VS_LAST_TEXT
    /*LEFT JOIN (SELECT DISTINCT UPPER_MANAGE_ORG_NUM, UPPER_MANAGE_ORG_ID
                 FROM PBOCD_JS_101_JRJGFZ_SQ
                WHERE CJRQ = VS_LAST_TEXT) SQ2
      ON B.ORG_NUM = SQ2.UPPER_MANAGE_ORG_NUM*/
   WHERE A.DATA_DATE = IS_DATE
     AND A.BUSI_STATE  = '01' --20231214 JLF
     AND EXISTS
   (SELECT * FROM SYS_OFFICE C WHERE A.ORG_NUM = C.ID)
     AND (SUBSTR(A.ORG_NUM, 5, 2) <> '00' OR
         SUBSTR(A.ORG_NUM, 3, 4) = '0000')
     AND A.ORG_NUM NOT IN ('000000',--总行
                           '510000',
                           '520000',
                           '530000',
                           '540000',
                           '550000',
                           '560000',
                           '570000',
                           '580000',
                           '590000',
                           '600000',----20230620多法人新增
                           '990000',

                           '019801',--各分行清算中心
                           '029801',
                           '039801',
                           '049801',
                           '059801',
                           '099801',
                           '109801',
                           '119801',

                           '029804',--吉林资产中心

                           '012102',--村镇银行
                           '012103',
                           '012104',
                           '012105',
                           '012106',
                           '012107',
                           '012108',
                           --[2025-09-18] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_四阶段][李楠] 下面移过来的
                           '120000', '120101',--小企12开头的机构废弃改成009826了
                           '012502'--万达广场支行改成中韩国际合作示范区支行了
                           )
     /*--[2025-09-18] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_四阶段][李楠] 只报送有业务的机构
     AND ( EXISTS (SELECT 1 FROM PBOCD_JS_102_FTYKHX    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --单位客户信息
        OR EXISTS (SELECT 1 FROM PBOCD_JS_102_GRKHXX    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --个人客户信息
        OR EXISTS (SELECT 1 FROM PBOCD_JS_102_TYKHXX    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --同业客户信息
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_CLDWDK    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量单位贷款
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_CLGRDK    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量个人贷款
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_CLTYJD    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量同业借贷
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_CLWTDK    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量委托贷款
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_CLZXYP    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量专项一批
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_CLZXEP    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量专项二批
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_DBHTXX    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --担保合同信息
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_DBWXX     T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --担保物信息
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_DWDKFS    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --单位贷款发生
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_GRDKFS    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --个人贷款发生
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_HDACLKJDK T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量科技贷款
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_HDAKJDKFS T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --科技贷款发生
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_TYJDFS    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --同业借贷发生
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_WTDKFS    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --委托贷款发生
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_ZHJZFS    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --置换旧债发生
        OR EXISTS (SELECT 1 FROM PBOCD_JS_202_CLGRCK    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量个人存款
        OR EXISTS (SELECT 1 FROM PBOCD_JS_202_CLTYCK    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量同业存款
        OR EXISTS (SELECT 1 FROM PBOCD_JS_202_DWCKFS    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --单位存款发生
        OR EXISTS (SELECT 1 FROM PBOCD_JS_202_FTYDWC    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --非同业单位存款
        OR EXISTS (SELECT 1 FROM PBOCD_JS_202_HDACLHLCK T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量互联网存款
        OR EXISTS (SELECT 1 FROM PBOCD_JS_202_TYCKFS    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --同业存款发生
        OR EXISTS (SELECT 1 FROM PBOCD_JS_202_WQYBJY    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --稳企业保就业
        OR EXISTS (SELECT 1 FROM PBOCD_JS_203_CLZQTZ    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量债券投资
        OR EXISTS (SELECT 1 FROM PBOCD_JS_203_ZQTZFS    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --债券投资发生
        OR EXISTS (SELECT 1 FROM PBOCD_JS_205_CLPJRZ    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量票据融资
        OR EXISTS (SELECT 1 FROM PBOCD_JS_205_CLYHCD    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量银行承兑
        OR EXISTS (SELECT 1 FROM PBOCD_JS_205_CLZTX     T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量再贴现
        OR EXISTS (SELECT 1 FROM PBOCD_JS_205_PJRZFS    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --票据融资发生
        OR EXISTS (SELECT 1 FROM PBOCD_JS_205_YHCDFS    T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --银行承兑发生
        OR EXISTS (SELECT 1 FROM PBOCD_JS_205_ZTXFS     T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --再贴现发生
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_HDACLKJDK T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量科技贷款
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_HDAKJDKFS T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --科技贷款发生
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_HDACLLSDK T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量绿色贷款
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_HDALSDKFS T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --绿色贷款发生
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_HDACLPHDK T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量普惠贷款
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_HDAPHDKFS T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --普惠贷款发生
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_HDACLYLDK T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量养老产业贷款
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_HDAYLDKFS T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --养老产业贷款发生
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_HDACLSZDK T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量数字经济产业贷款
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_HDASZDKFS T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --数字经济产业贷款发生
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_HDBCLHLDK T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量互联网单位贷款
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_HDBHLDKFS T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --互联网单位贷款发生
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_HDCCLHLDK T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --存量互联网个人贷款
        OR EXISTS (SELECT 1 FROM PBOCD_JS_201_HDCHLDKFS T WHERE T.CJRQ = IS_DATE AND T.ORG_NUM = A.ORG_NUM) --互联网个人贷款发生) 
)*/;

  COMMIT;

--[2025-09-18] [周立鹏] [JLBA202412270002_关于分析排查及改造金融基础数据取数逻辑的需求_四阶段][李楠] 移到上面去了
/*--过滤掉冗余数据
  DELETE FROM PBOCD_JS_101_JRJGFZ
   WHERE CJRQ = IS_DATE
     AND ORG_NUM IN ('120000', '120101',--小企12开头的机构废弃改成009826了
                     '012502'--万达广场支行改成中韩国际合作示范区支行了
                     );
  COMMIT;*/
END IF;
  -------------------------------------------------------------------------
  OI_RETCODE := 0; --设置异常状态为0 成功状态
  OI_RETCODE_DEC :='执行成功';

  /*COMMIT; --非特殊处理只能在最后一次提交*/
  -- 结束日志
  VS_STEP := 'END';
 -- SP_PBOCD_LOG(VS_OWNER, VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, IS_DATE);
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
    /*SP_PBOCD_LOG(VS_OWNER,
                 VS_PROCEDURE_NAME,
                 'ERROR',
                 VI_ERRORCODE,
                 VS_TEXT);*/
     SP_PBOCD_LOG(VS_PROCEDURE_NAME, 'ERROR', VI_ERRORCODE, VS_TEXT, IS_DATE);
END;
