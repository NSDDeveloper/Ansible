variable retval number;
begin
 if nvl(To_Date(aud.lic_mgr.get_limit('IBS','MAX_DATE'),'DD/MM/YYYY'),SysDate-1)>=Trunc(SysDate) Then
  :retval:=0;
 else
  :retval:=1;
 end if;
end;
/
exit :retval
