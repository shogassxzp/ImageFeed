import UIKit

final class AuthViewController: UIViewController {
    


    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.masksToBounds = true
        loginButton.layer.cornerRadius = 16
        
    }
}
