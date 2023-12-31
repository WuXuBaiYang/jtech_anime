# <img alt="app-logo" height="50" width="50" src="./readme/app_logo.png"/> 看番咩？ - Flutter 开源项目

欢迎使用 '看番咩？' 开源项目！本项目基于 Flutter 3.16.0 版本开发。

<img alt="桌面端" height="200" width="260" src="./readme/desktop.png"/>
<img alt="桌面端" height="200" width="110" src="./readme/mobile.jpg"/>
<img alt="PAD" height="200" width="110" src="./readme/pad.png"/>

## 部署步骤

请按照以下步骤来部署 '看番咩？' 项目：

1. 克隆项目到本地：
   ```
   git clone https://github.com/WuXuBaiYang/jtech_anime.git
   ```

2. 进入项目目录：
   ```
   cd jtech_anime/base
   ```

3. 执行脚本生成数据库文件：
   ```
   dart pub run build_runner
   // 以下是持续监听命令
   // 会让控制台阻塞等待，执行后面的命令需要重开窗口
   dart pub run build_runner watch --verbose
   ```

4. 进入到mobilie(移动端项目)/desktop(桌面端项目)：
   ```
   cd ../mobile
   或
   cd ../desktop
   ```
5. 拉取依赖
   ```
   flutter pub get
   ```
6. 使用开发工具打开mobile或者deskktop目录开始使用吧~

## 未来计划

以下是我们对 '看番咩？' 项目的未来计划：

1. M3U8文件下载与管理 --已完成
2. 使用 JS 插件方式加载数据源 --已完成
3. 重做整体UI --已完成
4. 插件开发相关的 Debug 工具
5. 拆解核心模块抽取为独立库 --已完成
6. 开发 Windows、macOS 和 Linux 桌面端版本 --已完成
7. 开发大屏幕版本，包括桌面端与tv端
8. 开发pad版本，包括android/ios --已完成

我们正在努力实现这些计划，并将持续改进 '看番咩？' 项目。如果您有任何其他建议或想法，我们也非常欢迎您的贡献！

## 注意事项

- 在部署之前，请确保已经正确安装了 Flutter 3.16.0 版本。
- 如果遇到任何问题，请尝试重新拉取依赖和重新生成数据库文件。
- 如果问题仍然存在，请查看项目的文档或提交问题到项目的 GitHub 页面以获取帮助。

## 贡献

- <img alt="猫男的头像" height="20" width="20" src="./readme/avatar_mao.jpg"/> 猫男(的老婆)
    - 来自'煎蛋发大财' QQ群

如果您对 '看番咩？' 项目有任何改进或建议，我们非常欢迎您的贡献！请在 GitHub 上提交拉取请求或问题以帮助改进这个项目。

感谢您使用 '看番咩？' 开源项目！希望这个项目能满足您的需求，如果您有任何问题，请随时联系我们。
