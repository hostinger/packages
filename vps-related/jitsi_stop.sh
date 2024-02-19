#!/bin/bash

systemctl stop \
	coturn.service \
	jicofo.service \
	jitsi-videobridge2.service \
	nginx.service \
	prosody.service