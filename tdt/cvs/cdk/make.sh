#!/bin/bash

if [ "$1" == -h ] || [ "$1" == --help ]; then
 echo "Parameter 1: target system (1-3)"
 echo "Parameter 2: kernel (1-4)"
 echo "Parameter 3: debug (Y/N)"
 echo "Parameter 4: Multicom (1-2)"
 echo "Parameter 5: Python (1-2)"
 echo "Parameter 6: External LCD support (1-2)"
 echo "Parameter 7: Image  (1-5)"
 echo "Parameter 8: Media Framework (1-2)" 
 exit
fi

CURDIR=`pwd`
KATIDIR=${CURDIR%/cvs/cdk}
export PATH=/usr/sbin:/sbin:$PATH

CONFIGPARAM=" \
 --prefix=$KATIDIR/tufsbox \
 --with-cvsdir=$KATIDIR/cvs \
 --with-customizationsdir=$KATIDIR/custom \
 --with-archivedir=$HOME/Archive \
 --enable-ccache"

##############################################
echo "			     ___  ______         ______		
                            / _ \ | ___ \        | ___ \	
  ___   _ __    ___  _ __  / /_\ \| |_/ / ______ | |_/ /	
 / _ \ | '_ \  / _ \| '_ \ |  _  ||    / |______||  __/	
| (_) || |_) ||  __/| | | || | | || |\ \         | |	
 \___/ | .__/  \___||_| |_|\_| |_/\_| \_|        \_|	
       | |	
       |_|  "
##############################################

# config.guess generates different answers for some packages
# Ensure that all packages use the same host by explicitly specifying it.

# First obtain the triplet
AM_VER=`automake --version | awk '{print $NF}' | grep -oEm1 "^[0-9]+.[0-9]+"`
host_alias=`/usr/share/automake-${AM_VER}/config.guess`

# Then undo Suse specific modifications, no harm to other distribution
case `echo ${host_alias} | cut -d '-' -f 1` in
  i?86) VENDOR=pc ;;
  *   ) VENDOR=unknown ;;
esac
host_alias=`echo ${host_alias} | sed -e "s/suse/${VENDOR}/"`

# And add it to the config parameters.
CONFIGPARAM="${CONFIGPARAM} --host=${host_alias} --build=${host_alias}"

##############################################

echo "Targets:"
echo " 1) SpiderBox HL-101"
echo " 2) SPARK"
echo " 3) SPARK7162"

case $1 in
	[1-3]) REPLY=$1
	echo -e "\nSelected target: $REPLY\n"
	;;
	*)
	read -p "Select target (1-3)? ";;
esac

case "$REPLY" in
	1) TARGET="--enable-hl101";;
	2) TARGET="--enable-spark";;
	3) TARGET="--enable-spark7162";;
	*) TARGET="--enable-spark";;
esac
CONFIGPARAM="$CONFIGPARAM $TARGET"


##############################################

echo -e "\nKernel:"
echo " Maintained:"
echo "   1) STM 24 P0207"
echo "   2) STM 24 P0209"
echo " Experimental:"
echo "   3) STM 24 P0210 (Recommended)"
echo "   4) STM 24 P0211"
case $2 in
        [1-4]) REPLY=$2
        echo -e "\nSelected kernel: $REPLY\n"
        ;;
        *)
        read -p "Select kernel (1-4)? ";;
esac

case "$REPLY" in
	1) KERNEL="--enable-stm24 --enable-p0207";STMFB="stm24";;
	2) KERNEL="--enable-stm24 --enable-p0209";STMFB="stm24";;
	3) KERNEL="--enable-stm24 --enable-p0210";STMFB="stm24";;
	4) KERNEL="--enable-stm24 --enable-p0211";STMFB="stm24";;
	*) KERNEL="--enable-stm24 --enable-p0210";STMFB="stm24";;
esac
CONFIGPARAM="$CONFIGPARAM $KERNEL"

##############################################
if [ "$3" ]; then
 REPLY="$3"
 echo "Activate debug (y/N)? "
 echo -e "\nSelected option: $REPLY\n"
else
 REPLY=N
 read -p "Activate debug (y/N)? "
fi
[ "$REPLY" == "y" -o "$REPLY" == "Y" ] && CONFIGPARAM="$CONFIGPARAM --enable-debug"

##############################################

echo -e "\nSelect GCC:"
echo "   1) GCC 4.7.3"
echo "   2) GCC 4.8.2"
case $6 in
        [1-2]) REPLY=$6
        echo -e "\nSelected GCC: $REPLY\n"
        ;;
        *)
        read -p "Select GCC (1-2)? ";;
esac

case "$REPLY" in
	1) GCC="";;
	2) GCC="--enable-gcc48";;
	*) GCC="";;
esac

##############################################

cd ../driver/
echo "# Automatically generated config: don't edit" > .config
echo "#" >> .config
echo "export CONFIG_PLAYER_191=y" >> .config
cd - &>/dev/null
PLAYER="--enable-player191"
##############################################

echo -e "\nMulticom:"
echo "   1) Multicom 4.0.6 (testing)"
echo "   2) Multicom 3.2.4 "
case $4 in
        [1-2]) REPLY=$4
        echo -e "\nSelected multicom: $REPLY\n"
        ;;
        *)
        read -p "Select multicom (1-2)? ";;
esac

case "$REPLY" in
	1) MULTICOM="--enable-multicom406"
       cd ../driver/include/
       if [ -L multicom ]; then
          rm multicom
       fi

       ln -s ../multicom-4.0.6/include multicom
       cd - &>/dev/null

       cd ../driver/
       if [ -L multicom ]; then
          rm multicom
       fi

       ln -s multicom-4.0.6 multicom
       echo "export CONFIG_MULTICOM406=y" >> .config
       cd - &>/dev/null
    ;;
	2 ) MULTICOM="--enable-multicom324"
       cd ../driver/include/
       if [ -L multicom ]; then
          rm multicom
       fi

       ln -s ../multicom-3.2.4/include multicom
       cd - &>/dev/null

       cd ../driver/
       if [ -L multicom ]; then
          rm multicom
       fi

       ln -s multicom-3.2.4 multicom
       echo "export CONFIG_MULTICOM324=y" >> .config
       cd - &>/dev/null
    ;;
	*) MULTICOM="--enable-multicom324";;
esac

##############################################
echo -e "\nSelect Python:"
echo "   1) Python 2.6"
echo "   2) Python 2.7"
case $5 in
        [1-2]) REPLY=$5
        echo -e "\nSelected Python: $REPLY\n"
        ;;
        *)
        read -p "Select Python (1-2)? ";;
esac

case "$REPLY" in
	1) PYTHON="--enable-py26";;
	2) PYTHON="--enable-py27";;
	*) PYTHON="";;
esac

##############################################

echo -e "\nExternal LCD support:"
echo "   1) No external LCD"
echo "   2) graphlcd for external LCD"
case $7 in
        [1-2]) REPLY=$7
        echo -e "\nSelected LCD support: $REPLY\n"
        ;;
        *)
        read -p "Select external LCD support (1-2)? ";;
esac

case "$REPLY" in
	1) EXTERNAL_LCD="";;
	2) EXTERNAL_LCD="--enable-externallcd";;
	*) EXTERNAL_LCD="";;
esac

##############################################

echo -e "\nSelect Image (Enigma2-PLI, Neutrino, XBMC, VDR): "
echo "   1) Enigma2PLI"
echo "   2) Neutrino"
echo "   3) XBMC"
echo "   4) VDR"
case $8 in
        [1-4]) REPLY=$8
        echo -e "\nSelected Image: $REPLY\n"
        ;;
        *)
        read -p "Select Image (1-4)? ";;
esac
		if [ "$REPLY" == 1 ]; then
		    echo -e "\nChoose enigma2 OpenPli revision:"
			echo "   0) Newest (Can fail due to outdated patch)"
			echo "   1) Sat, 17 Mar 2012 19:51 - E2 OpenPli 945aeb939308b3652b56bc6c577853369d54a537"
			echo "   2) Sat, 18 May 2012 15:26 - E2 OpenPli 839e96b79600aba73f743fd39628f32bc1628f4c"
			echo "   3) Mon, 20 Aug 2012 16:00 - E2 OpenPli 51a7b9349070830b5c75feddc52e97a1109e381e"
			echo "   4) AR-P - E2 OpenPli non-public branch staging"
			echo "   5) AR-P - E2 OpenPli non-public branch master"
			echo "   6) AR-P - E2 OpenPli branch testing"
			echo "   7) AR-P - E2 OpenPli non-public branch last"
			echo "   8) AR-P - E2 OpenPli branch master"
		    read -p "Select enigma2 OpenPli revision (0-8):"
			
			case "$REPLY" in
			0) IMAGE="--enable-e2pd0";;
			1) IMAGE="--enable-e2pd1";;
			2) IMAGE="--enable-e2pd2";;
			3) IMAGE="--enable-e2pd3";;
			4) IMAGE="--enable-e2pd4";;
			5) IMAGE="--enable-e2pd5";;
			6) IMAGE="--enable-e2pd6";;
			7) IMAGE="--enable-e2pd7";;
			8) IMAGE="--enable-e2pd8";;
			*) IMAGE="--enable-e2pd8";;
			esac
		elif [ "$REPLY" == 2 ]; then
		    echo -e "\nChoose Neutrino revisions:"
			echo "	0) current inactive... comming soon"
			echo "	1) current inactive... comming soon"
			echo "	2) current inactive... comming soon"
		    read -p "Select Neutrino revision (0-2):"
			case "$REPLY" in
			0) IMAGE="--enable-nhd0";;
			1) IMAGE="--enable-nhd1";;
			2) IMAGE="--enable-nhd2";;
			*) IMAGE="--enable-nhd0";;
			esac
		elif [ "$REPLY" == 3 ]; then
		    echo -e "\nChoose XBMC revisions:"
			echo "	0) XBMC 12.2 Frodo"
			echo "	1) Sat, 14 Apr 2012 12:36 - 460e79416c5cb13010456794f36f89d49d25da75"
			echo "	2) Sun, 10 Jun 2012 13:53 - 327710767d2257dad27e3885effba1d49d4557f0"
		    read -p "Select XBMC revision (0-2):"
			case "$REPLY" in
			0) IMAGE="--enable-xbd0" GFW="--enable-graphicfwdirectfb" MEDIAFW="--enable-mediafwgstreamer";;
			1) IMAGE="--enable-xbd1" GFW="--enable-graphicfwdirectfb" MEDIAFW="--enable-mediafwgstreamer";;
			2) IMAGE="--enable-xbd2" GFW="--enable-graphicfwdirectfb" MEDIAFW="--enable-mediafwgstreamer";;
			*) IMAGE="--enable-xbd0" GFW="--enable-graphicfwdirectfb" MEDIAFW="--enable-mediafwgstreamer";;
			esac
		elif  [ "$REPLY" == 4 ]; then
		    echo -e "\nChoose VDR revisions"
			echo "   1) VDR-1.7.22"
			echo "   2) VDR-1.7.27"
		    read -p "Select VDR-1.7.XX (1-2)? "
			case "$REPLY" in
			1) IMAGE="--enable-vdr1722"
			    cd ../apps/vdr/
			if [ -L vdr ]; then
			    rm vdr
			fi
			    ln -s vdr-1.7.22 vdr
			cd - &>/dev/null
			;;
			2) IMAGE="--enable-vdr1727"
			    cd ../apps/vdr/
			if [ -L vdr ]; then
			    rm vdr
			fi
			    ln -s vdr-1.7.27 vdr
			cd - &>/dev/null
			;;
			*) IMAGE="--enable-vdr1722";;
			esac
		fi

##############################################

if [[ "$IMAGE" == --enable-e2* ]]; then
  echo -e "\nMedia Framework:"
  echo "   1) eplayer3 "
  echo "   2) gstreamer "
  case $6 in
	  [1-2]) REPLY=$6
	  echo -e "\nSelected media framwork: $REPLY\n"
	  ;;
	  *)
	  read -p "Select media framwork (1-2)? ";;
  esac

  case "$REPLY" in
	1) MEDIAFW="--enable-eplayer3";;
	2) MEDIAFW="--enable-mediafwgstreamer";;
	*) MEDIAFW="";;
  esac
fi
##############################################

CONFIGPARAM="$CONFIGPARAM $PLAYER $MULTICOM $PYTHON $MEDIAFW  $EXTERNAL_LCD $IMAGE $GFW $GCC"

##############################################

# configure still want's this
# ignore errors here
automake --add-missing

echo && \
echo "Performing autogen.sh..." && \
echo "------------------------" && \
./autogen.sh && \
echo && \
echo "Performing configure..." && \
echo "-----------------------" && \
echo && \
./configure $CONFIGPARAM

#Dagobert: I find it sometimes useful to know
#what I have build last in this directory ;)
echo $CONFIGPARAM >lastChoice

echo "-----------------------"
echo "Your build enivroment is ready :-)"
echo "Your next step could be:"
case "$IMAGE" in
        --enable-e2pd*)
        echo "make yaud-enigma2-pli-nightly"
        echo "make yaud-enigma2-pli-nightly-full";;
        --enable-nhd*)
        echo "make yaud-neutrino-hd-nightly";;
        --enable-xbd*)
        echo "make yaud-xbmc-nightly";;
        --enable-vdr*)
        echo "make yaud-vdr";;
        *)
        echo "Run ./make.sh again an select Image!";;
esac   
echo "-----------------------"
