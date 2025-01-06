# gergle

The second season for the frontend of the collaborative music player system grzegorz, succeeding the [grzegorz-clients](https://git.pvv.ntnu.no/Grzegorz/grzegorz-clients) GUI.

This player is meant to be used with the [websocket API from greg-ng](https://git.pvv.ntnu.no/Projects/greg-ng/src/branch/main/src/api/websocket_v1.rs).

### Getting started

- [Install flutter](https://docs.flutter.dev/get-started/install) (or get your environment with nix)

- [Run a local instance of greg-ng](https://git.pvv.ntnu.no/Grzegorz/greg-ng/src/branch/main/README.md)

- Start your app with `flutter run`.

### Running on web

While the software is maintained as a native desktop app for linux, we don't have development capacity to ensure it runs for mac and windows as well. But fear not, it builds as a webpage.

If you have chromiumm installed, you can use `flutter run -d chrome`

If you do not have chromium installed, you can build the website first, and then host it in a webserver of your choice. Here's an example with python's builtin webserver:

```bash
flutter build web
python -m http.server -d build/web/
```

