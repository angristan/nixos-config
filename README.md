# NixOS config

This is the NixOS config for my work laptop, a XPS 13 9360.

It uses systemd-boot, Xorg, GDM, GNOME and LVM on LUKS.

## Install

This posts helped me install NixOS on my XPS:

- https://nixos.org/nixos/manual/
- https://blog.qfpl.io/posts/installing-nixos/
- https://gist.github.com/RobBlackwell/64149c868f2361bb4c6e9d4fede65633
- https://grahamc.com/blog/nixos-on-dell-9560
- https://chris-martin.org/2015/installing-nixos

### Add unstable channel

I'm using NixOS unstable. To replace to nixos-channel with unstable:

```sh
nix-channel --add https://nixos.org/channels/nixos-unstable nixos
```

If you didn't use unstable during the install, you will need to update and rebuild:

```sh
nix-channel --update nixos
nixos-rebuild switch
```

## Configuration inspiration

I spent a lot of time reading other user's configurations, mainly from the wiki's [Configuration Collection](https://nixos.wiki/wiki/Configuration_Collection). This is where I learned the most!

## To Do

- Split into modules
- Use [Home Manager](https://github.com/rycee/home-manager)
