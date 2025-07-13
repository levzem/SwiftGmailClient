import Foundation

public class Gmail {

    private let httpApiClient: HttpApiClient

    init(credentialsProvider: CredentialsProvider) {
        self.httpApiClient = HttpApiClient(
            apiUrl: URL(string: "https://gmail.googleapis.com/gmail/v1")!,
            credentialsProvider: credentialsProvider
        )
    }

    var users: UsersApi {
        UsersApi(httpApiClient: httpApiClient)
    }
}