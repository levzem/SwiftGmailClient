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
    var gmail: Gmail = Gmail(credentialsProvider: SimpleCredentialsProvider(accessToken: "lol"))

    override func setUp() {
        super.setUp()
        try? loadDotEnv()
        self.gmail = Gmail(
            credentialsProvider: RefreshingCredentialsProvider(
                accessToken: ProcessInfo.processInfo.environment["GMAIL_OAUTH_ACCESS_TOKEN"]!,
                refreshToken: ProcessInfo.processInfo.environment["GMAIL_OAUTH_REFRESH_TOKEN"]!,
                clientID: ProcessInfo.processInfo.environment["GMAIL_OAUTH_CLIENT_ID"]!,
                clientSecret: ProcessInfo.processInfo.environment["GMAIL_OAUTH_CLIENT_SECRET"]!
            )
        )
    }
}
