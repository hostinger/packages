#!/bin/bash

FLAG_FILE="/root/.mt4_installed_flag"

MT4_SCRIPT="/root/mt4ubuntu.sh"

if [ ! -f "$FLAG_FILE" ]; then
    yes | bash "$MT4_SCRIPT"

    touch "$FLAG_FILE"
fi
