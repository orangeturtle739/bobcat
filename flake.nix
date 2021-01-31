{
  description = "Bobcat keyboard layout";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
  inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.qmk-compile-nix = {
    # url = "git+file:/home/jacob/Documents/MyStuff/projects/qmk-compile-nix";
    url = "github:orangeturtle739/qmk-compile-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils, qmk-compile-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        qmk = pkgs.fetchFromGitHub {
          owner = "zsa";
          repo = "qmk_firmware";
          rev = "ec2a7452fcbe47078a20cb095fb8a77e26cdc6f5";
          sha256 = "WGABahZ/i+vMNclYe7AXRmP5D7vEoDQdgPBRVK7KwF0=";
          fetchSubmodules = true;
        };
        unstable-pkgs = nixpkgs-unstable.legacyPackages.${system};
        wally = unstable-pkgs.wally-cli;
      in rec {
        defaultPackage = qmk-compile-nix.lib.mkKeyboardFirmware {
          inherit qmk system;
          keyboard = "ergodox_ez";
          firmware = "${self}";
          name = "bobcat";
        };
        packages.wally-cli = wally;
        defaultApp = {
          type = "app";
          program = let
            flasher = pkgs.writeScript "flash" ''
              ${wally}/bin/wally-cli ${defaultPackage}
            '';
          in "${flasher}";
        };
      });
}
