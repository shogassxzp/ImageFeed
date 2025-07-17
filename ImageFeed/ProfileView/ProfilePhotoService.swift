import Foundation

final class ProfileImageService {
    private(set) var avatarURL: String?
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var storage = OAuth2TokenStorage.shared
    
    private init() {}
    
    struct ProfileImageResult:Codable {
        let small : String
        let medium: String
        let large: String
        
        enum CodingKeys:String,CodingKey {
            case small
            case medium
            case large
        }
    }
    struct UserResult:Codable {
        let profileImage:ProfileImageResult
        
        enum CodingKeys:String, CodingKey {
            case profileImage = "profile_image"
        }
    }
    
    private func makeProfileImageRequest(token: String, username: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchProfileImage(username: String,_ completion: @escaping (Result<String, Error>) -> Void) {
        task?.cancel()

        guard let token = storage.token else {
            DispatchQueue.main.async {
                let error = URLError(.userAuthenticationRequired)
                print("Нет токена")
                completion(.failure(error))
            }
            return
        }
        
        guard let request = makeProfileImageRequest(token: token, username: username) else {
            DispatchQueue.main.async {
                let error = URLError(.badURL)
                print("Неверный URL")
                completion(.failure(error))
            }
            return
        }
        task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            self?.task = nil

            if let error = error {
                DispatchQueue.main.async {
                    print("Ошибка сетевого запроса")
                    completion(.failure(error))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    let error = URLError(.badServerResponse)
                    print("Данные от сервера не получены")
                    completion(.failure(error))
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let userResult = try decoder.decode(UserResult.self, from: data)
                let avatarURL = userResult.profileImage.small
                DispatchQueue.main.async {
                    self?.avatarURL = avatarURL
                    print("Получен URL аватарки")
                    completion(.success(avatarURL))
                }
            } catch {
                DispatchQueue.main.async {
                    print("Ошибка декодера \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
        task?.resume()
    }
    
}
extension ProfileImageService {
    static let shared = ProfileImageService()
}
