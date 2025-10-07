#!/bin/bash

# Auto-update build number with timestamp
BUILD_NUMBER=$(date +"%Y%m%d%H%M")
sed -i '' "s/version: \([0-9]*\.[0-9]*\.[0-9]*\)+[0-9]*/version: \1+$BUILD_NUMBER/" pubspec.yaml

echo "✅ Updated build number to: $BUILD_NUMBER"
echo "🔨 Building IPA..."

# Build the IPA
flutter clean
flutter pub get
flutter build ipa --release

echo "✅ Build complete!"
echo "📤 Now open Xcode to upload:"
echo "   open ios/Runner.xcworkspace"
echo "   Then: Product → Archive → Distribute App"
