import UIKit

final class SplashScreenViewController: UIViewController, AuthViewControllerDelegate {
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profilePhotoService = ProfileImageService.shared

    private let showAuthenticationScreenSegueIdentifier = "showAuthView"

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthentication()
    }

    private func checkAuthentication() {
        guard let token = storage.token else {
            print("Токена нет, иду на авторизацию")
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
            return
        }
        print("Токен есть, загружаю данные профиля и перехожу на TabBar")
        fetchProfile(token)
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Неправильная настройка окна")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")

        window.rootViewController = tabBarController
    }
}

extension SplashScreenViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else {
                assertionFailure("Failure to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }

    // When user logged in unsplash switch to TabBar and call fetchProfile
    func didAuthenticate(_ vc: AuthViewController) {
        print("didAuthenticate вызван, отпарвляю запрос на данные пользователя")
        guard let token = storage.token else {
            print("Ошибка с токеном")
            return
        }
        fetchProfile(token)
        print("Получаю данные пользователя")
        vc.dismiss(animated: true)
    }

    // Fetch profile and switch to TabBar

    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()

        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(profile):
                print("Профиль загружен,загружаю аватарку для \(profile.username)")
                self.profilePhotoService.fetchProfileImage(username: profile.username) { result in
                    DispatchQueue.main.async {
                        UIBlockingProgressHUD.dismiss()
                        switch result {
                        case let .success(avatarURL):
                            print("Аватарка загружена")
                            self.switchToTabBarController()
                        case let .failure(error):
                            print("Ошибка загрузки аватарки")
                        }
                    }
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    print("Ошибка загрузки профиля")
                }
            }
        }
    }
}
