#!/bin/bash

# FaceApp iOS Setup Script
# This script helps set up the Xcode project

echo "FaceApp iOS Setup"
echo "=================="

# Check if xcodegen is installed
if command -v xcodegen &> /dev/null; then
    echo "XcodeGen found. Generating project..."
    xcodegen generate
    echo "Project generated successfully!"
    echo "Opening FaceApp.xcodeproj..."
    open FaceApp.xcodeproj
else
    echo ""
    echo "XcodeGen is not installed."
    echo ""
    echo "To install XcodeGen, run:"
    echo "  brew install xcodegen"
    echo ""
    echo "Then run this script again, or manually:"
    echo "  xcodegen generate"
    echo "  open FaceApp.xcodeproj"
    echo ""
    echo "Alternatively, create the project manually in Xcode:"
    echo "1. Open Xcode"
    echo "2. File > New > Project"
    echo "3. iOS > App"
    echo "4. Product Name: FaceApp"
    echo "5. Interface: SwiftUI"
    echo "6. Language: Swift"
    echo "7. Delete the default ContentView.swift and Assets"
    echo "8. Drag the FaceApp folder contents into your project"
    echo "9. Set Bundle Identifier to: com.faceapp.nightlife"
    echo "10. Set Deployment Target to iOS 17.0"
fi
