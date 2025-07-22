import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    @IBOutlet private var progressView: UIProgressView!
    @IBOutlet private var webView: WKWebView!

    private var estimatedProgressObservation: NSKeyValueObservation?

    weak var delegate: WebViewViewControllerDelegate?

    enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        estimatedProgressObservation = webView.observe(\.estimatedProgress,
                                                       options: [],
                                                       changeHandler: { [weak self] _, _ in
                                                           guard let self = self else { return }
                                                           self.updateProgress()
                                                       })

        loadAuthView()
        setUpProgressView()
    }

    private func loadAuthView() {
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
        webView.load(request)
    }

    private func setUpProgressView() {
        progressView.progressTintColor = UIColor(resource: .ypBlack)
    }


    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            UIBlockingProgressHUD.show()
            print("Lock user interactions in WebView")
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
