import ComposableArchitecture
import XCTest

@testable import ResumeBuilderAI

final class AppReducerTests: XCTestCase {
  
  @MainActor
  func testHandleLogin() async {
    let currentUserResponse: SupabaseDependencyClient.User = {
      var rv = SupabaseDependencyClient.User.mock
      rv.email = "blob@example.com"
      return rv
    }()
    
    let (currentUser, setCurrentUser) = AsyncStream.makeStream(of: SupabaseDependencyClient.User?.self)
    
    let store = TestStore(initialState: AppReducer.State()) {
      AppReducer()
    } withDependencies: {
      $0.uuid = .incrementing
      $0.supabase.currentUser = { currentUser }
    }
   
    store.exhaustivity = .off(showSkippedAssertions: true)
    
    let task = await store.send(.view(.task))
    
    setCurrentUser.yield(with: .success(currentUserResponse))

    await store.receive(\.fetchCurrentUserResponse) {
      $0.user = currentUserResponse
      $0.destination = .main(MainReducer.State(chat: ChatReducer.State(conversation: Conversation(id: UUID(0).uuidString, messages: []))))
    }

    await task.cancel()
  }

  @MainActor
  func testHandleLogout() async {
    let (currentUser, setCurrentUser) = AsyncStream.makeStream(of: SupabaseDependencyClient.User?.self)
    
    let store = TestStore(initialState: AppReducer.State()) {
      AppReducer()
    } withDependencies: {
      $0.uuid = .incrementing
      $0.supabase.currentUser = { currentUser }
    }
   
    let task = await store.send(.view(.task))
    
    setCurrentUser.yield(.none)

    await store.receive(\.fetchCurrentUserResponse) {
      $0.destination = .authentication(Authentication.State())
    }

    await task.cancel()
  }
}
