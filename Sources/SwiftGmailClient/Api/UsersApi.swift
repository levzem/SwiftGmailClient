struct UsersApi {
    private let apiClient: HttpApiClient

    init(httpApiClient: HttpApiClient) {
        self.apiClient = httpApiClient
    }

    var labels: LabelsApi {
        LabelsApi(httpApiClient: apiClient)
    }

    var messages: MessagesApi {
        MessagesApi(httpApiClient: apiClient)
    }
}