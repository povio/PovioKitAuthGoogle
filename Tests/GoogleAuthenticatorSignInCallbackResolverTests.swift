import GoogleSignIn
import XCTest
@testable import PovioKitAuthGoogle

final class GoogleAuthenticatorSignInCallbackResolverTests: XCTestCase {
  func test_resolve_whenCancelledError_returnsCancelled() {
    let error = NSError(
      domain: "com.google.GIDSignIn",
      code: GIDSignInError.Code.canceled.rawValue
    )

    let resolution = SignInCallbackResolver.resolve(
      user: nil,
      error: error,
      mapUser: { _ in fatalError("User should not be mapped in this test.") }
    )

    guard case .failure(let authenticatorError) = resolution else {
      XCTFail("Expected failure.")
      return
    }
    XCTAssertEqual(authenticatorError, GoogleAuthenticator.Error.cancelled)
  }

  func test_resolve_whenSystemError_returnsSystem() {
    let error = NSError(domain: "test", code: 42)

    let resolution = SignInCallbackResolver.resolve(
      user: nil,
      error: error,
      mapUser: { _ in fatalError("User should not be mapped in this test.") }
    )

    guard case .failure(let authenticatorError) = resolution else {
      XCTFail("Expected failure.")
      return
    }
    XCTAssertEqual(authenticatorError, GoogleAuthenticator.Error.system(error))
  }

  func test_resolve_whenNoUserAndNoError_returnsUnhandledAuthorization() {
    let resolution = SignInCallbackResolver.resolve(
      user: nil,
      error: nil,
      mapUser: { _ in fatalError("User should not be mapped in this test.") }
    )

    guard case .failure(let authenticatorError) = resolution else {
      XCTFail("Expected failure.")
      return
    }
    XCTAssertEqual(authenticatorError, GoogleAuthenticator.Error.unhandledAuthorization)
  }
}
