with import <nixpkgs> {};
callPackage ./package.nix {
  gcr = callPackage ./gcr.nix { };
  webkitgtk = callPackage ./webkitgtk.nix {
    harfbuzz = harfbuzzFull;
    inherit (gst_all_1) gst-plugins-base gst-plugins-bad;
    inherit (darwin) apple_sdk;
  };
}
