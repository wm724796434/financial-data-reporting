CREATE OR REPLACE PROCEDURE BSP_SP_JS_SPOP(IS_DATE IN VARCHAR2,  --输入日期
                                           OI_RETCODE  OUT INTEGER,   --返回code
                                           OI_REMESSAGE OUT VARCHAR2,  --返回message
                                           I_TABLE_NAME  IN VARCHAR2  --输入表名
                                           ) AS
  ------------------------------------------------------------------------------------------------------
  -- 程序名：BSP_SP_JS_SPOP
  -- 程序功能：金数特殊处理（加工之后，推数之前）
  -- 创建日期：20230807
  -- 创建人：zhoulp
  -- 参数：
  -- IS_DATE 输入变量，传入跑批日期
  -- OI_RETCODE 输出变量，用来标识存储过程执行过程中是否出现异常

  VS_PROCEDURE_NAME VARCHAR(30); --当前储存过程名称
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --字符型  过程描述
  VS_STEP           VARCHAR2(50); --存储过程执行步骤标志
  VS_LAST_MONTH     VARCHAR2(10) DEFAULT NULL; --字符型
  VS_DATA_DATE_10   VARCHAR2(10) DEFAULT NULL; --字符型
  SQL_STMT          CLOB;
  SQL_STMT_A        CLOB;
  V_COUNT           NUMBER;
  V_TABLE_NAME_E    VARCHAR2(20);
  V_OPERA_ID        VARCHAR2(20);
  
  TYPE TYPE_ARRAY IS TABLE OF  JS_SPOP_CONFIG%rowtype INDEX BY BINARY_INTEGER;
  VAR_ARRAY TYPE_ARRAY ;
  
BEGIN

  VS_PROCEDURE_NAME := 'BSP_SP_JS_SPOP';
  VS_LAST_MONTH   := TO_CHAR(LAST_DAY(ADD_MONTHS(TO_DATE(IS_DATE, 'YYYYMMDD'), '-1')),'YYYYMMDD');
  VS_DATA_DATE_10 := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'),'YYYY-MM-DD');
  -- 开始日志
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, OI_RETCODE, VS_TEXT, IS_DATE);
  
  SELECT *
    BULK COLLECT
    INTO VAR_ARRAY
    FROM JS_SPOP_CONFIG
   WHERE TABLE_NAME_E = I_TABLE_NAME
     AND OPERA_STATUS = 'Y' ORDER BY OPERA_ID;
     
  FOR I IN 1..VAR_ARRAY.COUNT LOOP
  V_COUNT := LENGTH(VAR_ARRAY(I).OPERA_SQL)- LENGTH(REPLACE(VAR_ARRAY(I).OPERA_SQL,';'));
  V_TABLE_NAME_E:=VAR_ARRAY(I).TABLE_NAME_E;
  V_OPERA_ID:=VAR_ARRAY(I).OPERA_ID;
  FOR J IN 1..V_COUNT LOOP 
  IF J=1 THEN 
    SQL_STMT := REPLACE(REPLACE(REPLACE(SUBSTR(VAR_ARRAY(I).OPERA_SQL,1
                   ,INSTR(VAR_ARRAY(I).OPERA_SQL,';',1,J)-1)
                   ,'$DATA_DATE_10',''''||VS_DATA_DATE_10||''''),'$LAST_MONTH_DATE',''''||VS_LAST_MONTH||'''')
                   ,'$DATA_DATE',''''||IS_DATE||'''');
  ELSE
    SQL_STMT := REPLACE(REPLACE(REPLACE(SUBSTR(VAR_ARRAY(I).OPERA_SQL,1+INSTR(VAR_ARRAY(I).OPERA_SQL,';',1,J-1)
                   ,INSTR(VAR_ARRAY(I).OPERA_SQL,';',1,J)-INSTR(VAR_ARRAY(I).OPERA_SQL,';',1,J-1)-1)
                   ,'$DATA_DATE_10',''''||VS_DATA_DATE_10||''''),'$LAST_MONTH_DATE',''''||VS_LAST_MONTH||'''')
                   ,'$DATA_DATE',''''||IS_DATE||'''');
  END IF;
    EXECUTE IMMEDIATE SQL_STMT;
    COMMIT;

--记录日志
    SQL_STMT_A := 'insert into JS_SPOP_LOG values('''||i||'_'||j||''','''||IS_DATE||''','||to_char(sysdate,'''YYYY-MM-DD HH24:MI:SS''')||','''||VAR_ARRAY(I).opera_id||''','''||VAR_ARRAY(I).table_name_e||''','''||VAR_ARRAY(I).table_name||''','''||VAR_ARRAY(I).opera_desc||''','''||REPLACE(substr(SQL_STMT,1,2000),'''','''''')||''')';
    EXECUTE IMMEDIATE SQL_STMT_A;
    COMMIT;
END LOOP;
END LOOP;


  -- 结束日志
  VS_STEP := 'END';
  OI_RETCODE := 0; --设置异常状态为0 成功状态
  OI_REMESSAGE :='执行成功';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, OI_RETCODE, VS_TEXT, IS_DATE);
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    --如果出现异常
    OI_RETCODE := SQLCODE; --设置异常代码
    VS_TEXT      := 'JS_SPOP_CONFIG表 操作编号'|| V_TABLE_NAME_E ||'-'
                    || V_OPERA_ID ||'执行错误 语句:' ||
                    SUBSTR(SQL_STMT, 1, 200); --设置异常描述
    --ROLLBACK; --数据回滚
    OI_RETCODE := -1; --设置异常状态为-1
    OI_REMESSAGE :=SQLCODE||':'||SUBSTR(SQL_STMT,1,50);--系统错误描述
    --插入日志表，记录错误
    SP_PBOCD_LOG(VS_PROCEDURE_NAME, 'ERROR', OI_RETCODE, VS_TEXT, IS_DATE);
END;
/

