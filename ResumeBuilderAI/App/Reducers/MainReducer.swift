import ComposableArchitecture
import SwiftUI
import OpenAI

@Reducer
struct MainReducer {
  @ObservableState
  struct State: Equatable {
    
  }
  enum Action: Equatable {
    
  }
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      }
    }
  }
}

// MARK: - SwiftUI

struct MainView: View {
  @Bindable var store: StoreOf<MainReducer>
  
  var body: some View {
    VanillaMainView()
  }
}


// MARK: - SwiftUI Previews

#Preview {
  MainView(store: Store(initialState: MainReducer.State()) {
    MainReducer()
  })
}

