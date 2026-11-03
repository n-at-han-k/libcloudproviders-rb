{
  description = "libcloudproviders — provider and collector examples";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, utils, ... }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Introspection bindings, so the libraries and their typelibs have to be
        # found at runtime as well as at build time. libcloudproviders is here for
        # CloudProviders-0.3.typelib, which is the whole point: the gem compiles
        # nothing and reads that.
        giStack = with pkgs; [
          glib
          gobject-introspection
          libcloudproviders
        ];

        # The pkg-config gem resolves Requires.private transitively and hard-fails
        # on any missing .pc, so glib's private closure has to be here too, or
        # gio2's extconf dies in required_pkg_config_package before anything is
        # compiled.
        privateClosure = with pkgs; [
          pcre2 util-linux libffi libxml2 zlib libselinux libsepol
          libgcrypt libgpg-error xz zstd libsysprof-capture
        ];

        # nixpkgs' defaultGemConfig carries no build inputs for these, so they
        # get them here or they fail to compile their extensions.
        rubyGnomeGem = _attrs: {
          nativeBuildInputs = [ pkgs.pkg-config ];
          buildInputs = giStack ++ privateClosure;
        };

        gems = pkgs.bundlerEnv {
          name = "libcloudproviders-examples-gems";
          ruby = pkgs.ruby_3_4;
          gemfile = ./Gemfile;
          lockfile = ./Gemfile.lock;
          gemset = import ./gemset.nix;

          gemConfig = pkgs.defaultGemConfig // {
            glib2 = rubyGnomeGem;
            gio2 = rubyGnomeGem;
            gobject-introspection = rubyGnomeGem;
          };
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [ gems gems.wrappedRuby ] ++ giStack;

          shellHook = /* bash */ ''
            # glib's first output is `bin`, which carries no typelibs, so
            # makeSearchPath over the derivations themselves finds nothing and
            # gio2 dies on "Typelib file for namespace 'Gio' not found". Hence
            # `.out`.
            export GI_TYPELIB_PATH="${pkgs.lib.makeSearchPath "lib/girepository-1.0" (map (drv: drv.out or drv) giStack)}"
            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath (map (drv: drv.out or drv) giStack)}''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

            # `require "libcloudproviders"` from the repository's own lib, so the
            # examples exercise the working tree. The gem is pure ruby, so there
            # is nothing to compile first.
            root="$(cd "$PWD/.." && pwd)"
            export RUBYLIB="$root/lib''${RUBYLIB:+:$RUBYLIB}"

            export BUNDLE_GEMFILE="$PWD/Gemfile"
            export BUNDLE_FROZEN=false

            echo "libcloudproviders examples."
            echo "  ruby examples/export_provider.rb   # the sync client's side"
            echo "  ruby examples/list_providers.rb    # the file manager's side"
            echo "Run the exporter first; it prints the XDG_DATA_DIRS the lister needs."
          '';
        };
      }
    );
}
