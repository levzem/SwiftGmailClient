import Foundation

func attempt<T>(_ work: () async throws -> T) async -> Result<T, Error> {
    do {
        return .success(try await work())
    } catch {
        return .failure(error)
    }
}

func attempt<T>(_ work: () throws -> T) -> Result<T, Error> {
    do {
        return .success(try work())
    } catch {
        return .failure(error)
    }
}

extension Result {

    func isSuccess() -> Bool {
        switch self {
            case .success(_):
                return true
            case .failure(_):
                return false
        }
    }

    func isFailure() -> Bool {
        switch self {
            case .success(_):
                return false
            case .failure(_):
                return true
        }
    }

    func asError<NewError: Error>(_ toError: (String) -> NewError) -> Result<Success, NewError> {
        return mapError { error in
            toError(error.localizedDescription)
        }
    }

    func flatMap<NewSuccess>(_ transform: (Success) async -> Result<NewSuccess, Failure>) async
        -> Result<
            NewSuccess, Failure
        > where NewSuccess: ~Copyable
    {
        switch self {
            case .success(let value):
                return await transform(value)
            case .failure(let error):
                return .failure(error)

        }
    }

    @discardableResult
    func onError(_ callable: (Failure) -> Void) -> Self {
        guard case .failure(let error) = self else {
            return self
        }

        callable(error)
        return self
    }

    @discardableResult
    func onSuccess(_ callable: (Success) -> Void) -> Self {
        guard case .success(let value) = self else {
            return self
        }

        callable(value)
        return self
    }

    func orElse(_ defaultValue: Success) -> Success {
        switch self {
            case .success(let value):
                return value
            case .failure(_):
                return defaultValue
        }
    }

    func toOptional() -> Success? {
        switch self {
            case .success(let value):
                return value
            case .failure(_):
                return nil
        }
    }
}

extension Optional {

    func isEmpty() -> Bool {
        return self == nil
    }

    func isPresent() -> Bool {
        return self != nil
    }

    func orElse(_ defaultValue: Wrapped) -> Wrapped {
        return self ?? defaultValue
    }

    func orElse(_ callable: () -> Wrapped) -> Wrapped {
        return self ?? callable()
    }

    @discardableResult
    func ifEmpty(_ callable: () -> Void) -> Self {
        if self == nil {
            callable()
        }
        return self
    }

    @discardableResult
    func ifPresent(_ callable: (Wrapped) -> Void, _ orElse: () -> Void = {}) -> Self {
        if let value = self {
            callable(value)
        } else {
            orElse()
        }
        return self
    }

    func result<E: Error>(_ error: E) -> Result<Wrapped, E> {
        if let value = self {
            return .success(value)
        } else {
            return .failure(error)
        }
    }

    func filter(_ condition: (Wrapped) -> Bool) -> Wrapped? {
        if let value = self {
            if condition(value) {
                return value
            }
        }

        return nil
    }
}