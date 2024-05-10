#!/bin/bash
clear
cd /var/discourse

if ./discourse-setup; then
  clear
  echo "Discourse is now installed. Log into your admin account in a browser to continue"
  echo "configuring Discourse."

  cp -f /etc/skel/.bashrc /root/.bashrc
else
  echo ""
  echo "-----------------------------------------------------------------------------"
  echo "The setup script failed with the provided Discourse details."
  echo "It will rerun. Please address the above issues."
  echo "-----------------------------------------------------------------------------"
  echo "When you are ready, press Enter"
  echo "To cancel setup, press Ctrl+C and this script will be rerun on your next login"
  read wait
fi
