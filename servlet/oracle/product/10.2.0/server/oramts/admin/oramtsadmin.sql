Rem prompt the user for the Oracle MTS admin user and password
variable mtsadm_usr varchar2(32);
variable mtsadm_pwd varchar2(32);
variable mtsadm_con varchar2(64);
accept mtsadm_usr default 'mtssys' prompt 'enter the MTS administrator username (default mtssys) =>  '
accept mtsadm_pwd default 'mtssys' prompt 'enter the MTS administrator password (default mtssys) =>  '
accept mtsadm_con default 'local'  prompt 'enter the Net connect string for the database (default local) => '

spool oramts.out
Rem drop the Oracle MTS administrator first
drop user &mtsadm_usr cascade;
Rem create the Oracle MTS adminsitrator anew
create user &mtsadm_usr identified by &mtsadm_pwd;

Rem grant the necessary privileges to the MTS administrator
grant connect, resource, create session to &mtsadm_usr;
grant create synonym, create view, create table to &mtsadm_usr;
grant select_catalog_role to &mtsadm_usr;
grant force any transaction to &mtsadm_usr;
grant execute on dbms_job to &mtsadm_usr;
grant execute on utl_http to &mtsadm_usr;

Rem the following two grants are needed as PL/SQL doesn't use
Rem privileges granted via roles i.e. select_catalog_role.
grant select on sys.dba_pending_transactions to &mtsadm_usr;
grant select on sys.dba_2pc_pending to &mtsadm_usr;
grant select, update, delete on sys.pending_trans$ to &mtsadm_usr;
grant select, update, delete on sys.pending_sessions$ to &mtsadm_usr;
grant select, update, delete on sys.pending_sub_sessions$ to &mtsadm_usr;
disconnect

Rem connect as the Oracle MTS admin user
set instance &mtsadm_con
connect &mtsadm_usr/&mtsadm_pwd

Rem create the oramts_rmproxy_info table
create table oramts_rmproxy_info
(
  rmguid		VARCHAR2(32) NOT NULL UNIQUE,
  protid		NUMBER(2),
  endpoint		VARCHAR2(64),
  last_scan_time	DATE,
  last_oper_time	DATE
);

Rem create the oramts_pending_transactions table
create table oramts_pending_transactions as select * from dba_pending_transactions where 1 = 0;

Rem create the relevant PL/SQL packages
@@utl_oramts.sql
show errors
@@prvtoramts.plb
show errors

Rem create the view for MTS-related pending transactions
create view oramts_2pc_pending 
(
	formatid,
	global_transaction_id,
	branch_id,
	local_tx_id,
	state,
	protocol,
	endpoint
)
as 
select 
	b.formatid					
	"Format id",	
	substr(rawtohex(b.globalid),0,40)
	"Global txid", 
	substr(rawtohex(b.branchid),0,132)				
	"Branch Id" ,
	a.local_tran_id 				
	"Local Txid" , 
	a.state 					
	"State",
	substr(utl_oramts.get_protocol(rawtohex(b.branchid)),0,8)	
	"Protocol",
	substr(utl_oramts.get_endpoint(rawtohex(b.branchid)),0,64) 	
	"Endpoint"
from
	dba_2pc_pending a, dba_pending_transactions b
where
	b.formatid = 1145324612
and
	a.global_tran_id = to_char(b.formatid) || '.' ||  rawtohex(b.globalid);

Rem create the stored procedure for the recovery job 
create or replace procedure oramts_recovery_job
as
begin
	utl_oramts.recover_automatic();
exception 
	when others then null;
end;
/

Rem create the stored procedure for the forgetrm job
create or replace procedure oramts_forgetrm_job
as
begin
	utl_oramts.forget_rms();
exception 
	when others then null;
end;
/

variable jobno number;

Rem submit the recovery job
begin 
	dbms_job.submit(:jobno, 'oramts_recovery_job();',SYSDATE, 'SYSDATE + 1/1440');
	commit;
end;
/
print jobno

Rem submit the forget rm job
begin
	dbms_job.submit(:jobno, 'oramts_forgetrm_job();',SYSDATE, 'SYSDATE + 1/24');
	commit;
end;
/
print jobno

spool off
