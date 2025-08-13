@testable import ImageFeed
import XCTest

final class ImageListViewControllerTests: XCTestCase {
    var viewController: ImageListViewController!
    var presenter: ImageListPresenterProtocolMock!
    var loading = false

    override func setUp() {
        super.setUp()

        viewController = ImageListViewController()
        presenter = ImageListPresenterProtocolMock(view: viewController)
        viewController.presenter = presenter

        _ = viewController.view
    }

    override func tearDown() {
        viewController = nil
        presenter = nil
        super.tearDown()
    }

    func testUpdatePhotos() {
        let photos = [
            ImageListService.Photo(id: "1", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: "example", thumbImageURL: "url1", fullImageURL: "url1-1", isLike: false),
            ImageListService.Photo(id: "2", size: CGSize(width: 100, height: 100), createdAt: nil, welcomeDescription: "example", thumbImageURL: "url2", fullImageURL: "url2-1", isLike: false),
        ]

        viewController.updatePhotos(photos)

        let expectation = self.expectation(description: "Обновление таблицы")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(viewController.tableView.numberOfRows(inSection: 0), photos.count)
    }

    func testShowLoading() {
        viewController.showLoading()
        loading = true

        XCTAssertTrue(loading)
    }

    func testHideLoading() {
        viewController.hideLoading()
        loading = false

        XCTAssertFalse(loading)
    }
}

class ImageListPresenterProtocolMock: ImageListPresenterProtocol {
    weak var view: ImageListViewProtocol?

    init(view: ImageListViewProtocol?) {
        self.view = view
    }

    func viewDidLoad() {}

    func didSelectPhoto(at indexPath: IndexPath) {
    }

    func didTapLike(at indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
    }

    func willDisplayCell(at indexPath: IndexPath) {
    }
}
