#!/usr/bin/env bash


# Get & set Current Directory as a Variable:
pwd=$(pwd list)


### DZL Installer ### 
echo "Copying 'DZL Folder' to /home/$USER/"
cp -R /$pwd/DZL/ /home/$USER/
echo ""
echo ""
echo "Installing Dependencies:"


### Install Dependencies: ###
echo ""
sudo pacman -S gawk -y
echo ""
echo ""
sudo pacman -S curl -y
echo ""
echo ""
sudo pacman -S jq -y
echo ""
echo ""


### Give user ownership to .png icon ###
echo "Taking Ownership of the DZL Folder Contents."
sudo chmod +x /home/$USER/DZL/./*
sudo chmod +x /home/$USER/DZL/./*
echo ""
echo ""


### Copy DZL.desktop file to your application Directory ###
cp /home/$USER/DZL/DZL.desktop /home/$USER/.local/share/applications/DZL.desktop &
echo "DZL.desktop was copied to '/home/$USER/.local/share/applications/' and should be available in the application menu."
echo ""
echo ""


### Copy dzl.png file to /usr/share/icons ###
sudo cp /home/$USER/DZL/dzl.png /usr/share/icons/
echo "Application Icon copied to 'usr/share/icons'"
echo ""
echo ""
echo ""
echo ""
echo "All Done! Launch DZL by Using the Application Menu Entry or through Terminal: bash /home/$USER/DZL/DZL.sh"
