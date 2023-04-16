#!/bin/bash

REPOOWNER="ekkinox"
REPONAME="yo"
RELEASETAG=$(curl -s "https://api.github.com/repos/$REPOOWNER/$REPONAME/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

KERNEL=$(uname -s 2>/dev/null || /usr/bin/uname -s)
case ${KERNEL} in
    "Linux"|"linux")
        KERNEL="linux"
        ;;
    "Darwin"|"darwin")
        KERNEL="darwin"
        ;;
    *)
        output "OS '${KERNEL}' not supported" "error"
        exit 1
        ;;
esac

MACHINE=$(uname -m 2>/dev/null || /usr/bin/uname -m)
case ${MACHINE} in
    arm|armv7*)
        MACHINE="arm"
        ;;
    aarch64*|armv8*|arm64)
        MACHINE="arm64"
        ;;
    i[36]86)
        MACHINE="386"
        if [ "darwin" = "${KERNEL}" ]; then
            output "  [ ] Your architecture (${MACHINE}) is not supported anymore" "error"
            exit 1
        fi
        ;;
    x86_64)
        MACHINE="amd64"
        ;;
    *)
        output "  [ ] Your architecture (${MACHINE}) is not currently supported" "error"
        exit 1
        ;;
esac

BINNAME="${BINNAME:-yo}"
BINDIR="${BINDIR:-/usr/local/bin}"
URL="https://github.com/$REPOOWNER/$REPONAME/releases/download/${RELEASETAG}/yo_${RELEASETAG}_${KERNEL}_${MACHINE}.tar.gz"

echo "Downloading from $URL"
echo

curl -q --fail --location --progress-bar --output "yo_${RELEASETAG}_${KERNEL}_${MACHINE}.tar.gz" "$URL"
tar xzf "yo_${RELEASETAG}_${KERNEL}_${MACHINE}.tar.gz"
chmod +x $BINNAME
sudo mv $BINNAME $BINDIR/$BINNAME
rm "yo_${RELEASETAG}_${KERNEL}_${MACHINE}.tar.gz"

echo
echo "Installation of version $RELEASETAG complete!"