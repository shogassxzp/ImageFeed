import UIKit


final class TabBarController: UITabBarController {
    private let imageListViewController = ImageListViewController()
    private let profileViewController = ProfileViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBar()
    }

    private func setupBar() {
        imageListViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .mainActive),
            selectedImage: UIImage(resource: .mainActive)
        )

        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(resource: .profileActive),
            selectedImage: UIImage(resource: .profileActive)
        )
        viewControllers = [imageListViewController, profileViewController]

        tabBar.tintColor = .white
        tabBar.backgroundColor = UIColor(resource: .ypBlack)
        tabBar.barTintColor = UIColor(resource: .ypBlack)
        tabBar.isTranslucent = false
    }
}
