{ callPackage, ... }@args:

callPackage ./generic.nix (
  args
  // rec {
    brand = "Behringer";
    type = "WING";
    version = "3.3.1";

    url = "https://cdn.mediavalet.com/aunsw/musictribe/cOBFJrXte0GPqwr6AfER2A/iwlHH7bEXE-X1AreNHQLvg/Original/Wing-Edit_LINUX_${version}.tar.gz";
    hash = "sha256-mcoIFTE9xm2XCaStUdP9HLZX//nGN6YAB9z8DZ9rqfU=";
    homepage = "https://www.behringer.com/wing/wing-rack.html";
  }
)
