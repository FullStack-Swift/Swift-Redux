import SwiftRex
import SwiftUI
import UIKit
import ReactiveSwift
import ReactiveCocoa

final class AuthViewController: BaseViewController {
  
  private let store: AnyStoreType<AuthAction, AuthState>
  
  private var viewStore: ViewStore<AuthAction, AuthState>
  
  init(store: AnyStoreType<AuthAction, AuthState>? = nil) {
    let unwrapStore = store ?? ReduxStoreBase(
      subject: .reactive(initialValue: AuthState()),
      reducer: AuthReducer,
      middleware: IdentityMiddleware<AuthAction, AuthAction, AuthState>()
    )
      .eraseToAnyStoreType()
    self.store = unwrapStore
    self.viewStore = unwrapStore.asViewStore(initialState: AuthState())
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewStore.send(.viewDidLoad)
    // buttonLogin
    let buttonLogin = UIButton(type: .system)
    buttonLogin.setTitle("Login", for: .normal)
    buttonLogin.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(buttonLogin)
    // contraint
    NSLayoutConstraint.activate([
      buttonLogin.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      buttonLogin.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
    ])
    
    //bind view to viewstore
    disposables += viewStore.action <~ buttonLogin.reactive.controlEvents(.touchUpInside).map{_ in AuthAction.login}
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    viewStore.send(.viewWillAppear)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewStore.send(.viewWillDisappear)
  }
}

struct AuthViewController_Previews: PreviewProvider {
  static var previews: some View {
    let vc = AuthViewController()
    UIViewRepresented(makeUIView: { _ in vc.view })
  }
}
