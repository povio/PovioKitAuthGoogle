import Foundation
import XCTest
@testable import PovioKitAuthGoogle

final class GoogleAuthenticatorResponseTests: XCTestCase {
  func testNameReturnsNilWhenNameComponentsAreMissing() {
    let response = GoogleAuthenticator.Response(
      userId: "user-id",
      idToken: "id-token",
      accessToken: "access-token",
      refreshToken: "refresh-token",
      nameComponents: nil,
      email: "test@example.com",
      expiresAt: Date()
    )

    XCTAssertNil(response.name)
  }

  func testNameIncludesGivenAndFamilyNameWhenAvailable() {
    var components = PersonNameComponents()
    components.givenName = "John"
    components.familyName = "Appleseed"

    let response = GoogleAuthenticator.Response(
      userId: nil,
      idToken: nil,
      accessToken: "access-token",
      refreshToken: "refresh-token",
      nameComponents: components,
      email: nil,
      expiresAt: nil
    )

    guard let name = response.name else {
      XCTFail("Expected non-nil name when name components are present.")
      return
    }

    XCTAssertTrue(name.contains("John"))
    XCTAssertTrue(name.contains("Appleseed"))
  }

  func testResponseStoresProvidedValues() {
    let expiration = Date(timeIntervalSince1970: 1_714_289_600)
    var components = PersonNameComponents()
    components.givenName = "Jane"
    components.familyName = "Doe"

    let response = GoogleAuthenticator.Response(
      userId: "123",
      idToken: "id-token",
      accessToken: "access-token",
      refreshToken: "refresh-token",
      nameComponents: components,
      email: "jane@example.com",
      expiresAt: expiration
    )

    XCTAssertEqual(response.userId, "123")
    XCTAssertEqual(response.idToken, "id-token")
    XCTAssertEqual(response.accessToken, "access-token")
    XCTAssertEqual(response.refreshToken, "refresh-token")
    XCTAssertEqual(response.nameComponents?.givenName, "Jane")
    XCTAssertEqual(response.nameComponents?.familyName, "Doe")
    XCTAssertEqual(response.email, "jane@example.com")
    XCTAssertEqual(response.expiresAt, expiration)
  }
}
