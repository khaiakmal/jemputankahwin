# Custom Keyboard - Flutter Android App

A modern, customizable Flutter keyboard app for Android with complete QWERTY layout, Material Design styling, and responsive UI.

## 🚀 Features

### **PHASE 1: Basic Keyboard Layout** ✅ COMPLETED
- ✅ Complete QWERTY keyboard layout
- ✅ Full alphabet (A-Z), numbers (0-9), symbols
- ✅ Shift key functionality for uppercase
- ✅ Backspace and Space bar
- ✅ Material Design styling
- ✅ Responsive layout for different screen sizes
- ✅ Haptic feedback on key press
- ✅ Smooth press animations

## 📁 Project Structure

```
CustomKeyboard/
├── lib/
│   ├── main.dart                    # App entry point and main screen
│   ├── widgets/
│   │   ├── keyboard_layout.dart     # QWERTY keyboard layout implementation
│   │   └── key_widget.dart          # Individual key components
│   └── services/
│       └── keyboard_service.dart    # Keyboard functionality and text processing
├── android/                         # Android-specific configuration
├── pubspec.yaml                     # Dependencies and project config
└── README.md                        # Project documentation
```

## 🛠 Technical Specifications

- **Target**: Android SDK 31+
- **Flutter**: 3.x compatible
- **Architecture**: Clean, modular code structure
- **UI**: Material Design 3.0
- **Features**: Proper widget separation, responsive design

## 📋 Installation & Setup

### Prerequisites
- Flutter SDK 3.0+
- Android Studio / VS Code
- Android SDK 31+
- Dart 3.0+

### Steps

1. **Clone/Setup the project**
   ```bash
   cd CustomKeyboard
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🎯 Key Components

### 1. **main.dart**
- App initialization and setup
- Main screen with text input area
- Custom keyboard integration
- Text cursor management

### 2. **keyboard_layout.dart**
- Complete QWERTY layout implementation
- Shift and caps lock functionality
- Number row with symbols
- Special keys (Space, Backspace, Enter)
- Responsive row layouts

### 3. **key_widget.dart**
- Individual keyboard key component
- Press animations and haptic feedback
- Special key styling (Shift, Backspace, etc.)
- Spacebar widget with custom styling

### 4. **keyboard_service.dart**
- Text input management
- Keyboard state handling
- Text processing utilities
- Cursor position management

## 🎨 Design Features

- **Material Design 3.0** styling
- **Smooth animations** on key press
- **Haptic feedback** for better UX
- **Responsive layout** for different screen sizes
- **Visual feedback** for active states (Shift, Caps Lock)
- **Modern color scheme** with theme support

## 🔧 Customization

### Keyboard Layout
The keyboard layout can be easily modified by editing the arrays in `keyboard_layout.dart`:

```dart
final List<List<String>> _qwertyLayout = [
  ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
  ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
  ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
];
```

### Key Styling
Individual key appearance can be customized in `key_widget.dart`:

```dart
KeyWidget(
  keyValue: 'A',
  backgroundColor: Colors.blue,
  textColor: Colors.white,
  height: 50,
  fontSize: 16,
)
```

## 🎮 Usage

1. **Launch the app** - The keyboard appears at the bottom
2. **Type text** - Tap keys to input text in the text field above
3. **Use Shift** - Tap Shift for uppercase letters and symbols
4. **Backspace** - Remove characters
5. **Space** - Add spaces between words

## 🔄 Next Phases (Coming Soon)

### **PHASE 2: Language Toggle System**
- Language toggle buttons [BM] [BI]
- Language indicator in top bar
- Smooth transition animations
- Language state management

### **PHASE 3: Settings & Configuration**
- Keyboard preferences screen
- Theme selection (Light/Dark)
- Key size adjustment
- Sound and vibration toggles

### **PHASE 4: Bubble UI Components**
- Floating overlay bubble widget
- Draggable positioning system
- Auto-hide/show animations
- Modern glassmorphism design

## 🐛 Troubleshooting

### Common Issues

1. **Flutter not found**
   - Ensure Flutter SDK is installed and in PATH
   - Run `flutter doctor` to check setup

2. **Dependencies not installed**
   - Run `flutter pub get` in project root

3. **Android build issues**
   - Ensure Android SDK 31+ is installed
   - Check `android/app/build.gradle` configuration

## 📱 Testing

### On Physical Device
```bash
flutter run --release
```

### On Emulator
```bash
flutter run
```

## 📄 License

This project is created for educational and development purposes.

## 🤝 Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

---

**Built with Flutter 💙 | Material Design 3.0 🎨 | Android 🤖**