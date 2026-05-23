---------------------查明细开始
select substr(tt,1,INSTR(tt, '_')-1) as field_type,
substr(tt,INSTR(tt, '_')+1,2) as clorfs,
balance_sum,
int_rate_wa,
get_loan_num
 from (
select * from (
-- 存量绿色贷款加权平均利率		
SELECT 'TNA01_存量绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLLSDK A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TNA01'
union all
-- 存量单位贷款&存量票据融资加权平均利率
SELECT 'TNA01_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLDWDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA01'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLGRDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA01'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA01'
                            AND C.BILL_NUM = D.BILL_NUM)))           
union all
-- 存量绿色贷款加权平均利率		
SELECT 'TNA02_存量绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLLSDK A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TNA02'
union all
-- 存量单位贷款&存量票据融资加权平均利率
SELECT 'TNA02_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLDWDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA02'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLGRDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA02'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA02'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 存量绿色贷款加权平均利率		
SELECT 'TNA03_存量绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLLSDK A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TNA03'
union all
-- 存量单位贷款&存量票据融资加权平均利率
SELECT 'TNA03_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLDWDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA03'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLGRDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA03'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA03'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 存量绿色贷款加权平均利率		
SELECT 'TNA04_存量绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLLSDK A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TNA04'
union all
-- 存量单位贷款&存量票据融资加权平均利率
SELECT 'TNA04_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLDWDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA04'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLGRDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA04'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA04'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 存量绿色贷款加权平均利率		
SELECT 'TNA05_存量绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLLSDK A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TNA05'
union all
-- 存量单位贷款&存量票据融资加权平均利率
SELECT 'TNA05_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLDWDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA05'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLGRDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA05'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA05'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 存量绿色贷款加权平均利率		
SELECT 'TNA06_存量绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLLSDK A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TNA06'
union all
-- 存量单位贷款&存量票据融资加权平均利率
SELECT 'TNA06_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLDWDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA06'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLGRDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA06'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA06'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 存量绿色贷款加权平均利率		
SELECT 'TNA07_存量绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLLSDK A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TNA07'
union all
-- 存量单位贷款&存量票据融资加权平均利率
SELECT 'TNA07_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLDWDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA07'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLGRDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA07'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA07'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 存量绿色贷款加权平均利率		
SELECT 'TNB_存量绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLLSDK A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TNB'
union all
-- 存量单位贷款&存量票据融资加权平均利率
SELECT 'TNB_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLDWDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NB'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLGRDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NB'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NB'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 存量绿色贷款加权平均利率		
SELECT 'TNC_存量绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLLSDK A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TNC'
union all
-- 存量单位贷款&存量票据融资加权平均利率
SELECT 'TNC_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLDWDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NC'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLGRDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NC'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NC'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 存量绿色贷款加权平均利率		
SELECT 'TW00_存量绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLLSDK A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TW00'
union all
-- 存量单位贷款&存量票据融资加权平均利率
SELECT 'TW00_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLDWDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'W00'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLGRDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'W00'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLLSDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'W00'
                            AND C.BILL_NUM = D.BILL_NUM)))
                            
                            



union all
-- 发生绿色贷款加权平均利率
SELECT 'TNA01_发生绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDALSDKFS A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TNA01'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'TNA01_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_DWDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA01'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA01'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA01'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 发生绿色贷款加权平均利率
SELECT 'TNA02_发生绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDALSDKFS A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TNA02'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'TNA02_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_DWDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA02'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA02'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA02'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 发生绿色贷款加权平均利率
SELECT 'TNA03_发生绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDALSDKFS A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TNA03'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'TNA03_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_DWDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA03'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA03'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA03'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 发生绿色贷款加权平均利率
SELECT 'TNA04_发生绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDALSDKFS A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TNA04'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'TNA04_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_DWDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA04'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA04'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA04'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 发生绿色贷款加权平均利率
SELECT 'TNA05_发生绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDALSDKFS A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TNA05'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'TNA05_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_DWDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA05'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA05'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA05'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 发生绿色贷款加权平均利率
SELECT 'TNA06_发生绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDALSDKFS A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TNA06'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'TNA06_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_DWDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA06'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA06'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA06'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 发生绿色贷款加权平均利率
SELECT 'TNA07_发生绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDALSDKFS A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TNA07'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'TNA07_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_DWDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA07'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA07'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NA07'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 发生绿色贷款加权平均利率
SELECT 'TNB_发生绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDALSDKFS A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TNB'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'TNB_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_DWDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NB'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NB'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NB'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 发生绿色贷款加权平均利率
SELECT 'TNC_发生绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDALSDKFS A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TNC'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'TNC_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_DWDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NC'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NC'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'NC'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 发生绿色贷款加权平均利率
SELECT 'TW00_发生绿色贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDALSDKFS A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='TW00'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'TW00_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
  FROM (        
        SELECT SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_DWDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'W00'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'W00'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDALSDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.GREEN_LOAN_TYPE = 'W00'
                            AND C.BILL_NUM = D.BILL_NUM)))
                            
                            ) 
                            where tt like '%单位%'     
);
---------------------查明细结束
