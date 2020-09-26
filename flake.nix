{
  description = "Bobcat keyboard layout";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.03";
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
          rev = "86fc93a8b47ca59a16850b7c2b68b220fb4776d0";
          sha256 = "tlWBOKS4JtOv+VJNp3+9s+kPjLzOO8NsVHCgN+ykYqA=";
          fetchSubmodules = true;
        };
      in { defaultPackage = qmk-compile-nix.lib.mkKeyboardFirmware {
        inherit qmk system;
        keyboard = "ergodox_ez";
        firmware = "${self}";
        name = "bobcat";
      }; });
}
