#!/usr/bin/env bash
# sed -i 's/\r$//' Jetbrains-Installer/software_install.sh
# 该脚本用于自动化安装 JetBrains 产品的归档包
# 参数说明：
# $1 - 归档包路径（.tar.gz 文件）
# $2 - 产品通用名称（如 Pycharm-Community）
# $3 - 产品安装目录（如 /SunshineCloud/Jetbrains/）
# $4 - 产品下载临时目录（如 /SunshineCloud/Jetbrains/temp）
# $5 - 产品目录用户权限（如 matrix0523）

# 保存当前工作目录
export jbiDir="$(pwd)"

# 创建 JetBrains 安装目录和临时目录（如果不存在则创建）
sudo mkdir -vp $3
sudo mkdir -vp $4

# 解压归档包到临时目录
sudo tar xvf $1 -C $4

# 解析归档包名称，获取原始目录名
rawarchDir="${1%".tar.gz"}"         # 去掉.tar.gz后缀
archDir="${rawarchDir%%-*}"         # 去掉第一个'-'及其后内容
progDir="$(basename $archDir)"      # 获取归档包的基础名称

# 进入临时目录
cd $4

# 获取产品通用名称
commonName=$2

# 如果目标目录已存在，先删除旧版本
if [ -d "../$commonName" ]; then
  echo "Removing old version"
  yes | rm -r ../$commonName
fi

# 将归档包目录名转为小写（未使用，可删除或用于后续扩展）
export progDirL=$(echo "$progDir" | sed -e 's/\(.*\)/\L\1/')

# 将解压出来的所有内容移动到目标目录
mv * ../$commonName

# 返回上级目录并删除临时目录
cd ..
rm -r $4

# 设置产品目录的所有者为当前用户
sudo chown -R $5:$5 /SunshineCloud

# 进入产品的 bin 目录，准备后续操作
cd $commonName/bin || exit 1

# 以下为可选操作（已注释），如复制图标、desktop 文件、安装启动脚本等
cp -u *.svg /usr/share/pixmaps/$2.svg
cp -u $jbiDir/applications/$commonName.desktop /usr/share/applications/
cp -u $jbiDir/applications/$commonName.desktop $HOME/Desktop/
# 安装完成提示
echo "Software Installed"