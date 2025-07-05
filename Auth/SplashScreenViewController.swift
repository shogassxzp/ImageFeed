import UIKit

final class SplashScreenViewController: UIViewController, AuthViewControllerDelegate {
    private let showAuthenticationScreenSegueIdentifier = "showAuthView"

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if OAuth2TokenStorage.shared.token != nil {
            print("Токен есть, переключаюсь на TabBar")
            switchToTabBarController()
        } else {
            print("Токена нет, иду на авторизацию")
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
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

    func didAuthenticate(_ vc: AuthViewController) {
        print("didAuthenticate вызван, переключаюсь на TabBar")
        switchToTabBarController()
        vc.dismiss(animated: true)
    }
}
