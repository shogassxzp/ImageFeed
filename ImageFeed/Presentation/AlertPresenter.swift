import UIKit

enum AlertPresenter {
    static func showErrorAlert(on viewController: UIViewController,
                               title: String = "Что-то пошло не так",
                               message: String = "Не удалось войти в систему",
                               buttonTitle: String = "Ок",
                               handler: (() -> Void)? = nil) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let action = UIAlertAction(title: buttonTitle, style: .default) { _ in
            handler?()
        }
        
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
}
