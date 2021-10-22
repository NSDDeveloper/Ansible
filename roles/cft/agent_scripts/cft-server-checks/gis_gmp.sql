variable retval number;
declare job_ok boolean;
        JOB_ST_TBL Z$CIT_ABONENT_JLIB.JOB_STATE_TBL;
        gmp Z#CIT_ABONENT#INTERFACE.CLASS#CIT_ABONENT;
begin
 job_ok:=false;
 gmp:=Z#CIT_ABONENT#INTERFACE.get_CIT_ABONENT(810149955,null,false); -- GIS_GMP
 JOB_ST_TBL:=Z$CIT_ABONENT_JLIB.GET_JOB_STATE(gmp.id,Z$CIT_ABONENT_JLIB.V_JOB_METH_PROC_IN);
 for I in  1..JOB_ST_TBL.COUNT loop
  if JOB_ST_TBL(I).JOB_STATE = '3' then
   job_ok:=true;
   exit;
  end if;
 end loop;
 if job_ok and Z$RUNTIME_AQ_LIB.QUEUE_STATE(gmp.A#AQ_IN)=2 and Z$RUNTIME_AQ_LIB.QUEUE_STATE(gmp.A#AQ_OUT)=2 then
  :retval:=0;
 else
  :retval:=1;
 end if;
end;
/
exit :retval
