import ComposableArchitecture
import SwiftUI
import OpenAI

@Reducer
struct MainReducer {
  @ObservableState
  struct State: Equatable {
    var chat: ChatReducer.State
  }
  enum Action {
    case chat(ChatReducer.Action)
  }
  var body: some ReducerOf<Self> {
    Scope(state: \.chat, action: \.chat) {
      ChatReducer()
    }
  }
}

// MARK: - SwiftUI

struct MainView: View {
  @Bindable var store: StoreOf<MainReducer>
  
  var body: some View {
    NavigationStack {
      TabView {
        ChatView(store: store.scope(state: \.chat, action: \.chat))
          .tabItem { Label("Conversation", systemImage: "eyeglasses") }
        
        NavigationStack {
          Text("Community")
            .navigationTitle("Community")
        }
        .tabItem { Label("Community", systemImage: "message") }
        
        NavigationStack {
          Text("Network")
            .navigationTitle("Network")
        }
        .tabItem { Label("Network", systemImage: "person.badge.plus") }

        NavigationStack {
          Text("Jobs")
            .navigationTitle("Jobs")
        }
        .tabItem { Label("Jobs", systemImage: "suitcase") }
      }
    }
  }
}

// MARK: - SwiftUI Previews

#Preview {
  MainView(store: Store(initialState: MainReducer.State(
    chat: ChatReducer.State(conversation: Conversation(id: UUID().uuidString, messages: []))
  )) {
    MainReducer()
  })
}
