import UIKit

final class SplashScreenViewController: UIViewController, AuthViewControllerDelegate {
    private var logoImageView = UIImageView()

    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profilePhotoService = ProfileImageService.shared

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkAuthentication()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        logoImageView.image = UIImage(resource: .logoOfUnsplash)
        view.backgroundColor = UIColor(resource: .ypBlack)
        view.addSubview(logoImageView)

        logoImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 72),
            logoImageView.heightAnchor.constraint(equalToConstant: 74),
        ])
    }

    private func presentAuthView() {
        let authViewController = AuthViewController()
        authViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: authViewController)
        navigationController.modalPresentationStyle = .fullScreen
        UIBlockingProgressHUD.dismiss()
        present(navigationController, animated: true)
    }

    private func checkAuthentication() {
        guard let token = storage.token else {
            print("[SplashScreenViewController]: Токена нет, иду на авторизацию")
            presentAuthView()
            return
        }
        print("[SplashScreenViewController]: Токен есть, загружаю данные профиля и перехожу на TabBar")
        fetchProfile(token)
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("[SplashScreenViewController]: Неправильная настройка окна")
            return
        }
        let tabBarController = TabBarController()

        window.rootViewController = tabBarController
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            UIBlockingProgressHUD.dismiss()
        }
    }
}

extension SplashScreenViewController {
    // When user logged in unsplash switch to TabBar and call fetchProfile
    func didAuthenticate(_ vc: AuthViewController) {
        print("[SplashScreenViewController]: didAuthenticate вызван, отпарвляю запрос на данные пользователя")
        guard storage.token != nil else {
            print("[SplashScreenViewController]: Ошибка с токеном")
            return
        }
        checkAuthentication()
        print("[SplashScreenViewController]: Получаю данные пользователя")
    }

    // Fetch profile and switch to TabBar

    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .success(profile):
                print("[SplashScreenViewController]: Профиль загружен,загружаю аватарку для \(profile.username)")
                self.profilePhotoService.fetchProfileImageURL(username: profile.username) { result in
                    DispatchQueue.main.async {
                        UIBlockingProgressHUD.dismiss()
                        switch result {
                        case .success:
                            self.switchToTabBarController()
                        case .failure:
                            print("[SplashScreenViewController]: Ошибка получения avatarURL")
                            UIBlockingProgressHUD.dismiss()
                        }
                    }
                }
            case .failure:
                DispatchQueue.main.async {
                    UIBlockingProgressHUD.dismiss()
                    print("[SplashScreenViewController]: Ошибка загрузки профиля")
                }
            }
        }
    }
}
