import SwiftRex

// MARK: Functional helpers
func ignore<T>(_ t: T) -> Void { }
func identity<T>(_ t: T) -> T { t }
func absurd<T>(_ never: Never) -> T { }

//Middleware
//var mainMiddleware = MainMiddleware()
fileprivate var mainMiddleware = mainEffectMiddleware
<> CounterMiddleware().lift(inputAction: {$0.counterAction}, outputAction: MainAction.counterAction, state: {$0.counterState})
fileprivate var rootMiddleware = RootMiddleware()
<> mainMiddleware.lift(inputAction: {$0.mainAction}, outputAction: RootAction.mainAction, state: {$0.mainState})
<> AuthMiddleware().lift(inputAction: {$0.authAction}, outputAction: RootAction.authAction, state: {$0.authState})

// Reducer
fileprivate let mainReducer = MainReducer
<> CounterReducer.lift(action: \.counterAction, state: \.counterState)
fileprivate let rootReducer = RootReducer
<> mainReducer.lift(action: \.mainAction, state: \.mainState)
<> AuthReducer.lift(action: \.authAction, state: \.authState)

// MARK: Store
class Store: ReduxStoreBase<RootAction, RootState> {
  static func create() -> Store {
    let store = Store(
      subject: .combine(initialValue: RootState()),
      reducer: rootReducer,
      middleware: rootMiddleware
    )
    return store
  }
}
