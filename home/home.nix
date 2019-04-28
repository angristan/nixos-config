{ config, pkgs, ... }:

{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;

    userName = "Stanislas Lange";
    userEmail = "stanislas.lange@fr.clara.net";

    aliases = {
      plog = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
    };

    extraConfig = {
      core = {
        pager = "diff-so-fancy | less --tabs=4 -RFX";
      };
      color = {
        ui = "true";
      };
      "color \"diff-highlight\"" = {
        oldnormal = "red bold";
        oldHighlight = "red bold 52";
        newNormal = "green bold";
        newHighlight = "green bold 22";
      };
      "color \"diff\"" = {
        meta = "yellow";
        frag = "magenta bold";
        commit = "yellow bold";
        old = "red bold";
        new = "green bold";
        whitespace = "red reverse";
      };
    };

    ignores = [
      "*.swp"
      "*~"
      ".#*"
      ".DS_Store"
      ".direnv"
      ".vagrant"
    ];
  };
}
