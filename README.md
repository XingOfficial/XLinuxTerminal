# XLinuxTerminal

一款基于 Termux 终端库构建的 Android 终端模拟器，支持在 Android 设备上执行 Linux 命令。

## 功能特性

- Termux 终端库集成：使用官方 terminal-view 和 terminal-emulator
- 命令行交互：支持 ls、pwd、echo、cat、mkdir、touch 等常用命令
- 绿色终端主题：经典终端配色方案
- 协程异步执行：命令执行不阻塞 UI
- 命令历史记录：自动保存输入历史
- 滚动输出区域：支持长文本滚动查看
- 清空功能：一键清空输出区域

## 技术栈

| 组件 | 版本 |
|------|------|
| Kotlin | 1.9.20 |
| Android Gradle Plugin | 8.2.0 |
| Gradle | 8.7 |
| compileSdk | 34 |
| minSdk | 24 |

## 依赖库

### AndroidX
- androidx.core:core-ktx:1.12.0
- androidx.appcompat:appcompat:1.6.1
- com.google.android.material:material:1.11.0
- androidx.constraintlayout:constraintlayout:2.1.4
- androidx.lifecycle:lifecycle-runtime-ktx:2.7.0

### Termux 终端库
- com.termux.termux-app:termux-shared:0.118.0
- com.termux.termux-app:terminal-view:0.118.0
- com.termux.termux-app:terminal-emulator:0.118.0

## 项目结构

```
XLinuxTerminal/
├── app/
│   ├── build.gradle.kts
│   ├── proguard-rules.pro
│   └── src/main/
│       ├── AndroidManifest.xml
│       ├── java/cn/xing/terminal/xerminal/
│       │   └── MainActivity.kt
│       └── res/
│           ├── layout/activity_main.xml
│           ├── mipmap-hdpi/ic_launcher.xml
│           └── values/
│               ├── colors.xml
│               ├── strings.xml
│               └── themes.xml
├── build.gradle.kts
├── settings.gradle.kts
├── gradle.properties
└── gradle/wrapper/
    └── gradle-wrapper.properties
```

## 构建方式

### 本地构建

```bash
./gradlew assembleRelease
```

### GitHub Actions 自动构建

项目配置了 GitHub Actions CI，推送代码后自动编译并上传签名 APK。

## 安装要求

- Android 7.0+ (API 24+)
- 存储权限（用于文件操作）

## 包名

```
cn.xing.terminal.xerminal
```

## 应用名

```
XLinuxTerminal
```

## 截图

[待添加]

## 许可证

MIT License

## 作者

XingOfficial
