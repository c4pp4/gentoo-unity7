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
  unity-indicators/unity-indicators-meta java
  ```

- You can try **Ubuntu Unity** theme as the default one if you don't like **Ambiance**:

  ```
  unity-base/unity-settings ubuntu-unity
  ```

- You can try **Dash** classic look - horizontal with bottom scope bar:

  ```
  unity-base/unity classic
  ```

- You can try classic fonts **media-fonts/ubuntu-font-family** instead of newer **media-fonts/fonts-ubuntu**:

  ```
  unity-base/unity-settings ubuntu-classic
  ```

- You can try to turn on **system tray** support for all applications if you are missing some icons:

  ```
  unity-base/unity systray
  ```
