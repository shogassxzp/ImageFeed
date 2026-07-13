# ImageFeed

ImageFeed is an iOS Unsplash client with authorization, profile loading, a paginated photo feed, likes, and full-screen image viewing.

## Overview

The project focuses on real app flows that are common in production iOS development: OAuth authorization, token storage, networking, image loading, presentation architecture, and automated tests.

## Features

- OAuth authorization through WebView
- Access token storage in Keychain
- Splash screen with auth state handling
- User profile loading
- Profile image loading
- Logout flow with token cleanup
- Paginated image feed
- Like and unlike photos
- Full-screen image viewer
- Loading HUD for blocking operations
- Unit tests for WebView, profile, and image list logic
- UI tests for feed and profile flows

## Tech Stack

- Swift
- UIKit
- MVP
- URLSession
- WebKit
- Kingfisher
- SwiftKeychainWrapper
- ProgressHUD
- XCTest

## Architecture

ImageFeed is split by feature and uses presenters for presentation logic:

```text
ImageFeed/
├── Auth/            # Auth screen, OAuth service, WebView flow
├── ImageFeed/       # App entry, helpers, feed, profile, tab bar
├── ImageFeedTests/  # Unit tests
└── ImageFeedUITests/# UI tests
```

Important modules:

- `OAuth2Service` exchanges authorization code for an access token.
- `OAuth2TokenStorage` stores the token securely.
- `AuthHelper` builds authorization requests and extracts auth codes.
- `WebViewPresenter` manages WebView progress and auth code detection.
- `ImageListService` loads photos and changes like state.
- `ImageListPresenter` prepares feed data for the view.
- `ProfileService` and `ProfileImageService` load profile information.
- `ProfileLogoutService` clears auth data on logout.

## Dependencies

Swift Package Manager dependencies:

- [Kingfisher](https://github.com/onevcat/Kingfisher)
- [ProgressHUD](https://github.com/relatedcode/ProgressHUD)
- [SwiftKeychainWrapper](https://github.com/jrendel/SwiftKeychainWrapper)

## Tests

The project includes:

- `WebViewTest`
- `ProfileTest`
- `ImageListTest`
- `ImageFeedUITests`

## Getting Started

1. Open `ImageFeed.xcodeproj` in Xcode.
2. Configure Unsplash OAuth constants in `AuthConfiguration`.
3. Select the `ImageFeed` scheme.
4. Run on an iPhone simulator.

## Repository

[github.com/shogassxzp/ImageFeed](https://github.com/shogassxzp/ImageFeed)
