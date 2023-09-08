{
  inputs.nixpkgs.url = github:nixOS/nixpkgs/nixos-unstable;

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
    in
    with lib; {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          # List packages needed here
          ## For compiling hypoellipse
          gfortran
          gnumake
          glibc.static

          # You need chromedriver?
          chromedriver

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