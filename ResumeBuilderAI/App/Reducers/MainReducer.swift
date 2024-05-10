import ComposableArchitecture
import SwiftUI
import OpenAI

@Reducer
struct MainReducer {
  @ObservableState
  struct State: Equatable {
    var conversations = IdentifiedArrayOf<ConversationReducer.State>()
  }
  enum Action: ViewAction {
    case view(View)
    case conversations(IdentifiedActionOf<ConversationReducer>)

    enum View: BindableAction {
      case newConversationButtonTapped
      case binding(BindingAction<State>)
    }
  }
  
  @Dependency(\.uuid) var uuid
  
  var body: some ReducerOf<Self> {
    BindingReducer(action: \.view)
    Reduce { state, action in
      switch action {
        
      case let .view(action):
        switch action {
          
        case .newConversationButtonTapped:
          state.conversations.append(ConversationReducer.State(
            conversation: Conversation(
              id: self.uuid().uuidString,
              messages: []
            ))
          )
          return .none
          
        case .binding:
          return .none
          
        }
        
      case .conversations:
        return .none
      }
    }
    .forEach(\.conversations, action: \.conversations) {
      ConversationReducer()
    }
  }
}

// MARK: - SwiftUI

@ViewAction(for: MainReducer.self)
struct MainView: View {
  @Bindable var store: StoreOf<MainReducer>
  
  var body: some View {
    NavigationStack {
      List {
        ForEach(store.scope(state: \.conversations, action: \.conversations)) { childStore in
          NavigationLink("Untitled") {//(childStore.conversation.value.messages.last?.content ?? "New Conversation") {
            ConversationView(store: childStore)
          }
        }
      }
      .navigationTitle("Conversations")
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button(action: { send(.newConversationButtonTapped) }) {
            Image(systemName: "plus")
          }
          .buttonStyle(.borderedProminent)
        }
      }
    }
  }
}
