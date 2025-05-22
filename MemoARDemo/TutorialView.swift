import SwiftUI
import UIKit

struct TutorialView: View {
    @Environment(\.presentationMode) var presentationMode
    var onComplete: (() -> Void)? = nil
    
    var body: some View {
        TutorialViewControllerRepresentable(onSelectTheme: {
            if let onComplete = onComplete {
                onComplete()
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        })
        .ignoresSafeArea()
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
