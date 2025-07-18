#!/usr/bin/env bash
echo ""
echo "Searching for Servers.. Please Wait!"
echo ""
#####################################################################################################################################
### DZL ###
#####################################################################################################################################


startmenu() {

# Temporarily changing max.map_count or else the game wont lauch at all.. (Will reset to default after the next reboot)
echo ""
echo "Map Count Setting:"
sudo sysctl -w vm.max_map_count=1048576
echo ""
# To make it persistent: Run 'sudo su' in the Terminal and then run: echo "vm.max_map_count=1048576" >> /etc/sysctl.conf

unset number
until [[ $number == +([1-4]) ]] ; do

read -s -n1 -p $'
 Select:\n
 1) Setup Server\n
 2) Favorites\n
 3) Options Favorites And Mods\n
 4) Quit
\n' number
done
case ${number} in

######################################################
#### Normal Mod Setup Start ##########################
######################################################

[1] )

echo ""
echo -e "\n
 Server Info can be found at: https://www.battlemetrics.com/servers/dayz/"
sleep 0.5
echo ""

echo -e "\n
 Enter IP-Address:Port"
sleep 0.5
read SSERVER
sleep 0.5

echo -e "\n
 Enter Query Port Number"
sleep 0.5
read PPORT
sleep 0.5

echo -e "\n
 Enter Username"
sleep 0.5
read NNAME
sleep 0.5;;


######################################################
#### Normal Mod Setup End ############################
######################################################



######################################################
#### Menu Options Start      #########################
######################################################

[2] )

dir="/home/$USER/DZL/Favorites/"
list=$(ls "$dir")

if [[ -z "$list" ]]; then
    echo ""
    echo "No Favorites Added!"
    echo ""
    exit
fi

echo "Select By Number:"
select file in $list
do
    if [ -n "$file" ]; then
        echo "Launching: $file"
        sh /home/$USER/DZL/Favorites/$file
        break
    else
        echo "Invalid selection"
        exit
    fi
done
exit
echo ""

startmenu "${dir_dayz}" "${dir_workshop}" || exit 1;;


[3] )
submenur1
sleep 0.1;;

[4] )
exit;;

esac
}

submenur1(){
unset number
until [[ $number == +([1-3]) ]] ; do
read -s -n1 -p $'
\n
 1) Remove A Server From Favorites\n
 2) Remove All Mods\n
 3) Exit\n
\n' number
done

#echo ""
case $number in

"1") ######################################################################################

rdir="/home/$USER/DZL/Favorites/"
rlist=$(ls "$rdir")
if [[ -z "$rlist" ]]; then
    echo ""
    echo "No Favorites Added!"
    echo ""
    exit

fi

echo "Select By Number To Delete:"
select rfile in $rlist
do
    if [ -n "$rfile" ]; then
        echo "You deleted: $rfile"
        rm /home/$USER/DZL/Favorites/$rfile
        exit
    else
        echo "Invalid selection"
        exit
    fi
done
exit
echo ""

startmenu "${dir_dayz}" "${dir_workshop}" || exit 1;;

"2") ######################################################################################

read -p $'\n
 Press Enter to Delete All DayZ Mods.' foo

      	    rm -rf /home/$USER/.steam/steam/steamapps/workshop/content/221100/*
     	    sleep 0.1
            rm -rf /home/$USER/.steam/steam/steamapps/workshop/downloads/*
            sleep 0.1
     	    rm -r -f /home/$USER/.steam/steam/steamapps/common/DayZ/@*

exit 1;;

"3") ######################################################################################

    exit;;
esac

}


######################################################
#### Menu Options Stop       #########################
######################################################


set -eo pipefail

SELF=$(basename "$(readlink -f "${0}")")

DAYZ_ID=221100

DEFAULT_GAMEPORT=2302
DEFAULT_QUERYPORT=27016

API_URL="https://dayzsalauncher.com/api/v1/query/@ADDRESS@/@PPORT@"
API_PARAMS=(
  -sSL
  -m 10
  -H "User-Agent: $USER"
)
WORKSHOP_URL="https://steamcommunity.com/sharedfiles/filedetails/SubscribeItem/?id=@ID@"

SSERVER=""
PPORT="${DEFAULT_QUERYPORT}"
DEBUG=0
LAUNCH=0
STEAM=""
SERVER=""
PORT="${DEFAULT_QUERYPORT}"
NAME=""
NNAME=""
INPUT=()
MODS=()
MODS2=()
PARAMS=()
IP=()
PORT=()

declare -A DEPS=(

  [gawk]="required for mod metadata. Try: sudo apt install gawk"
  [curl]="required for the server API. Try: sudo apt install curl"
  [jq]="required for the server API's JSON response. Try: sudo apt install jq"
)

while (( "$#" )); do
  case "${1}" in
    -h|--help)
      print_help
      exit
      ;;
    -d|--debug)
      DEBUG=1
      ;;
    --steam)
      STEAM="${2}"
      shift
      ;;
    -l|--launch)
      LAUNCH=1
      ;;
    -s|--server)
      SERVER="${2}"
      [[ "${SERVER}" = *:* ]] || SERVER="${SERVER}:${DEFAULT_GAMEPORT}"
      shift
      ;;
    -p|--port)
      PORT="${2}"
      shift
      ;;
    -n|--name)
      NAME="${2}"
      shift
      ;;
    --)
      shift
      PARAMS+=("${@}")
      LAUNCH=1
      break
      ;;
    *)
      INPUT+=("${1}")
      ;;
  esac
  shift
done

err() {
echo -e >&2 "[${SELF}][error] ${@}"

exit 1
}

msg() {

echo "[${SELF}][info] ${@}"
}

debug() {
if [[ ${DEBUG} == 1 ]]; then
echo "[${SELF}][debug] ${@}"
  fi
}

#check_dir() {

#debug "Checking directory: ${1}"
#if [ ! -d "${1}" ] ; then
#mkdir "/home/$USER/.steam/steam/steamapps/workshop/content/221100"
#fi
#}

check_dir() {
  debug "Checking system-wide for directory: ${1}"

  # search for an existing dir matching $1 anywhere
  if find / -type d -path "${1}" -print -quit 2>/dev/null >/dev/null; then
    debug "Directory found system-wide, skipping creation"
    return 0
  fi

  # not found → create it (with parents)
  mkdir -p "${1}" || {
    echo "Error: could not create ${1}" >&2
    return 1
  }
}

check_dep() {
  command -v "${1}" >/dev/null 2>&1
}

check_deps() {
  for dep in "${!DEPS[@]}"; do
    check_dep "${dep}" || err "'${dep}' not installed (${DEPS["${dep}"]})"
done
}

dec2base64() {
  echo "$1" \
    | LC_ALL=C gawk '
      {
        do {
          printf "%c", and($1, 255)
          $1 = rshift($1, 8)
        } while ($1 > 0)
      }
    ' \
    | base64 \
    | sed 's|/|-|g; s|+|_|g; s|=||g'
}

resolve_steam() {
    if [[ -n "${STEAM}" ]]; then
    check_dep "${STEAM}" || err "Could not find the '${STEAM}' executable"
    fi

    if check_dep steam; then
    STEAM=steam
    fi
}

query_server_api() {

  [[ -z "${SSERVER}" ]] && return

  local query
  local response
  echo ""
  echo -e "\n
 Server IP   : $SSERVER
 Query Port  : $PPORT
 UserName    : $NNAME"

  query="$(sed -e "s/@ADDRESS@/${SSERVER%:*}/" -e "s/@PPORT@/${PPORT}/" <<< "${API_URL}")"
  debug "Querying ${query}"
  response="$(curl "${API_PARAMS[@]}" "${query}")"
  debug "Parsing API response"
  jq -e '.result.mods | select(type == "array")' >/dev/null 2>&1 <<< "${response}" || err " Missing data from API response. Try again in a few seconds"
  jq -e '.result.mods[]' >/dev/null 2>&1 <<< "${response}" || { echo ""; echo ""; echo -e " This is a Vanilla Server.";}

  INPUT+=( $(jq -r ".result.mods[] | .steamWorkshopId" <<< "${response}") )
}

mainmenu(){

sleep 0.25
if [ -f "/home/$USER/.steam/steam/steamapps/workshop/appworkshop_221100.acf" ] ; then
rm /home/$USER/.steam/steam/steamapps/workshop/appworkshop_221100.acf
fi
sleep 0.25
if [ -f "/home/$USER/.steam/steam/steamapps/workshop/appworkshop_241100.acf" ] ; then
rm /home/$USER/.steam/steam/steamapps/workshop/appworkshop_241100.acf
fi
sleep 0.25

missing=0

unset number
until [[ $number == +([1-5]) ]] ; do
read -s -n1 -p $'
\n
 1) Join Server\n
 2) Add To Favorites\n
 3) Edit Server Mods (For This Server Only)\n
 4) Quit
\n' number
done
case $number in
    [1])
	    echo ""
	    echo -e "\n
 Checking Server Mods .."
            sleep 0.25
            rm -rf /home/$USER/.steam/steam/steamapps/workshop/content/downloads/*
            rm -r -f /home/$USER/.steam/steam/steamapps/common/DayZ/@*
            sleep 0.1;;
    [2])
    submenu2
    ;;
    [3])
    submenu1
    ;;
    [4])
    exit
    ;;
        *)
        echo "invalid answer, please try again"
        ;;

esac

}

submenu1(){
unset number
until [[ $number == +([1-4]) ]] ; do
read -s -n1 -p $'
\n
 1) Verify Mods\n
 2) Remove Mods Used By This Server\n
 3) Back\n
\n' number
done

#echo ""
case $number in

"1") ######################################################################################

read -p $'\n
 Press Enter to Verify Mods for this Server.
\n' foo
            sleep 0.25
            for modid in "${INPUT[@]}"; do
	    rm -rf /home/$USER/.steam/steam/steamapps/workshop/content/221100/${modid}
	    rm -r -f /home/$USER/.steam/steam/steamapps/common/DayZ/@*
	    continue
	   done
            sleep 0.1
            rm -rf /home/$USER/.steam/steam/steamapps/workshop/content/downloads/*
            sleep 0.1
            rm -r -f /home/$USER/.steam/steam/steamapps/common/DayZ/@*
            sleep 0.1
            if [ -f "/home/$USER/.steam/steam/steamapps/workshop/appworkshop_221100.acf" ] ; then
            rm /home/$USER/.steam/steam/steamapps/workshop/appworkshop_221100.acf
            fi
sleep 0.1;;

"2") ######################################################################################

   unset mods2
   for modid in "${INPUT[@]}"; do

    local modpath2="${dir_workshop}/${modid}"
    local namelink="${modid}"
    MODS2+=("${namelink}")
    local mods2="$(IFS=";" echo "${MODS2[*]}")"
done

read -p $'\n
 Press Enter to Delete Mods Used By This Server.
\n' foo
echo -e "\n
 Mods Deleted:\n ${mods2}\n From Workshop Directory: \n ${dir_workshop}"
            sleep 0.1
	    for modid in "${INPUT[@]}"; do
	    rm -rf /home/$USER/.steam/steam/steamapps/workshop/content/221100/${modid}
	    continue
	    done
            rm -rf /home/$USER/.steam/steam/steamapps/workshop/downloads/*
            sleep 0.1
	    rm -r -f /home/$USER/.steam/steam/steamapps/common/DayZ/@*
            if [ -f "/home/$USER/.steam/steam/steamapps/workshop/appworkshop_221100.acf" ] ; then
            rm /home/$USER/.steam/steam/steamapps/workshop/appworkshop_221100.acf
            fi
#exit;;

mainmenu "${dir_dayz}" "${dir_workshop}" || exit 1;;

"3") ######################################################################################

    mainmenu
    ;;

esac

}

submenu2(){

    ppath=/home/$USER/DZL/Favorites/
    echo -e "\n
 Save Favorite As:
 ";
    read fname;
    echo ""
    unset MODS
for modid in "${INPUT[@]}"; do
    local modlink="@$(dec2base64 "${modid}")"
    local modpath="${dir_workshop}/${modid}"
    local modmeta="${modpath}/meta.cpp"
    MODS+=("${modlink}")
    local mods="$(IFS=";"; echo "${MODS[*]}")"
    local modlink="@$(dec2base64 "${modid}")"
    sleep 0.2
done

    cat > $ppath$fname.sh << ENDMASTER
steam -applaunch 221100 "-mod=$mods" -connect=${SSERVER} --port ${PPORT} -name=${NNAME} -nolauncher -world=empty
ENDMASTER
    echo -e "\n
 Launch Script Saved In:$ppath$fname.sh";
   echo "";
   echo " This Server Was Added To Favorites";
echo -e "\n
 Launch command for this server: \n\n steam -applaunch 221100 \"-mod=$mods\" -connect=$SSERVER --port ${PPORT} -name=${NNAME} -nolauncher -world=empty"
echo ""
echo "";
mainmenu;
}

mods_setup() {

    local dir_dayz="${1}"
    local dir_workshop="${2}"
    unset MODS

for modid in "${INPUT[@]}"; do

    local modlink="@$(dec2base64 "${modid}")"
    local modpath="${dir_workshop}/${modid}"

if ! [[ -d "${modpath}" ]]; then

    missing=1
    echo -e "\n
 MOD MISSING: ${modid}: $(sed -e"s/@ID@/${modid}/" <<< "${WORKSHOP_URL}")
 DOWNLOADING MOD: ${modid}...
  ";
    echo ""
    steam steam+workshop_download_item 221100 ${modid} && wait

  continue
fi

done

if (( missing == 1 )); then

   echo -e "\n
 Please Wait While Steam Download The Mods."
   sleep 10
   until [ ! -d "/home/$USER/.steam/steam/steamapps/workshop/temp/221100" ] && sleep 5 && [ ! -d "/home/$USER/.steam/steam/steamapps/workshop/temp/221100" ];
   do
   echo -e "\n
 ..Downloading Mods. Please wait.."
   sleep 10
   done
echo ""
   echo -e "\n
 Mods Finished Downloading."
fi
    echo ""
    missing=0
    unset MODS
    for modid in "${INPUT[@]}"; do
    local modlink="@$(dec2base64 "${modid}")"
    local modpath="${dir_workshop}/${modid}"
    local modmeta="${modpath}/meta.cpp"
    ln -sr -f "${modpath}" "${dir_dayz}/${modlink}"
    MODS+=("${modlink}")
    local mods="$(IFS=";"; echo "${MODS[*]}")"
    local modlink="@$(dec2base64 "${modid}")"
  continue

    done

    echo -e "\n
 Name: $NNAME
 Game IP:Port $SSERVER
 Query Port: $PPORT"
    echo ""

   echo -e "\n
 Launch command for this server: \n\n steam -applaunch 221100 \"-mod=$mods\" -connect=$SSERVER --port ${PPORT} -name=${NNAME} -nolauncher -world=empty"
echo ""

read -p $'\n
 Press " Enter " to Launch DayZ And Join The Server
\n' foo

echo -e "\n
 Starting DayZ.. Please Wait..
\n";

steam -applaunch 221100 "-mod=$mods" -connect=${SSERVER} --port ${PPORT} -name=${NNAME} -nolauncher -world=empty

echo ""
exit
}


add_to_favorites() {
while true; do
read -p "Add server to Favorites? (y/n) " yn
case $yn in
    [Yy]* )
         submenu2;;
    [Nn]* )

	 launch_game;;


    * ) echo "invalid response";;

esac
done
echo ""
}

launch_game() {
read -p $'\n
 Press " Enter " to Launch DayZ And Join The Server
\n' foo

echo -e "\n
 Starting DayZ.. Please Wait..
\n";
steam -applaunch 221100 "-mod=$mods" -connect=${SSERVER} --port ${PPORT} -name=${NNAME} -nolauncher -world=empty
exit;
}


main() {
  check_deps
  resolve_steam

  if [[ -z "${STEAM_ROOT}" ]]; then
  STEAM_ROOT="${XDG_DATA_HOME:-${HOME}/.steam}/steam"
  fi
  STEAM_ROOT="${STEAM_ROOT}/steamapps"
  local dir_dayz="${STEAM_ROOT}/common/DayZ"
  local dir_workshop="${STEAM_ROOT}/workshop/content/${DAYZ_ID}"
  check_dir "${dir_dayz}"
  check_dir "${dir_workshop}"
  startmenu "${dir_dayz}" "${dir_workshop}" || exit 1
  query_server_api
  mainmenu "${dir_dayz}" "${dir_workshop}" || exit 1
  mods_setup "${dir_dayz}" "${dir_workshop}" || exit 1
  local mods="$(IFS=";"; echo "${MODS[*]}")"
  local mods2="$(IFS=";"; echo "${MODS2[*]}")"

}

main
