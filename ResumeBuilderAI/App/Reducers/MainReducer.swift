import ComposableArchitecture
import SwiftUI

@Reducer
struct MainReducer {
  @ObservableState
  struct State: Equatable {
    var myMessage = String()
    var assistantChats: [String] = (0..<3).map({ _ in UUID().uuidString })
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
        ForEach(store.assistantChats, id: \.self) { value in
          Text(value.description)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
            .multilineTextAlignment(.leading)
            .padding()
            .background { Color(.systemGroupedBackground) }
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .padding(.horizontal)
        }
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

// MARK: - SwiftUI Previews

#Preview {
  MainView(store: Store(initialState: MainReducer.State()) {
    MainReducer()
  })
}

