# Build tips

- to install stable version of **www-client/firefox** (Extended Support Release), create an appropriate file in `/etc/portage/package.accept_keywords` directory with the following content:

  ```
  dev-libs/nspr::gentoo -~*
  dev-libs/nss::gentoo -~*
  www-client/firefox::gentoo -~*
  ```

- enable **OpenGL ES 2.0** support:

  ```
  unity-base/unity gles2
  unity-base/compiz gles2
  unity-base/nux gles2
  ```

- enable **system tray** support for all applications:

  ```
  unity-base/unity systray
  ```

- disable **Evolution Data Server** support:

  ```
  unity-indicators/indicator-datetime -eds
  ```

- **unity-extra/diodon** - clipboard manager for the Unity7:

  ```
  unity-indicators/unity-indicators-meta paste
  ```

- **net-mail/mailnag** - mail notification with Messaging menu support

  ```
  unity-indicators/unity-indicators-meta mail
  ```

- **dev-java/jayatana** - Global Menu for Java applications

  ```
  unity-indicators/unity-indicators-meta java
  ```
