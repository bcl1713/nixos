# user/packages/default.nix

{ ... }:

{
  imports = [
    ./system
    ./development
    ./media
    ./utilities
    ./apps
    ./scripts
    ./wm
    ./editors
    ./fonts
    ./security
  ];

}
