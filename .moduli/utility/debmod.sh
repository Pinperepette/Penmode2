#!/bin/bash

#  Script creato da TheZero
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
 
build(){
	cd "$ARCHIVE_FULLPATH"
    find . -type f ! -regex '.*\.hg.*' ! -regex '.*?debian-binary.*' ! -regex '.*?DEBIAN.*' -printf '%P ' | xargs md5sum > DEBIAN/md5sums
    cd ..
    if [ "$VERBOSE" == "" ]; then
		cmd=`dpkg-deb -b "$ARCHIVE_FULLPATH"`
	else
		dpkg-deb -b "$ARCHIVE_FULLPATH"
    fi
    if [ "$KEEP" == "n" ]; then
		rm -f$VERBOSE -R "$ARCHIVE_FULLPATH"
    fi
}


extract(){
	if [[ -e "$NEWDIRNAME" ]]; then
		if [ "$KEEP" == "n" ]; then
			rm -f$VERBOSE -R "$NEWDIRNAME"
			mkdir "$NEWDIRNAME"
		fi
	else
	    mkdir "$NEWDIRNAME"
	fi
    cp -f$VERBOSE -R "$ARCHIVE_FULLPATH" "$NEWDIRNAME"
    cd "$NEWDIRNAME"
    ar ${VERBOSE}x "$FILENAME"
	rm -f$VERBOSE -R "$FILENAME"
    for FILE in *.tar.gz; do [[ -e $FILE ]] && tar x${VERBOSE}pf $FILE; done
    for FILE in *.tar.lzma; do [[ -e $FILE ]] && tar x${VERBOSE}pf $FILE; done
    [[ -e "control.tar.gz" ]] && rm -f$VERBOSE -R "control.tar.gz"
    [[ -e "data.tar.gz" ]] && rm -f$VERBOSE -R "data.tar.gz"
    [[ -e "data.tar.lzma" ]] && rm -f$VERBOSE -R "data.tar.lzma"
    [[ -e "debian-binary" ]] && rm -f$VERBOSE -R "debian-binary"

    if [[ -e "DEBIAN" ]]; then
		if [ "$KEEP" == "n" ]; then
			rm -f$VERBOSE -R "DEBIAN"
			mkdir "DEBIAN"
		fi
	else
	    mkdir "DEBIAN"
	fi
    [[ -e "changelog" ]] && mv -f$VERBOSE "changelog" "DEBIAN"
    [[ -e "config" ]] && mv -f$VERBOSE "config" "DEBIAN"
    [[ -e "conffiles" ]] && mv -f$VERBOSE "conffiles" "DEBIAN"
    [[ -e "control" ]] && mv -f$VERBOSE "control" "DEBIAN"
    [[ -e "copyright" ]] && mv -f$VERBOSE "copyright" "DEBIAN"
    [[ -e "postinst" ]] && mv -f$VERBOSE "postinst" "DEBIAN"
    [[ -e "preinst" ]] && mv -f$VERBOSE "preinst" "DEBIAN"
    [[ -e "prerm" ]] && mv -f$VERBOSE "prerm" "DEBIAN"
    [[ -e "postrm" ]] && mv -f$VERBOSE "postrm" "DEBIAN"
    [[ -e "rules" ]] && mv -f$VERBOSE "rules" "DEBIAN"
    [[ -e "shlibs" ]] && mv -f$VERBOSE "shlibs" "DEBIAN"
    [[ -e "templates" ]] && mv -f$VERBOSE "templates" "DEBIAN"
    [[ -e "triggers" ]] && mv -f$VERBOSE "triggers" "DEBIAN"
    [[ -e ".svn" ]] && mv -f$VERBOSE ".svn" "DEBIAN"

    [[ -e "md5sums" ]] && rm -f$VERBOSE -R "md5sums"
}


# Program Main #
KEEP="n"
VERBOSE=""
ACTION="n"

while getopts ":b:x:kv" opt; do
  case $opt in
    b)
      ACTION="b"
      ARCHIVE_FULLPATH="$2"
	  NEWDIRNAME=${ARCHIVE_FULLPATH%.*}
      ;;
    x)
      ACTION="x"
      ARCHIVE_FULLPATH="$2"
	  NEWDIRNAME=${ARCHIVE_FULLPATH%.*}
	  FILENAME=${ARCHIVE_FULLPATH##*/}
      ;;
    k)
      KEEP="y"
      ;;
    v)
      VERBOSE="v"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

if [ $ACTION == "b" ]; then
	build
elif [ $ACTION == "x" ]; then
	extract
elif [ $ACTION == "n" ]; then
	echo -e "Usage: \n\t-b [file_path]\t-> Build DEB\n\t-x [dir_path]\t-> Extract DEB \n\t-k\t\t-> Keep File\n\t-v\t\t-> Verbose"
	exit 1
fi

exit 0
