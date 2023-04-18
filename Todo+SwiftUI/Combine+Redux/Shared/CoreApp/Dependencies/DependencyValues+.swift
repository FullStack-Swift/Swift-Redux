import Foundation
import SwiftRex

// MARK: Middleware DependencyKey
fileprivate struct CounterMiddlewareKey: DependencyKey {
  static var liveValue = CounterMiddleware()
}

fileprivate struct MainMiddlewareKey: DependencyKey {
  static var liveValue = MainMiddleware()
}

fileprivate struct AuthMiddlewareKey: DependencyKey {
  static var liveValue = AuthMiddleware()
}

fileprivate struct RootMiddlewareKey: DependencyKey {
  static var liveValue = RootMiddleware()
}

// MARK: Middleware DependencyValues
fileprivate extension DependencyValues {
  var counterMiddleware: CounterMiddleware {
    self[CounterMiddlewareKey.self]
  }

  var mainMiddleware: MainMiddleware {
    self[MainMiddlewareKey.self]
  }

  var authMiddleware: AuthMiddleware {
    self[AuthMiddlewareKey.self]
  }

  var rootMiddleware: RootMiddleware {
    self[RootMiddlewareKey.self]
  }
}

// MARK: Reducer DependencyKey
fileprivate struct CounterReducerKey: DependencyKey {
  static var liveValue = CounterReducer
}

fileprivate struct MainReducerKey: DependencyKey {
  static var liveValue = MainReducer
}

fileprivate struct AuthReducerKey: DependencyKey {
  static var liveValue = AuthReducer
}

fileprivate struct RootReducerKey: DependencyKey {
  static var liveValue = RootReducer
}

// MARK: Reducer DependencyValues
fileprivate extension DependencyValues {
  var counterReducer: Reducer<CounterAction, CounterState> {
    self[CounterReducerKey.self]
  }

  var mainReducer: Reducer<MainAction, MainState> {
    self[MainReducerKey.self]
  }

  var authReducer: Reducer<AuthAction, AuthState> {
    self[AuthReducerKey.self]
  }

  var rootReducer: Reducer<RootAction, RootState> {
    self[RootReducerKey.self]
  }
}

// MARK: AppComposedMiddleware DependencyValues
extension DependencyValues {
  var appMiddleware: ComposedMiddleware<RootMiddleware.InputActionType, RootMiddleware.OutputActionType, RootMiddleware.StateType> {
    IdentityMiddleware()
    <> authMiddleware
      .lift(
        inputAction: {$0.authAction},
        outputAction: RootAction.authAction,
        state: {$0.authState}
      )
    <> (
      counterMiddleware
        .lift(
          inputAction: {$0.counterAction},
          outputAction: MainAction.counterAction,
          state: {$0.counterState}
        )
      <> mainMiddleware
    )
    .lift(
      inputAction: {$0.mainAction},
      outputAction: RootAction.mainAction,
      state: {$0.mainState}
    )
    <> rootMiddleware
  }
}

// MARK: AppReducer DependencyValues
extension DependencyValues {
  var appReducer: Reducer<RootAction, RootState> {
    Reducer.identity
    <> authReducer
      .lift(
        action: \.authAction,
        state: \.authState
      )
    <> (
      Reducer.identity
      <> counterReducer
        .lift(
          action: \.counterAction,
          state: \.counterState
        )
      <> mainReducer
    )
    .lift(
      action: \.mainAction,
      state: \.mainState
    )
    <> rootReducer
  }
}

// MARK: StoreProjection DependencyValues
extension DependencyValues {
  var rootStore: StoreProjection<RootAction, RootState> {
    ReduxStoreBase(
      subject: .combine(initialValue: rootState),
      reducer: appReducer,
      middleware: appMiddleware
    )
    .eraseToAnyStoreType()
  }

  var authStore: StoreProjection<AuthAction, AuthState> {
    rootStore
      .projection(
        action: RootAction.authAction,
        state: {$0.authState}
      )
  }

  var mainStore: StoreProjection<MainAction, MainState> {
    rootStore
      .projection(
        action: RootAction.mainAction,
        state: {$0.mainState}
      )
  }

  var counterStore: StoreProjection<CounterAction, CounterState> {
    mainStore
      .projection(
        action: MainAction.counterAction,
        state: {$0.counterState}
      )
  }
}

extension DependencyValues {
  var rootState: RootState {
    self[RootStateKey.self]
  }
}
fileprivate struct RootStateKey: DependencyKey {
  static let liveValue = RootState()
}

public typealias Store = ReduxStoreBase
