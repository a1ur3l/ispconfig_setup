#---------------------------------------------------------------------
# Function: InstallISPConfig
#    Start the ISPConfig3 intallation script
#---------------------------------------------------------------------
InstallISPConfig() {
  START_TIME=$SECONDS
  echo -n -e "$IDENTATION_LVL_0 ${BWhite}Installing ISPConfig${NC}\n"

  echo -n -e "$IDENTATION_LVL_1 Download Latest ISPConfig ... "
  #https://sourceforge.net/projects/ispconfig/files/latest/download seems that it have 3.1.2 instead of 3.1.3
  wget -q -O $PROGRAMS_INSTALL_DOWNLOAD/ISPConfig-3-stable-latest.tar.gz https://ispconfig.org/downloads/ISPConfig-3.2.2.tar.gz >>$PROGRAMS_INSTALL_LOG_FILES 2>&1
  echo -e " [ ${green}DONE${NC} ] "

  echo -n -e "$IDENTATION_LVL_1 Untar the downloaded package ... "
  cd $PROGRAMS_INSTALL_DOWNLOAD
  tar xfz $PROGRAMS_INSTALL_DOWNLOAD/ISPConfig-3-stable-latest.tar.gz >>$PROGRAMS_INSTALL_LOG_FILES 2>&1
  cd ispconfig3_install*
  cd install
  echo -n -e $PWD
  echo -e " [ ${green}DONE${NC} ] "

  if [ $CFG_ISPC == "standard" ]; then
    echo -n -e "$IDENTATION_LVL_1 Create the auto install INI file "
    touch autoinstall.ini
    echo -n -e " - start write to autoinstall.ini ">> $PROGRAMS_INSTALL_LOG_FILES 2>&1
    echo "[install]" > autoinstall.ini
    echo "language=en" >> autoinstall.ini
    echo "install_mode=$CFG_ISPC" >> autoinstall.ini
    echo "hostname=$CFG_HOSTNAME_FQDN" >> autoinstall.ini
    echo "mysql_hostname=127.0.0.1" >> autoinstall.ini   
    echo "mysql_root_user=root" >> autoinstall.ini
    echo "mysql_root_password=$CFG_MYSQL_ROOT_PWD" >> autoinstall.ini
    echo "mysql_database=dbispconfig" >> autoinstall.ini
    echo "mysql_port=3306" >> autoinstall.ini
    echo "mysql_charset=utf8" >> autoinstall.ini

    if [ $CFG_WEBSERVER == "apache" ]; then
      echo "http_server=apache" >> autoinstall.ini
    elif [ $CFG_WEBSERVER == "nginx" ]; then
      echo "http_server=nginx" >> autoinstall.ini
    else
      echo "http_server=" >> autoinstall.ini
    fi
    echo -n -e " - start write ports to autoinstall.ini ">> $PROGRAMS_INSTALL_LOG_FILES 2>&1
    echo "ispconfig_port=$CFG_ISPONCFIG_PORT" >> autoinstall.ini
    echo "ispconfig_admin_password=$CFG_ISPONCFIG_ADMIN_PASS" >> autoinstall.ini
    echo "ispconfig_use_ssl=y" >> autoinstall.ini
    echo "apps_vhost_port=$CFG_ISPONCFIG_APPS_PORT" >> autoinstall.ini
    echo "" >> autoinstall.ini
    echo "[ssl_cert]" >> autoinstall.ini
    echo "ssl_cert_country=$SSL_COUNTRY" >> autoinstall.ini
    echo "ssl_cert_state=$SSL_STATE" >> autoinstall.ini
    echo "ssl_cert_locality=$SSL_LOCALITY" >> autoinstall.ini
    echo "ssl_cert_organisation=$SSL_ORGANIZATION" >> autoinstall.ini
    echo "ssl_cert_organisation_unit=$SSL_ORGUNIT" >> autoinstall.ini
    echo "ssl_cert_common_name=$CFG_HOSTNAME_FQDN" >> autoinstall.ini
    echo "" >> autoinstall.ini
    echo "[expert]" >> autoinstall.ini
    echo "mysql_ispconfig_user=ispconfig" >> autoinstall.ini
    echo "mysql_ispconfig_password=$CFG_ISPCONFIG_DB_PASS" >> autoinstall.ini
    echo "join_multiserver_setup=$MULTISERVER" >> autoinstall.ini
    echo "mysql_master_hostname=$CFG_MASTER_FQDN" >> autoinstall.ini
    echo "mysql_master_root_user=root" >> autoinstall.ini
    echo "mysql_master_root_password=$CFG_MASTER_MYSQL_ROOT_PWD" >> autoinstall.ini
    echo "mysql_master_database=dbispconfig" >> autoinstall.ini
    echo "configure_mail=$CFG_SETUP_MAIL" >> autoinstall.ini

    if $(getTrueFalseFormat $CFG_SETUP_WEB) == "true"; then
      echo "configure_jailkit=" getYNFormat $CFG_JKIT >> autoinstall.ini
    else
      echo "configure_jailkit=n" >> autoinstall.ini
    fi
    echo -n -e " - start write ftps to autoinstall.ini ">> $PROGRAMS_INSTALL_LOG_FILES 2>&1
    echo "configure_ftp=" getYNFormat $CFG_SETUP_WEB >> autoinstall.ini
    echo "configure_dns=" getYNFormat $CFG_SETUP_NS >> autoinstall.ini
    echo "configure_apache=" getYNFormat $CFG_APACHE >> autoinstall.ini
    echo "configure_nginx=" getYNFormat $CFG_NGINX >> autoinstall.ini
    echo "configure_firewall=y" >> autoinstall.ini
    echo "install_ispconfig_web_interface=$CFG_SETUP_MASTER" >> autoinstall.ini
    echo "" >> autoinstall.ini
    echo "[update]" >> autoinstall.ini
    echo "do_backup=y" >> autoinstall.ini
    echo "mysql_root_password=$CFG_MYSQL_ROOT_PWD" >> autoinstall.ini
    echo "mysql_master_hostname=$CFG_MASTER_FQDN" >> autoinstall.ini
    echo "mysql_master_root_user=root" >> autoinstall.ini
    echo "mysql_master_root_password=$CFG_MASTER_MYSQL_ROOT_PWD" >> autoinstall.ini
    echo "mysql_master_database=dbispconfig" >> autoinstall.ini
    echo "reconfigure_permissions_in_master_database=n" >> autoinstall.ini
    echo "reconfigure_services=y" >> autoinstall.ini
    echo "apps_vhost_port=$CFG_ISPONCFIG_APPS_PORT" >> autoinstall.ini
    echo "ispconfig_port=$CFG_ISPONCFIG_PORT" >> autoinstall.ini
    echo "create_new_ispconfig_ssl_cert=n" >> autoinstall.ini
    echo "reconfigure_crontab=y" >> autoinstall.ini
    echo -n -e " - start write ftps to autoinstall.ini ">> $PROGRAMS_INSTALL_LOG_FILES 2>&1
    echo -e " [ ${green}DONE${NC} ] "

    echo -n -e "$IDENTATION_LVL_1 Start the automatic install process "

    php -q install.php --autoinstall=autoinstall.ini >>$PROGRAMS_INSTALL_LOG_FILES 2>&1


    echo -e " [ ${green}DONE${NC} ] "
  else
    echo -n -e "$IDENTATION_LVL_1 Start the install. During this you will be asked for serveral questions. Please follow the steps \n "

    php -q install.php
  fi

  if $(getTrueFalseFormat $CFG_SETUP_WEB) == "true"; then
    echo -n -e "$IDENTATION_LVL_1 Restart the webserver "
    if [ $CFG_WEBSERVER == "nginx" ]; then
      service nginx restart
    else
     service apache2 restart
    fi
    echo -e " [ ${green}DONE${NC} ] "
  fi

  MeasureTimeDuration $START_TIME
}
