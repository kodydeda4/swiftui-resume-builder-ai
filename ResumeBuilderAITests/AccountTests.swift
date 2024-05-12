import ComposableArchitecture
import XCTest

@testable import ResumeBuilderAI

final class AccountTests: XCTestCase {

  @MainActor
  func testSignout() async {
    let store = TestStore(initialState: Account.State()) {
      Account()
    } withDependencies: {
      $0.supabase.signOut = {}
    }

    await store.send(.view(.signoutButtonTapped)) {
      $0.destination = .confirmSignout(.areYouSure)
    }
    await store.send(\.destination.confirmSignout.confirm) {
      $0.destination = nil
    }
  }
  
  @MainActor
  func testDismiss() async {
    let store = TestStore(initialState: Account.State()) {
      Account()
    } withDependencies: {
      $0.dismiss = .init({})
    }
    await store.send(.view(.doneButtonTapped))
  }
}
