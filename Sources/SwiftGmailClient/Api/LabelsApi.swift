public struct LabelsApi {
    private let apiClient: HttpApiClient

    init(httpApiClient: HttpApiClient) {
        self.apiClient = httpApiClient
    }

    public func create(request: CreateLabelRequest) async -> Result<Label, ApiError> {
        return await apiClient.post(
            endpoint: "/users/me/labels",
            request: request,
            responseType: Label.self
        )
    }

    @discardableResult
    public func delete(labelId: String) async -> Result<EmptyResponse, ApiError> {
        return await apiClient.delete(
            endpoint: "/users/me/labels/\(labelId)"
        )
    }

    public func get(labelId: String) async -> Result<FullLabel, ApiError> {
        return await apiClient.get(
            endpoint: "/users/me/labels/\(labelId)",
            responseType: FullLabel.self
        )
    }

    public func list() async -> Result<ListLabelsResponse, ApiError> {
        return await apiClient.get(
            endpoint: "/users/me/labels",
            responseType: ListLabelsResponse.self
        )
    }

    public func update(request: UpdateLabelRequest) async -> Result<Label, ApiError> {
        return await apiClient.put(
            endpoint: "/users/me/labels/\(request.id)",
            request: request,
            responseType: Label.self
        )
    }
}

// MARK: - Request and Response Models
public struct CreateLabelRequest: Codable, Hashable, Sendable {
    public let name: String
    public let labelListVisibility: LabelListVisibility?
    public let messageListVisibility: MessageListVisibility?

    public init(
        name: String,
        labelListVisibility: LabelListVisibility? = nil,
        messageListVisibility: MessageListVisibility? = nil
    ) {
        self.name = name
        self.labelListVisibility = labelListVisibility
        self.messageListVisibility = messageListVisibility
    }
}

public struct ListLabelsResponse: Codable, Hashable, Sendable {
    public let labels: [Label]

    public init(labels: [Label]) {
        self.labels = labels
    }
}

public struct UpdateLabelRequest: Codable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let labelListVisibility: LabelListVisibility
    public let messageListVisibility: MessageListVisibility

    public init(
        id: String,
        name: String,
        labelListVisibility: LabelListVisibility,
        messageListVisibility: MessageListVisibility
    ) {
        self.id = id
        self.name = name
        self.labelListVisibility = labelListVisibility
        self.messageListVisibility = messageListVisibility
    }
}

// MARK: - Models
public struct Label: Codable, Equatable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let labelListVisibility: LabelListVisibility?
    public let messageListVisibility: MessageListVisibility?
    public let type: Type?

    public init(
        id: String,
        name: String,
        labelListVisibility: LabelListVisibility? = nil,
        messageListVisibility: MessageListVisibility? = nil,
        type: Type? = nil
    ) {
        self.id = id
        self.name = name
        self.labelListVisibility = labelListVisibility
        self.messageListVisibility = messageListVisibility
        self.type = type
    }
}

public struct FullLabel: Codable, Equatable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let labelListVisibility: LabelListVisibility?
    public let messageListVisibility: MessageListVisibility?
    public let type: Type
    public let messagesTotal: Int
    public let messagesUnread: Int
    public let threadsTotal: Int
    public let threadsUnread: Int

    public init(
        id: String,
        name: String,
        labelListVisibility: LabelListVisibility? = nil,
        messageListVisibility: MessageListVisibility? = nil,
        type: Type,
        messagesTotal: Int,
        messagesUnread: Int,
        threadsTotal: Int,
        threadsUnread: Int
    ) {
        self.id = id
        self.name = name
        self.labelListVisibility = labelListVisibility
        self.messageListVisibility = messageListVisibility
        self.type = type
        self.messagesTotal = messagesTotal
        self.messagesUnread = messagesUnread
        self.threadsTotal = threadsTotal
        self.threadsUnread = threadsUnread
    }
}

public enum MessageListVisibility: String, CaseIterable, Codable, Sendable {
    case show = "show"
    case hide = "hide"
}

public enum LabelListVisibility: String, CaseIterable, Codable, Sendable {
    case labelShow = "labelShow"
    case labelHide = "labelHide"
    case labelShowIfUnread = "labelShowIfUnread"
}

public enum Type: String, CaseIterable, Codable, Sendable {
    case system = "system"
    case user = "user"
}
