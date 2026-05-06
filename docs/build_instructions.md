# Build instructions

1. **Use** the [stage3-amd64-systemd⬀][s3] tarball for a new installation, or **switch to** the [systemd⬀][sysd] init system on an existing installation.

2. **Add the overlay** using the [eselect-repository⬀][erepo] module and synchronize it:

   `eselect repository enable gentoo-unity7`
   <br/>
   `emaint sync -r gentoo-unity7`

   NOTE: The package [dev-vcs/git⬀][git] is required.

3. **Set** `gentoo-unity7:amd64/23.0/desktop/unity/systemd (stable)` [profile⬀][ep] listed with `eselect profile list`.

4. **Add** the `EHOOKS_ACCEPT="yes"` **variable** into the `/etc/portage/make.conf` configuration file.

   WARNING: Some overlay patches will be applied to packages from the Gentoo tree via the ehooks patching system. For more details, see [ehooks - Chapter I.][ehooks] Set the variable to confirm you agree with it.

5. **Set up** the Gentoo Unity⁷ Desktop **build environment**:

   `emerge gentoo-unity-env`

   WARNING: Don't use the portage variable EMERGE_DEFAULT_OPTS with the `--jobs N` option, as it causes informational and warning messages to be ignored. Such messages are important mainly in the next step.

6. The previous emerge command installs the *'unity-base/gentoo-unity-env'* package. The package, among other things, generates an emerge command that needs to be applied and displays it as a warning message in the pkg_postinst phase. **Rebuild all affected packages**, if any.

   FOR EXAMPLE, YOU CAN SEE:
   ```
   >>> Looking for ehooks changes... done!

    ------------------------------------------------------------
    * Rebuild the following packages affected by ehooks changes:
    * emerge -av1 app-i18n/ibus gnome-base/gnome-menus gnome-base/gnome-session gnome-base/gsettings-desktop-schemas gnome-extra/polkit-gnome x11-libs/gtk+:2 x11-libs/gtk+:3
    ------------------------------------------------------------
   ```

   WARNING: If you don't see a similar message, don't continue with the installation. Please write to our [Telegram group⬀][tg] or create an issue report.

7. **Update the whole system**:

   `emerge -avuDU --with-bdeps=y @world`

   NOTE: A circular dependencies error may appear between *'media-libs/freetype'* and *'media-libs/harfbuzz'*. Before the update, try:
   <br/>
   `USE="-harfbuzz" emerge --oneshot media-libs/freetype`

8. **Install Unity7**:

   `emerge -av unity-meta`

#

NOTES:

- Don't forget to enable systemd services, such as:
  <br/>
  [LightDM⬀][ldm], [PipeWire⬀][pw], [WirePlumber⬀][wp], [NetworkManager⬀][nm], [CUPS⬀][cups], and [Bluetooth⬀][bt].

- In case of starting Unity7 with the `startx` command, use [our .xinitrc file][xirc] to ensure all needed services are started.

- If you switch the default Python target, you **must** update `sys-apps/portage` before any other packages.

[//]: # (LINKS)
[bt]: https://wiki.gentoo.org/wiki/Bluetooth#systemd
[cups]: https://wiki.gentoo.org/wiki/Printing#systemd
[ehooks]: ehooks.md
[ep]: https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base#Choosing_the_right_profile
[erepo]: https://wiki.gentoo.org/wiki/Eselect/Repository
[git]: https://wiki.gentoo.org/wiki/Git
[ldm]: https://wiki.gentoo.org/wiki/LightDM#systemd
[nm]: https://wiki.gentoo.org/wiki/NetworkManager#systemd
[pw]: https://wiki.gentoo.org/wiki/PipeWire#systemd
[s3]: https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage#Downloading_the_stage_file
[sysd]: https://wiki.gentoo.org/wiki/Systemd
[tg]: https://t.me/gentoo_unity7_lomiri
[wp]: https://wiki.gentoo.org/wiki/WirePlumber#systemd
[xirc]: /unity-base/unity/files/xinitrc
