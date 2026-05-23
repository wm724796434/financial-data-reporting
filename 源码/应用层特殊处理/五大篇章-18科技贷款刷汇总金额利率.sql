/*--当票据编号不为“0”时，对应的票据融资信息应在存量票据融资信息中存在 
-------------------①机构号和机构代码按存量票据刷-----------------------
merge into JS_201_HDAclKJDK a 
using  js_205_clpjrz b 
on (a.bill_num=b.bill_num and b.cjrq=IS_DATE and a.cjrq=IS_DATE )
when matched then 
  update set a.org_code=b.org_code,a.org_num=b.org_num 
  where 
  a.cjrq =IS_DATE and a.frnbjgh='990000' and a.field_type='T13'and a.bill_num <>'0'
  and not exists (select * from js_205_clpjrz b 
  where b.cjrq=IS_DATE and a.bill_num =b.bill_num 
  and a.org_code=b.org_code and a.org_num=b.org_num) ;
-------------------②删除不存在的票据号-------------------------------------
delete FROM JS_201_HDACLKJDK a 
where a.cjrq =IS_DATE and a.frnbjgh='990000' and a.field_type='T13'and a.bill_num <>'0'
and not exists (select * from js_205_clpjrz b 
where b.cjrq=IS_DATE and a.bill_num =b.bill_num and a.org_code=b.org_code ) ;


  
--当贷款合同编码不为“0”，且贷款借据编码不为“0”时，对应的贷款借据信息应在存量单位贷款信息中存在
-------------------①机构号和机构代码按存量单位贷款刷-----------------------
merge into JS_201_HDAclKJDK a 
using  js_201_cldwdk b 
on (a.contract_code=b.contract_code and a.loan_num=b.loan_num and b.cjrq=IS_DATE and a.cjrq=IS_DATE )
when matched then 
  update set a.org_code=b.org_code,a.org_num=b.org_num 
  where 
  a.cjrq =IS_DATE and a.frnbjgh='990000' and a.field_type='T13'and a.contract_code <>'0'and a.loan_num<>'0'
  and not exists (select * from js_201_cldwdk b 
  where b.cjrq=IS_DATE and a.contract_code =b.contract_code 
  and a.loan_num=b.loan_num and a.org_code=b.org_code and a.org_num=b.org_num) ;
-------------------②删除不存在的合同号-------------------------------------
delete FROM JS_201_HDACLKJDK a 
where a.cjrq =IS_DATE and a.frnbjgh='990000' and a.field_type='T13'and a.contract_code <>'0'and a.loan_num<>'0'
and not exists (select * from js_201_cldwdk b 
where b.cjrq=IS_DATE and a.contract_code =b.contract_code and a.loan_num=b.loan_num and a.org_code=b.org_code ) ;

  
--当票据编号不为“0”时，对应的票据融资信息应在票据融资发生额信息中存在 
-------------------①机构号和机构代码按票据发生刷---------------------------
merge into JS_201_HDAKJDKfs a 
using  js_205_pjrzfs b 
on (a.bill_num=b.bill_num and b.cjrq=IS_DATE and a.cjrq=IS_DATE )
when matched then 
  update set a.org_code=b.org_code,a.org_num=b.org_num 
  where 
  a.cjrq =IS_DATE and a.frnbjgh='990000' and a.field_type='T13'and a.bill_num <>'0'
  and not exists (select * from js_205_pjrzfs b 
  where b.cjrq=IS_DATE and a.bill_num =b.bill_num 
  and a.org_code=b.org_code and a.org_num=b.org_num) ;
-------------------②删除不存在的票据号-------------------------------------
delete FROM JS_201_HDAKJDKfs a 
where a.cjrq =IS_DATE and a.frnbjgh='990000' and a.field_type='T13'and a.bill_num <>'0'
and not exists (select * from js_205_pjrzfs b 
where b.cjrq=IS_DATE and a.bill_num =b.bill_num and a.org_code=b.org_code ) ;


--当贷款合同编码不为“0”，且贷款借据编码不为“0”时，对应的贷款借据信息应在单位贷款发生额信息中存在 
-------------------①机构号和机构代码按单位贷款发生刷----------------------
merge into JS_201_HDAKJDKfs a 
using  js_201_dwdkfs b 
on (a.contract_code=b.contract_code and a.loan_num=b.loan_num and b.cjrq=IS_DATE and a.cjrq=IS_DATE )
when matched then 
  update set a.org_code=b.org_code,a.org_num=b.org_num 
  where 
  a.cjrq =IS_DATE and a.frnbjgh='990000' and a.field_type='T13'and a.contract_code <>'0'and a.loan_num<>'0'
  and not exists (select * from js_201_dwdkfs b 
  where b.cjrq=IS_DATE and a.contract_code =b.contract_code 
  and a.loan_num=b.loan_num and a.org_code=b.org_code and a.org_num=b.org_num) ;
-------------------②删除不存在的合同号-------------------------------------
delete FROM JS_201_HDAKJDKfs a 
where a.cjrq =IS_DATE and a.frnbjgh='990000' and a.field_type='T13'and a.contract_code <>'0'and a.loan_num<>'0'
and not exists (select * from js_201_dwdkfs b 
where b.cjrq=IS_DATE and a.contract_code =b.contract_code and a.loan_num=b.loan_num and a.org_code=b.org_code) ;
*/

--当月汇总数据插入临时表 
truncate table KJDK_spop_tmp ;
insert into  KJDK_spop_tmp 
---------------------查明细开始
select substr(tt,1,3) as field_type,
substr(tt,5,2) as clorfs,
balance_sum,
int_rate_wa,
get_loan_num
 from (
select * from (
-- 存量科技贷款加权平均利率		
SELECT 'T12_存量科技贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLKJDK A WHERE A.CJRQ=IS_DATE  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T12'
union all
-- 存量存量单位贷款&存量票据融资加权平均利率
SELECT 'T12_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLDWDK B
                  WHERE B.CJRQ = IS_DATE 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLKJDK D
                          WHERE D.CJRQ = IS_DATE 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T13'
                            AND (D.EMERGING_FLG = '1' OR D.IP_FLG = '1' OR D.SERVICE_TECH_FLG = '1' OR D.HIGH_TECH_FLG = '1')
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = IS_DATE 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLKJDK E
                          WHERE E.CJRQ = IS_DATE 
                            AND E.FRNBJGH = '990000'
                            AND E.BILL_NUM <> '0'
                            AND E.FIELD_TYPE = 'T13'
                            AND (E.EMERGING_FLG = '1' OR E.IP_FLG = '1' OR E.SERVICE_TECH_FLG = '1' OR E.HIGH_TECH_FLG = '1')
                            AND C.BILL_NUM = E.BILL_NUM)))
              
union all
-- 存量科技贷款加权平均利率    
SELECT 'T10_存量科技贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLKJDK A WHERE A.CJRQ=IS_DATE  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T10'
union all
-- 存量存量单位贷款&存量票据融资加权平均利率
SELECT 'T10_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLDWDK B
                  WHERE B.CJRQ = IS_DATE 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLKJDK D
                          WHERE D.CJRQ = IS_DATE 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T13'
                            AND D.EMERGING_FLG = '1' --14712
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = IS_DATE 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLKJDK E
                          WHERE E.CJRQ = IS_DATE 
                            AND E.FRNBJGH = '990000'
                            AND E.BILL_NUM <> '0'
                            AND E.FIELD_TYPE = 'T13'
                            AND E.EMERGING_FLG = '1'
                            AND C.BILL_NUM = E.BILL_NUM)))
union all              
-- 存量科技贷款加权平均利率    
SELECT 'T11_存量科技贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLKJDK A WHERE A.CJRQ=IS_DATE  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T11'
union all
-- 存量存量单位贷款&存量票据融资加权平均利率
SELECT 'T11_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLDWDK B
                  WHERE B.CJRQ = IS_DATE 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLKJDK D
                          WHERE D.CJRQ = IS_DATE 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T13'
                            AND D.IP_FLG = '1' --14712
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = IS_DATE 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLKJDK E
                          WHERE E.CJRQ = IS_DATE 
                            AND E.FRNBJGH = '990000'
                            AND E.BILL_NUM <> '0'
                            AND E.FIELD_TYPE = 'T13'
                            AND E.IP_FLG = '1'
                            AND C.BILL_NUM = E.BILL_NUM)))
union all              
-- 存量科技贷款加权平均利率    
SELECT 'T09_存量科技贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLKJDK A WHERE A.CJRQ=IS_DATE  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T09'
union all
-- 存量存量单位贷款&存量票据融资加权平均利率
SELECT 'T09_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLDWDK B
                  WHERE B.CJRQ = IS_DATE 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLKJDK D
                          WHERE D.CJRQ = IS_DATE 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T13'
                            AND D.SERVICE_TECH_FLG = '1' --14712
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = IS_DATE 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLKJDK E
                          WHERE E.CJRQ = IS_DATE 
                            AND E.FRNBJGH = '990000'
                            AND E.BILL_NUM <> '0'
                            AND E.FIELD_TYPE = 'T13'
                            AND E.SERVICE_TECH_FLG = '1'
                            AND C.BILL_NUM = E.BILL_NUM)))
                            
union all              
-- 存量科技贷款加权平均利率    
SELECT 'T08_存量科技贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLKJDK A WHERE A.CJRQ=IS_DATE  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T08'
union all
-- 存量存量单位贷款&存量票据融资加权平均利率
SELECT 'T08_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLDWDK B
                  WHERE B.CJRQ = IS_DATE 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLKJDK D
                          WHERE D.CJRQ = IS_DATE 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T13'
                            AND D.HIGH_TECH_FLG = '1' --14712
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = IS_DATE 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLKJDK E
                          WHERE E.CJRQ = IS_DATE 
                            AND E.FRNBJGH = '990000'
                            AND E.BILL_NUM <> '0'
                            AND E.FIELD_TYPE = 'T13'
                            AND E.HIGH_TECH_FLG = '1'
                            AND C.BILL_NUM = E.BILL_NUM)))





union all
-- 发生科技贷款加权平均利率
SELECT 'T12_发生科技贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDAKJDKFS A WHERE A.CJRQ=IS_DATE  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T12'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'T12_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_DWDKFS B
                  WHERE B.CJRQ = IS_DATE 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAKJDKFS D
                          WHERE D.CJRQ = IS_DATE 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T13'
                            AND (D.EMERGING_FLG = '1' OR D.IP_FLG = '1' OR D.SERVICE_TECH_FLG = '1' OR D.HIGH_TECH_FLG = '1')
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = IS_DATE 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAKJDKFS E
                          WHERE E.CJRQ = IS_DATE 
                            AND E.FRNBJGH = '990000'
                            AND E.BILL_NUM <> '0'
                            AND E.FIELD_TYPE = 'T13'
                            AND (E.EMERGING_FLG = '1' OR E.IP_FLG = '1' OR E.SERVICE_TECH_FLG = '1' OR E.HIGH_TECH_FLG = '1')
                            AND C.BILL_NUM = E.BILL_NUM)))
              
union all              
-- 发生科技贷款加权平均利率    
SELECT 'T10_发生科技贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDAKJDKFS A WHERE A.CJRQ=IS_DATE  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T10'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'T10_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_DWDKFS B
                  WHERE B.CJRQ = IS_DATE 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAKJDKFS D
                          WHERE D.CJRQ = IS_DATE 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T13'
                            AND D.EMERGING_FLG = '1' --14712
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = IS_DATE 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAKJDKFS E
                          WHERE E.CJRQ = IS_DATE 
                            AND E.FRNBJGH = '990000'
                            AND E.BILL_NUM <> '0'
                            AND E.FIELD_TYPE = 'T13'
                            AND E.EMERGING_FLG = '1'
                            AND C.BILL_NUM = E.BILL_NUM)))
              
union all              
-- 发生科技贷款加权平均利率    
SELECT 'T11_发生科技贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDAKJDKFS A WHERE A.CJRQ=IS_DATE  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T11'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'T11_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_DWDKFS B
                  WHERE B.CJRQ = IS_DATE 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAKJDKFS D
                          WHERE D.CJRQ = IS_DATE 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T13'
                            AND D.IP_FLG = '1' --14712
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = IS_DATE 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAKJDKFS E
                          WHERE E.CJRQ = IS_DATE 
                            AND E.FRNBJGH = '990000'
                            AND E.BILL_NUM <> '0'
                            AND E.FIELD_TYPE = 'T13'
                            AND E.IP_FLG = '1'
                            AND C.BILL_NUM = E.BILL_NUM)))
union all              
-- 发生科技贷款加权平均利率    
SELECT 'T09_发生科技贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDAKJDKFS A WHERE A.CJRQ=IS_DATE  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T09'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'T09_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_DWDKFS B
                  WHERE B.CJRQ = IS_DATE 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAKJDKFS D
                          WHERE D.CJRQ = IS_DATE 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T13'
                            AND D.SERVICE_TECH_FLG = '1' --14712
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = IS_DATE 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAKJDKFS E
                          WHERE E.CJRQ = IS_DATE 
                            AND E.FRNBJGH = '990000'
                            AND E.BILL_NUM <> '0'
                            AND E.FIELD_TYPE = 'T13'
                            AND E.SERVICE_TECH_FLG = '1'
                            AND C.BILL_NUM = E.BILL_NUM)))
                            
union all              
-- 发生科技贷款加权平均利率    
SELECT 'T08_发生科技贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDAKJDKFS A WHERE A.CJRQ=IS_DATE  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T08'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'T08_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_DWDKFS B
                  WHERE B.CJRQ = IS_DATE 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAKJDKFS D
                          WHERE D.CJRQ = IS_DATE 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T13'
                            AND D.HIGH_TECH_FLG = '1' --14712
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = IS_DATE 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAKJDKFS E
                          WHERE E.CJRQ = IS_DATE 
                            AND E.FRNBJGH = '990000'
                            AND E.BILL_NUM <> '0'
                            AND E.FIELD_TYPE = 'T13'
                            AND E.HIGH_TECH_FLG = '1'
                            AND C.BILL_NUM = E.BILL_NUM)))
                            ) 
                            where tt like '%单位%'     
);
---------------------查明细结束
/* 存量科技贷款T01-T12按汇总数据刷 */
merge into JS_201_HDAclKJDK a 
using KJDK_spop_tmp b
on (a.cjrq=IS_DATE and a.field_type=b.field_type and b.clorfs='存量')
when matched then
  update set a.balance_sum=b.balance_sum,a.int_rate_wa=b.int_rate_wa,a.get_loan_num=b.get_loan_num
  where a.cjrq=IS_DATE and frnbjgh='990000'  ;

/* 科技贷款发生T01-T12按汇总数据刷 */
merge into JS_201_HDAKJDKFS a 
using KJDK_spop_tmp b
on (a.cjrq=IS_DATE and a.field_type=b.field_type and b.clorfs='发生')
when matched then
  update set a.balance_sum=b.balance_sum,a.int_rate_wa=b.int_rate_wa,a.get_loan_num=b.get_loan_num
  where a.cjrq=IS_DATE and frnbjgh='990000'  ;
------------END--------------------------------------------------