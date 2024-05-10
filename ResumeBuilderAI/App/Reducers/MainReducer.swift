import ComposableArchitecture
import SwiftUI

@Reducer
struct MainReducer {
  @ObservableState
  struct State: Equatable {
    var myMessage = String()
    @Presents var destination: Destination.State?
  }
  
  enum Action: ViewAction {
    case view(View)
    case destination(PresentationAction<Destination.Action>)
    
    enum View: BindableAction {
      case task
      case accountButtonTapped
      case binding(BindingAction<State>)
    }
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer(action: \.view)
    Reduce { state, action in
      switch action {
        
      case let .view(action):
        switch action {
          
        case .task:
          return .none
          
        case .accountButtonTapped:
          state.destination = .account(Account.State())
          return .none
          
        case .binding:
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
    case account(Account)
  }
}

// MARK: - SwiftUI

@ViewAction(for: MainReducer.self)
struct MainView: View {
  @Bindable var store: StoreOf<MainReducer>
  
  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        Divider()
        
        Color.blue.opacity(0.01)
        
        Divider()
        
        VStack {
          TextField("Your message", text: $store.myMessage)
            .textFieldStyle(.roundedBorder)
            .padding()
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .navigationTitle("Career Coach")
      .navigationBarTitleDisplayMode(.inline)
      .sheet(item: $store.scope(
        state: \.destination?.account,
        action: \.destination.account
      )) { store in
        AccountSheet(store: store)
      }
      .toolbar {
        ToolbarItem(placement: .navigationBarLeading) {
          Text("Career Coach")
            .fontWeight(.semibold)
        }
        ToolbarItem(placement: .principal) {
          Text("")
        }
        ToolbarItem(placement: .primaryAction) {
          Button(action: { send(.accountButtonTapped) }) {
            Image(systemName: "person.circle.fill")
          }
        }
      }
    }
  }
}

// MARK: - SwiftUI Previews

#Preview {
  MainView(store: Store(initialState: MainReducer.State()) {
    MainReducer()
  })
}

