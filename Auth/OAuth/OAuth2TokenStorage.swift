import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}

    private let tokenKey = "UnsplashAccessToken"

    var token: String? {
        get {
            let token = KeychainWrapper.standard.string(forKey: tokenKey)
            print("[OAuth2TokenStorage]: Чтение токена: \(token ?? "nil")")
            return token
        }
        set {
            if let newValue = newValue {
                print("[OAuth2TokenStorage]: Сохранение токена: \(newValue)")
                KeychainWrapper.standard.set(newValue, forKey: tokenKey)
            } else {
                print("[OAuth2TokenStorage]: Удаление токена")
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
}
