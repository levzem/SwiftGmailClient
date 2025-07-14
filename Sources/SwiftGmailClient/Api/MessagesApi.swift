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
    public init(ids: [String], addLabelIds: [String]? = nil, removeLabelIds: [String]? = nil) {
        self.ids = ids
        self.addLabelIds = addLabelIds
        self.removeLabelIds = removeLabelIds
    }

    public let ids: [String]
    public let addLabelIds: [String]?
    public let removeLabelIds: [String]?
}

public struct ListMessagesRequest: Codable {
    public let maxResults: UInt32?
    public let pageToken: String?
    public let q: String?
    public let labelIds: [String]?
    public let includeSpamTrash: Bool?
}

public struct ListMessagesResponse: Codable {
    public let messages: [MessageId]
    public let nextPageToken: String?
    public let resultSizeEstimate: Int?
}

public struct ModifyMessageRequest: Codable {
    public let addLabelIds: [String]?
    public let removeLabelIds: [String]?

    public init(addLabelIds: [String]? = nil, removeLabelIds: [String]? = nil) {
        self.addLabelIds = addLabelIds
        self.removeLabelIds = removeLabelIds
    }
}

public struct SendMessageRequest: Codable {
    public let raw: String
}

// MARK: - Models
public struct MessageId: Codable, Equatable {
    public let id: String
    public let threadId: String
}

public struct MessageMeta: Codable, Equatable {
    public let id: String
    public let threadId: String
    public let labelIds: [String]
}

public struct Message: Codable, Equatable {
    public let id: String
    public let threadId: String
    public let labelIds: [String]
    public let snippet: String
    public let payload: MessagePayload
    public let sizeEstimate: Int?
    public let historyId: String?
    public let internalDate: String?
}

public struct MessagePayload: Codable, Equatable {
    public let partId: String?
    public let mimeType: String
    public let filename: String?
    public let headers: [MessageHeader]
    public let body: MessageBody?
    public let parts: [MessagePayload]?
}

public struct MessageHeader: Codable, Equatable {
    public let name: String
    public let value: String
}

public struct MessageBody: Codable, Equatable {
    public let attachmentId: String?
    public let size: Int
    public let data: String?
}