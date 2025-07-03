import UIKit

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    private let ShowWebViewSegueIdentifier = "ShowWebView"

    @IBOutlet var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 16
        configureBackButton()
    }

    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "Backward")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "Backward")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: .none)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "YP Black")
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier,
           let webViewController = segue.destination as? WebViewViewController {
            webViewController.delegate = self
        }
    }

    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
            OAuth2Service.shared.fetchOAuthToken(code: code) { result in
                switch result {
                case .success(let token):
                    vc.dismiss(animated: true)
                case .failure(let error):
                }
            }
        }

    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
    }
}
