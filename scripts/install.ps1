#!/usr/bin/env pwsh

function Clone-CangjieMagic {
    # Check if the directory already exists
    if (Test-Path "./CangjieMagic") {
        Write-Host "CangjieMagic directory already exists. Skipping clone."
        return
    }

    # Clone the repository
    Write-Host "Cloning CangjieMagic repository..."
    git clone https://gitcode.com/Cangjie-TPC/CangjieMagic.git --branch dev --depth 1

    # Check if the clone was successful
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Error: Failed to clone CangjieMagic repository"
        exit 1
    }

    Write-Host "CangjieMagic repository cloned successfully."
}

function Download-CangjieStdx {
    # Determine the current OS type
    $OS = "windows"

    # Define version
    $VERSION = "1.0.0.1"

    # Construct download URL
    $URL = "https://gitcode.com/Cangjie/cangjie-stdx/releases/download/v1.0.0.1/cangjie-stdx-${OS}-x64-${VERSION}.zip"

    # Create target directories if they don't exist
    $INSTALL_DIR = "./CangjieMagic/libs"
    $TARGET_DIR = "$INSTALL_DIR/cangjie-stdx-${OS}-x64-${VERSION}"

    if (!(Test-Path $INSTALL_DIR)) {
        New-Item -ItemType Directory -Path $INSTALL_DIR | Out-Null
    }

    # Download the file
    Write-Host "Downloading from ${URL}..."
    $ZIP_FILE = "$INSTALL_DIR/cangjie-stdx-${OS}-x64-${VERSION}.zip"

    try {
        Invoke-WebRequest -Uri $URL -OutFile $ZIP_FILE
    }
    catch {
        Write-Error "Error: Failed to download file"
        exit 1
    }

    # Verify download succeeded
    if (!(Test-Path $ZIP_FILE)) {
        Write-Error "Error: Download failed"
        exit 1
    }

    # Create target directory and extract files
    Write-Host "Extracting ${ZIP_FILE} to ${TARGET_DIR}..."
    if (!(Test-Path $TARGET_DIR)) {
        New-Item -ItemType Directory -Path $TARGET_DIR | Out-Null
    }

    try {
        Expand-Archive -Path $ZIP_FILE -DestinationPath $TARGET_DIR -Force
    }
    catch {
        Write-Error "Error: Failed to extract archive"
        exit 1
    }

    # Verify extraction succeeded
    if (!(Test-Path $TARGET_DIR)) {
        Write-Error "Error: Extraction failed"
        exit 1
    }

    # Remove temporary files (optional)
    # Remove-Item -Path $ZIP_FILE -Force

    Write-Host "Download complete! Files are now in ${TARGET_DIR}"
}

function Set-Toml {
    # Extract platform information from cjc -v output
    try {
        $PLATFORM = (& cjc -v | Select-String -Pattern "Target:" | ForEach-Object { $_ -split "\s+" })[1]
    }
    catch {
        Write-Error "Error: Failed to execute cjc -v"
        exit 1
    }
    
    if ([string]::IsNullOrEmpty($PLATFORM)) {
        Write-Error "Error: Failed to extract PLATFORM from cjc -v output"
        exit 1
    }

    # Find the stdx directory and normalize the path
    $STDX_PATH = Get-ChildItem -Path ./CangjieMagic -Directory -Recurse -Filter "stdx" | Select-Object -First 1 -ExpandProperty FullName
    if (!$STDX_PATH) {
        Write-Error "Error: stdx directory not found"
        exit 1
    }

    # Convert to relative path starting with ./libs/
    $REL_STDX_PATH = ($STDX_PATH -replace "^.*CangjieMagic[\\/]", "./").Replace("\", "/")

    # Content to be appended to the TOML file
    $CONTENT = "[target.${PLATFORM}.bin-dependencies]`n  path-option = [`"${REL_STDX_PATH}`"]"

    $tomlPath = "./CangjieMagic/cjpm.toml"
    Add-Content -Path $tomlPath -Value "`n${CONTENT}"
    Write-Host "Successfully change ./CangjieMagic/cjpm.toml"

    $cangjieMagicPath = Resolve-Path -Path "./CangjieMagic"

    Write-Host ""
    Write-Host "Now, add the following config to your project:"
    Write-Host ""
    Write-Host "[dependencies]"
    Write-Host "  magic = { path = "${cangjieMagicPath}" }"
}

Main execution
Clone-CangjieMagic
Download-CangjieStdx
Set-Toml
