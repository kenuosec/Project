set hive.execution.engine=mr;
set mapreduce.map.memory.mb=4096;
set mapreduce.reduce.memory.mb=4096;
set hive.exec.parallel=true;
--set hive.exec.parallel.thread.number=12;
set mapred.job.queue.name=hive;
set spark.app.name="bill_cript";
SET hivevar:ST9=2020-11-30;
set mapreduce.input.fileinputformat.split.maxsize=1024000000;
set hivevar:product_id_list='001801','001802','001901','001902','001903','001904','001905','001906','001907','002001','002002','002003','002004','002005','002006','002007';

with due_bill_no_schedule as(
select
t1.due_bill_no
,concat('{',concat_ws(',',collect_list(concat('"',loan_term,'"',':','{',concat_ws(',',
 concat('"','schedule_id'              , '"', ':', '"',   schedule_id              ,'"')
,concat('"','due_bill_no'              , '"', ':', '"',   t1.due_bill_no           ,'"')
,concat('"','loan_active_date'         , '"', ':', '"',   loan_active_date         ,'"')
,concat('"','loan_init_principal'      , '"', ':', '"',   loan_init_principal      ,'"')
,concat('"','loan_init_term'           , '"', ':', '"',   loan_init_term           ,'"')
,concat('"','loan_term'                , '"', ':', '"',   loan_term                ,'"')
,concat('"','start_interest_date'      , '"', ':', '"',   start_interest_date      ,'"')
,concat('"','curr_bal'                 , '"', ':', '"',   curr_bal                 ,'"')
,concat('"','should_repay_date'        , '"', ':', '"',   should_repay_date        ,'"')
,concat('"','should_repay_date_history', '"', ':', '"',   should_repay_date_history,'"')
,concat('"','grace_date'               , '"', ':', '"',   grace_date               ,'"')
,concat('"','should_repay_amount'      , '"', ':', '"',   should_repay_amount      ,'"')
,concat('"','should_repay_principal'   , '"', ':', '"',   should_repay_principal   ,'"')
,concat('"','should_repay_interest'    , '"', ':', '"',   should_repay_interest    ,'"')
,concat('"','should_repay_term_fee'    , '"', ':', '"',   should_repay_term_fee    ,'"')
,concat('"','should_repay_svc_fee'     , '"', ':', '"',   should_repay_svc_fee     ,'"')
,concat('"','should_repay_penalty'     , '"', ':', '"',   should_repay_penalty     ,'"')
,concat('"','should_repay_mult_amt'    , '"', ':', '"',   should_repay_mult_amt    ,'"')
,concat('"','should_repay_penalty_acru', '"', ':', '"',   should_repay_penalty_acru,'"')
,concat('"','schedule_status'          , '"', ':', '"',   schedule_status          ,'"')
,concat('"','schedule_status_cn'       , '"', ':', '"',   schedule_status_cn       ,'"')
,concat('"','paid_out_date'            , '"', ':', '"',   paid_out_date            ,'"')
,concat('"','paid_out_type'            , '"', ':', '"',   paid_out_type            ,'"')
,concat('"','paid_out_type_cn'         , '"', ':', '"',   paid_out_type_cn         ,'"')
,concat('"','paid_amount'              , '"', ':', '"',   paid_amount              ,'"')
,concat('"','paid_principal'           , '"', ':', '"',   paid_principal           ,'"')
,concat('"','paid_interest'            , '"', ':', '"',   paid_interest            ,'"')
,concat('"','paid_term_fee'            , '"', ':', '"',   paid_term_fee            ,'"')
,concat('"','paid_svc_fee'             , '"', ':', '"',   paid_svc_fee             ,'"')
,concat('"','paid_penalty'             , '"', ':', '"',   paid_penalty             ,'"')
,concat('"','paid_mult'                , '"', ':', '"',   paid_mult                ,'"')
,concat('"','reduce_amount'            , '"', ':', '"',   reduce_amount            ,'"')
,concat('"','reduce_principal'         , '"', ':', '"',   reduce_principal         ,'"')
,concat('"','reduce_interest'          , '"', ':', '"',   reduce_interest          ,'"')
,concat('"','reduce_term_fee'          , '"', ':', '"',   reduce_term_fee          ,'"')
,concat('"','reduce_svc_fee'           , '"', ':', '"',   reduce_svc_fee           ,'"')
,concat('"','reduce_penalty'           , '"', ':', '"',   reduce_penalty           ,'"')
,concat('"','reduce_mult_amt'          , '"', ':', '"',   reduce_mult_amt          ,'"')
,concat('"','s_d_date'                 , '"', ':', '"',   s_d_date                 ,'"')
,concat('"','e_d_date'                 , '"', ':', '"',   e_d_date                 ,'"')
,concat('"','effective_time'           , '"', ':', '"',   effective_time           ,'"')
,concat('"','expire_time'              , '"', ':', '"',   expire_time              ,'"')
),'}'))),'}') as schedule
from
(
select
*
from
ods_new_s.repay_schedule
where
'${ST9}' between s_d_date and date_sub(e_d_date,1)  and  product_id in (${product_id_list})
) t1
join
(select 
due_bill_no 
from 
ods_new_s.rand_billno_1000000_for_risk
) t2
on t1.due_bill_no = t2.due_bill_no
group by t1.due_bill_no
)

INSERT OVERWRITE TABLE eagle.one_million_random_loan_data_day PARTITION(biz_date = '${ST9}')
select
 t3.due_bill_no                                             --'????????????'
,t3.product_id                                              --'????????????'
,null as risk_level                                         --'????????????'
,t3.loan_init_principal                                     --'????????????'
,t3.loan_init_term                                          --'????????????'
,t3.loan_init_interest_rate                                 --'???????????????8d/%???'
,t4.credit_coef                                             --'?????????????????????8d/%???'
,t3.loan_init_penalty_rate                                  --'???????????????8d/%???'
,t3.loan_active_date                                        --'????????????'
,if(t3.loan_status = 'F','???','???') as is_settled           --'????????????'
,t3.paid_out_date                                           --'????????????'
,t3.loan_out_reason                                         --'??????????????????'
,t3.paid_out_type                                           --'????????????'
,t5.schedule as schedule_detail                             --'????????????-?????????????????????????????????????????????'
,t3.Loan_status                                             --'????????????'
,t3.paid_amount                                             --'????????????'
,t3.paid_principal                                          --'????????????'
,t3.paid_interest                                           --'????????????'
,t3.paid_penalty                                            --'????????????'
,t3.paid_svc_fee                                            --'???????????????'
,t3.paid_term_fee                                           --'???????????????'
,t3.paid_mult                                               --'???????????????'
,t3.remain_amount                                           --'????????????????????????'
,t3.remain_principal                                        --'????????????'
,t3.remain_interest                                         --'????????????'
,t3.remain_svc_fee                                          --'???????????????'
,t3.remain_term_fee                                         --'???????????????'
,t3.overdue_principal                                       --'????????????'
,t3.overdue_interest                                        --'????????????'
,t3.overdue_svc_fee                                         --'???????????????'
,t3.overdue_term_fee                                        --'???????????????'
,t3.overdue_penalty                                         --'????????????'
,t3.overdue_mult_amt                                        --'???????????????'
,t3.overdue_date_first                                      --'??????????????????'
,t3.overdue_date_start                                      --'??????????????????'
,t3.overdue_days                                            --'????????????'
,t3.overdue_date                                            --'????????????'
,t3.dpd_begin_date                                          --'DPD????????????'
,t3.dpd_days                                                --'DPD??????'
,t3.dpd_days_count                                          --'??????DPD??????'
,t3.dpd_days_max                                            --'????????????DPD??????'
,t3.collect_out_date                                        --'????????????'
,t3.overdue_term                                            --'??????????????????'
,t3.overdue_terms_count                                     --'??????????????????'
,t3.overdue_terms_max                                       --'??????????????????????????????'
,t3.overdue_principal_accumulate                            --'??????????????????'
,t3.overdue_principal_max                                   --'????????????????????????'
from
(select
 t1.loan_init_interest_rate
,t1.loan_init_penalty_rate
,t2.*
from
ods_new_s.rand_billno_1000000_for_risk t1
join
(select 
* 
from 
ods_new_s.loan_info 
where 
'${ST9}' between s_d_date
and date_sub(e_d_date,1) and   product_id in (${product_id_list})
) t2
on t1.due_bill_no = t2.due_bill_no
and t1.product_id = t2.product_id
) t3
left join
(
select
distinct
due_bill_no
,credit_coef
,product_id
from
ods_new_s.loan_apply
where  product_id in (${product_id_list})
) t4
on t3.due_bill_no = t4.due_bill_no
and t3.product_id = t4.product_id
left join
due_bill_no_schedule t5
on t3.due_bill_no = t5.due_bill_no
;

insert overwrite table eagle.one_million_random_customer_reqdata
select
--count(*)
distinct
 t1.due_bill_no          
,t1.product_id           
,t1.creditLimit          
,t1.creditCoef           
,t1.availableCreditLimit 
,t1.edu                  
,t1.degree               
,t1.homests              
,t1.marriage             
,t1.mincome              
,t1.income               
,t1.homeIncome           
,t1.zxhomeIncome         
,t1.custType             
,t1.workWay              
,t1.workType             
,t1.workDuty             
,t1.workTitle            
,t1.appUse               
,t1.ifCar                
,t1.ifCarCred            
,t1.ifRoom               
,t1.ifMort               
,t1.ifCard               
,t1.cardAmt              
,t1.ifApp                
,t1.ifId                 
,t1.ifPact               
,t1.ifLaunder            
,t1.launder              
,t1.ifAgent              
,t1.isBelowRisk          
,t1.hasOverdueLoan       
,t2.idcard_area          
,t2.resident_area 
,t1.riskLevel      
from
(
select
distinct
get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.applyNo')                                       as due_bill_no  
,sha256(get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.idNo'),'idNumber',1)                    as user_hash_no
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.proCode')                                      as product_id
,cast(get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.creditLimit' )         as decimal(10,2))  as creditLimit
,cast(get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.creditCoef')           as decimal(10,2))  as creditCoef          
,cast(get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.availableCreditLimit') as decimal(10,2))  as availableCreditLimit
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.edu'                 )                         as edu
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.degree'              )                         as degree                                                               
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.homeSts'             )                         as homeSts
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.marriage'            )                         as marriage
,cast(get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.mincome') as decimal(10,2))               as mincome
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.income'              )                         as income
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.homeIncome'          )                         as homeIncome
,cast(get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.zxhomeIncome' )as decimal(10,2))          as zxhomeIncome
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.custType'            )                         as custType
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.workWay'             )                         as workWay
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.workType'            )                         as workType                                                                  
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.workDuty'            )                         as workDuty
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.workTitle'           )                         as workTitle

,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.appUse')                                       as appUse
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.ifCar')                                        as ifCar
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.ifCarCred')                                    as ifCarCred
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.ifRoom')                                       as ifRoom
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.ifMort')                                       as ifMort
                                                                                                      
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.ifCard')                                       as ifCard
,cast(get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.cardAmt') as decimal(10,2))               as cardAmt
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.ifApp')                                        as ifApp
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.ifId')                                         as ifId
                                                                                                      
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.ifPact')                                       as ifPact
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.ifLaunder')                                    as ifLaunder
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.launder')                                      as launder
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.ifAgent')                                      as ifAgent
                                                                                                                               
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.isBelowRisk')                                  as isBelowRisk
,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.hasOverdueLoan')                               as hasOverdueLoan

,get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.riskLevel')                                    as riskLevel

from
(select
datefmt(create_time,'ms','yyyy-MM-dd HH:mm:ss') as create_time,
datefmt(update_time,'ms','yyyy-MM-dd HH:mm:ss') as update_time,
regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(original_msg,'\\\\\"\\\{','\\\{'),'\\\}\\\\\"','\\\}'),'\\\"\\\{','\\\{'),'\\\}\\\"','\\\}'),'\\\\\\\\\\\\\"','\\\"'),'\\\\\"','\\\"'),'\\\\\\\\','\\\\') as original_msg
-- regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(regexp_replace(original_msg,'\\\\\"\{','\{'),'\}\\\\\"','\}'),'\"\{','\{'),'\}\"','\}'),'\\\\\\\\\\\\\"','\"'),'\\\\\"','\"'),'\\\\\\\\','\\\\') as original_msg
from ods.ecas_msg_log
where 1 > 0
and msg_type = 'WIND_CONTROL_CREDIT'
and original_msg is not null
and get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.proCode') in (${product_id_list})
--and deal_date between date_sub('${ST9}',2) and '${ST9}'
-- and deal_date between '2020-12-01' and '2020-12-27'
-- and deal_date like '2020-11%'
) loan_apply
join
ods_new_s.rand_billno_1000000_for_risk rand_bill
on get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.applyNo') = rand_bill.due_bill_no
and get_json_object(loan_apply.original_msg,'$.reqContent.jsonReq.content.reqData.proCode')  = rand_bill.product_id
) t1
inner join
(select user_hash_no,max(idcard_area) as idcard_area, max(resident_area) as resident_area from ods_new_s.customer_info where  product_id in (${product_id_list})  group by user_hash_no) t2
on t1.user_hash_no = t2.user_hash_no
;

--create table eagle.one_million_random_risk_data (
--due_bill_no             string
--,product_id              string
--,risk_level              string
--,loan_init_principal     decimal(15,4)
--,loan_init_term          decimal(15,4)
--,loan_init_interest_rate decimal(15,4)
--,credit_coef             decimal(15,4)
--,loan_init_penalty_rate  decimal(15,4)
--,loan_active_date        string
--,settled                 string
--,paid_out_date           string
--,loan_out_reason         string
--,paid_out_type           string
--,schedule                string
--,loan_status             string
--,paid_amount             decimal(15,4)
--,paid_principal          decimal(15,4)
--,paid_interest           decimal(15,4)
--,paid_penalty            decimal(15,4)
--,paid_svc_fee            decimal(15,4)
--,paid_term_fee           decimal(15,4)
--,paid_mult               decimal(15,4)
--,remain_amount           decimal(15,4)
--,remain_principal        decimal(15,4)
--,remain_interest         decimal(15,4)
--,remain_svc_fee          decimal(15,4)
--,remain_term_fee         decimal(15,4)
--,overdue_principal       decimal(15,4)
--,overdue_interest        decimal(15,4)
--,overdue_svc_fee         decimal(15,4)
--,overdue_term_fee        decimal(15,4)
--,overdue_penalty         decimal(15,4)
--,overdue_mult_amt        decimal(15,4)
--,overdue_date_first      string
--,overdue_date_start      string
--,overdue_days            decimal(5,0)
--,overdue_date            string
--,dpd_begin_date          string
--,dpd_days                decimal(4,0)
--,dpd_days_count          decimal(4,0)
--,dpd_days_max            decimal(4,0)
--,collect_out_date        string
--,overdue_term            decimal(3,0)
--,overdue_terms_count     decimal(3,0)
--,overdue_terms_max       decimal(3,0)
--,overdue_principal_accumulate    decimal(15,4)
--,overdue_principal_max   decimal(15,4)
--,biz_date                string
--,creditlimit             decimal(10,2)
--,edu                     string
--,degree                  string
--,homests                 string
--,marriage                string
--,mincome                 decimal(10,2)
--,homeincome              string
--,zxhomeincome            decimal(10,2)
--,custtype                string
--,worktype                string
--,workduty                string
--,worktitle               string
--,idcard_area             string
--,risklevel               string
--,scorerange              string
--) comment "100???????????????????????????"
--STORED AS PARQUET;
insert overwrite table eagle.one_million_random_risk_data partition (cycle_key='0')
select
t1.*         
,t2.creditLimit as creditlimit --         
--,t2.creditCoef as credit_coef --          
--,availableCreditLimit 
,t2.edu  --                  
,t2.degree --               
,t2.homests --             
,t2.marriage --            
,t2.mincome    --             
--,income               
,t2.homeIncome as homeincome --         
,t2.zxhomeIncome as zxhomeincome --        
,t2.custType  as custtype --           
--,workWay              
,t2.workType             
,t2.workDuty as workduty  --          
,t2.workTitle as worktitle --          
--,appUse               
--,ifCar                
--,ifCarCred            
--,ifRoom               
--,ifMort               
--,ifCard               
--,cardAmt              
--,ifApp                
--,ifId                 
--,ifPact               
--,ifLaunder            
--,launder              
--,ifAgent              
--,isBelowRisk          
--,hasOverdueLoan       
,t2.idcard_area  --        
--,resident_area
,t2.riskLevel
,'6' AS scoreRange         
from
(select * from eagle.one_million_random_loan_data_day  where biz_date='${ST9}'  )t1
join
eagle.one_million_random_customer_reqdata t2
on
t1.due_bill_no = t2.due_bill_no
and 
t1.product_id = t2.product_id
;