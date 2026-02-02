{
  stdenv,
  fetchurl,
  lib,
  brand,
  type,
  version,
  homepage,
  url,
  hash,
  runCommand,
  dpkg,
  vmTools,
  runtimeShell,
  bubblewrap,
  ...
}:
let
  debian =
    let
      debs = lib.flatten (import ./deps.nix { inherit fetchurl; });
    in
    runCommand "x32edit-debian" { nativeBuildInputs = [ dpkg ]; } (
      lib.concatMapStringsSep "\n" (deb: ''
        dpkg-deb -x ${deb} $out
      '') debs
    );
in
stdenv.mkDerivation (finalAttrs: {
  pname = "${lib.toLower type}-edit";
  inherit version;

  src = fetchurl {
    inherit url hash;
  };

  sourceRoot = ".";
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
      mkdir -p "$out/bin"

      # Original-Binary aus dem Tarball installieren (liegt laut Log als ./WING-Edit vor)
      install -m755 "${type}-Edit" "$out/bin/.${pname}"

      # Wrapper erzeugen (ohne $out zur Laufzeit)
      cat >"$out/bin/${pname}" <<'EOF'
    #!${runtimeShell} -eu

    # Pfad zum "hidden" Binary neben dem Wrapper
    DIR="$(cd -- "$(dirname -- "$0")" && pwd)"

    # Runtime vars (Wayland/X11) – Nix-Interpolation vermeiden mit ''${...}
    if [ -z "''${XDG_RUNTIME_DIR:-}" ]; then
      XDG_RUNTIME_DIR="/run/user/$(id -u)"
    fi

    exec ${lib.getExe bubblewrap} \
      --proc /proc \
      --dev /dev \
      --dev-bind /dev/snd /dev/snd \
      --dev-bind /dev/bus/usb /dev/bus/usb \
      --ro-bind /nix /nix \
      --ro-bind /etc /etc \
      --bind /run /run \
      --tmpfs /tmp \
      \
      --dir /lib \
      --dir /lib64 \
      --dir /usr \
      --dir /usr/lib \
      --dir /usr/share \
      \
      --ro-bind "${debian}/lib" /lib \
      --ro-bind "${debian}/lib64" /lib64 \
      --ro-bind "${debian}/usr/lib" /usr/lib \
      --ro-bind "${debian}/usr/share" /usr/share \
      \
      --bind "''${XDG_RUNTIME_DIR}" "''${XDG_RUNTIME_DIR}" \
      --bind-try /tmp/.X11-unix /tmp/.X11-unix \
      --bind "''${HOME}" "''${HOME}" \
      --chdir "''${PWD}" \
      "$DIR/.${pname}"
    EOF

      chmod 755 "$out/bin/${pname}"
  '';

  passthru.deps =
    let
      distro = vmTools.debDistros.debian12x86_64;
    in
    vmTools.debClosureGenerator {
      name = "x32edit-dependencies";
      inherit (distro) urlPrefix;
      packagesLists = [ distro.packagesLists ];
      packages = [
        "libstdc++6"
        "libcurl4"
        "libfreetype6"
        "libasound2"
        "libx11-6"
        "libxext6"
      ];
    };

  meta = {
    inherit homepage;
    description = "Editor for the ${brand} ${type} digital mixer";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ magnetophon ];
  };
})
