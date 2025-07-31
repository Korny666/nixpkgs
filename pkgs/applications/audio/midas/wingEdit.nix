{ callPackage, ... }@args:

callPackage ./generic.nix (
  args
  // rec {
    brand = "Behringer";
    type = "WING";
    version = "3.2.1";
    url = "https://cdn.mediavalet.com/aunsw/musictribe/12irYFvmhkKYvUwtSHH5Vg/wIh7eO1brkmWNwHE6O3WwA/Original/${type}-Edit_LINUX_${version}.tar.gz";
    hash = "sha256-ZrndzHomr8nY/FNMq+ZdjTzZA8hYflytgLA3em+P3XA=";
    homepage = "https://www.behringer.com/wing/wing-rack.html";
  }
)
