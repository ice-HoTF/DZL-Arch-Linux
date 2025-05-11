# A Konsole-based DayZ Mod Launcher For Linux!
\
 **Beta released 16/02/2025**
\
\
By: ice_hotf
\
\
Supported Distros:
\
Tested with Debian 12. 
\
\
Other Distros:
\
The steam path "/home/$USER/.steam/debian-installation/steamapps/" might need to be changed for other distros. 
\
Replace it with yours.
\
\
\
**FLATPAK STEAM NOT SUPPORTED!**
\
This script only works with the official steam package: https://wiki.debian.org/Steam
\
\
**Dependencies:**
\
gawk
\
curl
\
jq
\
\
\
\
**About This Script:**
\
\
   This script will identify missing mods, download them and launch DayZ with the mods. 
   This script will also allow you to delete mods and save Favorite Servers.
   Just follow the instructions in the terminal window and that's it.
\
\
   This script supports modded servers and vanilla servers.
\
\
\
\
**How To:**
\
\
1: Extract <DZL-Beta-Linux-main.zip> and Open Terminal in the 'DZL-Beta-Linux-main' Folder.
\
\
2: Install DZL by running <install_DZL.sh> in the Terminal:
\
   sh install_DZL.sh
\
\
3: Start DZL by Opening the Application Menu Shortcut <DZL> 
\
or Start DZL with a Terminal Command: 
\
bash /home/$USER/DZL/DZL.sh
\
\
\
**Video: How To Setup and Launch DZL:**
https://www.youtube.com/watch?v=bssSaxZ6hS4
\
\
\
\
**Join Server:**
\
\
![join_server_1](https://github.com/user-attachments/assets/6ec5261a-aed7-4f57-ad87-721ffee2bd58)
\
\
**Add Favorite:**
\
\
![add_favorite](https://github.com/user-attachments/assets/bda435ef-ce73-4eac-9d0e-c721d347d628)
\
\
**Join Favorite:**
\
\
![join_favorite](https://github.com/user-attachments/assets/419abb14-c5ad-4e40-92d9-0454825296f9)
\
\
**Remove Favorite:**
\
\
![remove_favorite](https://github.com/user-attachments/assets/30ff3c24-fd89-4919-a65e-d58349de3783)
\
\
**Remove From Specific Server:**
\
\
![remode_mods_this_server](https://github.com/user-attachments/assets/46a232fd-ed2b-4123-9df6-413d5135fd88)
\
\
**Remove All Mods:**
\
\
![remove_all_mods](https://github.com/user-attachments/assets/54d2fa7f-20fa-495e-9d99-3ac86cbec6f2)
\
\
\
\
![dzl](https://github.com/user-attachments/assets/24a04856-76ee-494d-a0a3-9f7116fb1f3e)
\
\
**Add DZL as a Application Entry and Open it as an Application** 
\
This is automatically done through the <install_DZL.sh> script, but this is how you do it manually:
\
\
1: Copy <DZL.desktop> to /home/$USER/.local/share/applications/ and in the Terminal:
\
cp /home/$USER/DZL-Beta-Linux-main/DZL.desktop /home/$USER/.local/share/applications/DZL.desktop
\
\
2: Copy the .png-icon to the </usr/share/icons> folder in the Terminal:
\
sudo cp /home/$USER/DZL-Beta-Linux-main/DZL/dzl.png /usr/share/icons/
\
\
\
\
**FAQ:**
\
\
I can't join the server:
- Restart Steam if you can't join the server and try again.
- On heavily modded servers, steam once in a while glitches right after downloading the mods and. A steam restart solves it.
