import SwiftUI
import UIKit
import RxCocoa
import SwiftRex
import RxSwift

final class AuthViewController: UIViewController {
  private let store: AnyStoreType<AuthAction, AuthState>
  private var viewStore: ViewStore<AuthAction, AuthState>
  init(store: AnyStoreType<AuthAction, AuthState>) {
    self.store = store
    self.viewStore = store.asViewStore(initialState: AuthState())
    super.init(nibName: nil, bundle: nil)
  }
  
  private let disposeBag = DisposeBag()
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let buttonLogin = UIButton(type: .system)
    buttonLogin.setTitle("Login", for: .normal)
    buttonLogin.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(buttonLogin)
    NSLayoutConstraint.activate([
      buttonLogin.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
      buttonLogin.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
    ])
    buttonLogin.rx.tap
      .map{_ in AuthAction.changeRootScreen(.main)}
      .bind(to: viewStore.action)
      .disposed(by: disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
}
