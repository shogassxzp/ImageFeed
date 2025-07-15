import Foundation


final class ProfileService {
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    struct ProfileResult: Codable {
        let username: String
        let firstName: String?
        let lastName: String?
        let bio: String?
        
        enum CodingKeys: String, CodingKey {
            case username
            case firstName = "first_name"
            case lastName = "last_name"
            case bio
        }
    }
    
    struct Profile {
        
        let username: String
        let name: String
        let loginName: String
        let bio: String?
        
        init(result: ProfileResult) {
            self.username = result.username
            self.name = [result.firstName, result.lastName]
                .compactMap{ $0 }
                .joined(separator: " ")
                .trimmingCharacters(in: .whitespaces)
            self.loginName = "@\(result.username)"
            self.bio = result.bio
        }
    }
    
    private func makeProfileRequest(token:String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            return nil
        }
        var request = URLRequest(url:url)
        request.setValue("Brear \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        task?.cancel()
        
        guard let request = makeProfileRequest(token: token) else {
            DispatchQueue.main.async {
                let error = URLError(.badURL)
                print("Неверный URL")
                completion(.failure(error))
            }
            return
        }
        task = urlSession.dataTask(with: request) {data, response, error in
            self.task = nil
            
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
                let profileResult = try decoder.decode(ProfileResult.self, from: data)
                let profile = Profile(result: profileResult)
                DispatchQueue.main.async {
                    print("Профиль загружен \(profile.username)")
                    completion(.success(profile))
                }
            } catch {
                DispatchQueue.main.async {
                    print("Ошибка декодера")
                    completion(.failure(error))
                }
            }
        }
        task?.resume()
    }
}

extension ProfileService {
    static let shared = ProfileService()
}
