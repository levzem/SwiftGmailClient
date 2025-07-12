import Testing
import XCTest

@testable import SwiftGmail

func loadDotEnv(at path: String = ".env") throws {
    let text = try attempt {
        try String(contentsOfFile: path)
    }.get()

    for line in text.split(whereSeparator: \.isNewline) {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard !trimmed.hasPrefix("#"), let eq = trimmed.firstIndex(of: "=") else { continue }
        let key = String(trimmed[..<eq])
        let value = String(trimmed[trimmed.index(after: eq)...])
        setenv(key, value, 1)
    }
}

class BaseTest: XCTestCase {
    var gmail: Gmail = Gmail(
        oauthCredentials: OAuthCredentials(accessToken: "fake", refreshToken: "fake")
    )

    override func setUp() {
        super.setUp()
        try? loadDotEnv()
        let accessToken = ProcessInfo.processInfo.environment["GMAIL_OAUTH_ACCESS_TOKEN"]
        let refreshToken = ProcessInfo.processInfo.environment["GMAIL_OAUTH_REFRESH_TOKEN"]
        self.gmail = Gmail(
            oauthCredentials: OAuthCredentials(
                accessToken: accessToken!,
                refreshToken: refreshToken!
            )
        )
    }
}
