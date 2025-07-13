import Foundation
import os

extension Logger {
    static func logger<T>(_ type: T.Type, filePath: String = #fileID) -> Logger {
        let group = filePath.split(separator: "/")
            .filter { part in
                !part.starts(with: String(describing: type))
            }
            .joined(separator: ".")
        return Logger(
            subsystem: !group.isEmpty ? "SwiftGmail.\(group)" : "SwiftGmail",
            category: String(describing: type)
        )
    }
}
