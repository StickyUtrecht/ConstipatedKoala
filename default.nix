{ pkgs ? import <nixpkgs> {} }:
let
  gems = pkgs.bundlerEnv {
    name = "koala";
    ruby = pkgs.ruby;
    gemdir = ./.;
  };
in
  pkgs.stdenv.mkDerivation {
    name = "koala";
    buildInputs = [
      gems
      pkgs.yarn2nix
      pkgs.nodejs
      pkgs.ruby
      pkgs.yarn
      pkgs.curl
      pkgs.imagemagick
      pkgs.ghostscript
      pkgs.bundler
      pkgs.mupdf
    ];
    installPhase = ''
      cp -r $src $out
    '';
  }
