import SwiftUI

public struct MultiChildrenView<Content: View, ViewsContent: View>: View {
  let content: () -> Content
  let views: (_VariadicView.Children) -> ViewsContent

  public init(_ content: Content, @ViewBuilder views: @escaping (_VariadicView.Children) -> ViewsContent) {
    self.content = { content }
    self.views = views
  }

  public init(@ViewBuilder _ content: @escaping () -> Content, @ViewBuilder views: @escaping (_VariadicView.Children) -> ViewsContent) {
    self.content = content
    self.views = views
  }

  public var body: some View {
    _VariadicView.Tree(
      UnaryViewRoot(views: views),
      content: content
    )
  }
}

fileprivate struct UnaryViewRoot<Content: View>: _VariadicView_UnaryViewRoot {
  let views: (_VariadicView.Children) -> Content

  func body(children: _VariadicView.Children) -> some View {
    views(children)
  }
}

public struct DividedVStack<Content: View>: View {

  @ViewBuilder let content: () -> Content

  public init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content
  }

  public var body: some View {
    MultiChildrenView(content) { views in
      VStack {
        let first = views.first?.id
        ForEach(views) { view in
          if view.id != first {
            Divider()
          }
          view
        }
      }
    }
  }
}
