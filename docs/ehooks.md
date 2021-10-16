# ehooks

### Chapter I.

- It's a patching system that looks for existence of **{pre,post}\_${EBUILD_PHASE_FUNC}.ehooks** file and source it to perform hooks. It provides a way to patch packages we don't need to maintain. It's loosly based on **eapply_user** function from /usr/lib/portage/python3.\*/phase-helpers.sh script and **pre_src_prepare** function from the Gentoo wiki ([archived version](https://web.archive.org/web/20191226202345/https://wiki.gentoo.org/wiki//etc/portage/patches#Enabling_.2Fetc.2Fportage.2Fpatches_for_all_ebuilds) from web.archive.org).

   - see [profile.bashrc][code]

- Overlay's ehooks are located in [profiles/ehooks][ehooks] directory.

- **Optional** ehooks are managed via [unity-extra/ehooks USE flags][use flags].

- **Changes** are managed via **unity-extra/ehooks** package. It looks for ehooks changes and generates emerge command needed to apply the changes.

- You have to set **EHOOKS_ACCEPT="yes"** in make.conf to confirm you agree with this patching system.

#

### Chapter II.

- Version control is managed via **/usr/bin/ehooks**. It's not intended for end users. It looks for gentoo tree updates of package versions masked via **unity-portage.pmask** and refreshes version entries. It looks for available version changes of debian archive file in {pre,post}_src_unpack.ehooks and updates BLAKE2 checksum. It's a symlink to **ehooks_version_control.sh** script.

   - run **ehooks** for options

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

     see [gnome-base/nautilus][nautilus]:

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

  - it's possible to use any [ebuild function](https://devmanual.gentoo.org/function-reference/index.html)

  - **templates** are in [profiles/ehooks/templates][templates] directory

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

  - it returns a true value if **unity-extra/ehooks** USE flag is declared
  - e.g. `if ehooks_use nemo_noroot; then`, see [gnome-extra/nemo/02-pre_src_prepare.ehooks][nemo]:

  `ehooks_require [USE flag]`

  - it skips the rest of the related ehooks if **unity-extra/ehooks** USE flag is not declared
  - it should be the first command of ehooks
  - e.g. `ehooks_require gnome-terminal_theme`, see [x11-terms/gnome-terminal/01-post_src_prepare.ehooks][terminal] and [x11-libs/vte:2.91/01-post_src_prepare.ehooks][vte]

- **EHOOKS_PATH** variable defines the location of additional ehooks. It provides a way for users to apply their own ehooks. It's set through **/etc/portage/make.conf**
   - e.g. `EHOOKS_PATH="/home/ehooks"`
   - own directory **overrides** overlay's directory of the same name
   - own empty directory **disables** overlay's directory of the same name
   - e.g. **/home/ehooks/app-arch/file-roller** overrides or disables **/var/lib/layman/gentoo-unity7/profiles/ehooks/app-arch/file-roller**

[//]: # (LINKS)
[code]: ../profiles/amd64/17.1/desktop/unity/profile.bashrc#L15
[ehooks]: ../profiles/ehooks
[nautilus]: ../profiles/ehooks/gnome-base/nautilus
[nemo]: ../profiles/ehooks/gnome-extra/nemo/02-pre_src_prepare.ehooks
[templates]: ../profiles/ehooks/templates
[terminal]: ../profiles/ehooks/x11-terms/gnome-terminal/01-post_src_prepare.ehooks
[use flags]: ../unity-extra/ehooks/metadata.xml
[vte]: ../profiles/ehooks/x11-libs/vte:2.91/01-post_src_prepare.ehooks
