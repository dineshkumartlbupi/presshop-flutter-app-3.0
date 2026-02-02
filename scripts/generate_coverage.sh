#!/bin/bash

# Run all tests with coverage
flutter test --coverage

# Check if lcov is installed for HTML generation
if command -v genhtml &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    echo "Coverage report generated at coverage/html/index.html"
else
    echo "Coverage info generated at coverage/lcov.info"
    echo "Install lcov (brew install lcov) to generate HTML report."
fi
