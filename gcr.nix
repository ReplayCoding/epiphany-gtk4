{ lib, stdenv
, fetchurl
, fetchpatch
, pkg-config
, meson
, ninja
, gettext
, gnupg
, p11-kit
, glib
, libgcrypt
, libtasn1
, gtk4
, libadwaita
, libportal-gtk4
, libsoup
, pango
, libsecret
, openssh
, systemd
, gobject-introspection
, wrapGAppsHook
, libxslt
, vala
, gnome
, python3
, shared-mime-info
}:

stdenv.mkDerivation rec {
  pname = "gcr-4-gtk4";
  version = "5924eced679b3a2caea2fd4637e52b85c85f6f0c";

  src = fetchurl {
    url = "https://gitlab.gnome.org/GNOME/gcr/-/archive/${version}/gcr-${version}.tar";
    sha256 = "sha256-7LDmthYXqvpz43h4pbBsFbfWX2QDwEIl5W7Vp8MtFrc=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    python3
    ninja
    gettext
    gobject-introspection
    libxslt
    wrapGAppsHook
    vala
    shared-mime-info
  ];

  buildInputs = [
    gnupg
    libgcrypt
    libtasn1
    pango
    libsecret
    openssh
    systemd
    libadwaita
    libportal-gtk4
    libsoup
  ];

  propagatedBuildInputs = [
    glib
    gtk4
    p11-kit
  ];

  checkInputs = [
    python3
  ];

  mesonFlags = [
    "-Dgtk_doc=false"
    "-Dgtk3=false"
    # We are still using ssh-agent from gnome-keyring.
    # https://github.com/NixOS/nixpkgs/issues/140824
    "-Dssh_agent=false"
  ];

  doCheck = false; # fails 21 out of 603 tests, needs dbus daemon

  PKG_CONFIG_SYSTEMD_SYSTEMDUSERUNITDIR = "${placeholder "out"}/lib/systemd/user";

  postPatch = ''
    patchShebangs build/ gcr/fixtures/
    chmod +x meson_post_install.py
    patchShebangs meson_post_install.py
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = pname;
    };
  };

  meta = with lib; {
    platforms = platforms.unix;
    maintainers = teams.gnome.members;
    description = "GNOME crypto services (daemon and tools)";
    homepage = "https://gitlab.gnome.org/GNOME/gcr";
    license = licenses.lgpl2Plus;

    longDescription = ''
      GCR is a library for displaying certificates, and crypto UI, accessing
      key stores. It also provides the viewer for crypto files on the GNOME
      desktop.
      GCK is a library for accessing PKCS#11 modules like smart cards, in a
      (G)object oriented way.
    '';
  };
}

