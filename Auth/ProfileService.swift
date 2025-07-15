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
}
