#!/bin/bash
#
# Copyright (C) 2018 smallmuou <smallmuou@163.com>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is furnished
# to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

set -e

spushd() {
     pushd "$1" 2>&1> /dev/null
}

spopd() {
     popd 2>&1> /dev/null
}

info() {
     local green="\033[1;32m"
     local normal="\033[0m"
     echo -e "[${green}INFO${normal}] $1"
}

cmdcheck() {
    command -v $1>/dev/null 2>&1 || { error >&2 "Please install command $1 first."; exit 1; }
}

error() {
     local red="\033[1;31m"
     local normal="\033[0m"
     echo -e "[${red}ERROR${normal}] $1"
}

warn() {
     local yellow="\033[1;33m"
     local normal="\033[0m"
     echo -e "[${yellow}WARNING${normal}] $1"
}

yesno() {
    while true;do
    read -p "$1 (y/n)" yn
    case $yn in
        [Yy]) $2;break;;
        [Nn]) exit;;
        *) echo 'please enter y or n.'
    esac
done
}

curdir() {
    if [ ${0:0:1} = '/' ] || [ ${0:0:1} = '~' ]; then
        echo "$(dirname $0)"
    elif [ -L $0 ];then
        name=`readlink $0`
        echo $(dirname $name)
    else
        echo "`pwd`/$(dirname $0)"
    fi
}

myos() {
    echo `uname|tr "[:upper:]" "[:lower:]"`
}

#########################################
###           GROBLE DEFINE           ###
#########################################

VERSION=2.0.0
AUTHOR=smallmuou

#########################################
###             ARG PARSER            ###
#########################################

usage() {
prog=`basename $0`
cat << EOF
$prog version $VERSION by $AUTHOR

USAGE: $prog [OPTIONS] srcfile srcfilev srcfileh dstpath

DESCRIPTION:
    This script aim to generate iOS/macOS/watchOS APP icons more easier and simply.

    srcfile - The source png image. Preferably above 1024x1024
    srcfilev - The source png image. Preferably in portrait or vertical
    srcfileh - The source png image. Preferably in landscape or horizontal
    dstpath - The destination path where the icons generate to.

OPTIONS:
    -h      Show this help message and exit

EXAMPLES:
    $prog 1024.png ~/123

EOF
exit 1
}

while getopts 'h' arg; do
    case $arg in
        h)
            usage
            ;;
        ?)
            # OPTARG
            usage
            ;;
    esac
done

shift $(($OPTIND - 1))

[ $# -ne 4 ] && usage

#########################################
###            MAIN ENTRY             ###
#########################################

cmdcheck sips
src_file=$1
src_file_v=$2
src_file_h=$3
dst_path=$4

# check source file
[ ! -f "$src_file" ] && { error "The source file $src_file does not exist, please check it."; exit -1; }
[ ! -f "$src_file_v" ] && { error "The source file $src_file_v does not exist, please check it."; exit -1; }
[ ! -f "$src_file_h" ] && { error "The source file $src_file_h does not exist, please check it."; exit -1; }

# check width and height
src_width=`sips -g pixelWidth $src_file 2>/dev/null|awk '/pixelWidth:/{print $NF}'`
src_height=`sips -g pixelHeight $src_file 2>/dev/null|awk '/pixelHeight:/{print $NF}'`

src_width_v=`sips -g pixelWidth $src_file_v 2>/dev/null|awk '/pixelWidth:/{print $NF}'`
src_height_v=`sips -g pixelHeight $src_file_v 2>/dev/null|awk '/pixelHeight:/{print $NF}'`

src_width_h=`sips -g pixelWidth $src_file_h 2>/dev/null|awk '/pixelWidth:/{print $NF}'`
src_height_h=`sips -g pixelHeight $src_file_h 2>/dev/null|awk '/pixelHeight:/{print $NF}'`

[ -z "$src_width" ] &&  { error "The source file $src_file is not a image file, please check it."; exit -1; }

[ -z "$src_width_v" ] &&  { error "The source file $src_file_v is not a image file, please check it."; exit -1; }

[ -z "$src_width_h" ] &&  { error "The source file $src_file_h is not a image file, please check it."; exit -1; }

if [ $src_width -ne $src_height ];then
    warn "The height and width of the source image are different, will cause image deformation."
fi

# create dst directory
[ ! -d "$dst_path" ] && mkdir -p "$dst_path"

# ios sizes refer to https://developer.apple.com/design/human-interface-guidelines/ios/icons-and-images/app-icon/
# macos sizes refer to https://developer.apple.com/design/human-interface-guidelines/macos/icons-and-images/app-icon/
# watchos sizes refer to https://developer.apple.com/design/human-interface-guidelines/watchos/icons-and-images/home-screen-icons/
#
#
# name size (width height)
sizes_mapper=`cat << EOF
AppIcon.appiconset/Icon-20                             20      20
AppIcon.appiconset/Icon-29                             29      29
AppIcon.appiconset/Icon-32                             32      32
AppIcon.appiconset/Icon-40                             40      40
AppIcon.appiconset/Icon-48                             48      48
AppIcon.appiconset/Icon-55                             55      55
AppIcon.appiconset/Icon-58                             58      58
AppIcon.appiconset/Icon-60                             60      60
AppIcon.appiconset/Icon-64                             64      64
AppIcon.appiconset/Icon-76                             76      76
AppIcon.appiconset/Icon-80                             80      80
AppIcon.appiconset/Icon-87                             87      87
AppIcon.appiconset/Icon-88                             88      88
AppIcon.appiconset/Icon-100                            100     100
AppIcon.appiconset/Icon-120                            120     120
AppIcon.appiconset/Icon-128                            128     128
AppIcon.appiconset/Icon-152                            152     152
AppIcon.appiconset/Icon-167                            167     167
AppIcon.appiconset/Icon-172                            172     172
AppIcon.appiconset/Icon-180                            180     180
AppIcon.appiconset/Icon-196                            196     196
AppIcon.appiconset/Icon-216                            216     216
AppIcon.appiconset/Icon-256                            256     256
AppIcon.appiconset/Icon-512                            512     512
AppIcon.appiconset/Icon-1024                           1024    1024
EOF`


sizes_mapper_v=`cat << EOF
LaunchImage.launchimage/Launch-1125x2436                    1125    2436
LaunchImage.launchimage/Launch-1242x2206                    1242    2208
LaunchImage.launchimage/Launch-1242x2688                    1242    2688
LaunchImage.launchimage/Launch-1536x2048                    1536    2048
LaunchImage.launchimage/Launch-1536x2008                    1536    2008
LaunchImage.launchimage/Launch-1636x2048                    1636    2048
LaunchImage.launchimage/Launch-320x480                      320     480
LaunchImage.launchimage/Launch-640x1136                     640     1136
LaunchImage.launchimage/Launch-640x960                      640     960
LaunchImage.launchimage/Launch-750x1334                     750     1334
LaunchImage.launchimage/Launch-768x1004                     768     1004
LaunchImage.launchimage/Launch-768x1024                     768     1024
LaunchImage.launchimage/Launch-828x1792                     828     1792
EOF`

sizes_mapper_h=`cat << EOF
LaunchImage.launchimage/Launch-1024x748                     1024    748
LaunchImage.launchimage/Launch-1024x768                     1024    768
LaunchImage.launchimage/Launch-1792x828                     1792    828
LaunchImage.launchimage/Launch-2048x1496                    2048    1496
LaunchImage.launchimage/Launch-2048x1536                    2048    1536
LaunchImage.launchimage/Launch-2048x1636                    2048    1636
LaunchImage.launchimage/Launch-2208x1242                    2208    1242
LaunchImage.launchimage/Launch-2436x1125                    2436    1125
LaunchImage.launchimage/Launch-2688x1242                    2688    1242
EOF`

OLD_IFS=$IFS
IFS=$'\n'
srgb_profile='/System/Library/ColorSync/Profiles/sRGB Profile.icc'

#hh=`sips --getProperty pixelHeight "$src_file" | sed -E "s/.*pixelHeight: ([0-9]+)/\1/g" | tail -1`
#ww=`sips --getProperty pixelWidth "$src_file" | sed -E "s/.*pixelWidth: ([0-9]+)/\1/g" | tail -1`
#proportion=$(echo "scale=5;$ww / $hh" | bc)


for line in $sizes_mapper
do
    name=`echo $line|awk '{print $1}'`
    width=`echo $line|awk '{print $2}'`
    height=`echo $line|awk '{print $3}'`

    info "Generate $name.png ..."
    if [ -f $srgb_profile ];then
        sips --matchTo '/System/Library/ColorSync/Profiles/sRGB Profile.icc' -z $height $width $src_file --out $dst_path/$name.png >/dev/null 2>&1
    else
        sips -z $height $width $src_file --out $dst_path/$name.png >/dev/null
    fi
done

for line in $sizes_mapper_v
do
    name=`echo $line|awk '{print $1}'`
    width=`echo $line|awk '{print $2}'`
    height=`echo $line|awk '{print $3}'`

    info "Generate $name.png ..."
    if [ -f $srgb_profile ];then
        sips --matchTo '/System/Library/ColorSync/Profiles/sRGB Profile.icc' -z $height $width $src_file_v --out $dst_path/$name.png >/dev/null 2>&1
    else
        sips -z $height $width $src_file_v --out $dst_path/$name.png >/dev/null
    fi
done

for line in $sizes_mapper_h
do
    name=`echo $line|awk '{print $1}'`
    width=`echo $line|awk '{print $2}'`
    height=`echo $line|awk '{print $3}'`

    info "Generate $name.png ..."
    if [ -f $srgb_profile ];then
        sips --matchTo '/System/Library/ColorSync/Profiles/sRGB Profile.icc' -z $height $width $src_file_h --out $dst_path/$name.png >/dev/null 2>&1
    else
        sips -z $height $width $src_file_h --out $dst_path/$name.png >/dev/null
    fi
done

info "Congratulation. All icons for iOS/macOS/watchOS APP are generate to the directory: $dst_path."

IFS=$OLD_IFS


