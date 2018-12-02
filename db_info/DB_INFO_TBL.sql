--------------------------------------------------------
--  DDL for Table DB_INFO
--------------------------------------------------------

  CREATE TABLE "DBTOOLS"."DB_INFO" 
   (	"NOD" VARCHAR2(50 BYTE), 
	"CDB" VARCHAR2(20 BYTE), 
	"PDB" VARCHAR2(20 BYTE), 
	"PARAMETER" VARCHAR2(30 BYTE), 
	"VARDE" VARCHAR2(100 BYTE), 
	"ABOUT" VARCHAR2(100 BYTE)
   ) SEGMENT CREATION IMMEDIATE 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1
  BUFFER_POOL DEFAULT FLASH_CACHE DEFAULT CELL_FLASH_CACHE DEFAULT)
  TABLESPACE "USERS" ;