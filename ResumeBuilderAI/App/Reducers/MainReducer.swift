import ComposableArchitecture
import SwiftUI

struct ChatMessage2: Identifiable, Equatable, Codable {
  let id: UUID
  let authorId: String
  let content: String
  let createdAt = Date()
}

@Reducer
struct MainReducer {
  @ObservableState
  struct State: Equatable {
    var myMessage = String()
    var chat: [ChatMessage2] = [
      (0..<2).map({ _ in
        ChatMessage2(id: .init(), authorId: "ai", content: UUID().uuidString)
      }),
      (0..<3).map({ _ in
        ChatMessage2(id: .init(), authorId: "me", content: UUID().uuidString)
      })
    ].joined().flatMap({ $0 })
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
          .padding(.top, 4)
        content
        Divider()
        footer
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
            .fontWeight(.bold)
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
  
  @MainActor private var content: some View {
    ScrollView {
      VStack(spacing: 16) {
        ForEach(store.chat, content: ChatView.init)
          .padding(.top)
      }
    }
    //    .background { Color(.systemGroupedBackground).opacity(0.5) }
  }
  
  @MainActor private var footer: some View {
    HStack {
      TextField("Your message", text: $store.myMessage)
        .padding(.vertical , 8)
        .padding(.horizontal, 16)
        .overlay {
          RoundedRectangle(cornerRadius: 30, style: .continuous)
            .strokeBorder()
            .foregroundColor(Color(.separator))
        }
      
      Button(action: {}) {
        Image(systemName: "arrow.up.circle.fill")
          .resizable()
          .scaledToFit()
          .frame(width: 26)
          .foregroundColor(.accentColor)
      }
      .buttonStyle(.plain)
    }
    .padding()
  }
}

struct ChatView: View {
  let value: ChatMessage2
  
  private var aiMessage: some View {
    HStack {
      Image(.coachF0)
        .resizable()
        .scaledToFit()
        .frame(width: 26, height: 26)
        .clipShape(Circle())
      
      VStack(spacing: 4) {
        Text(value.createdAt.formatted())
          .font(.caption)
          .foregroundStyle(.secondary)
        
        Text(value.content)
          .frame(alignment: .leading)
          .multilineTextAlignment(.leading)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background { Color(.systemGroupedBackground) }
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
      }
    }
    .padding(.horizontal)
    .frame(maxWidth: .infinity, alignment: .leading)
  }

  private var myMessage: some View {
    HStack {
      VStack(spacing: 4) {
        Text(value.createdAt.formatted())
          .font(.caption)
          .foregroundStyle(.secondary)
        
        Text(value.content)
          .foregroundColor(.white)
          .multilineTextAlignment(.leading)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background { Color.accentColor }
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
      }
    }
    .padding(.horizontal)
    .frame(maxWidth: .infinity, alignment: .trailing)
  }
  
  var body: some View {
    if value.authorId == "ai" {
      aiMessage
    } else {
      myMessage
    }
  }
}

// MARK: - SwiftUI Previews

#Preview {
  MainView(store: Store(initialState: MainReducer.State()) {
    MainReducer()
  })
}

