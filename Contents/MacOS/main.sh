#!/usr/bin/env bash

# shellcheck disable=SC2015,SC2164

# Exit on non-0 exit
set -e

# Make sure dependencies are installed
for dep in brew git steamcmd
do
	command -v "$dep" &> /dev/null || {
		echo "Not found: $dep"
		false
	}
done

# Go to Descent 3.app
cd "$(dirname "$0")/../.."

# Create directory
dirD3="D3-open-source"
mkdir -p "$dirD3"

# Download Windows version of Descent 3 from Steam if not already downloaded (recommended over macOS version for cutscene/cinematic support)
dirSteamD3="$HOME/Library/Application Support/Steam/steamapps/common/Descent 3"
idD3=273590
[ -d "$dirSteamD3" ] || {
	echo -n "Steam username: " && read -r usernameSteam
	steamcmd \
		+@sSteamCmdForcePlatformType windows \
		+login "$usernameSteam" \
		+app_update "$idD3" \
		validate \
		+quit
}

# Copy files
for ext in "*.hog" "*.pld"
do
	find "$dirSteamD3" -type f -mindepth 1 -maxdepth 1 -name "$ext" | while read -r f
	do
		cp "$f" "$dirD3"
	done
done
cp -r "$dirSteamD3/demo" "$dirD3"
cp -r "$dirSteamD3/movies" "$dirD3"

# Create cache directory
mkdir -p "$dirD3/custom/cache"

# Clone or pull repo if Github's available
urlClone="https://github.com/DescentDevelopers/Descent3.git"
ping -c 1 github.com &> /dev/null && {
	dirRepo=Descent3
	if [ -d "$dirRepo" ]
	then
		git -C "$dirRepo" pull
		echo "Brewfile.lock.json" > "$dirRepo/.git/info/exclude"
	else
		git clone "$urlClone"
	fi
}
[ -d "$dirRepo" ] || {
	echo "Couldn't clone $urlClone" >&2
}

# Clean and build repo
brew bundle --file "$dirRepo/Brewfile" install
for artifact in "Descent3/builds" "Descent3/git-hash.txt"
do
	[ -e "$artifact" ] && rm -rf "$artifact"
done
(cd "$dirRepo" && cmake --preset mac -D ENABLE_LOGGER=ON)
(cd "$dirRepo" && cmake --build --preset mac --config Release)

# Copy files
cp -rf "$dirRepo/builds/mac/Descent3/release/." "$dirD3"

# Run
(cd "$dirD3" && ./Descent3)
