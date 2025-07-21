import UIKit

private let storyboard = UIStoryboard(name: "Main", bundle: .main)

private let imageListViewController = storyboard.instantiateViewController(withIdentifier: "ImageListViewController")

private let profileViewController = ProfileViewController()

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()

        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .profileNoActive),
            selectedImage: UIImage(resource: .profileActive)
        )
        viewControllers = [imageListViewController, profileViewController]
    }
}
