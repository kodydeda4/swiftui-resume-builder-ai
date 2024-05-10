import ComposableArchitecture
import SwiftUI
import Supabase

@Reducer
struct Account {
  @ObservableState
  struct State: Equatable {
    @Shared(.user) var user = Supabase.User.mock
    @Presents var destination: Destination.State?
  }
  
  enum Action: ViewAction {
    case view(View)
    case destination(PresentationAction<Destination.Action>)
    
    enum View {
      case task
      case doneButtonTapped
      case signoutButtonTapped
    }
  }
  
  @Dependency(\.api) var api
  @Dependency(\.dismiss) var dismiss
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      case let .view(action):
        switch action {
          
        case .task:
          return .none
          
        case .doneButtonTapped:
          return .run { _ in await self.dismiss() }
          
        case .signoutButtonTapped:
          state.destination = .confirmSignout(.areYouSure)
          return .none
        }
        
      case let .destination(.presented(.confirmSignout(action))):
        switch action {
          
        case .confirm:
          return .run { send in
            try await self.api.signOut()
          }
        }
        
      case .destination:
        return .none
        
      }
    }
    .ifLet(\.$destination, action: \.destination)
  }
  
  @Reducer(state: .equatable)
  enum Destination {
    case confirmSignout(ConfirmationDialogState<ConfirmSignout>)
    
    @CasePathable
    enum ConfirmSignout: Equatable {
      case confirm
    }
  }
}

extension ConfirmationDialogState where Action == Account.Destination.ConfirmSignout {
  static let areYouSure = Self {
    TextState("Are you sure?")
  } actions: {
    ButtonState(role: .destructive, action: .confirm) {
      TextState("Sign Out")
    }
  } message: {
    TextState("You'll have to sign back in again.")
  }
}

// MARK: - SwiftUI

@ViewAction(for: Account.self)
struct AccountSheet: View {
  @Bindable var store: StoreOf<Account>
  
  var body: some View {
    NavigationStack {
      List {
        Text(store.user.email?.description ?? "Email missing.")
        
        Section {
          Button("Sign Out", role: .destructive) {
            send(.signoutButtonTapped)
          }
        }
      }
      .navigationTitle("Account")
      .navigationBarTitleDisplayMode(.inline)
      .confirmationDialog($store.scope(
        state: \.destination?.confirmSignout,
        action: \.destination.confirmSignout
      ))
      .toolbar {
        ToolbarItem(placement: .primaryAction) {
          Button("Done") {
            send(.doneButtonTapped)
          }
          .fontWeight(.semibold)
        }
      }
    }
  }
}

// MARK: - SwiftUI Previews

#Preview {
  Text("Hello World").sheet(isPresented: .constant(true)) {
    AccountSheet(store: Store(initialState: Account.State()) {
      Account()
    })
  }
}

