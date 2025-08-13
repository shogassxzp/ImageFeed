
import Foundation

enum Constants {
    static let accessKey = "SCQr0W-_9Tlrm5UtUr90vG2jBlw1__R6KvgoxSuHA4w"
    static let secretKey = "lxaF30WLSCfDxFQHNeniQlPBozbduixJvXWBeyEB0BE"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = URL(string: "https://api.unsplash.com")
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaltBaseURL: URL
    let authStringURL: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaltBaseURL: URL, authStringURL: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaltBaseURL = defaltBaseURL
        self.authStringURL = authStringURL
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(
            accessKey: Constants.accessKey,
            secretKey: Constants.secretKey,
            redirectURI: Constants.redirectURI,
            accessScope: Constants.accessScope,
            defaltBaseURL: Constants.defaultBaseURL!,
            authStringURL: Constants.unsplashAuthorizeURLString
        )
    }
}
