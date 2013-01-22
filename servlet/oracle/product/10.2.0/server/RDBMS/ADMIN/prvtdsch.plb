create type sys.scheduler$_job_results wrapped 
a000000
1
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
d
ab ba
le1me12dpJ9gX34CIpumwkoowgswg5n0dLhc558zuDK9gVKyCfT+m78YKMCyy4G9vSu4dCul
v5vAMsvuJY8Jaab6zq2SRcUWFkatOa0SVzmI3gT9EfxnY2fJznvgjZsom/X+0oRaiKuTyl3d
bxY2gDkea74VeCHbs/pbkaQvuN6jgqamApPFtg==

/
declare
  jc  sys.aq$_agent;
begin
  jc := sys.aq$_agent('SCHEDULER_PICKUP', NULL, NULL);
  dbms_aqadm.add_subscriber('scheduler$_jobq', jc);
exception
  when others then
    if sqlcode = -24034 then NULL;
    else raise;
    end if;
end;
/
DECLARE
  type varchartab is table of varchar2(70);
  rules varchartab;
  rulesets varchartab;
  i pls_integer;
BEGIN
  select rule_owner ||'.'|| rule_name name bulk collect into rules
    from dba_streams_message_rules where streams_name
    in ('SCHEDULER_COORDINATOR','SCHEDULER_PICKUP') ;

  select rule_set_owner ||'.'|| rule_set_name name bulk collect into rulesets
    from dba_streams_message_consumers where queue_name = 'SCHEDULER$_JOBQ' ;

  sys.dbms_streams_adm.remove_rule(null, 'DEQUEUE', 'SCHEDULER_COORDINATOR',
    true, true);
  sys.dbms_streams_adm.remove_rule(null, 'DEQUEUE', 'SCHEDULER_PICKUP',
    true, true);

  FOR i IN rules.FIRST..rules.LAST LOOP
    BEGIN
      dbms_rule_adm.drop_rule(rules(i),TRUE);
    EXCEPTION
    WHEN others THEN
      IF sqlcode = -24147 THEN NULL;
      ELSE raise;
      END IF;
    END;
  END LOOP;

  FOR i IN rulesets.FIRST..rulesets.LAST LOOP
    BEGIN
      dbms_rule_adm.drop_rule_set(rulesets(i),TRUE);
    EXCEPTION
    WHEN others THEN
      IF sqlcode = -24141 THEN NULL;
      ELSE raise;
      END IF;
    END;
  END LOOP;
EXCEPTION
  
  
  when others then
    if sqlcode = -23605 then NULL;
    else raise;
    end if;
END;
/
declare
  tmp_rule_name  varchar2(61);
begin
   sys.dbms_streams_adm_utl_invok.add_message_rule (
     message_type => 'sys.scheduler$_job_fixed',
     rule_condition => ':MSG.GET_FLAGS() IS NOT NULL',
     streams_type => 'DEQUEUE',
     streams_name => 'SCHEDULER_COORDINATOR',
     queue_name => 'scheduler$_jobq',
     rule_name => tmp_rule_name);
end;
/
declare
  tmp_rule_name  varchar2(61);
begin
   sys.dbms_streams_adm_utl_invok.add_message_rule (
     message_type => 'sys.scheduler$_job_external',
     rule_condition => ':MSG.JOB_NAME IS NOT NULL',
     streams_type => 'DEQUEUE',
     streams_name => 'SCHEDULER_PICKUP',
     queue_name => 'scheduler$_jobq',
     rule_name => tmp_rule_name);
end;
/
declare
  tmp_rule_name  varchar2(61);
begin
   sys.dbms_streams_adm_utl_invok.add_message_rule (
     message_type => 'sys.scheduler$_job_results',
     rule_condition => ':MSG.JOB_NAME IS NOT NULL',
     streams_type => 'DEQUEUE',
     streams_name => 'SCHEDULER_PICKUP',
     queue_name => 'scheduler$_jobq',
     rule_name => tmp_rule_name);
end;
/
update reg$ set subscription_name='"SYS"."SCHEDULER$_JOBQ":"SCHEDULER_PICKUP"' where subscription_name='SYS.SCHEDULER$_JOBQ:SCHEDULER_PICKUP';
commit;
declare
reglist sys.aq$_reg_info_list;
reginfo sys.aq$_reg_info;
begin
  reginfo := sys.aq$_reg_info('SYS.SCHEDULER$_JOBQ:SCHEDULER_PICKUP',
                              dbms_aq.namespace_aq,
                              'plsql://sys.dbms_isched.pickup_job', NULL);
  reglist := sys.aq$_reg_info_list(reginfo);
  dbms_aq.register ( reglist, 1 );
end;
/
