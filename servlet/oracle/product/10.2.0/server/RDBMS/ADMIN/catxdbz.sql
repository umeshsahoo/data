Rem
Rem $Header: catxdbz.sql 16-feb-2005.21:05:45 thbaby Exp $
Rem
Rem catxdbz.sql
Rem
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catxdbz.sql - xdb security initialization
Rem
Rem    DESCRIPTION
Rem      <short description of component this file declares/defines>
Rem
Rem    NOTES
Rem      <other useful comments, qualifications, etc.>
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    thbaby      02/16/05 - Remove all_xdbadmin_acl.xml
Rem    abagrawa    09/01/04 - Add all_xdbadmin_acl.xml 
Rem    nmontoya    01/13/03 - ADD collection AND principalformat TO acl schema
Rem    nmontoya    03/14/02 - change priv names TO link-to AND unlink-from
Rem    nmontoya    03/13/02 - USE dbms_xdbz0.initXDBSecurity
Rem    njalali     02/19/02 - granting all privs on ACL table to PUBLIC
Rem    rmurthy     02/14/02 - fix descriptions
Rem    nmontoya    02/21/02 - add link, unlink, linkto, unlinkfrom privileges
Rem    rmurthy     01/30/02 - make privilege a global element
Rem    rmurthy     01/18/02 - new ACL schema
Rem    rmurthy     12/28/01 - set elementForm to qualified
Rem    rmurthy     12/26/01 - change to 2001 xmlschema-instance namespace
Rem    spannala    12/27/01 - xdb setup should run as sys
Rem    najain      11/26/01 - use XDB instead of xdb
Rem    rmurthy     12/17/01 - fix ACL schema
Rem    nagarwal    11/12/01 - change ordering of packages
Rem    nmontoya    11/04/01 - indent acl schema, ADD system acls
Rem    nmontoya    10/29/01 - USE dbms_xdb.createresource
Rem    mkrishna    11/01/01 - change xmldata to xmldata
Rem    nmontoya    10/18/01 - disable hierarchy FROM xdb$schema 
Rem    nmontoya    10/12/01 - ADD xdbadmin TO bootstrap acl
Rem    rmurthy     08/31/01 - change to xml binary type
Rem    rmurthy     08/03/01 - change XDB namespace
Rem    bkhaladk    08/03/01 - fix acl xmls.
Rem    njalali     07/18/01 - More resource as XMLType
Rem    njalali     07/17/01 - Resource as XMLType
Rem    nmontoya    07/05/01 - bootstrap acl inserts using pl/sql wrappers
Rem    sichandr    05/30/01 - add temporary connect
Rem    spannala    05/18/01 - xmltype_p ->xmltype
Rem    rmurthy     05/09/01 - remove conn as sysdba, add SQL type names
Rem    bkhaladk    03/20/01 - add param to register schema.
Rem    nmontoya    03/18/01 - user privileges
Rem    nmontoya    03/14/01 - schoid and elnum for acl schema.
Rem    rmurthy     03/08/01 - changes for new xmlschema
Rem    nmontoya    02/02/01 - Created
Rem

-- User must be XDB  
  
BEGIN
   xdb.dbms_xdbz.enable_hierarchy ('XDB', 'XDB$SCHEMA');
   xdb.dbms_xdbz.disable_hierarchy('XDB', 'XDB$SCHEMA');
END;
/

Rem Register ACL Schema

declare
  ACLXSD VARCHAR2(31000) :=
'<schema xmlns="http://www.w3.org/2001/XMLSchema" 
        targetNamespace="http://xmlns.oracle.com/xdb/acl.xsd" version="1.0"
        xmlns:xdb="http://xmlns.oracle.com/xdb"
        xmlns:xdbacl="http://xmlns.oracle.com/xdb/acl.xsd"
        elementFormDefault="qualified">

   <annotation>
     <documentation>
        This XML schema describes the structure of XDB ACL documents.
        
        Note : The "systemPrivileges" element below lists all supported 
          system privileges and their aggregations.
          See dav.xsd for description of DAV privileges
        Note : The elements and attributes marked "hidden" are for
          internal use only.
     </documentation>
     <appinfo>
       <xdb:systemPrivileges>
        <xdbacl:all>
          <xdbacl:read-properties/>
          <xdbacl:read-contents/>
          <xdbacl:read-acl/>
          <xdbacl:update/>
          <xdbacl:link/>
          <xdbacl:unlink/>
          <xdbacl:unlink-from/>
          <xdbacl:write-acl-ref/>
          <xdbacl:update-acl/>
          <xdbacl:link-to/>
          <xdbacl:resolve/>
        </xdbacl:all>
       </xdb:systemPrivileges>
     </appinfo>
   </annotation>

  <!-- privilegeNameType (this is an emptycontent type) -->
  <complexType name = "privilegeNameType"/>

  <!-- privilegeName element 
       All system and user privileges are in the substitutionGroup 
       of this element. 
    -->
  <element name = "privilegeName" type="xdbacl:privilegeNameType"
           xdb:defaultTable=""/>

  <!-- all system privileges in the XDB ACL namespace -->
  <element name = "read-properties" type="xdbacl:privilegeNameType"
           substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>
  <element name = "read-contents" type="xdbacl:privilegeNameType"
           substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>
  <element name = "read-acl" type="xdbacl:privilegeNameType"
           substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>
  <element name = "update" type="xdbacl:privilegeNameType"
           substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>
  <element name = "link" type="xdbacl:privilegeNameType"
           substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>
  <element name = "unlink" type="xdbacl:privilegeNameType"
           substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>
  <element name = "unlink-from" type="xdbacl:privilegeNameType"
           substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>
  <element name = "write-acl-ref" type="xdbacl:privilegeNameType"
           substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>
  <element name = "update-acl" type="xdbacl:privilegeNameType"
           substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>
  <element name = "link-to" type="xdbacl:privilegeNameType"
           substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>
  <element name = "resolve" type="xdbacl:privilegeNameType"
           substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>
  <element name = "all" type="xdbacl:privilegeNameType"
           substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>

  <!-- privilege element -->
  <element name = "privilege" xdb:SQLType = "XDB$PRIV_T" xdb:defaultTable="">
    <complexType> 
      <choice maxOccurs="unbounded">
        <any xdb:transient="generated"/>
        <!-- HIDDEN ELEMENTS -->
        <element name = "privNum" type = "hexBinary" xdb:baseProp="true" 
                 xdb:hidden="true"/>
      </choice> 
    </complexType>
  </element>

  <!-- ace element -->
  <element name = "ace" xdb:SQLType = "XDB$ACE_T" xdb:defaultTable="">
    <complexType> 
      <sequence>
        <element name = "grant" type = "boolean"/>
        <element name = "principal" type = "string"
                 xdb:transient="generated"/>
        <element ref="xdbacl:privilege" minOccurs="1"/>
        <!-- HIDDEN ELEMENTS -->
        <element name = "principalID" type = "hexBinary" minOccurs="0"
                 xdb:baseProp="true" xdb:hidden="true"/>
        <element name = "flags" type = "unsignedInt" minOccurs="0" 
                 xdb:baseProp="true" xdb:hidden="true"/>
      </sequence> 
      <attribute name = "collection" type = "boolean" 
                 xdb:transient="generated" use="optional"/>
      <attribute name = "principalFormat" 
                 xdb:transient="generated" use="optional">
        <simpleType>
          <restriction base="string">
            <enumeration value="ShortName"/>
            <enumeration value="DistinguishedName"/>
            <enumeration value="GUID"/>
          </restriction>    
        </simpleType>
      </attribute>    
    </complexType>
  </element>

  <!-- acl element -->
  <element name = "acl" xdb:SQLType = "XDB$ACL_T" xdb:defaultTable = "XDB$ACL">
    <complexType> 
     <sequence>
      <element name = "schemaURL" type = "string" minOccurs="0"
               xdb:transient="generated"/>
      <element name = "elementName" type = "string" minOccurs="0" 
               xdb:transient="generated"/>
      <element ref = "xdbacl:ace" minOccurs="1" maxOccurs = "unbounded"
               xdb:SQLCollType="XDB$ACE_LIST_T"/>
        
      <!-- HIDDEN ELEMENTS -->
      <element name = "schemaOID" type = "hexBinary" minOccurs="0"
               xdb:baseProp="true" xdb:hidden="true"/>
      <element name = "elementNum" type = "unsignedInt" minOccurs="0"
               xdb:baseProp="true" xdb:hidden="true"/>
     </sequence>
     <attribute name = "shared" type = "boolean" default="true"/>
     <attribute name = "description" type = "string"/>
    </complexType>
  </element>

 </schema>';

  ACLURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/acl.xsd';  

begin

xdb.dbms_xmlschema.registerSchema(ACLURL, ACLXSD, FALSE, TRUE, FALSE, TRUE,
                                  FALSE, 'XDB');

end;
/

-- Disable XRLS hierarchy priv check for xdb$acl and xdb$schema tables
BEGIN
   xdb.dbms_xdbz.disable_hierarchy('XDB', 'XDB$ACL');
   xdb.dbms_xdbz.disable_hierarchy('XDB', 'XDB$SCHEMA');
END;
/
  
-- INSERT bootstrap AND root acl's   
DECLARE 
  b_abspath          VARCHAR2(200);
  b_data             VARCHAR2(2000);
  r_abspath          VARCHAR2(200);
  r_data             VARCHAR2(2000);
  o_abspath          VARCHAR2(200);
  o_data             VARCHAR2(2000);
  ro_abspath         VARCHAR2(200);
  ro_data            VARCHAR2(2000);
  retbool            BOOLEAN;
BEGIN
   b_abspath := '/sys/acls/bootstrap_acl.xml';
   b_data := 
'<acl description="Protected:Readable by PUBLIC and all privileges to OWNER"
      xmlns="http://xmlns.oracle.com/xdb/acl.xsd" xmlns:dav="DAV:"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
      xsi:schemaLocation="http://xmlns.oracle.com/xdb/acl.xsd 
                          http://xmlns.oracle.com/xdb/acl.xsd">
  <ace> 
    <principal>dav:owner</principal>
    <grant>true</grant>
    <privilege>
      <all/>
    </privilege>
  </ace> 
  <ace> 
    <principal>XDBADMIN</principal>
    <grant>true</grant>
    <privilege>
      <all/>
    </privilege>
  </ace> 
  <ace> 
    <principal>PUBLIC</principal>
    <grant>true</grant>
    <privilege>
      <read-properties/>
      <read-contents/>
      <read-acl/>
      <resolve/>
    </privilege>
  </ace>
</acl>';
   
   r_abspath := '/sys/acls/all_all_acl.xml';
   r_data := 
'<acl description="Public:All privileges to PUBLIC"
      xmlns="http://xmlns.oracle.com/xdb/acl.xsd" 
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
      xsi:schemaLocation="http://xmlns.oracle.com/xdb/acl.xsd  
                          http://xmlns.oracle.com/xdb/acl.xsd"> 
  <ace> 
    <principal>PUBLIC</principal>
    <grant>true</grant>
    <privilege>
      <all/>
    </privilege>
  </ace>
</acl>';
   
   o_abspath := '/sys/acls/all_owner_acl.xml';
   o_data := 
'<acl description="Private:All privileges to OWNER only and not accessible to others"
      xmlns="http://xmlns.oracle.com/xdb/acl.xsd" xmlns:dav="DAV:"
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
      xsi:schemaLocation="http://xmlns.oracle.com/xdb/acl.xsd 
                          http://xmlns.oracle.com/xdb/acl.xsd"> 
  <ace> 
    <principal>dav:owner</principal>
    <grant>true</grant>
    <privilege>
      <all/>
    </privilege>
  </ace>
</acl>';
   
   ro_abspath := '/sys/acls/ro_all_acl.xml';
   ro_data := 
'<acl description="Read-Only:Readable by all and writeable by none"
      xmlns="http://xmlns.oracle.com/xdb/acl.xsd" 
      xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
      xsi:schemaLocation="http://xmlns.oracle.com/xdb/acl.xsd  
                          http://xmlns.oracle.com/xdb/acl.xsd">
  <ace> 
    <principal>PUBLIC</principal>
    <grant>true</grant>
    <privilege>
      <read-properties/>
      <read-contents/>
      <read-acl/>
      <resolve/>
    </privilege>
  </ace>
</acl>';
   
   retbool := dbms_xdb.createresource(b_abspath, b_data);
   retbool := dbms_xdb.createresource(r_abspath, r_data);
   retbool := dbms_xdb.createresource(o_abspath, o_data);
   retbool := dbms_xdb.createresource(ro_abspath, ro_data);
END;
/
  
declare 
   tablename     varchar2(2000);
   sqlstatement  varchar2(2000);
begin
   select e.xmldata.default_table into tablename from xdb.xdb$element e where e.xmldata.property.parent_schema = ( select ref(s) from xdb.xdb$schema s where s.xmldata.schema_url = 'http://xmlns.oracle.com/xdb/acl.xsd') and e.xmldata.property.name = 'acl';

   tablename := 'xdb.' || '"' || tablename || '"';

   sqlstatement := 'update xdb.xdb$resource r set r.xmldata.acloid = ( select e.sys_nc_oid$ from ' || tablename || ' e where e.xmldata."description" like ''Protected%'')';
   execute immediate sqlstatement;

   sqlstatement := 'update xdb.xdb$acl set acloid = ( select e.sys_nc_oid$ from ' || tablename || ' e where e.xmldata."description" like ''Protected%'')';
   execute immediate sqlstatement;

   sqlstatement := 'update xdb.xdb$h_index set acl_id = ( select e.sys_nc_oid$ from ' || tablename || ' e where e.xmldata."description" like ''Protected%'')';
   execute immediate sqlstatement;
end;
/

commit;

call xdb.dbms_xdbz0.initXDBSecurity();

-- Enable XRLS hierarchy priv check for xdb$acl and xdb$schema tables
BEGIN
   xdb.dbms_xdbz.enable_hierarchy('XDB', 'XDB$ACL');
   -- dbms_xdbz.enable_hierarchy('xdb', 'XDB$SCHEMA');
END;
/

commit;

Rem Make XDB$ACL writable by all users
grant all on XDB.XDB$ACL to public;
commit;

Rem Register the DAV schema

declare
  DAVXSD VARCHAR2(4000) := 
'<schema xmlns="http://www.w3.org/2001/XMLSchema" 
        targetNamespace="DAV:" version="1.0"
        xmlns:xdb="http://xmlns.oracle.com/xdb"
        xmlns:xdbacl="http://xmlns.oracle.com/xdb/acl.xsd"
        xmlns:dav="DAV:"
        elementFormDefault="qualified">

   <annotation> 
      <documentation>
        This XML schema declares all the DAV privilege elements 
      </documentation> 
      <appinfo>
         <dav:all>
           <dav:read>
             <xdbacl:read-properties/>
             <xdbacl:read-contents/>
             <xdbacl:resolve/>
           </dav:read>
           <dav:write>
             <xdbacl:update/>
             <xdbacl:link/>
             <xdbacl:unlink/>
             <xdbacl:unlink-from/>
           </dav:write>
           <dav:read-acl>
             <xdbacl:read-acl/>
           </dav:read-acl>
           <dav:write-acl>
             <xdbacl:write-acl-ref/>
             <xdbacl:update-acl/>
           </dav:write-acl>
           <dav:lock/>
           <dav:unlock/>
         </dav:all>
      </appinfo>
   </annotation>

   <import namespace="http://xmlns.oracle.com/xdb/acl.xsd" 
           schemaLocation="http://xmlns.oracle.com/xdb/acl.xsd"/>

   <!-- declare all DAV privileges -->
   <element name = "all" type="xdbacl:privilegeNameType" 
            substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>
   <element name = "read" type="xdbacl:privilegeNameType" 
            substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>
   <element name = "write" type="xdbacl:privilegeNameType" 
            substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>
   <element name = "read-acl" type="xdbacl:privilegeNameType" 
            substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>
   <element name = "write-acl" type="xdbacl:privilegeNameType" 
            substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>
   <element name = "lock" type="xdbacl:privilegeNameType" 
            substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>
   <element name = "unlock" type="xdbacl:privilegeNameType" 
            substitutionGroup="xdbacl:privilegeName" xdb:defaultTable=""/>

 </schema>';

 DAVURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/dav.xsd';  
begin
 xdb.dbms_xmlschema.registerSchema(DAVURL, DAVXSD, FALSE, TRUE, FALSE, TRUE,
                                   FALSE, 'XDB');
end;
/

