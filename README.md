# MKSandboxSync

MKSandboxSync is a debug-only iOS sandbox inspection SDK. Add it to an iOS app, start it in Debug builds, and use a browser or Mac tool to inspect and modify sandbox files and `UserDefaults`.

The first version intentionally has no third-party dependencies. It uses `Network.framework`, supports iOS 14 and later, and exposes a small HTTP API with optional Bonjour discovery.

## Install

Add this repository as a Swift Package dependency and link the `MKSandboxSync` product to the app target.

```swift
#if DEBUG
import MKSandboxSync

try? MKSandboxSync.shared.start(
    configuration: .init(
        serviceName: "MyApp Debug",
        requiresPairingToken: false
    )
)
#endif
```

## App Group data

To inspect a shared App Group container, enable the App Groups capability for the app target and add the same identifier to the SDK configuration:

```swift
try? MKSandboxSync.shared.start(
    configuration: .init(
        serviceName: "MyApp Debug",
        appGroupIdentifiers: [
            "group.com.example.myapp"
        ]
    )
)
```

When the entitlement is available at runtime, the web console and manifest expose a root like:

```text
/AppGroup:group.com.example.myapp
```

Files under that root support the same list, read, write, and delete operations as normal sandbox directories.

## Test endpoints

After the app starts, read the port from the Xcode console:

```text
[MKSandboxSync] MKSandboxSync started on port 12345.
```

Then open:

```text
http://<device-ip>:12345/mkss/console
http://<device-ip>:12345/mkss/manifest
http://<device-ip>:12345/mkss/files?path=/Documents
http://<device-ip>:12345/mkss/defaults
http://<device-ip>:12345/mkss/logs
```

## Web console

Open the `Web console` URL printed in Xcode. The page loads `/mkss/manifest`, lists every configured sandbox root, lets you click into directories, read file contents, edit text-like files, create files, and delete files or folders.

Save, create, and delete actions are two-step operations: the first click prepares the action, and the second click on `Confirm` sends the change to the device.

Write a file:

```bash
curl -X PUT --data 'hello' "http://<device-ip>:12345/mkss/file?path=/Documents/hello.txt"
```

Set a `UserDefaults` value:

```bash
curl -X POST -H 'Content-Type: application/json' \
  --data '{"key":"debugName","value":"MKSandboxSync"}' \
  "http://<device-ip>:12345/mkss/defaults"
```

## Safety defaults

- The SDK starts only in debug assertion builds unless `allowInReleaseBuild` is set.
- All file paths are restricted to configured sandbox roots.
- Deleting a whole root is blocked.
- Pairing token auth can be enabled with `requiresPairingToken`.

## Demo

Open `Demo/MKSandboxSyncDemo/MKSandboxSyncDemo.xcodeproj`, choose an iOS simulator or device, and run the `MKSandboxSyncDemo` scheme. The app writes sample sandbox data and starts the SDK automatically.
