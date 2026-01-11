{
  description = "Gleam/Lustre web application development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Gleam toolchain
            gleam
            erlang
            rebar3
            
            # Node.js for frontend tooling
            nodejs_20
            
            # Optional but useful
            git
            watchexec  # For file watching during development
          ];

          shellHook = ''
            echo "Gleam/Lustre development environment loaded"
            echo "Gleam version: $(gleam --version)"
            echo "Erlang version: $(erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell)"
            echo "Node version: $(node --version)"
            echo ""
            echo "To create a new Lustre project:"
            echo "  gleam new my_app"
            echo "  cd my_app"
            echo "  gleam add lustre lustre_dev_tools"
            echo ""
            echo "To run the dev server:"
            echo "  gleam run -m lustre/dev start"
          '';
        };
      }
    );
}
