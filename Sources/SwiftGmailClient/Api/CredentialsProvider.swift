import Foundation
import os

public protocol CredentialsProvider {
    func getAccessToken() async -> String
}

public class SimpleCredentialsProvider: CredentialsProvider {

    private static let LOGGER = Logger.logger(SimpleCredentialsProvider.self)

    private let accessToken: String

    public init(accessToken: String) {
        self.accessToken = accessToken
    }

    public func getAccessToken() async -> String {
        return self.accessToken
    }
}

public actor RefreshingCredentialsProvider: CredentialsProvider {

    private static let LOGGER = Logger.logger(RefreshingCredentialsProvider.self)

    private static let TOKEN_URL = URL(string: "https://oauth2.googleapis.com/token")!

    private var accessToken: String
    private let refreshToken: String
    private var expiryDate: Date

    private let clientID: String
    private let clientSecret: String

    private var timer: DispatchSourceTimer?

    init(
        accessToken: String,
        refreshToken: String,
        clientID: String,
        clientSecret: String
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.clientID = clientID
        self.clientSecret = clientSecret
        self.expiryDate = Date()
    }

    public func getAccessToken() async -> String {
        if shouldRefresh() {
            await refreshAccessToken()
        }
        return self.accessToken
    }

    private func shouldRefresh() -> Bool {
        return Date().distance(to: expiryDate) <= 5 * 60
    }

    private func refreshAccessToken() async {
        var request = URLRequest(url: Self.TOKEN_URL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        _ = attempt {
            try JSONEncoder().encode(
                RefreshTokenRequest(
                    client_id: clientID,
                    client_secret: clientSecret,
                    refresh_token: refreshToken,
                    grant_type: "refresh_token"
                )
            )
        }.onSuccess { data in
            request.httpBody = data
        }

        await attempt {
            try await URLSession.shared.data(for: request)
        }.flatMap { data, response in
            attempt {
                try JSONDecoder().decode(RefreshTokenResponse.self, from: data)
            }
        }.onSuccess { response in
            self.accessToken = response.access_token
            self.expiryDate = Date().addingTimeInterval(response.expires_in)
        }.onError { error in
            Self.LOGGER.error("Failed to refresh access token: \(error.localizedDescription)")
        }
    }

    func startAutoRefresh(every timeInterval: TimeInterval) {
        let queue = DispatchQueue(label: "io.tezemie.SwiftGmail.oauthRefresh", qos: .background)
        timer = DispatchSource.makeTimerSource(queue: queue)
        timer?.schedule(
            deadline: .now() + timeInterval,
            repeating: timeInterval
        )

        timer?.setEventHandler {
            if self.shouldRefresh() {
                Task {
                    await self.refreshAccessToken()
                }
            }
        }
        timer?.resume()
    }

    func stopAutoRefresh() {
        timer?.cancel()
        timer = nil
    }
}

private struct RefreshTokenResponse: Codable {
    let access_token: String
    let expires_in: TimeInterval
}

private struct RefreshTokenRequest: Codable {
    let client_id: String
    let client_secret: String
    let refresh_token: String
    let grant_type: String
}