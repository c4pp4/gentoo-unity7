# Gentoo Unity⁷ Desktop

### A Gentoo overlay to install the Unity7 user interface.

- Forked from https://github.com/shiznix/unity-gentoo

### How to install:

---

**WARNING:**

Some overlay patches will be applied to packages from the Gentoo tree via ebuild hooks patching system. For more details, see README_ehooks.txt, Chapter I. Set variable **EHOOK_ACCEPT="yes"** in /etc/portage/make.conf to confirm you agree with it.

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

---

- Gentoo tree packages from testing phase ~amd64 enabled through the overlay:

  - **x11-wm/metacity** - required

  - **app-backup/deja-dup** and **www-client/firefox** - optional

- Tips and tricks:

  - **enable OpenGL ES 2.0 support**: unity-base/unity **gles2**, unity-base/compiz **gles2**, unity-base/nux **gles2**

  - **enable system tray support for all applications**: unity-base/unity **systray**

  - **disable Evolution Data Server support**: unity-indicators/indicator-datetime **-eds**

  - **unity-extra/diodon**: clipboard manager for the Unity7 - unity-indicators/unity-indicators-meta **paste**

  - **net-mail/mailnag**: mail notification with Messaging menu support - unity-indicators/unity-indicators-meta **mail**

  - **dev-java/jayatana**: Global Menu for Java applications - unity-indicators/unity-indicators-meta **java**

- For more information about the Unity7, see: https://en.wikipedia.org/wiki/Unity_(user_interface)
