<img width="661" height="571" alt="配置工具" src="https://github.com/user-attachments/assets/7a4fd64b-7fde-4561-88bf-7e8ddb06d955" />


# Game Config Tool

一款基于 **Lazarus** 开发的轻量级、跨平台游戏配置工具。

## 📖 项目简介

此为游戏逐梦江湖行的游戏配置工具，制作时，发现没有同类轻便实现游戏配置工具的开源方案。

本项目完全基于 **Lazarus 4.2** 编译通过，旨在提供一个简洁、稳定的配置方案。

## ✨ 功能特性

* **全平台覆盖**：一份代码多端编译，完美支持 **Windows**、**macOS** 和 **Linux**。
* **原生性能**：基于 Free Pascal，拥有极高的运行效率和极小的内存占用。

## 🛠 编译说明

如果你需要从源代码构建本项目，请确保安装了以下环境：

* **IDE**: Lazarus 4.2
* **编译器**: FPC (Free Pascal Compiler)

### ⚠️ 特定平台编译注意事项 (macOS)
在 **macOS** 平台上进行编译时，请务必在项目选项中添加编译器指令：
1. 进入 `Project Options` -> `Compiler Options` -> `Custom Options`。
2. 添加以下参数：
   -WM10.5
