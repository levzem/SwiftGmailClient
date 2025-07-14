import Foundation
import Testing
@testable import SwiftGmailClient

class MessagesApiTest: BaseTest {

    func testBatchModify() async throws {
        // 1. Send an email
        let rawEmail = """
            From: \(self.testEmail)
            To: \(self.testEmail)
            Subject: BatchModifyTest

            This is a test email for batch modify.
            """
        let sentMessage = try
            (await gmail.users.messages.send(
                request: SendMessageRequest(raw: Data(rawEmail.utf8).base64EncodedString())
            )).get()

        _ = try
            (await gmail.users.messages.batchModify(
                request: BatchModifyMessagesRequest(
                    ids: [sentMessage.id],
                    addLabelIds: ["TRASH"],
                    removeLabelIds: ["INBOX"]
                )
            )).get()

        let modifiedMessage = try (await gmail.users.messages.get(messageId: sentMessage.id)).get()
        #expect(modifiedMessage.labelIds.contains("TRASH"))

        _ = await gmail.users.messages.trash(messageId: sentMessage.id)
    }

    func testDelete() async throws {
        // 1. Send an email
        let rawEmail = """
            From: \(self.testEmail)
            To: \(self.testEmail)
            Subject: DeleteTest

            This is a test email for delete.
            """
        let sentMessage = try
            (await gmail.users.messages.send(
                request: SendMessageRequest(raw: Data(rawEmail.utf8).base64EncodedString())
            )).get()

        _ = try (await gmail.users.messages.delete(messageId: sentMessage.id)).get()

        let result = await gmail.users.messages.get(messageId: sentMessage.id)
        #expect(result == .failure(ApiError.failedRequest(httpCode: 404)))
    }

    func testGet() async throws {
        let message = try
            (await gmail.users.messages.list(
                request: ListMessagesRequest(
                    maxResults: 1,
                    pageToken: nil,
                    q: nil,
                    labelIds: ["INBOX"],
                    includeSpamTrash: false
                )
            )).get().messages.first

        let messageId = message?.id ?? ""
        let email = try (await gmail.users.messages.get(messageId: messageId)).get()
        #expect(email.id == messageId)
    }

    func testList() async throws {
        let response = try
            (await gmail.users.messages.list(
                request: ListMessagesRequest(
                    maxResults: 10,
                    pageToken: nil,
                    q: nil,
                    labelIds: ["INBOX"],
                    includeSpamTrash: false
                )
            )).get()
        #expect(response.messages.count > 0)
    }

    func testModify() async throws {
        // 1. Send an email
        let rawEmail = """
            From: \(self.testEmail)
            To: \(self.testEmail)
            Subject: ModifyTest

            This is a test email for modify.
            """
        let sentMessage = try
            (await gmail.users.messages.send(
                request: SendMessageRequest(raw: Data(rawEmail.utf8).base64EncodedString())
            )).get()

        let modifiedMessage = try
            (await gmail.users.messages.modify(
                messageId: sentMessage.id,
                request: ModifyMessageRequest(addLabelIds: ["TRASH"], removeLabelIds: ["INBOX"])
            )).get()

        #expect(modifiedMessage.labelIds.contains("TRASH"))

        _ = await gmail.users.messages.trash(messageId: sentMessage.id)
    }

    func testSend() async throws {
        // 1. Send an email
        let rawEmail = """
            From: \(self.testEmail)
            To: \(self.testEmail)
            Subject: SendTest

            This is a test email for send.
            """
        let sentMessage = try
            (await gmail.users.messages.send(
                request: SendMessageRequest(raw: Data(rawEmail.utf8).base64EncodedString())
            )).get()

        let fetchedMessage = try (await gmail.users.messages.get(messageId: sentMessage.id)).get()
        #expect(fetchedMessage.id == sentMessage.id)

        _ = await gmail.users.messages.trash(messageId: sentMessage.id)
    }

    func testTrash() async throws {
        let rawEmail = """
            From: \(self.testEmail)
            To: \(self.testEmail)
            Subject: TrashTest

            This is a test email for trash.
            """
        let sentMessage = try
            (await gmail.users.messages.send(
                request: SendMessageRequest(raw: Data(rawEmail.utf8).base64EncodedString())
            )).get()

        let trashedMessage = try (await gmail.users.messages.trash(messageId: sentMessage.id)).get()

        #expect(trashedMessage.labelIds.contains("TRASH"))
    }
}