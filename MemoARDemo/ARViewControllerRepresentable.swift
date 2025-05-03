//
//  ARViewControllerRepresentable.swift
//  Lostandfound
//
//  Created by Akmal Hakim on 03/05/25.
//

import SwiftUI
import UIKit

struct ARViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var score: Int
    var gameCompleted: () -> Void
    
    func makeUIViewController(context: Context) -> ViewController {
        // If your ViewController is in a storyboard:
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ARViewController") as! ViewController
        
        // If creating programmatically, make sure to initialize all required properties
        // let controller = ViewController()
        // controller.setupViews() // Add a method to set up views programmatically
        
        controller.scoreUpdateHandler = { newScore in
            score = newScore
        }
        controller.gameCompletionHandler = {
            gameCompleted()
        }
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ViewController, context: Context) {}
}
