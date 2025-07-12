struct LabelsApi {
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

    public func list() async -> Result<ListLabelsResponse, ApiError> {
        return await apiClient.get(
            endpoint: "/users/me/labels",
            responseType: ListLabelsResponse.self
        )
    }

    public func update(request: UpdateLabelRequest) async -> Result<Label, ApiError> {
        return await apiClient.update(
            endpoint: "/users/me/labels/\(request.id)",
            request: request,
            responseType: Label.self
        )
    }
}

// MARK: - Request and Response Models
public struct CreateLabelRequest: Codable {
    let name: String
    let labelListVisibility: LabelListVisibility?
    let messageListVisibility: MessageListVisibility?

    init(
        name: String,
        labelListVisibility: LabelListVisibility? = nil,
        messageListVisibility: MessageListVisibility? = nil
    ) {
        self.name = name
        self.labelListVisibility = labelListVisibility
        self.messageListVisibility = messageListVisibility
    }
}

public struct ListLabelsResponse: Codable {
    let labels: [Label]
}

public struct UpdateLabelRequest: Codable {
    let id: String
    let name: String
    let labelListVisibility: LabelListVisibility
    let messageListVisibility: MessageListVisibility
}

// MARK: - Models
public struct Label: Codable {
    let id: String
    let name: String
    let messageListVisibility: MessageListVisibility
    let labelListVisibility: LabelListVisibility
    let type: Type
    let messagesTotal: Int
    let messagesUnread: Int
    let threadsTotal: Int
    let threadsUnread: Int
}

public enum MessageListVisibility: String, Codable, CaseIterable {
    case show = "show"
    case hide = "hide"
}

public enum LabelListVisibility: String, Codable, CaseIterable {
    case labelShow = "labelShow"
    case labelHide = "labelHide"
    case labelShowIfUnread = "labelShowIfUnread"
}

public enum Type: String, Codable, CaseIterable {
    case system = "system"
    case user = "user"
}
