import Foundation

struct OAuthTokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}

final class OAuth2Service {
    static let shared = OAuth2Service()

    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?

    private init() {}

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]

        guard let authTokenUrl = urlComponents.url else {
            return nil
        }

        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = HTTPMethod.post
        return request
    }

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)

        if task != nil, lastCode == code {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        task?.cancel()
        lastCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            print("[OAuth2Service]: Не удалось создать запрос")
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponse, Error>) in
            guard let self else { return }
            self.task = nil
            self.lastCode = nil

            switch result {
            case let .success(tokenResponse):
                print("[OAuth2Service]: Токен декодирован \(tokenResponse.accessToken)")
                OAuth2TokenStorage.shared.token = tokenResponse.accessToken
                completion(.success(tokenResponse.accessToken))
            case let .failure(error):
                print("[OAuth2Service]: Ошибка получения токена: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
}
