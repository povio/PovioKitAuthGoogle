//
//  GoogleSignInProviding.swift
//  PovioKitAuthGoogle
//
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import GoogleSignIn
import UIKit

/// Abstraction over `GIDSignIn` for testability.
protocol GoogleSignInProviding: AnyObject {
  var currentUser: GIDGoogleUser? { get }
  var configuration: GIDConfiguration? { get set }
  func hasPreviousSignIn() -> Bool
  func signOut()
  @discardableResult
  func handle(_ url: URL) -> Bool
  func restorePreviousSignIn(completion: @escaping (GIDGoogleUser?, Error?) -> Void)
  func signIn(
    withPresenting viewController: UIViewController,
    hint: String?,
    additionalScopes: [String]?,
    nonce: String?,
    completion: @escaping (GIDSignInResult?, Error?) -> Void
  )
}

final class LiveGoogleSignInProvider: GoogleSignInProviding {
  private let signIn: GIDSignIn

  init(signIn: GIDSignIn = .sharedInstance) {
    self.signIn = signIn
  }

  var currentUser: GIDGoogleUser? { signIn.currentUser }

  var configuration: GIDConfiguration? {
    get { signIn.configuration }
    set { signIn.configuration = newValue }
  }

  func hasPreviousSignIn() -> Bool {
    signIn.hasPreviousSignIn()
  }

  func signOut() {
    signIn.signOut()
  }

  @discardableResult
  func handle(_ url: URL) -> Bool {
    signIn.handle(url)
  }

  func restorePreviousSignIn(completion: @escaping (GIDGoogleUser?, Error?) -> Void) {
    signIn.restorePreviousSignIn(completion: completion)
  }

  func signIn(
    withPresenting viewController: UIViewController,
    hint: String?,
    additionalScopes: [String]?,
    nonce: String?,
    completion: @escaping (GIDSignInResult?, Error?) -> Void
  ) {
    signIn.signIn(
      withPresenting: viewController,
      hint: hint,
      additionalScopes: additionalScopes,
      nonce: nonce,
      completion: completion
    )
  }
}
