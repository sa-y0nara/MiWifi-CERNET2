#!/bin/sh

auto_minieap="/userdisk/auto_minieap.sh"
minieap="/userdisk/minieap"
minieap_conf="/userdisk/minieap.conf"

authenticate() {
    # Kill running program
    $minieap --kill --conf-file $minieap_conf
    # Call minieap
    $minieap --conf-file $minieap_conf
}

install() {
    # Authenticate.
    authenticate

    # Add script to system autostart
    uci set firewall.auto_minieap=include
    uci set firewall.auto_minieap.type='script'
    uci set firewall.auto_minieap.path="${auto_minieap}"
    uci set firewall.auto_minieap.enabled='1'
    uci set firewall.auto_minieap.reload='1'
    uci commit firewall
    echo -e "\033[32m Authenticate complete. \033[0m"
}

uninstall() {
    # Remove scripts from system autostart
    uci delete firewall.auto_minieap
    uci commit firewall
    echo -e "\033[33m Auto_minieap has been removed. \033[0m"
}

main() {
    [ -z "$1" ] && authenticate && return
    case "$1" in
    install)
        install
        ;;
    uninstall)
        uninstall
        ;;
    *)
        echo -e "\033[31m Unknown parameter: $1 \033[0m"
        return 1
        ;;
    esac
}

main "$@"