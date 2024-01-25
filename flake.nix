{
  description = "MUMPS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    mumps-src = {
      url = "https://mumps-solver.org/MUMPS_5.6.2.tar.gz";
      flake = false;
    };
  };

  outputs = inputs@{ flake-parts, mumps-src, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let deps = with pkgs; [ cmake gfortran openmpi lapack lapack.dev scalapack scalapack.dev ]; in {
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = deps;
          };
          packages = rec {
            mumps = pkgs.stdenv.mkDerivation {
              name = "mumps";
              src = ./.;
              outputs = [ "out"];
              nativeBuildInputs = deps;
              patchPhase = ''
                rm -fr build/mumps_src 
                mkdir -p build/mumps_src
                cp --dereference --no-preserve=mode,ownership --recursive --force ${mumps-src}/** build/mumps_src/
              '';

              buildInputs = deps;
              cmakeFlags = [
                "-D LAPACK_ROOT=${pkgs.lapack}"
                "-D SCALAPACK_ROOT=${pkgs.scalapack}"
                "-D FETCHCONTENT_SOURCE_DIR_MUMPS=mumps_src"
                "-D MUMPS_UPSTREAM_VERSION=5.6.2"
                "-D BUILD_DOUBLE=on"
                "-D parallel=true"
                "-D intsize64=off"
              ];
              doCheck = false;
              preInstall = ''
                mkdir --parents $out/include
                cp --recursive cmake $out/include
              '';
            };
            default = mumps;
            build = pkgs.writeShellApplication {
              name = "default";

              runtimeInputs = deps;
              text = ''
                rm -fr mumps_src 
                mkdir mumps_src
                cp --dereference --no-preserve=mode,ownership --recursive --force ${mumps-src}/** mumps_src/
                cmake build -B build . -D LAPACK_ROOT="${pkgs.lapack}" -D SCALAPACK_ROOT="${pkgs.scalapack}" -D FETCHCONTENT_SOURCE_DIR_MUMPS=mumps_src -D intsize64=on -D BUILD_DOUBLE=on -D parallel=true -D MUMPS_UPSTREAM_VERSION=5.6.2                 
                cd build
                cmake --build .
              '';
            };
          };
        };
    };
}
