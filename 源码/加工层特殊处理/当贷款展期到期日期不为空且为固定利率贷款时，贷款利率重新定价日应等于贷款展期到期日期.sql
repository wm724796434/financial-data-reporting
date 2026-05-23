--规则：贷款展期到期日期=贷款实际到期日期 李楠--20230508
MERGE INTO PBOCD_JS_201_CLDWDK A
USING SMTMODS.L_ACCT_LOAN B
ON (B.DATA_DATE = $DATA_DATE AND A.LOAN_NUM = B.LOAN_NUM)
WHEN MATCHED THEN
  UPDATE
     SET A.DEFER_END_DATE = TO_CHAR(B.ACTUAL_MATURITY_DT, 'yyyy-mm-dd')
   WHERE A.CJRQ = $DATA_DATE
     AND A.FRNBJGH = '990000'
     AND A.DEFER_END_DATE IS NOT NULL
     AND A.INT_RATE_TYPE = 'RF01'
     AND A.INT_REPRICE_DATE <> A.DEFER_END_DATE
     AND LOAN_NUM IN ( --严格刷这19 笔，再有新增的要发给楠姐--20230407
                      --如果没报错的就不要刷，避免刷错
                      '09080521001221296001',
                      '09080521001219782301',
                      '09080521001219771601',
                      '09080521001219785801',
                      '01060119001196560301',
                      '01060119001196216801',
                      '01060119001196250701',
                      '01060119001196253701',
                      '01060119001196562601',
                      '01060119001196254601',
                      '01060119001196561501',
                      '01060119001196256201',
                      '03060119001183294001',
                      '01220118001168049201',
                      '01220120001210375601',
                      '05190119001180413201',
                      '11010118001174424601',
                      '11010119001181832201',
                      '11010119001190961101');                                                    