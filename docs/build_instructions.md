# Build instructions

Follow the [Gentoo AMD64 Handbook⬀][handbook] for the base installation and complete the steps below along the way. Note that OpenRC support already works, but it is still considered experimental.

1. Select the `stage3-amd64-desktop-systemd` or `stage3-amd64-desktop-openrc` tarball when [choosing a stage file⬀][stagefile].

2. Add the overlay using the [eselect-repository⬀][erepo] module and synchronize it:

   `eselect repository enable gentoo-unity7`
   <br/>
   `emaint sync -r gentoo-unity7`

3. Set the [profile⬀][ep] matching your init system, listed by `eselect profile list`:

   `gentoo-unity7:amd64/23.0/desktop/unity/systemd (stable)`
   <br/>
   `gentoo-unity7:amd64/23.0/desktop/unity/openrc (exp)`

4. Add the `ACCEPT_EHOOKS="yes"` variable into the `/etc/portage/make.conf` configuration file.

   WARNING: Some overlay patches will be applied to packages from the Gentoo repository via the ehooks patching system. For more details, see [ehooks - Chapter I.][ehooks] Set the variable to confirm you agree with it.

5. Set up the Gentoo Unity⁷ Desktop build environment:

   `emerge gentoo-unity-env`

6. Update the whole system and rebuild packages affected by ehooks:

   `emerge -avuDU --with-bdeps=y @world @ehooks-rebuild`

7. Install Unity7:

   `emerge -av unity-meta`

---

NOTES:

- Don't forget to enable services:

  - systemd or OpenRC: [LightDM⬀][ldm], [NetworkManager⬀][nm], [CUPS⬀][cups], and [Bluetooth⬀][bt].

  - systemd: [PipeWire⬀][pw] and [WirePlumber⬀][wp].

  - OpenRC: [elogind⬀][elogind] and [D-Bus⬀][dbus] (PipeWire and WirePlumber are started by default).

- In case of starting Unity7 with the `startx` command, use [our .xinitrc file][xirc] to ensure all needed services are started.

- If you switch the default Python target, you **must** update `sys-apps/portage` before any other packages.

[//]: # (LINKS)
[bt]: https://wiki.gentoo.org/wiki/Bluetooth#Services
[cups]: https://wiki.gentoo.org/wiki/Printing#Service
[dbus]: https://wiki.gentoo.org/wiki/D-Bus#OpenRC
[ehooks]: ehooks.md
[elogind]: https://wiki.gentoo.org/wiki/Elogind#Service
[ep]: https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base#Choosing_the_right_profile
[erepo]: https://wiki.gentoo.org/wiki/Eselect/Repository
[handbook]: https://wiki.gentoo.org/wiki/Handbook:AMD64
[ldm]: https://wiki.gentoo.org/wiki/LightDM#Boot_service
[nm]: https://wiki.gentoo.org/wiki/NetworkManager#Service
[pw]: https://wiki.gentoo.org/wiki/PipeWire#systemd
[stagefile]: https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage#Choosing_a_stage_file
[wp]: https://wiki.gentoo.org/wiki/WirePlumber#systemd
[xirc]: /unity-base/unity/files/xinitrc
