import Foundation

public class Gmail {

    private let httpApiClient: HttpApiClient

    init(oauthCredentials: OAuthCredentials) {
        self.httpApiClient = HttpApiClient(
            apiUrl: URL(string: "https://gmail.googleapis.com/gmail/v1")!,
            accessToken: oauthCredentials.accessToken,
            refreshToken: oauthCredentials.refreshToken
        )
    }

    var users: UsersApi {
        UsersApi(httpApiClient: httpApiClient)
    }
}

public struct OAuthCredentials {
    let accessToken: String
    let refreshToken: String
}