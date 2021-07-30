# Gentoo Unity⁷

### A Gentoo overlay to install the Unity7 user interface on amd64 architecture.

- Forked from https://github.com/shiznix/unity-gentoo

- For more information about the Unity7, see: https://en.wikipedia.org/wiki/Unity_(user_interface)

### How to install:

---

**WARNING:**

Some overlay patches will be applied to packages from the Gentoo tree via ebuild hooks patching system. For more details see README_ehooks.txt - Chapter I. Set variable **EHOOK_ACCEPT="yes"** in /etc/portage/make.conf to confirm you agree with it.

---

1. Switch init system to **systemd**:

   https://wiki.gentoo.org/wiki/Systemd

2. Add the overlay using layman:

   **layman -o https://raw.githubusercontent.com/c4pp4/gentoo-unity7/master/repositories.xml -f -a gentoo-unity7**

3. Select **gentoo-unity7** profile listed with:

   **eselect profile list**

4. Install the package to setup the Unity7 build environment:

   **emerge -av unity-build-env**

5. Update the whole system:

   **emerge -avuDU --with-bdeps=y @world**

6. Install the Unity7:

   **emerge -av unity-meta**
