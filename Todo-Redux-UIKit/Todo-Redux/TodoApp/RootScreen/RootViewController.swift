import SwiftUI
import UIKit
import SwiftRex
import RxSwift
import RxCocoa

final class RootViewController: UIViewController {
  
  private let store: Store
  private var viewStore: ViewStore<RootAction, RootState>
  
  init(store: Store) {
    self.store = store
    viewStore = store.asViewStore(initialState: RootState())
    super.init(nibName: nil, bundle: nil)
  }
  
  private var disposeBag = DisposeBag()
  
  private var viewController = UIViewController() {
    willSet {
      viewController.willMove(toParent: nil)
      viewController.view.removeFromSuperview()
      viewController.removeFromParent()
      addChild(newValue)
      newValue.view.frame = self.view.frame
      view.addSubview(newValue.view)
      newValue.didMove(toParent: self)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    viewStore.publisher.rootScreen.subscribe { [weak self] event in
      guard let self = self else {return}
      switch event {
      case .next(let screen):
        switch screen {
        case .main:
          let vc = MainViewController(store: self.store.projection(action: RootAction.mainAction, state: {$0.mainState}))
          let nav = UINavigationController(rootViewController: vc)
          self.viewController = nav
        case .auth:
          let vc = AuthViewController(store: self.store.projection(action: RootAction.authAction, state: {$0.authState}))
          self.viewController = vc
        }
      default:
        break
      }
    }.disposed(by: disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
  }
}
