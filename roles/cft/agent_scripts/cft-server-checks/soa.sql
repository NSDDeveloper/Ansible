variable retval number;
begin
 select sum(cnt) into :retval from
 (select count(1) cnt from tq_xml_message where enq_time>SysDate-3 and enq_time<SysDate-300/86400
  union all
  select count(1) cnt from tq_xml_message_edo where enq_time>SysDate-3 and enq_time<SysDate-300/86400
  union all
  select count(1) cnt from tq_xml_message_ftp where enq_time>SysDate-3 and enq_time<SysDate-300/86400
  union all
  select count(1) cnt from tq_xml_message_block where enq_time>SysDate-3 and enq_time<SysDate-300/86400);
end;
/
exit :retval
