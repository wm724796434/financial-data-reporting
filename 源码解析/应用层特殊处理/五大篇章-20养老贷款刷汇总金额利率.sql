
----------------------------------------------------------------------------------------------------
-- 文件名: 五大篇章-20养老贷款刷汇总金额利率.sql
-- 业务域: 应用层特殊处理
-- 用途: 查明细开始
----------------------------------------------------------------------------------------------------
truncate table YLDK_spop_tmp ;
insert into  YLDK_spop_tmp 
---------------------查明细开始
select substr(tt,1,3) as field_type,
substr(tt,5,2) as clorfs,
balance_sum,
int_rate_wa,
get_loan_num
 from ( 
----------------------存量养老贷款----------------------
--T01-养老产业贷款汇总
SELECT * from (
SELECT 'T01_存量养老贷款' tt,NVL(BALANCE_SUM,0) AS BALANCE_SUM,NVL(INT_RATE_WA,0) AS INT_RATE_WA,NVL(GET_LOAN_NUM,0)AS GET_LOAN_NUM FROM JS_201_HDACLYLDK A WHERE A.CJRQ=IS_DATE AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T01'
union all
SELECT 'T01_存量单位/个人/票据贷款' tt,NVL(BALANCE_SUM,0),NVL(ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),0),NVL(GET_LOAN_NUM,0)
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
                           FROM JS_201_HDACLYLDK D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C01'
              AND D.PENSIDY_TYPE IS NOT NULL
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLGRDK B
                  WHERE B.CJRQ = IS_DATE
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLYLDK D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C02'
              AND D.PENSIDY_TYPE IS NOT NULL
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = IS_DATE
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLYLDK D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C03'
              AND D.PENSIDY_TYPE IS NOT NULL
                            AND C.BILL_NUM = D.BILL_NUM)))

union all                       
--T02-全国养老机构贷款汇总
SELECT 'T02_存量养老贷款' tt,NVL(BALANCE_SUM,0),NVL(INT_RATE_WA,0),NVL(GET_LOAN_NUM,0) FROM JS_201_HDACLYLDK A WHERE A.CJRQ=IS_DATE AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T02'
union all
SELECT 'T02_存量单位/个人/票据贷款' tt,NVL(BALANCE_SUM,0),NVL(ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),0),NVL(GET_LOAN_NUM,0)
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
                           FROM JS_201_HDACLYLDK D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C01'
              AND D.NURSING_FLG = '1'
              AND D.PENSIDY_TYPE IS NOT NULL
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                        BALANCE_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_CLGRDK B
                  WHERE B.CJRQ = IS_DATE
                    AND B.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLYLDK D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C02'
              AND D.NURSING_FLG = '1'
              AND D.PENSIDY_TYPE IS NOT NULL
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_BAL_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_CLPJRZ C
                  WHERE C.CJRQ = IS_DATE
                    AND C.FRNBJGH = '990000'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDACLYLDK D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C03'
              AND D.NURSING_FLG = '1'
              AND D.PENSIDY_TYPE IS NOT NULL
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
--ADD BY ZHOULP 20260129 BEGIN_01
--T03-T14养老产业贷款按分类汇总
SELECT FIELD_TYPE||'_存量养老贷款' tt,NVL(BALANCE_SUM,0) AS BALANCE_SUM,NVL(INT_RATE_WA,0) AS INT_RATE_WA,NVL(GET_LOAN_NUM,0)AS GET_LOAN_NUM FROM JS_201_HDACLYLDK A WHERE A.CJRQ=IS_DATE AND A.FRNBJGH='990000' AND FIELD_TYPE NOT IN('T01','T02','T99') 
union all
SELECT CASE
         WHEN PENSIDY_TYPE = 'EC01' THEN
          'T03'
         WHEN PENSIDY_TYPE = 'EC02' THEN
          'T04'
         WHEN PENSIDY_TYPE = 'EC03' THEN
          'T05'
         WHEN PENSIDY_TYPE = 'EC04' THEN
          'T06'
         WHEN PENSIDY_TYPE = 'EC05' THEN
          'T07'
         WHEN PENSIDY_TYPE = 'EC06' THEN
          'T08'
         WHEN PENSIDY_TYPE = 'EC07' THEN
          'T09'
         WHEN PENSIDY_TYPE = 'EC08' THEN
          'T10'
         WHEN PENSIDY_TYPE = 'EC09' THEN
          'T11'
         WHEN PENSIDY_TYPE = 'EC10' THEN
          'T12'
         WHEN PENSIDY_TYPE = 'EC11' THEN
          'T13'
         WHEN PENSIDY_TYPE = 'EC12' THEN
          'T14'
       END || '_存量单位/个人/票据贷款' tt,
       NVL(BALANCE_SUM, 0),
       NVL(ROUND(BALANCE_INT_SUM / BALANCE_SUM, 5), 0),
       NVL(GET_LOAN_NUM, 0)
  FROM (SELECT PENSIDY_TYPE,
               SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
               SUM(BALANCE_SUM) AS BALANCE_SUM,
               COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT PENSIDY_TYPE,
                       BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                       BALANCE_RMB AS BALANCE_SUM,
                       CUST_ID_NO AS GET_LOAN_NUM
                  FROM JS_201_CLDWDK B
                 INNER JOIN JS_201_HDACLYLDK D
                    ON D.CJRQ = IS_DATE
                   AND D.FRNBJGH = '990000'
                   AND D.LOAN_NUM <> '0'
                   AND D.FIELD_TYPE = 'T99'
                   AND D.BIZ_TYPE = 'C01'
                   AND D.PENSIDY_TYPE IS NOT NULL
                   AND B.LOAN_NUM = D.LOAN_NUM
                 WHERE B.CJRQ = IS_DATE
                   AND B.FRNBJGH = '990000'
                UNION ALL
                SELECT PENSIDY_TYPE,
                       BALANCE_RMB * INT_RATE AS BALANCE_INT_SUM,
                       BALANCE_RMB AS BALANCE_SUM,
                       CUST_ID_NO AS GET_LOAN_NUM
                  FROM JS_201_CLGRDK B
                 INNER JOIN JS_201_HDACLYLDK D
                    ON D.CJRQ = IS_DATE
                   AND D.FRNBJGH = '990000'
                   AND D.LOAN_NUM <> '0'
                   AND D.FIELD_TYPE = 'T99'
                   AND D.BIZ_TYPE = 'C02'
                   AND D.PENSIDY_TYPE IS NOT NULL
                   AND B.LOAN_NUM = D.LOAN_NUM
                 WHERE B.CJRQ = IS_DATE
                   AND B.FRNBJGH = '990000'
                UNION ALL
                SELECT PENSIDY_TYPE,
                       DISCOUNT_BAL_RMB * INT_RATE AS BALANCE_INT_SUM,
                       DISCOUNT_BAL_RMB AS BALANCE_SUM,
                       DISCOUNT_ID_NO AS GET_LOAN_NUM
                  FROM JS_205_CLPJRZ C
                 INNER JOIN JS_201_HDACLYLDK D
                    ON D.CJRQ = IS_DATE
                   AND D.FRNBJGH = '990000'
                   AND D.LOAN_NUM <> '0'
                   AND D.FIELD_TYPE = 'T99'
                   AND D.BIZ_TYPE = 'C03'
                   AND D.PENSIDY_TYPE IS NOT NULL
                   AND C.BILL_NUM = D.BILL_NUM)
         GROUP BY PENSIDY_TYPE)
--ADD BY ZHOULP 20260129 END_01
union all
----------------------养老贷款发生----------------------
--T01-养老产业贷款汇总
SELECT 'T01_发生养老贷款' tt,NVL(BALANCE_SUM,0),NVL(INT_RATE_WA,0),NVL(GET_LOAN_NUM,0) FROM JS_201_HDAYLDKFS A WHERE A.CJRQ=IS_DATE AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T01'
union all
SELECT 'T01_发生单位/个人/票据贷款' tt,NVL(BALANCE_SUM,0),NVL(ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),0),NVL(GET_LOAN_NUM,0)
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
                           FROM JS_201_HDAYLDKFS D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C01'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  WHERE B.CJRQ = IS_DATE
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAYLDKFS D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C02'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = IS_DATE
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAYLDKFS D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C03'
                            AND C.BILL_NUM = D.BILL_NUM)))
UNION ALL
--T02-全国养老机构贷款汇总
SELECT 'T02_发生养老贷款' tt,NVL(BALANCE_SUM,0),NVL(INT_RATE_WA,0),NVL(GET_LOAN_NUM,0) FROM JS_201_HDAYLDKFS A WHERE A.CJRQ=IS_DATE AND A.FRNBJGH='990000' AND A.FIELD_TYPE='T02'
union all
SELECT 'T02_发生单位/个人/票据贷款' tt,NVL(BALANCE_SUM,0),NVL(ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),0),NVL(GET_LOAN_NUM,0)
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
                           FROM JS_201_HDAYLDKFS D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C01'
              AND D.NURSING_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  WHERE B.CJRQ = IS_DATE
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAYLDKFS D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C02'
              AND D.NURSING_FLG = '1'
                            AND B.LOAN_NUM = D.LOAN_NUM)
                 UNION ALL
                 SELECT DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                  WHERE C.CJRQ = IS_DATE
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01'
                    AND EXISTS (SELECT *
                           FROM JS_201_HDAYLDKFS D
                          WHERE D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C03'
              AND D.NURSING_FLG = '1'
                            AND C.BILL_NUM = D.BILL_NUM)))
union all
--ADD BY ZHOULP 20260129 BEGIN_02
--T03-T14养老产业贷款按分类汇总
SELECT FIELD_TYPE||'_发生养老贷款' tt,NVL(BALANCE_SUM,0),NVL(INT_RATE_WA,0),NVL(GET_LOAN_NUM,0) FROM JS_201_HDAYLDKFS A WHERE A.CJRQ=IS_DATE AND A.FRNBJGH='990000' AND FIELD_TYPE NOT IN('T01','T02','T99')
union all
SELECT CASE
         WHEN PENSIDY_TYPE = 'EC01' THEN
          'T03'
         WHEN PENSIDY_TYPE = 'EC02' THEN
          'T04'
         WHEN PENSIDY_TYPE = 'EC03' THEN
          'T05'
         WHEN PENSIDY_TYPE = 'EC04' THEN
          'T06'
         WHEN PENSIDY_TYPE = 'EC05' THEN
          'T07'
         WHEN PENSIDY_TYPE = 'EC06' THEN
          'T08'
         WHEN PENSIDY_TYPE = 'EC07' THEN
          'T09'
         WHEN PENSIDY_TYPE = 'EC08' THEN
          'T10'
         WHEN PENSIDY_TYPE = 'EC09' THEN
          'T11'
         WHEN PENSIDY_TYPE = 'EC10' THEN
          'T12'
         WHEN PENSIDY_TYPE = 'EC11' THEN
          'T13'
         WHEN PENSIDY_TYPE = 'EC12' THEN
          'T14'
       END || '_发生单位/个人/票据贷款' tt,NVL(BALANCE_SUM,0),NVL(ROUND(BALANCE_INT_SUM / BALANCE_SUM,5),0),NVL(GET_LOAN_NUM,0)
  FROM (        
        SELECT PENSIDY_TYPE,SUM(BALANCE_INT_SUM) AS BALANCE_INT_SUM,
                SUM(BALANCE_SUM) AS BALANCE_SUM,
                COUNT(DISTINCT GET_LOAN_NUM) AS GET_LOAN_NUM
          FROM (SELECT PENSIDY_TYPE,TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_DWDKFS B
                   INNER JOIN JS_201_HDAYLDKFS D
                   ON D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C01'
                            AND B.LOAN_NUM = D.LOAN_NUM
                  WHERE B.CJRQ = IS_DATE
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                 UNION ALL
                 SELECT PENSIDY_TYPE,TRANS_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        TRANS_AMT_RMB AS BALANCE_SUM,
                        CUST_ID_NO AS GET_LOAN_NUM
                   FROM JS_201_GRDKFS B
                  INNER JOIN JS_201_HDAYLDKFS D
                   ON D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.LOAN_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C02'
                            AND B.LOAN_NUM = D.LOAN_NUM
                  WHERE B.CJRQ = IS_DATE
                    AND B.FRNBJGH = '990000' AND B.TRANS_TYPE='1'
                 UNION ALL
                 SELECT PENSIDY_TYPE,DISCOUNT_AMT_RMB * INT_RATE AS BALANCE_INT_SUM,
                        DISCOUNT_AMT_RMB AS BALANCE_SUM,
                        DISCOUNT_ID_NO AS GET_LOAN_NUM
                   FROM JS_205_PJRZFS C
                   INNER JOIN JS_201_HDAYLDKFS D
                   ON D.CJRQ = IS_DATE
                            AND D.FRNBJGH = '990000'
                            AND D.BILL_NUM <> '0'
                            AND D.FIELD_TYPE = 'T99'
                            AND D.BIZ_TYPE='C03'
                            AND C.BILL_NUM = D.BILL_NUM
                  WHERE C.CJRQ = IS_DATE
                    AND C.FRNBJGH = '990000' AND C.TRANS_TYPE='A01')
                    GROUP BY PENSIDY_TYPE)
--ADD BY ZHOULP 20260129 END_02							
)  
where tt like '%单位%'
order by substr(tt,5,2),substr(tt,2,2)    
) ; 
---------------------查明细结束

merge into JS_201_HDACLYLDK a 
using YLDK_spop_tmp b
on (a.cjrq=IS_DATE and a.field_type=b.field_type and b.clorfs='存量')
when matched then
  update set a.balance_sum=b.balance_sum,a.int_rate_wa=b.int_rate_wa,a.get_loan_num=b.get_loan_num
  where a.cjrq=IS_DATE and frnbjgh='990000'  ;

merge into JS_201_HDAYLDKFS a 
using YLDK_spop_tmp b
on (a.cjrq=IS_DATE and a.field_type=b.field_type and b.clorfs='发生')
when matched then
  update set a.balance_sum=b.balance_sum,a.int_rate_wa=b.int_rate_wa,a.get_loan_num=b.get_loan_num
  where a.cjrq=IS_DATE and frnbjgh='990000'  ;