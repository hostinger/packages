#!/bin/bash

systemctl start \
	coturn.service \
	jicofo.service \
	jitsi-videobridge2.service \
	nginx.service \
	prosody.service