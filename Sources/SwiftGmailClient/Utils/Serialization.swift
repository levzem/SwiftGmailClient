import Foundation

extension Encodable {
    func asQueryString() -> String {
        guard
            let data = try? JSONEncoder().encode(self),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else { return "" }

        var items = [URLQueryItem]()
        dict.forEach { key, value in
            guard !(value is NSNull) else { return }
            let stringValue: String
            switch value {
                case let num as NSNumber:
                    if CFGetTypeID(num) == CFBooleanGetTypeID() {
                        stringValue = num.boolValue ? "true" : "false"
                    } else {
                        stringValue = num.stringValue
                    }
                case let b as Bool:
                    stringValue = b ? "true" : "false"
                case let arr as [Any]:
                    stringValue = arr.map { "\($0)" }.joined(separator: ",")
                default:
                    stringValue = "\(value)"
            }

            items.append(URLQueryItem(name: key, value: stringValue))
        }

        var comps = URLComponents()
        comps.queryItems = items
        return comps.percentEncodedQuery ?? ""
    }
}