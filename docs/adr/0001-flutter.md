---
status: accepted
date: 2026-06-25
---

# ADR-0001: Flutter 作为跨平台移动端技术栈

游戏用 Flutter（Dart）实现 iOS + Android 双端。备选 PWA 和 React Native (Expo)。Flutter 给出原生 App 体验、home-screen 体感，且对 14 个系统的程序化内容生成最友好。

## 考虑过的方案

- **PWA** — 开发部署最快，浏览器打开即可玩，但缺原生 App 手感，且不能上 App Store
- **React Native (Expo)** — 与 Flutter 形态相近，TypeScript/JSX 生态，无决定性优势
- **原生 iOS + Android** — 工作量翻倍，此规模无收益

## 后果

- 锁定 Dart 语言。换平台需重写整个 UI 层
- 所有 UI 走 Flutter widget 树，无 HTML/CSS
- 部署产物：iOS .ipa + Android .apk/.aab（可上 App Store，个人玩不需要）
