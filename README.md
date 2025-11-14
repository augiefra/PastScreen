# 📸 PastScreen

**Ultra-fast screenshots for developers**

[![Version](https://img.shields.io/badge/version-1.4-blue.svg)](https://github.com/augiefra/PastScreen/releases/tag/v1.4)
[![Platform](https://img.shields.io/badge/platform-macOS%2014.0+-lightgrey.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

> The fastest way to capture, copy, and paste screenshots directly into your code editor.

---

## ✨ Features

- **Instant Capture**: Screenshot to clipboard in milliseconds
- **Smart Selection**: Click and drag to select any screen region
- **Multi-Monitor**: Works seamlessly across multiple displays
- **Auto-Paste Ready**: Optimized for VSCode, Cursor, Zed, and all IDEs
- **Customizable Hotkey**: Set your preferred keyboard shortcut
- **Menu Bar App**: Always accessible, never intrusive
- **Multilingual**: English, French, Spanish, German, Italian

## 🚀 Installation

### Download

1. Download the latest `.dmg` from [Releases](https://github.com/augiefra/PastScreen/releases)
2. Open the `.dmg` file
3. Drag **PastScreen** to your Applications folder
4. Launch PastScreen from Applications

### Auto-Update

PastScreen includes Sparkle auto-update. You'll be notified when new versions are available.

## 🎯 Usage

### Quick Start

1. **Launch** PastScreen - it appears in your menu bar
2. **Press** your hotkey (default: `⌥⌘S`)
3. **Select** screen region by clicking and dragging
4. **Paste** instantly in your editor with `⌘V`

### Settings

Click the menu bar icon to:
- Change keyboard shortcut
- Choose save location
- Select image format (PNG/JPG)
- Enable/disable clipboard copy
- Enable/disable file save

## ⌨️ Default Hotkey

**`⌥⌘S`** (Option + Command + S)

Customizable in Settings → Shortcut tab

## 🔒 Permissions

PastScreen requires two macOS permissions:

- **Screen Recording**: To capture screenshots
- **Accessibility**: For global keyboard shortcuts

Grant these in **System Settings → Privacy & Security**

## 🛠️ Technical Details

- **Framework**: SwiftUI + AppKit
- **Minimum macOS**: 14.0 (Sonoma)
- **Architecture**: Native Apple Silicon + Intel
- **Bundle ID**: `com.augiefra.PastScreen`
- **Auto-Update**: Sparkle framework

## 📸 How It Works

1. Global hotkey triggers capture mode
2. Transparent overlay covers all screens
3. User drags selection rectangle
4. CGDisplayCreateImage captures region
5. Image copied to clipboard (NSPasteboard)
6. Optional: Save to disk with timestamp

## 🌍 Supported Languages

- 🇬🇧 English
- 🇫🇷 Français
- 🇪🇸 Español
- 🇩🇪 Deutsch
- 🇮🇹 Italiano

Language auto-detected from system preferences.

## 📝 Changelog

### v1.4 (Latest)
- Complete rebrand: ScreenSnap → PastScreen
- Architecture modernization
- Memory management improvements
- Enhanced multilingual support
- Bug fixes and stability improvements

### v1.3
- Redesigned onboarding interface
- Improved user experience

### v1.2
- Smart clipboard detection
- Multilingual localization

[Full changelog](https://github.com/augiefra/PastScreen/releases)

## 🤝 Contributing

This is the public release repository. For development:
- Development repo: [PastScreen-dev](https://github.com/augiefra/PastScreen-dev)
- Issues: [Report bugs here](https://github.com/augiefra/PastScreen/issues)
- Feature requests: [Submit ideas](https://github.com/augiefra/PastScreen/issues/new)

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details

## 👤 Author

**Eric Cologni** ([@augiefra](https://github.com/augiefra))

---

⭐ **Star this repo** if PastScreen helps your workflow!

🐛 **Found a bug?** [Open an issue](https://github.com/augiefra/PastScreen/issues/new)

💡 **Have an idea?** [Share it with us](https://github.com/augiefra/PastScreen/issues/new)
