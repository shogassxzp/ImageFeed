import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}

    private let tokenKey = "UnsplashAccessToken"

    var token: String? {
        get {
            let token = UserDefaults.standard.string(forKey: tokenKey)
            print("Чтение токена: \(token ?? "nil")")
            return token
        }
        set {
            if let newValue = newValue {
                print("Сохранение токена: \(newValue)")
                UserDefaults.standard.set(newValue, forKey: tokenKey)
            } else {
                print("Удаление токена")
                UserDefaults.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
