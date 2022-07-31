# Build instructions

1. Switch init system to systemd:

   https://wiki.gentoo.org/wiki/Systemd

2. Add the overlay using `eselect-repository` module or `layman` tool:
   - eselect-repository:

     `eselect repository add gentoo-unity7 git https://github.com/c4pp4/gentoo-unity7.git`
     <br/>
     `emaint sync -r gentoo-unity7`

   - layman:

     `layman -o https://raw.githubusercontent.com/c4pp4/gentoo-unity7/master/repositories.xml -f -a gentoo-unity7`

     NOTE: Copy `repositories.xml` file into `/etc/layman/overlays` directory to suppress warning when updating the overlay that says *overlay could not be found in the remote lists*.

3. Select `gentoo-unity7:amd64/17.1/desktop/unity/systemd (stable)` profile listed with:

   `eselect profile list`

5. Set variable `EHOOKS_ACCEPT="yes"` in `/etc/portage/make.conf`

   WARNING: Some overlay patches will be applied to packages from the Gentoo tree via ehooks patching system. For more details, see [ehooks - Chapter I.][ehooks] Set the variable to confirm you agree with it.

4. Install the package to setup the Unity7 build environment:

   `emerge -av unity-build-env`

5. Previous emerge command will install `unity-extra/ehooks` package. The package generates emerge command needed to be applied and displays it as a warning message. Rebuild affected packages if needed.

6. Update the whole system:

   `emerge -avuDU --with-bdeps=y @world`

7. Install the Unity7:

   `emerge -av unity-meta`

[//]: # (LINKS)
[ehooks]: ehooks.md
