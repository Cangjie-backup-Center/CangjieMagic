#!/bin/bash

function clone_cangjie_magic() {
    # Check if the directory already exists
    if [ -d "./CangjieMagic" ]; then
        echo "CangjieMagic directory already exists. Skipping clone."
        return
    fi

    # Clone the repository
    echo "Cloning CangjieMagic repository..."
    git clone https://gitcode.com/Cangjie-TPC/CangjieMagic.git --branch dev --depth 1

    # Check if the clone was successful
    if [ $? -ne 0 ]; then
        echo "Error: Failed to clone CangjieMagic repository" >&2
        exit 1
    fi

    echo "CangjieMagic repository cloned successfully."
}

function download_cangjie_stdx() {
    # Determine the current OS type
    OS="unknown"
    case "$(uname -s)" in
        Linux)     OS="linux" ;;
        Darwin)    OS="mac" ;;
        *)         echo "Unknown OS"; exit 1 ;;
    esac

    # Detect CPU architecture (x64 or aarch64)
    ARCH="unknown"
    case "$(uname -m)" in
        x86_64)    ARCH="x64" ;;
        aarch64)   ARCH="aarch64" ;;
        arm64)     ARCH="aarch64" ;;  # macOS reports ARM64 as "arm64"
        *)         echo "Unsupported CPU architecture"; exit 1 ;;
    esac

    VERSION="1.0.0.1"

    # Construct the download URL
    URL="https://gitcode.com/Cangjie/cangjie-stdx/releases/download/v${VERSION}/cangjie-stdx-${OS}-${ARCH}-${VERSION}.zip"

    # Create target directories if they don't exist
    INSTALL_DIR="./CangjieMagic/libs"
    TARGET_DIR="${INSTALL_DIR}/cangjie-stdx-${OS}-${ARCH}-${VERSION}"

    mkdir -p "${INSTALL_DIR}"

    # Download the file
    echo "Downloading from ${URL}..."
    ZIP_FILE="${INSTALL_DIR}/cangjie-stdx-${OS}-${ARCH}-${VERSION}.zip"

    if command -v curl &> /dev/null; then
        curl -L -o "${ZIP_FILE}" "${URL}"
    elif command -v wget &> /dev/null; then
        wget -O "${ZIP_FILE}" "${URL}"
    else
        echo "Error: Neither curl nor wget found" >&2
        exit 1
    fi

    # Verify download succeeded
    if [ ! -f "${ZIP_FILE}" ]; then
        echo "Error: Download failed" >&2
        exit 1
    fi

    # Create target directory and extract files
    echo "Extracting ${ZIP_FILE} to ${TARGET_DIR}..."
    mkdir -p "${TARGET_DIR}"
    if command -v unzip &> /dev/null; then
        unzip -q "${ZIP_FILE}" -d "${TARGET_DIR}"
    else
        echo "Error: unzip command not found" >&2
        exit 1
    fi

    # Verify extraction succeeded
    if [ ! -d "${TARGET_DIR}" ]; then
        echo "Error: Extraction failed" >&2
        exit 1
    fi

    # Remove temporary files (optional)
    # rm -f "${ZIP_FILE}"

    echo "Download complete! Files are now in ${TARGET_DIR}"
}

function set_toml() {
    # Extract platform information from cjc -v output and store in PLATFORM variable
    PLATFORM=$(cjc -v | grep "Target:" | awk '{print $2}')
    # Verify if PLATFORM was successfully extracted
    if [ -z "$PLATFORM" ]; then
        echo "Error: Failed to extract PLATFORM from cjc -v output"
        exit 1
    fi

    # Find the stdx directory and normalize the path
    STDX_PATH=$(find ./CangjieMagic -type d -name stdx | head -n 1)
    # Convert to relative path starting with ./libs/
    REL_STDX_PATH=$(echo "$STDX_PATH" | sed -E 's/^\.\/CangjieMagic\/(.+)$/\.\/\1/')

    # Content to be appended to the TOML file
    CONTENT="[target.${PLATFORM}.bin-dependencies]\n  path-option = [\"${REL_STDX_PATH}\"]"

    # Check if content already exists in the file
    if ! grep -q "^[^#]*${REL_STDX_PATH}" "./CangjieMagic/cjpm.toml"; then
        echo -e "\n${CONTENT}" >> "./CangjieMagic/cjpm.toml"
        echo "Successfully change ./CangjieMagic/cjpm.toml"
    else
        echo "Notice: Configuration for ${PLATFORM} already exists in ./CangjieMagic/cjpm.toml - no changes made"
    fi

    # Get the absolute path to ./CangjieMagic
    cangjieMagicPath=$(realpath "./CangjieMagic")
    echo ""
    echo "Now, add the following config to your project:"
    echo ""
    echo "[dependencies]"
    echo "  magic = { path = \"$cangjieMagicPath\" }"
}

clone_cangjie_magic

download_cangjie_stdx

set_toml
