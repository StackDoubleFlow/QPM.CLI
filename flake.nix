{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };
  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          overlays = [ (import rust-overlay) ];
          pkgs = import nixpkgs {
            inherit system overlays;
          };
          rustToolchain = pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
          nativeBuildInputs = with pkgs; [
            rustToolchain pkg-config
          ];
          buildInputs = with pkgs; [
            openssl
          ];
        in
        with pkgs;
        {
          devShells.default = mkShell {
	          inherit buildInputs nativeBuildInputs;
            LD_LIBRARY_PATH = lib.makeLibraryPath buildInputs;
          };
          packages.default = pkgs.rustPlatform.buildRustPackage {
            pname = "qpm";
            version = "0.1.0";
            src = ./.;

            cargoLock = {
              lockFile = ./Cargo.lock;
              outputHashes = {
                "cursed-semver-parser-0.1.0" = "sha256-T1nXjKpAJtAikJOJwI3+t+beP7iVzSnoIBkYkA1UZx0=";
                "qpm_arg_tokenizer-0.1.0" = "sha256-1bYxmEYfWuWSNPs7TvutNxMjB44ITOtkaM2KvzND/d0=";
                "qpm_package-0.4.0" = "sha256-dz2NqHtqyK7PvrpBNGy8paPqWm+/LJSYF4o93qEg+9k=";
                "qpm_qmod-0.1.0" = "sha256-kFzj8odyXDnHFXPWN9EHBS0g7W1Hb3mcz085E0SWFYw=";
                "templatr-0.1.0" = "sha256-aaPV2HACXpvxPIEsUtf4ob/WtSxtlflgZG/lXvP6axM=";
              };
            };

            # The tests depend on network stuff (rip purity)
            doCheck = false;

            nativeBuildInputs = [ rustToolchain pkgs.pkg-config ];
            PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
          };
        }
      );
}
