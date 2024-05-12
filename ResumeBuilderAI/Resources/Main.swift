import SwiftUI
import ComposableArchitecture

@main
struct Main: App {
  var body: some Scene {
    WindowGroup {
      if !_XCTIsTesting {
        AppView(store: Store(initialState: AppReducer.State()) {
          AppReducer()
        })
      }
    }
  }
}
