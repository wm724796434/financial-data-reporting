---------------------查明细开始
select substr(tt,1,INSTR(tt, '_')-1) as field_type,
substr(tt,INSTR(tt, '_')+1,2) as clorfs,
balance_sum,
int_rate_wa,
get_loan_num
 from (
select * from (
-- 存量普惠贷款加权平均利率		
SELECT 'T01_存量普惠贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLPHDK A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T01'
union all
-- 存量单位贷款&存量票据融资加权平均利率
SELECT 'T01_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
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
                           FROM JS_201_HDACLPHDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.SME_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLGRDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLPHDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.SME_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLPHDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.SME_LOAN_FLG = '1'
                            AND C.BILL_NUM = D.BILL_NUM)))           
union all
-- 存量普惠贷款加权平均利率		
SELECT 'T02_存量普惠贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLPHDK A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T02'
union all
-- 存量单位贷款&存量票据融资加权平均利率
SELECT 'T02_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
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
                           FROM JS_201_HDACLPHDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.INDIBUS_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLGRDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLPHDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.INDIBUS_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLPHDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.INDIBUS_LOAN_FLG = '1'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 存量普惠贷款加权平均利率		
SELECT 'T03_存量普惠贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLPHDK A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T03'
union all
-- 存量单位贷款&存量票据融资加权平均利率
SELECT 'T03_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
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
                           FROM JS_201_HDACLPHDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.SMEOWNER_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLGRDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLPHDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.SMEOWNER_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLPHDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.SMEOWNER_LOAN_FLG = '1'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 存量普惠贷款加权平均利率		
SELECT 'T04_存量普惠贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLPHDK A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T04'
union all
-- 存量单位贷款&存量票据融资加权平均利率
SELECT 'T04_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
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
                           FROM JS_201_HDACLPHDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.FARMER_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLGRDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLPHDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.FARMER_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLPHDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.FARMER_LOAN_FLG = '1'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 存量普惠贷款加权平均利率		
SELECT 'T05_存量普惠贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLPHDK A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T05'
union all
-- 存量单位贷款&存量票据融资加权平均利率
SELECT 'T05_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
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
                           FROM JS_201_HDACLPHDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.VENTURE_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLGRDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLPHDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.VENTURE_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLPHDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.VENTURE_FLG = '1'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 存量普惠贷款加权平均利率		
SELECT 'T06_存量普惠贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDACLPHDK A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T06'
union all
-- 存量单位贷款&存量票据融资加权平均利率
SELECT 'T06_存量单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
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
                           FROM JS_201_HDACLPHDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.STUDENT_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLGRDK B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLPHDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.STUDENT_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLPHDK D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.STUDENT_LOAN_FLG = '1'
                            AND C.BILL_NUM = D.BILL_NUM)))



union all
-- 发生普惠贷款加权平均利率
SELECT 'T01_发生普惠贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDAPHDKFS A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T01'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'T01_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
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
                           FROM JS_201_HDAPHDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.SME_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAPHDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.SME_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAPHDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.SME_LOAN_FLG = '1'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 发生普惠贷款加权平均利率
SELECT 'T02_发生普惠贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDAPHDKFS A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T02'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'T02_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
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
                           FROM JS_201_HDAPHDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.INDIBUS_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAPHDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.INDIBUS_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAPHDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.INDIBUS_LOAN_FLG = '1'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 发生普惠贷款加权平均利率
SELECT 'T03_发生普惠贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDAPHDKFS A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T03'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'T03_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
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
                           FROM JS_201_HDAPHDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.SMEOWNER_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAPHDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.SMEOWNER_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAPHDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.SMEOWNER_LOAN_FLG = '1'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 发生普惠贷款加权平均利率
SELECT 'T04_发生普惠贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDAPHDKFS A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T04'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'T04_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
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
                           FROM JS_201_HDAPHDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.FARMER_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAPHDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.FARMER_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAPHDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.FARMER_LOAN_FLG = '1'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 发生普惠贷款加权平均利率
SELECT 'T05_发生普惠贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDAPHDKFS A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T05'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'T05_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
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
                           FROM JS_201_HDAPHDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.VENTURE_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAPHDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.VENTURE_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAPHDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.VENTURE_FLG = '1'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
-- 发生普惠贷款加权平均利率
SELECT 'T06_发生普惠贷款' tt,BALANCE_SUM,INT_RATE_WA,GET_LOAN_NUM FROM JS_201_HDAPHDKFS A WHERE A.CJRQ='20240630'  AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T06'
union all
-- 存量发生单位贷款&存量票据融资加权平均利率
SELECT 'T06_发生单位贷款' tt,BALANCE_SUM,ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),GET_LOAN_NUM
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
                           FROM JS_201_HDAPHDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.STUDENT_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  WHERE B.CJRQ = '20240630' 
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAPHDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.STUDENT_LOAN_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = '20240630' 
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAPHDKFS D
                          WHERE D.CJRQ = '20240630' 
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.STUDENT_LOAN_FLG = '1'
                            AND C.BILL_NUM = D.BILL_NUM)))
                            
                            ) 
                            where tt like '%单位%'     
);
---------------------查明细结束
