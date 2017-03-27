#---------------------------------------------------------------------
# Function: InstallBasics
#    Install basic packages
#---------------------------------------------------------------------
InstallAditionalRepos() {
	echo -n -e "Start Adding additional repositories: \n"	
	
	#Add Debian backports - Required for Letsencrypt
    echo -n -e "   --- ${BBlack}Debian Jessie backports${NC} ... "
    echo "##################  Debian Jessie Backports  ##################

deb http://ftp.debian.org/debian jessie-backports main
deb-src http://ftp.debian.org/debian jessie-backports main

deb http://http.debian.net/debian/ jessie-backports main contrib non-free
deb-src http://http.debian.net/debian/ jessie-backports main contrib non-free

###############################################################" > /etc/apt/sources.list.d/jessie-backports.list
	echo -e " [ ${green}DONE${NC} ]"
	
	
	#Add the debian-stretch sources
    echo -n -e "   --- ${BBlack}Debian Stretch Repository${NC} ... "
	echo "#################  Debian Stretch Repository  #################

deb http://httpredir.debian.org/debian/ stretch main contrib non-free
deb-src http://httpredir.debian.org/debian/ stretch main contrib non-free

deb http://security.debian.org/ stretch/updates main contrib non-free
deb-src http://security.debian.org/ stretch/updates main contrib non-free

# stretch-updates, previously known as 'volatile'
deb http://httpredir.debian.org/debian/ stretch-updates main contrib non-free
deb-src http://httpredir.debian.org/debian/ stretch-updates main contrib non-free

###############################################################" > /etc/apt/sources.list.d/stretch-backports.list
    echo -e " [ ${green}DONE${NC} ]"
	
   
    #Add Deb.Sury repo for php
    echo -n -e "   --- ${BBlack}Deb Sury PHP  [ packages.sury.org ] Repository${NC} ... "
    echo "##################  Deb Sury PHP Repository  ##################" >  /etc/apt/sources.list.d/php-deb-sury.list
	echo ""                                                                >> /etc/apt/sources.list.d/php-deb-sury.list
	echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main"      >> /etc/apt/sources.list.d/php-deb-sury.list
	echo ""                                                                >> /etc/apt/sources.list.d/php-deb-sury.list
	echo "###############################################################" >> /etc/apt/sources.list.d/php-deb-sury.list
    echo -e " [ ${green}DONE${NC} ]"
	
    echo -n -e "   --- ${BBlack}Deb Sury PHP [ packages.sury.org ] Repository GnuPG Key${NC} ... "
    wget -q -O /etc/apt/trusted.gpg.d/php-packages-sury-org.gpg https://packages.sury.org/php/apt.gpg && sudo apt-key add php-packages-sury-org.gpg > /dev/null 2>&1
    echo -e " [ ${green}DONE${NC} ]"
  
	
	#Add latest nginx version
    echo -n -e "   --- ${BBlack}Official Nginx [ nginx.org ] Repository${NC}"
    echo "#################  Official Nginx Repository  #################

#latest Official Nginx version
deb https://nginx.org/packages/mainline/debian/ jessie nginx
deb-src https://nginx.org/packages/mainline/debian/ jessie nginx

###############################################################" > /etc/apt/sources.list.d/nginx-latest-official.list
    echo -e " [ ${green}DONE${NC} ]"
	
    echo -n -e "   --- ${BBlack}Official Nginx [ nginx.org ] Repository GnuPG Key${NC} ... "	
    wget -q -O /etc/apt/trusted.gpg.d/nginx_signing.key https://nginx.org/keys/nginx_signing.key && sudo apt-key add nginx_signing.key > /dev/null 2>&1
	echo -e " [ ${green}DONE${NC} ]"
	
	
	#Add dotdeb nginx
    echo -n -e "   --- ${BBlack}DotDeb Nginx [ dotdeb.org ] Repository${NC}"
    echo "#################  Official Nginx Repository  #################

#dotdeb nginx repository
deb http://packages.dotdeb.org jessie-nginx-http2 all
deb-src http://packages.dotdeb.org jessie-nginx-http2 all

###############################################################" > /etc/apt/sources.list.d/nginx-dotdeb.list
    echo -e " [ ${green}DONE${NC} ]"
	
    echo -n -e "   --- ${BBlack}DotDeb Nginx [ dotdeb.org ] Repository GnuPG Key${NC} ... "	
    wget -q -O /etc/apt/trusted.gpg.d/dot-deb.gpg https://www.dotdeb.org/dotdeb.gpg && sudo apt-key add dot-deb.gpg > /dev/null 2>&1
	echo -e " [ ${green}DONE${NC} ]"
	
	
	echo -n -e "   --- Configure ${BBlack}sources priorities via PIN${NC}"
    echo "##############################
Package: *
Pin: release n=jessie
Pin-Priority: 900

Package: * 
Pin: release a=jessie-backports
Pin-Priority: 500

Package: *
Pin: release n=stretch
Pin-Priority: 100
####################################" > /etc/apt/preferences

    echo -e " [ ${green}DONE${NC} ]"
	
    echo -n -e " Aditional Repositories Configuration Complete [ ${green}DONE${NC} ]"
  
  exit 1
}