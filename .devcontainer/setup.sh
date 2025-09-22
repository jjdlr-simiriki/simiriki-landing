#!/usr/bin/env bash
set -euo pipefail

echo "Installing Azure Functions Core Tools..."
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" > /etc/apt/sources.list.d/microsoft-prod.list'
rm microsoft.gpg
sudo apt-get update -y
sudo apt-get install -y azure-functions-core-tools-4
echo "Done."

