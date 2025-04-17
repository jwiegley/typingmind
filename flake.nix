{
  description = "TypingMind self-hosted server";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in rec {
        flakedPkgs = pkgs;

        # enables use of `nix shell`
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [ pkgs.nodejs ];
        };

        # package with script that runs npm start and npx https-proxy
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "typingmind-server";
          version = "0.1.0";

          src = ./.;

          buildInputs = [ pkgs.nodejs ];

          installPhase = ''
            mkdir -p $out/bin

            # Create a script to run the server with proxy
            cat > $out/bin/start-server-with-proxy <<EOF
            #!${pkgs.stdenv.shell}
            export PATH=$out/bin:$PATH

            # Start the Node.js server
            npm install

            (npx local-ssl-proxy --source 3443 --target 3000 &)

            # Run your server
            npm run start
            EOF

            chmod +x $out/bin/start-server-with-proxy
          '';

          meta = with pkgs.lib; {
            description = "TypingMind self-hosted server with HTTPS proxy support";
            licenses = [ licenses.mit ];
          };
        };
      }
    );
}
