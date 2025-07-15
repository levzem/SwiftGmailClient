import Foundation
import os

class HttpApiClient {
    private static let LOGGER: Logger = Logger.logger(HttpApiClient.self)

    let apiUrl: URL
    let credentialsProvider: CredentialsProvider

    init(apiUrl: URL, credentialsProvider: CredentialsProvider) {
        self.apiUrl = apiUrl
        self.credentialsProvider = credentialsProvider
    }

    func delete(endpoint: String) async -> Result<EmptyResponse, ApiError> {
        return await send(httpMethod: .delete, endpoint: endpoint, responseType: EmptyResponse.self)
    }

    func get<T: Decodable>(endpoint: String, responseType: T.Type) async -> Result<T, ApiError> {
        return await send(
            httpMethod: .get,
            endpoint: endpoint,
            responseType: responseType
        )
    }

    func post<T: Decodable>(
        endpoint: String,
        request: Codable,
        responseType: T.Type
    ) async -> Result<T, ApiError> {
        return await send(
            httpMethod: .post,
            endpoint: endpoint,
            request: request,
            responseType: responseType
        )
    }

    func put<T: Decodable>(
        endpoint: String,
        request: Codable,
        responseType: T.Type
    ) async -> Result<T, ApiError> {
        return await send(
            httpMethod: .put,
            endpoint: endpoint,
            request: request,
            responseType: responseType
        )
    }

    private func send<T: Decodable>(
        httpMethod: HttpMethod,
        endpoint: String,
        request: Codable? = nil,
        responseType: T.Type
    ) async -> Result<T, ApiError> {
        let accessToken = await credentialsProvider.getAccessToken()
        var httpRequest = URLRequest(url: url(endpoint))
        httpRequest.httpMethod = httpMethod.rawValue
        httpRequest.setValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField: "Authorization"
        )

        if let request = request {
            let result = attempt {
                try JSONEncoder().encode(request)
            }

            switch result {
                case .success(let data):
                    httpRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    httpRequest.httpBody = data
                case .failure(let err):
                    return .failure(ApiError.serializationError(message: err.localizedDescription))
            }
        }

        print("\(httpMethod.rawValue) \(httpRequest.url?.absoluteString ?? "unknown")")
        return await attempt {
            Self.LOGGER.debug(
                "\(httpMethod.rawValue) \(httpRequest.url?.absoluteString ?? "unknown")"
            )
            return try await URLSession.shared.data(for: httpRequest)
        }.mapError { error in
            Self.LOGGER.error("Failed request to \(endpoint): \(error.localizedDescription)")
            return ApiError.invalidResponse
        }.flatMap { (dataResponse: (Data, URLResponse)) in
            let (data, response) = dataResponse
            guard let httpResponse = response as? HTTPURLResponse else {
                return .failure(ApiError.invalidResponse)
            }

            if httpResponse.statusCode == 204 && responseType == EmptyResponse.self {
                return .success(EmptyResponse() as! T)
            }

            guard httpResponse.statusCode <= 299 else {
                Self.LOGGER.error(
                    "Failed \(httpMethod.rawValue) to \(endpoint): \(httpResponse.statusCode)"
                )
                return .failure(ApiError.failedRequest(httpCode: httpResponse.statusCode))
            }

            let lol = String(data: data, encoding: .utf8)!
            print(lol)
            return attempt {
                try JSONDecoder().decode(responseType, from: data)
            }.asError(ApiError.serializationError(message:))
        }
    }

    private func url(_ endpoint: String) -> URL {
        return URL(string: "\(apiUrl.absoluteString)\(endpoint)")!
    }
}

enum HttpMethod: String {
    case delete = "DELETE"
    case get = "GET"
    case post = "POST"
    case put = "PUT"
}

public struct EmptyResponse: Codable, Hashable, Sendable {
}

public enum ApiError: Error, Equatable, Sendable {
    case invalidResponse
    case serializationError(message: String)
    case failedRequest(httpCode: Int)

    var errorDescription: String? {
        switch self {
            case .invalidResponse:
                return "Invalid response from Gmail API"
            case .failedRequest(let httpCode):
                return "Failed response from Gmail API: \(httpCode)"
            case .serializationError(let message):
                return "Failed to serialize Gmail object: \(message)"
        }
    }
}
