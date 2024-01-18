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

      python3 = pkgs.python3.override {
        packageOverrides = final: prev: {
          noisepy-seis = final.buildPythonPackage rec {
            pname = "noisepy_seis";
            version = "0.9.84";
            format = "pyproject";
            pythonRelaxDeps = true;
            pythonRemoveDeps = [ "pycwt" ];
            src = pkgs.fetchPypi {
              inherit pname version;
              hash = "sha256-CYE+SMm6U0MD3zHvrL3/Dmyjg2FNARgqnNzrhIUhEYw=";
            };
            doCheck = false;
            nativeBuildInputs = with final; [
              hatchling
              hatch-vcs
              pythonRelaxDepsHook
            ];
            propagatedBuildInputs = with final; [
              aiobotocore
              datetimerange
              diskcache
              fsspec
              h5py
              numba
              numpy
              pandas
              psutil
              pyasdf
              pycwt
              pydantic-yaml
              pydantic
              pyyaml
              s3fs
              zarr
            ];
          };

          datetimerange = final.buildPythonPackage rec {
            pname = "DateTimeRange";
            version = "2.2.0";
            format = "pyproject";
            src = pkgs.fetchPypi {
              inherit pname version;
              hash = "sha256-Bx6dyJxuRMNEzSUaF4kQ+wXI30I9HGvTNX4ylv57LZc=";
            };
            doCheck = false;
            propagatedBuildInputs = with final; [
              setuptools
              setuptools-scm

              dateutils
              typepy
            ];
          };

          pycwt = final.buildPythonPackage rec {
            pname = "pycwt";
            version = "0.3.0a22";
            format = "pyproject";
            src = pkgs.fetchPypi {
              inherit pname version;
              hash = "sha256-+ZZo7yyvjVAg72vLvMhu5ULQOK58Xh6A2hLlJkRF6xc=";
            };
            doCheck = false;
            nativeBuildInputs = with final; [
              setuptools
              setuptools-scm
            ];
            propagatedBuildInputs = with final; [
              numpy
              scipy
              matplotlib
              tqdm
            ];
          };

          pydantic-yaml = final.buildPythonPackage rec {
            pname = "pydantic_yaml";
            version = "1.2.0";
            format = "pyproject";
            src = pkgs.fetchPypi {
              inherit pname version;
              hash = "sha256-VL2vTaJbypW7m6eQsaXGtLPpP3zyGPzeRrMHO2F3n4E=";
            };
            pythonRelaxDeps = true;
            doCheck = false;
            nativeBuildInputs = with final; [
              setuptools
              setuptools-scm
              importlib-metadata
              pythonRelaxDepsHook
            ];
            propagatedBuildInputs = with final; [
              pydantic
              ruamel-yaml
            ];
          };

          pyasdf = final.buildPythonPackage rec {
            pname = "pyasdf";
            version = "0.8.1";
            format = "pyproject";
            src = pkgs.fetchPypi {
              inherit pname version;
              hash = "sha256-O5/2AB72PsS6x30/a2E/PYKagNVsiE9Zs1rq3dnk3BI=";
            };
            doCheck = false;
            propagatedBuildInputs = with final; [
              setuptools
              setuptools-scm

              colorama
              dill
              h5py
              numpy
              obspy
              prov
            ];
          };
        };
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
            (
              # From https://discourse.nixos.org/t/how-to-fix-selenium-python-package-locally/23660/4
              p.selenium.overridePythonAttrs
                (old: {
                  src = pkgs.fetchFromGitHub {
                    owner = "SeleniumHQ";
                    repo = "selenium";
                    rev = "refs/tags/selenium-4.8.0";
                    hash = "sha256-YTi6SNtTWuEPlQ3PTeis9osvtnWmZ7SRQbne9fefdco=";
                  };
                  postInstall = ''
                    install -Dm 755 ../rb/lib/selenium/webdriver/atoms/getAttribute.js $out/${pkgs.python3Packages.python.sitePackages}/selenium/webdriver/remote/getAttribute.js
                    install -Dm 755 ../rb/lib/selenium/webdriver/atoms/isDisplayed.js $out/${pkgs.python3Packages.python.sitePackages}/selenium/webdriver/remote/isDisplayed.js
                  '';
                })
            )
            beautifulsoup4
            requests

            noisepy-seis
          ]))
        ];
      };
    };
}
