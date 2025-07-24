import Foundation

final class ProfileService {
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private(set) var profileData: Profile?

    private init() {}

    struct ProfileResult: Codable {
        let username: String
        let firstName: String?
        let lastName: String?
        let bio: String?

    }

    struct Profile {
        let username: String
        let name: String
        let loginName: String
        let bio: String?

        init(result: ProfileResult) {
            username = result.username
            name = [result.firstName, result.lastName]
                .compactMap { $0 }
                .joined(separator: " ")
                .trimmingCharacters(in: .whitespaces)
            loginName = "@\(result.username)"
            bio = result.bio
        }
    }

    private func makeProfileRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }

    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()

        guard let request = makeProfileRequest(token: token) else {
            DispatchQueue.main.async {
                let error = URLError(.badURL)
                print("[ProfileService]: Неверный URL")
                completion(.failure(error))
            }
            return
        }
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            guard let self else { return }
            self.task = nil

            switch result {
            case let .success(profileResult):
                let profile = Profile(result: profileResult)
                self.profileData = profile
                completion(.success(profile))
            case let .failure(error):
                print("[ProfileService]: Ошибка получения профиля \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        task?.resume()
    }
}

extension ProfileService {
    static let shared = ProfileService()
}
