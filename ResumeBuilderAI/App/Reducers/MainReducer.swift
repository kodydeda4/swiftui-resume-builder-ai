import ComposableArchitecture
import SwiftUI
import OpenAI

@Reducer
struct MainReducer {
  @ObservableState
  struct State: Equatable {
    var conversation = ConversationReducer.State()
    @Presents var destination: Destination.State?
  }
  enum Action: ViewAction {
    case view(View)
    case destination(PresentationAction<Destination.Action>)
    case conversation(ConversationReducer.Action)

    enum View: BindableAction {
      case navigateToAccount
      case binding(BindingAction<State>)
    }
  }
  
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerOf<Self> {
    Scope(state: \.conversation, action: \.conversation) {
      ConversationReducer()
    }
    BindingReducer(action: \.view)
    Reduce { state, action in
      switch action {
        
      case let .view(action):
        switch action {
          
        case .navigateToAccount:
          state.destination = .account(.init())
          return .none
          
        case .binding:
          return .none
          
        }
        
      case .conversation:
        return .none
        
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
      TabView {
        ConversationView(store: store.scope(state: \.conversation, action: \.conversation))
          .tabItem { Label("Conversation", systemImage: "eyeglasses") }
        
        Text("Community")
          .tabItem { Label("Community", systemImage: "eyeglasses") }
        Text("Network")
          .tabItem { Label("Network", systemImage: "eyeglasses") }
        Text("Jobs")
          .tabItem { Label("Jobs", systemImage: "eyeglasses") }
      }
      .navigationTitle("Conversations")
      .sheet(item: $store.scope(
        state: \.destination?.account,
        action: \.destination.account
      )) { store in
        AccountSheet(store: store)
      }
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button(action: { send(.navigateToAccount) }) {
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

