import Foundation

protocol ProfilePresenterProtocol {
    var view: ProfileViewProtocol? { get set }
    func viewDidLoad()
    func updateProfileInfo()
    func updateAvatar()
    func didUpdateAvatar()
    func logout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    var view: ProfileViewProtocol?

    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private let logoutService = ProfileLogoutService.shared

    init(view: ProfileViewProtocol?) {
        self.view = view
    }

    func viewDidLoad() {
        updateProfileInfo()
        updateAvatar()
    }

    func updateProfileInfo() {
        guard let profile = profileService.profileData else {
            print("Данные профиля отсутсвуют")
            return
        }
        view?.updateProfileData(username: profile.username,
                                loginName: profile.loginName,
                                bio: profile.bio
        )
    }

    func updateAvatar() {
        guard let avatarURL = profileImageService.avatarURL,
              let url = URL(string: avatarURL) else {
            print("URL аватара отсутсвует")
            return
        }
        view?.updateAvatar(url: url)
    }

    func didUpdateAvatar() {
        updateAvatar()
    }

    func logout() {
        logoutService.logout()
    }
}
