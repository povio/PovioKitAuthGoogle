import GoogleSignIn
import UIKit
import XCTest
@testable import PovioKitAuthGoogle

@MainActor
final class GoogleAuthenticatorTests: XCTestCase {
  func test_hasSavedSession_reflectsProviderState() {
    let provider = MockGoogleSignInProvider()
    provider.hasPreviousSignInValue = true
    let sut = GoogleAuthenticator(provider: provider)

    XCTAssertTrue(sut.hasSavedSession)
  }

  func test_isAuthenticated_whenCurrentUserMissing_returnsFalse() {
    let provider = MockGoogleSignInProvider()
    provider.currentUser = nil
    let sut = GoogleAuthenticator(provider: provider)

    XCTAssertFalse(sut.isAuthenticated)
  }

  func test_signIn_whenAlreadyInProgress_throwsSignInInProgress() async throws {
    let provider = MockGoogleSignInProvider()
    provider.signInHandler = { _, _, _, _, _ in }
    let sut = GoogleAuthenticator(provider: provider)

    let firstSignIn = Task {
      try await sut.signIn(from: UIViewController())
    }

    try await Task.sleep(nanoseconds: 50_000_000)

    do {
      _ = try await sut.signIn(from: UIViewController())
      XCTFail("Expected signInInProgress.")
    } catch GoogleAuthenticator.Error.signInInProgress {
      // expected
    } catch {
      XCTFail("Unexpected error: \(error)")
    }

    firstSignIn.cancel()
  }

  func test_signIn_whenCancelled_propagatesCancelledError() async {
    let provider = MockGoogleSignInProvider()
    provider.signInHandler = { _, _, _, _, completion in
      completion(
        nil,
        NSError(
          domain: "com.google.GIDSignIn",
          code: GIDSignInError.Code.canceled.rawValue
        )
      )
    }
    let sut = GoogleAuthenticator(provider: provider)

    do {
      _ = try await sut.signIn(from: UIViewController())
      XCTFail("Expected cancelled.")
    } catch GoogleAuthenticator.Error.cancelled {
      // expected
    } catch {
      XCTFail("Unexpected error: \(error)")
    }
  }

  func test_signIn_whenHasPreviousSignIn_restoresInsteadOfPresentingUI() async {
    let provider = MockGoogleSignInProvider()
    provider.hasPreviousSignInValue = true
    provider.restorePreviousSignInHandler = { completion in
      completion(nil, NSError(domain: "test", code: 1))
    }
    let sut = GoogleAuthenticator(provider: provider)

    _ = try? await sut.signIn(from: UIViewController())

    XCTAssertEqual(provider.restorePreviousSignInCalls, 1)
    XCTAssertEqual(provider.signInCalls, 0)
  }

  func test_signOut_clearsProviderSession() {
    let provider = MockGoogleSignInProvider()
    provider.hasPreviousSignInValue = true
    let sut = GoogleAuthenticator(provider: provider)

    sut.signOut()

    XCTAssertEqual(provider.signOutCalls, 1)
  }

  func test_canOpenUrl_returnsProviderResult() {
    let provider = MockGoogleSignInProvider()
    provider.handleResult = true
    let sut = GoogleAuthenticator(provider: provider)

    let canOpen = sut.canOpenUrl(
      URL(string: "myapp://callback")!,
      application: UIApplication.shared,
      options: [:]
    )

    XCTAssertTrue(canOpen)
  }
}
