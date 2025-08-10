import ProgressHUD
import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    private let logoImageView = UIImageView()
    private let loginButton = UIButton(type: .system)

    weak var delegate: AuthViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureBackButton()
    }

    private func setupView() {
        view.backgroundColor = UIColor(resource: .ypBlack)
        logoImageView.image = UIImage(resource: .logoOfUnsplash)
        loginButton.setTitle("Войти", for: .normal)
        loginButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        loginButton.backgroundColor = UIColor(resource: .ypWhite)
        loginButton.tintColor = UIColor(resource: .ypBlack)
        loginButton.addTarget(self, action: #selector(showWebView(_:)), for: .touchUpInside)
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 16
        loginButton.accessibilityIdentifier = "Login"

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(logoImageView)
        view.addSubview(loginButton)

        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 72),
            logoImageView.heightAnchor.constraint(equalToConstant: 74),
            loginButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            loginButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -90),
            loginButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            loginButton.heightAnchor.constraint(equalToConstant: 45),
        ])
    }

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .backward)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .backward)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: .none)
        navigationItem.backBarButtonItem?.tintColor = UIColor(resource: .ypBlack)
    }

    @objc private func showWebView(_ sender: Any) {
        let webViewViewController = WebViewViewController()
        let authHelper = AuthHelper()
        let webViewPresenter = WebViewPresenter(authHelper: authHelper)
        webViewViewController.presenter = webViewPresenter
        webViewPresenter.view = webViewViewController
        webViewViewController.delegate = self
        navigationController?.pushViewController(webViewViewController, animated: true)
    }

    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("[AuthViewController]: Получен код в AuthViewController: \(code)")
        OAuth2Service.shared.fetchOAuthToken(code: code) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(token):
                OAuth2TokenStorage.shared.token = token
                print("[AuthViewController]: Токен получен: \(token), вызываем делегата")
                if self.delegate != nil {
                    print("[AuthViewController]: Делегат Auth существует, вызываем didAuthenticate")
                    self.delegate?.didAuthenticate(self)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("[AuthViewController]: Делегат Auth не установлен!")
                    self.navigationController?.popViewController(animated: true)
                }
            case let .failure(error):
                AlertPresenter.showErrorAlert(on: self)
                print("[AuthViewController]: Ошибка \(error.localizedDescription)")
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
    }
}
