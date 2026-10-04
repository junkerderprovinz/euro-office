"""The download buttons the README shows, read by gen_download_buttons.py.

Each entry names a button the generator knows and where it leads. The rows,
their order, the colours and the words are the generator's, the same in every
repository.
"""

REPO = "euro-office"

BUTTONS = {
    "unraid": "https://ca.unraid.net/apps/euro-office-01m59u11rtj6n9",
    # The image is only on GHCR. A browser cannot download it, so this opens
    # its package page, which carries the pull command and every tag.
    "docker": "https://github.com/junkerderprovinz/euro-office/pkgs/container/euro-office",
    # A release's "Source code (zip)" is the whole repository at that tag, and
    # GitHub gives the newest one no fixed address, so this leads to the release
    # that lists it.
    "source": "https://github.com/junkerderprovinz/euro-office/releases/latest",
}
