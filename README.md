<p align="center">
    <a href="https://github.com/povio/PovioKitAuthGoogle" alt="Package">
        <img src="https://img.shields.io/badge/SPM-Swift-lightgrey.svg" />
    </a>
    <a href="https://www.swift.org" alt="Swift">
        <img src="https://img.shields.io/badge/Swift-5.9-orange.svg" />
    </a>
    <a href="./LICENSE" alt="License">
        <img src="https://img.shields.io/badge/Licence-MIT-red.svg" />
    </a>
</p>

<p align="center">
    Welcome to <b>PovioKitAuthGoogle</b>.
    <br />An auth provider for social login with Google.
</p>

## Installation

### Swift Package Manager
- In Xcode, click `File` -> `Add Packages...`  
- Insert `https://github.com/povio/PovioKitAuthGoogle` in the Search field.
- Select a desired `Dependency Rule`. Usually "Up to Next Major Version" with "1.0.0".
- Select "Add Package" button and check `PovioKitAuthGoogle`.
- Select "Add Package" again and you are done.

## Setup

Please read [official documentation](https://developers.google.com/identity/sign-in/ios/start-integrating) from Google for all the details around the setup and integration.

## Usage

```swift
import PovioKitAuthCore
import PovioKitAuthGoogle

// initialization
let authenticator = GoogleAuthenticator()

// signIn user
let result = try await authenticator
  .signIn(from: <view-controller-instance>)

// signIn with Firebase (custom client ID + nonce)
let firebaseResult = try await authenticator.signIn(
  from: <view-controller-instance>,
  clientId: "<firebase-client-id>",
  nonce: .random(length: 32)
)

// active session with a non-expired access token
let isSignedIn = authenticator.isAuthenticated

// Google has a stored session that can be restored (e.g. show "Continue as …")
let canRestore = authenticator.hasSavedSession

// signOut user
authenticator.signOut() // all provider data regarding the user auth is cleared at this point

// handle url
authenticator.canOpenUrl(url, application: application, options: options)
// call this from `application:openURL:options:` in UIApplicationDelegate
```

## License

PovioKitAuthGoogle is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
