import Foundation
import Kingfisher
import WebKit

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    private let storage = OAuth2TokenStorage.shared

    private init() {}

    @objc func logout() {
        storage.deleteToken()
        clearCookies()
        clearImageCache()
        switchToSlashScreen()
    }

    private func clearImageCache() {
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache()
    }

    private func clearCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) {
            records in records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes,
                                                        for: [record],
                                                        completionHandler: {})
            }
        }
    }

    private func switchToSlashScreen() {
        UIBlockingProgressHUD.show()
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("[ProfileLogoutService]: Неправильная настройка окна")
            return
        }
        let splashScreen = SplashScreenViewController()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            window.rootViewController = splashScreen
            window.makeKeyAndVisible()
            UIBlockingProgressHUD.dismiss()
        }
    }
}
