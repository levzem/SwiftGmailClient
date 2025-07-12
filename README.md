# Swift Gmail SDK

A Swift library for interacting with the Gmail API, allowing developers to easily integrate Gmail functionalities into
their iOS and macOS applications.

## Supported Features
This is still a work in progress, however, feel free to open an issue and request a feature. They are quick to add.


- [x] labels 
- [ ] messages (partial support) 

## Installation

You can install the Swift Gmail SDK using the Swift Package Manager. Add the following dependency to your
`Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/levzem/SwiftGmail", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: ["SwiftGmail"]
    )
]
```

## Usage

To use the Swift Gmail client in your application, follow these steps:

1. **Acquire the user's OAuth 2.0 credentials**: Before using this client, you will need to ask the user to authenticate
   your application with their Google account. This typically involves using the Google Sign-In SDK or manually handling
   OAuth 2.0 flows.

    - For Google Sign-In, you can follow
      the [Google Sign-In for iOS documentation](https://developers.google.com/identity/sign-in/ios/start-integrating)
      to set up the necessary configurations and obtain the credentials.
    - Alternatively, you can use OAuth 2.0 directly by following
      the [OAuth 2.0 documentation](https://developers.google.com/identity/protocols/oauth2).

2. **Import the SDK**: In your Swift file, import the Swift Gmail module.

   ```swift
   import SwiftGmail
   ```

3. **Initialize the client**: Initialize the client with your user's OAuth 2.0 credentials.

   ```swift
    let gmailService = GmailService(
        oauthCredentials: OAuthCredentials(
            accessToken: "<USER_ACCESS_TOKEN>", 
            refreshToken: "<USER_REFRESH_TOKEN>"
        )
    )
    ```

4. **List user's labels**: To list a user's email labels, create a `ListLabelsRequest` object and call the `list` method.

   ```swift
   let result = await gmail.users.labels.list()
   switch result {
         case .success(let response):
              print("Labels found: \(response.labels)")
         case .failure(let error):
              print("Failed to fetch user's labels: \(error.localizedDescription)")
         }
    }
    ```
5. The call pattern mirrors the Google Gmail REST resources, so you can refer to the
   [Gmail API documentation](https://developers.google.com/gmail/api/reference/rest) for more details on available
   methods and their parameters.

## Testing

To run the tests, you can use the following command in your terminal:

```bash
swift test
```

You will need to set up some OAuth credentials. You can do this by creating a `.env` file and adding the following lines:

```
GMAIL_OAUTH_ACCESS_TOKEN=<YOUR_ACCESS_TOKEN>
GMAIL_OAUTH_REFRESH_TOKEN=<YOUR_REFRESH_TOKEN>
```

Alternatively, you can set the environment variables directly in your terminal.

I would like to improve this in the future, but for now, this is the best way to test the library.