# Cursor IDE Extensions Optimization Guide

## Current Java Processes Running

Based on the process list, you have these Cursor extensions running Java processes:

### 1. **Gradle Extension** (`vscjava.vscode-gradle`)
- **Purpose**: Gradle build tool support
- **Java Processes**: Multiple Gradle daemons
- **Needed for Flutter?**: Only if actively editing Android build files
- **Recommendation**: **Can be disabled** if you're not working on Android native code

### 2. **Java Language Support** (`redhat.java`)
- **Purpose**: Java language server for IntelliSense, refactoring, etc.
- **Java Processes**: Eclipse JDT Language Server
- **Needed for Flutter?**: Only if editing Android native Java/Kotlin code
- **Recommendation**: **Can be disabled** if you're only working with Dart/Flutter

### 3. **SonarLint** (`sonarsource.sonarlint-vscode`)
- **Purpose**: Code quality and security analysis
- **Java Processes**: SonarLint language server
- **Needed for Flutter?**: Optional - only if you want code quality checks
- **Recommendation**: **Can be disabled** if not actively using it

### 4. **Gradle Daemons** (Build tools)
- **Purpose**: Android build system
- **Java Processes**: Gradle build daemons (multiple versions: 8.9, 8.12)
- **Needed for Flutter?**: Only when building Android apps
- **Recommendation**: Can be stopped when not building

## How to Disable Extensions in Cursor

1. Open Cursor
2. Press `Ctrl+Shift+X` (or `Cmd+Shift+X` on Mac) to open Extensions
3. Search for each extension and click "Disable" or "Uninstall"

### Extensions to Consider Disabling:

1. **Gradle for Java** (`vscjava.vscode-gradle`)
   - Disable if you're not editing `build.gradle` files

2. **Language Support for Java** (`redhat.java`)
   - Disable if you're not editing Java/Kotlin files in `android/` folder

3. **SonarLint** (`sonarsource.sonarlint-vscode`)
   - Disable if you're not using code quality checks

## Stop Gradle Daemons

You can also stop Gradle daemons manually:

```bash
# Stop all Gradle daemons
cd /home/enrico/StudioProjects/food_prepping
./gradlew --stop

# Or for specific Gradle version
cd ~/.gradle
find . -name "gradle-daemon-*.pid" -delete
```

## Recommended Extensions for Flutter Development

Keep these enabled:
- ✅ Dart
- ✅ Flutter
- ✅ Flutter Intl (if using)
- ✅ Error Lens
- ✅ GitLens (optional)

## Expected Resource Savings

After disabling Java-related extensions:
- **Memory**: ~2-4GB freed (Java processes use significant RAM)
- **CPU**: Lower background usage
- **Startup**: Faster IDE startup

## Notes

- You can always re-enable extensions if you need to work on Android native code
- Gradle daemons will restart automatically when you build Android apps
- Disabling extensions won't affect your Flutter app's functionality

