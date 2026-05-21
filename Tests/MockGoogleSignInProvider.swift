import GoogleSignIn
import UIKit
@testable import PovioKitAuthGoogle

final class MockGoogleSignInProvider: GoogleSignInProviding {
  var currentUser: GIDGoogleUser?
  var configuration: GIDConfiguration?
  var hasPreviousSignInValue = false
  var handleResult = false

  private(set) var signOutCalls = 0
  private(set) var restorePreviousSignInCalls = 0
  private(set) var signInCalls = 0

  var restorePreviousSignInHandler: ((
    @escaping (GIDGoogleUser?, Error?) -> Void
  ) -> Void)?

  var signInHandler: ((
    UIViewController,
    String?,
    [String]?,
    String?,
    @escaping (GIDSignInResult?, Error?) -> Void
  ) -> Void)?

  func hasPreviousSignIn() -> Bool {
    hasPreviousSignInValue
  }

  func signOut() {
    signOutCalls += 1
    currentUser = nil
    hasPreviousSignInValue = false
  }

  @discardableResult
  func handle(_ url: URL) -> Bool {
    handleResult
  }

  func restorePreviousSignIn(completion: @escaping (GIDGoogleUser?, Error?) -> Void) {
    restorePreviousSignInCalls += 1
    restorePreviousSignInHandler?(completion)
  }

  func signIn(
    withPresenting viewController: UIViewController,
    hint: String?,
    additionalScopes: [String]?,
    nonce: String?,
    completion: @escaping (GIDSignInResult?, Error?) -> Void
  ) {
    signInCalls += 1
    signInHandler?(viewController, hint, additionalScopes, nonce, completion)
  }
}
