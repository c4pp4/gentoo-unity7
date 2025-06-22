# ehooks

### Chapter I.

- It's a patching system that looks for existence of **{pre,post}\_${EBUILD_PHASE_FUNC}.ehooks** file and source it to perform hooks. It provides a way to patch packages not needed to maintain. It's loosly based on **eapply_user** function from /usr/lib/portage/python3.\*/phase-helpers.sh script and **pre_src_prepare** function from the Gentoo wiki ([archived version⬀][warch] from web.archive.org).

   - see the [code][code]

- Overlay's ehooks are located in [gentoo-unity7/profiles/ehooks][ehooks] directory.

- **Changes** are managed via **unity-base/gentoo-unity-env** package. The package looks for ehooks changes, generates emerge command needed to be applied and displays it as a warning message in pkg_postinst phase.

- **Optional** ehooks are managed via [unity-base/gentoo-unity-env USE flags][uflags].

- Some [special ehooks][env] are downloading debian archive file to apply ubuntu patchset. Downloading is allowed through [network-sandbox-proxy][cenv]. The archive file is checked via b2sum tool (it checks BLAKE2 512-bit checksum of downloaded file).

- You have to set **EHOOKS_ACCEPT="yes"** in make.conf to confirm you agree with this patching system.

#

### Chapter II.

- Version control is managed via /usr/bin/**gentoo-unity-ver**. It's not intended for end users. It's a symlink to **version_control.sh** script.

   - run **gentoo-unity-ver** for more options

- **Directory name and search order:**

   ```
    1) app-arch/file-roller-3.22.3-r0:0
    2) app-arch/file-roller-3.22.3-r0
    3) app-arch/file-roller-3.22.3:0
    4) app-arch/file-roller-3.22.3
    5) app-arch/file-roller-3.22:0
    6) app-arch/file-roller-3.22
    7) app-arch/file-roller-3:0
    8) app-arch/file-roller-3
    9) app-arch/file-roller:0
   10) app-arch/file-roller
   ```

   - **empty directory excludes** the specific version from applying ehooks

- **File format to trigger ehooks:**

   - {pre,post}_${EBUILD_PHASE_FUNC}.ehooks

   ```
    1) pre_pkg_setup.ehooks
    2) post_pkg_setup.ehooks
    3) pre_src_unpack.ehooks
    4) post_src_unpack.ehooks
    5) pre_src_prepare.ehooks
    6) post_src_prepare.ehooks
    7) pre_src_configure.ehooks
    8) post_src_configure.ehooks
    9) pre_src_compile.ehooks
   10) post_src_compile.ehooks
   11) pre_src_install.ehooks
   12) post_src_install.ehooks
   13) pre_pkg_preinst.ehooks
   14) post_pkg_preinst.ehooks
   15) pre_pkg_postinst.ehooks
   16) post_pkg_postinst.ehooks
   ```

   - it's possible to use filename prefix and sort it for better overview:

     **[anything...]** pre_src_prepare.ehooks

     ```
     01_pre_src_prepare.ehooks
     aa-pre_src_prepare.ehooks
     ```

   - it's possible to use more files in one phase

     see [gnome-base/gnome-session][gnome-session]:

     ```
     02-pre_src_prepare.ehooks
     03-pre_src_prepare.ehooks
     ```

- **File body:**
  ```
  ehooks() {
    [COMMANDS...]
  }
  ```

  - it's possible to use any [ebuild function⬀][efn]

  - **templates** are in [gentoo-unity7/profiles/ehooks/templates][templates] directory

	 the preferred way of using templates are **symbolic links**:

    `ln -s ../../templates/patches.template 02-pre_src_prepare.ehooks`

   - command to **apply patches** in prepare phase:

     `eapply "${EHOOKS_FILESDIR}"`

   - command to trigger **eautoreconf**:

     `eautoreconf`

     and in **post_src_prepare** phase when **eautoreconf** already used:

     `AT_NOELIBTOOLIZE="yes" eautoreconf`

   - **errors log** is located at ${T}/ehooks.log

- **${EHOOKS_FILESDIR}**
   - path to ${pkgdir}/files
   - used for patches and miscellaneous files

- **Patch file format:**
   - extensions: *.patch or *.diff
   - use filename prefix to control apply order

- **Query functions:**

  `ehooks_use [USE flag]`

  - it returns a true value if **unity-base/gentoo-unity-env** USE flag is declared
  - e.g. `if ehooks_use fontconfig; then`, see [app-office/libreoffice/03-pre_pkg_preinst.ehooks][libreoffice]:

  `ehooks_require [USE flag]`

  - it skips the rest of the related ehooks if **unity-base/gentoo-unity-env** USE flag is not declared
  - it should be the first command of ehooks
  - e.g. `ehooks_require fontconfig`, see [media-libs/fontconfig:1.0/01-pre_pkg_preinst.ehooks][fconf]

- **EHOOKS_PATH** variable defines the location of additional ehooks. It provides a way for users to apply their own ehooks. It's set through **/etc/portage/make.conf**
   - e.g. `EHOOKS_PATH="/home/ehooks"`
   - own directory **overrides** overlay's directory of the same name
   - own empty directory **disables** overlay's directory of the same name
   - e.g. **/home/ehooks/app-arch/file-roller** overrides or disables **gentoo-unity7/profiles/ehooks/app-arch/file-roller**

- **Generic ehooks:**
  - it's possible to use ehooks to be applied to every package
  - create **generic** directory and place all desired ehooks inside
  - e.g. create `/home/ehooks/generic` directory in case of `EHOOKS_PATH="/home/ehooks"`
  - if you have [/etc/portage/bashrc⬀][bashrc] file and {pre,post}_${EBUILD_PHASE_FUNC} function in it (phase: setup, unpack, prepare, configure, compile, install, preinst or postinst), call **ehooks_apply** function inside each, e.g. if you defined pre_src_prepare function:
     ```
     pre_src_prepare() {
       [YOUR COMMANDS...]
       ehooks_apply
       [YOUR COMMANDS...]
     }
     ```

- **Using debian archive file:**
   - e.g. we need to process `gnome-session_42.0-1ubuntu3.debian.tar.xz` debian archive file
   - create `01-post_src_unpack.ehooks` file to download debian archive file:

     ```
     ehooks() {
       local \
         blake= \
         uver=gnome-session_42.0-1ubuntu3

       source "${EHOOKS_PATH}"/templates/fetch_debian.template
       fetch_debian "${blake}" "${uver}"
     }
     ```

   - update BLAKE2 512-bit checksum via `gentoo-unity-ver -b` command
   - create **02-pre_src_prepare.ehooks** file to apply debian archive file patchset:

     `ln -s ../../templates/patches.template 02-pre_src_prepare.ehooks`

[//]: # (LINKS)
[bashrc]: https://wiki.gentoo.org/wiki//etc/portage/bashrc
[cenv]: ../profiles/gentoo-unity7.conf.env
[code]: ../profiles/amd64/23.0/desktop/unity/profile.bashrc
[efn]: https://devmanual.gentoo.org/function-reference/index.html
[ehooks]: ../profiles/ehooks
[env]: ../profiles/gentoo-unity7.env
[fconf]: ../profiles/ehooks/media-libs/fontconfig:1.0/01-pre_pkg_preinst.ehooks
[gnome-session]: ../profiles/ehooks/gnome-base/gnome-session
[libreoffice]: ../profiles/ehooks/app-office/libreoffice/03-pre_pkg_preinst.ehooks
[templates]: ../profiles/ehooks/templates
[uflags]: ../unity-base/gentoo-unity-env/metadata.xml
[warch]: https://web.archive.org/web/20191226202345/https://wiki.gentoo.org/wiki//etc/portage/patches#Enabling_.2Fetc.2Fportage.2Fpatches_for_all_ebuilds
