CREATE OR REPLACE PROCEDURE BSP_SP_JS_202_CLGRCK (IS_DATE    IN VARCHAR2,
                                             OI_RETCODE OUT INTEGER,
                                             OI_RETCODE_DEC OUT VARCHAR2) AS
  ------------------------------------------------------------------------------------------------------
  -- ≥ћ–т√ы
  --    SP_JS_202_CLGRCK
  -- ”√ЌЊ:…ъ≥…љ”њЏ±н SP_JS_202_CLGRCK іжЅњЄц»Ћіжњо–≈ѕҐ
  -- ≤ќ э
  --    IS_DATE  д»л±дЅњ£ђіЂ»л≈№≈ъ»’∆Џ
  --    OI_RETCODE  д≥ц±дЅњ£ђ”√јі±к ґіжіҐєэ≥ћ÷і––єэ≥ћ÷– «Јс≥цѕ÷“м≥£
  --
  --–ёЄƒЉ«¬Љ
  --    CAEATE BY ZHOULP AT 20221114 іжњоЄцћеє§…ћїІЌ®єэіжњо»ЋњЌїІја±р≈–ґѕ£ђ”ліыњоµƒЄцћеє§…ћїІ≈–ґѕ≤ї“ї÷¬
  --    MODIFY BY DW AT 20230130 –ёЄƒ„Ґ≤бµЎ«шіъ¬л»° э£ђ”≈ѕ»»°µЎ«шіъ¬л£ђ»зєыќ™њ’љЎ»°…нЈЁ÷§«∞6ќї£ђ„оЇу»°Ћщ‘ЏїъєєµƒµЎ«ш
  --    MODIFY BY DW AT 20230426 –ёЄƒ„Ґ≤бµЎ«шіъ¬л»° э£ђ≈–ґѕ÷§Љюја–ЌЌђ ±≈–ґѕ «Јс¬ъ„г6ќї
  --    –и«у±аЇ≈£ЇJLBA202412270002_єЎ”ЏЈ÷ќц≈≈≤йЉ∞Єƒ‘мљр»Џїщі° эЊЁ»° э¬яЉ≠µƒ–и«у_ґюљ„ґќ …ѕѕя»’∆Џ£Ї2025-05-27£ђ–ёЄƒ»Ћ£Ї÷№ЅҐ≈ф£ђћб≥ц»Ћ£Їјой™   –ёЄƒ‘≠“т£Їћё≥э»°…ѕ∆Џ/≈д÷√±н
  --    –и«у±аЇ≈£ЇJLBA202412270002_єЎ”ЏЈ÷ќц≈≈≤йЉ∞Єƒ‘мљр»Џїщі° эЊЁ»° э¬яЉ≠µƒ–и«у_»эљ„ґќ …ѕѕя»’∆Џ£Ї2025-07-29£ђ–ёЄƒ»Ћ£Ї÷№ЅҐ≈ф£ђћб≥ц»Ћ£Їјой™   –ёЄƒ‘≠“т£Їћё≥э»°…ѕ∆Џ/≈д÷√±н
  --    –и«у±аЇ≈£ЇJLBA202412270002_єЎ”ЏЈ÷ќц≈≈≤йЉ∞Єƒ‘мљр»Џїщі° эЊЁ»° э¬яЉ≠µƒ–и«у_Ћƒљ„ґќ …ѕѕя»’∆Џ£Ї2025-09-18£ђ–ёЄƒ»Ћ£Ї÷№ЅҐ≈ф£ђћб≥ц»Ћ£Їјой™   –ёЄƒ‘≠“т£Їћё≥э»°…ѕ∆Џ/≈д÷√±н
  --    –и«у±аЇ≈£ЇJLBA202601150009 єЎ”Џ2026ƒкЉ™Ѕ÷“ш––»Ћ––іуЉѓ÷–Љ∞љр»Џїщі° эЊЁ≤…ЉѓѕµЌ≥»Ћ––±®±н÷∆ґ»…эЉґµƒѕаєЎ–и«у …ѕѕя»’∆Џ£Ї2026-01-30£ђ–ёЄƒ»Ћ£Ї÷№ЅҐ≈ф£ђћб≥ц»Ћ£Їјой™   –ёЄƒ‘≠“т£Ї÷∆ґ»…эЉґ
  ------------------------------------------------------------------------------------------------------

  VI_ERRORCODE      NUMBER DEFAULT 0; -- э÷µ–Ќ  “м≥£іъ¬л
  VS_TEXT           VARCHAR2(500) DEFAULT NULL; --„÷Јы–Ќ  єэ≥ћ√и ц
  VS_OWNER          VARCHAR2(32) DEFAULT NULL; --„÷Јы–Ќ  іжіҐєэ≥ћµч”√”√їІ
  VS_PROCEDURE_NAME VARCHAR2(32) DEFAULT NULL; --„÷Јы–Ќ  іжіҐєэ≥ћ√ы≥∆
  VS_STEP           VARCHAR2(100); --іжіҐєэ≥ћ÷і––≤љ÷и±к÷Њ
  --NUM               INTEGER;
  --VS_NMONTH         VARCHAR2(10);

BEGIN
  VS_TEXT           := TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD');
  --VS_NMONTH         := TO_CHAR(TRUNC(TO_DATE(IS_DATE, 'YYYYMMDD') + 1), 'YYYYMMDD');
  -- Љ«¬Љ»’÷Њ є”√
  SELECT T.USERNAME INTO VS_OWNER FROM SYS.USER_USERS T;
  VS_PROCEDURE_NAME := 'SP_JS_202_CLGRCK';
  -- њ™ Љ»’÷Њ
  VS_STEP := 'START';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
  -------------------------------------------------------------------------

/*  --≤йњі¬дµЎ±н «Јс“—Њ≠љ®ЅҐЈ÷«ш
  SELECT COUNT(1)
    INTO NUM
    FROM USER_TAB_PARTITIONS
   WHERE TABLE_NAME = 'PBOCD_JS_202_CLGRCK_TMP'
     AND PARTITION_NAME = 'P' || IS_DATE;

  --»зєы√ї”–љ®ЅҐЈ÷«ш£ђ‘т‘цЉ”Ј÷«ш
  IF (NUM = 0) THEN
    EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_DATACORE.PBOCD_JS_202_CLGRCK_TMP ADD PARTITION P' ||
                      IS_DATE || ' VALUES LESS THAN (' || VS_NMONTH || ')';
  END IF;

    EXECUTE IMMEDIATE 'ALTER TABLE PBOCD_DATACORE.PBOCD_JS_202_CLGRCK_TMP TRUNCATE PARTITION P' ||
                    IS_DATE;*/
                    
 SP_PBOCD_PARTITIONS(IS_DATE,'PBOCD_JS_202_CLGRCK',OI_RETCODE);

  VS_STEP := '1.Єцћеє§…ћїІіжњо”аґо';
  INSERT INTO PBOCD_JS_202_CLGRCK (
         DATA_DATE,  -- эЊЁ»’∆Џ
         ORG_CODE,   --љр»Џїъєєіъ¬л
         ORG_NUM,   --ƒЏ≤њїъєєЇ≈
         CUST_ID_TYPE,   --њЌїІ÷§Љюја–Ќ
         CUST_ID_NO,   --њЌїІ÷§Љюіъ¬л
         REG_REGION_CODE,   --њЌїІЊ”„°µЎ––’ю«шїЃіъ¬л
         DEP_ACC_CODE,   --іжњо’ЋїІіъ¬л
         DEP_AGR_CODE,   --іжњо–≠“йіъ¬л
         PRODUCT_TYPE,   --іжњо≤ъ∆Јја±р
         CON_BGN_DATE,   --іжњо–≠“й∆р Љ»’∆Џ
         CON_DUE_DATE,   --іжњо–≠“йµљ∆Џ»’∆Џ
         CURR_CODE,   --іжњо±“÷÷
         BALANCE,   --іжњо”аґо
         BALANCE_RMB,   --іжњо”аґо’џ»Ћ√с±“
         INT_RATE,   --јы¬ ЋЃ∆љ
         DEPOSIT_RESERVE_METHOD,   --љ…іж„Љ±ЄљрЈљ љ
         
         --[2026-01-30] [÷№ЅҐ≈ф] [JLBA202601150009 єЎ”Џ2026ƒкЉ™Ѕ÷“ш––»Ћ––іуЉѓ÷–Љ∞љр»Џїщі° эЊЁ≤…ЉѓѕµЌ≥»Ћ––±®±н÷∆ґ»…эЉґµƒѕаєЎ–и«у][јой™] –¬‘ц±®ЋЌ„÷ґќ
         FINI_REGION_CODE,   --љр»ЏїъєєµЎ«шіъ¬л
         DEP_ACC_TYPE,   --іжњо’ЋїІја–Ќ
         DEP_STATUS,   --іжњо„іћђ
         
         REPORT_ID,   --±®±нID
         CJRQ,   --≤…Љѓ»’∆Џ
         NBJGH,   --ƒЏ≤њїъєєЇ≈
         BIZ_LINE_ID,   --“µќсћхѕя
         VERIFY_STATUS,   --–£—й„іћђ
         BSCJRQ,   --±®ЋЌ≤…Љѓ»’∆Џ
         FRNBJGH,   --Ј®»ЋƒЏ≤њїъєєЇ≈
         CUST_ID, --њЌїІЇ≈
         CUST_NAME  --њЌїІ√ы
   )
  --ґ‘єЂњЌїІ±нµƒЄцћеє§…ћїІ£®іжњо£©
  SELECT /*+PARALLEL(4)*/
         TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD') DATA_DATE, -- эЊЁ»’∆Џ
         NVL(OB.ID_NO,OB.UP_ID_NO) AS  ORG_CODE, --љр»Џїъєєіъ¬л
         A.ORG_NUM ORG_NUM, --ƒЏ≤њїъєєЇ≈

         (CASE WHEN B.LEGAL_CARD_TYPE IS NULL AND LENGTH(B.LEGAL_CARD_NO)=18
                    AND SUBSTR(B.LEGAL_CARD_NO,7,8) BETWEEN '19000101' AND '21001231'
                 THEN 'B01'
               ELSE F.PBOCD_CODE END) AS CUST_ID_TYPE, --њЌїІ÷§Љюја–Ќ
         NVL(B.LEGAL_CARD_NO,B.ID_NO) AS CUST_ID_NO, --њЌїІ÷§Љюіъ¬л

         --[2025-12-30] [÷№ЅҐ≈ф] [JLBA202509240002_єЎ”Џљр»Џїщі° эЊЁѕµЌ≥»° э¬яЉ≠Єƒ‘мЉ∞÷ќјн≥£ћђїѓљ®…иµƒ–и«у_“їљ„ґќ][јой™] ћё≥эћЎ ві¶јн
         --NVL(B.REGION_CD,B.ORG_AREA) AS REG_REGION_CODE, --њЌїІµЎ«шіъ¬л
         CASE
           WHEN LENGTH(TRIM(B.REGION_CD)) = 6 AND B.REGION_CD NOT LIKE '000%' AND B.REGION_CD <> '999999' THEN TRIM(B.REGION_CD)--њЌїІЋщ фµЎ«ш
           WHEN LENGTH(TRIM(B.ORG_AREA)) = 6 AND B.ORG_AREA NOT LIKE '000%' AND B.ORG_AREA <> '999999' THEN TRIM(B.ORG_AREA)--„°ЋщїтЊ≠”™Ћщ‘ЏµЎ––’ю«шїЃ
           WHEN B.LEGAL_CARD_TYPE IS NULL AND LENGTH(B.LEGAL_CARD_NO)=18 AND SUBSTR(B.LEGAL_CARD_NO,7,8) BETWEEN '19000101' AND '21001231' THEN SUBSTR(B.LEGAL_CARD_NO,1,6)--Ј®»Ћ…нЈЁ÷§Ї≈«∞6ќї
           WHEN LENGTH(TRIM(OB.REGION_CD)) = 6 AND OB.REGION_CD NOT LIKE '000%' AND OB.REGION_CD <> '999999' THEN TRIM(OB.REGION_CD)--њЌїІЋщ фїъєєµЎ«ш
         END AS REG_REGION_CODE, --њЌїІµЎ«шіъ¬л
         
         A.O_ACCT_NUM DEP_ACC_CODE, --іжњо’ЋїІ±а¬л
         A.O_ACCT_NUM DEP_AGR_CODE, --іжњо–≠“й±а¬л

         CASE WHEN A.GL_ITEM_CODE IN ('20110201', '22410101') THEN 'D013' --Єц»Ћїо∆Џ
              
              --[2025-09-18] [÷№ЅҐ≈ф] [JLBA202412270002_єЎ”ЏЈ÷ќц≈≈≤йЉ∞Єƒ‘мљр»Џїщі° эЊЁ»° э¬яЉ≠µƒ–и«у_Ћƒљ„ґќ][јой™] –ёЄƒґ®„™їоєж‘т
              --WHEN A.GL_ITEM_CODE IN ('20110202', '20110203') AND TO_CHAR(A.MATUR_DATE, 'YYYYMMDD') < IS_DATE THEN 'D013'--Єц»Ћїо∆Џ --µљ∆Џќі÷І»°µƒґ®∆Џ≤ъ∆ЈЄƒќ™їо∆Џ zhoulp20231205
              WHEN A.GL_ITEM_CODE IN ('20110202', '20110203') AND TO_CHAR(A.MATUR_DATE, 'YYYYMMDD') <= IS_DATE THEN 'D013'--Єц»Ћїо∆Џ --µљ∆Џќі÷І»°µƒґ®∆Џ≤ъ∆ЈЄƒќ™їо∆Џ zhoulp20231205
              
              WHEN A.GL_ITEM_CODE IN ('20110202', '20110203') THEN 'D014' --Єц»Ћґ®∆Џ
        WHEN A.ACCT_TYPE IN ('0401', '0402') THEN 'D03' --Єц»ЋЌ®÷™
              WHEN A.GL_ITEM_CODE IN ('20110204', '20110211') THEN 'D04' --Єц»Ћ–≠“йіжњо
              --WHEN A.GL_ITEM_CODE IN ('20110207', '21903') THEN 'D08' --Єц»Ћљбєє–‘іжњо--…Њ≥э
              WHEN A.GL_ITEM_CODE IN ('20110209','20110210') THEN 'D069'--20231115wxb±£÷§љріжњо
         END AS PRODUCT_TYPE, --іжњо≤ъ∆Јја±р
         --TO_CHAR(A.ACCT_OPDATE, 'YYYY-MM-DD') CON_BGN_DATE, --іжњо–≠“й∆р Љ»’∆Џ
         CASE WHEN (TO_CHAR(A.ST_INT_DT, 'YYYY-MM-DD')='1900-01-01'
           OR A.ST_INT_DT IS NULL)
            THEN
                 TO_CHAR(A.ACCT_OPDATE, 'YYYY-MM-DD')
            ELSE TO_CHAR(A.ST_INT_DT, 'YYYY-MM-DD')
         END CON_BGN_DATE, --іжњо–≠“й∆р Љ»’∆Џ
         CASE /*WHEN A.ACCT_TYPE IN ('0401', '0402') THEN \*Ќ®÷™іжњо∞іЈҐќƒ“™«ућЎ ві¶јн*\
              (CASE WHEN A.INT_RATE = 0.8 THEN '1999-01-01'
               ELSE '1999-01-07' END)*/
              WHEN A.ACCT_TYPE ='0401' THEN '1999-01-01'
              WHEN A.ACCT_TYPE ='0402' THEN '1999-01-07'--zhoulp20240410 –и«уJLBA202401240008
                
              --[2025-09-18] [÷№ЅҐ≈ф] [JLBA202412270002_єЎ”ЏЈ÷ќц≈≈≤йЉ∞Єƒ‘мљр»Џїщі° эЊЁ»° э¬яЉ≠µƒ–и«у_Ћƒљ„ґќ][јой™] –ёЄƒґ®„™їоєж‘т
              --WHEN A.GL_ITEM_CODE IN ('20110202', '20110203') AND TO_CHAR(A.MATUR_DATE, 'YYYYMMDD') < IS_DATE THEN
              WHEN A.GL_ITEM_CODE IN ('20110202', '20110203',--µљ∆Џќі÷І»°µƒґ®∆Џ≤ъ∆ЈЄƒќ™їо∆Џ£ђµљ∆Џ»’ћо99991231 zhoulp20231205
                                      '20110209','20110210' --±£÷§љріжњоµљ∆Џќі»°µƒ£ђµљ∆Џ»’Є≥÷µ99991231
                                     ) AND TO_CHAR(A.MATUR_DATE, 'YYYYMMDD') <= IS_DATE THEN
                '9999-12-31'
         ELSE NVL(TO_CHAR(A.MATUR_DATE, 'YYYY-MM-DD'), '9999-12-31') END CON_DUE_DATE, --іжњо–≠“йµљ∆Џ»’∆Џ
         A.CURR_CD AS CURR_CODE, --±“÷÷
         A.ACCT_BALANCE AS BALANCE, --іжњо”аґо
         A.ACCT_BALANCE * c.CCY_RATE AS BALANCE_RMB, --іжњо”аґо’џ»Ћ√с±“

         --[2025-09-18] [÷№ЅҐ≈ф] [JLBA202412270002_єЎ”ЏЈ÷ќц≈≈≤йЉ∞Єƒ‘мљр»Џїщі° эЊЁ»° э¬яЉ≠µƒ–и«у_Ћƒљ„ґќ][јой™] –ёЄƒґ®„™їоєж‘т
         /*CASE
           WHEN A.GL_ITEM_CODE IN ('20110202', '20110203','20110103','20110104','20110105','20110106','20110107','20110108','20110109','20110113')
             AND TO_CHAR(A.MATUR_DATE, 'YYYYMMDD') < IS_DATE
             AND A.INT_RATE >=0.8 THEN 0.05000--Єц»Ћїо∆Џ --µљ∆Џќі÷І»°µƒґ®∆Џ≤ъ∆Јјы¬ Єƒќ™0.05000  --[2025/05/30] [∞„—о] ”¶јой™“™«у0.95Єƒ≥…0.8
           ELSE A.INT_RATE
          END INT_RATE, --јы¬ ЋЃ∆љ*/
          A.INT_RATE AS INT_RATE, --јы¬ ЋЃ∆љ
         
         --[2025-07-29] [÷№ЅҐ≈ф] [JLBA202412270002_єЎ”ЏЈ÷ќц≈≈≤йЉ∞Єƒ‘мљр»Џїщі° эЊЁ»° э¬яЉ≠µƒ–и«у_»эљ„ґќ][јой™] ќƒЉюєж‘т£Ї2005єйјаµљDR02-»Ђґољ…іж£ђќƒЉю…ѕ∆дЋыњ∆ƒњєйјаµљDR03-±»јэљ…іж
         --NVL(A.RESERVE_DEPO_TYPE, 'DR03') AS DEPOSIT_RESERVE_METHOD, --љ…іж„Љ±ЄљрЈљ љ
         'DR03' AS DEPOSIT_RESERVE_METHOD, --љ…іж„Љ±ЄљрЈљ љ  --2011°Ґ224101єйјаµљDR03-±»јэљ…іж
         
         --[2026-01-30] [÷№ЅҐ≈ф] [JLBA202601150009 єЎ”Џ2026ƒкЉ™Ѕ÷“ш––»Ћ––іуЉѓ÷–Љ∞љр»Џїщі° эЊЁ≤…ЉѓѕµЌ≥»Ћ––±®±н÷∆ґ»…эЉґµƒѕаєЎ–и«у][јой™] –¬‘ц±®ЋЌ„÷ґќ
         CASE WHEN LENGTH(TRIM(OB.REGION_CD)) = 6 AND OB.REGION_CD NOT LIKE '000%' AND OB.REGION_CD <> '999999' THEN TRIM(OB.REGION_CD) END AS FINI_REGION_CODE,   --љр»ЏїъєєµЎ«шіъ¬л
         DECODE(A.DEMAND_DEPOSIT_TYPE,'A','A01','B','A02','C','A03','A99') AS DEP_ACC_TYPE,   --іжњо’ЋїІја–Ќ A01-Єц»ЋҐсјаљбЋг’ЋїІ A02-Єц»ЋҐтјаљбЋг’ЋїІ A03-Єц»ЋҐујаљбЋг’ЋїІ A99-∆дЋыЄц»ЋЈ«љбЋгіжњо’ЋїІ
         E.PBOCD_CODE AS DEP_STATUS,   --іжњо„іћђ DS01-’э≥£ DS02-–Ё√я DS03-ѕё÷∆ DS04-ѕъїІ DS99-∆дЋы
         
         --zhoulp20251230  эЊЁЉмЇЋѕµЌ≥”√”Џ«шЈ÷Єцћеє§…ћїІ
         'GTGSH-'||SYS_GUID() REPORT_ID, --±®ЋЌID
         IS_DATE CJRQ, --≤…Љѓ»’∆Џ
         A.ORG_NUM NBJGH, --ƒЏ≤њїъєєЇ≈
         '99' BIZ_LINE_ID, --“µќсћхѕя
         '' VERIFY_STATUS, --–£—й„іћђ
         '' BSCJRQ, --±®ЋЌ÷№∆Џ
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
            '600000'----20231013Ќхѕю±т
           ELSE '990000'
             END FRNBJGH,

         A.CUST_ID, --њЌїІЇ≈
         NVL(B.LEGAL_NAME,B.CUST_NAM) --њЌїІ√ы≥∆
  FROM SMTMODS.L_ACCT_DEPOSIT A
  LEFT JOIN SMTMODS.L_PUBL_RATE c --їг¬ ±н
  ON A.CURR_CD = c.BASIC_CCY --’ЋїІ±“÷÷
  AND c.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD') --їг¬ »’∆Џ
  AND A.DATA_DATE = c.DATA_DATE
  AND c.FORWARD_CCY = 'CNY' --’џЋг±“÷÷
  INNER JOIN SMTMODS.L_CUST_C B
  ON A.CUST_ID = B.CUST_ID
  AND B.DATA_DATE = IS_DATE
  AND B.DEPOSIT_CUSTTYPE IN ('13', '14') --Єцћеє§…ћїІ
/*  AND A.ACCT_TYPE NOT LIKE '07%' --±£÷§љріжњо≤ї«шЈ÷Єцћеє§…ћїІ ≤ќ’’іуЉѓ÷–
*/  --20240111ћнЉ”Єцћеє§…ћїІ±£÷§љр≤њЈ÷
  LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY F --Љ”є§‘±є§÷§Љюја–Ќ
  ON NVL2(B.LEGAL_CARD_NO,B.LEGAL_CARD_TYPE,B.ID_TYPE) = F.L_CODE
  AND F.CODE_CLMN_NAME = 'ID_TYPE'
  
  LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E --іжњо„іћђ
  ON A.ACCT_STS = E.L_CODE
  AND E.CODE_CLMN_NAME = 'ACCT_STS'
  
  --[2025-12-30] [÷№ЅҐ≈ф] [JLBA202509240002_єЎ”Џљр»Џїщі° эЊЁѕµЌ≥»° э¬яЉ≠Єƒ‘мЉ∞÷ќјн≥£ћђїѓљ®…иµƒ–и«у_“їљ„ґќ][јой™] ћё≥эћЎ ві¶јн
  LEFT JOIN L_PUBL_ORG_BRA_TMP OB--љр эїъєє±н
  ON OB.ORG_NUM=A.ORG_NUM AND OB.DATA_DATE=IS_DATE
  
  WHERE A.DATA_DATE = IS_DATE
  AND A.ACCT_BALANCE <> 0

  AND (A.GL_ITEM_CODE = '20110201' OR --Єц»Ћїо∆Џ
       A.GL_ITEM_CODE = '22410101' OR --Њ√–ьїІ
       A.GL_ITEM_CODE IN ('20110202', '20110203') OR --Єц»Ћґ®∆Џ
       A.ACCT_TYPE IN ('0401', '0402') OR--Єц»ЋЌ®÷™
       A.GL_ITEM_CODE IN ('20110204', '20110211') --Єц»Ћ–≠“йіжњо
       --A.GL_ITEM_CODE IN ('20110207', '21903') --Єц»Ћљбєє–‘іжњо--…Њ≥э
       OR A.GL_ITEM_CODE IN ('20110209','20110210')--20231115WXBЄц»ЋћнЉ”±£÷§љр
  )
  ;
  commit;
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

  VS_STEP := '2.іжЅњЄц»Ћіжњо';
  --Єц»Ћіжњо
  INSERT INTO PBOCD_JS_202_CLGRCK (
         DATA_DATE,  -- эЊЁ»’∆Џ
         ORG_CODE,   --љр»Џїъєєіъ¬л
         ORG_NUM,   --ƒЏ≤њїъєєЇ≈
         CUST_ID_TYPE,   --њЌїІ÷§Љюја–Ќ
         CUST_ID_NO,   --њЌїІ÷§Љюіъ¬л
         REG_REGION_CODE,   --њЌїІЊ”„°µЎ––’ю«шїЃіъ¬л
         DEP_ACC_CODE,   --іжњо’ЋїІіъ¬л
         DEP_AGR_CODE,   --іжњо–≠“йіъ¬л
         PRODUCT_TYPE,   --іжњо≤ъ∆Јја±р
         CON_BGN_DATE,   --іжњо–≠“й∆р Љ»’∆Џ
         CON_DUE_DATE,   --іжњо–≠“йµљ∆Џ»’∆Џ
         CURR_CODE,   --іжњо±“÷÷
         BALANCE,   --іжњо”аґо
         BALANCE_RMB,   --іжњо”аґо’џ»Ћ√с±“
         INT_RATE,   --јы¬ ЋЃ∆љ
         DEPOSIT_RESERVE_METHOD,   --љ…іж„Љ±ЄљрЈљ љ
         
         --[2026-01-30] [÷№ЅҐ≈ф] [JLBA202601150009 єЎ”Џ2026ƒкЉ™Ѕ÷“ш––»Ћ––іуЉѓ÷–Љ∞љр»Џїщі° эЊЁ≤…ЉѓѕµЌ≥»Ћ––±®±н÷∆ґ»…эЉґµƒѕаєЎ–и«у][јой™] –¬‘ц±®ЋЌ„÷ґќ
         FINI_REGION_CODE,   --љр»ЏїъєєµЎ«шіъ¬л
         DEP_ACC_TYPE,   --іжњо’ЋїІја–Ќ
         DEP_STATUS,   --іжњо„іћђ
         
         REPORT_ID,   --±®±нID
         CJRQ,   --≤…Љѓ»’∆Џ
         NBJGH,   --ƒЏ≤њїъєєЇ≈
         BIZ_LINE_ID,   --“µќсћхѕя
         VERIFY_STATUS,   --–£—й„іћђ
         BSCJRQ,   --±®ЋЌ≤…Љѓ»’∆Џ
         FRNBJGH,   --Ј®»ЋƒЏ≤њїъєєЇ≈
         CUST_ID, --њЌїІЇ≈
         CUST_NAME  --њЌїІ√ы
   )
  SELECT /*+PARALLEL(4)*/
         TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD') DATA_DATE, -- эЊЁ»’∆Џ
         NVL(OB.ID_NO,OB.UP_ID_NO) AS ORG_CODE, --љр»Џїъєєіъ¬л
         A.ORG_NUM ORG_NUM, --ƒЏ≤њїъєєЇ≈
         F.PBOCD_CODE AS CUST_ID_TYPE, --њЌїІ÷§Љюја–Ќ
         C.ID_NO AS CUST_ID_NO, --њЌїІ÷§Љюіъ¬л
         
         --[2025-12-30] [÷№ЅҐ≈ф] [JLBA202509240002_єЎ”Џљр»Џїщі° эЊЁѕµЌ≥»° э¬яЉ≠Єƒ‘мЉ∞÷ќјн≥£ћђїѓљ®…иµƒ–и«у_“їљ„ґќ][јой™] ћё≥эћЎ ві¶јн
         /*CASE WHEN LENGTH(TRIM(C.REGION_CD)) = 6 THEN C.REGION_CD
              WHEN F.PBOCD_CODE IN ('B01','B08') AND LENGTH(TRIM(C.ID_NO)) = 18 THEN SUBSTR(C.ID_NO,1,6)
         END REG_REGION_CODE, --њЌїІµЎ«шіъ¬л(”≈ѕ»»°µЎ«шіъ¬л£ђ»зєыµЎ«шіъ¬лќ™њ’£ђ»°…нЈЁ÷§Ї≈«∞6ќї)*/
         CASE 
           WHEN LENGTH(TRIM(C.REGION_CD)) = 6 AND C.REGION_CD NOT LIKE '000%' AND C.REGION_CD <> '999999' THEN TRIM(C.REGION_CD)--њЌїІЋщ фµЎ«ш
           WHEN F.PBOCD_CODE IN ('B01','B08') AND LENGTH(TRIM(C.ID_NO)) = 18 THEN SUBSTR(C.ID_NO,1,6)--…нЈЁ÷§Ї≈«∞6ќї
           WHEN LENGTH(TRIM(OB.REGION_CD)) = 6 AND OB.REGION_CD NOT LIKE '000%' AND OB.REGION_CD <> '999999' THEN TRIM(OB.REGION_CD)--њЌїІЋщ фїъєєµЎ«ш
         END AS REG_REGION_CODE, --њЌїІµЎ«шіъ¬л
         
         A.O_ACCT_NUM DEP_ACC_CODE, --іжњо’ЋїІ±а¬л
         A.O_ACCT_NUM DEP_AGR_CODE, --іжњо–≠“й±а¬л
         CASE WHEN A.GL_ITEM_CODE IN ('20110101','22410102') THEN 'D013' --Єц»Ћїо∆Џіжњо
              WHEN A.GL_ITEM_CODE IN ('20110103','20110104','20110105','20110106','20110107','20110108','20110109','20110113')
              
              --[2025-09-18] [÷№ЅҐ≈ф] [JLBA202412270002_єЎ”ЏЈ÷ќц≈≈≤йЉ∞Єƒ‘мљр»Џїщі° эЊЁ»° э¬яЉ≠µƒ–и«у_Ћƒљ„ґќ][јой™] –ёЄƒґ®„™їоєж‘т
              --AND TO_CHAR(A.MATUR_DATE, 'YYYYMMDD') < IS_DATE THEN 'D013'--Єц»Ћїо∆Џ --µљ∆Џќі÷І»°µƒґ®∆Џ°Ґіуґоіжµ•≤ъ∆ЈЄƒќ™їо∆Џ zhoulp20231205
              AND TO_CHAR(A.MATUR_DATE, 'YYYYMMDD') <= IS_DATE THEN 'D013'--Єц»Ћїо∆Џ --µљ∆Џќі÷І»°µƒґ®∆Џ°Ґіуґоіжµ•≤ъ∆ЈЄƒќ™їо∆Џ zhoulp20231205
              
              WHEN A.GL_ITEM_CODE IN ('20110103','20110104','20110105','20110106','20110107','20110108','20110109')
                   THEN 'D014' --Єц»Ћґ®∆Џіжњо
              WHEN A.GL_ITEM_CODE = '20110110' THEN 'D03' --Єц»ЋЌ®÷™іжњо
              WHEN A.ACCT_TYPE = '0701' THEN 'D061' --“ш––≥–ґ“їг∆±±£÷§љріжњо
              WHEN A.ACCT_TYPE = '0702' THEN 'D062' --–≈”√÷§±£÷§љріжњо
              WHEN A.ACCT_TYPE = '0703' THEN 'D063' --±£Їѓ±£÷§љріжњо
              WHEN A.ACCT_TYPE = '0707' THEN 'D065' --–≈”√њ®±£÷§љріжњо
              WHEN (A.ACCT_TYPE LIKE '07%' OR A.GL_ITEM_CODE IN ('20110114','20110115')) THEN 'D069' --∆дЋы±£÷§љріжњо
              WHEN A.GL_ITEM_CODE = '20110102' THEN 'D02' --ґ®їоЅљ±г
              WHEN A.GL_ITEM_CODE = '20110113' THEN 'D16' --іуґоіжµ•
         END AS PRODUCT_TYPE, --іжњо≤ъ∆Јја±р

         --TO_CHAR(A.ACCT_OPDATE, 'YYYY-MM-DD') CON_BGN_DATE, --іжњо–≠“й∆р Љ»’∆Џ
         CASE WHEN (TO_CHAR(A.ST_INT_DT, 'YYYY-MM-DD')='1900-01-01'
           OR A.ST_INT_DT IS NULL)
            THEN
                 TO_CHAR(A.ACCT_OPDATE, 'YYYY-MM-DD')
            ELSE TO_CHAR(A.ST_INT_DT, 'YYYY-MM-DD')
         END CON_BGN_DATE, --іжњо–≠“й∆р Љ»’∆Џ

         CASE /*WHEN A.ACCT_TYPE IN ('0401', '0402') THEN \*Ќ®÷™іжњо∞іЈҐќƒ“™«ућЎ ві¶јн*\
              (CASE WHEN A.INT_RATE = 0.8 THEN '1999-01-01' ELSE '1999-01-07' END)*/
              WHEN A.ACCT_TYPE ='0401' THEN '1999-01-01'
              WHEN A.ACCT_TYPE ='0402' THEN '1999-01-07'--zhoulp20240410 –и«уJLBA202401240008
              WHEN A.GL_ITEM_CODE IN ('20110103','20110104','20110105','20110106','20110107','20110108','20110109','20110113')
                
              --[2025-09-18] [÷№ЅҐ≈ф] [JLBA202412270002_єЎ”ЏЈ÷ќц≈≈≤йЉ∞Єƒ‘мљр»Џїщі° эЊЁ»° э¬яЉ≠µƒ–и«у_Ћƒљ„ґќ][јой™] –ёЄƒґ®„™їоєж‘т
              --     AND NVL(TO_CHAR(A.MATUR_DATE, 'YYYYMMDD'),'99991231') < IS_DATE THEN
                   AND NVL(TO_CHAR(A.MATUR_DATE, 'YYYYMMDD'),'99991231') <= IS_DATE THEN
                 '9999-12-31'--µљ∆Џќі÷І»°µƒґ®∆Џ°Ґіуґоіжµ•≤ъ∆ЈЄƒќ™їо∆Џ£ђµљ∆Џ»’ћо99991231 zhoulp20231205
                 
              --[2025-09-18] [÷№ЅҐ≈ф] [JLBA202412270002_єЎ”ЏЈ÷ќц≈≈≤йЉ∞Єƒ‘мљр»Џїщі° эЊЁ»° э¬яЉ≠µƒ–и«у_Ћƒљ„ґќ][јой™] –ёЄƒґ®„™їоєж‘т
              --WHEN (A.ACCT_TYPE like '07%' OR A.GL_ITEM_CODE IN('20110114','20110115')) AND NVL(TO_CHAR(A.MATUR_DATE, 'YYYYMMDD'),'99991231') < IS_DATE THEN
              WHEN (A.ACCT_TYPE like '07%' OR A.GL_ITEM_CODE IN('20110114','20110115')) AND NVL(TO_CHAR(A.MATUR_DATE, 'YYYYMMDD'),'99991231') <= IS_DATE THEN
                 '9999-12-31'--±£÷§љріжњоµљ∆Џќі»°µƒ£ђµљ∆Џ»’Є≥÷µ99991231
         ELSE NVL(TO_CHAR(A.MATUR_DATE, 'YYYY-MM-DD'), '9999-12-31')
         END CON_DUE_DATE, --іжњо–≠“йµљ∆Џ»’∆Џ
         A.CURR_CD AS CURR_CODE, --±“÷÷
         A.ACCT_BALANCE AS BALANCE, --іжњо”аґо
         A.ACCT_BALANCE * B.CCY_RATE AS BALANCE_RMB, --іжњо”аґо’џ»Ћ√с±“
         
         --[2025-09-18] [÷№ЅҐ≈ф] [JLBA202412270002_єЎ”ЏЈ÷ќц≈≈≤йЉ∞Єƒ‘мљр»Џїщі° эЊЁ»° э¬яЉ≠µƒ–и«у_Ћƒљ„ґќ][јой™] –ёЄƒґ®„™їоєж‘т
         /*CASE
           WHEN A.GL_ITEM_CODE IN ('20110202', '20110203','20110103','20110104','20110105','20110106','20110107','20110108','20110109','20110113')
             AND TO_CHAR(A.MATUR_DATE, 'YYYYMMDD') < IS_DATE
             AND A.INT_RATE >=0.8 THEN 0.05000--Єц»Ћїо∆Џ --µљ∆Џќі÷І»°µƒґ®∆Џ≤ъ∆Јјы¬ Єƒќ™0.05000  --[2025/05/30] [∞„—о] ”¶јой™“™«у0.95Єƒ≥…0.8
           ELSE A.INT_RATE
          END INT_RATE, --јы¬ ЋЃ∆љ*/
          A.INT_RATE AS INT_RATE, --јы¬ ЋЃ∆љ
         
         --[2025-07-29] [÷№ЅҐ≈ф] [JLBA202412270002_єЎ”ЏЈ÷ќц≈≈≤йЉ∞Єƒ‘мљр»Џїщі° эЊЁ»° э¬яЉ≠µƒ–и«у_»эљ„ґќ][јой™] ќƒЉюєж‘т£Ї2005єйјаµљDR02-»Ђґољ…іж£ђќƒЉю…ѕ∆дЋыњ∆ƒњєйјаµљDR03-±»јэљ…іж
         --NVL(A.RESERVE_DEPO_TYPE, 'DR03') AS DEPOSIT_RESERVE_METHOD, --љ…іж„Љ±ЄљрЈљ љ
         'DR03' AS DEPOSIT_RESERVE_METHOD, --љ…іж„Љ±ЄљрЈљ љ  ∞іќƒЉюі¶јн£ђ2011°Ґ224101єйјаµљDR03-±»јэљ…іж
         
         --[2026-01-30] [÷№ЅҐ≈ф] [JLBA202601150009 єЎ”Џ2026ƒкЉ™Ѕ÷“ш––»Ћ––іуЉѓ÷–Љ∞љр»Џїщі° эЊЁ≤…ЉѓѕµЌ≥»Ћ––±®±н÷∆ґ»…эЉґµƒѕаєЎ–и«у][јой™] –¬‘ц±®ЋЌ„÷ґќ
         CASE WHEN LENGTH(TRIM(OB.REGION_CD)) = 6 AND OB.REGION_CD NOT LIKE '000%' AND OB.REGION_CD <> '999999' THEN TRIM(OB.REGION_CD) END AS FINI_REGION_CODE,   --љр»ЏїъєєµЎ«шіъ¬л
         DECODE(A.DEMAND_DEPOSIT_TYPE,'A','A01','B','A02','C','A03','A99') AS DEP_ACC_TYPE,   --іжњо’ЋїІја–Ќ A01-Єц»ЋҐсјаљбЋг’ЋїІ A02-Єц»ЋҐтјаљбЋг’ЋїІ A03-Єц»ЋҐујаљбЋг’ЋїІ A99-∆дЋыЄц»ЋЈ«љбЋгіжњо’ЋїІ
         E.PBOCD_CODE AS DEP_STATUS,   --іжњо„іћђ DS01-’э≥£ DS02-–Ё√я DS03-ѕё÷∆ DS04-ѕъїІ DS99-∆дЋы
         
         SYS_GUID() REPORT_ID, --±®ЋЌID
         IS_DATE CJRQ, --≤…Љѓ»’∆Џ
         A.ORG_NUM NBJGH, --ƒЏ≤њїъєєЇ≈
         '99' BIZ_LINE_ID, --“µќсћхѕя
         '' VERIFY_STATUS, --–£—й„іћђ
         '' BSCJRQ, --±®ЋЌ÷№∆Џ
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
            '600000'----20231013Ќхѕю±т
           ELSE '990000'
             END FRNBJGH,
          A.CUST_ID, --њЌїІЇ≈
         C.CUST_NAM --њЌїІ√ы≥∆
  FROM SMTMODS.L_ACCT_DEPOSIT A
  left JOIN PBOCD_DATACORE.L_CUST_P_NEW C --Єц»ЋЉ∞Єцћеє§…ћїІњЌїІ±н
  ON A.CUST_ID = C.CUST_ID
  AND C.DATA_DATE = IS_DATE
  LEFT JOIN SMTMODS.L_PUBL_RATE B --їг¬ ±н
  ON A.CURR_CD = B.BASIC_CCY --’ЋїІ±“÷÷
  AND B.CCY_DATE = TO_DATE(IS_DATE, 'YYYYMMDD') --їг¬ »’∆Џ
  AND A.DATA_DATE = B.DATA_DATE
  AND B.FORWARD_CCY = 'CNY' --’џЋг±“÷÷
  LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY F --Љ”є§‘±є§÷§Љюја–Ќ
  ON C.ID_TYPE = F.L_CODE
  AND F.CODE_CLMN_NAME = 'ID_TYPE'
  
  LEFT JOIN PBOCD_DATACORE.L_CODE_DICTIONARY E --іжњо„іћђ
  ON A.ACCT_STS = E.L_CODE
  AND E.CODE_CLMN_NAME = 'ACCT_STS'
  
  --[2025-12-30] [÷№ЅҐ≈ф] [JLBA202509240002_єЎ”Џљр»Џїщі° эЊЁѕµЌ≥»° э¬яЉ≠Єƒ‘мЉ∞÷ќјн≥£ћђїѓљ®…иµƒ–и«у_“їљ„ґќ][јой™] ћё≥эћЎ ві¶јн
  LEFT JOIN L_PUBL_ORG_BRA_TMP OB--љр эїъєє±н
  ON OB.ORG_NUM=A.ORG_NUM AND OB.DATA_DATE=IS_DATE
  
  WHERE A.DATA_DATE = IS_DATE
  AND (A.GL_ITEM_CODE IN ('20110101') OR --Єц»Ћїо∆Џіжњо
       A.GL_ITEM_CODE IN ('22410102') OR --Њ√–ьїІ
       A.GL_ITEM_CODE IN ('20110103','20110104','20110105','20110106','20110107','20110108','20110109') OR --Єц»Ћґ®∆Џіжњо
       A.GL_ITEM_CODE = '20110110' OR --Єц»ЋЌ®÷™іжњо
       A.GL_ITEM_CODE IN ('20110114','20110115') OR --Єц»Ћ±£÷§љріжњо
       A.GL_ITEM_CODE = '20110102' OR --ґ®їоЅљ±г
       A.GL_ITEM_CODE = '20110113' --іуґоіжµ•
  )
  AND A.ACCT_BALANCE <> 0;
  commit;
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);

  /*VS_STEP := '3.іжЅњЄц»ЋіжњоќѓЌ–іжњоЊї÷µ';
  INSERT INTO PBOCD_JS_202_CLGRCK_TMP (
         DATA_DATE,  -- эЊЁ»’∆Џ
         ORG_CODE,   --љр»Џїъєєіъ¬л
         ORG_NUM,   --ƒЏ≤њїъєєЇ≈
         CUST_ID_TYPE,   --њЌїІ÷§Љюја–Ќ
         CUST_ID_NO,   --њЌїІ÷§Љюіъ¬л
         REG_REGION_CODE,   --њЌїІЊ”„°µЎ––’ю«шїЃіъ¬л
         DEP_ACC_CODE,   --іжњо’ЋїІіъ¬л
         DEP_AGR_CODE,   --іжњо–≠“йіъ¬л
         PRODUCT_TYPE,   --іжњо≤ъ∆Јја±р
         CON_BGN_DATE,   --іжњо–≠“й∆р Љ»’∆Џ
         CON_DUE_DATE,   --іжњо–≠“йµљ∆Џ»’∆Џ
         CURR_CODE,   --іжњо±“÷÷
         BALANCE,   --іжњо”аґо
         BALANCE_RMB,   --іжњо”аґо’џ»Ћ√с±“
         INT_RATE,   --јы¬ ЋЃ∆љ
         DEPOSIT_RESERVE_METHOD,   --љ…іж„Љ±ЄљрЈљ љ
         REPORT_ID,   --±®±нID
         CJRQ,   --≤…Љѓ»’∆Џ
         NBJGH,   --ƒЏ≤њїъєєЇ≈
         BIZ_LINE_ID,   --“µќсћхѕя
         VERIFY_STATUS,   --–£—й„іћђ
         BSCJRQ,   --±®ЋЌ≤…Љѓ»’∆Џ
         FRNBJGH,   --Ј®»ЋƒЏ≤њїъєєЇ≈
         CUST_ID, --њЌїІЇ≈
         CUST_NAME  --њЌїІ√ы
   )SELECT \*+parallel(4)*\
         TO_CHAR(TO_DATE(IS_DATE, 'YYYYMMDD'), 'YYYY-MM-DD') DATA_DATE, -- эЊЁ»’∆Џ
         '' ORG_CODE, --љр»Џїъєєіъ¬л
         '990000' ORG_NUM, --ƒЏ≤њїъєєЇ≈--„№––
         '' AS CUST_ID_TYPE, --њЌїІ÷§Љюја–Ќ
         '' AS CUST_ID_NO, --њЌїІ÷§Љюіъ¬л
         '220000' AS REG_REGION_CODE, --њЌїІµЎ«шіъ¬л--„№––
         '303001-304001' DEP_ACC_CODE, --іжњо’ЋїІ±а¬л
         '303001-304001' DEP_AGR_CODE, --іжњо–≠“й±а¬л
         'D15'  AS PRODUCT_TYPE, --іжњо≤ъ∆Јја±р--ќѓЌ–„ љріжњо£®Њї£©
         NULL AS CON_BGN_DATE, --іжњо–≠“й∆р Љ»’∆Џ
         '9999-12-31' AS CON_DUE_DATE, --іжњо–≠“йµљ∆Џ»’∆Џ
         'CNY' AS CURR_CODE, --±“÷÷
         SUM(CASE WHEN GL.ITEM_CD = '304001' THEN -GL.DEBIT_BAL  ELSE GL.CREDIT_BAL END) AS BALANCE, --іжњо”аґо
         SUM(CASE WHEN GL.ITEM_CD = '304001' THEN -GL.DEBIT_BAL  ELSE GL.CREDIT_BAL END) AS BALANCE_RMB, --іжњо”аґо’џ»Ћ√с±“
         NULL AS INT_RATE, --јы¬ ЋЃ∆љ
         'DR03' AS DEPOSIT_RESERVE_METHOD, --љ…іж„Љ±ЄљрЈљ љ
         SYS_GUID() REPORT_ID, --±®ЋЌID
         IS_DATE CJRQ, --≤…Љѓ»’∆Џ
         '990000' NBJGH, --ƒЏ≤њїъєєЇ≈
         '99 ' BIZ_LINE_ID, --“µќсћхѕя
         '' VERIFY_STATUS, --–£—й„іћђ
         '' BSCJRQ, --±®ЋЌ÷№∆Џ
         '990000' AS FRNBJGH,
         NULL, --њЌїІЇ≈
         NULL --њЌїІ√ы≥∆
  FROM SMTMODS.L_FINA_GL GL WHERE GL.DATA_DATE = IS_DATE
   AND GL.ITEM_CD IN ('303001', '304001') AND GL.CURR_CD = 'CNY' AND GL.ORG_NUM = '990000';
   COMMIT;
     SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);*/

--[2025-12-30] [÷№ЅҐ≈ф] [JLBA202509240002_єЎ”Џљр»Џїщі° эЊЁѕµЌ≥»° э¬яЉ≠Єƒ‘мЉ∞÷ќјн≥£ћђїѓљ®…иµƒ–и«у_“їљ„ґќ][јой™] іъ¬л«∞“∆
/*----“‘ѕ¬ќ™‘≠”¶”√≤г¬яЉ≠
 SP_PBOCD_PARTITIONS(IS_DATE,'PBOCD_JS_202_CLGRCK',OI_RETCODE);

  VS_STEP := '1.≤е»лƒњ±к±н эЊЁ';
  INSERT INTO PBOCD_JS_202_CLGRCK  (
      DATA_DATE,   -- эЊЁ»’∆Џ
      ORG_CODE,    --љр»Џїъєєіъ¬л
      ORG_NUM,    --ƒЏ≤њїъєєЇ≈
      CUST_ID_TYPE,    --њЌїІ÷§Љюја–Ќ
      CUST_ID_NO,      --њЌїІ÷§Љюіъ¬л
      REG_REGION_CODE,    --њЌїІЊ”„°µЎ––’ю«шїЃіъ¬л
      DEP_ACC_CODE,   --іжњо’ЋїІіъ¬л
      DEP_AGR_CODE,   --іжњо–≠“йіъ¬л
      PRODUCT_TYPE,   --іжњо≤ъ∆Јја±р
      CON_BGN_DATE,   --іжњо–≠“й∆р Љ»’∆Џ
      CON_DUE_DATE,   --іжњо–≠“йµљ∆Џ»’∆Џ
      CURR_CODE,   --іжњо±“÷÷
      BALANCE,   --іжњо”аґо
      BALANCE_RMB,   --іжњо”аґо’џ»Ћ√с±“
      INT_RATE,   --јы¬ ЋЃ∆љ
      DEPOSIT_RESERVE_METHOD,   --љ…іж„Љ±ЄљрЈљ љ
      REPORT_ID,   --±®±нID
      CJRQ,   --≤…Љѓ»’∆Џ
      NBJGH,   --ƒЏ≤њїъєєЇ≈
      BIZ_LINE_ID,   --“µќсћхѕя
      VERIFY_STATUS,   --–£—й„іћђ
      BSCJRQ,   --±®ЋЌ≤…Љѓ»’∆Џ
      FRNBJGH,   --Ј®»ЋƒЏ≤њїъєєЇ≈
      CUST_ID, --њЌїІЇ≈
      CUST_NAME --њЌїІ√ы≥∆
  )
  SELECT \*+parallel(4)*\
      VS_TEXT AS DATA_DATE,  -- эЊЁ»’∆Џ

      NVL(OB.ID_NO,OB.UP_ID_NO), --љр»Џїъєєіъ¬л
      A.ORG_NUM,    --ƒЏ≤њїъєєЇ≈
      A.CUST_ID_TYPE,    --њЌїІ÷§Љюја–Ќ
      A.CUST_ID_NO,      --њЌїІ÷§Љюіъ¬л
      CASE WHEN A.REG_REGION_CODE IS NOT NULL THEN A.REG_REGION_CODE ELSE OB.REGION_CD END REG_REGION_CODE,    --њЌїІЊ”„°µЎ––’ю«шїЃіъ¬л(»зєыµЎ«шіъ¬лќ™њ’£ђ»°Ћщ‘ЏїъєєµƒµЎ«шіъ¬л)
      A.DEP_ACC_CODE,   --іжњо’ЋїІіъ¬л
      A.DEP_AGR_CODE,   --іжњо–≠“йіъ¬л
      A.PRODUCT_TYPE,   --іжњо≤ъ∆Јја±р
      A.CON_BGN_DATE,   --іжњо–≠“й∆р Љ»’∆Џ
      A.CON_DUE_DATE,   --іжњо–≠“йµљ∆Џ»’∆Џ
      A.CURR_CODE,   --іжњо±“÷÷
      A.BALANCE,   --іжњо”аґо
      A.BALANCE_RMB,   --іжњо”аґо’џ»Ћ√с±“
      A.INT_RATE,   --јы¬ ЋЃ∆љ
      A.DEPOSIT_RESERVE_METHOD,   --љ…іж„Љ±ЄљрЈљ љ
      A.REPORT_ID,   --±®±нID
      IS_DATE AS CJRQ,   --≤…Љѓ»’∆Џ
      A.NBJGH,   --ƒЏ≤њїъєєЇ≈
      '99' AS BIZ_LINE_ID,   --“µќсћхѕя
      '' AS VERIFY_STATUS,   --–£—й„іћђ
      '' AS BSCJRQ,   --±®ЋЌ≤…Љѓ»’∆Џ
      A.FRNBJGH,   --Ј®»ЋƒЏ≤њїъєєЇ≈
      A.CUST_ID, --њЌїІЇ≈
      A.CUST_NAME --њЌїІ√ы≥∆
  FROM PBOCD_JS_202_CLGRCK_TMP A --»•µфЇЋѕъ эЊЁ

  LEFT JOIN L_PUBL_ORG_BRA_TMP OB--љр эїъєє±н
      ON OB.ORG_NUM=A.NBJGH AND OB.DATA_DATE=IS_DATE
  WHERE A.CJRQ = IS_DATE;
  COMMIT;*/

--≤е»л–≈”√њ® эЊЁ
INSERT INTO PBOCD_JS_202_CLGRCK
  (data_date,
   org_code,
   org_num,
   cust_id_type,
   cust_id_no,
   reg_region_code,
   dep_acc_code,
   dep_agr_code,
   product_type,
   con_bgn_date,
   con_due_date,
   curr_code,
   balance,
   balance_rmb,
   int_rate,
   deposit_reserve_method,
   fini_region_code,
   dep_acc_type,
   dep_status,
   report_id,
   cjrq,
   nbjgh,
   biz_line_id,
   verify_status,
   bscjrq,
   frnbjgh)
  SELECT VS_TEXT AS DATA_DATE,
         ORG_CODE,
         '009803' ORG_NUM,
         CUST_ID_TYPE,
         CUST_ID_NO,
         REG_REGION_CODE,
         DEP_ACC_CODE,
         DEP_AGR_CODE,
         PRODUCT_TYPE,
         CON_BGN_DATE,
         CON_DUE_DATE,
         CURR_CODE,
         BALANCE,
         BALANCE_RMB,
         INT_RATE,
         SUBSTR(DEPOSIT_RESERVE_METHOD, 1, 4),
         FINI_REGION_CODE,
         DEP_ACC_TYPE,
         DEP_STATUS,
         SYS_GUID() REPORT_ID,
         IS_DATE CJRQ,
         '009803' NBJGH,
         '99' BIZ_LINE_ID,
         '' VERIFY_STATUS,
         '' BSCJRQ,
         '990000' FRNBJGH
    FROM PBOCD_DATACORE.JS_202_CLGRCK_XYK
   WHERE DATA_DATE = IS_DATE;
COMMIT;

--[2025-09-18] [÷№ЅҐ≈ф] [JLBA202412270002_єЎ”ЏЈ÷ќц≈≈≤йЉ∞Єƒ‘мљр»Џїщі° эЊЁ»° э¬яЉ≠µƒ–и«у_Ћƒљ„ґќ][јой™] –ёЄƒґ®„™їоєж‘т
--±Њ±“ґ®∆Џ≤ъ∆Јјы¬ –°”Џ1£ђ–ёЄƒ≤ъ∆Јја–ЌЇЌµљ∆Џ»’јы¬ 
/*UPDATE PBOCD_JS_202_CLGRCK T
SET T.PRODUCT_TYPE='D013',T.INT_RATE='0.05000',T.CON_DUE_DATE='9999-12-31'
WHERE T.CJRQ = IS_DATE
AND T.FRNBJGH='990000'
AND T.PRODUCT_TYPE='D014'
AND T.INT_RATE <0.8
AND T.CURR_CODE='CNY'
AND T.BALANCE_RMB>='50'
AND T.DEP_ACC_CODE <> '9020790501000013_1'
--”–љ±іҐ–о’ЋїІ£ђ≤ї„ці¶јн£ђ–іЋµ√ч
;
COMMIT;*/

--”–љ±іҐ–о’ЋїІ£ђµљ∆Џ»’–іЋј9999-12-31
UPDATE PBOCD_JS_202_CLGRCK T
SET T.CON_DUE_DATE='9999-12-31'
WHERE T.DEP_ACC_CODE='9020790501000013_1'
AND T.FRNBJGH='990000'
AND T.CJRQ = IS_DATE ;
COMMIT;

--’в±  «–≈”√њ®іжњоµƒїг„№ э£ђ…Њµф
  DELETE FROM PBOCD_JS_202_CLGRCK
   WHERE CJRQ = IS_DATE
     AND DEP_ACC_CODE = '9019800217000015_1';
  COMMIT;

--µЎ«шіъ¬л000000µƒ∞і÷Ѓ«∞µƒєж‘т£ђѕµЌ≥»°£ђѕµЌ≥»°≤їµљљЎ«∞Ѕщќї£ђ«∞ЅщќїљЎ≤їµљµƒЄшЋщ‘ЏЊ≠∞мїъєєµƒµЎ«шіъ¬л
MERGE INTO /*+parallel(4)*/PBOCD_JS_202_CLGRCK A
USING L_PUBL_ORG_BRA_TMP B
ON (A.ORG_NUM = B.ORG_NUM AND B.DATA_DATE = IS_DATE)
WHEN MATCHED THEN
  UPDATE
     SET A.REG_REGION_CODE = B.REGION_CD
   WHERE A.CJRQ = IS_DATE
     AND A.REG_REGION_CODE = '000000';
COMMIT;

--[2025-05-27] [÷№ЅҐ≈ф] [JLBA202412270002_єЎ”ЏЈ÷ќц≈≈≤йЉ∞Єƒ‘мљр»Џїщі° эЊЁ»° э¬яЉ≠µƒ–и«у_ґюљ„ґќ][јой™] ћё≥э»°…ѕ∆Џ/≈д÷√±н
/*--єЂ÷чЅлµЎ«шіъ¬л
UPDATE PBOCD_JS_202_CLGRCK
   SET REG_REGION_CODE = '220184'
 WHERE CJRQ = IS_DATE
   AND REG_REGION_CODE = '220381';
COMMIT;
--µЎ«шіъ¬л
UPDATE PBOCD_JS_202_CLGRCK
   SET REG_REGION_CODE = '220202'--Њ≠∞мїъєєµЎ«шіъ¬л
 WHERE CJRQ = IS_DATE
   AND CUST_ID = '2021669343'
   AND REG_REGION_CODE = '93035';
COMMIT;

UPDATE PBOCD_JS_202_CLGRCK
   SET REG_REGION_CODE = '210103'--Њ≠∞мїъєєµЎ«шіъ¬л
 WHERE CJRQ = IS_DATE
   AND CUST_ID = '8911192147'
   AND REG_REGION_CODE = 'shenzi';
COMMIT;*/

--÷§Љюја–Ќќ™B01-…нЈЁ÷§їт’яB08-Ѕў ±…нЈЁ÷§µƒ£ђµЏ7-14ќїµƒљЎ»°љбєы”¶Є√¬ъ„г»’∆ЏЄс љ“™«у
--’вЄц±®інµƒ÷§Љюја–ЌЈ≈µљB99
UPDATE /*+parallel(4)*/PBOCD_JS_202_CLGRCK A
   SET CUST_ID_TYPE = 'B99'
 WHERE A.CJRQ = IS_DATE
   AND FRNBJGH = '990000'
   AND CUST_ID_TYPE IN ('B01', 'B08')
   AND (SUBSTR(CUST_ID_NO, 7, 8) NOT BETWEEN '19000101' AND IS_DATE - 1 -- эЊЁ»’∆Џµƒ«∞“їћм
       OR DATE_FLG(SUBSTR(CUST_ID_NO, 7, 8)) = 0 --0іъ±нЄ√„÷Јыќ™≤їЇѕЈ®»’∆Џ£ђ1іъ±нЄ√„÷Јыќ™ЇѕЈ®»’∆Џ
       OR LENGTH(CUST_ID_NO) <> 18);
COMMIT;

--њЌїІ÷§Љюіъ¬лі•ЈҐ_”≤–£—й-њЌїІ÷§Љюіъ¬л„÷ґќƒЏ»Ё÷–≤їµ√≥цѕ÷°∞£њ°±°Ґ°∞£°°±°Ґ°∞^°±°£∆д÷–°∞£њ°±ЇЌ°∞£°°±∞ьЇђ»Ђљ«ЇЌ∞лљ«Ѕљ÷÷Єс љ°£
--»зєыB04їє±®інµƒї∞“≤Ј≈µљB99
UPDATE /*+parallel(4)*/PBOCD_JS_202_CLGRCK A
   SET CUST_ID_NO = REGEXP_REPLACE(CUST_ID_NO, '[,,.,,<,(]')
 WHERE A.CJRQ = IS_DATE
   AND FRNBJGH = '990000'
   AND REGEXP_LIKE(CUST_ID_NO, '[,,?,£њ,!,£°,^]');
COMMIT;

--[2025-05-27] [÷№ЅҐ≈ф] [JLBA202412270002_єЎ”ЏЈ÷ќц≈≈≤йЉ∞Єƒ‘мљр»Џїщі° эЊЁ»° э¬яЉ≠µƒ–и«у_ґюљ„ґќ][јой™] ћё≥э»°…ѕ∆Џ/≈д÷√±н
--µч”√ћЎ ві¶јн≥ћ–т
--≈Ќ ѓ“™«у≤їЇѕєжµƒµЎ«шіъ¬л∞і–¬Њ…ґ‘’’≈д÷√±н–ёЄƒ
--  BSP_SP_JS_SPOP(IS_DATE,OI_RETCODE,OI_RETCODE_DEC,'PBOCD_JS_202_CLGRCK');
  -------------------------------------------------------------------------

  -- љб ш»’÷Њ
  VS_STEP := 'END';
  SP_PBOCD_LOG(VS_PROCEDURE_NAME, VS_STEP, VI_ERRORCODE, VS_TEXT, IS_DATE);
EXCEPTION
  WHEN OTHERS THEN
    --»зєы≥цѕ÷“м≥£
    VI_ERRORCODE := SQLCODE; --…и÷√“м≥£іъ¬л
    VS_TEXT      := VS_STEP || '|' || IS_DATE || '|' ||
                    SUBSTR(SQLERRM, 1, 200); --…и÷√“м≥£√и ц
    ROLLBACK; -- эЊЁїЎєц
    OI_RETCODE := -1; --…и÷√“м≥£„іћђќ™-1
    OI_RETCODE_DEC :=SQLCODE||':'||SUBSTR(SQLERRM,1,50);--ѕµЌ≥інќу√и ц
    --≤е»л»’÷Њ±н£ђЉ«¬Љінќу
    SP_PBOCD_LOG(VS_PROCEDURE_NAME, 'ERROR', VI_ERRORCODE, VS_TEXT, IS_DATE);
END;