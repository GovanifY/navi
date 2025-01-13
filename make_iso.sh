#!/bin/sh
nix-shell -p nixos-generators --run "nixos-generate --format iso --configuration ./iso.nix -o navi-iso"
