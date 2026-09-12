<h1 align="center">Euro Office (Unraid wrapper)</h1>

<p align="center">
<a href="https://github.com/junkerderprovinz/euro-office/actions/workflows/build.yml"><img src="https://github.com/junkerderprovinz/euro-office/actions/workflows/build.yml/badge.svg" alt="Build"></a>
<a href="https://github.com/junkerderprovinz/euro-office/actions/workflows/lint.yml"><img src="https://github.com/junkerderprovinz/euro-office/actions/workflows/lint.yml/badge.svg" alt="Lint"></a>
<img src="https://img.shields.io/badge/image-ghcr.io%2Fjunkerderprovinz%2Feuro--office-blue" alt="Image">
<img src="https://img.shields.io/badge/arch-amd64%20%7C%20arm64-informational" alt="Arch">
<img src="https://img.shields.io/badge/Unraid-Community%20Applications-orange" alt="Unraid">
<img src="https://img.shields.io/badge/License-AGPL--3.0-blue?logo=gnu" alt="License">
</p>

<p align="center">
One-click <a href="https://github.com/euro-office/documentserver">Euro Office</a> document server for Unraid: fixes a real upstream Data-volume permission bug, no configuration required.
</p>

<p align="center">
One knight's job: I build it, keep it running, work through the issues and add what people ask for, until nothing is missing. No accounts, no telemetry, no ads. No trial, no tier, no asterisk. Nothing readable ever leaves your own walls.
</p>

<p align="center">
If it has earned a place on your computer or server, a donation covers what it costs: the domain, the server, and the evenings that go into it. It also makes this knight's heart beat a little faster. Three ways below, whichever suits you.
</p>

## Table of Contents

1. [About](#1-about)
2. [Why this wrapper exists](#2-why-this-wrapper-exists)
3. [Installation](#3-installation)
4. [Configuration](#4-configuration)
5. [Troubleshooting](#5-troubleshooting)
6. [Support this project](#6-support-this-project)

<br>

## 1. About

[Euro Office](https://github.com/euro-office/documentserver) is a European document server, API-compatible with ONLYOFFICE Document Server. It plugs into [OpenCloud](https://github.com/junkerderprovinz/opencloud) (and any other WOPI host) as a browser-based document editor for Word/Excel/PowerPoint-format files.

This repository packages the official `ghcr.io/euro-office/documentserver` image for one-click use on Unraid, via the Community Applications template maintained in [unraid-apps](https://github.com/junkerderprovinz/unraid-apps).

<br>

## 2. Why this wrapper exists

The upstream image ships with a real permission bug: the `chown -R ds:ds` step that should hand ownership of the `Data` volume to the `ds` user (the account every internal service actually runs as) is commented out in the vendor's own build. On a fresh bind-mounted `Data` folder - exactly what Unraid creates - this means the document-server's own admin panel and, in some configurations, document editing itself fail with a permission error.

This wrapper adds nothing to the image except a small extra process that heals `Data`'s ownership on boot, so the container works correctly out of the box. Nothing else about the upstream image is modified. Reported upstream: see the repository's issues for the tracking link once filed.

<br>

## 3. Installation

Community Applications → search **Euro Office** → install. Or import the template directly:

```
https://raw.githubusercontent.com/junkerderprovinz/unraid-apps/main/euro-office/euro-office.xml
```

<br>

## 4. Configuration

The template exposes the same environment variables as the upstream image (`JWT_SECRET`, `WOPI_ENABLED`, `USE_UNAUTHORIZED_STORAGE`, and so on) - see the field descriptions in the template itself. The one setting that matters most: **`JWT_SECRET` here must be the exact same string as the "Office WOPI secret" field in your OpenCloud (or other WOPI host) container.** They sign and verify the same tokens; if they differ, documents fail to open with "document security token is not correctly formed."

<br>

## 5. Troubleshooting

**Admin panel / document editing fails with a permission error.** This wrapper's whole purpose is fixing exactly that (see [§2](#2-why-this-wrapper-exists)) - make sure you're running the wrapped image (`junkerderprovinz/euro-office`), not the raw upstream image directly.

**"Document security token is not correctly formed."** The `JWT_SECRET` here and the WOPI host's matching secret field don't agree - see [§4](#4-configuration).

For anything else, please [open an issue](https://github.com/junkerderprovinz/euro-office/issues).

<br>

## 6. Support this project

Problems, wishes or suggestions? Don't hesitate to open an [issue](https://github.com/junkerderprovinz/euro-office/issues).

One knight's job: I build it, keep it running, work through the issues and add what people ask for, until nothing is missing. No accounts, no telemetry, no ads. No trial, no tier, no asterisk. Nothing readable ever leaves your own walls.

If it has earned a place on your computer or server, a donation covers what it costs: the domain, the server, and the evenings that go into it. It also makes this knight's heart beat a little faster. Three ways below, whichever suits you.

<p align="center">
  <a href="https://buymeacoffee.com/junkerderprovinz"><img src="https://raw.githubusercontent.com/junkerderprovinz/junkerderprovinz/main/donate/buttons/button-buy-me-a-coffee-live.svg" alt="Buy me a coffee" width="160"></a>
  &nbsp;
  <a href="https://paypal.me/hallelujadesign"><img src="https://raw.githubusercontent.com/junkerderprovinz/junkerderprovinz/main/donate/buttons/button-paypal-live.svg" alt="PayPal" width="160"></a>
  &nbsp;
  <a href="https://junkerderprovinz.github.io/junkerderprovinz/"><img src="https://raw.githubusercontent.com/junkerderprovinz/junkerderprovinz/main/donate/buttons/button-crypto-live.svg" alt="Donate with crypto" width="160"></a>
</p>
