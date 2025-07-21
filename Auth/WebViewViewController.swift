import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

private var progressView = UIProgressView()
private var OAuthWebView = WKWebView()

final class WebViewViewController: UIViewController {
   
    private var estimatedProgressObservation: NSKeyValueObservation?

    weak var delegate: WebViewViewControllerDelegate?

    enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        OAuthWebView.navigationDelegate = self
        estimatedProgressObservation = OAuthWebView.observe(\.estimatedProgress,
                                                       options: [],
                                                       changeHandler: { [weak self] _, _ in
                                                           guard let self = self else { return }
                                                           self.updateProgress()
                                                       })
        setUpView()
        loadPage()
    }
    
    private func setUpView() {
        view.backgroundColor = UIColor(resource: .ypWhite)
        OAuthWebView.navigationDelegate = self
        progressView.progressTintColor = UIColor(resource: .ypBlack)
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        OAuthWebView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(OAuthWebView)
        view.addSubview(progressView)
        
        NSLayoutConstraint.activate([
            OAuthWebView.topAnchor.constraint(equalTo: view.topAnchor),
            OAuthWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            OAuthWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            OAuthWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        
    }

    private func loadPage() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            return
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope),
        ]
        guard let url = urlComponents.url else { return }
        let request = URLRequest(url: url)
        print("Загружаем запрос: \(request)")
        OAuthWebView.load(request)
    }

    private func updateProgress() {
        progressView.progress = Float(OAuthWebView.estimatedProgress)
        progressView.isHidden = fabs(OAuthWebView.estimatedProgress - 1.0) <= 0.0001
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            UIBlockingProgressHUD.show()
            print("Код получен в WebView: \(code)")
            if let delegate = delegate {
                print("Делегат WebView существует, передаём код")
                delegate.webViewViewController(self, didAuthenticateWithCode: code)
            } else {
                print("Делегат WebView не установлен!")
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }

    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url,
           let urlComponents = URLComponents(string: url.absoluteString),
           urlComponents.path == "/oauth/authorize/native",
           let items = urlComponents.queryItems,
           let codeItem = items.first(where: { $0.name == "code" }) {
            return codeItem.value
        }
        return nil
    }
}
