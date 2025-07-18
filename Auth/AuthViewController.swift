import ProgressHUD
import UIKit

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    private let showWebViewSegueIdentifier = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?
    
    @IBOutlet var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 16
        configureBackButton()
    }
    
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(resource: .backward)
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(resource: .backward)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: .none)
        navigationItem.backBarButtonItem?.tintColor = UIColor(resource: .ypBlack)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Подготовка сегвея: \(segue.identifier ?? "Нет идентификатора")")
        if segue.identifier == showWebViewSegueIdentifier,
           let webViewController = segue.destination as? WebViewViewController {
            webViewController.delegate = self
            print("Делегат установлен для WebViewViewController")
        } else {
            print("Сегвей не соответствует ShowWebView или тип неверный")
        }
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        print("Получен код в AuthViewController: \(code)")
        OAuth2Service.shared.fetchOAuthToken(code: code) { result in
            switch result {
            case let .success(token):
                OAuth2TokenStorage.shared.token = token
                
                print("Токен получен: \(token), вызываем делегата")
                if self.delegate != nil {
                    print("Делегат Auth существует, вызываем didAuthenticate")
                    self.delegate?.didAuthenticate(self)
                } else {
                    print("Делегат Auth не установлен!")
                }
                vc.dismiss(animated: true)
                UIBlockingProgressHUD.dismiss()
            case let .failure(error):
                UIBlockingProgressHUD.dismiss()
                AlertPresenter.showErrorAlert(on: self)
                print("Ошибка: \(error.localizedDescription)")
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
    }
}
    
    protocol AuthViewControllerDelegate: AnyObject {
        func didAuthenticate(_ vc: AuthViewController)
    
}
