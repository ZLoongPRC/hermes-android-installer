# Hermes Android Installer

一键在 Android 手机上安装 Hermes Agent。

## 快速开始

### 方式一：全新安装（推荐）
1. 下载 Releases 页面的最新 APK
2. 安装 APK
3. 打开 Termux，等 3 分钟自动装好
4. 输入 `hermes` 开始使用

### 方式二：已有 Termux
```bash
curl -sL https://github.com/ZLoongPRC/hermes-android-installer/releases/latest/download/setup.sh | bash
```

## 项目文件

```
├── .github/workflows/
│   └── build.yml        # GitHub Actions — 编译 APK + 发布 Release
├── scripts/
│   ├── setup.sh         # 一键安装脚本
│   ├── build-apk.sh     # 本地编译脚本
│   └── optimize.sh      # 环境优化（Dashboard 等）
└── patches/
    └── termux-boot.patch # Termux 首次启动自动运行 setup
```

## 许可证

- 本项目构建脚本和配置：**MIT**
- termux-app（APK 基础）：**GPL-3.0**
- Hermes Agent：**MIT**

本项目的构建产物非官方发行版。
