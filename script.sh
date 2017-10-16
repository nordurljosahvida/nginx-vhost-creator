#!/usr/bin/env bash

# initial vars [if var name ends with dir include trailing slash as such: /var/www/path/to/dir/]

export var_nginxdir="/etc/nginx/conf.d/"
export var_dhparampath="/etc/ssl/dhparam.pem"

# / initial vars

echo
echo "nginx tls vhost creation tool"
echo "v 1.0 | 2016.03.21 [Initial version 0.1 from 2016.03.07]"
echo "written by Nk [openspace]"
echo

sleep 0.7

echo "Enter the primary server name for this vhost:"
echo
read var_servername
echo
export var_servername="$var_servername"

export var_vhostname="$(echo -e "${var_servername}" | sed -e 's/\./_/g')"

if test -f $var_nginxdir$var_vhostname.conf;

        then	echo "A vhost config file with the same name already exists on this server."
                echo "If you are recreating this config you may proceed by simply typing the name again right here:"
                echo
		read var_servername
		echo
		export var_servername="$var_servername"
		export var_vhostname="$(echo -e "${var_servername}" | sed -e 's/\./_/g')"

fi

export var_altname_zero="www.$var_servername"

cat ${BASH_SOURCE%/*}/config.txt > /tmp/$var_vhostname.conf

read -p "Is this going to be the default host for this server (y/N)? " var_choice
echo

case "$var_choice" in

	y|Y )		echo "Default host mode selected" && \
			var_defserver=yes;;

	n|N|*|"" )	echo "Non-default host mode selected" && \
			var_defserver=no;;

esac

if [ "$var_defserver" = "yes" ];

	then	export var_ipv4listen="listen 443 ssl deferred http2 default_server;"
                export var_ipv6listen="listen [::]:443 ssl deferred http2 ipv6only=on default_server;"

	else	export var_ipv4listen="listen 443 ssl deferred http2;"
                export var_ipv6listen="listen [::]:443 ssl deferred http2 ipv6only=on;"

fi

echo
read -p "Are you using NK CA TLS certificates or LetsEncrypt TLS certificates (NK/LE)? " var_choice
echo

case "$var_choice" in

	nk|NK )	echo "NK CA TLS certificate mode selected" && \
			var_certstype=nk;;

	le|LE|*|"" ) 	echo "LetsEncrypt TLS certificate mode selected" && \
			var_certstype=le;;

esac
echo

if [ "$var_certstype" = "nk" ];

	then	export var_vmname="$(sed 's/\..*//' /etc/hostname)" && \
		export var_certsdir="/etc/ssl/" && \
		export var_certname="certs/$var_vmname.crt" && \
		export var_chainname="null" && \
		export var_keyname="private/$var_vmname.key" #debug previous line

	else	export var_certsdir="/etc/letsencrypt/live/internal-domain.tld-0001/" #debug
		export var_certname="fullchain.pem"
		export var_chainname="chain.pem"
		export var_keyname="privkey.pem"

fi

if test -f $var_dhparampath;

	then	echo "DHParam file found. Reference will be added in config." && \
		sed -i '/#dhparam/a \ \ \ \ ssl_dhparam $var_dhparampath;' /tmp/$var_vhostname.conf

	else	read -p "DHParam file not found. Key generation takes some time but improves security. Would you like to proceed (Y/n)? " var_choice
		echo

		case "$var_choice" in

			y|Y|'' )	echo	"DHParam generation will occurr automatically at the end of this configuration." && \
					var_dhparamgen=yes;;

			n|N|* )		echo "Skipping DHParam generation." && \
					var_dhparamgen=no;;

		esac

fi

echo
echo "Enter the first of any alternative server names for his vhost. If you don't have any simply press return:"
echo
read var_altname_one

if [ "$var_altname_one" != "" ];

then	var_altname_one="$var_altname_one www.$var_altname_one"

	echo
	echo "Enter the second alternative server name for his vhost if you have one. Otherwise simply press return:"
	echo
	read var_altname_two

	if [ "$var_altname_two" != "" ];

	then	var_altname_two="$var_altname_two www.$var_altname_two"
		echo
		echo "Enter the third alternative server name for his vhost if you have one. Otherwise simply press return:"
		echo
		read var_altname_three

		if [ "$var_altname_three" != "" ];

		then	var_altname_three="$var_altname_three www.$var_altname_three"
			echo
			echo "Enter the fourth alternative server name for his vhost if you have one. Otherwise simply press return:"
			echo
			read var_altname_four

			if [ "$var_altname_four" != "" ];

			then	var_altname_four="$var_altname_four www.$var_altname_four"

			fi

		fi

	fi

fi

var_altnames="$var_altname_zero $var_altname_one $var_altname_two $var_altname_three $var_altname_four"
var_altnames="$(echo -e "${var_altnames}" | sed -e 's/[[:space:]]*$//')"
export var_altnames="$var_altnames"

echo "The servername + altnames you've specified are: $var_servername $var_altnames"
echo

read -p "Is this vhost going to serve as a reverse proxy for another virtual machine on the local network? (y/N)? " var_choice
echo

case "$var_choice" in

        y|Y )           echo "Reverse proxy mode selected" && \
                        var_revproxy=yes;;

        n|N|*|"" )      echo "Non-revproxy mode selected" && \
			var_revproxy=no;;

esac
echo

if [ "$var_revproxy" = "yes" ];

	then	echo "Enter the hostname/ip for the vm to be reached when acting as a reverse proxy:"
                echo
                read var_proxyaddress
		echo
		export var_proxyaddress="$var_proxyaddress"
		echo "$(${BASH_SOURCE%/*}/transfer.py ${BASH_SOURCE%/*}/addconfigs/location/main/revproxy.txt)" > /tmp/"$var_vhostname"-location-main.conf
		sed -i "/#location/r /tmp/"$var_vhostname"-location-main.conf" /tmp/$var_vhostname.conf

	else	echo "$(${BASH_SOURCE%/*}/transfer.py ${BASH_SOURCE%/*}/addconfigs/location/main/standard.txt)" > /tmp/"$var_vhostname"-location-main.conf
                sed -i "/#location/r /tmp/"$var_vhostname"-location-main.conf" /tmp/$var_vhostname.conf

fi

if [ "$var_dhparamgen" = "yes" ];

	then	echo "You have previously selected to proceed with DHParam generation."
		echo "This will take some time but the vhost configuration is now complete."
		echo "You can let the final part of this script run and it'll automatically exit once generation is complete as well."
		echo
		echo "Thanks and see you next time! :)"
		openssl dhparam -out $var_dhparampath 4096
		sed -i '/#dhparam/a \ \ \ \ ssl_dhparam $var_dhparampath;' /tmp/$var_vhostname.conf

	else	echo "All done! Thanks and see you next time! :)"

fi

${BASH_SOURCE%/*}/transfer.py /tmp/$var_vhostname.conf > $var_nginxdir$var_vhostname.conf
rm /tmp/$var_vhostname_*.conf

echo
echo '"Program terminated."'
echo
