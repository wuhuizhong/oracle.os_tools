create or replace package body db_info_pkg
as

  procedure upsert_db_info
             (
               p_in_nod in varchar2,
               p_in_cdb in varchar2,
               p_in_pdb in varchar2,
               p_in_parameter in varchar2,
               p_in_varde in varchar2
              )
 as
   
   lv_cnt pls_integer := 0;
   
 begin
   
   select count(*) into lv_cnt
   from db_info
   where nod = p_in_nod
     and cdb = p_in_cdb
     and pdb = p_in_pdb
     and parameter = p_in_parameter
     and varde = p_in_varde;
     
  if lv_cnt > 0 then
 
     update db_info
     set parameter = p_in_parameter
        ,varde = p_in_varde
     where nod = p_in_nod
       and cdb = p_in_cdb
       and pdb = p_in_pdb;
      
  else
   
    insert into db_info (nod,cdb,pdb,parameter,varde)
    values(p_in_nod,p_in_cdb,p_in_pdb,p_in_parameter,p_in_varde);
   
  end if;
 
  commit;
      
 end upsert_db_info;
              
  procedure gen_tnsnames_file 
              (
                p_in_client_only in boolean default false
              )
  as

    cursor cur_get_db_info_cdb is
    select distinct cdb, about
    from db_info
    order by cdb asc;

    cursor cur_get_db_info_pdb is
    select cdb
          ,pdb
          ,parameter
          ,varde
          ,about
   from db_info
   where parameter = 'service_names'
   order by cdb,pdb asc;

   lv_tns clob := null;
   lv_tmp clob := null;
   lc_tns_host constant clob := 'td02-scan.systest.receptpartner.se';
   lc_lf constant char(1)  := chr(10);  -- Linux LF
   lc_banner constant clob := '##############################################################';

  begin

    lv_tns := '# tnsnames.ora Network Configuration File: /u01/app/oracle/product/12.2.0.1/dbhome_1/network/admin/tnsnames.ora'||lc_lf||
              '# AUTOGENERATES FROM DB_INFO_PKG on '||to_char(sysdate,'RRRR-MM-DD HH24:MI:SS')||lc_lf||
              lc_banner||lc_lf||lc_lf;

    -- Handling all containers below

    lv_tns := lv_tns||lc_banner||lc_lf||
                      '# ALL CDB databases generated below '||lc_lf||
                      lc_banner||lc_lf||lc_lf;

    for rec in cur_get_db_info_cdb loop

      lv_tmp := lc_banner||lc_lf||
                '# CONTAINER: '||rec.cdb||lc_lf||
                '# ABOUT    : '||nvl(rec.about,'N/A')||lc_lf||
                lc_banner||lc_lf;

      lv_tns := lv_tns||lv_tmp;
      lv_tns := lv_tns||os_tools.gen_tns_entry
                   (
                      p_in_tns_entry => rec.cdb
                      ,p_in_host => lc_tns_host
                      ,p_in_service_name => rec.cdb
                      ,p_in_portno => 1521
                   )||lc_lf;
    end loop;

    -- Handling all pluggable database instances

    lv_tns := lv_tns||lc_banner||lc_lf||
                      '# ALL PDB instances generated below '||lc_lf||
                      lc_banner||lc_lf||lc_lf;
    for rec in cur_get_db_info_pdb loop

      lv_tmp := lc_banner||lc_lf||
                '# PDB      : '||rec.pdb||lc_lf||
                '# CONTAINER: '||rec.cdb||lc_lf||
                '# ABOUT    : '||nvl(rec.about,'N/A')||lc_lf||
                lc_banner||lc_lf;

      --dbms_output.put_line(lv_tmp);
      
      lv_tns := lv_tns||lv_tmp;
      
      -- Client service name (dbms_service generated).
      
      lv_tns := lv_tns||os_tools.gen_tns_entry
                   (
                      p_in_tns_entry => rec.varde
                      ,p_in_host => lc_tns_host
                      ,p_in_service_name => rec.varde
                      ,p_in_portno => 1521
                   )||lc_lf;
      
      -- If server then generate Oracle generated server also             

      if p_in_client_only = false then
      
        lv_tns := lv_tns||os_tools.gen_tns_entry
                     (
                        p_in_tns_entry => rec.pdb
                        ,p_in_host => lc_tns_host
                        ,p_in_service_name => rec.pdb
                        ,p_in_portno => 1521
                     )||lc_lf;
                     
      end if; -- p_in_client_only
      
    end loop; --cur_get_db_info_pdb

    --dbms_output.put_line(lv_tns);

    os_tools.write_clob_to_file
        (
          p_dir=>'UTV_DUMP'
          ,p_filename=>'tnsnames.ora'
          ,p_clob=>lv_tns
        );

  end gen_tnsnames_file;

end db_info_pkg;
/