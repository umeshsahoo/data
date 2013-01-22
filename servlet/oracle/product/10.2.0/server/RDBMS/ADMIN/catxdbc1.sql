Rem
Rem $Header: catxdbc1.sql 23-nov-2005.13:11:02 rtjoa Exp $
Rem
Rem catxdbc1.sql
Rem
Rem Copyright (c) 2001, 2005, Oracle. All rights reserved.  
Rem
Rem    NAME
Rem      catxdbc1.sql - Registration of XDB Config Schema
Rem
Rem    DESCRIPTION
Rem      This script registers the XDB configuration schema
Rem
Rem    NOTES
Rem      Subject to change, as the schema evolves
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    rtjoa       11/09/05 - Adding new element http-host and http2-host 
Rem    rpang       04/01/05 - request-validation-function/input-filter-enable
Rem    rpang       03/24/05 - Fix SSO typo 
Rem    petam       03/18/05 - add allow-repository-anonymous-access for http
Rem    abagrawa    02/08/05 - Remove public grants on xdb$config
Rem    rpang       12/01/04 - Reordered plsql element 
Rem    petam       11/02/04 - bug#3957281 - add element <ftp-welcome-message> 
Rem    rpang       10/27/04 - Added owa-debug-enable
Rem    rpang       10/14/04 - plsql-servlet-config to the end for downgrade
Rem    rpang       07/28/04 - Added database-username attribute
Rem    rpang       06/02/04 - Added PL/SQL servlet configuration
Rem    rangrish    05/11/04 - add XDBWEBSERVICES role 
Rem    spannala    05/10/04 - remove http2 listener 
Rem    thbaby      02/17/04 - add HTTP2 elements to schema 
Rem    spannala    07/11/03 - put new elements at the end
Rem    athusoo     07/17/03 - Set minOccurs=0 for new elements
Rem    athusoo     03/11/03 - Add xdbcore-xobmem-bound
Rem    rmurthy     11/20/02 - add schemalocation and xml mimetype mappings
Rem    njalali     09/26/02 - granting select privs on config tbl to public
Rem    dchiba      06/28/02 - Adding default URL charset in httpconfig
Rem    nmontoya    05/20/02 - ADD acl-cache-size
Rem    spannala    07/10/02 - adding case-sensitive-index-clause
Rem    nmontoya    07/08/02 - GRANT ALL ON xdb$config to xdbadmin
Rem    fge         04/26/02 - add resource-view-cache-size to sysconfig
Rem    abagrawa    03/08/02 - Change default log values
Rem    abagrawa    03/04/02 - Change userconfig to have minoccurs=0
Rem    nmontoya    02/26/02 - SET acl-max-age TYPE TO unsignedInt
Rem    rmurthy     02/14/02 - fix schema
Rem    spannala    01/31/02 - removing ftp-root
Rem    esedlar     02/05/02 - Remove duplicate type defs for protocols
Rem    rmurthy     12/28/01 - set elementForm to qualified
Rem    spannala    12/27/01 - setup should be run as SYS
Rem    sidicula    12/14/01 - Adding max-header-size in httpconfig
Rem    rmurthy     12/17/01 - fix schemas
Rem    abagrawa    11/19/01 - Add servlet realm
Rem    abagrawa    11/20/01 - Add default table
Rem    sidicula    11/08/01 - Config params for HTTP & FTP
Rem    jwwarner    10/24/01 - add authenticated user role
Rem    abagrawa    10/17/01 - Adding <servlet-schema>
Rem    sidicula    10/24/01 - Timeouts
Rem    abagrawa    10/07/01 - Merged abagrawa_http_trans
Rem    abagrawa    09/20/01 - Created
Rem

Rem alter session set events='31156 trace name context forever';
Rem Register Config Schema

declare
 CONFIGURL VARCHAR2(2000) := 'http://xmlns.oracle.com/xdb/xdbconfig.xsd';  
 CONFIGXSD VARCHAR2(32000) :=
'<schema        targetNamespace="http://xmlns.oracle.com/xdb/xdbconfig.xsd"
        xmlns="http://www.w3.org/2001/XMLSchema"
        xmlns:xdbc="http://xmlns.oracle.com/xdb/xdbconfig.xsd"
        xmlns:xdb="http://xmlns.oracle.com/xdb"
        version="1.0" elementFormDefault="qualified">

  <element name="xdbconfig" xdb:defaultTable="XDB$CONFIG">

  <complexType><sequence>

    <!-- predefined XDB properties - these should NOT be changed -->
    <element name="sysconfig">
    <complexType><sequence>     
        <!-- generic XDB properties -->
        <element name="acl-max-age" type="unsignedInt" default="1000"/>
        <element name="acl-cache-size" type="unsignedInt" default="32"/>
        <element name="invalid-pathname-chars" type="string" default=""/>
        <element name="case-sensitive" type="boolean" default="true"/>
        <element name="call-timeout"   type="unsignedInt" default="300"/>
        <element name="max-link-queue" type="unsignedInt" default="65536"/>
        <element name="max-session-use" type="unsignedInt" default="100"/>
        <element name="persistent-sessions" type="boolean" default="false"/>
        <element name="default-lock-timeout" type="unsignedInt" 
                                                   default="3600"/>
        <element name="xdbcore-logfile-path" type="string" 
                                     default="/sys/log/xdblog.xml"/> 
        <element name="xdbcore-log-level" type="unsignedInt" default="0"/>
        <element name="resource-view-cache-size" type="unsignedInt"
                                                 default="1048576"/>
        <element name="case-sensitive-index-clause" type="string" minOccurs="0"/>
        
        <!-- protocol specific properties -->
        <element name="protocolconfig">
        <complexType><sequence>

            <!-- these apply to all protocols -->
            <element name="common">
            <complexType><sequence>
                <element name="extension-mappings">
                <complexType><sequence> 
                  <element name="mime-mappings" type="xdbc:mime-mapping-type"/>
                  <element name="lang-mappings" type="xdbc:lang-mapping-type"/>
                  <element name="charset-mappings" 
                                             type="xdbc:charset-mapping-type"/>
                  <element name="encoding-mappings" 
                                            type="xdbc:encoding-mapping-type"/>
                  <element name="xml-extensions"
                                type="xdbc:xml-extension-type" minOccurs="0"/>
                </sequence></complexType>
                </element>
                <element name="session-pool-size" type="unsignedInt" 
                                                          default="50"/>
                <element name="session-timeout"   type="unsignedInt" 
                                                          default="6000"/>
            </sequence></complexType>
            </element>    

            <!-- FTP specific -->
            <element name="ftpconfig">
            <complexType><sequence>
              <element name="ftp-port" type="unsignedShort" default="2100"/>
              <element name="ftp-listener" type="string"/>
              <element name="ftp-protocol" type="string"/>
              <element name="logfile-path" type="string" 
                                               default="/sys/log/ftplog.xml"/> 
              <element name="log-level" type="unsignedInt" default="0"/>
              <element name="session-timeout"  type="unsignedInt" 
                                                         default="6000"/>
              <element name="buffer-size" default="8192">
                <simpleType>
                  <restriction base="unsignedInt">
                    <minInclusive value="1024"/>       <!-- 1KB -->
                    <maxInclusive value="1048496"/>    <!-- 1MB -->  
                  </restriction>
                </simpleType>
              </element>
              <element name="ftp-welcome-message" type="string" minOccurs="0" 
                                                               maxOccurs="1"/>
            </sequence></complexType>
            </element>  

            <!-- HTTP specific -->
            <element name="httpconfig">
            <complexType><sequence>
                <element name="http-port" type="unsignedShort" default="8080"/>
                <element name="http-listener" type="string"/>
                <element name="http-protocol" type="string"/>
                <element name="max-http-headers" type="unsignedInt" 
                                                               default="64"/>
                <element name="max-header-size" type="unsignedInt" 
                                                               default="4096"/>
                <element name="max-request-body" type="unsignedInt" 
                                          default="2000000000" minOccurs="1"/>
                <element name="session-timeout"  type="unsignedInt" 
                                                            default="6000"/>
                <element name="server-name" type="string"/>              
                <element name="logfile-path" type="string" 
                                            default="/sys/log/httplog.xml"/> 
                <element name="log-level" type="unsignedInt" default="0"/>
                <element name="servlet-realm" type="string" minOccurs="0"/>

                <element name="webappconfig">
                <complexType><sequence> 
                  <element name="welcome-file-list" 
                                               type="xdbc:welcome-file-type"/>
                  <element name="error-pages" type="xdbc:error-page-type"/>
                  <element name="servletconfig" 
                                             type="xdbc:servlet-config-type"/> 
                </sequence></complexType>
                </element>
                <element name="default-url-charset" type="string" 
                                                               minOccurs="0"/>
                <element name="http2-port" type="unsignedShort"
                                                minOccurs="0"/>
                <element name="http2-protocol" type="string"
                                                default="tcp" minOccurs="0"/>
                <element name="plsql" minOccurs="0">
                <complexType><sequence> 
                  <element name="log-level" type="unsignedInt" minOccurs="0"/>
                  <element name="max-parameters" type="unsignedInt"
                                                               minOccurs="0"/>
                </sequence></complexType>
                </element>
                <element name="allow-repository-anonymous-access" 
                         minOccurs="0" default="false" type="boolean"/>
                <element name="http-host" type="string" minOccurs="0"/>
                <element name="http2-host" type="string" minOccurs="0"/>
            </sequence></complexType>
            </element>  

        </sequence></complexType>
        </element>

        <element name="schemaLocation-mappings"
                 type="xdbc:schemaLocation-mapping-type" minOccurs="0"/>
        <element name="xdbcore-xobmem-bound" type="unsignedInt"
                                                 default="1024" minOccurs="0"/>
        <element name="xdbcore-loadableunit-size" type="unsignedInt"
                                                 default="16" minOccurs="0"/>
    </sequence></complexType>
    </element>
 

   <!-- users can add any properties they want here -->        
   <element name="userconfig" minOccurs="0">
        <complexType><sequence>
           <any maxOccurs="unbounded" namespace="##other"/>
        </sequence></complexType>
   </element>

  </sequence></complexType>

  </element>

  <complexType name="welcome-file-type">
     <sequence>                        
         <element name="welcome-file" minOccurs="0" maxOccurs="unbounded">
          <simpleType>
          <restriction base="string">
            <pattern value="[^/]*"/>
          </restriction>
          </simpleType>
         </element>
     </sequence>
  </complexType>

  <!-- customized error pages -->
  <complexType name="error-page-type">
  <sequence>    
        <element name="error-page" minOccurs="0" maxOccurs="unbounded">
        <complexType><sequence>
              <choice>
                <element name="error-code">
                  <simpleType>
                    <restriction base="positiveInteger">
                      <minInclusive value="100"/>
                      <maxInclusive value="999"/>
                    </restriction>
                  </simpleType>
                </element>
                
                <!-- Fully qualified classname of a Java exception type -->
                <element name="exception-type" type="string"/>
        
                <element name="OracleError">
                 <complexType><sequence>
                    <element name="facility" type="string" default="ORA"/>
                    <element name="errnum" type="unsignedInt"/>
                 </sequence></complexType>
                </element>
              </choice>
        
              <element name="location" type="anyURI"/>

         </sequence></complexType>
         </element>
  </sequence>   
  </complexType>


  <!-- parameter for a servlet: name, value pair and a description  -->
  <complexType name="param">
    <sequence>
      <element name="param-name" type="string"/>        
      <element name="param-value" type="string"/>
      <element name="description" type="string"/>    
    </sequence>
  </complexType>

  <complexType name="servlet-config-type">
    <sequence>
         <element name="servlet-mappings">
           <complexType><sequence>
              <element name="servlet-mapping" minOccurs="0" 
                       maxOccurs="unbounded">
              <complexType><sequence>
                  <element name="servlet-pattern" type="string"/>
                  <element name="servlet-name" type="string"/>
              </sequence></complexType>
              </element>
           </sequence></complexType>
          </element> 

      <element name="servlet-list"> 
        <complexType><sequence>
              <element name="servlet" minOccurs="0" maxOccurs="unbounded">
                <complexType><sequence>
                  <element name="servlet-name" type="string"/>
                  <element name="servlet-language">
                    <simpleType>
                      <restriction base="string">
                        <enumeration value="C"/>
                        <enumeration value="Java"/>
                        <enumeration value="PL/SQL"/>
                      </restriction>
                    </simpleType> 
                  </element> 
                  <element name="icon" type="string" minOccurs="0"/>
                  <element name="display-name" type="string"/>
                  <element name="description" type="string" minOccurs="0"/>
                  <choice>
                    <element name="servlet-class" type="string" minOccurs="0"/>
                    <element name="jsp-file" type="string" minOccurs="0"/>
                    <element name="plsql" type="xdbc:plsql-servlet-config" minOccurs="0"/>
                  </choice>
                  <element name="servlet-schema" type="string" minOccurs="0"/>
                  <element name="init-param" minOccurs="0" 
                           maxOccurs="unbounded" type="xdbc:param"/>
                  <element name="load-on-startup" type="string" minOccurs="0"/>
                  <element name="security-role-ref" minOccurs="0" 
                        maxOccurs="unbounded">
                  <complexType><sequence>
                      <element name="description" type="string" minOccurs="0"/>
                      <element name="role-name" type="string"/>
                      <element name="role-link" type="string"/>
                  </sequence></complexType>
                  </element>
                </sequence></complexType>
              </element>
        </sequence></complexType>
      </element> 
  </sequence>
  </complexType>    


  <complexType name="lang-mapping-type"><sequence>
      <element name="lang-mapping" minOccurs="0" maxOccurs="unbounded">
        <complexType><sequence>
        <element name="extension" type="xdbc:exttype"/>
        <element name="lang" type="string"/>
        </sequence></complexType>
      </element></sequence>
  </complexType>


  <complexType name="charset-mapping-type"><sequence>
      <element name="charset-mapping" minOccurs="0" maxOccurs="unbounded">
        <complexType><sequence>
        <element name="extension" type="xdbc:exttype"/>
        <element name="charset" type="string"/>
        </sequence></complexType>
      </element></sequence>
  </complexType>

  <complexType name="encoding-mapping-type"><sequence>
      <element name="encoding-mapping" minOccurs="0" maxOccurs="unbounded">
        <complexType><sequence>
        <element name="extension" type="xdbc:exttype"/>
        <element name="encoding" type="string"/>
        </sequence></complexType>
      </element></sequence>
  </complexType>

 <complexType name="mime-mapping-type"><sequence>
      <element name="mime-mapping" minOccurs="0" maxOccurs="unbounded">
      <complexType><sequence>
        <element name="extension" type="xdbc:exttype"/>
        <element name="mime-type" type="string"/>
      </sequence></complexType>
      </element></sequence> 
  </complexType> 

 <complexType name="xml-extension-type"><sequence>
      <element name="extension" type="xdbc:exttype"
               minOccurs="0" maxOccurs="unbounded">
      </element></sequence> 
  </complexType> 

 <complexType name="schemaLocation-mapping-type"><sequence>
      <element name="schemaLocation-mapping"
               minOccurs="0" maxOccurs="unbounded">
      <complexType><sequence>
        <element name="namespace" type="string"/>
        <element name="element" type="string"/>
        <element name="schemaURL" type="string"/>
      </sequence></complexType>
      </element></sequence> 
  </complexType> 


  <complexType name="plsql-servlet-config">
    <sequence>
      <element name="database-username" type="string" minOccurs="0"/>
      <element name="authentication-mode" minOccurs="0">
        <simpleType>
          <restriction base="string">
            <enumeration value="Basic"/>
            <enumeration value="SingleSignOn"/>
            <enumeration value="GlobalOwa"/>
            <enumeration value="CustomOwa"/>
            <enumeration value="PerPackageOwa"/>
          </restriction>
        </simpleType> 
      </element>
      <element name="session-cookie-name" type="string" minOccurs="0"/>
      <element name="session-state-management" minOccurs="0">
        <simpleType>
          <restriction base="string">
            <enumeration value="StatelessWithResetPackageState"/>
            <enumeration value="StatelessWithFastResetPackageState"/>
            <enumeration value="StatelessWithPreservePackageState"/>
          </restriction>
        </simpleType> 
      </element>
      <element name="max-requests-per-session" type="unsignedInt" minOccurs="0"/>
      <element name="default-page" type="string" minOccurs="0"/>
      <element name="document-table-name" type="string" minOccurs="0"/>
      <element name="document-path" type="string" minOccurs="0"/>
      <element name="document-procedure" type="string" minOccurs="0"/>
      <element name="upload-as-long-raw" type="string" minOccurs="0" maxOccurs="unbounded"/>
      <element name="path-alias" type="string" minOccurs="0"/>
      <element name="path-alias-procedure" type="string" minOccurs="0"/>
      <element name="exclusion-list" type="string" minOccurs="0" maxOccurs="unbounded"/>
      <element name="cgi-environment-list" type="string" minOccurs="0" maxOccurs="unbounded"/>
      <element name="compatibility-mode" type="unsignedInt" minOccurs="0"/>
      <element name="nls-language" type="string" minOccurs="0"/>
      <element name="fetch-buffer-size" type="unsignedInt" minOccurs="0"/>
      <element name="error-style" minOccurs="0">
        <simpleType>
          <restriction base="string">
            <enumeration value="ApacheStyle"/>
            <enumeration value="ModplsqlStyle"/>
            <enumeration value="DebugStyle"/>
          </restriction>
        </simpleType> 
      </element>
      <element name="transfer-mode" minOccurs="0">
        <simpleType>
          <restriction base="string">
            <enumeration value="Char"/>
            <enumeration value="Raw"/>
          </restriction>
        </simpleType> 
      </element>
      <element name="before-procedure" type="string" minOccurs="0"/>
      <element name="after-procedure" type="string" minOccurs="0"/>
      <element name="bind-bucket-lengths" type="unsignedInt" minOccurs="0" maxOccurs="unbounded"/>
      <element name="bind-bucket-widths" type="unsignedInt" minOccurs="0" maxOccurs="unbounded"/>
      <element name="always-describe-procedure" minOccurs="0">
        <simpleType>
          <restriction base="string">
            <enumeration value="On"/>
            <enumeration value="Off"/>
          </restriction>
        </simpleType> 
      </element>
      <element name="info-logging" minOccurs="0">
        <simpleType>
          <restriction base="string">
            <enumeration value="InfoDebug"/>
          </restriction>
        </simpleType> 
      </element>
      <element name="owa-debug-enable" minOccurs="0">
        <simpleType>
          <restriction base="string">
            <enumeration value="On"/>
            <enumeration value="Off"/>
          </restriction>
        </simpleType> 
      </element>
      <element name="request-validation-function" type="string" minOccurs="0"/>
      <element name="input-filter-enable" minOccurs="0">
        <simpleType>
          <restriction base="string">
            <enumeration value="On"/>
            <enumeration value="Off"/>
          </restriction>
        </simpleType> 
      </element>
    </sequence>
  </complexType>

  <simpleType name="exttype">
      <restriction base="string">
        <pattern value="[^\*\./]*"/>
      </restriction>
  </simpleType>

</schema>';




begin
  
-- xdb.dbms_xmlschema.deleteSchema('http://xmlns.oracle.com/xdb/xdbconfig.xsd');
 xdb.dbms_xmlschema.registerSchema(CONFIGURL, CONFIGXSD, FALSE, TRUE, FALSE, TRUE, FALSE, 'XDB');
-- dbms_xdbz.disable_hierarchy('XDB', 'XDB$CONFIG');
end;
/


-- create the "virtual" authenticated user role we use in servlets
create role authenticatedUser;

-- create role for web services.  Must be granted to users for web services use
create role XDBWEBSERVICES;
grant XDBWEBSERVICES to dba;
grant XDBWEBSERVICES to xdbadmin;

-- grant database privileges on xdb$config table so that users with xdbadmin 
--   role can proceed with xdb configuration update
grant all on xdb.xdb$config to xdbadmin ; 

create or replace trigger xdb.xdbconfig_validate before insert or update
on xdb.XDB$CONFIG for each row
declare
  xdoc xmltype;  
begin
  xdoc := :new.sys_nc_rowinfo$;
  xmltype.schemaValidate(xdoc);
end;
/
