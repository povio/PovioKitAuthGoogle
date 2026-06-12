//
//  GoogleAuthenticator.swift
//  PovioKitAuth
//
//  Created by Borut Tomazin on 25/10/2022.
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import Foundation
@preconcurrency import GoogleSignIn
import PovioKitAuthCore
import UIKit

public final class GoogleAuthenticator: Sendable {
  private let provider: any GoogleSignInProviding
  @MainActor private var signInContinuation: CheckedContinuation<Response, Swift.Error>?

  public init() {
    self.provider = LiveGoogleSignInProvider()
  }

  init(provider: any GoogleSignInProviding) {
    self.provider = provider
  }
}

// MARK: - Authenticator
extension GoogleAuthenticator: Authenticator {
  /// Clears the signIn footprint and logs out the user immediately.
  public func signOut() {
    performSignOut()
  }

  /// Whether Google has a stored session that can be restored without showing the sign-in UI.
  public var hasSavedSession: Bool {
    SessionStateEvaluator.hasSavedSession(hasPreviousSignIn: provider.hasPreviousSignIn())
  }

  /// Returns the current authentication state (active session with a non-expired access token).
  public var isAuthenticated: Authenticated {
    SessionStateEvaluator.isAuthenticated(currentUser: provider.currentUser)
  }

  /// Boolean if given `url` should be handled.
  ///
  /// Call this from UIApplicationDelegate’s `application:openURL:options:` method.
  public func canOpenUrl(
    _ url: URL,
    application: UIApplication,
    options: [UIApplication.OpenURLOptionsKey: Any]
  ) -> Bool {
    provider.handle(url)
  }
}

// MARK: - Sign In
public extension GoogleAuthenticator {
  /// SignIn user.
  ///
  /// Will asynchronously return the `Response` object on success or `Error` on error.
  @MainActor
  func signIn(
    from presentingViewController: UIViewController,
    clientId: String? = nil,
    hint: String? = .none,
    additionalScopes: [String]? = .none,
    nonce: Nonce? = nil
  ) async throws -> Response {
    guard signInContinuation == nil else { throw GoogleAuthenticator.Error.signInInProgress }

    guard !provider.hasPreviousSignIn() else {
      return try await restorePreviousSignIn()
    }

    // set clientId if provided (clientId is needed when doing auth via firebase)
    clientId.map { provider.configuration = .init(clientID: $0) }

    return try await signInUser(
      from: presentingViewController,
      hint: hint,
      additionalScopes: additionalScopes,
      nonce: nonce?.value
    )
  }
}

// MARK: - Private Methods
private extension GoogleAuthenticator {
  func performSignOut() {
    if Thread.isMainThread {
      MainActor.assumeIsolated { resolveSignInAndSignOut() }
    } else {
      DispatchQueue.main.sync {
        MainActor.assumeIsolated { resolveSignInAndSignOut() }
      }
    }
  }

  @MainActor
  func resolveSignInAndSignOut() {
    resolveSignIn(with: .failure(.cancelled))
    provider.signOut()
  }

  @MainActor
  func restorePreviousSignIn() async throws -> Response {
    try await withSignInContinuation { _ in
      provider.restorePreviousSignIn { user, error in
        Task { @MainActor in
          if let user {
            self.resolveSignIn(with: .success(user.authResponse))
          } else if let error {
            self.resolveSignIn(with: .failure(.system(error)))
          } else {
            self.resolveSignIn(with: .failure(.unhandledAuthorization))
          }
        }
      }
    }
  }

  @MainActor
  func signInUser(
    from presentingViewController: UIViewController,
    hint: String?,
    additionalScopes: [String]?,
    nonce: String?
  ) async throws -> Response {
    try await withSignInContinuation { _ in
      provider.signIn(
        withPresenting: presentingViewController,
        hint: hint,
        additionalScopes: additionalScopes,
        nonce: nonce
      ) { result, error in
        Task { @MainActor in
          self.resolveSignIn(
            with: SignInCallbackResolver.resolve(
              user: result?.user,
              error: error,
              mapUser: { $0.authResponse }
            )
          )
        }
      }
    }
  }

  @MainActor
  func withSignInContinuation(
    _ operation: (CheckedContinuation<Response, Swift.Error>) -> Void
  ) async throws -> Response {
    try await withCheckedThrowingContinuation { continuation in
      signInContinuation = continuation
      operation(continuation)
    }
  }

  @MainActor
  func resolveSignIn(with result: Result<Response, GoogleAuthenticator.Error>) {
    guard let continuation = signInContinuation else { return }
    signInContinuation = nil
    switch result {
    case .success(let response):
      continuation.resume(returning: response)
    case .failure(let error):
      continuation.resume(throwing: error)
    }
  }
}

// MARK: - Private Extension
private extension GIDGoogleUser {
  var authResponse: GoogleAuthenticator.Response {
    var nameComponents = PersonNameComponents()
    nameComponents.givenName = profile?.givenName
    nameComponents.familyName = profile?.familyName

    return .init(
      userId: userID,
      idToken: idToken?.tokenString,
      accessToken: accessToken.tokenString,
      refreshToken: refreshToken.tokenString,
      nameComponents: nameComponents,
      email: profile?.email,
      expiresAt: accessToken.expirationDate
    )
  }
}
