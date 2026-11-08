{
  inputs,
  nixpkgs,
  self,
  ...
}:
let
  sharedOSModules = [
    ../os
    ../nix
    inputs.stylix.nixosModules.stylix
    inputs.niri.nixosModules.niri
    inputs.linuxqq-wayland-fix.nixosModules.default
  ];

  sharedHomeModules = [
    ../home
    ../nix/nixpkgs.nix
    inputs.stylix.homeModules.stylix
    inputs.niri.homeModules.niri
    inputs.nixvim.homeModules.nixvim
    inputs.caelestia-shell.homeManagerModules.default
    inputs.serpantinum.homeManagerModules.default
  ]
  ++ (builtins.attrValues self.homeManagerModules);

  mkHost =
    {
      host,
      user,
      extraOSModules ? [ ],
      extraOSArgs ? { },
      extraHomeModules ? [ ],
      extraHomeArgs ? { },
      ...
    }:
    {
      nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit
            inputs
            nixpkgs
            self
            host
            user
            ;
        }
        // extraOSArgs;
        modules = extraOSModules ++ sharedOSModules;
      };

      homeConfigurations."${user}@${host}" = inputs.home-manager.lib.homeManagerConfiguration {
        # home-manager 的 fcitx5 模块仍会拉 gtk2（immodule cache），
        # 新版 nixpkgs 把 gtk2 标为 broken 导致评估被拒，这里只清除该标记。
        pkgs = nixpkgs.legacyPackages."x86_64-linux".extend (
          _final: prev: {
            gtk2 = prev.gtk2.overrideAttrs (old: {
              meta = old.meta // {
                problems = builtins.removeAttrs (old.meta.problems or { }) [ "broken" ];
              };
            });
          }
        );
        extraSpecialArgs = {
          inherit
            inputs
            nixpkgs
            self
            host
            user
            ;
        }
        // extraHomeArgs;
        modules = extraHomeModules ++ sharedHomeModules;
      };
    };

in
{
  flake = import ./hosts.nix |> map mkHost |> builtins.foldl' (x: y: x // y) { };
}
