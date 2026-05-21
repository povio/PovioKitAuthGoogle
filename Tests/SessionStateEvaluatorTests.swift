import XCTest
@testable import PovioKitAuthGoogle

final class SessionStateEvaluatorTests: XCTestCase {
  func test_isAuthenticated_whenCurrentUserMissing_returnsFalse() {
    XCTAssertFalse(SessionStateEvaluator.isAuthenticated(currentUser: nil))
  }

  func test_hasSavedSession_reflectsPreviousSignInFlag() {
    XCTAssertTrue(SessionStateEvaluator.hasSavedSession(hasPreviousSignIn: true))
    XCTAssertFalse(SessionStateEvaluator.hasSavedSession(hasPreviousSignIn: false))
  }
}
