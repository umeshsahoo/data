create or replace type aq$_jms_value 
oid '00000000000000000000000000021040' wrapped 
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
90 a6
ErGOnEiDIH7N1DKdssf4NJGpQc4wg5n0dLhcuHTD9P6bskoox9K9MlyPwHQrpb+bwDLL7iWP
CWnn+yap4Z1pD0mxyrLvLqTRfFsaHaHhFPyK7gQ2tjktKnSvGIRx7+aPFSL53Mp/sIUvsXBN
DrZpXwzr7PumI47KOw==

/
show errors;
create or replace type aq$_jms_exception 
oid '00000000000000000000000000021041' wrapped 
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
92 b2
u6hA9RtHmWYij2oz1WFqx8zG89Ewgy5H2p6pfC/pzB7Y4J6ZRG3Ko5PwUqWA4G6i9FwznZmU
w89DAKXkOL24LoYaTBoOhZJSf8pQryXcGjSFNt20r3gDKadTqdVeS7MO6Nq7hSdn//I+Tgbf
i01MKKoKLMccPeRo7Sv6mekZFElN+sp0

/
show errors;
create or replace type aq$_jms_namearray 
oid '00000000000000000000000000021042' 
as varray(1024) of varchar(200);
/
show errors; 
alter type aq$_jms_header replace as object
(
  replyto     sys.aq$_agent,
  type        varchar(100),
  userid      varchar(100),
  appid       varchar(100),
  groupid     varchar(100),
  groupseq    int,
  properties  aq$_jms_userproparray,
  MEMBER PROCEDURE lookup_property_name (new_property_name IN VARCHAR ),
  MEMBER PROCEDURE set_replyto (replyto IN      sys.aq$_agent),
  MEMBER PROCEDURE set_type (type       IN      VARCHAR ),
  MEMBER PROCEDURE set_userid (userid   IN      VARCHAR ),
  MEMBER PROCEDURE set_appid (appid     IN      VARCHAR ),
  MEMBER PROCEDURE set_groupid (groupid IN      VARCHAR ),
  MEMBER PROCEDURE set_groupseq (groupseq       IN      int ),
  MEMBER PROCEDURE clear_properties ,
  MEMBER PROCEDURE set_boolean_property (
                property_name   IN      VARCHAR,
                property_value  IN      BOOLEAN ),
  MEMBER PROCEDURE set_byte_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_short_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_int_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_long_property (
                property_name   IN      VARCHAR,
                property_value  IN      NUMBER ),
  MEMBER PROCEDURE set_float_property (
                property_name   IN      VARCHAR,
                property_value  IN      FLOAT ),
  MEMBER PROCEDURE set_double_property (
                property_name   IN      VARCHAR,
                property_value  IN      DOUBLE PRECISION ),
  MEMBER PROCEDURE set_string_property (
                property_name   IN      VARCHAR,
                property_value  IN      VARCHAR ),
  MEMBER FUNCTION get_replyto RETURN sys.aq$_agent,
  MEMBER FUNCTION get_type RETURN VARCHAR,
  MEMBER FUNCTION get_userid RETURN VARCHAR,
  MEMBER FUNCTION get_appid RETURN VARCHAR,
  MEMBER FUNCTION get_groupid RETURN VARCHAR,
  MEMBER FUNCTION get_groupseq RETURN int,
  MEMBER FUNCTION get_boolean_property ( property_name   IN      VARCHAR)
  RETURN   BOOLEAN,
  MEMBER FUNCTION get_boolean_property_as_int ( property_name   IN   VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_byte_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_short_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_int_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_long_property ( property_name   IN      VARCHAR)
  RETURN   NUMBER,
  MEMBER FUNCTION get_float_property ( property_name   IN      VARCHAR)
  RETURN   FLOAT,
  MEMBER FUNCTION get_double_property ( property_name   IN      VARCHAR)
  RETURN   DOUBLE PRECISION,
  MEMBER FUNCTION get_string_property ( property_name   IN      VARCHAR)
  RETURN   VARCHAR
);
show errors;
alter type aq$_jms_message replace as object
(
  header        aq$_jms_header,
  senderid      varchar2(100),
  message_type  int,
  text_len      int,
  bytes_len     int,
  text_vc       varchar2(4000),
  bytes_raw     raw(2000),
  text_lob      clob,
  bytes_lob     blob,
  STATIC FUNCTION construct ( mtype IN int ) RETURN aq$_jms_message,
  STATIC FUNCTION construct( text_msg IN  aq$_jms_text_message)
  RETURN aq$_jms_message,
  STATIC FUNCTION construct( bytes_msg IN  aq$_jms_bytes_message)
  RETURN aq$_jms_message,
  STATIC FUNCTION construct( stream_msg IN  aq$_jms_stream_message)
  RETURN aq$_jms_message,
  STATIC FUNCTION construct( map_msg IN  aq$_jms_map_message)
  RETURN aq$_jms_message,
  STATIC FUNCTION construct( object_msg IN  aq$_jms_object_message)
  RETURN aq$_jms_message,
  MEMBER FUNCTION cast_to_text_msg RETURN aq$_jms_text_message,
  MEMBER FUNCTION cast_to_bytes_msg RETURN aq$_jms_bytes_message,
  MEMBER FUNCTION cast_to_stream_msg RETURN aq$_jms_stream_message,
  MEMBER FUNCTION cast_to_map_msg RETURN aq$_jms_map_message,
  MEMBER FUNCTION cast_to_object_msg RETURN aq$_jms_object_message,
  MEMBER PROCEDURE set_text ( payload IN VARCHAR2 ),
  MEMBER PROCEDURE set_text ( payload IN CLOB ),
  MEMBER PROCEDURE get_text ( payload OUT VARCHAR2 ),
  MEMBER PROCEDURE get_text ( payload OUT CLOB ),
  MEMBER PROCEDURE set_bytes ( payload IN RAW ),
  MEMBER PROCEDURE set_bytes ( payload IN BLOB ),
  MEMBER PROCEDURE get_bytes ( payload OUT RAW ),
  MEMBER PROCEDURE get_bytes ( payload OUT BLOB ),
  MEMBER PROCEDURE set_replyto (replyto IN      sys.aq$_agent),
  MEMBER PROCEDURE set_type (type       IN      VARCHAR ),
  MEMBER PROCEDURE set_userid (userid   IN      VARCHAR ),
  MEMBER PROCEDURE set_appid (appid     IN      VARCHAR ),
  MEMBER PROCEDURE set_groupid (groupid IN      VARCHAR ),
  MEMBER PROCEDURE set_groupseq (groupseq       IN      int ),
  MEMBER PROCEDURE clear_properties ,
  MEMBER PROCEDURE set_boolean_property (
                property_name   IN      VARCHAR,
                property_value  IN      BOOLEAN ),
  MEMBER PROCEDURE set_byte_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_short_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_int_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_long_property (
                property_name   IN      VARCHAR,
                property_value  IN      NUMBER ),
  MEMBER PROCEDURE set_float_property (
                property_name   IN      VARCHAR,
                property_value  IN      FLOAT ),
  MEMBER PROCEDURE set_double_property (
                property_name   IN      VARCHAR,
                property_value  IN      DOUBLE PRECISION ),
  MEMBER PROCEDURE set_string_property (
                property_name   IN      VARCHAR,
                property_value  IN      VARCHAR ),
  MEMBER FUNCTION get_replyto RETURN sys.aq$_agent,
  MEMBER FUNCTION get_type RETURN VARCHAR,
  MEMBER FUNCTION get_userid RETURN VARCHAR,
  MEMBER FUNCTION get_appid RETURN VARCHAR,
  MEMBER FUNCTION get_groupid RETURN VARCHAR,
  MEMBER FUNCTION get_groupseq RETURN int,
  MEMBER FUNCTION get_boolean_property ( property_name   IN      VARCHAR)
  RETURN   BOOLEAN,
  MEMBER FUNCTION get_byte_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_short_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_int_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_long_property ( property_name   IN      VARCHAR)
  RETURN   NUMBER,
  MEMBER FUNCTION get_float_property ( property_name   IN      VARCHAR)
  RETURN   FLOAT,
  MEMBER FUNCTION get_double_property ( property_name   IN      VARCHAR)
  RETURN   DOUBLE PRECISION,
  MEMBER FUNCTION get_string_property ( property_name   IN      VARCHAR)
  RETURN   VARCHAR
);
show errors;
alter type aq$_jms_text_message replace as object
(
  header    aq$_jms_header,
  text_len  int,
  text_vc   varchar2(4000),
  text_lob  clob,
  STATIC FUNCTION construct RETURN aq$_jms_text_message,
  MEMBER PROCEDURE set_text ( payload IN VARCHAR2 ),
  MEMBER PROCEDURE set_text ( payload IN CLOB ),
  MEMBER PROCEDURE get_text ( payload OUT VARCHAR2 ),
  MEMBER PROCEDURE get_text ( payload OUT CLOB ),
  MEMBER PROCEDURE set_replyto (replyto IN      sys.aq$_agent),
  MEMBER PROCEDURE set_type (type       IN      VARCHAR ),
  MEMBER PROCEDURE set_userid (userid   IN      VARCHAR ),
  MEMBER PROCEDURE set_appid (appid     IN      VARCHAR ),
  MEMBER PROCEDURE set_groupid (groupid IN      VARCHAR ),
  MEMBER PROCEDURE set_groupseq (groupseq       IN      int ),
  MEMBER PROCEDURE clear_properties ,
  MEMBER PROCEDURE set_boolean_property (
                property_name   IN      VARCHAR,
                property_value  IN      BOOLEAN ),
  MEMBER PROCEDURE set_byte_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_short_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_int_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_long_property (
                property_name   IN      VARCHAR,
                property_value  IN      NUMBER ),
  MEMBER PROCEDURE set_float_property (
                property_name   IN      VARCHAR,
                property_value  IN      FLOAT ),
  MEMBER PROCEDURE set_double_property (
                property_name   IN      VARCHAR,
                property_value  IN      DOUBLE PRECISION ),
  MEMBER PROCEDURE set_string_property (
                property_name   IN      VARCHAR,
                property_value  IN      VARCHAR ),
  MEMBER FUNCTION get_replyto RETURN sys.aq$_agent,
  MEMBER FUNCTION get_type RETURN VARCHAR,
  MEMBER FUNCTION get_userid RETURN VARCHAR,
  MEMBER FUNCTION get_appid RETURN VARCHAR,
  MEMBER FUNCTION get_groupid RETURN VARCHAR,
  MEMBER FUNCTION get_groupseq RETURN int,
  MEMBER FUNCTION get_boolean_property ( property_name   IN      VARCHAR)
  RETURN   BOOLEAN,
  MEMBER FUNCTION get_byte_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_short_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_int_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_long_property ( property_name   IN      VARCHAR)
  RETURN   NUMBER,
  MEMBER FUNCTION get_float_property ( property_name   IN      VARCHAR)
  RETURN   FLOAT,
  MEMBER FUNCTION get_double_property ( property_name   IN      VARCHAR)
  RETURN   DOUBLE PRECISION,
  MEMBER FUNCTION get_string_property ( property_name   IN      VARCHAR)
  RETURN   VARCHAR
);
show errors;
alter type aq$_jms_bytes_message replace authid current_user as object
(
  header     aq$_jms_header,
  bytes_len  int,
  bytes_raw  raw(2000),
  bytes_lob  blob,
  STATIC FUNCTION construct RETURN aq$_jms_bytes_message,
  MEMBER PROCEDURE set_bytes ( payload IN RAW ),
  MEMBER PROCEDURE set_bytes ( payload IN BLOB ),
  MEMBER PROCEDURE get_bytes ( payload OUT RAW ),
  MEMBER PROCEDURE get_bytes ( payload OUT BLOB ),
  STATIC FUNCTION get_exception 
  RETURN AQ$_JMS_EXCEPTION,
  STATIC PROCEDURE clean_all,
  MEMBER FUNCTION prepare (id IN PLS_INTEGER) 
  RETURN PLS_INTEGER,
  MEMBER FUNCTION clear_body (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,
  MEMBER FUNCTION get_mode (id IN PLS_INTEGER)  
  RETURN PLS_INTEGER,
  MEMBER PROCEDURE reset (id IN PLS_INTEGER),
  MEMBER PROCEDURE flush (id IN PLS_INTEGER),  
  MEMBER PROCEDURE clean (id IN PLS_INTEGER),
  MEMBER FUNCTION read_boolean (id IN PLS_INTEGER)
  RETURN BOOLEAN,
  MEMBER FUNCTION read_byte (id IN PLS_INTEGER) 
  RETURN PLS_INTEGER,
  MEMBER FUNCTION read_bytes (id IN PLS_INTEGER, value OUT NOCOPY BLOB, length IN PLS_INTEGER) 
  RETURN PLS_INTEGER,
  MEMBER FUNCTION read_char (id IN PLS_INTEGER)  
  RETURN CHAR,
  MEMBER FUNCTION read_double (id IN PLS_INTEGER) 
  RETURN DOUBLE PRECISION,
  MEMBER FUNCTION read_float (id IN PLS_INTEGER)  
  RETURN FLOAT,
  MEMBER FUNCTION read_int (id IN PLS_INTEGER)  
  RETURN PLS_INTEGER,
  MEMBER FUNCTION read_long (id IN PLS_INTEGER)  
  RETURN NUMBER,
  MEMBER FUNCTION read_short (id IN PLS_INTEGER) 
  RETURN PLS_INTEGER,
  MEMBER FUNCTION read_unsigned_byte (id IN PLS_INTEGER) 
  RETURN PLS_INTEGER,
  MEMBER FUNCTION read_unsigned_short (id IN PLS_INTEGER) 
  RETURN PLS_INTEGER,
  MEMBER PROCEDURE read_utf (id IN PLS_INTEGER, value OUT NOCOPY CLOB),
  MEMBER PROCEDURE write_boolean (id IN PLS_INTEGER, value IN BOOLEAN), 
  MEMBER PROCEDURE write_byte (id IN PLS_INTEGER, value IN PLS_INTEGER),
  MEMBER PROCEDURE write_bytes (id IN PLS_INTEGER, value IN RAW),
  MEMBER PROCEDURE write_bytes (id IN PLS_INTEGER, value IN BLOB),
  MEMBER PROCEDURE write_bytes (
         id        IN      PLS_INTEGER, 
         value     IN      RAW,
	 offset    IN      PLS_INTEGER,
	 length    IN      PLS_INTEGER
  ),
  MEMBER PROCEDURE write_bytes (
         id        IN      PLS_INTEGER, 
         value     IN      BLOB,
         offset    IN      PLS_INTEGER,
         length    IN      PLS_INTEGER
  ),
  MEMBER PROCEDURE write_char (id IN PLS_INTEGER, value IN CHAR),
  MEMBER PROCEDURE write_double (id IN PLS_INTEGER, value IN DOUBLE PRECISION), 
  MEMBER PROCEDURE write_float (id IN PLS_INTEGER, value IN FLOAT),
  MEMBER PROCEDURE write_int (id IN PLS_INTEGER, value IN PLS_INTEGER),
  MEMBER PROCEDURE write_long (id IN PLS_INTEGER, value IN NUMBER),
  MEMBER PROCEDURE write_short (id IN PLS_INTEGER, value IN PLS_INTEGER),
  MEMBER PROCEDURE write_utf (id IN PLS_INTEGER, value IN VARCHAR2),
  MEMBER PROCEDURE write_utf (id IN PLS_INTEGER, value IN CLOB),
  MEMBER PROCEDURE set_replyto (replyto IN      sys.aq$_agent),
  MEMBER PROCEDURE set_type (type       IN      VARCHAR ),
  MEMBER PROCEDURE set_userid (userid   IN      VARCHAR ),
  MEMBER PROCEDURE set_appid (appid     IN      VARCHAR ),
  MEMBER PROCEDURE set_groupid (groupid IN      VARCHAR ),
  MEMBER PROCEDURE set_groupseq (groupseq       IN      int ),
  MEMBER PROCEDURE clear_properties ,
  MEMBER PROCEDURE set_boolean_property (
                property_name   IN      VARCHAR,
                property_value  IN      BOOLEAN ),
  MEMBER PROCEDURE set_byte_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_short_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_int_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_long_property (
                property_name   IN      VARCHAR,
                property_value  IN      NUMBER ),
  MEMBER PROCEDURE set_float_property (
                property_name   IN      VARCHAR,
                property_value  IN      FLOAT ),
  MEMBER PROCEDURE set_double_property (
                property_name   IN      VARCHAR,
                property_value  IN      DOUBLE PRECISION ),
  MEMBER PROCEDURE set_string_property (
                property_name   IN      VARCHAR,
                property_value  IN      VARCHAR ),
  MEMBER FUNCTION get_replyto RETURN sys.aq$_agent,
  MEMBER FUNCTION get_type RETURN VARCHAR,
  MEMBER FUNCTION get_userid RETURN VARCHAR,
  MEMBER FUNCTION get_appid RETURN VARCHAR,
  MEMBER FUNCTION get_groupid RETURN VARCHAR,
  MEMBER FUNCTION get_groupseq RETURN int,
  MEMBER FUNCTION get_boolean_property ( property_name   IN      VARCHAR)
  RETURN   BOOLEAN,
  MEMBER FUNCTION get_byte_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_short_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_int_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_long_property ( property_name   IN      VARCHAR)
  RETURN   NUMBER,
  MEMBER FUNCTION get_float_property ( property_name   IN      VARCHAR)
  RETURN   FLOAT,
  MEMBER FUNCTION get_double_property ( property_name   IN      VARCHAR)
  RETURN   DOUBLE PRECISION,
  MEMBER FUNCTION get_string_property ( property_name   IN      VARCHAR)
  RETURN   VARCHAR
);
show errors;
alter type aq$_jms_stream_message replace authid current_user as object
(
  header     aq$_jms_header,
  bytes_len  int,
  bytes_raw  raw(2000),
  bytes_lob  blob,
  STATIC FUNCTION construct RETURN aq$_jms_stream_message,
  STATIC FUNCTION get_exception 
  RETURN AQ$_JMS_EXCEPTION,
  STATIC PROCEDURE clean_all,
  MEMBER FUNCTION prepare (id IN PLS_INTEGER) 
  RETURN PLS_INTEGER,
  MEMBER FUNCTION clear_body (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,
  MEMBER FUNCTION get_mode (id IN PLS_INTEGER)  
  RETURN PLS_INTEGER,
  MEMBER PROCEDURE reset (id IN PLS_INTEGER),
  MEMBER PROCEDURE flush (id IN PLS_INTEGER),  
  MEMBER PROCEDURE clean (id IN PLS_INTEGER),
  MEMBER PROCEDURE read_object (id IN PLS_INTEGER, value OUT NOCOPY AQ$_JMS_VALUE),
  MEMBER FUNCTION read_boolean (id IN PLS_INTEGER)
  RETURN BOOLEAN,
  MEMBER FUNCTION read_byte (id IN PLS_INTEGER) 
  RETURN PLS_INTEGER,
  MEMBER PROCEDURE read_bytes (id IN PLS_INTEGER, value OUT NOCOPY BLOB),
  MEMBER FUNCTION read_char (id IN PLS_INTEGER)  
  RETURN CHAR,
  MEMBER FUNCTION read_double (id IN PLS_INTEGER) 
  RETURN DOUBLE PRECISION,
  MEMBER FUNCTION read_float (id IN PLS_INTEGER)  
  RETURN FLOAT,
  MEMBER FUNCTION read_int (id IN PLS_INTEGER)  
  RETURN PLS_INTEGER,
  MEMBER FUNCTION read_long (id IN PLS_INTEGER)  
  RETURN NUMBER,
  MEMBER FUNCTION read_short (id IN PLS_INTEGER) 
  RETURN PLS_INTEGER,
  MEMBER PROCEDURE read_string (id IN PLS_INTEGER, value OUT NOCOPY CLOB), 
  MEMBER PROCEDURE write_boolean (id IN PLS_INTEGER, value IN BOOLEAN), 
  MEMBER PROCEDURE write_byte (id IN PLS_INTEGER, value IN PLS_INTEGER),
  MEMBER PROCEDURE write_bytes (id IN PLS_INTEGER, value IN RAW),
  MEMBER PROCEDURE write_bytes (id IN PLS_INTEGER, value IN BLOB),
  MEMBER PROCEDURE write_bytes (
         id        IN      PLS_INTEGER, 
         value     IN      RAW,
	 offset    IN      PLS_INTEGER,
	 length    IN      PLS_INTEGER
  ),
  MEMBER PROCEDURE write_bytes (
         id        IN      PLS_INTEGER, 
         value     IN      BLOB,
         offset    IN      PLS_INTEGER,
         length    IN      PLS_INTEGER
  ),
  MEMBER PROCEDURE write_char (id IN PLS_INTEGER, value IN CHAR),
  MEMBER PROCEDURE write_double (id IN PLS_INTEGER, value IN DOUBLE PRECISION), 
  MEMBER PROCEDURE write_float (id IN PLS_INTEGER, value IN FLOAT),
  MEMBER PROCEDURE write_int (id IN PLS_INTEGER, value IN PLS_INTEGER),
  MEMBER PROCEDURE write_long (id IN PLS_INTEGER, value IN NUMBER),
  MEMBER PROCEDURE write_short (id IN PLS_INTEGER, value IN PLS_INTEGER),
  MEMBER PROCEDURE write_string (id IN PLS_INTEGER, value IN VARCHAR2),
  MEMBER PROCEDURE write_string (id IN PLS_INTEGER, value IN CLOB),
  MEMBER PROCEDURE set_replyto (replyto IN      sys.aq$_agent),
  MEMBER PROCEDURE set_type (type       IN      VARCHAR ),
  MEMBER PROCEDURE set_userid (userid   IN      VARCHAR ),
  MEMBER PROCEDURE set_appid (appid     IN      VARCHAR ),
  MEMBER PROCEDURE set_groupid (groupid IN      VARCHAR ),
  MEMBER PROCEDURE set_groupseq (groupseq       IN      int ),
  MEMBER PROCEDURE clear_properties ,
  MEMBER PROCEDURE set_boolean_property (
                property_name   IN      VARCHAR,
                property_value  IN      BOOLEAN ),
  MEMBER PROCEDURE set_byte_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_short_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_int_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_long_property (
                property_name   IN      VARCHAR,
                property_value  IN      NUMBER ),
  MEMBER PROCEDURE set_float_property (
                property_name   IN      VARCHAR,
                property_value  IN      FLOAT ),
  MEMBER PROCEDURE set_double_property (
                property_name   IN      VARCHAR,
                property_value  IN      DOUBLE PRECISION ),
  MEMBER PROCEDURE set_string_property (
                property_name   IN      VARCHAR,
                property_value  IN      VARCHAR ),
  MEMBER FUNCTION get_replyto RETURN sys.aq$_agent,
  MEMBER FUNCTION get_type RETURN VARCHAR,
  MEMBER FUNCTION get_userid RETURN VARCHAR,
  MEMBER FUNCTION get_appid RETURN VARCHAR,
  MEMBER FUNCTION get_groupid RETURN VARCHAR,
  MEMBER FUNCTION get_groupseq RETURN int,
  MEMBER FUNCTION get_boolean_property ( property_name   IN      VARCHAR)
  RETURN   BOOLEAN,
  MEMBER FUNCTION get_byte_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_short_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_int_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_long_property ( property_name   IN      VARCHAR)
  RETURN   NUMBER,
  MEMBER FUNCTION get_float_property ( property_name   IN      VARCHAR)
  RETURN   FLOAT,
  MEMBER FUNCTION get_double_property ( property_name   IN      VARCHAR)
  RETURN   DOUBLE PRECISION,
  MEMBER FUNCTION get_string_property ( property_name   IN      VARCHAR)
  RETURN   VARCHAR
);
show errors;
alter type aq$_jms_map_message replace authid current_user as object
(
  header     aq$_jms_header,
  bytes_len  int,
  bytes_raw  raw(2000),
  bytes_lob  blob,
  STATIC FUNCTION construct RETURN aq$_jms_map_message,
  STATIC FUNCTION get_exception 
  RETURN AQ$_JMS_EXCEPTION,
  STATIC PROCEDURE clean_all,
  MEMBER FUNCTION prepare (id IN PLS_INTEGER) 
  RETURN PLS_INTEGER,
  MEMBER FUNCTION clear_body (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,
  MEMBER PROCEDURE flush (id IN PLS_INTEGER),  
  MEMBER PROCEDURE clean (id IN PLS_INTEGER),
  MEMBER FUNCTION get_size (id IN PLS_INTEGER)
  RETURN PLS_INTEGER,
  MEMBER FUNCTION get_names (id IN PLS_INTEGER)
  RETURN AQ$_JMS_NAMEARRAY,
  MEMBER FUNCTION get_names (
         id       IN        PLS_INTEGER,
         names    OUT       AQ$_JMS_NAMEARRAY,
         offset   IN        PLS_INTEGER,
         length   IN        PLS_INTEGER )
  RETURN PLS_INTEGER,
  MEMBER FUNCTION item_exists (id IN PLS_INTEGER, name IN VARCHAR2)
  RETURN BOOLEAN,
  MEMBER PROCEDURE get_object (id IN PLS_INTEGER, name IN VARCHAR2, value OUT NOCOPY AQ$_JMS_VALUE), 
  MEMBER FUNCTION get_boolean (id IN PLS_INTEGER, name IN VARCHAR2)
  RETURN BOOLEAN,
  MEMBER FUNCTION get_byte (id IN PLS_INTEGER, name IN VARCHAR2) 
  RETURN PLS_INTEGER,
  MEMBER PROCEDURE get_bytes (id IN PLS_INTEGER, name IN VARCHAR2, value OUT NOCOPY BLOB),
  MEMBER FUNCTION get_char (id IN PLS_INTEGER, name IN VARCHAR2)  
  RETURN CHAR,
  MEMBER FUNCTION get_double (id IN PLS_INTEGER, name IN VARCHAR2) 
  RETURN DOUBLE PRECISION,
  MEMBER FUNCTION get_float (id IN PLS_INTEGER, name IN VARCHAR2)  
  RETURN FLOAT,
  MEMBER FUNCTION get_int (id IN PLS_INTEGER, name IN VARCHAR2)  
  RETURN PLS_INTEGER,
  MEMBER FUNCTION get_long (id IN PLS_INTEGER, name IN VARCHAR2)  
  RETURN NUMBER,
  MEMBER FUNCTION get_short (id IN PLS_INTEGER, name IN VARCHAR2) 
  RETURN PLS_INTEGER,
  MEMBER PROCEDURE get_string (id IN PLS_INTEGER, name IN VARCHAR2, value OUT NOCOPY CLOB), 
  MEMBER PROCEDURE set_boolean (id IN PLS_INTEGER, name IN VARCHAR2, value IN BOOLEAN), 
  MEMBER PROCEDURE set_byte (id IN PLS_INTEGER, name IN VARCHAR2, value IN PLS_INTEGER),
  MEMBER PROCEDURE set_bytes (id IN PLS_INTEGER, name IN VARCHAR2, value IN RAW),
  MEMBER PROCEDURE set_bytes (id IN PLS_INTEGER, name IN VARCHAR2, value IN BLOB),
  MEMBER PROCEDURE set_bytes (
         id        IN      PLS_INTEGER,
         name      IN      VARCHAR2,
         value     IN      RAW,
	 offset    IN      PLS_INTEGER,
	 length    IN      PLS_INTEGER
  ),
  MEMBER PROCEDURE set_bytes (
         id        IN      PLS_INTEGER, 
         name      IN      VARCHAR2,
         value     IN      BLOB,
         offset    IN      PLS_INTEGER,
         length    IN      PLS_INTEGER
  ),
  MEMBER PROCEDURE set_char (id IN PLS_INTEGER, name IN VARCHAR2, value IN CHAR),
  MEMBER PROCEDURE set_double (id IN PLS_INTEGER, name IN VARCHAR2, value IN DOUBLE PRECISION), 
  MEMBER PROCEDURE set_float (id IN PLS_INTEGER, name IN VARCHAR2, value IN FLOAT),
  MEMBER PROCEDURE set_int (id IN PLS_INTEGER, name IN VARCHAR2, value IN PLS_INTEGER),
  MEMBER PROCEDURE set_long (id IN PLS_INTEGER, name IN VARCHAR2, value IN NUMBER),
  MEMBER PROCEDURE set_short (id IN PLS_INTEGER, name IN VARCHAR2, value IN PLS_INTEGER),
  MEMBER PROCEDURE set_string (id IN PLS_INTEGER, name IN VARCHAR2, value IN VARCHAR2),
  MEMBER PROCEDURE set_string (id IN PLS_INTEGER, name IN VARCHAR2, value IN CLOB),
  MEMBER PROCEDURE set_replyto (replyto IN      sys.aq$_agent),
  MEMBER PROCEDURE set_type (type       IN      VARCHAR ),
  MEMBER PROCEDURE set_userid (userid   IN      VARCHAR ),
  MEMBER PROCEDURE set_appid (appid     IN      VARCHAR ),
  MEMBER PROCEDURE set_groupid (groupid IN      VARCHAR ),
  MEMBER PROCEDURE set_groupseq (groupseq       IN      int ),
  MEMBER PROCEDURE clear_properties ,
  MEMBER PROCEDURE set_boolean_property (
                property_name   IN      VARCHAR,
                property_value  IN      BOOLEAN ),
  MEMBER PROCEDURE set_byte_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_short_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_int_property (
                property_name   IN      VARCHAR,
                property_value  IN      int ),
  MEMBER PROCEDURE set_long_property (
                property_name   IN      VARCHAR,
                property_value  IN      NUMBER ),
  MEMBER PROCEDURE set_float_property (
                property_name   IN      VARCHAR,
                property_value  IN      FLOAT ),
  MEMBER PROCEDURE set_double_property (
                property_name   IN      VARCHAR,
                property_value  IN      DOUBLE PRECISION ),
  MEMBER PROCEDURE set_string_property (
                property_name   IN      VARCHAR,
                property_value  IN      VARCHAR ),
  MEMBER FUNCTION get_replyto RETURN sys.aq$_agent,
  MEMBER FUNCTION get_type RETURN VARCHAR,
  MEMBER FUNCTION get_userid RETURN VARCHAR,
  MEMBER FUNCTION get_appid RETURN VARCHAR,
  MEMBER FUNCTION get_groupid RETURN VARCHAR,
  MEMBER FUNCTION get_groupseq RETURN int,
  MEMBER FUNCTION get_boolean_property ( property_name   IN      VARCHAR)
  RETURN   BOOLEAN,
  MEMBER FUNCTION get_byte_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_short_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_int_property ( property_name   IN      VARCHAR)
  RETURN   int,
  MEMBER FUNCTION get_long_property ( property_name   IN      VARCHAR)
  RETURN   NUMBER,
  MEMBER FUNCTION get_float_property ( property_name   IN      VARCHAR)
  RETURN   FLOAT,
  MEMBER FUNCTION get_double_property ( property_name   IN      VARCHAR)
  RETURN   DOUBLE PRECISION,
  MEMBER FUNCTION get_string_property ( property_name   IN      VARCHAR)
  RETURN   VARCHAR
);
show errors;
grant execute on aq$_jms_message to public;
grant execute on aq$_jms_text_message to public;
grant execute on aq$_jms_bytes_message to public;
grant execute on aq$_jms_stream_message to public;
grant execute on aq$_jms_map_message to public;
grant execute on aq$_jms_object_message to public;
grant execute on aq$_jms_header to public;
grant execute on aq$_jms_userproparray to public;
grant execute on aq$_jms_userproperty to public;
grant execute on aq$_jms_value to public;
grant execute on aq$_jms_exception to public;
grant execute on aq$_jms_namearray to public;
CREATE OR REPLACE PACKAGE dbms_jms_plsql wrapped 
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
9
4c34 9d2
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
wrvilfaDDV2TRl0BV/iq1pDkmyRk/m8w

/
show errors;
CREATE OR REPLACE PACKAGE BODY DBMS_JMS_PLSQL wrapped 
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
b
534 1fa
kF7ioMOd6txBRi5b4e2ZgMENr/4wg9deDyDWyi+aA08GHAXbIUgx63GcbsB5KRZX3RsiOnOd
laYtEbViDEWRovQcv/74HSFUqganDgnYHSukWZ2/IO9HnKYhkzl8ehMrPKfVvQ3xgCXfGojT
w7pjH9E4BAs24nTR+0pNHqT8nGMKUJG6Yq6oH+7ULpR5vnSyCxVc2wjvJO/t4JF+745lLANM
hK1UVSXC9WKhwmX4gi46JhXHfVvTQa/pAguDx97eDJL3YEfMgFU1/CTDQRgnMhE2gN4g3cPy
veZCxsVJafZj+KN/0K01PlsduvdTX5VtsVEWFb5a3E7XAkYqGu89qyWFVrSk+lokZas7q6Va
dSx7lWq9/2gS3hbaQG+wqeJSZX7TT0KlYUAAHC21zfdC/9bq2WXfMuZ993NtTvnxrTUBp6Au
ZxkkDnXVdL9V9egok9XwaMi1xPUE5m3DP5nvSHWwUoNW7GT6K+NTb/bG/V3BsCDwWa3I

/
show errors;
CREATE OR REPLACE TYPE BODY aq$_jms_header wrapped 
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
e
2d80 672
traQ9T1bjjLkGCBJSN2IycBXo90wg82TTLcGFo5VsddkjzgKGyutp/Rh/+LrXgIYn8kL4B0p
pE/kvU5ltZ1v53Wma9YpEb8FC5NARtDH7nbRi4cjtO9LR7Fbpiy1ez+a94YdrPZG+6kU56a0
a1XxVc1SvOYe4e/IizqdlfmFHIrz6AcLOb/nRoiScjCJkY+9Bj0d23Dd1KHn+JNRefEt1ZhV
qS8h9WbK1SWOdKYQZwEMM5OWWJNdZ0rnhnbQfFnnBv6OzZeA7sEwq3OkKG9RW5c8fuTpykjf
rTm9eGDhbONf370b9SHlAKGoa8/JEkSTo1QN57evWlQwILo7/RKSMKOksv1gccOMJjFNZcTx
12Ivv21gGOdRgF8zKTeLysNEYTYGalYEUuXubwGgN4isJddaMpLBHIUGUTlUP/04PpxeFj9D
ZfK0F6DKL+kfOcZkQVRENVeT1mmHcy2RW0AbDEGpuJ3BMENDbvqNAARBFjBReVKH53pcpele
zYhBxUEdoVCM211skJUUjHJqm9GenJwAqeo+rM5UeSoSzuVK0GJ2RsFGp0L/YHLcmJlGPN89
pMiVKVBV7r3oROV7WlbHEKy32iYuhDqtVVLDeXePfiRwny3kbWFmpwKXt8cyTqcvCzDnPdRk
sbhNabo3qOPGhmtLSOdmP3hQNMzy7Nho3Yk0QViGG4Kz9lQJ+ezUd3pT3qPr3qt7cqyD9AI/
aWu1H/Swn93wK0Kv/x0SMnvZ6Fs9cYW8Ld6aThjeDQZs5lIeGpIfhoZ9y45MldkqbqY3DKma
Z45yNUrXwQ+vwRb5JeRk+v4g65HnIvTMP3NdFk85sh7oukMzmJI6JROCUBfX5VGXYnGXmTAK
YU869bbVQoV/ENYnkNtOWIRkNOUolaeGfNee2PnD9pMyrZTGeOgGU4wYWGEZDkCGEXtPP1hH
6MuoT/z4acd5fBspnpJM/CPAC0VB9Xcy7BcFCufa1TYj/v5jsQmX0tSJZc1NiS7sah7OZzfS
y43Avwvyvh5NiTKHVuseNA6JadirO9PxXTHaw9eK1MOCHpJBZ1LAYwOF816y5BrAoWuizzjX
bI3u1r7T8kwbwePbYvOuN9KCmQAghlDU6IUriSB9eY0ZTTyr76OPWXJINisUk2EJKbIkVkHx
S6nc8VKs419ALOZYQEt8gy+Dwh+rQFoAbrLMydHkL5HC7n5fPBQC8OZQjES3eoRT/F1bOBey
o+RHynx+9++0M6adt4DLavbc2iUwjUVnyeuFJxV+zZtPwpq/zjbZiZoA2qaKH/J55eFNtKFy
2cGQ6+i+xJ/tWwvGmAqjePNUh3WBK+PqHmoLQ58fYhQeHOj0ZIv7ispkWX3fdHeh2IBaMBFR
kwPR7UEz/080LuXSmHwN2R4wI2QQt3TFa8DtCEoylztuvifDG2LsCfwld0283d8fwj1U9mO3
cEgU1nrQbLHWzRn/a3vaqxCUU0yaLzHP5Q24iptKutQHIoLk5BOdK/ng/j80Iqojj4F4EjuK
Lm6Yu3GbI3By55afDmRf/T8WObAg9DWCirE35n/bB+CluWJ/EQKGe2kR1DEijhMDGbSK7rtf
iGweZ+hOlHNArW4SwIU8sQbI17mA5g9axbVzhqpO8EhS

/
CREATE OR REPLACE TYPE BODY aq$_jms_message wrapped 
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
e
3b67 938
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
rloeGck11lmaqvgofYBklA==

/
show errors;
CREATE OR REPLACE TYPE BODY aq$_jms_text_message wrapped 
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
e
22c3 611
3ACAi5d+ecB5Xq/K+cnP4s8CgGowg0OTedAG3y+5Fz+Vz0319KLqijN3XgzECdMbqFxLrQUx
p67ktaqzLQtJUodUt0MvsYQWNn5yenJHCxJZdynjyJtVvfFkJE+1IoUDFao9OqkJG0TmZurV
pibTXMnIsVZebBfIUhuNTYJE4VxitF1Uq+ryRRpUiV8i7gnBhfV9nXFkABvajvMKCieyx7Eu
x7ZkgMnfc0oIp4P3zWHsw04ij6jp+4Cvgmg94TVRZYVmVxuwGEnaFog0bGYFSQZE4Mae7A4B
lK7EHPplB02kPvC64zXN94FLiPyUZc6GlN9LKmJUoW4p5iwCg9oDLc1yhTXcw6PEzcgkD+5O
yQOIznnsQuViJ1S6ZO5i6526Hwui7SIZtEzyrWaMrljdomsVavdtom5mkvA/co+BlrYmKpGh
YYBzjYnWCLTdJFHD5/N0W0oJg8Vd3fboX+kMz7yWcsfy2Ln4epo+O05uoGeQ5Foo4LDM8O7B
4cExxgWNTwMBZXcnHhQwAovo0t+W4/px/ttQxDyblmnwkSf4WxHHh24QITuCk7Cgpq2uHtym
pYrAiy6wrYEjSJAzr6t9wDIuBp4TV31lxvYqLaxUDb5AfbGclp0Qf30mlUblkZ6ZjoaBY0OM
t9c9d2aGz7aWsb7XCxfmgk/E7rhZsDGIfRv0LR45zEGyjAgGsYNRlAtbcyYGWUBHQh7ByV68
vh6Fzn9+owVgqjvfRl2hQczn0UGiCfJ3mt6tET8YP0I65OTaeelPWVoiModu4s8TAMY7cSTY
Z+0w9QYTmjTmiX/DnCp35R4QEPkk/rLZmIQxnFBReQtNYTch3WRErGGUN8b8GleiuUCfb05m
+iIpwm38f+joxFjoq06bg3In6+R3TgZuWWktYeP0x2gK/opLvwwi4x+iZylReGWxi0NmcB8L
MJzkIQiI0TUNHnXjH9yyPMrLOzj29FEaQz0/Pyh2/U1vUhZyXTB3IRPQu++cOfbWV4kBqDB5
MEUTxhfe93vb6n+Nzj0JPb/5dmPlfcwx07RvMuea2BWibin48wLFzD9w+qTso0vF6G6384tf
bnDPFr8uF6d2uHqxPE4dGfHl1EipgYGp9HZgqJtXZBDma1Hcrp6707HGbnYccxM2w7m+aSS4
ohD5eL0+83M3HYMXqre4K26Uv/RJCvD+xpkmHzcT2yGwjHIQoid6AHBZc+doFE3ah7A9EJ+w
1JQqCyvyc8ruCOF649R539Vsl9piOdASdgQ2ODhwBYBp6f4fhB92+Kn6+CwLKv4El+AeiKx8
xJKOIpsxQCLbTzrBqEeTxwQcvpgVWHMdykeQrYk/27rHyyjHya5ALFLBSmrqVxoDMYULiOi2
eCJHBc56gf8h0OodVDzm56DZxqfdvSpX6DZqzRs1cMqWdufha8sopprLHmMJ2i/YD6Oq2k1O
6X7KUDWzRabeXvBAqe1pHDlRpKfWmY+rtqgRlpSHN7iAAjzhNGqexTaSlfEb9UWyDHVEtGRU
PJZvmQCFkpLrqlhK4Wc=

/
show errors;
CREATE OR REPLACE TYPE BODY aq$_jms_bytes_message wrapped 
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
e
5e8b bc9
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
3TOC6IGvka98WPm1zaorWo+x

/
show errors;
CREATE OR REPLACE TYPE BODY aq$_jms_stream_message wrapped 
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
e
5425 9c6
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
khHCj3VWh7XOLH4VrNU=

/
show errors;
CREATE OR REPLACE TYPE BODY aq$_jms_map_message wrapped 
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
e
5bb4 aad
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
YmgVVlAQYFRPaFYwxW2aquQoKHqiog==

/
show errors;
ALTER PACKAGE DBMS_AQIN COMPILE;
ALTER PUBLIC SYNONYM DBMS_AQIN COMPILE;
show errors;
