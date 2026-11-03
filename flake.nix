{
  description = "libcloudproviders — Ruby bindings";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    mine.url = "github:n-at-han-k/flake.nix";
    mine.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, mine, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = mine.lib.${system};

        gemspecFiles = pkgs.runCommand "libcloudproviders-gemspec" { } ''
          mkdir -p $out/lib/libcloudproviders
          cp ${./libcloudproviders.gemspec}         $out/libcloudproviders.gemspec
          cp ${./lib/libcloudproviders/version.rb}  $out/lib/libcloudproviders/version.rb
        '';

        gems = pkgs.bundlerEnv {
          name = "libcloudproviders-gems";
          ruby = pkgs.ruby_3_4;
          gemfile = ./Gemfile;
          lockfile = ./Gemfile.lock;
          gemset = import ./gemset.nix;
          extraConfigPaths = [ "${gemspecFiles}/." ];
        };

        # The namespaces the loader needs at require time: CloudProviders itself, and
        # Gio/GLib/GObject which CloudProviders-0.3.typelib declares as dependencies and
        # the loader resolves transitively.
        #
        # `makeSearchPath` would take each package's *first* output, and glib's
        # first output is `bin`, which carries no typelibs -- hence the explicit
        # `.out`. This is the same trap the port scaffold documents.
        typelibPath = pkgs.lib.makeSearchPath "lib/girepository-1.0"
          (map (drv: drv.out or drv) [ pkgs.libcloudproviders pkgs.glib ]);
      in
      {
        devShells.default = lib.mkRubyShell {
          buildInputs = with pkgs; [
            gems
            gems.wrappedRuby

            # libcloudproviders itself, for its typelib. Taking it from the same
            # nixpkgs as the gobject-introspection gem is not a tidiness
            # point: a typelib built against a different glib registers GIO a
            # second time in the process and dies with
            #   cannot register existing type 'GTlsCertificate'
            libcloudproviders

            skywalking-eyes
          ];

          shellHook = /* bash */ ''
            # CloudProviders-0.3.typelib and the typelibs it declares, which the loader
            # resolves transitively at require time. A missing one surfaces as
            # "Typelib file for namespace 'X' not found", one at a time.
            export GI_TYPELIB_PATH="${typelibPath}''${GI_TYPELIB_PATH:+:$GI_TYPELIB_PATH}"

            export BUNDLE_GEMFILE="$PWD/Gemfile"
            export BUNDLE_FROZEN=false

            export LANG="''${LANG:-C.UTF-8}"
            export LC_ALL="''${LC_ALL:-$LANG}"

            export RUBYLIB="$PWD/lib''${RUBYLIB:+:$RUBYLIB}"
          '';
        };
      }
    );
}
