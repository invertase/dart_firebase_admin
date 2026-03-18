#!/bin/bash
set -e

# Get the package name from the current directory
PACKAGE_NAME=$(basename "$(pwd)")

# Generate docs to subdirectory
dart doc . --output "../../doc/api/$PACKAGE_NAME"
