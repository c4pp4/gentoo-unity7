# Source URIs

- **default** (see [eclass][ec] and [ehooks][eh])

  ```
  https://launchpad.net/ubuntu
  ```

  When Launchpad fails, ebuilds and ehooks try the other sources in [profiles/thirdpartymirrors][tpm]: the independent Ubuntu archive mirrors, the Ubuntu archive and the old releases archive.

- **dev-java/jayatana**

  ```
  https://gitlab.com/vala-panel-project/vala-panel-appmenu
  ```

- **unity-extra/indicator-netspeed**

  ```
  https://github.com/GGleb/indicator-netspeed-unity
  ```

- **unity-extra/indicator-privacy**

  ```
  https://www.florian-diesch.de/software/indicator-privacy
  ```

- **x11-plugins/mailnag-messagingmenu-plugin**

  ```
  https://github.com/pulb/mailnag-messagingmenu-plugin
  ```

[//]: # (LINKS)
[eh]: ../ehooks/templates/fetch_debian.template#L31
[ec]: ../eclass/ubuntu-versionator.eclass#L59
[tpm]: ../profiles/thirdpartymirrors
