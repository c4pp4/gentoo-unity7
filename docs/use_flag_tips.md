# USE flag tips

[/etc/portage/package.use⬀](https://wiki.gentoo.org/wiki//etc/portage/package.use)

- You can install **unity-extra/diodon** clipboard manager for the Unity7:

  ```
  unity-indicators/unity-indicators-meta paste
  ```

- You can install mail notification with Messaging menu support **net-mail/mailnag**:

  ```
  unity-indicators/unity-indicators-meta mail
  ```

- You can enable Java global menu support **dev-java/jayatana** if you are using some Java applications:

  ```
  unity-indicators/unity-indicators-meta java8 java11 java17 java21 java25
  ```

- You can try **classic Unity look** (Ambiance theme, ubuntu-font-family, non-transparent panel with shadow, and horizontal Dash):

  ```
  unity-base/unity-meta classic-unity
  ```

  or you can choose individual changes yourself:

  ```
  unity-base/unity classic-dash classic-panel
  unity-base/unity-settings classic-fonts classic-theme
  ```

  NOTE: If you want to revert back to fonts-ubuntu, you must also run the command `emerge --oneshot media-fonts/fonts-ubuntu`

- You can try to turn on **system tray** support for all applications if you are missing some icons:

  ```
  unity-base/unity systray
  ```
