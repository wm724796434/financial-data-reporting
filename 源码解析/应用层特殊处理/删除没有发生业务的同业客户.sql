
----------------------------------------------------------------------------------------------------
-- 文件名: 删除没有发生业务的同业客户.sql
-- 业务域: 应用层特殊处理
----------------------------------------------------------------------------------------------------
DELETE FROM PBOCD.JS_102_TYKHXX A
 WHERE A.CJRQ = $DATA_DATE
   AND FRNBJGH = '990000'
   AND (A.CUST_ID_NO IS NULL OR
       A.CUST_ID_NO NOT IN
       (SELECT DISTINCT B.CONT_PARTY_CODE
           FROM (SELECT DISTINCT C.CONT_PARTY_CODE
                   FROM PBOCD.JS_201_CLTYJD C
                  WHERE C.CJRQ = $DATA_DATE
                    AND FRNBJGH = '990000'
                    AND C.CONT_PARTY_TYPE not in ('C01','C02','Z99') 
                 UNION
                 SELECT DISTINCT D.CONT_PARTY_CODE
                   FROM PBOCD.JS_201_TYJDFS D
                  WHERE D.CJRQ = $DATA_DATE
                    AND FRNBJGH = '990000'
                    AND D.CONT_PARTY_TYPE not in ('C01','C02','Z99')
                 UNION
                 SELECT DISTINCT E.CONT_PARTY_CODE
                   FROM PBOCD.JS_202_CLTYCK E
                  WHERE E.CJRQ = $DATA_DATE
                    AND FRNBJGH = '990000'
                    AND E.CONT_PARTY_TYPE not in ('C01','C02','Z99')
                 UNION
                 SELECT DISTINCT F.CONT_PARTY_CODE
                   FROM PBOCD.JS_202_TYCKFS F
                  WHERE F.CJRQ = $DATA_DATE
                    AND FRNBJGH = '990000'
                    AND F.CONT_PARTY_TYPE not in ('C01','C02','Z99') ) B
          WHERE B.CONT_PARTY_CODE IS NOT NULL));
 