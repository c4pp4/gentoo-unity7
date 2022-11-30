# Build instructions

1. **Switch to** [systemd⬀][sysd] init system.

2. **Add the overlay** using [eselect-repository⬀][erepo] module or [layman⬀][lay] tool:
   - eselect-repository:

     `eselect repository add gentoo-unity7 git https://github.com/c4pp4/gentoo-unity7.git`
     <br/>
     `emaint sync -r gentoo-unity7`

   - layman (deprecated):

     `layman -o https://raw.githubusercontent.com/c4pp4/gentoo-unity7/master/repositories.xml -f -a gentoo-unity7`

     NOTE: Copy `repositories.xml` file into `/etc/layman/overlays` directory to suppress warning when updating the overlay that says *overlay could not be found in the remote lists*.

3. **Select** `gentoo-unity7:amd64/17.1/desktop/unity/systemd (stable)` [profile⬀][ep] listed with:

   `eselect profile list`

4. **Set** `EHOOKS_ACCEPT="yes"` **variable** in `/etc/portage/make.conf` configuration file.

   WARNING: Some overlay patches will be applied to packages from the Gentoo tree via ehooks patching system. For more details, see [ehooks - Chapter I.][ehooks] Set the variable to confirm you agree with it.

5. Install the package to **setup the Unity7 build environment**:

   `emerge -av unity-build-env`

6. Previous emerge command will install `unity-extra/ehooks` package. The package generates emerge command needed to be applied and displays it as a warning message in pkg_postinst phase. **Rebuild affected packages**.

   FOR EXAMPLE:
   ```
   Looking for ehooks changes... done!

    * Rebuild the packages affected by ehooks changes:

    * emerge -av1 app-i18n/ibus gnome-base/gnome-menus gnome-base/gnome-session gnome-base/gsettings-desktop-schemas gnome-extra/polkit-gnome x11-libs/gtk+:2 x11-libs/gtk+:3
   ```

7. **Update the whole system**:

   `emerge -avuDU --with-bdeps=y @world`

8. **Install the Unity7**:

   `emerge -av unity-meta`

   NOTE: Don't forget to start systemd services, such as [LightDM⬀][ldm], [NetworkManager⬀][nm] or [CUPS⬀][cups].

[//]: # (LINKS)
[cups]: https://wiki.gentoo.org/wiki/Printing#systemd
[ehooks]: ehooks.md
[ep]: https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base#Choosing_the_right_profile
[erepo]: https://wiki.gentoo.org/wiki/Eselect/Repository
[lay]: https://wiki.gentoo.org/wiki/Layman
[ldm]: https://wiki.gentoo.org/wiki/LightDM#systemd
[nm]: https://wiki.gentoo.org/wiki/NetworkManager#systemd
[sysd]: https://wiki.gentoo.org/wiki/Systemd
