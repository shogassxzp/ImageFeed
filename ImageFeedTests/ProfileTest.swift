@testable import ImageFeed
import XCTest

final class ProfileViewControllerTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        let viewController = ProfileViewController()
        let presenter = MockProfilePresenter()
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        
        XCTAssertNotNil(viewController.presenter)
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}
final class MockProfilePresenter: ProfilePresenterProtocol {
    var view: ProfileViewProtocol?
    var viewDidLoadCalled: Bool = false
    var didUpdateAvatarCalled = false
    var logoutCalled = false
    var updateAvatarCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updateProfileInfo() {
        updateAvatarCalled = true
    }
    
    func updateAvatar() {
        updateAvatarCalled = true
    }
    
    func didUpdateAvatar() {
        didUpdateAvatarCalled = true
    }
    
    func logout() {
        logoutCalled = true
    }
}


