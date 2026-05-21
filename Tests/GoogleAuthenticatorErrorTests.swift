import XCTest
@testable import PovioKitAuthGoogle

final class GoogleAuthenticatorErrorTests: XCTestCase {
  func test_equatable_matchesSameSystemError() {
    let error = NSError(domain: "test", code: 7)
    XCTAssertEqual(GoogleAuthenticator.Error.system(error), .system(error))
  }

  func test_equatable_distinguishesDifferentCases() {
    XCTAssertNotEqual(GoogleAuthenticator.Error.cancelled, .signInInProgress)
  }

  func test_localizedDescription_forCancelled() {
    XCTAssertEqual(
      GoogleAuthenticator.Error.cancelled.errorDescription,
      "Google sign-in was cancelled."
    )
  }
}
