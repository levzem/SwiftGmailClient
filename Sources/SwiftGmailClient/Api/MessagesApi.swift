public struct MessagesApi {
    private let apiClient: HttpApiClient

    init(httpApiClient: HttpApiClient) {
        self.apiClient = httpApiClient
    }

    @discardableResult
    func batchModify(
        request: BatchModifyMessagesRequest
    ) async -> Result<EmptyResponse, ApiError> {
        return await apiClient.post(
            endpoint: "/users/me/messages/batchModify",
            request: request,
            responseType: EmptyResponse.self
        )
    }

    public func delete(messageId: String) async -> Result<EmptyResponse, ApiError> {
        return await apiClient.delete(
            endpoint: "/users/me/messages/\(messageId)"
        )
    }

    public func get(messageId: String) async -> Result<Message, ApiError> {
        return await apiClient.get(
            endpoint: "/users/me/messages/\(messageId)",
            responseType: Message.self
        )
    }

    public func list(request: ListMessagesRequest) async -> Result<ListMessagesResponse, ApiError> {
        return await apiClient.get(
            endpoint: "/users/me/messages?\(request.asQueryString())",
            responseType: ListMessagesResponse.self
        )
    }

    public func modify(messageId: String, request: ModifyMessageRequest) async -> Result<
        MessageMeta, ApiError
    > {
        return await apiClient.post(
            endpoint: "/users/me/messages/\(messageId)/modify",
            request: request,
            responseType: MessageMeta.self
        )
    }

    public func send(request: SendMessageRequest) async -> Result<MessageMeta, ApiError> {
        return await apiClient.post(
            endpoint: "/users/me/messages/send",
            request: request,
            responseType: MessageMeta.self
        )
    }

    public func trash(messageId: String) async -> Result<MessageMeta, ApiError> {
        return await apiClient.post(
            endpoint: "/users/me/messages/\(messageId)/trash",
            request: EmptyResponse(),
            responseType: MessageMeta.self
        )
    }
}

// MARK: - Request and Response Models
public struct BatchModifyMessagesRequest: Codable {
    init(ids: [String], addLabelIds: [String]? = nil, removeLabelIds: [String]? = nil) {
        self.ids = ids
        self.addLabelIds = addLabelIds
        self.removeLabelIds = removeLabelIds
    }

    let ids: [String]
    let addLabelIds: [String]?
    let removeLabelIds: [String]?
}

public struct ListMessagesRequest: Codable {
    let maxResults: UInt32?
    let pageToken: String?
    let q: String?
    let labelIds: [String]?
    let includeSpamTrash: Bool?
}

public struct ListMessagesResponse: Codable {
    let messages: [MessageId]
    let nextPageToken: String?
    let resultSizeEstimate: Int?
}

public struct ModifyMessageRequest: Codable {
    let addLabelIds: [String]?
    let removeLabelIds: [String]?

    init(addLabelIds: [String]? = nil, removeLabelIds: [String]? = nil) {
        self.addLabelIds = addLabelIds
        self.removeLabelIds = removeLabelIds
    }
}

public struct SendMessageRequest: Codable {
    let raw: String
}

// MARK: - Models
public struct MessageId: Codable, Equatable {
    let id: String
    let threadId: String
}

public struct MessageMeta: Codable, Equatable {
    let id: String
    let threadId: String
    let labelIds: [String]
}

public struct Message: Codable, Equatable {
    let id: String
    let threadId: String
    let labelIds: [String]
    let snippet: String
    let payload: MessagePayload
    let sizeEstimate: Int?
    let historyId: String?
    let internalDate: String?
}

public struct MessagePayload: Codable, Equatable {
    let partId: String?
    let mimeType: String
    let filename: String?
    let headers: [MessageHeader]
    let body: MessageBody?
    let parts: [MessagePayload]?
}

public struct MessageHeader: Codable, Equatable {
    let name: String
    let value: String
}

public struct MessageBody: Codable, Equatable {
    let attachmentId: String?
    let size: Int
    let data: String?
}