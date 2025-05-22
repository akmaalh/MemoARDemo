import SwiftUI

struct TutorialView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        TutorialViewControllerRepresentable(onSelectTheme: {
            presentationMode.wrappedValue.dismiss()
        })
        .edgesIgnoringSafeArea(.all)
    }
}

struct TutorialViewControllerRepresentable: UIViewControllerRepresentable {
    var onSelectTheme: () -> Void
    
    func makeUIViewController(context: Context) -> TutorialViewController {
        let controller = TutorialViewController()
        controller.requestSelectThemeHandler = onSelectTheme
        return controller
    }
    
    func updateUIViewController(_ uiViewController: TutorialViewController, context: Context) {
        uiViewController.requestSelectThemeHandler = onSelectTheme
    }
}
