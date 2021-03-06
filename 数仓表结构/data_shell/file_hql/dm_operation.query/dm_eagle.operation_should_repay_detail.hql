set mapred.job.name=dm_eagle.operation_should_repay_detail;
set hive.execution.engine=mr;
set mapreduce.map.memory.mb=2048;
set mapreduce.reduce.memory.mb=2048;
set hive.exec.parallel=true;
set hive.exec.parallel.thread.number=10;
set hive.exec.dynamic.partition=true;
set hive.exec.dynamic.partition.mode=nonstrict
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

--set hivevar:ST9=2020-10-01;
--应还款明细报表 （取最新的数据）
--drop table if exists dm_eagle.operation_should_repay_detail;
--create table if not exists dm_eagle.operation_should_repay_detail(
--    channel_id               string            COMMENT '合同渠道方'
--   ,project_id               string            COMMENT '项目名称'
--   ,contract_no              string            COMMENT '合同编号'
--   ,due_bill_no              string            COMMENT '借据编号'
--   ,loan_active_date         string            COMMENT '借据生效日'
--   ,customer_name            string            COMMENT '客户姓名'  
--   ,loan_init_term           decimal(3,0)      COMMENT '总期数'
--   ,should_repay_date        string            COMMENT '应还日期'
--   ,loan_term                decimal(3,0)      COMMENT '期次'
--   ,should_repay_amount      decimal(15,4)     COMMENT '应还金额'
--   ,should_repay_principal   decimal(15,4)     COMMENT '应还本金'
--   ,should_repay_interest    decimal(15,4)     COMMENT '应还利息'
--   ,should_repay_fee         decimal(15,4)     COMMENT '应还费用'
--   ,should_repay_penalty     decimal(15,4)     COMMENT '应还罚息'
--   ,execution_date           string            COMMENT '跑批日期'
--) COMMENT '应还款明细报表'
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


insert overwrite table dm_eagle.operation_should_repay_detail partition(product_id)                       
SELECT
 distinct                                                                                                    
 t3.channel_id                                                                                        --'合作渠道方'
,t3.project_id                                                                                        --'项目名称'
,t2.contract_no                                                                                       --'合同编号'
,t1.due_bill_no                                                                                       --'借据编号'
,t1.loan_active_date                                                                                  --'借据生效日'
,t4.dim_decrypt AS customer_name                                                                      --'客户姓名'  
,t1.loan_init_term                                                                                    --'总期数'
,t1.should_repay_date                                                                                 --'应还日期'
,t1.loan_term                                                                                         --'期次'
,t1.should_repay_amount                                                                               --'应还金额'
,t1.should_repay_principal                                                                            --'应还本金'
,t1.should_repay_interest                                                                             --'应还利息'
,( nvl ( t1.should_repay_term_fee, 0 ) + nvl ( t1.should_repay_svc_fee, 0 ) ) AS should_repay_fee     --'应还费用'
,t1.should_repay_penalty                                                                              --'应还罚息'
,current_date() AS execution_date                                                                     --'跑批日期'
,t1.product_id                                                                                        --'产品名称'
FROM 
(
SELECT 
*
FROM ods_new_s_cps.repay_schedule
WHERE '${ST9}' BETWEEN s_d_date AND date_sub(e_d_date, 1)
) t1
LEFT JOIN 
(select 
due_bill_no, 
contract_no
from 
ods_new_s_cps.loan_lending
) t2
ON t1.due_bill_no = t2.due_bill_no
 JOIN 
(SELECT 
DISTINCT 
product_id, 
channel_id, 
project_id
FROM dim_new.biz_conf
where project_id in ('WS0009200001','WS0006200001','WS0006200002','WS0006200003')
) t3
ON t1.product_id = t3.product_id
LEFT JOIN 
due_bill_no_name t4
ON t1.due_bill_no = t4.due_bill_no
union all
SELECT
 distinct
 t3.channel_id                                                                                        --'合作渠道方'
,t3.project_id                                                                                        --'项目名称'
,t2.contract_no                                                                                       --'合同编号'
,t1.due_bill_no                                                                                       --'借据编号'
,t1.loan_active_date                                                                                  --'借据生效日'
,t4.dim_decrypt AS customer_name                                                                      --'客户姓名'
,t1.loan_init_term                                                                                    --'总期数'
,t1.should_repay_date                                                                                 --'应还日期'
,t1.loan_term                                                                                         --'期次'
,t1.should_repay_amount                                                                               --'应还金额'
,t1.should_repay_principal                                                                            --'应还本金'
,t1.should_repay_interest                                                                             --'应还利息'
,( nvl ( t1.should_repay_term_fee, 0 ) + nvl ( t1.should_repay_svc_fee, 0 ) ) AS should_repay_fee     --'应还费用'
,t1.should_repay_penalty                                                                              --'应还罚息'
,current_date() AS execution_date                                                                     --'跑批日期'
,t1.product_id                                                                                        --'产品名称'
FROM
(
SELECT
*
FROM ods_new_s.repay_schedule
WHERE '${ST9}' BETWEEN s_d_date AND date_sub(e_d_date, 1)
) t1
LEFT JOIN
(select
due_bill_no,
contract_no
from
ods_new_s.loan_lending
) t2
ON t1.due_bill_no = t2.due_bill_no
 JOIN
(SELECT
DISTINCT
product_id,
channel_id,
project_id
FROM dim_new.biz_conf
where project_id in ('bd')
) t3
ON t1.product_id = t3.product_id
LEFT JOIN
due_bill_no_name t4
ON t1.due_bill_no = t4.due_bill_no
;
    
    
    
