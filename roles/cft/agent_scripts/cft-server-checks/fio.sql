declare txt varchar2(32000);
begin
  txt:=stdio.file_list('.',2);
end;
/
exit sql.sqlcode
