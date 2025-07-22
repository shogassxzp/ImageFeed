import Foundation

final class ProfileImageService {
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")

    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var storage = OAuth2TokenStorage.shared
    private(set) var avatarURL: String?

    private init() {}

    struct ProfileImageResult: Codable {
        let small: String
        let medium: String
        let large: String

        enum CodingKeys: String, CodingKey {
            case small
            case medium
            case large
        }
    }

    struct UserResult: Codable {
        let profileImage: ProfileImageResult

        enum CodingKeys: String, CodingKey {
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

    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
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
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self else { return }
            self.task = nil
            switch result {
            case let .success(userResult):
                let avatarURL = userResult.profileImage.small
                self.avatarURL = avatarURL
                print("Получен URL аватарки: \(avatarURL)")
                completion(.success(avatarURL))
                NotificationCenter.default.post(name: ProfileImageService.didChangeNotification,
                                                object: self,
                                                userInfo: ["URL": avatarURL]
                )
            case let .failure(error):
                print("Ошибка получения URL аватарки \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
}

extension ProfileImageService {
    static let shared = ProfileImageService()
}
