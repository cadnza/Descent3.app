#!/usr/bin/env bash

# Error if this isn't macOS
[[ "$OSTYPE" == "darwin"* ]] || {
	echo "This script only runs on macOS." >&2
	exit 1
}

# Run build and launch script in terminal
open -a Terminal.app "$(dirname "$0")/main.sh"
