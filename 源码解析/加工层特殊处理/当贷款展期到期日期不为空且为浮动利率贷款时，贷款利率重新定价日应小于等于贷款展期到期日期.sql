
----------------------------------------------------------------------------------------------------
-- 文件名: 当贷款展期到期日期不为空且为浮动利率贷款时，贷款利率重新定价日应小于等于贷款展期到期日期.sql
-- 业务域: 加工层特殊处理
-- 用途: 规则：贷款展期到期日期=贷款实际到期日期 李楠--20230508
-- 操作接口表: PBOCD_JS_201_CLDWDK
-- 引用的监管集市表:
--   L_ACCT_LOAN — 贷款借据信息表
----------------------------------------------------------------------------------------------------

--规则：贷款展期到期日期=贷款实际到期日期 李楠--20230508
MERGE INTO PBOCD_JS_201_CLDWDK A USING SMTMODS.L_ACCT_LOAN B 
ON(B.DATA_DATE=$DATA_DATE AND A.LOAN_NUM=B.LOAN_NUM)
WHEN MATCHED THEN UPDATE SET A.DEFER_END_DATE=TO_CHAR(B.ACTUAL_MATURITY_DT,'yyyy-mm-dd')
WHERE A.CJRQ =$DATA_DATE AND A.FRNBJGH='990000' AND A.DEFER_END_DATE IS NOT NULL
AND A.INT_RATE_TYPE='RF02' AND A.INT_REPRICE_DATE>A.DEFER_END_DATE AND
LOAN_NUM IN(--严格刷这6 笔，再有新增的要发给楠姐--20230407
--如果没报错的就不要刷，避免刷错
'04070119001193854103',
'04070119001193854105',
'04070119001193854106',
'04070119001193854104',
'04070119001193854102',
'04070119001193854107'
);                                                    