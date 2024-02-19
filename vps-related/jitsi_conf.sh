#!/bin/bash

set -euo pipefail
shopt -s inherit_errexit

export \
	DEBIAN_FRONTEND="noninteractive" \
	DEBIAN_PRIORITY="critical" \
	NEEDRESTART_SUSPEND="1"

password_authorization=0

# User choices
read -e -r -p "Please specify which domain you would like to use: " host_name
read -e -r -p "Please enter your email address for Let's Encrypt Registration: " cert_email
read -r -p "Would you like to enable password authorization? [y/N] " response
case "${response}" in
	[yY][eE][sS] | [yY])
		password_authorization=1
		;;
	*) ;;

esac

: "${host_name:?}" "${cert_email:?}"

prosody_conf="/etc/prosody/conf.avail/${host_name}.cfg.lua"
jitsi_conf="/etc/jitsi/meet/${host_name}-config.js"
jicofo_conf="/etc/jitsi/jicofo/sip-communicator.properties"

########
# Stop services and purge packages
########
/opt/hostinger/scripts/jitsi_stop.sh
sleep 5 # Avoid race - give services a chance to fully stop
apt-get --assume-yes purge \
	jicofo \
	jigasi \
	jitsi-meet \
	jitsi-meet-prosody \
	jitsi-meet-turnserver \
	jitsi-meet-web \
	jitsi-meet-web-config \
	jitsi-videobridge2

########
# Reinstall packages
########
printf '%s %s %s %s' "jitsi-videobridge2" "jitsi-videobridge/jvb-hostname" "string" "${host_name}" |
	debconf-set-selections

printf '%s %s %s %s' \
	"jitsi-meet-web-config" \
	"jitsi-meet/cert-choice" \
	"string" \
	"Generate a new self-signed certificate (You will later get a chance to obtain a Let's encrypt certificate" |
	debconf-set-selections

apt-get update
apt-get --assume-yes install jitsi-meet

########
# Configure Lets Encrypt
########
systemctl restart nginx.service
# shellcheck disable=SC2016
sed -i \
	-e '/echo.*Enter your email and press.*/d' \
	-e '/read EMAIL/d' /usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh

/usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh "${cert_email}"

[[ "${password_authorization}" == 0 ]] ||
	{
		########
		# Configure Prosody
		########
		sed -i -e 's/authentication\ \=\ \"anonymous\"/authentication\ \=\ \"internal_plain\"/g' "${prosody_conf}"
		cat >> "${prosody_conf}" << EOT
VirtualHost "guest.${host_name}"
    authentication = "anonymous"
    c2s_require_encryption = false

EOT

		########
		# Configure Jitsi
		########
		sed -i \
			-e "s/\/\/ anonymousdomain:\ 'guest.example.com',/anonymousdomain:\ 'guest.${host_name}',/" \
			-e 's/\/\/ desktopSharingF.*/desktopSharingFrameRate: { min: 5, max: 30 },/' "${jitsi_conf}"

		########
		# Configure Jicofo
		########
		printf 'org.jitsi.jicofo.auth.URL=XMPP:%s\n' "${host_name}" >> "${jicofo_conf}"

		########
		# Register Prosody user
		########
		admin_password="$(
			set +euxo pipefail
			tr -dc "[:alnum:]" < /dev/urandom | head -c 16
		)"
		prosodyctl register admin "${host_name}" "${admin_password}"

		########
		# Restart services
		########
		/opt/hostinger/script/jitsi_stop.sh
		sleep 5
		/opt/hostinger/script/jitsi_start.sh
	}
echo "JITSI SETUP COMPLETED!"
echo "JITSI URL: https://${host_name}"

[[ "${password_authorization}" == 0 ]] || printf 'USERNAME: admin\nPASSWORD: %s\n\n' "${admin_password}"