import Foundation
import WebKit

final class WebViewViewController: UIViewController {
    

    @IBOutlet weak var webView: WKWebView!
    
    enum WebViewConstants {
        
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString)!
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        let url = urlComponents.url!
        
        let request = URLRequest(url: url)
        webView.load(request)
        
    }
}
