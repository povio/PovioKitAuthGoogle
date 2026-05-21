//
//  GoogleAuthenticator+Error.swift
//  PovioKitAuthGoogle
//
//  Copyright © 2025 Povio Inc. All rights reserved.
//

import Foundation
import GoogleSignIn

public extension GoogleAuthenticator {
  enum Error: Swift.Error, LocalizedError, Equatable {
    case system(_ error: Swift.Error)
    case cancelled
    case unhandledAuthorization
    case signInInProgress

    public var errorDescription: String? {
      switch self {
      case .system(let error):
        return error.localizedDescription
      case .cancelled:
        return "Google sign-in was cancelled."
      case .unhandledAuthorization:
        return "Google sign-in finished without a user or error."
      case .signInInProgress:
        return "A Google sign-in request is already in progress."
      }
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
      switch (lhs, rhs) {
      case (.cancelled, .cancelled),
           (.unhandledAuthorization, .unhandledAuthorization),
           (.signInInProgress, .signInInProgress):
        return true
      case (.system(let lhsError), .system(let rhsError)):
        let lhs = lhsError as NSError
        let rhs = rhsError as NSError
        return lhs.domain == rhs.domain && lhs.code == rhs.code
      default:
        return false
      }
    }
  }
}

enum SignInCallbackResolver {
  static func resolve(
    user: GIDGoogleUser?,
    error: (any Error)?,
    mapUser: (GIDGoogleUser) -> GoogleAuthenticator.Response
  ) -> Result<GoogleAuthenticator.Response, GoogleAuthenticator.Error> {
    switch (user, error) {
    case (let user?, _):
      return .success(mapUser(user))
    case (_, let actualError?):
      let errorCode = (actualError as NSError).code
      if errorCode == GIDSignInError.Code.canceled.rawValue {
        return .failure(.cancelled)
      }
      return .failure(.system(actualError))
    case (.none, .none):
      return .failure(.unhandledAuthorization)
    }
  }
}

enum SessionStateEvaluator {
  static func isAuthenticated(
    currentUser: GIDGoogleUser?,
    now: Date = Date()
  ) -> Bool {
    guard let user = currentUser else { return false }
    guard let expiration = user.accessToken.expirationDate else { return true }
    return expiration > now
  }

  static func hasSavedSession(hasPreviousSignIn: Bool) -> Bool {
    hasPreviousSignIn
  }
}
