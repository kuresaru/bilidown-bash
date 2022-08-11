# bilidown-bash
用 GNU Bash 的方式下载 Bilibili 视频

(未做任何错误处理和错误提示,请手动判断是否下载完整.)

**请勿滥用，本项目仅用于学习和测试！！**

## Require:

```shell
apt install curl ffmpeg nodejs npm
npm install -g json
```


## Usage:

```shell
# 下载 BV1tJ411p7yM
./down.sh BV1tJ411p7yM

# 下载 av83005929
./down.sh av83005929
```

## Login:

```
复制config.example为.config  (参考命令  cp config.example .config)
编辑.config 设置auth变量为有效的SESSDATA
部分视频或画质需要登录特定帐号才能下载
```


## Dependencies:

+ [json](https://www.npmjs.com/package/json)
+ [GNU Bash](http://www.gnu.org/software/bash/)
+ [FFmpeg](http://www.ffmpeg.org/)
+ [CURL](https://curl.se/)


## References:

+ [Bilibili API](https://github.com/SocialSisterYi/bilibili-API-collect)


## Author:


[暮光小猿wzt](http://www.scraft.top)
