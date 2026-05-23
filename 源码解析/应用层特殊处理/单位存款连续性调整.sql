
----------------------------------------------------------------------------------------------------
-- 文件名: 单位存款连续性调整.sql
-- 业务域: 应用层特殊处理
-- 用途: 备份本期存量和发生数据     代码最后修改时间20251013 16:25*/
----------------------------------------------------------------------------------------------------

/*备份本期存量和发生数据     代码最后修改时间20251013 16:25*/
truncate table js_202_ftydwc_spop_bk;
insert into js_202_ftydwc_spop_bk 
select * from js_202_ftydwc where cjrq = $DATA_DATE  ;

truncate table js_202_dwckfs_spop_bk;
insert into js_202_dwckfs_spop_bk 
select * from js_202_dwckfs where cjrq = $DATA_DATE  ;

/*--1、核查确认不平的，如果是账户或流水缺失导致，找上游，如果是个体工商户变化或科目变化等，提供清单给业务*/
truncate table dwck_tmp01;
insert into dwck_tmp01
select a.dep_acc_code,
       nvl( b.balance ,0)上月,nvl(a.balance,0)本月,
       -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) 差值,
       nvl(c.TRANS_AMT,0) 收回,nvl(D.TRANS_AMT,0) 发生
  from (select dep_acc_code
          ,SUM(balance) balance from js_202_ftydwc a where a.cjrq = $DATA_DATE and frnbjgh='990000'
     group by dep_acc_code) a
  left join (select dep_acc_code
  ,SUM(balance) balance from js_202_ftydwc b where b.cjrq = $LAST_MONTH_DATE and frnbjgh='990000' 
     group by dep_acc_code ) b 
     on a.dep_acc_code = b.dep_acc_code
  left join (
       select c.dep_acc_code
       ,SUM(TRANS_AMT) TRANS_AMT 
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='0'  
       GROUP BY c.dep_acc_code
  ) c on a.dep_acc_code = c.dep_acc_code
  left join (
       select c.dep_acc_code
       ,SUM(case when c.trans_type ='1' THEN C.TRANS_AMT ELSE -C.TRANS_AMT END) TRANS_AMT 
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='1'  
       GROUP BY c.dep_acc_code
  )d on a.dep_acc_code = d.dep_acc_code
  where -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) <> 0 ;


insert into dwck_tmp01
select b.dep_acc_code,
       nvl( b.balance ,0)上月,nvl(a.balance,0)本月,
       -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) 差值,
       nvl(c.TRANS_AMT,0) 收回,nvl(D.TRANS_AMT,0) 发生
  from  (select dep_acc_code
  ,SUM(balance) balance from js_202_ftydwc b where b.cjrq = $LAST_MONTH_DATE and frnbjgh='990000' 
         group by dep_acc_code )b
  left join (select dep_acc_code
  ,SUM(balance) balance from js_202_ftydwc a where a.cjrq = $DATA_DATE and frnbjgh='990000' 
         group by dep_acc_code ) a 
   on a.dep_acc_code = b.dep_acc_code
  left join (
       select c.dep_acc_code
       ,SUM(TRANS_AMT) TRANS_AMT 
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='0' 
       GROUP BY c.dep_acc_code
  ) c on b.dep_acc_code = c.dep_acc_code
  left join (
       select c.dep_acc_code
       ,SUM(case when c.trans_type ='1' THEN C.TRANS_AMT ELSE -C.TRANS_AMT END) TRANS_AMT 
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='1'  
       GROUP BY c.dep_acc_code
  )d on b.dep_acc_code = d.dep_acc_code
  where -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) <> 0;


insert into dwck_tmp01
select c.dep_acc_code,
       nvl( b.balance ,0)上月,nvl(a.balance,0)本月,
       -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) 差值,
       nvl(c.TRANS_AMT,0) 收回,nvl(D.TRANS_AMT,0) 发生
  from    (
       select c.dep_acc_code
       ,SUM(TRANS_AMT) TRANS_AMT 
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='0'  
       GROUP BY c.dep_acc_code
  ) c 
left join  
  (select dep_acc_code
  ,SUM(balance) balance from js_202_ftydwc a where a.cjrq = $DATA_DATE and frnbjgh='990000' 
    group by dep_acc_code) a
  on a.dep_acc_code = c.dep_acc_code
  left join (select dep_acc_code
  ,SUM(balance) balance from js_202_ftydwc b where b.cjrq = $LAST_MONTH_DATE and frnbjgh='990000' 
    group by dep_acc_code ) b 
    on c.dep_acc_code = b.dep_acc_code
  left join (
       select c.dep_acc_code
       ,SUM(case when c.trans_type ='1' THEN C.TRANS_AMT ELSE -C.TRANS_AMT END) TRANS_AMT 
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='1'  
       GROUP BY c.dep_acc_code
  )d on c.dep_acc_code = d.dep_acc_code
  where -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) <> 0;


insert into dwck_tmp01
select d.dep_acc_code,
       nvl( b.balance ,0)上月,nvl(a.balance,0)本月,
       -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) 差值,
       nvl(c.TRANS_AMT,0) 收回,nvl(D.TRANS_AMT,0) 发生
  from     (
       select c.dep_acc_code
       ,SUM(case when c.trans_type ='1' THEN C.TRANS_AMT ELSE -C.TRANS_AMT END) TRANS_AMT 
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='1'
       GROUP BY c.dep_acc_code
  )d
  left join(
       select c.dep_acc_code
       ,SUM(TRANS_AMT) TRANS_AMT 
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='0'  
       GROUP BY c.dep_acc_code
  ) c  on c.dep_acc_code = d.dep_acc_code
left join  
  (select dep_acc_code
  ,SUM(balance) balance from js_202_ftydwc a where a.cjrq = $DATA_DATE and frnbjgh='990000' 
     group by dep_acc_code) a
  on a.dep_acc_code = d.dep_acc_code
  left join (select dep_acc_code
  ,SUM(balance) balance from js_202_ftydwc b where b.cjrq = $LAST_MONTH_DATE and frnbjgh='990000' 
     group by dep_acc_code) b 
     on d.dep_acc_code = b.dep_acc_code
  where -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) <> 0 ;


--2、做定转活
--特别注意，查一下上期做了定转活的，这期也直接改一下，不然下面做一笔收回一笔发放就不对了！！！！
select * from js_202_ftydwc A where cjrq in ($DATA_DATE) and product_type='D012' AND EXISTS(
select * from js_202_ftydwc B where cjrq in ($LAST_MONTH_DATE) and product_type='D011' 
AND A.DEP_ACC_CODE=B.DEP_ACC_CODE
);
--发现是之前做了定转活的，本期直接把定期改成活期
update js_202_ftydwc A set product_type='D011',CON_DUE_DATE='9999-12-31' 
where cjrq in ($DATA_DATE) and product_type='D012' AND EXISTS(
select * from js_202_ftydwc B where cjrq in ($LAST_MONTH_DATE) and product_type='D011' 
AND A.DEP_ACC_CODE=B.DEP_ACC_CODE
);


--3_1、整理出D05以外的产品跨期数据（因为D05特殊，后面单独处理）
truncate table dwck_tmp02;
insert into dwck_tmp02
select * from (
select a.dep_acc_code,A.PRODUCT_TYPE,
       nvl( b.balance ,0)上月,nvl(a.balance,0)本月,
       -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) 差值,
     -nvl(a.balance_rmb,0) -NVL(c.TRANS_AMT_RMB,0)+nvl( b.balance_rmb ,0) + NVL(d.TRANS_AMT_RMB,0) 差值rmb,
       nvl(c.TRANS_AMT,0) 收回,nvl(D.TRANS_AMT,0) 发生
  from (select dep_acc_code
          ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END product_type
          ,SUM(balance) balance,SUM(balance_rmb) balance_rmb from js_202_ftydwc a where a.cjrq = $DATA_DATE and frnbjgh='990000'
     group by dep_acc_code
     ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END) a
  left join (select dep_acc_code
  ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END product_type
  ,SUM(balance) balance,SUM(balance_rmb) balance_rmb from js_202_ftydwc b where b.cjrq = $LAST_MONTH_DATE and frnbjgh='990000' 
     group by dep_acc_code 
     ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END) b 
     on a.dep_acc_code = b.dep_acc_code
     AND A.PRODUCT_TYPE=B.PRODUCT_TYPE
  left join (
       select c.dep_acc_code
       ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END product_type
       ,SUM(TRANS_AMT) TRANS_AMT ,SUM(TRANS_AMT_RMB) TRANS_AMT_RMB 
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='0'  
       GROUP BY c.dep_acc_code
       ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END 
  ) c on a.dep_acc_code = c.dep_acc_code AND A.PRODUCT_TYPE=C.PRODUCT_TYPE
  left join (
       select c.dep_acc_code
       ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END product_type
       ,SUM(TRANS_AMT) TRANS_AMT ,SUM(TRANS_AMT_RMB) TRANS_AMT_RMB 
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='1'  
       GROUP BY c.dep_acc_code
       ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END
  )d on a.dep_acc_code = d.dep_acc_code AND A.PRODUCT_TYPE=D.PRODUCT_TYPE
  where -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) <> 0
  ) where dep_acc_code not in (select dep_acc_code from dwck_tmp01)--确定这些是客户类型变化或科目变化，不调整，由业务写说明
  and PRODUCT_TYPE in ('D011','D012','D16') --zhoulp20251011 只处理活期、定期、大额存单
--and dep_acc_code not in(select dep_acc_code from dwck_tmp03)--配置表，这5条确定是D062产品，由业务调整--因为整个处理操作都改到业务调整之后了，所以这行可以注释掉了
;


insert into dwck_tmp02
select * from (
select b.dep_acc_code,b.product_type,
       nvl( b.balance ,0)上月,nvl(a.balance,0)本月,
       -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) 差值,
     -nvl(a.balance_rmb,0) -NVL(c.TRANS_AMT_RMB,0)+nvl( b.balance_rmb ,0) + NVL(d.TRANS_AMT_RMB,0) 差值rmb,
       nvl(c.TRANS_AMT,0) 收回,nvl(D.TRANS_AMT,0) 发生
  from  (select dep_acc_code
  ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END product_type
  ,SUM(balance) balance,SUM(balance_rmb) balance_rmb from js_202_ftydwc b where b.cjrq = $LAST_MONTH_DATE and frnbjgh='990000' 
         group by dep_acc_code 
         ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END)b
  left join (select dep_acc_code
  ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END product_type
  ,SUM(balance) balance,SUM(balance_rmb) balance_rmb from js_202_ftydwc a where a.cjrq = $DATA_DATE and frnbjgh='990000' 
         group by dep_acc_code 
         ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END) a 
   on a.dep_acc_code = b.dep_acc_code and a.product_type=b.product_type
  left join (
       select c.dep_acc_code
       ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END product_type
       ,SUM(TRANS_AMT) TRANS_AMT ,SUM(TRANS_AMT_RMB) TRANS_AMT_RMB 
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='0' 
       GROUP BY c.dep_acc_code
       ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END
  ) c on b.dep_acc_code = c.dep_acc_code and b.product_type=c.product_type
  left join (
       select c.dep_acc_code
       ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END product_type
       ,SUM(TRANS_AMT) TRANS_AMT ,SUM(TRANS_AMT_RMB) TRANS_AMT_RMB 
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='1'  
       GROUP BY c.dep_acc_code
       ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END
  )d on b.dep_acc_code = d.dep_acc_code and b.product_type=d.product_type
  where -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) <> 0
  ) where dep_acc_code not in (select dep_acc_code from dwck_tmp01)--确定这些是客户类型变化或科目变化，不调整，由业务写说明
  and PRODUCT_TYPE in ('D011','D012','D16') --zhoulp20251011 只处理活期、定期、大额存单
--and dep_acc_code not in(select dep_acc_code from dwck_tmp03)--配置表，这5条确定是D062产品，由业务调整--因为整个处理操作都改到业务调整之后了，所以这行可以注释掉了
;


insert into dwck_tmp02
select * from (
select c.dep_acc_code,b.product_type,
       nvl( b.balance ,0)上月,nvl(a.balance,0)本月,
       -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) 差值,
     -nvl(a.balance_rmb,0) -NVL(c.TRANS_AMT_RMB,0)+nvl( b.balance_rmb ,0) + NVL(d.TRANS_AMT_RMB,0) 差值rmb,
       nvl(c.TRANS_AMT,0) 收回,nvl(D.TRANS_AMT,0) 发生
  from    (
       select c.dep_acc_code
       ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END product_type
       ,SUM(TRANS_AMT) TRANS_AMT ,SUM(TRANS_AMT_RMB) TRANS_AMT_RMB  
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='0'  
       GROUP BY c.dep_acc_code,case when product_type like 'D05%' THEN 'D05' ELSE product_type END
  ) c 
left join  
  (select dep_acc_code
  ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END product_type
  ,SUM(balance) balance,SUM(balance_rmb) balance_rmb from js_202_ftydwc a where a.cjrq = $DATA_DATE and frnbjgh='990000' 
    group by dep_acc_code ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END) a
  on a.dep_acc_code = c.dep_acc_code AND A.PRODUCT_TYPE=C.PRODUCT_TYPE
  left join (select dep_acc_code
  ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END product_type
  ,SUM(balance) balance,SUM(balance_rmb) balance_rmb from js_202_ftydwc b where b.cjrq = $LAST_MONTH_DATE and frnbjgh='990000' 
    group by dep_acc_code 
    ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END) b 
    on c.dep_acc_code = b.dep_acc_code AND C.PRODUCT_TYPE=B.PRODUCT_TYPE
  left join (
       select c.dep_acc_code
       ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END product_type
       ,SUM(TRANS_AMT) TRANS_AMT ,SUM(TRANS_AMT_RMB) TRANS_AMT_RMB 
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='1'  
       GROUP BY c.dep_acc_code,case when product_type like 'D05%' THEN 'D05' ELSE product_type END
  )d on c.dep_acc_code = d.dep_acc_code AND C.PRODUCT_TYPE=D.PRODUCT_TYPE
  where -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) <> 0
  ) where dep_acc_code not in (select dep_acc_code from dwck_tmp01)--确定这些是客户类型变化或科目变化，不调整，由业务写说明
  and PRODUCT_TYPE in ('D011','D012','D16') --zhoulp20251011 只处理活期、定期、大额存单
--and dep_acc_code not in(select dep_acc_code from dwck_tmp03)--配置表，这5条确定是D062产品，由业务调整--因为整个处理操作都改到业务调整之后了，所以这行可以注释掉了
;


insert into dwck_tmp02
select * from (
select d.dep_acc_code,d.product_type,
       nvl( b.balance ,0)上月,nvl(a.balance,0)本月,
       -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) 差值,
     -nvl(a.balance_rmb,0) -NVL(c.TRANS_AMT_RMB,0)+nvl( b.balance_rmb ,0) + NVL(d.TRANS_AMT_RMB,0) 差值rmb,
       nvl(c.TRANS_AMT,0) 收回,nvl(D.TRANS_AMT,0) 发生
  from     (
       select c.dep_acc_code
       ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END product_type
       ,SUM(TRANS_AMT) TRANS_AMT ,SUM(TRANS_AMT_RMB) TRANS_AMT_RMB 
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='1'  
       GROUP BY c.dep_acc_code,case when product_type like 'D05%' THEN 'D05' ELSE product_type END
  )d
  left join(
       select c.dep_acc_code
       ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END product_type
       ,SUM(TRANS_AMT) TRANS_AMT ,SUM(TRANS_AMT_RMB) TRANS_AMT_RMB 
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='0'  
       GROUP BY c.dep_acc_code,case when product_type like 'D05%' THEN 'D05' ELSE product_type END
  ) c  on c.dep_acc_code = d.dep_acc_code and c.product_type=d.product_type
left join  
  (select dep_acc_code
  ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END product_type
  ,SUM(balance) balance,SUM(balance_rmb) balance_rmb from js_202_ftydwc a where a.cjrq = $DATA_DATE and frnbjgh='990000' 
     group by dep_acc_code ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END) a
  on a.dep_acc_code = d.dep_acc_code and a.product_type=d.product_type
  left join (select dep_acc_code
  ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END product_type
  ,SUM(balance) balance,SUM(balance_rmb) balance_rmb from js_202_ftydwc b where b.cjrq = $LAST_MONTH_DATE and frnbjgh='990000' 
     group by dep_acc_code ,case when product_type like 'D05%' THEN 'D05' ELSE product_type END) b 
     on d.dep_acc_code = b.dep_acc_code and d.product_type=b.product_type
  where -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) <> 0
  
) where dep_acc_code not in (select dep_acc_code from dwck_tmp01)--确定这些是客户类型变化或科目变化，不调整，由业务写说明
and PRODUCT_TYPE in ('D011','D012','D16') --zhoulp20251011 只处理活期、定期、大额存单
--and dep_acc_code not in(select dep_acc_code from dwck_tmp03)--配置表，这5条确定是D062产品，由业务调整--因为整个处理操作都改到业务调整之后了，所以这行可以注释掉了
;


--3_2、D05以外的产品跨期，做一笔上期产品的收回流水、本期产品的发放流水
--上期收回
insert into pbocd.js_202_dwckfs 
   select $DATA_DATE_10,
          a.org_code,
          a.org_num,
          a.cust_id_type,
          a.cust_id_no,
          a.dep_acc_code,
          a.dep_agr_code,
          a.PRODUCT_TYPE,
          A.CON_BGN_DATE,
          A.CON_DUE_DATE,
          '',
          A.CURR_CODE,
          ABS(B.CZ),
          ABS(B.CZ_RMB),
          a.int_rate,
          $DATA_DATE_10,
          SYS_GUID(),
          '0',
          '01',
          '1',
          SYS_GUID(),
          $DATA_DATE,
          a.org_num,
          a.biz_line_id,
          a.verify_status,
          a.bscjrq,
          a.reg_address,
          a.reg_region_code,
          a.frnbjgh,
          '',
          '',
          '',
          '',
          '',
          'A',
          a.cust_id,
          a.cust_nam
FROM (select * from (select a.*,row_number() over(partition by DEP_ACC_CODE order by product_type)rn
         from js_202_ftydwc a where cjrq=$LAST_MONTH_DATE)where rn=1 )A
INNER JOIN (SELECT dep_acc_code,CZ,CZ_RMB from (select dep_acc_code,abs(cz) CZ,abs(cz_RMB) cz_RMB,
                row_number() over(partition by dep_acc_code,abs(cz) order by abs(cz_RMB)) RN from dwck_tmp02
) T WHERE T.RN=1) B
ON A.DEP_ACC_CODE=B.DEP_ACC_CODE   
and exists  (--避免插入存量里只有上期没有本期的记录，依旧是不平
select * from js_202_ftydwc b where cjrq=$DATA_DATE and A.DEP_ACC_CODE=B.DEP_ACC_CODE);


--本期发放
insert into pbocd.js_202_dwckfs 
   select $DATA_DATE_10,
          a.org_code,
          a.org_num,
          a.cust_id_type,
          a.cust_id_no,
          a.dep_acc_code,
          a.dep_agr_code,
          A.PRODUCT_TYPE,
          A.CON_BGN_DATE,
          A.CON_DUE_DATE,
          '',
          A.CURR_CODE,
          ABS(B.CZ),
          ABS(B.cz_RMB),
          a.int_rate,
          $DATA_DATE_10,
          SYS_GUID(),
          '1',
          '01',
          '1',
          SYS_GUID(),
          $DATA_DATE,
          a.org_num,
          a.biz_line_id,
          a.verify_status,
          a.bscjrq,
          a.reg_address,
          a.reg_region_code,
          a.frnbjgh,
          '',
          '',
          '',
          '',
          '',
          'A',
          a.cust_id,
          a.cust_nam
FROM (select * from (select a.*,row_number() over(partition by DEP_ACC_CODE order by product_type)rn
         from js_202_ftydwc a where cjrq=$DATA_DATE)where rn=1 )A
INNER JOIN (SELECT dep_acc_code,CZ,CZ_RMB from (select dep_acc_code,abs(cz) CZ,abs(cz_RMB) cz_RMB,
                row_number() over(partition by dep_acc_code,abs(cz) order by abs(cz_RMB)) RN from dwck_tmp02
) T WHERE T.RN=1) B
ON A.DEP_ACC_CODE=B.DEP_ACC_CODE ;


--3_3、D05以外的产品跨期，只有上期存量和本期发生，没有本期存量的，流水按上期刷一下
merge into js_202_dwckfs a using(
select a.* FROM (select * from (select a.*,row_number() over(partition by DEP_ACC_CODE order by product_type)rn
         from js_202_ftydwc a where cjrq=$LAST_MONTH_DATE)where rn=1 )A
INNER JOIN (select distinct dep_acc_code from dwck_tmp02) B
ON A.DEP_ACC_CODE=B.DEP_ACC_CODE   
and not exists  (
select * from js_202_ftydwc b where cjrq=$DATA_DATE and A.DEP_ACC_CODE=B.DEP_ACC_CODE)
)b on(a.dep_acc_code=b.dep_acc_code)
when matched then update set a.product_type=b.product_type,a.dep_agr_code=b.dep_agr_code
,a.CON_DUE_DATE=b.CON_DUE_DATE,a.int_rate=b.int_rate--有可能是之前做过定转活的，流水表要改一下到期日，利率一般都是活期利率
where a.cjrq=$DATA_DATE;


--3_4、用3_1的select查询语句检查一下结果，此时应该没有D05以外的产品跨期了(即查询结果无数据)。如果还有数据，需要查明原因并处理之后再进行下一步操作，以免影响结果


--4_1、整理出D05的产品跨期数据
truncate table dwck_tmp02;
insert into dwck_tmp02
select * from (
select a.dep_acc_code,A.PRODUCT_TYPE,
       nvl( b.balance ,0)上月,nvl(a.balance,0)本月,
       -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) 差值,
     -nvl(a.balance_rmb,0) -NVL(c.TRANS_AMT_RMB,0)+nvl( b.balance_rmb ,0) + NVL(d.TRANS_AMT_RMB,0) 差值rmb,
       nvl(c.TRANS_AMT,0) 收回,nvl(D.TRANS_AMT,0) 发生
  from (select dep_acc_code
          , product_type
          ,SUM(balance) balance,SUM(balance_rmb) balance_rmb from js_202_ftydwc a where a.cjrq = $DATA_DATE and frnbjgh='990000'
           
     group by dep_acc_code
     ,PRODUCT_TYPE) a
  left join (select dep_acc_code
  , product_type
  ,SUM(balance) balance,SUM(balance_rmb) balance_rmb from js_202_ftydwc b where b.cjrq = $LAST_MONTH_DATE and frnbjgh='990000' 
     group by dep_acc_code 
     ,PRODUCT_TYPE) b 
     on a.dep_acc_code = b.dep_acc_code
     AND A.PRODUCT_TYPE=B.PRODUCT_TYPE
  left join (
       select c.dep_acc_code
       , product_type
       ,SUM(TRANS_AMT) TRANS_AMT ,SUM(TRANS_AMT_RMB) TRANS_AMT_RMB
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='0'  
       GROUP BY c.dep_acc_code,PRODUCT_TYPE) c on a.dep_acc_code = c.dep_acc_code AND A.PRODUCT_TYPE=C.PRODUCT_TYPE
  left join (
       select c.dep_acc_code
       , product_type
       ,SUM(TRANS_AMT) TRANS_AMT ,SUM(TRANS_AMT_RMB) TRANS_AMT_RMB 
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='1'  
       GROUP BY c.dep_acc_code,PRODUCT_TYPE)d on a.dep_acc_code = d.dep_acc_code AND A.PRODUCT_TYPE=D.PRODUCT_TYPE
  
  where -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) <> 0 
) where dep_acc_code not in (select dep_acc_code from dwck_tmp01)--确定这些是客户类型变化或科目变化，不调整，由业务写说明
and substr(PRODUCT_TYPE,1,3) = 'D05' --zhoulp20251011
--and dep_acc_code not in(select dep_acc_code from dwck_tmp03)--配置表，这5条确定是D062产品，由业务调整--因为整个处理操作都改到业务调整之后了，所以这行可以注释掉了
;


insert into dwck_tmp02
select * from (
select b.dep_acc_code,b.product_type,
       nvl( b.balance ,0)上月,nvl(a.balance,0)本月,
       -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) 差值,
     -nvl(a.balance_rmb,0) -NVL(c.TRANS_AMT_RMB,0)+nvl( b.balance_rmb ,0) + NVL(d.TRANS_AMT_RMB,0) 差值rmb,
       nvl(c.TRANS_AMT,0) 收回,nvl(D.TRANS_AMT,0) 发生
  from  (select dep_acc_code
  , product_type
  ,SUM(balance) balance,SUM(balance_rmb) balance_rmb from js_202_ftydwc b where b.cjrq = $LAST_MONTH_DATE and frnbjgh='990000' 
         group by dep_acc_code 
         ,PRODUCT_TYPE)b
  left join (select dep_acc_code
  , product_type
  ,SUM(balance) balance,SUM(balance_rmb) balance_rmb from js_202_ftydwc a where a.cjrq = $DATA_DATE and frnbjgh='990000' 
         group by dep_acc_code 
         ,PRODUCT_TYPE) a 
   on a.dep_acc_code = b.dep_acc_code and a.product_type=b.product_type
  left join (
       select c.dep_acc_code
       , product_type
       ,SUM(TRANS_AMT) TRANS_AMT ,SUM(TRANS_AMT_RMB) TRANS_AMT_RMB
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='0' 
       GROUP BY c.dep_acc_code,PRODUCT_TYPE) c on b.dep_acc_code = c.dep_acc_code and b.product_type=c.product_type
  left join (
       select c.dep_acc_code
       , product_type
       ,SUM(TRANS_AMT) TRANS_AMT ,SUM(TRANS_AMT_RMB) TRANS_AMT_RMB
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='1'  
       GROUP BY c.dep_acc_code,PRODUCT_TYPE)d on b.dep_acc_code = d.dep_acc_code and b.product_type=d.product_type
  where -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) <> 0 
) where dep_acc_code not in (select dep_acc_code from dwck_tmp01)--确定这些是客户类型变化或科目变化，不调整，由业务写说明
and substr(PRODUCT_TYPE,1,3) = 'D05' --zhoulp20251011
--and dep_acc_code not in(select dep_acc_code from dwck_tmp03)--配置表，这5条确定是D062产品，由业务调整--因为整个处理操作都改到业务调整之后了，所以这行可以注释掉了
;


insert into dwck_tmp02
select * from (
select c.dep_acc_code,b.product_type,
       nvl( b.balance ,0)上月,nvl(a.balance,0)本月,
       -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) 差值,
     -nvl(a.balance_rmb,0) -NVL(c.TRANS_AMT_RMB,0)+nvl( b.balance_rmb ,0) + NVL(d.TRANS_AMT_RMB,0) 差值rmb,
       nvl(c.TRANS_AMT,0) 收回,nvl(D.TRANS_AMT,0) 发生
  from    (
       select c.dep_acc_code
       , product_type
       ,SUM(TRANS_AMT) TRANS_AMT ,SUM(TRANS_AMT_RMB) TRANS_AMT_RMB
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='0'  
       GROUP BY c.dep_acc_code,PRODUCT_TYPE) c 
left join  
  (select dep_acc_code
  , product_type
  ,SUM(balance) balance,SUM(balance_rmb) balance_rmb from js_202_ftydwc a where a.cjrq = $DATA_DATE and frnbjgh='990000' 
    group by dep_acc_code ,PRODUCT_TYPE) a
  on a.dep_acc_code = c.dep_acc_code AND A.PRODUCT_TYPE=C.PRODUCT_TYPE
  left join (select dep_acc_code
  , product_type
  ,SUM(balance) balance,SUM(balance_rmb) balance_rmb from js_202_ftydwc b where b.cjrq = $LAST_MONTH_DATE and frnbjgh='990000' 
    group by dep_acc_code 
    ,PRODUCT_TYPE) b 
    on c.dep_acc_code = b.dep_acc_code AND C.PRODUCT_TYPE=B.PRODUCT_TYPE


  left join (
       select c.dep_acc_code
       , product_type
       ,SUM(TRANS_AMT) TRANS_AMT ,SUM(TRANS_AMT_RMB) TRANS_AMT_RMB
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='1'  
       GROUP BY c.dep_acc_code,PRODUCT_TYPE)d on c.dep_acc_code = d.dep_acc_code AND C.PRODUCT_TYPE=D.PRODUCT_TYPE
  where -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) <> 0 
) where dep_acc_code not in (select dep_acc_code from dwck_tmp01)--确定这些是客户类型变化或科目变化，不调整，由业务写说明
and substr(PRODUCT_TYPE,1,3) = 'D05' --zhoulp20251011
--and dep_acc_code not in(select dep_acc_code from dwck_tmp03)--配置表，这5条确定是D062产品，由业务调整--因为整个处理操作都改到业务调整之后了，所以这行可以注释掉了
;


insert into dwck_tmp02
select * from (
select d.dep_acc_code,d.product_type,
       nvl( b.balance ,0)上月,nvl(a.balance,0)本月,
       -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) 差值,
     -nvl(a.balance_rmb,0) -NVL(c.TRANS_AMT_RMB,0)+nvl( b.balance_rmb ,0) + NVL(d.TRANS_AMT_RMB,0) 差值rmb,
       nvl(c.TRANS_AMT,0) 收回,nvl(D.TRANS_AMT,0) 发生
  from     (
       select c.dep_acc_code
       , product_type
       ,SUM(TRANS_AMT) TRANS_AMT ,SUM(TRANS_AMT_RMB) TRANS_AMT_RMB
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='1'  
       GROUP BY c.dep_acc_code,PRODUCT_TYPE)d
  
  left join(
       select c.dep_acc_code
       , product_type
       ,SUM(TRANS_AMT) TRANS_AMT ,SUM(TRANS_AMT_RMB) TRANS_AMT_RMB
       from js_202_dwckfs c
       where c.cjrq = $DATA_DATE and frnbjgh='990000' and c.trans_type ='0'  
       GROUP BY c.dep_acc_code,PRODUCT_TYPE) c  on c.dep_acc_code = d.dep_acc_code and c.product_type=d.product_type
left join  
  (select dep_acc_code
  , product_type
  ,SUM(balance) balance,SUM(balance_rmb) balance_rmb from js_202_ftydwc a where a.cjrq = $DATA_DATE and frnbjgh='990000' 
     group by dep_acc_code ,PRODUCT_TYPE) a
  on a.dep_acc_code = d.dep_acc_code and a.product_type=d.product_type
  left join (select dep_acc_code
  , product_type
  ,SUM(balance) balance,SUM(balance_rmb) balance_rmb from js_202_ftydwc b where b.cjrq = $LAST_MONTH_DATE and frnbjgh='990000' 
     group by dep_acc_code ,PRODUCT_TYPE) b 
     on d.dep_acc_code = b.dep_acc_code and d.product_type=b.product_type
  
  where -nvl(a.balance,0) -NVL(c.TRANS_AMT,0)+nvl( b.balance ,0) + NVL(d.TRANS_AMT,0) <> 0 
  
) where dep_acc_code not in (select dep_acc_code from dwck_tmp01)--确定这些是客户类型变化或科目变化，不调整，由业务写说明
and substr(PRODUCT_TYPE,1,3) = 'D05' --zhoulp20251011
--and dep_acc_code not in(select dep_acc_code from dwck_tmp03)--配置表，这5条确定是D062产品，由业务调整--因为整个处理操作都改到业务调整之后了，所以这行可以注释掉了
;


--4_2、D05的产品跨期是因为D05的流水都归到D051产品了，此处通过产品的跨期差异判断交易方向，来做一笔D051(D052)的收回、D052(D051)的发放，调整其连续性。
--D051
insert into pbocd.js_202_dwckfs 
   select $DATA_DATE_10,
          a.org_code,
          a.org_num,
          a.cust_id_type,
          a.cust_id_no,
          a.dep_acc_code,
          '1',
          'D051',
          A.CON_BGN_DATE,
          A.CON_DUE_DATE,
          '',
          A.CURR_CODE,
          ABS(B.CZ),
          ABS(B.CZ_RMB),
          a.int_rate,
          $DATA_DATE_10,
          SYS_GUID(),
          CASE WHEN CZ<0 THEN '1' ELSE '0' END,
          '01',
          '1',
          SYS_GUID(),
          $DATA_DATE,
          a.org_num,
          a.biz_line_id,
          a.verify_status,
          a.bscjrq,
          a.reg_address,
          a.reg_region_code,
          a.frnbjgh,
          '',
          '',
          '',
          '',
          '',
          'A',
          a.cust_id,
          a.cust_nam
FROM (select * from (select a.*,row_number() over(partition by DEP_ACC_CODE order by cjrq desc,product_type)rn
         from js_202_ftydwc a where cjrq in($LAST_MONTH_DATE,$DATA_DATE)) where rn=1)A
INNER JOIN (SELECT dep_acc_code,CZ,CZ_RMB from (select dep_acc_code,CZ,cz_RMB,
                row_number() over(partition by dep_acc_code,abs(cz) order by abs(cz_RMB)) RN from dwck_tmp02 WHERE product_type='D051'
) T WHERE T.RN=1) B
ON A.DEP_ACC_CODE=B.DEP_ACC_CODE;


--D052
insert into pbocd.js_202_dwckfs 
   select $DATA_DATE_10,
          a.org_code,
          a.org_num,
          a.cust_id_type,
          a.cust_id_no,
          a.dep_acc_code,
          '2',
          'D052',
          A.CON_BGN_DATE,
          A.CON_DUE_DATE,
          '',
          A.CURR_CODE,
          ABS(B.CZ),
          ABS(B.CZ_RMB),
          a.int_rate,
          $DATA_DATE_10,
          SYS_GUID(),
          CASE WHEN CZ<0 THEN '1' ELSE '0' END,
          '01',
          '1',
          SYS_GUID(),
          $DATA_DATE,
          a.org_num,
          a.biz_line_id,
          a.verify_status,
          a.bscjrq,
          a.reg_address,
          a.reg_region_code,
          a.frnbjgh,
          '',
          '',
          '',
          '',
          '',
          'A',
          a.cust_id,
          a.cust_nam
FROM (select * from (select a.*,row_number() over(partition by DEP_ACC_CODE order by cjrq desc,product_type desc)rn
         from js_202_ftydwc a where cjrq in($LAST_MONTH_DATE,$DATA_DATE)) where rn=1)A
INNER JOIN (SELECT dep_acc_code,CZ,CZ_RMB from (select dep_acc_code,CZ,cz_RMB,
                row_number() over(partition by dep_acc_code,abs(cz) order by abs(cz_RMB)) RN from dwck_tmp02 WHERE product_type='D052'
) T WHERE T.RN=1) B
ON A.DEP_ACC_CODE=B.DEP_ACC_CODE;


--4_3、用4_1的select查询语句检查一下结果，此时应该没有产品跨期了(即查询结果无数据)。如果还有数据，需要查明原因并处理。


--5、修改一下协议代码，避免校验报错
update js_202_ftydwc a set DEP_AGR_CODE='1' where a.cjrq=$DATA_DATE and frnbjgh='990000'
AND product_type='D051';
update js_202_ftydwc a set DEP_AGR_CODE='2' where a.cjrq=$DATA_DATE and frnbjgh='990000'
AND product_type='D052';
update js_202_dwckfs a set DEP_AGR_CODE='1' where a.cjrq=$DATA_DATE and frnbjgh='990000'
AND product_type='D051';
update js_202_dwckfs a set DEP_AGR_CODE='2' where a.cjrq=$DATA_DATE and frnbjgh='990000'
AND product_type='D052';


--其他产品跨期的也改一下
update js_202_dwckfs set dep_agr_code='1' where cjrq=$DATA_DATE and frnbjgh='990000' and serial_no in
(--查询一下serial_no，根据serial_no改协议号
select b.serial_no from js_202_ftydwc a 
inner join (select * from js_202_dwckfs b where b.cjrq=$DATA_DATE and frnbjgh='990000')b
on a.dep_acc_code=b.dep_acc_code and a.dep_agr_code=b.dep_agr_code 
and a.product_type<>b.product_type
where a.cjrq=$DATA_DATE and a.frnbjgh='990000');


--6、因为发生额中的D052是造出来的，利率可能是按D051赋值的，按存量D052刷一下
merge into js_202_dwckfs a using(
select * from (
select a.*,row_number() over(partition by dep_acc_code order by cjrq desc) rn
from js_202_ftydwc a where cjrq in($DATA_DATE,$LAST_MONTH_DATE) and product_type='D052' and frnbjgh='990000'
)b where b.rn=1)b on (a.dep_acc_code=b.dep_acc_code)
when matched then update set a.int_rate=b.int_rate
where a.cjrq=$DATA_DATE and a.product_type='D052' and a.frnbjgh='990000';


--7、检查D011产品利率大于1.8的，上个月有两笔，一直都有
select * from js_202_ftydwc where cjrq=$DATA_DATE and product_type='D011' and INT_RATE>1.8;
--8、检查D051产品利率小于0.25的，上个月有两笔，一直都有
select * from js_202_ftydwc where cjrq=$DATA_DATE 
and product_type='D051' and INT_RATE<0.25;


--9、存量里面，定期存款和大额存单，活期利率或到期未支取的账户，做定转活。交易日期取存款到期日、注意D012/D16的利率、注意D011发生的到期日取99991231
--D012的收回
insert into pbocd.js_202_dwckfs 
   select $DATA_DATE_10,
          a.org_code,
          a.org_num,
          a.cust_id_type,
          a.cust_id_no,
          a.dep_acc_code,
          a.dep_agr_code,
          'D012',
          A.CON_BGN_DATE,
          A.CON_DUE_DATE,
          '',
          A.CURR_CODE,
          balance,
          balance_rmb,
          a.int_rate,
          A.CON_DUE_DATE trans_date,
          SYS_GUID(),
          '0',--交易方向
          '01',
          '1',
          SYS_GUID(),
          $DATA_DATE,
          a.org_num,
          a.biz_line_id,
          a.verify_status,
          a.bscjrq,
          a.reg_address,
          a.reg_region_code,
          a.frnbjgh,
          '',
          '',
          '',
          '',
          '',
          'A',
          a.cust_id,
          a.cust_nam
FROM js_202_ftydwc a where cjrq=$LAST_MONTH_DATE --上期
and A.DEP_ACC_CODE in(
select DEP_ACC_CODE from js_202_ftydwc where cjrq=$DATA_DATE and product_type in ('D012','D16') and ((CURR_CODE='CNY' AND INT_RATE<0.8) OR CON_DUE_DATE<=$DATA_DATE_10)
);-- 卡利率是按人行规定，如果本行定期利率下调此处会有问题，需要同步修改，本程序中一共4处


--D011的发放
insert into pbocd.js_202_dwckfs 
   select $DATA_DATE_10,
          a.org_code,
          a.org_num,
          a.cust_id_type,
          a.cust_id_no,
          a.dep_acc_code,
          '1',--改一下存款协议代码避免校验报错
          'D011',
          A.CON_BGN_DATE,
          '9999-12-31',--到期日取9999-12-31
          '',
          A.CURR_CODE,
          a.balance,
          a.balance_rmb,
          a.int_rate,--活期利率
          b.CON_DUE_DATE trans_date,
          SYS_GUID(),
          '1',--交易方向
          '01',
          '1',
          SYS_GUID(),
          $DATA_DATE,
          a.org_num,
          a.biz_line_id,
          a.verify_status,
          a.bscjrq,
          a.reg_address,
          a.reg_region_code,
          a.frnbjgh,
          '',
          '',
          '',
          '',
          '',
          'A',
          a.cust_id,
          a.cust_nam
 FROM js_202_ftydwc a  --本期
 left join js_202_ftydwc b 
 on b.cjrq=$LAST_MONTH_DATE and a.dep_acc_code=b.dep_acc_code--交易日期取上期的到日期，避免本期的到期日变化导致交易日期不在当月
 where a.cjrq=$DATA_DATE
and A.DEP_ACC_CODE in(
select DEP_ACC_CODE from js_202_ftydwc where cjrq=$DATA_DATE and product_type in ('D012','D16') and ((CURR_CODE='CNY' AND INT_RATE<0.8) OR CON_DUE_DATE<=$DATA_DATE_10)
);-- 卡利率是按人行规定，如果本行定期利率下调此处会有问题，需要同步修改


--插完流水后把本期存量改成D011
update js_202_ftydwc set dep_agr_code='1',product_type='D011',con_due_date='9999-12-31'
where cjrq=$DATA_DATE and product_type in ('D012','D16') and ((CURR_CODE='CNY' AND INT_RATE<0.8) OR CON_DUE_DATE<=$DATA_DATE_10);


--10、发生额里面，交易日期大于到期日期的D012产品，做定转活。


--10_2_1、发生额里面，同一账户下交易日期不同，交易日期大于到期日期的D012产品，做定转活（发生方向做一笔定期收回、一笔活期发放，收回方向直接改成活期）
--到期日的D012的收回/发生
insert into pbocd.js_202_dwckfs 
   select a.DATA_DATE,
          a.org_code,
          a.org_num,
          a.cust_id_type,
          a.cust_id_no,
          a.dep_acc_code,
          a.dep_agr_code,
          'D012',
          A.CON_BGN_DATE,
          A.CON_DUE_DATE,
          CASE WHEN TRANS_TYPE = '0' THEN A.CON_DUE_DATE END, --取到期日作为实际终止日期
          A.CURR_CODE,
          A.TRANS_AMT,
          A.TRANS_AMT_RMB,
          nvl(b.int_rate,a.int_rate), -- 利率按上期存量的定期
          A.CON_DUE_DATE trans_date,--取到期日
          SYS_GUID(),
          CASE WHEN TRANS_TYPE = '1' THEN '1' ELSE '0' END,--交易方向
          '01',
          '1',
          SYS_GUID(),
          $DATA_DATE,
          a.org_num,
          a.biz_line_id,
          a.verify_status,
          $DATA_DATE bscjrq,
          a.reg_address,
          a.reg_region_code,
          a.frnbjgh,
          '',
          '',
          '',
          '',
          '',
          'A',
          a.cust_id,
          a.cust_name
 FROM pbocd.js_202_dwckfs a
 LEFT JOIN PBOCD.JS_202_FTYDWC B
   ON A.DEP_ACC_CODE = B.DEP_ACC_CODE AND B.CJRQ=$LAST_MONTH_DATE -- 上期
 where a.cjrq = $DATA_DATE
   and a.product_type in ('D012','D16')
   and a.trans_date > a.con_due_date;
   
--到期日的D011的发生/收回--插入后确认与收回插入的记录数一样多，避免笛卡尔积
insert into pbocd.js_202_dwckfs 
   select a.DATA_DATE,
          a.org_code,
          a.org_num,
          a.cust_id_type,
          a.cust_id_no,
          a.dep_acc_code,
          a.dep_agr_code,
          'D011',
          A.CON_DUE_DATE AS CON_BGN_DATE,--取到期日作为起始日期
          '9999-12-31',--到期日取9999-12-31
          '',
          A.CURR_CODE,
          A.TRANS_AMT,
          A.TRANS_AMT_RMB,
          A.int_rate,--活期利率--本期发生额里面跑出来的就是活期利率，所以这么取
          con_due_date trans_date,--取到期日期作为交易日期
          SYS_GUID(),
          CASE WHEN TRANS_TYPE = '1' THEN '0' ELSE '1' END,--交易方向
          '01',
          '1',
          SYS_GUID(),
          $DATA_DATE,
          a.org_num,
          a.biz_line_id,
          a.verify_status,
          $DATA_DATE bscjrq,
          a.reg_address,
          a.reg_region_code,
          a.frnbjgh,
          '',
          '',
          '',
          '',
          '',
          'A',
          a.cust_id,
          a.cust_name
 FROM pbocd.js_202_dwckfs a
 where cjrq = $DATA_DATE
   and product_type in ('D012','D16')
   and trans_date > con_due_date;


--10_2_2、原来的定期交易改成活期
UPDATE pbocd.JS_202_DWCKFS A
   SET PRODUCT_TYPE        = 'D011',
       CON_BGN_DATE        = CON_DUE_DATE,
       CON_DUE_DATE        = '9999-12-31',
       CON_ACTUAL_DUE_DATE = ''
 WHERE CJRQ = $DATA_DATE
   AND PRODUCT_TYPE in ('D012','D16')
   AND TRANS_DATE > CON_DUE_DATE ;
   
--10_3、做完定转活之后，剩下这些定期产品活期利率的，按存量刷一下
merge into js_202_dwckfs a using(select * from (
select dep_acc_code,int_rate,
  row_number() over(partition by dep_acc_code order by cjrq desc )rn
   from js_202_ftydwc where cjrq in($LAST_MONTH_DATE,$DATA_DATE)
) where rn=1)b on (a.dep_acc_code=b.dep_acc_code)
when matched then update set a.int_rate=b.int_rate
where a.cjrq=$DATA_DATE and product_type IN('D16','D012') --20230926加入大额存单
AND INT_RATE<0.8;


--10_4、应该没有下面这种数据了，检查两期没问题就删了  7月份无此数据
select * from js_202_dwckfs B where cjrq=$DATA_DATE and product_type='D011' and
con_due_date<>'9999-12-31';


update js_202_dwckfs B set con_due_date='9999-12-31',con_actual_due_date=''
where cjrq=$DATA_DATE and product_type='D011' and
con_due_date<>'9999-12-31';
commit;