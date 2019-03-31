# About

This is a small command line tool that automatically adjust the brighness of [LG UltraFine 4k monitor](https://www.apple.com/shop/product/HKMY2VC/A/lg-ultrafine-4k-display).
Despite the fact that Apple collaborated on the monitor and it has an ambient light sensor, macOS 10.14 still does not support automatic brightness control; frustrating 😡.

I found

* <https://bugzilla.mozilla.org/show_bug.cgi?id=793728#attach_664102> and
* [ddcctl](https://github.com/kfix/ddcctl) from [kfix](https://github.com/kfix)

and combined them to this small tool.

# How to build

First clone the repository.
Then,

```bash
$ git submodule update --init
$ xcodebuild -derivedDataPath build -configuration Release -scheme ultrafine-auto-brightness clean build
```

The executable `ultrafine-auto-brighness` can be found in `build/Build/Products/Release`.
Put the executable under `/usr/local/opt`.
Copy `com.qvacua.ultrafine-auto-brightness.plist` to `~/Library/LaunchAgents` and load it using

```bash
$ launchctl load -w ~/Library/LaunchAgents/com.qvacua.ultrafine-auto-brightness.plist
```

It works on my machine; your mileage may vary.
