#!/bin/bash
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

PERMALINK_WIN="https://aka.ms/win32-x64-user-stable"
# https://az764295.vo.msecnd.net/stable/485c41f9460bdb830c4da12c102daff275415b53/VSCodeUserSetup-x64-1.47.1.exe
PERMALINK="https://go.microsoft.com/fwlink/?LinkID=760868"
# https://az764295.vo.msecnd.net/stable/485c41f9460bdb830c4da12c102daff275415b53/code_1.47.1-1594686231_amd64.deb
NOW=$(date +"%Y%m%d")
ROOT_DIR="${THIS_DIR}/vscode-$NOW"
mkdir -p "$ROOT_DIR"

# LINUX
IFS=$'\n' INFO=($(wget -O "$ROOT_DIR/tmp.deb" -nv "$PERMALINK" 2>&1 | \
  grep -o -e '[0-9]\+\.[0-9]\+\.[0-9]\+\|[a-z0-9]\{40\}'))
COMMIT=${INFO[0]}
VERSION=${INFO[1]}

echo "Commit: $COMMIT"
echo "Version: $VERSION"
mv "$ROOT_DIR/tmp.deb" "$ROOT_DIR/vscode-linux-x64-$VERSION-$COMMIT.deb"

# WINDOWS
IFS=$'\n' INFO=($(wget -O "$ROOT_DIR/tmp.exe" -nv "$PERMALINK_WIN" 2>&1 | \
  grep -o -e '[0-9]\+\.[0-9]\+\.[0-9]\+\|[a-z0-9]\{40\}'))
COMMIT=${INFO[0]}
VERSION=${INFO[1]}

echo "Commit: $COMMIT"
echo "Version: $VERSION"
mv "$ROOT_DIR/tmp.exe" "$ROOT_DIR/vscode-windows-x64-$VERSION-$COMMIT.exe"

# VSCode server
wget -nv -O "$ROOT_DIR/vscode-server-linux-x64-$VERSION-$COMMIT.tar.gz" \
    "https://update.code.visualstudio.com/commit:$COMMIT/server-linux-x64/stable" 2>/dev/null


"${THIS_DIR}/extensions.py" "$ROOT_DIR"

# https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-python/vsextensions/python/2020.6.91350/vspackage
