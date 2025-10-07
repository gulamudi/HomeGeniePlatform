#!/bin/bash

# Get current timestamp in YYYYMMDDHHNN format
BUILD_NUMBER=$(date +"%Y%m%d%H%M")

# Path to pubspec.yaml
PUBSPEC_PATH="$SRCROOT/../pubspec.yaml"

# Update the build number in pubspec.yaml
sed -i '' "s/version: \([0-9]*\.[0-9]*\.[0-9]*\)+[0-9]*/version: \1+$BUILD_NUMBER/" "$PUBSPEC_PATH"

echo "Updated build number to: $BUILD_NUMBER"
