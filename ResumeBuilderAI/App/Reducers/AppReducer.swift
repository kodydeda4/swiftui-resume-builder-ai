// Software Developed by Kody Deda.

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
    case setDestination(Destination.State)
    
    enum View {
      case task
    }
  }
  
  @Dependency(\.api) var api
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      case let .view(action):
        switch action {
          
        case .task:
//          return .run { [isOnboardingComplete = state.settings.isOnboardingComplete] send in
          return .run { send in
            await withTaskGroup(of: Void.self) { taskGroup in
              taskGroup.addTask {
                for await user in await api.currentUser() {
                  await send(.setDestination({
                    guard user != nil else {
                      return .authentication(.init())
                    }
//                    guard isOnboardingComplete else {
//                      return .onboarding(.init())
//                    }
                    return .main(.init())
                  }()))
                }
              }
            }
          }
        }
        
      case let .setDestination(value):
        state.destination = value
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
    case onboarding(Onboarding)
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
        
      case let .onboarding(store):
        OnboardingView(store: store)
        
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

