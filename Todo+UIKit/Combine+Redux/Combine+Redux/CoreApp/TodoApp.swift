import SwiftUI
import SwiftRex
import CombineRex

@main
struct TodoApp: App {
  
  private let store = ReduxStoreBase(
    subject: .combine(initialValue: RootState()),
    reducer: rootReducer,
    middleware: rootMiddleware
  )
  
  var body: some Scene {
    WindowGroup {
      let vc = RootViewController(store: store)
      UIViewRepresented(makeUIView: { _ in vc.view })
    }
  }
}
