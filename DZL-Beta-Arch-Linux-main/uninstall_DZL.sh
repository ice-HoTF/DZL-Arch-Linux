#!/bin/bash

### Uninstall DZL###

sudo rm /home/$USER/.local/share/applications/DZL.desktop 
echo "Removing DZL.Desktop from '.local/share/applications'"
sudo rm /usr/share/icons/dzl.png
echo "Removing dzl.png from 'usr/share/icons'"
sudo rm -rf /home/$USER/DZL/
echo "Removing folder 'DZL' from 'home/$USER/DZL'"
#cd ~
#exec bash
echo "Uninstallation Successful"


