import UIKit

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    
    private let ShowWebViewSegueIdentifier = "ShowWebView"

    @IBOutlet weak var loginButton: UIButton!
    
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
    
    func webViewViewController(_ vc: WebViewViewController, didAuthentcateWithCode code: String) {
        
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        navigationController?.popViewController(animated: true)
    }
    
}
