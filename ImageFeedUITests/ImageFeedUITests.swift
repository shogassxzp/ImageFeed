import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false

        app.launch()
    }

    func testAuth() throws {
        app.buttons["Login"].tap()
        let webView = app.webViews["Unsplash"]

        XCTAssertTrue(webView.waitForExistence(timeout: 10))

        let loginTextField = webView.descendants(matching: .textField).element
        loginTextField.tap()
        loginTextField.typeText("example@email.com")
        webView.swipeUp()

        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))

        passwordTextField.tap()
        passwordTextField.typeText("examplePassword")
        webView.swipeUp()

        webView.buttons["Login"].tap()

        let tableQuery = app.tables
        let cell = tableQuery.children(matching: .cell).element(boundBy: 0)

        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }

    func testFeed() throws {
        let tableQuery = app.tables
        let firstCell = tableQuery.children(matching: .cell).element(boundBy: 1)

        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))

        app.swipeUp()

        firstCell.buttons["likeButton"].tap()
        sleep(3)
        firstCell.buttons["likeButton"].tap()
        sleep(3)

        firstCell.tap()

        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))

        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        let backButton = app.buttons["single image back"]
        backButton.tap()
        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))
    }

    func testProfile() throws {
        let tableQuery = app.tables
        let firstCell = tableQuery.children(matching: .cell).element(boundBy: 1)

        XCTAssertTrue(firstCell.waitForExistence(timeout: 5))

        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(3)

        XCTAssertTrue(app.staticTexts["username"].exists)
        XCTAssertTrue(app.staticTexts["@username"].exists)

        let logoutButton = app.buttons["logout button"]
        logoutButton.tap()

        XCTAssertTrue(app.buttons["Login"].waitForExistence(timeout: 5))
    }
}
