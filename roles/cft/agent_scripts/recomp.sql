declare i integer;
crit_id number;

cursor crit is
select  c.id
   from criteria c, classes s 
     where s.id=c.class_id and
       ( exists (select 1 from user_objects
              where OBJECT_TYPE = 'VIEW' and OBJECT_NAME = c.SHORT_NAME
                and status <> 'VALID')
          or
          not exists (select status from user_objects where 
        object_type='VIEW' and 
        object_name=c.short_name and status = 'VALID'))
        and c.short_name not like '%_EXT'
    and c.name not like '%(расширение)'
  order by s.id, c.name;

begin
i:=rtl.open;
method.compile_status('INVALID');
method.compile_status('UPDATED');

for cr in crit
    loop
        begin
            data_views.create_vw_crit(cr.id);
        exception when others then null;
        end;
    end loop;

while dbms_pipe.receive_message('COMPILE$', 0) = 0  
loop
    null;
end loop;

end;

/

exit
