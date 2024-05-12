import ComposableArchitecture
import XCTest

@testable import ResumeBuilderAI

final class AuthenticationTests: XCTestCase {

  @MainActor
  func testContinueWithAppleSuccess() async {
    let store = TestStore(initialState: Authentication.State()) {
      Authentication()
    } withDependencies: {
      $0.supabase.signIn = { _ in .mock }
    }

    await store.send(.view(.continueWithAppleButtonTapped(.init(appleID: "", nonce: ""))))
    await store.receive(\.authenticationResponse.success)
  }
  
  @MainActor
  func testContinueWithAppleFailure() async {
    struct Failure: Error, Equatable {}
    let store = TestStore(initialState: Authentication.State()) {
      Authentication()
    } withDependencies: {
      $0.supabase.signIn = { _ in throw Failure() }
    }

    await store.send(.view(.continueWithAppleButtonTapped(.init(appleID: "", nonce: ""))))
    await store.receive(\.authenticationResponse.failure)
  }
}
