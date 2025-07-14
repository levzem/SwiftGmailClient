public struct UsersApi {
    private let apiClient: HttpApiClient

    init(httpApiClient: HttpApiClient) {
        self.apiClient = httpApiClient
    }

    public var labels: LabelsApi {
        LabelsApi(httpApiClient: apiClient)
    }

    public var messages: MessagesApi {
        MessagesApi(httpApiClient: apiClient)
    }
}