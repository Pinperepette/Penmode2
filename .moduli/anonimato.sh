#!/bin/sh
 
# Destinations you don't want routed through Tor
NON_TOR="192.168.0.0/16 172.16.0.0/12 10.0.0.0/8"
 
# The UID Tor runs as
TOR_UID="debian-tor"
 
# Tor's TransPort
TRANS_PORT="9040"
 
serv=$(cat '/opt/penmode/.moduli/settings/serv.txt') 
########################################################################
 
avvia() {
     
        # Check defaults for Tor
        grep -q -x 'RUN_DAEMON="yes"' /etc/default/tor
        if [ $? -ne 0 ]; then
           echo 'RUN_DAEMON="yes"' >> /etc/default/tor
        fi    
         
        # Check torrc config file
        grep -q -x 'VirtualAddrNetwork 10.192.0.0/10' /etc/tor/torrc
        if [ $? -ne 0 ]; then
            echo 'VirtualAddrNetwork 10.192.0.0/10'>> /etc/tor/torrc
            echo'VirtualAddrNetwork 10.192.0.0/10'>> /etc/tor/torrc
            echo 'AutomapHostsOnResolve 1'>> /etc/tor/torrc
            echo 'TransPort 9040'>> /etc/tor/torrc
            echo 'DNSPort 53' >> /etc/tor/torrc
        fi
 
        echo "Starting anonymous mode"
         
        if [ ! -e /var/run/tor/tor.pid ]; then
            /etc/init.d/tor start
        fi
         
        if ! [ -f /etc/network/iptables.rules ]; then
            iptables-save > /etc/network/iptables.rules
            echo "Saved iptables rules"
        fi
 
        iptables -F
        iptables -t nat -F
        echo "Deleted all iptables rules"
     
        echo -n "Service "
        service resolvconf stop 2>/dev/null || echo "resolvconf already stopped"
 
        cp /etc/resolv.conf /etc/resolv.conf.orig
        echo 'nameserver 127.0.0.1' > /etc/resolv.conf
       
        echo "Modified resolv.conf to use Tor"
 
        iptables -t nat -A OUTPUT -m owner --uid-owner $TOR_UID -j RETURN
        iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 53      
        for NET in $NON_TOR 127.0.0.0/9 127.128.0.0/10; do
            iptables -t nat -A OUTPUT -d $NET -j RETURN
        done
        iptables -t nat -A OUTPUT -p icmp -j REDIRECT --to-ports $TRANS_PORT
        iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports $TRANS_PORT
        iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
        for NET in $NON_TOR 127.0.0.0/8; do
                iptables -A OUTPUT -d $NET -j ACCEPT
        done
        iptables -A OUTPUT -m owner --uid-owner $TOR_UID -j ACCEPT
        iptables -A OUTPUT -j REJECT
        sleep 3
}
 
ferma() {
         
        echo " Stopping anonymous mode"
        cp /etc/resolv.conf.orig /etc/resolv.conf
        rm /etc/resolv.conf.orig
        iptables -F
        iptables -t nat -F
        echo "Deleted all iptables rules"
         
        if [ -f /etc/network/iptables.rules ]; then
            iptables-restore < /etc/network/iptables.rules
            rm /etc/network/iptables.rules
            echo "Restored iptables rules"
        fi
         
        echo -n "Service "
        service resolvconf start 2>/dev/null || echo "resolvconf already started"
         
        echo "Stopped anonymous mode\n"
        sleep 3
 
}
 
########################################################################
 
#______________________________________________________________________#      
case "$1" in
    start)
        avvia
        xdg-open $serv
 
    ;;
#______________________________________________________________________#  
    stop)
        ferma
        xdg-open $serv
 
    ;;
#______________________________________________________________________#      
    restart)
        ferma
        avvia
        xdg-open $serv
 
    ;;
    *)
        echo "Usage: $0 {start|stop|restart}"
        exit 1
    ;;
esac
 
exit 0
