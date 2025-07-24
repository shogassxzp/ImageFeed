import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case alreadyInProgress
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let task = dataTask(for: request) { (result: Result<Data, Error>) in
            switch result {
            case let .success(data):
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    DispatchQueue.main.async {
                        completion(.success(decodedObject))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        return task
    }

    func dataTask(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void)
        -> URLSessionTask {
        dataTask(with: request) { data, response, _ in

            guard let data = data, let response = response else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                completion(.failure(NetworkError.urlSessionError))
                return
            }
            if (200 ..< 300).contains(statusCode) {
                completion(.success(data))
            } else {
                completion(.failure(NetworkError.httpStatusCode(statusCode)))
            }
        }
    }
}
