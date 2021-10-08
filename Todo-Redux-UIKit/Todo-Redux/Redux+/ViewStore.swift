import SwiftRex
import RxSwiftRex
import RxSwift

open class ObservableViewModel<ViewAction, ViewState>: StoreType {
  
  private let disposeBag = DisposeBag()
  private var store: StoreProjection<ViewAction, ViewState>
  
  public var state: ViewState
  public let statePublisher: UnfailablePublisherType<ViewState>
  
  public init<S>(initialState: ViewState, store: S, emitsValue: ShouldEmitValue<ViewState>)
  where S: StoreType, S.ActionType == ViewAction, S.StateType == ViewState {
    self.state = initialState
    self.store = store.eraseToAnyStoreType()
    self.statePublisher = store
      .statePublisher
      .distinctUntilChanged(emitsValue.shouldRemove)
      .asPublisherType()
      .assertNoFailure()
    self.statePublisher.subscribe { [weak self] event in
      guard let self = self else {
        return
      }
      if let state = event.element {
        self.state = state
      }
    }
    .disposed(by: disposeBag)
  }

  open func dispatch(_ dispatchedAction: DispatchedAction<ViewAction>) {
    store.dispatch(dispatchedAction)
  }
}

@dynamicMemberLookup
final public class ViewStore<ViewAction, ViewState>: ObservableViewModel<ViewAction, ViewState> {
  
  public subscript<LocalState>(dynamicMember keyPath: KeyPath<ViewState, LocalState>) -> LocalState {
    self.state[keyPath: keyPath]
  }
  
  public subscript<LocalState>(
    get state: HashableWrapper<(ViewState) -> LocalState>,
    send action: HashableWrapper<(LocalState) -> ViewAction>
  ) -> LocalState {
    get { state.rawValue(self.state) }
    set { self.dispatch(action.rawValue(newValue)) }
  }
  
  public var action: Binder<ViewAction> {
    Binder(self) { weakSelf, action in
      weakSelf.send(action)
    }
  }

  public var publisher: StorePublisher<ViewState> {
    StorePublisher(viewStore: self)
  }
  
  public func send(_ action: ViewAction) {
    dispatch(action)
  }
}

public struct HashableWrapper<Value>: Hashable {
  let rawValue: Value
  public static func == (lhs: Self, rhs: Self) -> Bool { false }
  public func hash(into hasher: inout Hasher) {}
}

extension StoreType where StateType: Equatable {
  public func asViewStore(
    initialState: StateType
  ) -> ViewStore<ActionType, StateType> {
    .init(initialState: initialState, store: self, emitsValue: .whenDifferent)
  }
}

@dynamicMemberLookup
public struct StorePublisher<State>: ObservableType {
  public typealias Element = State
  
  public let upstream: Observable<State>
  
  public let viewStore: Any
  
  private let disposeBag = DisposeBag()
  
  fileprivate init<Action>(viewStore: ViewStore<Action, State>) {
    self.viewStore = viewStore
    self.upstream = viewStore.statePublisher.asObservable()
  }
  
  public func subscribe<Observer>(_ observer: Observer) -> Disposable where Observer: ObserverType, Element == Observer.Element {
    upstream.asObservable().subscribe { event in
      switch event {
      case .error, .completed:
        _ = viewStore
      default:
        break
      }
    }
    .disposed(by: disposeBag)
    return upstream.subscribe(observer)
  }
  
  private init(_ upstream: Observable<State>, viewStore: Any) {
    self.upstream = upstream
    self.viewStore = viewStore
  }
  
  public subscript<LocalState>(dynamicMember keyPath: KeyPath<State, LocalState>) -> StorePublisher<LocalState> where LocalState: Equatable {
    .init(self.upstream.map { $0[keyPath: keyPath] }.distinctUntilChanged(), viewStore: viewStore)
  }
}
