import ProgressHUD
import UIKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}

private let logoImageView = UIImageView()
private let loginButton = UIButton(type: .system)

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
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
        webViewViewController.delegate = self
        navigationController?.pushViewController(webViewViewController, animated: true)
    }

    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("Получен код в AuthViewController: \(code)")
        UIBlockingProgressHUD.show()
        OAuth2Service.shared.fetchOAuthToken(code: code) { result in
            switch result {
            case let .success(token):
                OAuth2TokenStorage.shared.token = token

                print("Токен получен: \(token), вызываем делегата")
                if self.delegate != nil {
                    print("Делегат Auth существует, вызываем didAuthenticate")
                    self.delegate?.didAuthenticate(self)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("Делегат Auth не установлен!")
                    self.navigationController?.popViewController(animated: true)
                }
            case let .failure(error):
                AlertPresenter.showErrorAlert(on: self)
                print("Ошибка: \(error.localizedDescription)")
            }
        }
    }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
    }
}
