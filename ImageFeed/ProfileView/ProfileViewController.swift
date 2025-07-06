import UIKit

// Create View`s

private var profilePhoto = UIImageView()
private var usernameLabel = UILabel()
private var bioLabel = UILabel()
private var userTagLabel = UILabel()
private var logoutButton = UIButton()

// Create images

private let profileImage = UIImage(resource: .unsplash)
private let logoutImage = UIImage(resource: .logout)

final class ProfileViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        profilePhoto = UIImageView(image: profileImage)
        usernameLabel = UILabel()
        bioLabel = UILabel()
        userTagLabel = UILabel()
        logoutButton = UIButton(type: .system)

        configView()

        // Disable mask
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        userTagLabel.translatesAutoresizingMaskIntoConstraints = false
        bioLabel.translatesAutoresizingMaskIntoConstraints = false
        profilePhoto.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.translatesAutoresizingMaskIntoConstraints = false

        // Add subview
        view.addSubview(profilePhoto)
        view.addSubview(usernameLabel)
        view.addSubview(userTagLabel)
        view.addSubview(bioLabel)
        view.addSubview(logoutButton)

        // Set constraint
        NSLayoutConstraint.activate([
            profilePhoto.widthAnchor.constraint(equalToConstant: 70),
            profilePhoto.heightAnchor.constraint(equalToConstant: 70),
            profilePhoto.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profilePhoto.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),

            usernameLabel.topAnchor.constraint(equalTo: profilePhoto.bottomAnchor, constant: 8),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            userTagLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 8),
            userTagLabel.leadingAnchor.constraint(equalTo: usernameLabel.leadingAnchor, constant: 0),

            bioLabel.topAnchor.constraint(equalTo: userTagLabel.bottomAnchor, constant: 8),
            bioLabel.leadingAnchor.constraint(equalTo: userTagLabel.leadingAnchor, constant: 0),

            logoutButton.centerYAnchor.constraint(equalTo: profilePhoto.centerYAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            logoutButton.widthAnchor.constraint(equalToConstant: 44),
            logoutButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    func configView() {
        view.backgroundColor = .ypBlack

        profilePhoto = UIImageView(image: profileImage)
        usernameLabel = UILabel()
        bioLabel = UILabel()
        userTagLabel = UILabel()
        logoutButton = UIButton(type: .system)

        usernameLabel.text = "username"
        usernameLabel.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        usernameLabel.textColor = .ypWhite

        userTagLabel.text = "@usernametag"
        userTagLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        userTagLabel.textColor = .ypGray

        bioLabel.text = "bio"
        bioLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        bioLabel.textColor = .ypWhite

        profilePhoto.contentMode = .scaleToFill
        profilePhoto.tintColor = .gray

        logoutButton.setImage(logoutImage, for: .normal)
        logoutButton.tintColor = .ypRed
        logoutButton.contentHorizontalAlignment = .right
    }
}
