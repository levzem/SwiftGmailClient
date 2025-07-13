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
            items.append(URLQueryItem(name: key, value: "\(value)"))
        }

        var comps = URLComponents()
        comps.queryItems = items
        return comps.percentEncodedQuery ?? ""
    }
}