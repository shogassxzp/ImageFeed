import UIKit
import WebKit

public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

private var progressView = UIProgressView()
private var OAuthWebView = WKWebView()

final class WebViewViewController: UIViewController & WebViewViewControllerProtocol {
    var presenter: WebViewPresenterProtocol?
    private var estimatedProgressObservation: NSKeyValueObservation?

    weak var delegate: WebViewViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        estimatedProgressObservation = OAuthWebView.observe(
            \.estimatedProgress,
            options: [],
            changeHandler: { [weak self] _, _ in
                guard let self = self else { return }
                presenter?.didUpdateProgressValue(OAuthWebView.estimatedProgress)
            })

        setUpView()
        presenter?.viewDidLoad()
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
            progressView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
        ])
    }

    func load(request: URLRequest) {
        OAuthWebView.load(request)
    }

    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let code = code(from: navigationAction) {
            UIBlockingProgressHUD.show()
            print("[WebViewViewController]: Код получен в WebView: \(code)")
            if let delegate = delegate {
                print("[WebViewViewController]: Делегат WebView существует, передаём код")
                delegate.webViewViewController(self, didAuthenticateWithCode: code)
            } else {
                print("[WebViewViewController]: Делегат WebView не установлен!")
            }
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
}
