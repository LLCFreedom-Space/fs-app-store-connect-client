# FSAppStoreConnectClient

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
![GitHub release (with filter)](https://img.shields.io/github/v/release/LLCFreedom-Space/fs-app-store-connect-client)
 [![Read the Docs](https://readthedocs.org/projects/docs/badge/?version=latest)](https://llcfreedom-space.github.io/fs-app-store-connect-client/)
![example workflow](https://github.com/LLCFreedom-Space/fs-app-store-connect-client/actions/workflows/docc.yml/badge.svg?branch=main)
![example workflow](https://github.com/LLCFreedom-Space/fs-app-store-connect-client/actions/workflows/lint.yml/badge.svg?branch=main)
![example workflow](https://github.com/LLCFreedom-Space/fs-app-store-connect-client/actions/workflows/test.yml/badge.svg?branch=main)
 [![codecov](https://codecov.io/github/LLCFreedom-Space/fs-app-store-connect-client/graph/badge.svg?token=2EUIA4OGS9)](https://codecov.io/github/LLCFreedom-Space/fs-app-store-connect-client)

This Swift package provides a client library for interacting with the App Store Connect API. It leverages the power of [Swift OpenAPI Generator](https://github.com/apple/swift-openapi-generator/tree/main) to automatically generate code from the provided OpenAPI specification file (openapi.yaml).

## Features

- Find and list your apps in App Store Connect using secure JWT-authenticated requests.
- Get a list of all App Store versions of your app across all platforms using secure JWT-authenticated requests.
- Handles JSON formats response.
- Implemented control over the number of requests from users and handling of rate limit errors.
- Providing automatically retrying HTTP requests based on customizable retry failed signals and delay strategies.
- Throws informative errors for server errors and not found cases.
- Ensure test coverage for code to guarantee robustness and reliability.

## Installation

1. Add the package dependency to your Package.swift file:

```swift
dependencies: [
.package(url: "https://github.com/LLCFreedom-Space/fs-app-store-connect-client", from: "1.0.0")
]
```

2. Import the library in your Swift code:

```swift
import AppStoreConnectClient
```

## Usage
Here's an example of how to use the AppStoreConnectClient to fetch information about list of your apps in App Store Connect:
```swift
let credentials = Credentials(
    issuerId: "<ISSUER_ID>"
    keyId: "<KEY_ID>"
    privateKey:
        """
        -----BEGIN PRIVATE KEY-----
                PRIVATE KEY
        -----END PRIVATE KEY-----
        """,
    expireDuration: "<TIME_INTERVAL>"
    )
let client = try AppStoreConnectClient(with: credentials)
do {
let fetchedApps = try await client.fetchApps()
// ... access to properties of apps
} catch {
print("Error fetching: \(error)")
}
```

Here's an example of how to use the AppStoreConnectClient to fetch information about versions of your app:
```swift
let credentials = Credentials(
    issuerId: "<ISSUER_ID>"
    keyId: "<KEY_ID>"
    privateKey:
        """
        -----BEGIN PRIVATE KEY-----
                PRIVATE KEY
        -----END PRIVATE KEY-----
        """,
    expireDuration: "<TIME_INTERVAL>"
    )
let client = try AppStoreConnectClient(with: credentials)
do {
let fetchedApps = try await client.fetchApps()
let apps = try await client.fetchApps()
guard let app = apps.first(where: { $0.bundleId == "your.bundle.id" }) else {
        throw AppStoreConnectError.invalidBundleId
    }
let releases = try await client.fetchVersions(for: app)
// ... access to properties of apps
} catch {
print("Error fetching: \(error)")
}
```

## added endpoints??? read markdown

## Generation???

## Contributions

We welcome contributions to this project! Please feel free to open issues or pull requests to help improve the package.

## Links

LLC Freedom Space – [@LLCFreedomSpace](https://twitter.com/llcfreedomspace) – [support@freedomspace.company](mailto:support@freedomspace.company)

Distributed under the GNU AFFERO GENERAL PUBLIC LICENSE Version 3. See [LICENSE.md][license-url] for more information.

 [GitHub](https://github.com/LLCFreedom-Space)

[swift-image]:https://img.shields.io/badge/swift-5.8-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-GPLv3-blue.svg
[license-url]: LICENSE
