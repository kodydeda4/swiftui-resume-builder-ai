import ComposableArchitecture
import SwiftUI

@Reducer
struct Onboarding {
  @ObservableState
  struct State: Equatable {
    @Presents var destination: Destination.State?
  }
  
  enum Action: ViewAction {
    case view(View)
    case destination(PresentationAction<Destination.Action>)
    
    enum View {
      case task
    }
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      case let .view(action):
        switch action {
          
        case .task:
          return .none
        }
        
      case .destination:
        return .none
        
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
  
  @Reducer(state: .equatable)
  enum Destination {
    //...
  }
}

// MARK: - SwiftUI

@ViewAction(for: Onboarding.self)
struct OnboardingView: View {
  @Bindable var store: StoreOf<Onboarding>
  
  var body: some View {
    NavigationStack {
      Text("Main")
    }
  }
}

// MARK: - SwiftUI Previews

#Preview {
  OnboardingView(store: Store(initialState: Onboarding.State()) {
    Onboarding()
  })
}

