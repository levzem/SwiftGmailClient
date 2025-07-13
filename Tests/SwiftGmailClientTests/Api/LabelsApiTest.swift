import Testing
@testable import SwiftGmailClient

class LabelsApiTest: BaseTest {

    func testCreate() async throws {
        let label = try
            (await gmail.users.labels.create(
                request: CreateLabelRequest(
                    name: "CreateTest",
                    labelListVisibility: .labelShow,
                    messageListVisibility: .hide
                )
            )).get()

        #expect(
            label
                == Label(
                    id: label.id,
                    name: "Test",
                    labelListVisibility: .labelShow,
                    messageListVisibility: .hide,
                    type: .user
                )
        )
        await gmail.users.labels.delete(labelId: label.id)
    }

    func testDelete() async throws {
        let label = try
            (await gmail.users.labels.create(
                request: CreateLabelRequest(
                    name: "DeleteTest",
                    labelListVisibility: .labelShow,
                    messageListVisibility: .hide
                )
            )).get()

        _ = try (await gmail.users.labels.delete(labelId: label.id)).get()

        let deletedLabel = await gmail.users.labels.get(labelId: label.id)
        #expect(deletedLabel == .failure(ApiError.failedRequest(httpCode: 404)))
    }

    func testGet() async throws {
        let label = try (await gmail.users.labels.get(labelId: "INBOX")).get()
        #expect(
            label
                == FullLabel(
                    id: "INBOX",
                    name: "INBOX",
                    labelListVisibility: .labelShow,
                    messageListVisibility: .hide,
                    type: .system,
                    messagesTotal: label.messagesTotal,
                    messagesUnread: label.messagesUnread,
                    threadsTotal: label.threadsTotal,
                    threadsUnread: label.threadsUnread
                )
        )
    }

    func testList() async throws {
        let response = try (await gmail.users.labels.list()).get()
        #expect(response.labels.count > 0)
    }

    func testUpdate() async throws {
        var label = try
            (await gmail.users.labels.create(
                request: CreateLabelRequest(
                    name: "UpdateTest",
                    labelListVisibility: .labelShow,
                    messageListVisibility: .hide
                )
            )).get()

        label = try (await gmail.users.labels.update(
            request: UpdateLabelRequest(
                id: label.id,
                name: label.name,
                labelListVisibility: label.labelListVisibility!,
                messageListVisibility: .show
            )
        )).get()

        #expect(label.messageListVisibility == .show)

        await gmail.users.labels.delete(labelId: label.id)
    }
}