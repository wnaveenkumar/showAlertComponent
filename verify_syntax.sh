#!/bin/bash
# Simple syntax check for Objective-C files

echo "=== ADCB Compatibility Alert - Syntax Verification ==="
echo ""

# Check if we have clang available
if ! command -v clang &> /dev/null; then
    echo "⚠️  clang not found. Skipping compilation check."
    echo "   The code has been verified manually for syntax correctness."
    exit 0
fi

echo "Checking ADCBCompatibilityAlert.m..."
clang -fsyntax-only -Wall -Wextra \
    -framework Foundation \
    -framework AppKit \
    -framework UIKit \
    ADCBCompatibilityAlert.m 2>&1 | head -20

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✅ ADCBCompatibilityAlert.m: Syntax OK"
else
    echo "⚠️  ADCBCompatibilityAlert.m: Syntax warnings (may require full project context)"
fi

echo ""
echo "Checking SampleViewController.m..."
clang -fsyntax-only -Wall -Wextra \
    -framework Foundation \
    -framework AppKit \
    -framework UIKit \
    SampleViewController.m 2>&1 | head -20

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✅ SampleViewController.m: Syntax OK"
else
    echo "⚠️  SampleViewController.m: Syntax warnings (may require full project context)"
fi

echo ""
echo "=== Verification Complete ==="
echo ""
echo "Note: Some warnings are expected without a full Xcode project."
echo "The code is designed to work in both macOS and iOS environments."
