import UIKit
import SwiftRex
import RxSwift
import RxCocoa

final class CounterViewController: UIViewController {
  
  private let store: AnyStoreType<CounterAction, CounterState>
  private var viewStore: ViewStore<CounterAction, CounterState>
  private let disposeBag = DisposeBag()
  init(store: AnyStoreType<CounterAction, CounterState>) {
    self.store = store
    self.viewStore = store.asViewStore(initialState: CounterState())
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    let decrementButton = UIButton(type: .system)
    decrementButton.setTitle("−", for: .normal)
    let countLabel = UILabel()
    countLabel.font = .monospacedDigitSystemFont(ofSize: 17, weight: .regular)
    let incrementButton = UIButton(type: .system)
    incrementButton.setTitle("+", for: .normal)
    let rootStackView = UIStackView(arrangedSubviews: [
        decrementButton,
        countLabel,
        incrementButton,
    ])
    rootStackView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(rootStackView)
    NSLayoutConstraint.activate([
        rootStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        rootStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
    ])
    decrementButton.rx.tap
        .map{CounterAction.decrement}
        .bind(to: viewStore.action)
        .disposed(by: disposeBag)
    incrementButton.rx.tap
        .map{CounterAction.increment}
        .bind(to: viewStore.action)
        .disposed(by: disposeBag)
    viewStore.publisher.count
        .map { "\($0)" }
        .bind(to: countLabel.rx.text)
        .disposed(by: disposeBag)
  }
}
