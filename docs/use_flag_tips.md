# USE flag tips

- **unity-extra/diodon** - clipboard manager for the Unity7:

  ```
  unity-indicators/unity-indicators-meta paste
  ```

- **net-mail/mailnag** - mail notification with Messaging menu support:

  ```
  unity-indicators/unity-indicators-meta mail
  ```

- **dev-java/jayatana** - enable Global menu for Java applications:

  ```
  unity-indicators/unity-indicators-meta java
  ```

- enable **system tray** support for all applications:

  ```
  unity-base/unity systray
  ```

- disable **Evolution Data Server** support:

  ```
  unity-indicators/indicator-datetime -eds
  ```

- disable **Wayland** support globally:

  ```
  */* -wayland
  ```
