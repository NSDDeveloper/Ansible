variable retval number;
begin
 select case when count(1)=0 then 1 else 0 end into :retval from VW_CRIT_USER_SESSIONS where C_5='APP_ADM'; 
end;
/
exit :retval
