# ABC、面白い！ (ABC Omoshiroi!)

![Platform](https://img.shields.io/badge/Platform-iPadOS-lightgrey) ![Language](https://img.shields.io/badge/Language-Swift-orange) ![Framework](https://img.shields.io/badge/Framework-SwiftUI-blue)

**[日本語]** | [English] | [中文]

---

## 🇯🇵 日本語：プロジェクト紹介

### 📱 概要
「ABC、面白い！」は、未就学児が楽しみながらアルファベットを学べる **iPad専用の知育アプリ** です。
視覚（3Dアニメーション）、聴覚（ネイティブ発音）、触覚（ハプティックフィードバック）を組み合わせ、直感的な学習体験を提供します。

### 💡 開発の背景（Motivation）
iOSエンジニアとしての就職を目指し、**SwiftUIによる高度なインタラクション** と **iPadデバイスへの最適化** を実践するために開発しました。単なる機能の実装にとどまらず、「ユーザー（子供）が触りたくなるUI」を追求しました。

### ✨ 技術的なこだわり (Key Features)
1.  **SwiftUIによる3Dフリップアニメーション**
    * カードをタップした際、`rotation3DEffect` を使用して滑らかな裏返しアニメーションを実装。状態管理（State）により、同時に1枚しかめくれないロジックを構築しました。
2.  **iPad Proへの最適化**
    * 10.5インチiPad Proの実機でテストを行い、子供の指でも押しやすいボタンサイズやレイアウト間隔（GridItem）を調整しました。
3.  **五感へのフィードバック**
    * `UINotificationFeedbackGenerator` を活用し、正解・不正解時に独自の振動フィードバックを実装。画面を見なくても結果がわかるユニバーサルデザインを意識しました。
4.  **AVFoundationによる音声制御**
    * `AVSpeechSynthesizer` を細かくチューニングし、発音の速度やピッチを調整して、子供が聞き取りやすい英語音声を実現しました。

---

## 🇺🇸 English: Project Overview

### 📱 About
"ABC Omoshiroi!" is an **educational iPad app** designed for preschoolers to learn the alphabet interactively. It combines visual 3D animations, native pronunciation, and haptic feedback to create an immersive learning experience.

### 💡 Motivation
Developed as a portfolio project for an iOS Engineer position in Japan, this app demonstrates proficiency in **SwiftUI interactions** and **iPadOS optimization**. The goal was to create a UI that is genuinely engaging for children.

### ✨ Tech Highlights
* **3D Flip Animations**: Implemented smooth card-flipping effects using `rotation3DEffect` and complex State management in SwiftUI.
* **Haptic Feedback**: Integrated `UINotificationFeedbackGenerator` to provide distinct tactile responses for correct/incorrect answers, optimized for iPad hardware.
* **Responsive Grid Layout**: Utilized `LazyVGrid` to ensure perfect rendering across different iPad screen sizes.
* **Text-to-Speech**: Customized `AVFoundation` speech synthesis for clear, child-friendly English pronunciation.

---

## 🇨🇳 中文：项目介绍

### 📱 简介
“ABC、面白い！” 是一款专为学龄前儿童设计的 **iPad 字母认知应用**。通过融合 3D 翻转动画、纯正发音和触感反馈，为孩子提供直观、有趣的英语启蒙体验。

### 💡 开发初衷
本项目是为了展示 iOS 开发能力（特别是针对日本市场）而制作的个人作品。重点在于探索 **SwiftUI 的高级交互动画** 以及 **iPad 真机适配**，力求打磨出具有商业级质感的 UI 体验。

### ✨ 技术亮点
1.  **SwiftUI 3D 翻转引擎**：使用 `rotation3DEffect` 实现丝滑的卡片翻转效果，并通过精细的状态管理（State Management）控制卡片的交互逻辑。
2.  **iPad Pro 深度适配**：针对 iPad Pro 10.5 英寸真机进行了布局优化，调整了 Grid 网格间距与触摸热区。
3.  **Haptic 触感反馈**：调用 `UINotificationFeedbackGenerator`，利用 iPad 的线性马达为答题结果提供细腻的震动反馈。
4.  **AVFoundation 音频控制**：定制语音合成器的语速与音调，实现了带有“呼吸感”的自然发音节奏。

---

### 🛠 Tools & Environment
* **Xcode**: 15.0+
* **Language**: Swift 5.9
* **Target**: iPadOS 17.0+
* **Frameworks**: SwiftUI, AVFoundation, UIKit (Haptics)

---
*Created by [Your Name] for iOS Developer Portfolio.*
