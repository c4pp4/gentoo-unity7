# ehooks

### Chapter I

- The ehooks patching system looks for files matching **{pre,post}\_${EBUILD_PHASE_FUNC}.ehooks** and sources them to run ehooks. It allows packages to be patched without maintaining separate ebuilds for them. It is loosely based on the **eapply_user** function from the /usr/lib/portage/python3.\*/phase-helpers.sh script and the **pre_src_prepare** function from the Gentoo wiki ([archived version⬀][warch]).

  - See the [code][code].

- The overlay's ehooks are located in the [gentoo-unity7/ehooks][ehooks] directory.

- **Changes** are reported after each synchronization of the overlay (via a repo.postsync.d hook installed by **unity-base/gentoo-unity-env**). Rebuild affected packages using the **@ehooks-rebuild** package set: `emerge @ehooks-rebuild`.

- Some [special ehooks][env] download a Debian archive to apply the Ubuntu patchset. Downloads are permitted via [network-sandbox-proxy][cenv]. The downloaded archive is verified with b2sum against its 512-bit BLAKE2 checksum.

- Set **ACCEPT_EHOOKS="yes"** in make.conf to accept the use of this patching system.

---

### Chapter II

- Version control is managed via /usr/bin/**gentoo-unity-ver**. This command is intended for maintainers rather than end users. It is a symbolic link to the **version_control.sh** script.

  - Run **gentoo-unity-ver** to see the available options.

- **Directory names and search order** (the `generic` directory is always processed first):

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

  - An **empty matching directory** prevents package-specific ehooks from being applied to that version.

  - To **remove all ehooks** of a package, delete its ehooks files but keep the directory with an empty `.keep_gentoo-unity7` file. Changes are detected via the modification time of existing ehooks directories, so a removed directory would not be reported and affected packages would not be rebuilt. The `.keep_gentoo-unity7` file is needed because Git does not track empty directories.

- **Filename format:**

  - `{pre,post}_${EBUILD_PHASE_FUNC}.ehooks`

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

  - Use filename prefixes to control the processing order and make ehooks files easier to organize:

    **[anything...]** pre_src_prepare.ehooks

    ```
    01_pre_src_prepare.ehooks
    aa-pre_src_prepare.ehooks
    ```

  - You can use multiple ehooks files for a single phase.

    See [media-plugins/audacious-plugins][audacious]:

    ```
    01-pre_src_prepare.ehooks
    02-pre_src_prepare.ehooks
    ```

- **File contents:**

  ```
  ehooks() {
    [COMMANDS...]
  }
  ```

  - You can use any [ebuild function⬀][efn].

  - As in ebuilds, the return value of **ehooks()** is ignored. Use `|| die` to report failures; any output to stderr is also treated as an error.

  - **ehooks()** runs in a subshell. Changes to variables (e.g. `export`, `append-cflags`) and the working directory do not affect the ebuild.

  - **Templates** are available in the [gentoo-unity7/ehooks/templates][templates] directory.

    The preferred way to use templates is through **symbolic links**:

    `ln -s ../../templates/patches.template 02-pre_src_prepare.ehooks`

  - To **apply patches** during the prepare phase:

    `eapply "${EHOOKS_FILESDIR}"`

  - To run **eautoreconf** (the autotools eclass does not need to be inherited, eautoreconf is loaded automatically):

    `eautoreconf`

    If **eautoreconf** has already been run, use the following command in **post_src_prepare**:

    `AT_NOELIBTOOLIZE="yes" eautoreconf`

  - The **error log** is located at `${T}/ehooks.log`.

- **${EHOOKS_FILESDIR}**

  - Used for patches and miscellaneous files.
  - Points to `${pkgdir}/files`, except in the install phase (**pre_src_install** and **post_src_install**), where it points to `${T}/ehooks-files`, a copy of `${pkgdir}/files`.
  - Why the install phase uses a copy: **doins** (also used by **domenu**) copies files with Portage's **copyfile()**, which tries reflink, **copy_file_range()** and **sendfile()** before falling back to a plain copy. On some filesystems (e.g. a VirtualBox shared folder), **sendfile()** fails. The fallback copy succeeds, but Portage writes a warning with a traceback to stderr. Any ehooks stderr output is treated as an error, so this harmless warning would abort the build. **doins** and **domenu** can only be used in the install phase, so the other phases use the files directly from the repository. The copy is made only once per install phase run, as **pre_src_install** and **post_src_install** ehooks run in the same process. A new run of the install phase makes a fresh copy.

- **Patch file format:**

  - Extensions: `*.patch` or `*.diff`.
  - Use filename prefixes to control the order in which patches are applied.

- The **EHOOKS_PATH** variable specifies the location of additional ehooks, allowing users to provide their own ehooks. Set it in **/etc/portage/make.conf**.

  - For example, `EHOOKS_PATH="/home/ehooks"`.
  - A user-provided directory **overrides** the overlay directory with the same name.
  - An empty user-provided directory **disables** the overlay directory with the same name.
  - For example, **/home/ehooks/app-arch/file-roller** overrides or disables **gentoo-unity7/ehooks/app-arch/file-roller**.

- **Generic ehooks:**

  - Generic ehooks can be applied to every package.
  - Create a directory named `generic` and place the desired ehooks files inside it.
  - For example, if `EHOOKS_PATH="/home/ehooks"`, create `/home/ehooks/generic`.
  - If your [/etc/portage/bashrc⬀][bashrc] defines any `{pre,post}_${EBUILD_PHASE_FUNC}` functions for the setup, unpack, prepare, configure, compile, install, preinst, or postinst phases, call **ehooks_apply** from each of those functions. For example, for **pre_src_prepare**:

    ```
    pre_src_prepare() {
      [YOUR COMMANDS...]
      ehooks_apply
      [YOUR COMMANDS...]
    }
    ```

- **Using a Debian archive:**

  - For example, to process the Debian archive `gnome-session_42.0-1ubuntu3.debian.tar.xz`:
  - Create a `01-post_src_unpack.ehooks` file to download the Debian archive:

    ```
    ehooks() {
      local \
        blake= \
        uver=gnome-session_42.0-1ubuntu3

      source "${EHOOKS_ROOT}"/templates/fetch_debian.template
      fetch_debian "${blake}" "${uver}"
    }
    ```

  - Update the 512-bit BLAKE2 checksum using `gentoo-unity-ver -b`.
  - Create a `02-pre_src_prepare.ehooks` file to apply the patchset from the Debian archive:

    `ln -s ../../templates/patches.template 02-pre_src_prepare.ehooks`

[//]: # (LINKS)
[audacious]: ../ehooks/media-plugins/audacious-plugins
[bashrc]: https://wiki.gentoo.org/wiki//etc/portage/bashrc
[cenv]: ../profiles/gentoo-unity7.conf.env
[code]: ../profiles/amd64/23.0/desktop/unity/profile.bashrc
[efn]: https://devmanual.gentoo.org/function-reference/index.html
[ehooks]: ../ehooks
[env]: ../profiles/gentoo-unity7.env
[templates]: ../ehooks/templates
[warch]: https://web.archive.org/web/20191226202345/https://wiki.gentoo.org/wiki//etc/portage/patches#Enabling_.2Fetc.2Fportage.2Fpatches_for_all_ebuilds
