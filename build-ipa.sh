
set -e  # 一旦命令失败就退出脚本

# 打印命令执行过程（调试用）
set -x

# 使用 fvm 指定版本的 Flutter 构建 iOS Release 包
fvm flutter build ios --release

# 检查 Runner.app 是否生成成功
APP_PATH="build/ios/Release-iphoneos/Runner.app"
if [ ! -d "$APP_PATH" ]; then
  echo "❌ Error: Runner.app not found at $APP_PATH"
  exit 1
fi

# 清理旧文件
rm -rf Payload Runner.ipa

# 创建 Payload 目录
mkdir Payload

# 复制 Runner.app 到 Payload
cp -rf "$APP_PATH" Payload/Runner.app

# 压缩为 ipa
zip -r Runner.ipa Payload > /dev/null

# 删除 Payload 临时目录
rm -rf Payload

# 输出 ipa 路径
echo "✅ IPA 打包完成: $(pwd)/Runner.ipa"
