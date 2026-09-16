[![Preview of Gentoo Unity⁷ Desktop][preview_image]][preview_image_url]

# Gentoo Unity⁷ Desktop

A Gentoo overlay for building and running the Unity7 desktop environment.

- [Build instructions][build]
- [USE flag tips][tips]
- [Additional packages list][addp]
- [Source URIs list][uris]
- [Join the Telegram group⬀ (the community home)][tg]

#

- [Forked from unity-gentoo][fork]
- [About Unity7⬀][wiki]
- [Gentoo Lomiri Desktop⬀ (formerly Unity8)][gld]

#

###### The overlay currently supports amd64, uses the Gentoo stable branch by default, and requires systemd. Some Unity integration patches are applied to packages from the main Gentoo repository through the ehooks patching system. You can build `www-client/firefox` from either the Gentoo stable or testing branch, since *unity-menubar.patch* is available for both slots: `esr` and `rapid`. The same applies to `mail-client/thunderbird` (slots `0/esr` and `0/stable`).

[//]: # (LINKS)
[addp]: docs/additional_packages.md
[build]: docs/build_instructions.md
[fork]: https://github.com/shiznix/unity-gentoo
[gld]: https://gitlab.com/renegart/gentoo-lomiri
[preview_image]: https://github.com/c4pp4/gentoo-unity7/blob/master/docs/assets/preview.png "Preview of Gentoo Unity⁷ Desktop"
[preview_image_url]: https://raw.githubusercontent.com/c4pp4/gentoo-unity7/master/docs/assets/preview.png
[tg]: https://t.me/gentoo_unity7_lomiri
[tips]: docs/use_flag_tips.md
[uris]: docs/source_uris.md
[wiki]: https://en.wikipedia.org/wiki/Unity_(user_interface)
