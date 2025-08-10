import Kingfisher
import ProgressHUD
import UIKit

protocol ProfileViewProtocol {
    var presenter: ProfilePresenterProtocol? { get set }
    func updateProfileData(username: String?, loginName: String?, bio: String?)
    func updateAvatar(url: URL?)
}

final class ProfileViewController: UIViewController & ProfileViewProtocol {
    var presenter: ProfilePresenterProtocol?
    private var profileImageServiceObserver: NSObjectProtocol?

    private var profilePhoto = UIImageView()
    private var usernameLabel = UILabel()
    private var bioLabel = UILabel()
    private var userTagLabel = UILabel()
    private var logoutButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = ProfilePresenter(view: self)
        addSubview()
        setupView()
        setupObserver()
        presenter?.viewDidLoad()
    }

    private func addSubview() {
        [profilePhoto, usernameLabel, userTagLabel, bioLabel, logoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
    }

    private func setupView() {
        view.backgroundColor = .ypBlack

        profilePhoto.layer.masksToBounds = true
        profilePhoto.layer.cornerRadius = 35
        profilePhoto.contentMode = .scaleAspectFill
        profilePhoto.clipsToBounds = true

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
        profilePhoto.kf.indicatorType = .activity

        logoutButton.setImage(UIImage(resource: .logout), for: .normal)
        logoutButton.tintColor = .ypRed
        logoutButton.contentHorizontalAlignment = .right
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        logoutButton.accessibilityIdentifier = "logout button"
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

    func setupObserver() {
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(forName: ProfileImageService.didChangeNotification,
                         object: nil,
                         queue: .main,) {
                [weak self] _ in
                guard let self = self else { return }
                presenter?.didUpdateAvatar()
                print("get notify")
            }
    }

    func updateProfileData(username: String?, loginName: String?, bio: String?) {
        DispatchQueue.main.async {
            self.usernameLabel.text = username ?? "Unknown"
            self.userTagLabel.text = loginName ?? "@unknown"
            self.bioLabel.text = bio ?? "No bio availiable"
        }
    }

    func updateAvatar(url: URL?) {
        guard let url else {
            profilePhoto.image = UIImage(resource: .photo)
            return
        }
        profilePhoto.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .photo),
            options: [.processor(RoundCornerImageProcessor(cornerRadius: 25))]
        )
    }

    @objc internal func logout() {
        presenter?.logout()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
