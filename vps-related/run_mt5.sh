#!/bin/bash

FLAG_FILE="/root/.mt5_installed_flag"

MT5_SCRIPT="/root/mt5ubuntu.sh"

if [ ! -f "$FLAG_FILE" ]; then
    yes | bash "$MT5_SCRIPT"

    touch "$FLAG_FILE"
fi
