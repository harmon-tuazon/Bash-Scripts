#!/bin/bash


# Function to get filtered ARP table entries
get_arp_ips() {
   ip_array=()
   
   for ip in $(powershell.exe arp -a | awk '{print $1}' | grep "192.168.77."); do
   	ip_array+=("$ip")
   done
}

# Function to ping a single host
ping_host() {
    local host=$1

    if ping -c 1 -W 1 "$host" > /dev/null 2>&1; then
        echo "Online"
    else
        echo "Offline"
    fi
}

# Main function
main() {
    get_arp_ips

    printf "%-20s%s\n" "IP Address" "Status"
    echo "------------------------------"

    for ip in "${ip_array[@]}"; do
        status=$(ping_host "$ip")
        printf "%-20s%s\n" "$ip" "$status"
    done
}

main

