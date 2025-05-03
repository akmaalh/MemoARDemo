//
//  ViewController.swift
//  Lostandfound
//
//  Created by Akmal Hakim on 19/04/25.
//

import UIKit
import SceneKit
import ARKit
import CoreHaptics

class ViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // Add these properties to your ViewController class
    var scoreUpdateHandler: ((Int) -> Void)?
    var gameCompletionHandler: (() -> Void)?

    // Game variables
    var score = 0
    var gameTimer: Timer?
    var gameTimeRemaining = 15
    var isGameActive = false
    
    // UI elements
    private var scoreLabel: UILabel!
    private var timerLabel: UILabel!
    private var startButton: UIButton!
    
    // Haptic feedback
    private var hapticFeedbackGenerator: UIImpactFeedbackGenerator?
    
    // Object nodes
    private var kitchenNodes: [SCNNode] = []
    private var unusualNode: SCNNode?
    
    // Model templates
    private var blenderTemplate: SCNNode?
    private var stoveTemplate: SCNNode?
    private var plateTemplate: SCNNode?
    private var teapotTemplate: SCNNode?
    
    // Unusual item templates
    private var helmetTemplate: SCNNode?
    private var laptopTemplate: SCNNode?
    private var cameraTemplate: SCNNode?
    private var tireTemplate: SCNNode?
    private var basketballTemplate: SCNNode?
    
    // List of unusual items
    private var unusualItems = ["helmet", "laptop", "camera", "tire", "basketball"]
    
    // Debug mode flag
    private let debugMode = false
    // Maximum kitchen objects to keep the scene from getting too crowded
    private let maxKitchenObjects = 5

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true

        let scene = SCNScene()
        sceneView.scene = scene

        // Setup tap gesture recognizer
        setupTapGestureRecognizer()

        // Prepare haptics
        setupHaptics()
        
        // Setup UI elements
        setupUI()
        
        // Load object templates
        loadObjectTemplates()
        
        // Add debug visualization if in debug mode
        if debugMode {
            addDebugVisualization()
        }

        print("Game Ready. Press Start to begin!")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
        stopGame()
    }

    // MARK: - Setup
    func setupTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGestureRecognizer.delegate = self
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    func setupHaptics() {
        hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        hapticFeedbackGenerator?.prepare()
    }
    
    func setupUI() {
        // Score Label
        scoreLabel = UILabel()
        scoreLabel.text = "Score: 0"
        scoreLabel.textColor = .white
        scoreLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        scoreLabel.textAlignment = .center
        scoreLabel.layer.cornerRadius = 10
        scoreLabel.layer.masksToBounds = true
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)
        
        // Timer Label
        timerLabel = UILabel()
        timerLabel.text = "Time: 15s"
        timerLabel.textColor = .white
        timerLabel.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        timerLabel.textAlignment = .center
        timerLabel.layer.cornerRadius = 10
        timerLabel.layer.masksToBounds = true
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timerLabel)
        
        // Start Button
        startButton = UIButton(type: .system)
        startButton.setTitle("Start Game", for: .normal)
        startButton.backgroundColor = UIColor.systemGreen
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 10
        startButton.translatesAutoresizingMaskIntoConstraints = false
        startButton.addTarget(self, action: #selector(startGame), for: .touchUpInside)
        view.addSubview(startButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scoreLabel.widthAnchor.constraint(equalToConstant: 100),
            scoreLabel.heightAnchor.constraint(equalToConstant: 40),
            
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            timerLabel.widthAnchor.constraint(equalToConstant: 100),
            timerLabel.heightAnchor.constraint(equalToConstant: 40),
            
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            startButton.widthAnchor.constraint(equalToConstant: 150),
            startButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    // MARK: - Game Logic
    @objc func startGame() {
        // Reset game state
        score = 0
        gameTimeRemaining = 15
        isGameActive = true
        updateScoreLabel()
        updateTimerLabel()
        
        // Clear any existing objects
        clearAllObjects()
        
        // Hide start button during gameplay
        startButton.isHidden = true
        
        // Start game timer
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateGameTimer), userInfo: nil, repeats: true)
        
        // Place initial objects
        placeGameObjects()
        
        print("Game Started!")
    }
    
    func stopGame() {
        // Stop timers
        gameTimer?.invalidate()
        gameTimer = nil
        
        // Reset game state
        isGameActive = false
        
        // Show start button
        startButton.isHidden = false
        
        // Clear all objects
        clearAllObjects()
        
        print("Game Stopped")
    }
    
    func clearAllObjects() {
        // Remove all kitchen objects from scene
        for node in kitchenNodes {
            node.removeFromParentNode()
        }
        kitchenNodes.removeAll()
        
        // Remove unusual object if it exists
        if let node = unusualNode {
            node.removeFromParentNode()
            unusualNode = nil
        }
    }
    
    @objc func updateGameTimer() {
        gameTimeRemaining -= 1
        updateTimerLabel()
        
        if gameTimeRemaining <= 0 {
            // Game over
            gameTimer?.invalidate()
            isGameActive = false
            
            // Show game over alert
            showGameOverAlert()
        }
    }
    
    func updateTimerLabel() {
        timerLabel.text = "Time: \(gameTimeRemaining)s"
    }
    
    func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
        scoreUpdateHandler?(score)
    }
    
    func showGameOverAlert() {
        let alertController = UIAlertController(
            title: "Game Over!",
            message: "Your final score: \(score)",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.startButton.isHidden = false
        }
        
        alertController.addAction(okAction)
        
        // Ensure alert is presented on the main thread
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
        
        gameCompletionHandler?()
    }
    
    // MARK: - Object Templates
    func loadObjectTemplates() {
        // Load kitchen item models
        guard let blenderScene = SCNScene(named: "blender.usdz"),
              let stoveScene = SCNScene(named: "stove.usdz"),
              let plateScene = SCNScene(named: "plate.usdz"),
              let teapotScene = SCNScene(named: "teapot.usdz"),
              let helmetScene = SCNScene(named: "helmet.usdz")
              else {
                  print("Failed to load basic models")
                  return
              }
        
        // Try to load additional unusual item models
        let laptopScene = SCNScene(named: "laptop.usdz")
        let cameraScene = SCNScene(named: "camera.usdz")
        let tireScene = SCNScene(named: "tire.usdz")
        let basketballScene = SCNScene(named: "basketball.usdz")

        // Get root nodes from scenes
        let blenderNode = blenderScene.rootNode.childNodes.first ?? blenderScene.rootNode
        let stoveNode = stoveScene.rootNode.childNodes.first ?? stoveScene.rootNode
        let plateNode = plateScene.rootNode.childNodes.first ?? plateScene.rootNode
        let teapotNode = teapotScene.rootNode.childNodes.first ?? teapotScene.rootNode
        let helmetNode = helmetScene.rootNode.childNodes.first ?? helmetScene.rootNode
        
        // Get optional unusual items
        let laptopNode = laptopScene?.rootNode.childNodes.first ?? laptopScene?.rootNode
        let cameraNode = cameraScene?.rootNode.childNodes.first ?? cameraScene?.rootNode
        let tireNode = tireScene?.rootNode.childNodes.first ?? tireScene?.rootNode
        let basketballNode = basketballScene?.rootNode.childNodes.first ?? basketballScene?.rootNode
        
        // Center each model
        centerNodeInParent(blenderNode)
        centerNodeInParent(stoveNode)
        centerNodeInParent(plateNode)
        centerNodeInParent(teapotNode)
        centerNodeInParent(helmetNode)
        
        if let laptopNode = laptopNode { centerNodeInParent(laptopNode) }
        if let cameraNode = cameraNode { centerNodeInParent(cameraNode) }
        if let tireNode = tireNode { centerNodeInParent(tireNode) }
        
        // Apply scales
        let blenderScale: Float = 0.001
        let teapotScale: Float = 0.01
        let stoveScale: Float = 0.008
        let plateScale: Float = 0.03
        let helmetScale: Float = 0.001
        
        blenderNode.scale = SCNVector3(blenderScale, blenderScale, blenderScale)
        stoveNode.scale = SCNVector3(stoveScale, stoveScale, stoveScale)
        plateNode.scale = SCNVector3(plateScale, plateScale, plateScale)
        teapotNode.scale = SCNVector3(teapotScale, teapotScale, teapotScale)
        helmetNode.scale = SCNVector3(helmetScale, helmetScale, helmetScale)
        
        // Apply scales to unusual items if available
        if let laptopNode = laptopNode {
            let laptopScale: Float = 0.01
            laptopNode.scale = SCNVector3(laptopScale, laptopScale, laptopScale)
        }
        
        if let cameraNode = cameraNode {
            let cameraScale: Float = 0.01
            cameraNode.scale = SCNVector3(cameraScale, cameraScale, cameraScale)
        }
        
        if let tireNode = tireNode {
            let tireScale: Float = 0.01
            tireNode.scale = SCNVector3(tireScale, tireScale, tireScale)
        }
        
        if let basketballNode = basketballNode {
            let basketballScale: Float = 0.001
            basketballNode.scale = SCNVector3(basketballScale, basketballScale, basketballScale)
        }
        
        // Store templates
        blenderTemplate = blenderNode
        stoveTemplate = stoveNode
        plateTemplate = plateNode
        teapotTemplate = teapotNode
        helmetTemplate = helmetNode
        laptopTemplate = laptopNode
        cameraTemplate = cameraNode
        tireTemplate = tireNode
        basketballTemplate = basketballNode
        
        // Update available unusual items based on what was loaded
        unusualItems = []
        if helmetTemplate != nil { unusualItems.append("helmet") }
        if laptopTemplate != nil { unusualItems.append("laptop") }
        if cameraTemplate != nil { unusualItems.append("camera") }
        if tireTemplate != nil { unusualItems.append("tire") }
        if basketballTemplate != nil { unusualItems.append("basketball") }
        
        // If no unusual items were loaded, keep helmet as fallback
        if unusualItems.isEmpty {
            unusualItems = ["helmet"]
        }
        
        print("Object templates loaded. Available unusual items: \(unusualItems)")
    }
    
    // MARK: - Object Placement
    func placeGameObjects() {
        // Clear existing objects
        clearAllObjects()
        
        // Place kitchen objects
        let kitchenObjectCount = Int.random(in: 3...maxKitchenObjects)
        for _ in 0..<kitchenObjectCount {
            placeRandomKitchenObject()
        }
        
        // Place one unusual object
        placeRandomUnusualObject()
    }
    
    func placeRandomKitchenObject() {
        // Randomly select which kitchen object to place
        let objectTypes = ["blender", "stove", "plate", "teapot"]
        guard let randomType = objectTypes.randomElement() else { return }
        
        // Get the template for the selected object type
        var template: SCNNode?
        
        switch randomType {
        case "blender":
            template = blenderTemplate?.clone()
        case "stove":
            template = stoveTemplate?.clone()
        case "plate":
            template = plateTemplate?.clone()
        case "teapot":
            template = teapotTemplate?.clone()
        default:
            return
        }
        
        guard let objectNode = template else { return }
        
        // Set the object's name and category
        objectNode.name = randomType
        objectNode.setValue("Kitchen", forKey: "category")
        
        // Generate random position with spacing check
        var randomPosition = generateRandomPosition()
        
        // Try up to 10 times to find a position that's not too close to other objects
        var attempts = 0
        let maxAttempts = 10
        
        while isPositionTooCloseToExistingObjects(randomPosition) && attempts < maxAttempts {
            randomPosition = generateRandomPosition()
            attempts += 1
        }
        
        // If we couldn't find a good position after max attempts, use the last one anyway
        objectNode.position = randomPosition
        
        // Add to scene
        sceneView.scene.rootNode.addChildNode(objectNode)
        
        // Track the object
        kitchenNodes.append(objectNode)
        
        print("Placed kitchen object \(randomType) at position \(randomPosition)")
    }
    
    func placeRandomUnusualObject() {
        // Randomly select which unusual object to place
        guard let randomType = unusualItems.randomElement() else { return }
        
        // Get the template for the selected object type
        var template: SCNNode?
        
        switch randomType {
        case "helmet":
            template = helmetTemplate?.clone()
        case "laptop":
            template = laptopTemplate?.clone()
        case "camera":
            template = cameraTemplate?.clone()
        case "tire":
            template = tireTemplate?.clone()
        default:
            // Fallback to helmet if the selected type isn't available
            template = helmetTemplate?.clone()
        }
        
        guard let objectNode = template else { return }
        
        // Set the object's name and category
        objectNode.name = randomType
        objectNode.setValue("Unusual", forKey: "category")
        
        // Generate random position with spacing check
        var randomPosition = generateRandomPosition()
        
        // Try up to 15 times to find a position that's not too close to other objects
        var attempts = 0
        let maxAttempts = 15
        
        while isPositionTooCloseToExistingObjects(randomPosition) && attempts < maxAttempts {
            randomPosition = generateRandomPosition()
            attempts += 1
        }
        
        // If we couldn't find a good position after max attempts, use the last one anyway
        objectNode.position = randomPosition
        
        // Add to scene
        sceneView.scene.rootNode.addChildNode(objectNode)
        
        // Track the object
        unusualNode = objectNode
        
        print("Placed unusual object \(randomType) at position \(randomPosition)")
    }
    
    func generateRandomPosition() -> SCNVector3 {
        // Get the current camera transform
        guard let cameraTransform = sceneView.session.currentFrame?.camera.transform else {
            return SCNVector3(0, 0, -0.8) // Default position if camera transform is not available
        }
        
        // Convert simd_float4x4 to SCNMatrix4
        let cameraMat = SCNMatrix4(cameraTransform)
        
        // Extract camera position
        let cameraPos = SCNVector3(
            cameraMat.m41,
            cameraMat.m42,
            cameraMat.m43
        )
        
        // Generate a random angle in radians (narrower range for better visibility)
        // Using -π/3 to π/3 (120° arc in front of user) instead of -π/2 to π/2 (180°)
        let randomAngle = Float.random(in: -Float.pi/3...Float.pi/3)
        
        // Random distance from camera (0.8 to 1.5 meters - closer range)
        let distance = Float.random(in: 0.8...1.5)
        
        // Calculate horizontal position using trigonometry
        // Use camera's orientation as the reference for forward direction
        let forwardX = -cameraMat.m31
        let forwardZ = -cameraMat.m33
        
        // Calculate the forward angle
        let forwardAngle = atan2(forwardX, forwardZ)
        
        // Apply the random angle offset to the forward angle
        let finalAngle = forwardAngle + randomAngle
        
        // Calculate the final position
        let xPosition = cameraPos.x + sin(finalAngle) * distance
        let zPosition = cameraPos.z + cos(finalAngle) * distance
        
        // Vertical position - slightly below eye level for better visibility
        // Narrower vertical range to keep objects more visible
        let yPosition = cameraPos.y + Float.random(in: -0.4 ... -0.2)
        
        // Final position
        let position = SCNVector3(xPosition, yPosition, zPosition)
        
        return position
    }

    func centerNodeInParent(_ node: SCNNode) {
        // Calculate the bounding box of the node
        let (min, max) = node.boundingBox
        
        // Calculate the center offset
        let centerX = (min.x + max.x) / 2
        let centerY = (min.y + max.y) / 2
        let centerZ = (min.z + max.z) / 2
        
        // Adjust the node's position to center it
        node.position = SCNVector3(-centerX, -centerY, -centerZ)
    }
    
    // MARK: - Interaction Handling
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        // Only process taps if the game is active
        guard isGameActive else { return }
        
        // Get the location of the tap
        let tapLocation = gestureRecognizer.location(in: sceneView)

        // Perform a hit test to find nodes at the tap location
        let hitTestResults = sceneView.hitTest(tapLocation, options: [:])

        // Check if any node was hit
        if let firstHit = hitTestResults.first {
            let hitNode = firstHit.node

            // Check if the node or any of its parents has the "Unusual" category
            var currentNode: SCNNode? = hitNode
            var isUnusual = false
            
            while let node = currentNode {
                if node.value(forKey: "category") as? String == "Unusual" {
                    isUnusual = true
                    break
                }
                
                // Also check if we've reached one of our tracked unusual nodes
                if let name = node.name, unusualItems.contains(name) {
                    isUnusual = true
                    break
                }
                
                currentNode = node.parent
            }
            
            if isUnusual {
                // --- Tapped the unusual object ---
                print("Tapped the unusual object! +1 point")
                score += 1
                updateScoreLabel()
                
                // Provide success feedback
                triggerHapticFeedback(style: .heavy)
                
                // Show brief success message
                showFloatingText(at: tapLocation, text: "+1", color: .green)
                
                // Clear all objects and place new ones
                placeGameObjects()
            } else {
                // --- Tapped a normal kitchen object ---
                let objectName = hitNode.name ?? "object"
                print("Tapped a normal kitchen object: \(objectName)")
                triggerHapticFeedback(style: .medium)
                showAlert(title: "Incorrect", message: "That's a normal kitchen object!")
                
                // Don't clear objects - they remain in place
            }
        }
    }
    
    // Add this function to check for minimum distance between objects
    func isPositionTooCloseToExistingObjects(_ position: SCNVector3, minimumDistance: Float = 0.3) -> Bool {
        // Check against all existing kitchen objects
        for node in kitchenNodes {
            let distance = calculateDistance(position, node.position)
            if distance < minimumDistance {
                return true // Too close to an existing object
            }
        }
        
        // Check against unusual object if it exists
        if let unusualNode = unusualNode {
            let distance = calculateDistance(position, unusualNode.position)
            if distance < minimumDistance {
                return true // Too close to the unusual object
            }
        }
        
        return false // Position is okay
    }

    // Helper function to calculate distance between two points
    func calculateDistance(_ point1: SCNVector3, _ point2: SCNVector3) -> Float {
        let dx = point1.x - point2.x
        let dy = point1.y - point2.y
        let dz = point1.z - point2.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }

    // MARK: - Feedback Helpers
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        // Ensure alert is presented on the main thread
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }

    func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        // Create and trigger the haptic generator with the specified style
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        
        DispatchQueue.main.async {
            generator.impactOccurred()
        }
    }
    
    func showFloatingText(at position: CGPoint, text: String, color: UIColor) {
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.sizeToFit()
        label.center = position
        view.addSubview(label)
        
        // Animate the label
        UIView.animate(withDuration: 0.8, animations: {
            label.alpha = 0
            label.center.y -= 50
        }) { _ in
            label.removeFromSuperview()
        }
    }

    // MARK: - Debug Helpers
    func addDebugVisualization() {
        // Add a grid to help with positioning
        let grid = SCNNode(geometry: SCNPlane(width: 2, height: 2))
        grid.geometry?.firstMaterial?.diffuse.contents = UIColor.gray.withAlphaComponent(0.5)
        grid.geometry?.firstMaterial?.isDoubleSided = true
        grid.eulerAngles.x = -.pi / 2
        grid.position = SCNVector3(0, -0.15, -1)
        grid.opacity = 0.3
        sceneView.scene.rootNode.addChildNode(grid)
    }
    
    // MARK: - ARSCNViewDelegate Methods
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // Handle plane detection if needed
        if debugMode, anchor is ARPlaneAnchor {
            // Add visualization for detected planes in debug mode
            let planeAnchor = anchor as! ARPlaneAnchor
            let planeNode = createPlaneNode(for: planeAnchor)
            node.addChildNode(planeNode)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Update plane visualization if needed
        if debugMode, anchor is ARPlaneAnchor {
            // Update plane visualization
            let planeAnchor = anchor as! ARPlaneAnchor
            updatePlaneNode(node.childNodes.first, for: planeAnchor)
        }
    }
    
    // MARK: - AR Plane Visualization (Debug Only)
    func createPlaneNode(for anchor: ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue.withAlphaComponent(0.3)
        plane.materials = [material]
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        return planeNode
    }
    
    func updatePlaneNode(_ node: SCNNode?, for anchor: ARPlaneAnchor) {
        guard let planeNode = node, let plane = planeNode.geometry as? SCNPlane else { return }
        
        // Update plane dimensions
        plane.width = CGFloat(anchor.extent.x)
        plane.height = CGFloat(anchor.extent.z)
        
        // Update position
        planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
    }
}

// MARK: - Extensions
extension SCNNode {
    // Helper function to find a node with a specific name in the hierarchy
    func findNodeWithName(_ name: String) -> SCNNode? {
        if self.name == name {
            return self
        }
        
        for childNode in childNodes {
            if let foundNode = childNode.findNodeWithName(name) {
                return foundNode
            }
        }
        
        return nil
    }
}
