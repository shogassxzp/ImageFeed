import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void)
        -> URLSessionTask {
        let fullCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }

        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fullCompletionOnTheMainThread(.success(data))
                } else {
                    fullCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                fullCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                fullCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })

        return task
    }
}
