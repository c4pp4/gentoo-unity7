# Build instructions

1. **Switch to** [systemd⬀][sysd] init system or use [stage3-amd64-systemd⬀][s3] tarball.

2. **Add the overlay** using [eselect-repository⬀][erepo] module and synchronize it:

   `eselect repository enable gentoo-unity7`
   <br/>
   `emaint sync -r gentoo-unity7`

   NOTE: Package [dev-vcs/git⬀][git] is required.

3. **Set** `gentoo-unity7:amd64/23.0/desktop/unity/systemd (stable)` [profile⬀][ep] listed with `eselect profile list`.

4. **Add** `EHOOKS_ACCEPT="yes"` **variable** into `/etc/portage/make.conf` configuration file.

   WARNING: Some overlay patches will be applied to packages from the Gentoo tree via ehooks patching system. For more details, see [ehooks - Chapter I.][ehooks] Set the variable to confirm you agree with it.

5. **Setup** Gentoo Unity⁷ Desktop **build environment**:

   `emerge -av gentoo-unity-env`

6. Previous emerge command installs *'unity-base/gentoo-unity-env'* package. The package, among other things, generates emerge command needed to be applied and displays it as a warning message in pkg_postinst phase. **Rebuild all affected packages**, if any.

   FOR EXAMPLE, YOU CAN SEE:
   ```
   >>> Looking for ehooks changes... done!

    * Rebuild the following packages affected by ehooks changes:
    * emerge -av1 app-i18n/ibus gnome-base/gnome-menus gnome-base/gnome-session gnome-base/gsettings-desktop-schemas gnome-extra/polkit-gnome x11-libs/gtk+:2 x11-libs/gtk+:3
   ```

7. **Update the whole system**:

   `emerge -avuDU --with-bdeps=y @world`

   NOTE: Circular dependencies error may appear between *'media-libs/freetype'* and *'media-libs/harfbuzz'*. Before the update, try:
   <br/>
   `USE="-harfbuzz" emerge -av1 media-libs/freetype`

8. **Install the Unity7**:

   `emerge -av unity-meta`

#

NOTES:

- Don't forget to start systemd services, such as [LightDM⬀][ldm], [PulseAudio⬀][pa], [NetworkManager⬀][nm], [CUPS⬀][cups] or [Bluetooth⬀][bt].

- If you switch the default Python target, you **must** update `sys-apps/portage` before any other packages.

[//]: # (LINKS)
[bt]: https://wiki.gentoo.org/wiki/Bluetooth#systemd
[cups]: https://wiki.gentoo.org/wiki/Printing#systemd
[ehooks]: ehooks.md
[ep]: https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base#Choosing_the_right_profile
[erepo]: https://wiki.gentoo.org/wiki/Eselect/Repository
[git]: https://wiki.gentoo.org/wiki/Git
[ldm]: https://wiki.gentoo.org/wiki/LightDM#systemd
[mu]: https://wiki.gentoo.org/wiki/Merge-usr
[nm]: https://wiki.gentoo.org/wiki/NetworkManager#systemd
[pa]: https://wiki.gentoo.org/wiki/PulseAudio#systemd
[s3]: https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage#Downloading_the_stage_file
[sysd]: https://wiki.gentoo.org/wiki/Systemd
