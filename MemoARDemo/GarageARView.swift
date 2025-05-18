import SwiftUI
import UIKit

struct GarageARView: UIViewControllerRepresentable {
    var scoreUpdateHandler: ((Int) -> Void)?
    var gameSaveHandler: (() -> Void)?
    var requestSelectThemeHandler: (() -> Void)?
    var requestShowHistoryHandler: (() -> Void)?
    var userName: String
    var themeDisplayName: String
    
    func makeUIViewController(context: Context) -> GarageViewController {
        let viewController = GarageViewController()
        viewController.scoreUpdateHandler = scoreUpdateHandler
        viewController.gameSaveHandler = gameSaveHandler
        viewController.requestSelectThemeHandler = requestSelectThemeHandler
        viewController.requestShowHistoryHandler = requestShowHistoryHandler
        viewController.userName = userName
        viewController.themeDisplayName = themeDisplayName
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: GarageViewController, context: Context) {
        // Update the view controller if needed
        uiViewController.scoreUpdateHandler = scoreUpdateHandler
        uiViewController.gameSaveHandler = gameSaveHandler
        uiViewController.requestSelectThemeHandler = requestSelectThemeHandler
        uiViewController.requestShowHistoryHandler = requestShowHistoryHandler
        uiViewController.userName = userName
        uiViewController.themeDisplayName = themeDisplayName
    }
} 
