[![Preview of Gentoo Unity⁷ Desktop][preview_image]][preview_image_url]

# Gentoo Unity⁷ Desktop

A Gentoo overlay to build the Unity7 user interface.

- [Build instructions][build]
- [USE flag tips][tips]
- [Source URIs][uris]
- [Join the Telegram group⬀][tg]

#

- [Forked from unity-gentoo][fork]
- [About the Unity7⬀][wiki]

#

###### It defaults to the Gentoo stable software branch for the system's architecture amd64 (except `app-backup/deja-dup` from the Gentoo testing branch, see [accept_keywords file][upak]). You can build `www-client/firefox` from the Gentoo testing branch as *unity-menubar.patch* is available for both branches, the stable ([extended support release][fesr]) and the testing ([the latest release][ftlr]).

[//]: # (LINKS)
[build]: docs/build_instructions.md
[fesr]: profiles/ehooks/www-client/firefox:esr/files
[ftlr]: profiles/ehooks/www-client/firefox:rapid/files
[fork]: https://github.com/shiznix/unity-gentoo
[upak]: profiles/unity-portage.paccept_keywords
[preview_image]: https://github.com/c4pp4/gentoo-unity7/blob/master/docs/assets/preview.png "Preview of Gentoo Unity⁷ Desktop"
[preview_image_url]: https://raw.githubusercontent.com/c4pp4/gentoo-unity7/master/docs/assets/preview.png
[tg]: https://t.me/gentoo_unity7
[tips]: docs/use_flag_tips.md
[uris]: docs/source_uris.md
[wiki]: https://en.wikipedia.org/wiki/Unity_(user_interface)
