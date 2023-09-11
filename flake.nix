{
  inputs.nixpkgs.url = github:nixOS/nixpkgs/nixos-unstable;

  inputs.mseed2sac.url = github:iris-edu/mseed2sac/v2.3;
  inputs.mseed2sac.flake = false;

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;

      hypoel = pkgs.stdenv.mkDerivation {
        pname = "hypoel";
        version = "0.0.0-old";
        buildInputs = with pkgs; [ gfortran ];
        nativeBuildInputs = with pkgs; [ glibc.static ];
        src = ./hypoellipse/source;
        installPhase = ''
          mkdir -p $out/bin
          cp Hypoel $out/bin/hypoel
        '';
      };

      mseed2sac = pkgs.stdenv.mkDerivation {
        pname = "mseed2sac";
        version = "2.3";
        src = inputs.mseed2sac;
        nativeBuildInputs = with pkgs; [ zlib ];
        installPhase = ''
          mkdir -p $out/bin
          cp mseed2sac $out/bin/mseed2sac
        '';
      };
    in
    with lib; {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # List packages needed here
          hypoel
          mseed2sac
          ## For compiling hypoellipse
          gfortran
          gnumake
          glibc.static

          # For scripts I guess
          fish

          # You need chromedriver?
          chromedriver
          chromium

          ## For running the jupyter notebook
          (python3.withPackages (p: with p; [
            # Python packages here
            jupyter
            ipython

            obspy
            pandas
            numpy
            selenium
            beautifulsoup4
            requests
          ]))
        ];
      };
    };
}
