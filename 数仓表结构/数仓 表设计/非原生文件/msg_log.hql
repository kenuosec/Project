-- dwb.dwb_dd_log_detail
select
  ecif_no                                                          as ecif_id,
  get_json_object(original_msg,'$.userInfo.name')                  as name,
  get_json_object(original_msg,'$.userInfo.cardNo')                as cardno,
  null                                                             as idtype,
  get_json_object(original_msg,'$.userInfo.phone')                 as phone,
  get_json_object(original_msg,'$.userInfo.telephone')             as telephone,
  get_json_object(original_msg,'$.userInfo.bankCardNo')            as bankcardno,
  get_json_object(original_msg,'$.userInfo.userRole')              as userrole,
  get_json_object(original_msg,'$.userInfo.idCardValidDate')       as idcardvaliddate,
  get_json_object(original_msg,'$.userInfo.address')               as address,
  get_json_object(original_msg,'$.userInfo.ocrInfo')               as ocrinfo,
  get_json_object(original_msg,'$.userInfo.idCardBackInfo')        as idcardbackinfo,
  get_json_object(original_msg,'$.userInfo.imageType')             as imagetype,
  null                                                             as imagestatus,
  null                                                             as imageurl,
  get_json_object(original_msg,'$.userInfo.livingImageInfo')       as livingimageinfo,
  get_json_object(original_msg,'$.userInfo.sftpDir')               as sftpdir,
  null                                                             as sftp,
  get_json_object(original_msg,'$.creditInfo.amount')              as amount,
  get_json_object(original_msg,'$.creditInfo.interestRate')        as interestrate,
  get_json_object(original_msg,'$.creditInfo.interestPenaltyRate') as interestpenaltyrate,
  get_json_object(original_msg,'$.creditInfo.startDate')           as startdate,
  get_json_object(original_msg,'$.creditInfo.endDate')             as enddate,
  get_json_object(original_msg,'$.creditInfo.lockDownEndTime')     as lockdownendtime,
  get_json_object(original_msg,'$.didiRcFeature')                  as didircfeature,
  get_json_object(original_msg,'$.flowNo')                         as flowno,
  get_json_object(original_msg,'$.signType')                       as signtype,
  get_json_object(original_msg,'$.applicationId')                  as applicationid,
  get_json_object(original_msg,'$.creditResultStatus')             as creditresultstatus, -- Yes,No
  get_json_object(original_msg,'$.applySource')                    as applysource,
  deal_date                                                        as deal_date,
  create_time                                                      as create_time,
  update_time                                                      as update_time,
  'DIDI201908161538'                                               as product_code,
  org                                                              as org
from (
  select
    org,
    deal_date,
    create_time,
    update_time,
    original_msg
  from ods.ecas_msg_log
  where msg_type = 'CREDIT_APPLY'
  and original_msg is not null
  and (
    get_json_object(original_msg,'$.applicationId') is null
    or length(get_json_object(original_msg,'$.applicationId')) >= 20
  )
) as msg_log
left join (
  select id_no,ecif_no from ecif_core.ecif_customer
) as ecif_customer
on encrypt_aes(get_json_object(msg_log.original_msg,'$.userInfo.cardNo'),'weshare666') = ecif_customer.id_no
limit 10;











-- ??????
select
  id as id,
  agency_id as agency_id,
  project_id as project_id,
  partition_key as partition_key,
  create_time as create_time,
  update_time as update_time,
  15601 as org,
  get_json_object(requst_data,'$.product_no') as product_no,
  get_json_object(requst_data,'$.request_no') as request_no,
  get_json_object(requst_data,'$.loan_apply_use') as loan_apply_use,
  get_json_object(requst_data,'$.loan_rate_type') as loan_rate_type,
  get_json_object(requst_data,'$.currency_type') as currency_type,
  get_json_object(requst_data,'$.contract_no') as contract_no,
  get_json_object(requst_data,'$.contract_amount') as contract_amount,
  get_json_object(requst_data,'$.company_loan_bool') as company_loan_bool,
  get_json_object(requst_data,'$.guaranties') as guaranties,
  get_json_object(requst_data,'$.relational_humans') as relational_humans,
  get_json_object(requst_data,'$.repayment_account') as repayment_account,
  get_json_object(requst_data,'$.loan_account') as loan_account,
  get_json_object(requst_data,'$.car') as car,
  get_json_object(requst_data,'$.borrower.open_id') as open_id,
  get_json_object(requst_data,'$.borrower.name') as name,
  get_json_object(requst_data,'$.borrower.id_type') as id_type,
  get_json_object(requst_data,'$.borrower.id_no') as id_no,
  ecif_no as ecif_id,
  if(get_json_object(requst_data,'$.borrower.sex') is null or length(get_json_object(requst_data,'$.borrower.sex')) = 0,
    sex_idno(get_json_object(requst_data,'$.borrower.id_no')),
    case get_json_object(requst_data,'$.borrower.sex')
    when 'F' then '???' when 'M' then '???'
    else get_json_object(requst_data,'$.borrower.sex')
    end
  ) as sex,
  if(get_json_object(requst_data,'$.borrower.age') is null or length(get_json_object(requst_data,'$.borrower.age')) = 0,
    year(get_json_object(requst_data,'$.schedule_base.loan_date')) - cast(datefmt(substring(get_json_object(requst_data,'$.borrower.id_no'),7,8),'yyyyMMdd','yyyy') as int),
    cast(get_json_object(requst_data,'$.borrower.age') as int)
  ) as age,
  get_json_object(requst_data,'$.borrower.mobile_phone') as mobile_phone,
  get_json_object(requst_data,'$.borrower.province') as province,
  get_json_object(requst_data,'$.borrower.city') as city,
  get_json_object(requst_data,'$.borrower.area') as area,
  get_json_object(requst_data,'$.borrower.address') as address,
  get_json_object(requst_data,'$.borrower.marital_status') as marital_status,
  get_json_object(requst_data,'$.borrower.education') as education,
  get_json_object(requst_data,'$.borrower.industry') as industry,

  get_json_object(requst_data,'$.borrower.annual_income') as annual_income,
  get_json_object(requst_data,'$.borrower.have_house') as have_house,
  get_json_object(requst_data,'$.borrower.housing_area') as housing_area,
  get_json_object(requst_data,'$.borrower.housing_value') as housing_value,
  get_json_object(requst_data,'$.borrower.family_worth') as family_worth,

  get_json_object(requst_data,'$.borrower.front_url') as front_url,
  get_json_object(requst_data,'$.borrower.back_url') as back_url,

  get_json_object(requst_data,'$.borrower.private_owners') as private_owners,
  get_json_object(requst_data,'$.borrower.income_m1') as income_m1,
  get_json_object(requst_data,'$.borrower.income_m2') as income_m2,
  get_json_object(requst_data,'$.borrower.income_m3') as income_m3,
  get_json_object(requst_data,'$.borrower.income_m4') as income_m4,
  get_json_object(requst_data,'$.borrower.social_credit_code') as social_credit_code,
  get_json_object(requst_data,'$.borrower.company_name') as company_name,

  get_json_object(requst_data,'$.borrower.industry') as industry,
  get_json_object(requst_data,'$.borrower.legal_person_name') as legal_person_name,
  get_json_object(requst_data,'$.borrower.legal_person_phone') as legal_person_phone,
  get_json_object(requst_data,'$.borrower.phone') as phone,
  get_json_object(requst_data,'$.borrower.operate_years') as operate_years,
  get_json_object(requst_data,'$.schedule_base.repay_type') as repay_type,
  get_json_object(requst_data,'$.schedule_base.repay_frequency') as repay_frequency,
  get_json_object(requst_data,'$.schedule_base.terms') as terms,
  get_json_object(requst_data,'$.schedule_base.deduction_date') as deduction_date,
  get_json_object(requst_data,'$.schedule_base.loan_rate') as loan_rate,
  get_json_object(requst_data,'$.schedule_base.year_rate_base') as year_rate_base,
  get_json_object(requst_data,'$.schedule_base.loan_date') as loan_date,
  get_json_object(requst_data,'$.schedule_base.loan_end_date') as loan_end_date,
  get_json_object(resp_data,'$.apply_request_no') as apply_request_no,
  get_json_object(resp_data,'$.acct_setup_ind') as acct_setup_ind
from (
  select
    id,
    agency_id,
    project_id,
    partition_key,
    create_time,
    update_time,
    requst_data,
    resp_data
  from ods.t_real_param
  where interface_name = 'LOAN_INFO_PER_APPLY'
  and agency_id = '0004'
  and requst_data is not null
) as t_real_param
left join (
  select id_no,ecif_no from ecif_core.ecif_customer_hive
) as ecif_customer
on encrypt_aes(get_json_object(t_real_param.requst_data,'$.borrower.id_no')) = ecif_customer.id_no
limit 10;









-- ??????
select
  case get_json_object(standard_resp_msg,'$.acct_setup_ind')
  when 'Y' then '??????' when 'N' then '??????'
  else get_json_object(standard_resp_msg,'$.acct_setup_ind')
  end as acct_setup_ind,
  get_json_object(standard_resp_msg,'$.cust_no') as cust_no,
  get_json_object(standard_resp_msg,'$.reject_msg') as reject_msg,

  get_json_object(standard_req_msg,'$.pre_apply_no') as pre_apply_no,
  get_json_object(standard_req_msg,'$.apply_no') as apply_no,
  get_json_object(standard_req_msg,'$.company_loan_bool') as company_loan_bool,
  get_json_object(standard_req_msg,'$.relational_humans') as relational_humans,
  get_json_object(standard_req_msg,'$.guaranties') as guaranties,

  -- get_json_object(standard_req_msg,'$.car') as car -- car ??? guaranties ???

  get_json_object(standard_req_msg,'$.product.product_no') as product_no,
  case get_json_object(standard_req_msg,'$.product.currency_type')
  when 'RMB' then '?????????'
  else get_json_object(standard_req_msg,'$.product.currency_type')
  end                                                          as currency_type,
  get_json_object(standard_req_msg,'$.product.currency_amt') as currency_amt,
  get_json_object(standard_req_msg,'$.product.loan_amt') as loan_amt,
  get_json_object(standard_req_msg,'$.product.loan_terms') as loan_terms,
  case get_json_object(standard_req_msg,'$.product.repay_type')
  when 'RT01' then '????????????'
  when 'RT02' then '????????????'
  when 'RT03' then '????????????'
  when 'RT04' then '??????????????????'
  when 'RT05' then '????????????-?????????????????????'
  when 'RT06' then '????????????-????????????'
  when 'RT07' then '????????????-????????????'
  when 'RT08' then '????????????-????????????'
  else get_json_object(standard_req_msg,'$.product.repay_type')
  end                                                          as repay_type,
  case get_json_object(standard_req_msg,'$.product.loan_rate_type')
  when 'LRT01' then '????????????'
  else get_json_object(standard_req_msg,'$.product.loan_rate_type')
  end                                                          as loan_rate_type,
  case get_json_object(standard_req_msg,'$.product.agreement_rate_ind')
  when 'Y' then '???' when 'N' then '???'
  else get_json_object(standard_req_msg,'$.product.agreement_rate_ind')
  end as agreement_rate_ind,
  get_json_object(standard_req_msg,'$.product.loan_rate') as loan_rate,
  get_json_object(standard_req_msg,'$.product.loan_fee_rate') as loan_fee_rate,
  get_json_object(standard_req_msg,'$.product.loan_svc_fee_rate') as loan_svc_fee_rate,
  get_json_object(standard_req_msg,'$.product.loan_penalty_rate') as loan_penalty_rate,
  get_json_object(standard_req_msg,'$.product.guarantee_type') as guarantee_type,
  case get_json_object(standard_req_msg,'$.product.loan_apply_use')
  when 'LAU99' then '???????????????'
  when 'LAU01' then '??????'
  when 'LAU02' then '??????'
  when 'LAU03' then '??????'
  when 'LAU04' then '????????????'
  when 'LAU05' then '????????????'
  when 'LAU06' then '??????'
  when 'LAU07' then '??????'
  when 'LAU08' then '??????'
  when 'LAU09' then '??????'
  when 'LAU10' then '??????'
  when 'LAU11' then '??????'
  when 'LAU12' then '????????????'
  when 'LAU13' then '????????????'
  when 'LAU14' then '????????????'
  else get_json_object(standard_req_msg,'$.product.loan_apply_use')
  end                                                          as loan_apply_use,
  ecif_no                                                           as ecif_id,
  get_json_object(standard_req_msg,'$.borrower.open_id')            as open_id,
  case get_json_object(standard_req_msg,'$.borrower.id_type')
  when 'I' then '?????????'
  when 'T' then '?????????'
  when 'S' then '?????????/?????????'
  when 'P' then '??????'
  when 'L' then '????????????'
  when 'O' then '??????????????????'
  when 'R' then '?????????'
  when 'H' then '?????????????????????????????????'
  when 'W' then '?????????????????????????????????'
  when 'F' then '??????????????????'
  when 'C' then '?????????'
  when 'B' then '????????????'
  else get_json_object(standard_req_msg,'$.borrower.id_type')
  end                                                               as id_type,
  get_json_object(standard_req_msg,'$.borrower.id_no')              as id_no,
  get_json_object(standard_req_msg,'$.borrower.name')               as name,
  get_json_object(standard_req_msg,'$.borrower.mobile_phone')       as mobile_phone,
  get_json_object(standard_req_msg,'$.borrower.province')           as province,
  get_json_object(standard_req_msg,'$.borrower.city')               as city,
  get_json_object(standard_req_msg,'$.borrower.area')               as area,
  get_json_object(standard_req_msg,'$.borrower.address')            as address,
  case get_json_object(standard_req_msg,'$.borrower.marital_status')
  when 'C' then '??????'
  when 'S' then '??????'
  when 'O' then '??????'
  when 'D' then '??????'
  when 'P' then '??????'
  else get_json_object(standard_req_msg,'$.borrower.marital_status')
  end                                                               as marital_status,
  case get_json_object(standard_req_msg,'$.borrower.education')
  when 'A' then '???????????????'
  when 'B' then '??????'
  when 'C' then '????????????'
  when 'D' then '????????????/????????????'
  when 'E' then '??????/??????/??????'
  when 'F' then '??????'
  when 'G' then '????????????'
  else get_json_object(standard_req_msg,'$.borrower.education')
  end                                                               as education,
  case get_json_object(standard_req_msg,'$.borrower.industry')
  when 'A' then '????????????????????????'
  when 'B' then '?????????'
  when 'C' then '?????????'
  when 'D' then '??????????????????????????????????????????'
  when 'E' then '?????????'
  when 'F' then '?????????????????????????????????'
  when 'G' then '??????????????????????????????????????????'
  when 'H' then '??????????????????'
  when 'I' then '??????????????????'
  when 'J' then '?????????'
  when 'K' then '????????????'
  when 'L' then '????????????????????????'
  when 'M' then '????????????????????????????????????????????????'
  when 'N' then '???????????????????????????????????????'
  when 'O' then '??????????????????????????????'
  when 'P' then '??????'
  when 'Q' then '???????????????????????????????????????'
  when 'R' then '???????????????????????????'
  when 'S' then '???????????????????????????'
  when 'T' then '????????????'
  when 'Z' then '??????'
  when 'NIL' then '???'
  else get_json_object(standard_req_msg,'$.borrower.industry')
  end                                                               as industry,
  get_json_object(standard_req_msg,'$.borrower.annual_income_max')  as annual_income_max,
  get_json_object(standard_req_msg,'$.borrower.annual_income_min')  as annual_income_min,
  if(length(get_json_object(standard_req_msg,'$.borrower.have_house')) = 0,null,get_json_object(standard_req_msg,'$.borrower.have_house'))         as have_house,
  get_json_object(standard_req_msg,'$.borrower.housing_area')       as housing_area,
  get_json_object(standard_req_msg,'$.borrower.housing_value')      as housing_value,
  if(length(get_json_object(standard_req_msg,'$.borrower.drivr_licen_no')) = 0,null,get_json_object(standard_req_msg,'$.borrower.drivr_licen_no'))     as drivr_licen_no,
  get_json_object(standard_req_msg,'$.borrower.driving_expr')       as driving_expr,
  if(get_json_object(standard_req_msg,'$.borrower.sex') is null or length(get_json_object(standard_req_msg,'$.borrower.sex')) = 0,
    sex_idno(get_json_object(standard_req_msg,'$.borrower.id_no')),
    case get_json_object(standard_req_msg,'$.borrower.sex')
    when 'M' then '???' when 'F' then '???'
    else get_json_object(standard_req_msg,'$.borrower.sex')
    end
  ) as sex,
  get_json_object(standard_req_msg,'$.borrower.age')                as age,
  if(length(get_json_object(standard_req_msg,'$.company.social_credit_code')) = 0,null,get_json_object(standard_req_msg,'$.company.social_credit_code')) as social_credit_code,
  if(length(get_json_object(standard_req_msg,'$.company.company_name')) = 0,null,get_json_object(standard_req_msg,'$.company.company_name')) as company_name,
  if(length(get_json_object(standard_req_msg,'$.company.industry')) = 0,null,get_json_object(standard_req_msg,'$.company.industry')) as industry,
  if(length(get_json_object(standard_req_msg,'$.company.province')) = 0,null,get_json_object(standard_req_msg,'$.company.province')) as province,
  if(length(get_json_object(standard_req_msg,'$.company.city')) = 0,null,get_json_object(standard_req_msg,'$.company.city')) as city,
  if(length(get_json_object(standard_req_msg,'$.company.address')) = 0,null,get_json_object(standard_req_msg,'$.company.address')) as address,
  if(length(get_json_object(standard_req_msg,'$.company.legal_person_name')) = 0,null,get_json_object(standard_req_msg,'$.company.legal_person_name')) as legal_person_name,
  if(length(get_json_object(standard_req_msg,'$.company.id_type')) = 0,null,get_json_object(standard_req_msg,'$.company.id_type')) as id_type,
  if(length(get_json_object(standard_req_msg,'$.company.id_no')) = 0,null,get_json_object(standard_req_msg,'$.company.id_no')) as id_no,
  if(length(get_json_object(standard_req_msg,'$.company.legal_person_phone')) = 0,null,get_json_object(standard_req_msg,'$.company.legal_person_phone')) as legal_person_phone,
  if(length(get_json_object(standard_req_msg,'$.company.phone')) = 0,null,get_json_object(standard_req_msg,'$.company.phone')) as phone,
  if(length(get_json_object(standard_req_msg,'$.company.operate_years')) = 0,0,cast(get_json_object(standard_req_msg,'$.company.operate_years') as int)) as operate_years,
  case get_json_object(standard_req_msg,'$.loan_account.account_type')
  when 'ERSONAL' then '????????????' when 'BUSINESS' then '????????????'
  else get_json_object(standard_req_msg,'$.loan_account.account_type')
  end                                                             as loan_account_account_type,
  get_json_object(standard_req_msg,'$.loan_account.account_num')  as loan_account_account_num,
  get_json_object(standard_req_msg,'$.loan_account.account_name') as loan_account_account_name,
  case get_json_object(standard_req_msg,'$.loan_account.bank_name')
  when 'B0100' then '????????????'
  when 'B0102' then '??????????????????'
  when 'B0103' then '??????????????????'
  when 'B0104' then '??????????????????'
  when 'B0105' then '????????????'
  when 'B0301' then '????????????'
  when 'B0302' then '??????????????????'
  when 'B0303' then '??????????????????'
  when 'B0305' then '??????????????????'
  when 'B0306' then '???????????????'
  when 'B0307' then '????????????'
  when 'B0308' then '????????????'
  when 'B0410' then '??????????????????'
  when 'B6440' then '????????????'
  when 'B0411' then '????????????'
  else get_json_object(standard_req_msg,'$.loan_account.bank_name')
  end as loan_account_bank_name,
  if(length(get_json_object(standard_req_msg,'$.loan_account.branch_name')) = 0,null,get_json_object(standard_req_msg,'$.loan_account.branch_name'))  as loan_account_branch_name,
  get_json_object(standard_req_msg,'$.loan_account.mobile_phone') as loan_account_mobile_phone
from (
  select
    id,
    deal_date,
    create_time,
    update_time,
    req_log_id,
    org,
    standard_req_msg,
    standard_resp_msg,
    status
  from ods.nms_interface_resp_log
  where sta_service_method_name = 'setupCustCredit'
    and standard_req_msg is not null
) as resp_log
left join (
  select id_no,ecif_no from ecif_core.ecif_customer_hive
) as ecif_customer
on encrypt_aes(get_json_object(resp_log.standard_req_msg,'$.borrower.id_no')) = ecif_customer.id_no
limit 10;
