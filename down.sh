#!/bin/bash

check_command() {
    if ! command -v $1 &> /dev/null
    then
        echo 未找到 $1 命令, 请先安装. >&2
        exit 1
    fi
}

check_command json  # yarn global add json
check_command curl  # apt install curl
check_command grep  # apt install grep
check_command ffmpeg  # apt install ffmpeg

[ -f .config ] && . .config

# parse video info url
VIURL="https://api.bilibili.com/x/web-interface/view"
if grep -E '^av[0-9]+$' &> /dev/null <<< "$1"
then
    VIURL="$VIURL?aid=$(grep -Eo '[0-9]+' <<< "$1")"
elif grep -E '^BV[a-zA-Z0-9]{10}$' &> /dev/null <<< "$1"
then
    VIURL="$VIURL?bvid=$1"
else
    echo "av/BV号码错误" >&2
    exit 1
fi

# add auth header
if [ x$auth != x ]
then
    export auth="-H 'Cookie: SESSDATA=$auth'"
else
    echo "未设置登录Cookie,无法下载高分辨率视频." >&2
fi


VINFO="$(curl -s -H 'User-Agent: Mozilla/5.0' $auth "$VIURL")"
TITLE="$(json data.title <<< "$VINFO")"
VIDEODIR="${1}_${TITLE}"
mkdir "$VIDEODIR"
echo "$VINFO" > "$VIDEODIR/vinfo.json"
cd "$VIDEODIR"

echo 下载封面
curl -H 'User-Agent: Mozilla/5.0' "$(json data.pic < vinfo.json)" > pic.jpg

TOTAL=$(json data.videos < vinfo.json)
AVID=$(json data.aid < vinfo.json)
p=0
while [ $p -lt $TOTAL ]
do
    # pinfo
    PINFO="$(json data.pages.$p < vinfo.json)"
    CID=$(json cid <<< "$PINFO")
    PAGE=$(json page <<< "$PINFO")
    PART=$(json part <<< "$PINFO")
    PDIR="P${PAGE}_${PART}_${CID}"
    echo "请求 $PDIR"
    mkdir "$PDIR"
    echo "$PINFO" > "$PDIR/pinfo.json"

    #sinfo
    curl -s -H 'User-Agent: Mozilla/5.0' $auth "https://api.bilibili.com/x/player/playurl?avid=${AVID}&cid=${CID}&fnval=16&fourk=1" > "$PDIR/sinfo.json"

    VURL="$(json data.dash.video.0.base_url < "$PDIR/sinfo.json")"
    AURL="$(json data.dash.audio.0.base_url < "$PDIR/sinfo.json")"

    echo "下载视频"
    curl -H 'User-Agent: Mozilla/5.0' -H 'Referer: https://www.bilibili.com/' "$VURL" > "$PDIR/video.m4s"
    echo "下载音频"
    curl -H 'User-Agent: Mozilla/5.0' -H 'Referer: https://www.bilibili.com/' "$AURL" > "$PDIR/audio.m4s"

    echo "合并音视频"
    ffmpeg -i "$PDIR/video.m4s" -i "$PDIR/audio.m4s" -c:v copy -c:a copy "$PDIR/$PDIR.mp4"

    p=$[p+1]
done

echo "$VIDEODIR 下载完成"
