import ComposableArchitecture
import SwiftUI
import AuthenticationServices
import Supabase

@Reducer
struct Authentication {
  @ObservableState
  struct State: Equatable {
    
  }
  enum Action: ViewAction {
    case view(View)
    case authenticationResponse(Result<Supabase.User?, Error>)
    
    enum View {
      case continueWithAppleButtonTapped(SignInWithAppleToken)
    }
  }
  
  @Dependency(\.api) var api

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      case let .view(.continueWithAppleButtonTapped(token)):
        return .run { send in
          await send(.authenticationResponse(Result {
            try await api.signIn(token)
          }))
        }
        
      case let .authenticationResponse(.success(value)):
        return .none
        
      case let .authenticationResponse(.failure(error)):
        return .none

      }
    }
  }
}

// MARK: - SwiftUI

@ViewAction(for: Authentication.self)
struct AuthenticationView: View {
  @Bindable var store: StoreOf<Authentication>
  @Environment(\.colorScheme) private var colorScheme
  
  private var signInWithAppleButtonStyle: SignInWithAppleButton.Style {
    switch colorScheme {
    case .light: return .black
    case .dark: return .white
    @unknown default: return .black
    }
  }
  
  var body: some View {
    NavigationStack {
      VStack {
        Image(.careerCoachAvatar)
          .resizable()
          .scaledToFit()
          .frame(width: 200, height: 200)
          .clipShape(Circle())
          .padding(.top, 90)
        
        VStack {
          Text("👋 Welcome to the demo!")
            .font(.title)
            .fontWeight(.bold)
          
          Text("This is demo was created by Kody Deda. It's designed to showcase some dev skillz.")
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
        }
        .padding(.top, 32)
        
        Spacer()
        
        SignInWithAppleButton {
          send(.continueWithAppleButtonTapped($0))
        }
        .frame(height: 16*3)
        .padding(.horizontal)
        .signInWithAppleButtonStyle(signInWithAppleButtonStyle)
        .id(colorScheme)
      }
      .padding()
    }
  }
}

// MARK: - SwiftUI Previews

#Preview {
  AuthenticationView(store: Store(initialState: Authentication.State()) {
    Authentication()
  })
}

