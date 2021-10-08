import SwiftUI

@main
struct Todo_ReduxApp: App {
  var body: some Scene {
    WindowGroup {
      RootView(store: Store.create())
    }
  }
}
