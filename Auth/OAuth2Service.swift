import Foundation

struct OAuthTokenResponse: Codable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
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
        request.httpMethod = "POST"
        return request
    }

    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        if let currentTask = task, lastCode == code {
            completion(.failure(NetworkError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("Не удалось создать запрос")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        let newTask = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else {return}
                self.task = nil
                self.lastCode = nil
                
                if let data = data, let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    do {
                        let tokenResponse = try JSONDecoder().decode(OAuthTokenResponse.self, from: data)
                        print("Токен декодирован: \(tokenResponse.accessToken)")
                        OAuth2TokenStorage.shared.token = tokenResponse.accessToken
                        completion(.success(tokenResponse.accessToken))
                    } catch {
                        print("Ошибка декодирования")
                        completion(.failure(NetworkError.urlRequestError(error)))
                    }
                } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                        print("Ошибка сервера: Код \(statusCode)")
                        completion(.failure(NetworkError.httpStatusCode(statusCode)))
                    
                } else {
                    print("Ошибка сети")
                    completion(.failure(error ?? NetworkError.urlSessionError))
                }
            }
        }
        task = newTask
        newTask.resume()
    }
}
