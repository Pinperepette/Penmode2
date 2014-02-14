#!/bin/sh
maschera=$(cat '/opt/penmode/.moduli/settings/dimensione.txt')
case $maschera in 
	1) /opt/penmode/.moduli/penmode2mini ;;
	2) /opt/penmode/.moduli/penmode2 ;;
esac	
