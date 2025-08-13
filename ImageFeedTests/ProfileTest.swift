@testable import ImageFeed
import XCTest

final class ProfileViewControllerTests: XCTestCase {
    class ProfilePresenterSpy: ProfilePresenterProtocol {
        var view: ProfileViewProtocol?

        var viewDidLoadCalled = false
        var updateProfileDataCalled = false
        var updateAvatarCalled = false
        var logoutCalled = false

        func viewDidLoad() {
            viewDidLoadCalled = true
        }

        func updateProfileData() {
            updateProfileDataCalled = true
        }

        func updateAvatar() {
            updateAvatarCalled = true
        }

        func didUpdateAvatar() {
            updateAvatarCalled = true
        }

        func logout() {
            logoutCalled = true
        }
    }

    var viewController: ProfileViewController!
       var presenterSpy: ProfilePresenterSpy!
       
       override func setUp() {
           super.setUp()
           viewController = ProfileViewController()
           presenterSpy = ProfilePresenterSpy()
           presenterSpy.view = viewController
           viewController.presenter = presenterSpy
           viewController.loadViewIfNeeded()
       }

    func testViewDidLoadCallsPresenterViewDidLoad() {
        viewController.viewDidLoad()

        XCTAssertTrue(presenterSpy.viewDidLoadCalled)
    }

    func testUpdateProfileData() {
        // Given
        let username = "TestUser"
        let loginName = "@testuser"
        let bio = "Test bio"
    
        viewController.updateProfileData(username: username, loginName: loginName, bio: bio)
        
        let expectation = XCTestExpectation(description: "Wait for UI update")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    
        XCTAssertEqual(viewController.usernameLabel.text, username, "Username label should update")
        XCTAssertEqual(viewController.userTagLabel.text, loginName, "User tag label should update")
        XCTAssertEqual(viewController.bioLabel.text, bio, "Bio label should update")
    }

    func testUpdateAvatar() {
        let url = URL(string: "https://example.com/avatar.jpg")

        viewController.updateAvatar(url: url)

        XCTAssertTrue(viewController.profilePhoto.image != nil)
    }

    func testLogout() {
        viewController.logout()

        XCTAssertTrue(presenterSpy.logoutCalled)
    }
}
