#!/bin/bash
cd /opt/penmode/.moduli/Keep/
cat keep-dead.php > set-keep-dead.php
sed "s/127.0.0.1:8080/$targetip:80/g" keep-dead.php > set-keep-dead.php
sed "s/pinperepette1/$requests/g" set-keep-dead.php > 1-set-keep-dead.php

sed "s/pinperepette2/$max/g" 1-set-keep-dead.php > 2-set-keep-dead.php
rm set-keep-dead.php
sed "s/pinperepette3/$delay/g" 2-set-keep-dead.php > 3-set-keep-dead.php
rm 1-set-keep-dead.php
sed "s/pinperepette4/$brequests/g" 3-set-keep-dead.php > 4-set-keep-dead.php
rm 2-set-keep-dead.php
sed "s/pinperepette5/$skip/g" 4-set-keep-dead.php > set-keep-dead.php
rm 3-set-keep-dead.php
rm 4-set-keep-dead.php


xterm -geometry 100x90 -hold -e php ./set-keep-dead.php
