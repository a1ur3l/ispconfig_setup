#---------------------------------------------------------------------
# Function: InstallFail2ban
#    Install and configure fail2ban
#---------------------------------------------------------------------
InstallFail2ban() {
  START_TIME=$SECONDS
  echo -n -e "$IDENTATION_LVL_0 ${BWhite}Installing Fail2Ban${NC}\n"

  echo -n -e "$IDENTATION_LVL_1 Install Needed Components ... "
  package_install fail2ban
  echo -e " [ ${green}DONE${NC} ] "


  echo -n -e "$IDENTATION_LVL_1 Create Basic Jail Roules ... "

  case $CFG_MTA in
	"courier")
    cat > /etc/fail2ban/jail.local <<EOF
[courierpop3]
enabled = true
port = pop3
filter = courierpop3
logpath = /var/log/mail.log
maxretry = 5

[courierpop3s]
enabled = true
port = pop3s
filter = courierpop3s
logpath = /var/log/mail.log
maxretry = 5

[courierimap]
enabled = true
port = imap2
filter = courierimap
logpath = /var/log/mail.log
maxretry = 5

[courierimaps]
enabled = true
port = imaps
filter = courierimaps
logpath = /var/log/mail.log
maxretry = 5

EOF

  cat > /etc/fail2ban/filter.d/courierpop3.conf <<EOF
[Definition]
failregex = pop3d: LOGIN FAILED.*ip=\[.*:<HOST>\]
ignoreregex =
EOF

    cat > /etc/fail2ban/filter.d/courierpop3s.conf <<EOF
[Definition]
failregex = pop3d-ssl: LOGIN FAILED.*ip=\[.*:<HOST>\]
ignoreregex =
EOF

    cat > /etc/fail2ban/filter.d/courierimap.conf <<EOF
[Definition]
failregex = imapd: LOGIN FAILED.*ip=\[.*:<HOST>\]
ignoreregex =
EOF

    cat > /etc/fail2ban/filter.d/courierimaps.conf <<EOF
[Definition]
failregex = imapd-ssl: LOGIN FAILED.*ip=\[.*:<HOST>\]
ignoreregex =
EOF

	;;
  "dovecot")
    cat > /etc/fail2ban/jail.local <<EOF

[dovecot-pop3imap]
enabled = true
filter = dovecot-pop3imap
action = iptables-multiport[name=dovecot-pop3imap, port="pop3,pop3s,imap,imaps", protocol=tcp]
logpath = /var/log/mail.log
maxretry = 5
EOF

    cat > /etc/fail2ban/filter.d/dovecot-pop3imap.conf <<EOF
[Definition]
failregex = (?: pop3-login|imap-login): .*(?:Authentication failure|Aborted login \(auth failed|Aborted login \(tried to use disabled|Disconnected \(auth failed|Aborted login \(\d+ authentication attempts).*rip=(?P<host>\S*),.*
ignoreregex =
EOF

	;;
  esac

  cat >> /etc/fail2ban/jail.local <<EOF
[pureftpd]
enabled = true
port = ftp
filter = pure-ftpd
logpath = /var/log/syslog
maxretry = 3

[postfix-sasl]
enabled = true
port = smtp
filter = postfix-sasl
logpath = /var/log/mail.log
maxretry = 5

EOF

  cat > /etc/fail2ban/filter.d/pure-ftpd.conf <<EOF
[Definition]
failregex = .*pure-ftpd: \(.*@<HOST>\) \[WARNING\] Authentication failed for user.*
ignoreregex =
EOF

  cat > /etc/fail2ban/filter.d/postfix-sasl.conf <<EOF
[Definition]
ignoreregex =

EOF


  cat >> /etc/fail2ban/jail.local <<EOF


#block direct access to wp-config.php*
[nginx-wp-config]
enabled  = false
port     = http,https
filter   = nginx-wp-config
logpath  = /var/www/clients/client*/web*/log/access.log
maxretry = 1
bantime  = 2635200


#block access to /.jpg|/.txt etc
[nginx-wp-dot-access]
enabled  = false
port     = http,https
filter   = nginx-wp-dot-access
logpath  = /var/www/clients/client*/web*/log/access.log
maxretry = 1
bantime  = 2635200


#block errors like "access forbidden by rule"
[nginx-wp-access-denied-by-rule]
enabled  = false
port     = http,https
filter   = nginx-wp-access-denied-by-rule
logpath  = /var/www/clients/client*/web*/log/access.log
maxretry = 1
bantime  = 2635200


#block bad bots from apache
[nginx-badbots]
enabled  = false
port     = http,https
filter   = apache-badbots
logpath  = /var/www/clients/client*/web*/log/access.log
maxretry = 1
bantime  = 86400
EOF

  cat >> /etc/fail2ban/filter.d/nginx-wp-config.conf <<EOF
# Fail2Ban configuration file
[Definition]
failregex = client: <HOST>,.* "(GET|POST) /wp-config.*
ignoreregex =
EOF

  cat >> /etc/fail2ban/filter.d/nginx-wp-dot-access.conf <<EOF
# Fail2Ban configuration file
[Definition]
failregex = client: <HOST>,.* "(GET|POST).*(/\.php|/\.asp|/\.exe|/\.pl|/\.cgi|/\scgi|/\.txt|/\.jpg|/\.html)
ignoreregex =
EOF

  cat >> /etc/fail2ban/filter.d/nginx-wp-access-denied-by-rule.conf <<EOF
# Fail2Ban configuration file
[Definition]
failregex = access forbidden by rule, client: <HOST>.*
ignoreregex =
EOF
  

  echo -e " [ ${green}DONE${NC} ] "

  echo -n -e "$IDENTATION_LVL_1 Restart Fail2Ban Service ... "
  systemctl restart fail2ban >> $PROGRAMS_INSTALL_LOG_FILES 2>&1
  echo -e " [ ${green}DONE${NC} ] "

  echo -n -e "$IDENTATION_LVL_1 Installing Firewall (UFW)... "
  package_install ufw
  echo -e " [ ${green}DONE${NC}] "

  MeasureTimeDuration $START_TIME

}