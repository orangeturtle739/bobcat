{
  description = "Bobcat keyboard layout";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.11";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.qmk-compile-nix = {
    # url = "git+file:/home/jacob/Documents/MyStuff/projects/qmk-compile-nix";
    url = "github:orangeturtle739/qmk-compile-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, qmk-compile-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        qmk = pkgs.fetchFromGitHub {
          owner = "zsa";
          repo = "qmk_firmware";
          # firmware22 branch
          # rev = "cf87d88fb228d9118480a98c909508adacb64f26";
          # sha256 = "pHlne7ZcXBI5ILIlnDH2JdUZMd6TlehaNwHz/cpE6x0=";

          rev = "ec2a7452fcbe47078a20cb095fb8a77e26cdc6f5";
          sha256 = "WGABahZ/i+vMNclYe7AXRmP5D7vEoDQdgPBRVK7KwF0=";

          fetchSubmodules = true;
        };
        wally = pkgs.wally-cli;
      in rec {
        packages = {
          default = qmk-compile-nix.lib.mkKeyboardFirmware {
            inherit qmk system;
            keyboard = "ergodox_ez";
            firmware = "${self}";
            name = "bobcat";
          };
          wally-cli = wally;
        };
        apps.default = {
          type = "app";
          program = let
            flasher = pkgs.writeScript "flash" ''
              ${wally}/bin/wally-cli ${packages.default}
            '';
          in "${flasher}";
        };
      });
}
