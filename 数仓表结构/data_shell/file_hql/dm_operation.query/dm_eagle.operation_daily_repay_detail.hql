set mapred.job.name=dm_eagle.operation_daily_repay_detail;
set mapreduce.map.memory.mb=2048;
set mapreduce.reduce.memory.mb=2048;
set hive.execution.engine=mr;
set hive.exec.parallel=true;
set hive.exec.parallel.thread.number=10;
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict;
set hive.auto.convert.join=true;
set hive.mapjoin.smalltable.filesize=50000000;
set hive.map.aggr=true;
set hive.merge.mapfiles=true;
set hive.merge.mapredfiles=true;
set hive.merge.size.per.task=1024000000;
set hive.merge.smallfiles.avgsize=1024000000;
set mapred.max.split.size=256000000;
set mapred.min.split.size.per.node=100000000;
set mapred.min.split.size.per.rack=100000000;
set hive.input.format=org.apache.hadoop.hive.ql.io.CombineHiveInputFormat;
--set hivevar:ST9=2021-01-05;
----日还款明细报表（取最新的数据）
--drop table if exists dm_eagle.operation_daily_repay_detail;
--create table if not exists dm_eagle.operation_daily_repay_detail(
--    channel_id              string             COMMENT '合同渠道方'
--   ,project_id              string             COMMENT '项目名称'
--   ,contract_no             string             COMMENT '合同编号'
--   ,due_bill_no             string             COMMENT '借据编号'
--   ,schedule_status         string             COMMENT '借据状态'
--   ,loan_active_date        string             COMMENT '借据生效日'
--   ,loan_expire_date        string             COMMENT '借据到期日'
--   ,customer_name           string             COMMENT '客户姓名'  ----取值逻辑待定
--   ,loan_init_principal     decimal(15,4)      COMMENT '借款金额'
--   ,loan_init_term          decimal(3,0)       COMMENT '总期数'
--   ,loan_term               decimal(3,0)       COMMENT '还款期次'
--   ,should_repay_date       string             COMMENT '应还日期'
--   ,biz_date                string             COMMENT '实还日期'
--   ,paid_out_date           string             COMMENT '核销日期'
--   ,fund_flow_date          string             COMMENT '资金流日期' ----取值逻辑待定
--   ,fund_flow_status        string             COMMENT '资金流状态' ----取值逻辑待定
--   ,overdue_days            decimal(5,0)       COMMENT '逾期天数'
--   ,repay_way               string             COMMENT '还款类型'
--   ,paid_amount             decimal(15,4)      COMMENT '还款金额'
--   ,paid_principal          decimal(15,4)      COMMENT '还款本金'
--   ,paid_interest           decimal(15,4)      COMMENT '还款利息'
--   ,paid_fee                decimal(15,4)      COMMENT '还款费用'
--   ,paid_penalty            decimal(15,4)      COMMENT '还款罚息'
--   ,execution_date          string             COMMENT '跑批日期'
--) COMMENT '日还款明细报表'
--PARTITIONED BY (product_id string COMMENT '产品编号')
--STORED AS PARQUET;
with due_bill_no_name as 
(
select
a.due_bill_no
,b.dim_decrypt
from(
select
distinct 
due_bill_no
,cust_id 
from 
ods_new_s.loan_apply) a
left join
(
select 
 cust_id,
 name,
 dim_decrypt
from (
select
distinct
cust_id,
name
from
ods_new_s.customer_info) c
left join
(select  
   dim_encrypt
  ,dim_decrypt  
  from dim_new.dim_encrypt_info 
  where dim_type = 'userName'
group by  
dim_encrypt
,dim_decrypt) d
on c.name = d.dim_encrypt
) b
on a.cust_id = b.cust_id
)
,
duebillno_repayterm_repayway as
(
select
t1.due_bill_no
,t1.repay_term as term
,t1.biz_date
,case when t2.purpose = '回购' then '回购' 
      when t2.purpose = '代偿' then '代偿'
      when t2.purpose = '退车' or t2.purpose = '三方支付退票' then '退票/退车'
      else '线上还款' end as repay_way
from
(select
distinct
 due_bill_no
,repay_term
,order_id
,biz_date
from 
ods_new_s_cps.repay_detail a
join
(SELECT 
    DISTINCT 
    product_id, 
    channel_id, 
    project_id
    FROM 
    dim_new.biz_conf
    where 
    project_id in ('WS0009200001','WS0006200001','WS0006200002','WS0006200003')
    ) b
on a.product_id = b.product_id
where due_bill_no != '1120123112250874213037'
) t1
left join
(
 select
 distinct
 order_id,
 repay_way,
 purpose
 from
 ods_new_s_cps.order_info
 where 
 order_id is not null
 and purpose != '放款申请'
 and purpose != '放款') t2
on t1.order_id = t2.order_id
union all
select
t1.due_bill_no
,t1.repay_term as term
,t1.biz_date
,case when t2.purpose = '商户贴息' then '商户贴息'
      when t2.purpose = '降额退息' then '降额退息'
      when t2.purpose = '退款退息' then '退款退息'
      when t2.purpose = '降额还本' then '降额还本'
      when t2.purpose = '退款回款' then '退款回款'
      when t2.purpose = '回购' then '回购'
      when t2.purpose = '代偿' then '代偿'
      when t2.purpose = '退车' or t2.purpose = '三方支付退票' then '退票/退车'
      else '线上还款' end as repay_way
from
(select
distinct
 due_bill_no
,repay_term
,order_id
,biz_date
from
ods_new_s.repay_detail a
join
(SELECT
    DISTINCT
    product_id,
    channel_id,
    project_id
    FROM
    dim_new.biz_conf
    where
    project_id in ('bd')
    ) b
on a.product_id = b.product_id
) t1
left join
(
 select
 distinct
 order_id,
 repay_way,
 purpose
 from
 ods_new_s.order_info
 where
 order_id is not null
 and purpose != '放款申请'
 and purpose != '放款') t2
on t1.order_id = t2.order_id
)

insert overwrite table dm_eagle.operation_daily_repay_detail_temp 
SELECT
    t4.channel_id,                                                                                                           --'合同渠道方'
    t4.project_id,                                                                                                           --'项目名称'
    t2.contract_no,                                                                                                          --'合同编号'
    t1.due_bill_no,                                                                                                          --'借据编号'
    t7.loan_status,                                                                                                          --'借据状态'
    t1.loan_active_date,                                                                                                     --'借据生效日'
    t2.loan_expire_date,                                                                                                     --'借据到期日'
    t6.dim_decrypt AS customer_name,                                                                                         --'客户姓名'  
    t7.loan_init_principal,
  --'借款金额'
    t7.loan_init_term,
  --'总期数'
    t1.loan_term,                                                                                                            --'还款期次'
    t1.should_repay_date,                                                                                                    --'应还日期'
    case when t1.due_bill_no = '1120123112250874213037' and t1.loan_term = 1 then '2021-01-01'
         when t1.due_bill_no = '1120123112250874213037' and t1.loan_term > 1 then '2021-01-04'
         else t3.biz_date end  as biz_date,                                                                                  --'实还日期'
         
    t1.paid_out_date,                                                                                                        --'核销日期'
    NULL AS fund_flow_date,                                                                                                  --'资金流日期' 
    NULL AS fund_flow_status,                                                                                                --'资金流状态'                                                                                                                          
    IF( paid_out_date > should_repay_date, datediff( paid_out_date, should_repay_date ), 0 ) AS overdue_days,                --'逾期天数'
    
    case when t1.due_bill_no = '1120123112250874213037' and t1.loan_term = 1 then '线上还款'
         when t1.due_bill_no = '1120123112250874213037' and t1.loan_term > 1 then '退票/退车'
         else t3.repay_way end  as repay_way,                                                                                --'还款类型'
         
    case when t3.biz_date = '2020-06-20' and t1.due_bill_no = '1120061910384241252747' then 200.4
         when t3.biz_date = '2020-06-23' and t1.due_bill_no = '1120061910384241252747' then 200
         else t1.paid_amount end as paid_amount,                                                                             --'还款金额'
    case when t3.biz_date = '2020-06-20' and t1.due_bill_no = '1120061910384241252747' then 200
         when t3.biz_date = '2020-06-23' and t1.due_bill_no = '1120061910384241252747' then 200
         else t1.paid_principal end as paid_principal,                                                                       --'还款本金'
    case when t3.biz_date = '2020-06-20' and t1.due_bill_no = '1120061910384241252747' then 0.4
         when t3.biz_date = '2020-06-23' and t1.due_bill_no = '1120061910384241252747' then 0
         else t1.paid_interest end as paid_interest,                                                                         --'还款利息'
    ( nvl ( t1.paid_term_fee, 0 ) + nvl ( t1.paid_svc_fee, 0 ) ) AS paid_fee,                                                --'还款费用'
    t1.paid_penalty,                                                                                                         --'还款罚息'
    current_date() AS execution_date,                                                                                        --'跑批日期'
    t1.product_id                                                                                                            --'产品编号'
FROM
    ( SELECT 
    distinct
     due_bill_no
    ,loan_active_date
    ,loan_term
    ,should_repay_date
    ,paid_amount
    ,paid_principal
    ,paid_interest
    ,paid_term_fee
    ,paid_svc_fee
    ,paid_penalty
    ,paid_out_date
    ,product_id
    FROM 
    ods_new_s_cps.repay_schedule 
    WHERE 
    '${ST9}' BETWEEN s_d_date AND date_sub( e_d_date, 1 ) 
    AND schedule_status_cn = '已还清' 
    ) t1
    LEFT JOIN 
    (select 
    due_bill_no, 
    contract_no,
    loan_expire_date
    from ods_new_s_cps.loan_lending
    ) t2 
    ON t1.due_bill_no = t2.due_bill_no
    LEFT JOIN 
    duebillno_repayterm_repayway t3 
    ON t1.due_bill_no = t3.due_bill_no 
    AND t1.loan_term = t3.term
    JOIN 
    ( SELECT 
    DISTINCT 
    product_id, 
    channel_id, 
    project_id 
    FROM 
    dim_new.biz_conf
    where project_id in ('WS0009200001','WS0006200001','WS0006200002','WS0006200003')  
    ) t4 
    ON t1.product_id = t4.product_id
    LEFT JOIN due_bill_no_name t6
    ON t1.due_bill_no = t6.due_bill_no
    LEFT JOIN
    (SELECT
    due_bill_no,    
    loan_status,
    loan_init_principal,
    loan_init_term
    FROM 
    ods_new_s_cps.loan_info
    where 
    '${ST9}' BETWEEN s_d_date AND date_sub( e_d_date, 1 ) 
    ) t7
    on t1.due_bill_no = t7.due_bill_no
union all
SELECT
    t4.channel_id,                                                                                                           --'合同渠道方'
    t4.project_id,                                                                                                           --'项目名称'
    t2.contract_no,                                                                                                          --'合同编号'
    t1.due_bill_no,                                                                                                          --'借据编号'
    t7.loan_status,                                                                                                          --'借据状态'
    t1.loan_active_date,                                                                                                     --'借据生效日'
    t2.loan_expire_date,                                                                                                     --'借据到期日'
    t6.dim_decrypt AS customer_name,                                                                                         --'客户姓名'
    t7.loan_init_principal,
  --'借款金额'
    t7.loan_init_term,
  --'总期数'
    t1.loan_term,                                                                                                            --'还款期次'
    t1.should_repay_date,                                                                                                    --'应还日期'
    case when t1.due_bill_no = '1120123112250874213037' and t1.loan_term = 1 then '2021-01-01'
         when t1.due_bill_no = '1120123112250874213037' and t1.loan_term > 1 then '2021-01-04'
         else t3.biz_date end  as biz_date,                                                                                  --'实还日期'

    t1.paid_out_date,                                                                                                        --'核销日期'
    NULL AS fund_flow_date,                                                                                                  --'资金流日期'
    NULL AS fund_flow_status,                                                                                                --'资金流状态'
    IF( paid_out_date > should_repay_date, datediff( paid_out_date, should_repay_date ), 0 ) AS overdue_days,                --'逾期天数'

    case when t1.due_bill_no = '1120123112250874213037' and t1.loan_term = 1 then '线上还款'
         when t1.due_bill_no = '1120123112250874213037' and t1.loan_term > 1 then '退票/退车'
         else t3.repay_way end  as repay_way,                                                                                --'还款类型'

    case when t3.biz_date = '2020-06-20' and t1.due_bill_no = '1120061910384241252747' then 200.4
         when t3.biz_date = '2020-06-23' and t1.due_bill_no = '1120061910384241252747' then 200
         else t1.paid_amount end as paid_amount,                                                                             --'还款金额'
    case when t3.biz_date = '2020-06-20' and t1.due_bill_no = '1120061910384241252747' then 200
         when t3.biz_date = '2020-06-23' and t1.due_bill_no = '1120061910384241252747' then 200
         else t1.paid_principal end as paid_principal,                                                                       --'还款本金'
    case when t3.biz_date = '2020-06-20' and t1.due_bill_no = '1120061910384241252747' then 0.4
         when t3.biz_date = '2020-06-23' and t1.due_bill_no = '1120061910384241252747' then 0
         else t1.paid_interest end as paid_interest,                                                                         --'还款利息'
    ( nvl ( t1.paid_term_fee, 0 ) + nvl ( t1.paid_svc_fee, 0 ) ) AS paid_fee,                                                --'还款费用'
    t1.paid_penalty,                                                                                                         --'还款罚息'
    current_date() AS execution_date,                                                                                        --'跑批日期'
    t1.product_id                                                                                                            --'产品编号'
FROM
    ( SELECT
    distinct
     due_bill_no
    ,loan_active_date
    ,loan_term
    ,should_repay_date
    ,paid_amount
    ,paid_principal
    ,paid_interest
    ,paid_term_fee
    ,paid_svc_fee
    ,paid_penalty
    ,paid_out_date
    ,product_id
    FROM
    ods_new_s.repay_schedule
    WHERE
    '${ST9}' BETWEEN s_d_date AND date_sub( e_d_date, 1 )
    AND schedule_status_cn = '已还清'
    ) t1
    LEFT JOIN
    (select
    due_bill_no,
    contract_no,
    loan_expire_date
    from ods_new_s.loan_lending
    ) t2
    ON t1.due_bill_no = t2.due_bill_no
    LEFT JOIN
    duebillno_repayterm_repayway t3
    ON t1.due_bill_no = t3.due_bill_no
    AND t1.loan_term = t3.term
    JOIN
    ( SELECT
    DISTINCT
    product_id,
    channel_id,
    project_id
    FROM
    dim_new.biz_conf
    where project_id in ('bd')
    ) t4
    ON t1.product_id = t4.product_id
    LEFT JOIN due_bill_no_name t6
    ON t1.due_bill_no = t6.due_bill_no
    LEFT JOIN
    (SELECT
    due_bill_no,
    loan_status,
    loan_init_principal,
    loan_init_term
    FROM
    ods_new_s.loan_info
    where
    '${ST9}' BETWEEN s_d_date AND date_sub( e_d_date, 1 )
    ) t7
    on t1.due_bill_no = t7.due_bill_no
;

insert overwrite table dm_eagle.operation_daily_repay_detail partition(product_id)
select
    channel_id,                                                                                                 --'合同渠道方'
    project_id,                                                                                                 --'项目名称'
    contract_no,                                                                                                --'合同编号'
    t1.due_bill_no,                                                                                             --'借据编号'
    schedule_status,                                                                                            --'借据状态'
    loan_active_date,                                                                                           --'借据生效日'
    loan_expire_date,                                                                                           --'借据到期日'
    customer_name,                                                                                              --'客户姓名'  
    loan_init_principal,                                                                                        --'借款金额'
    loan_init_term,                                                                                             --'总期数'
    loan_term,                                                                                                  --'还款期次'
    should_repay_date,                                                                                          --'应还日期'
    if(t1.biz_date is null, t1.paid_out_date, t1.biz_date) as biz_date,                                         --'实还日期'
    paid_out_date,                                                                                              --'核销日期'
    fund_flow_date,                                                                                             --'资金流日期' 
    fund_flow_status,                                                                                           --'资金流状态' 
    overdue_days,                                                                                               --'逾期天数'
    if(t1.repay_way is  null, t2.repay_way, t1.repay_way) as repay_way,                                         --'还款类型'
    paid_amount,                                                                                                --'还款金额'
    paid_principal,                                                                                             --'还款本金'
    paid_interest,                                                                                              --'还款利息'
    paid_fee,                                                                                                   --'还款费用'
    paid_penalty,                                                                                               --'还款罚息'
    execution_date,                                                                                             --'跑批日期'
    product_id   
from
dm_eagle.operation_daily_repay_detail_temp t1
left join
(select
due_bill_no
,repay_way
from
(select
due_bill_no
,repay_way
,row_number() over(partition by due_bill_no order by loan_term desc) rn
from
dm_eagle.operation_daily_repay_detail_temp b
where b.biz_date is not null
and b.repay_way is not null)
c where c.rn = 1
) t2
on 
t1.due_bill_no = t2.due_bill_no
;

