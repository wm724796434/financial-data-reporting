

truncate table SZDK_spop_tmp ;
insert into  SZDK_spop_tmp 
---------------------查明细开始
select substr(tt,1,3) as field_type,
substr(tt,5,2) as clorfs,
balance_sum,
int_rate_wa,
get_loan_num
 from (
----------------------存量数字贷款----------------------
--T01：数字经济核心产业贷款汇总
select * from (
SELECT 'T01_存量数字经济核心产业贷款' tt,NVL(BALANCE_SUM,0)AS BALANCE_SUM,NVL(INT_RATE_WA,0)AS INT_RATE_WA,NVL(GET_LOAN_NUM,0)AS GET_LOAN_NUM FROM JS_201_HDACLSZDK A WHERE A.CJRQ=IS_DATE AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T01'
union all
SELECT 'T01_存量单位/票据贷款' tt,NVL(BALANCE_SUM,0),NVL(ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),0),NVL(GET_LOAN_NUM,0)
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
                           FROM JS_201_HDACLSZDK D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C01'
              AND D.DEIDY_LOAN_TYPE IN ('DE01','DE02','DE03','DE04')
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = IS_DATE
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLSZDK D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = '99'
                            AND D.BIZ_TYPE='C03'
              AND D.DEIDY_LOAN_TYPE IN ('DE01','DE02','DE03','DE04')
                            AND C.BILL_NUM = D.BILL_NUM)))

union all                       
--T02：数字产品制造业贷款汇总
SELECT 'T02_存量数字产品制造业贷款' tt,NVL(BALANCE_SUM,0),NVL(INT_RATE_WA,0),NVL(GET_LOAN_NUM,0) FROM JS_201_HDACLSZDK A WHERE A.CJRQ=IS_DATE AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T02'
union all
SELECT 'T02_存量单位/票据贷款' tt,NVL(BALANCE_SUM,0),NVL(ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),0),NVL(GET_LOAN_NUM,0)
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
                           FROM JS_201_HDACLSZDK D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C01'
              AND D.DEIDY_LOAN_TYPE = 'DE01'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = IS_DATE
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLSZDK D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C03'
              AND D.DEIDY_LOAN_TYPE = 'DE01'
                            AND C.BILL_NUM = D.BILL_NUM)))

union all                       
--T03：数字产品服务业贷款汇总
SELECT 'T03_存量数字产品服务业贷款' tt,NVL(BALANCE_SUM,0),NVL(INT_RATE_WA,0),NVL(GET_LOAN_NUM,0) FROM JS_201_HDACLSZDK A WHERE A.CJRQ=IS_DATE AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T03'
union all
SELECT 'T03_存量单位/票据贷款' tt,NVL(BALANCE_SUM,0),NVL(ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),0),NVL(GET_LOAN_NUM,0)
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
                           FROM JS_201_HDACLSZDK D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C01'
              AND D.DEIDY_LOAN_TYPE = 'DE02'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = IS_DATE
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLSZDK D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C03'
              AND D.DEIDY_LOAN_TYPE = 'DE02'
                            AND C.BILL_NUM = D.BILL_NUM)))
                            
union all                       
--T04：数字技术应用业贷款汇总
SELECT 'T04_存量数字技术应用业贷款' tt,NVL(BALANCE_SUM,0),NVL(INT_RATE_WA,0),NVL(GET_LOAN_NUM,0) FROM JS_201_HDACLSZDK A WHERE A.CJRQ=IS_DATE AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T04'
union all
SELECT 'T04_存量单位/票据贷款' tt,NVL(BALANCE_SUM,0),NVL(ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),0),NVL(GET_LOAN_NUM,0)
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
                           FROM JS_201_HDACLSZDK D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C01'
              AND D.DEIDY_LOAN_TYPE = 'DE03'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = IS_DATE
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLSZDK D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C03'
              AND D.DEIDY_LOAN_TYPE = 'DE03'
                            AND C.BILL_NUM = D.BILL_NUM)))
                            
union all                       
--T05：数字要素驱动业贷款汇总
SELECT 'T05_存量数字要素驱动业贷款' tt,NVL(BALANCE_SUM,0),NVL(INT_RATE_WA,0),NVL(GET_LOAN_NUM,0) FROM JS_201_HDACLSZDK A WHERE A.CJRQ=IS_DATE AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T05'
union all
SELECT 'T05_存量单位/票据贷款' tt,NVL(BALANCE_SUM,0),NVL(ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),0),NVL(GET_LOAN_NUM,0)
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
                           FROM JS_201_HDACLSZDK D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C01'
              AND D.DEIDY_LOAN_TYPE = 'DE04'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = IS_DATE
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLSZDK D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C03'
              AND D.DEIDY_LOAN_TYPE = 'DE04'
                            AND C.BILL_NUM = D.BILL_NUM)))
                            
union all                       
--T06：数字化效率提升业贷款汇总
SELECT 'T06_存量数字化效率提升业贷款' tt,NVL(BALANCE_SUM,0),NVL(INT_RATE_WA,0),NVL(GET_LOAN_NUM,0) FROM JS_201_HDACLSZDK A WHERE A.CJRQ=IS_DATE AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T06'
union all
SELECT 'T06_存量单位/票据贷款' tt,NVL(BALANCE_SUM,0),NVL(ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),0),NVL(GET_LOAN_NUM,0)
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
                           FROM JS_201_HDACLSZDK D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C01'
              AND D.DIGI_EFF_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = IS_DATE
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLSZDK D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C03'
              AND D.DIGI_EFF_FLG = '1'
                            AND C.BILL_NUM = D.BILL_NUM)))                            
union all
----------------------数字贷款发生----------------------
--T01：数字经济核心产业贷款汇总
SELECT 'T01_发生数字经济核心产业贷款' tt,NVL(BALANCE_SUM,0),NVL(INT_RATE_WA,0),NVL(GET_LOAN_NUM,0) FROM JS_201_HDASZDKFS A WHERE A.CJRQ=IS_DATE AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T01'
union all
SELECT 'T01_发生单位/票据贷款' tt,NVL(BALANCE_SUM,0),NVL(ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),0),NVL(GET_LOAN_NUM,0)
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
                           FROM JS_201_HDASZDKFS D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C01'
              AND D.DEIDY_LOAN_TYPE IN ('DE01','DE02','DE03','DE04')
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = IS_DATE
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDASZDKFS D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C02'
              AND D.DEIDY_LOAN_TYPE IN ('DE01','DE02','DE03','DE04')
                            AND C.BILL_NUM = D.BILL_NUM)))
UNION ALL
--T02：数字产品制造业贷款汇总
SELECT 'T02_发生数字产品制造业贷款' tt,NVL(BALANCE_SUM,0),NVL(INT_RATE_WA,0),NVL(GET_LOAN_NUM,0) FROM JS_201_HDASZDKFS A WHERE A.CJRQ=IS_DATE AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T02'
union all
SELECT 'T02_发生单位/票据贷款' tt,NVL(BALANCE_SUM,0),NVL(ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),0),NVL(GET_LOAN_NUM,0)
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
                           FROM JS_201_HDASZDKFS D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C01'
              AND D.DEIDY_LOAN_TYPE = 'DE01'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = IS_DATE
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDASZDKFS D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C02'
              AND D.DEIDY_LOAN_TYPE = 'DE01'
                            AND C.BILL_NUM = D.BILL_NUM)))
                            
UNION ALL
--T03：数字产品服务业贷款汇总
SELECT 'T03_发生数字产品服务业贷款' tt,NVL(BALANCE_SUM,0),NVL(INT_RATE_WA,0),NVL(GET_LOAN_NUM,0) FROM JS_201_HDASZDKFS A WHERE A.CJRQ=IS_DATE AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T03'
union all
SELECT 'T03_发生单位/票据贷款' tt,NVL(BALANCE_SUM,0),NVL(ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),0),NVL(GET_LOAN_NUM,0)
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
                           FROM JS_201_HDASZDKFS D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C01'
              AND D.DEIDY_LOAN_TYPE = 'DE02'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = IS_DATE
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDASZDKFS D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C02'
              AND D.DEIDY_LOAN_TYPE = 'DE02'
                            AND C.BILL_NUM = D.BILL_NUM)))
                            
UNION ALL
--T04：数字技术应用业贷款汇总
SELECT 'T04_发生数字技术应用业贷款' tt,NVL(BALANCE_SUM,0),NVL(INT_RATE_WA,0),NVL(GET_LOAN_NUM,0) FROM JS_201_HDASZDKFS A WHERE A.CJRQ=IS_DATE AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T04'
union all
SELECT 'T04_发生单位/票据贷款' tt,NVL(BALANCE_SUM,0),NVL(ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),0),NVL(GET_LOAN_NUM,0)
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
                           FROM JS_201_HDASZDKFS D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C01'
              AND D.DEIDY_LOAN_TYPE = 'DE03'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = IS_DATE
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDASZDKFS D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C02'
              AND D.DEIDY_LOAN_TYPE = 'DE03'
                            AND C.BILL_NUM = D.BILL_NUM)))
                            
UNION ALL
--T05：数字要素驱动业贷款汇总
SELECT 'T05_发生数字要素驱动业贷款' tt,NVL(BALANCE_SUM,0),NVL(INT_RATE_WA,0),NVL(GET_LOAN_NUM,0) FROM JS_201_HDASZDKFS A WHERE A.CJRQ=IS_DATE AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T05'
union all
SELECT 'T05_发生单位/票据贷款' tt,NVL(BALANCE_SUM,0),NVL(ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),0),NVL(GET_LOAN_NUM,0)
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
                           FROM JS_201_HDASZDKFS D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C01'
              AND D.DEIDY_LOAN_TYPE = 'DE04'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = IS_DATE
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDASZDKFS D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C02'
              AND D.DEIDY_LOAN_TYPE = 'DE04'
                            AND C.BILL_NUM = D.BILL_NUM)))
                            
UNION ALL
--T06：数字化效率提升业贷款汇总
SELECT 'T06_发生数字化效率提升业贷款' tt,NVL(BALANCE_SUM,0),NVL(INT_RATE_WA,0),NVL(GET_LOAN_NUM,0) FROM JS_201_HDASZDKFS A WHERE A.CJRQ=IS_DATE AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T06'
union all
SELECT 'T06_发生单位/票据贷款' tt,NVL(BALANCE_SUM,0),NVL(ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),0),NVL(GET_LOAN_NUM,0)
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
                           FROM JS_201_HDASZDKFS D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C01'
              AND D.DIGI_EFF_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = IS_DATE
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDASZDKFS D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C02'
              AND D.DIGI_EFF_FLG = '1'
                            AND C.BILL_NUM = D.BILL_NUM)))
) 
where tt like '%单位%'      --
order by substr(tt,5,2),substr(tt,2,2)      
)   ;
---------------------查明细结束

merge into JS_201_HDACLSZDK a 
using SZDK_spop_tmp b
on (a.cjrq=IS_DATE and a.field_type=b.field_type and b.clorfs='存量')
when matched then
  update set a.balance_sum=b.balance_sum,a.int_rate_wa=b.int_rate_wa,a.get_loan_num=b.get_loan_num
  where a.cjrq=IS_DATE and frnbjgh='990000'  ;

merge into JS_201_HDASZDKFS a 
using SZDK_spop_tmp b
on (a.cjrq=IS_DATE and a.field_type=b.field_type and b.clorfs='发生')
when matched then
  update set a.balance_sum=b.balance_sum,a.int_rate_wa=b.int_rate_wa,a.get_loan_num=b.get_loan_num
  where a.cjrq=IS_DATE and frnbjgh='990000'  ;