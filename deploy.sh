#!/bin/bash
set -e

echo "=== ArcanaWatch Deploy Script ==="

# Step 1: Generate Xcode project
echo ""
echo "▶ Generating Xcode project with XcodeGen..."
cd "$(dirname "$0")/ArcanaWatch"
xcodegen

# Step 2: Build for device
echo ""
echo "▶ Building for Apple Watch (device)..."
xcodebuild \
  -project ArcanaWatch.xcodeproj \
  -scheme ArcanaWatch \
  -destination 'generic/platform=watchOS' \
  -allowProvisioningUpdates \
  clean build

echo ""
echo "✅ Build succeeded!"
echo ""
echo "Now open Xcode and press ▶ to install on your watch:"
echo "  open ArcanaWatch.xcodeproj"
