declare req utl_http.req;
        resp utl_http.resp;
begin
  req:=UTL_HTTP.begin_request(URL=>Z$FP_TUNE_LIB.GET_STR_VALUE('по_URL_WEB_PDF'),method=>'POST');
  resp:=UTL_HTTP.get_response(req);
end;
/
exit sql.sqlcode
