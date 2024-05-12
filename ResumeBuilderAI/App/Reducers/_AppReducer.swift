import ComposableArchitecture
import SwiftUI

@Reducer
struct AppReducer {
  @ObservableState
  struct State: Equatable {
    @Presents var destination: Destination.State?
  }
  
  enum Action: ViewAction {
    case view(View)
    case destination(PresentationAction<Destination.Action>)
    case fetchCurrentUserResponse(SupabaseDependencyClient.User?)
    
    enum View {
      case task
    }
  }
  
  @Dependency(\.supabase) var supabase
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      case let .view(action):
        switch action {
          
        case .task:
          return .run { send in
            await withTaskGroup(of: Void.self) { taskGroup in
              taskGroup.addTask {
                for await value in await supabase.currentUser() {
                  await send(.fetchCurrentUserResponse(value))
                }
              }
            }
          }
        }
        
      case let .fetchCurrentUserResponse(value):
        guard let value else {
          state.destination = .authentication(Authentication.State())
          return .none
        }
        @Shared(.user) var user = value
        state.destination = .main(MainReducer.State())
        return .none
        
      case .destination:
        return .none
        
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
  
  @Reducer(state: .equatable)
  enum Destination {
    case authentication(Authentication)
    case main(MainReducer)
  }
}

// MARK: - SwiftUI

@ViewAction(for: AppReducer.self)
struct AppView: View {
  @Bindable var store: StoreOf<AppReducer>
  
  var body: some View {
    Group {
      switch store.scope(
        state: \.destination,
        action: \.destination.presented
      )?.case {
      
      case let .authentication(store):
        AuthenticationView(store: store)
        
      case let .main(store):
        MainView(store: store)
        
      case .none:
        ProgressView()
      }
    }
    .task { await send(.task).finish() }
  }
}

// MARK: - SwiftUI Previews

#Preview {
  AppView(store: Store(
    initialState: AppReducer.State(),
    reducer: AppReducer.init
  ))
}
