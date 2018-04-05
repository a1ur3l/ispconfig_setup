#---------------------------------------------------------------------
# Function: InstallBasePhp Debian 8
#    Install Basic php need to run ispconfig
#---------------------------------------------------------------------
InstallBasePhp(){
  	START_TIME=$SECONDS
	echo -n -e "$IDENTATION_LVL_0 ${BWhite}Installing basic php modules for ispconfig${NC}\n"

	echo -n -e "$IDENTATION_LVL_1 ${BWhite}Installing needed components (php7.0) ${NC}\n"
  	package_install php7.0-fpm php7.0-cli php7.0-mysql php7.0-mcrypt
  	echo -e " [ ${green}DONE${NC} ] "

	MeasureTimeDuration $START_TIME
}
