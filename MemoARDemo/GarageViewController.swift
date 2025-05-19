//
//  GarageViewController.swift
//  MemoARDemo
//
//  Created by Roy Nababan on 18/05/25.
//


import UIKit
import SceneKit
import ARKit
import CoreHaptics
import SwiftUI
import AVFoundation

class GarageViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate {
    // MARK: - Properties
    var sceneView: ARSCNView!
    var scoreUpdateHandler: ((Int) -> Void)?
    var gameSaveHandler: (() -> Void)?
    var requestSelectThemeHandler: (() -> Void)?
    var requestShowHistoryHandler: (() -> Void)?
    var userName: String = "Pemain"
    var themeDisplayName: String = "Garasi"
    
    // Game variables
    var score = 0
    var gameTimer: Timer?
    var gameTimeRemaining = 30
    var isGameActive = false
    
    // Initial camera position
    private var initialCameraPosition: SCNVector3?
    private var initialCameraForward: Float?
    
    // UI elements
    private var scoreLabel: UILabel!
    private var timerLabel: UILabel!
    private var startButton: UIButton!
    
    // Haptic feedback
    private var hapticFeedbackGenerator: UIImpactFeedbackGenerator?
    
    // Object nodes
    private var garageNodes: [SCNNode] = []
    private var unusualNode: SCNNode?
    
    // Theme-specific normal items
    private let normalItems = ["redbull", "wrench", "pipewrench", "drill", "helmet", "tire", "basketball"]
    
    // Theme-specific unusual items
    private let unusualItems = ["blender", "stove", "plate", "teapot", "toothbrush", "sink", "bucket", "handsoap", "meds", "laptop", "camera"]
    
    // Debug mode flag
    private let debugMode = false
    private let maxObjects = 4
    
    // Sound effects
    private var timerSoundPlayer: AVAudioPlayer?
    private var foundSoundPlayer: AVAudioPlayer?
    private var wrongSoundPlayer: AVAudioPlayer?
    private var timerSoundDuration: TimeInterval = 7.0 // 5 seconds sound file
    private var lastTimerSoundTime: TimeInterval = 0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAR()
        setupUI()
        setupTapGestureRecognizer()
        setupHaptics()
        setupSoundEffects()
        loadObjectTemplates()
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
    private func setupAR() {
        sceneView = ARSCNView(frame: view.bounds)
        view.addSubview(sceneView)
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.autoenablesDefaultLighting = true
        
        let scene = SCNScene()
        sceneView.scene = scene
    }
    
    private func setupUI() {
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
        timerLabel.text = "Time: 30s"
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
    
    private func setupTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGestureRecognizer.delegate = self
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupHaptics() {
        hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        hapticFeedbackGenerator?.prepare()
    }
    
    private func setupSoundEffects() {
        // Setup timer sound
        if let timerSoundURL = Bundle.main.url(forResource: "timer_tick", withExtension: "mp3") {
            do {
                timerSoundPlayer = try AVAudioPlayer(contentsOf: timerSoundURL)
                timerSoundPlayer?.prepareToPlay()
                timerSoundDuration = timerSoundPlayer?.duration ?? 6.0
            } catch {
                print("Could not create timer sound player: \(error)")
            }
        }
        
        // Setup found object sound
        if let foundSoundURL = Bundle.main.url(forResource: "object_found", withExtension: "mp3") {
            do {
                foundSoundPlayer = try AVAudioPlayer(contentsOf: foundSoundURL)
                foundSoundPlayer?.prepareToPlay()
            } catch {
                print("Could not create found sound player: \(error)")
            }
        }
        
        // Setup wrong object sound
        if let wrongSoundURL = Bundle.main.url(forResource: "wrong_object", withExtension: "mp3") {
            do {
                wrongSoundPlayer = try AVAudioPlayer(contentsOf: wrongSoundURL)
                wrongSoundPlayer?.prepareToPlay()
            } catch {
                print("Could not create wrong sound player: \(error)")
            }
        }
    }
    
    // MARK: - Object Templates
    private func loadObjectTemplates() {
        // Preload normal items
        for item in normalItems {
            _ = loadObjectTemplate(named: item)
        }
        
        // Preload unusual items
        for item in unusualItems {
            _ = loadObjectTemplate(named: item)
        }
    }
    
    // MARK: - Game Logic
    @objc func startGame() {
        score = 0
        gameTimeRemaining = 30
        isGameActive = true
        updateScoreLabel()
        updateTimerLabel()
        
        // Store initial camera position when game starts
        if let cameraTransform = sceneView.session.currentFrame?.camera.transform {
            let cameraMat = SCNMatrix4(cameraTransform)
            initialCameraPosition = SCNVector3(cameraMat.m41, cameraMat.m42, cameraMat.m43)
            
            // Calculate initial forward angle
            let forwardX = -cameraMat.m31
            let forwardZ = -cameraMat.m33
            initialCameraForward = atan2(forwardX, forwardZ)
        }
        
        clearAllObjects()
        startButton.isHidden = true
        
        // Start timer sound from beginning
        timerSoundPlayer?.currentTime = 0
        timerSoundPlayer?.play()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateGameTimer), userInfo: nil, repeats: true)
        placeGameObjects()
    }
    
    func stopGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        isGameActive = false
        startButton.isHidden = false
        clearAllObjects()
        
        // Stop timer sound
        timerSoundPlayer?.stop()
    }
    
    private func clearAllObjects() {
        for node in garageNodes {
            node.removeAllActions() // Stop any running animations
            node.removeFromParentNode()
        }
        garageNodes.removeAll()
        
        if let node = unusualNode {
            node.removeAllActions() // Stop any running animations
            node.removeFromParentNode()
            unusualNode = nil
        }
    }
    
    @objc func updateGameTimer() {
        gameTimeRemaining -= 1
        updateTimerLabel()
        
        // Play timer sound at appropriate position
        if let player = timerSoundPlayer {
            let currentTime = player.currentTime
            let timePerSecond = timerSoundDuration / 30.0 // Divide 5 seconds into 30 parts
            
            // Calculate the position in the sound file for this second
            let targetTime = timePerSecond * TimeInterval(30 - gameTimeRemaining)
            
            // If we've moved to a new second, play from that position
            if abs(currentTime - targetTime) > 0.1 {
                player.currentTime = targetTime
                player.play()
            }
        }
        
        if gameTimeRemaining <= 0 {
            gameTimer?.invalidate()
            isGameActive = false
            showCustomGameOverUI()
        }
    }
    
    private func updateTimerLabel() {
        timerLabel.text = "Time: \(gameTimeRemaining)s"
    }
    
    private func updateScoreLabel() {
        scoreLabel.text = "Score: \(score)"
        scoreUpdateHandler?(score)
    }
    
    private func showCustomGameOverUI() {
        self.gameSaveHandler?()

        let gameOverView = GameOverSwiftUIView(
            themeTitle: self.themeDisplayName,
            userName: self.userName,
            score: self.score,
            onTryAgain: {
                self.startGame()
            },
            onSelectTheme: {
                self.requestSelectThemeHandler?()
            },
            onShowHistory: {
                self.requestShowHistoryHandler?()
            }
        )

        let hostingController = UIHostingController(rootView: gameOverView)
        hostingController.modalPresentationStyle = .fullScreen
        hostingController.view.backgroundColor = .clear

        DispatchQueue.main.async {
            self.present(hostingController, animated: true) {
                // Ensure the start button in the AR view is visible behind the modal, if needed.
            }
            self.startButton.isHidden = false
        }
    }
    
    // MARK: - Object Placement
    private func placeGameObjects() {
        clearAllObjects()
        
        let objectCount = Int.random(in: 3...maxObjects)
        for _ in 0..<objectCount {
            placeRandomNormalObject()
        }
        
        placeRandomUnusualObject()
    }
    
    private func placeRandomNormalObject() {
        guard let randomType = normalItems.randomElement() else { return }
        guard let template = loadObjectTemplate(named: randomType)?.clone() else { return }
        
        template.name = randomType
        template.setValue("Normal", forKey: "category")
        
        // Calculate position based on the number of existing objects
        let position = calculateEvenlyDistributedPosition()
        template.position = position
        
        // Add rotation animation with slower speed
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 4.0)
        let repeatRotation = SCNAction.repeatForever(rotation)
        template.runAction(repeatRotation)
        
        sceneView.scene.rootNode.addChildNode(template)
        garageNodes.append(template)
    }
    
    private func calculateEvenlyDistributedPosition() -> SCNVector3 {
        guard let initialPos = initialCameraPosition,
              let initialForward = initialCameraForward else {
            return SCNVector3(0, 0, -0.8)
        }
        
        // Calculate the angle based on the number of existing objects
        let objectCount = garageNodes.count
        let totalArc = Float.pi / 2 // 90 degrees total arc
        let angleStep = totalArc / Float(maxObjects) // Divide the arc into equal segments
        let baseAngle = initialForward - totalArc/2 + angleStep * Float(objectCount) // Center the arc around initial forward direction
        
        // Add some randomness to the angle but keep it within its segment
        let randomAngleVariation = Float.random(in: -angleStep/4...angleStep/4)
        let finalAngle = baseAngle + randomAngleVariation
        
        // Calculate distance with some controlled randomness
        let baseDistance = Float(1.5) // Increased base distance
        let distanceVariation = Float.random(in: 0.0...0.3) // Only positive variation to ensure minimum distance
        let distance = baseDistance + distanceVariation
        
        // Calculate position with more vertical randomness
        let xPosition = initialPos.x + sin(finalAngle) * distance
        let zPosition = initialPos.z + cos(finalAngle) * distance
        let yPosition = initialPos.y + Float.random(in: Float(-0.6)...Float(0.0)) // Increased vertical range
        
        return SCNVector3(xPosition, yPosition, zPosition)
    }
    
    private func placeRandomUnusualObject() {
        guard let randomType = unusualItems.randomElement() else { return }
        guard let template = loadObjectTemplate(named: randomType)?.clone() else { return }
        
        template.name = randomType
        template.setValue("Unusual", forKey: "category")
        
        // Try to find a valid position for the unusual object
        var position = calculateUnusualObjectPosition()
        var attempts = 0
        let maxAttempts = 10
        
        while isPositionTooCloseToExistingObjects(position) && attempts < maxAttempts {
            position = calculateUnusualObjectPosition()
            attempts += 1
        }
        
        template.position = position
        
        // Add rotation animation with slower speed for unusual object
        let rotation = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 3.0)
        let repeatRotation = SCNAction.repeatForever(rotation)
        template.runAction(repeatRotation)
        
        sceneView.scene.rootNode.addChildNode(template)
        unusualNode = template
    }
    
    private func calculateUnusualObjectPosition() -> SCNVector3 {
        guard let initialPos = initialCameraPosition,
              let initialForward = initialCameraForward else {
            return SCNVector3(0, 0, -0.8)
        }
        
        // Place unusual object in the same arc as normal objects
        let totalArc = Float.pi / 2 // 90 degrees total arc
        let angleStep = totalArc / Float(maxObjects)
        // Choose a random position between normal objects
        let randomIndex = Int.random(in: 0...maxObjects)
        let baseAngle = initialForward - totalArc/2 + angleStep * Float(randomIndex) // Center the arc around initial forward direction
        
        // Add some randomness to the angle but keep it within its segment
        let randomAngleVariation = Float.random(in: -angleStep/4...angleStep/4)
        let finalAngle = baseAngle + randomAngleVariation
        
        // Use a different distance range for unusual objects
        let baseDistance = Float(1.7) // Further than normal objects
        let distanceVariation = Float.random(in: 0.0...0.3) // Only positive variation
        let distance = baseDistance + distanceVariation
        
        // Calculate position with more vertical randomness
        let xPosition = initialPos.x + sin(finalAngle) * distance
        let zPosition = initialPos.z + cos(finalAngle) * distance
        let yPosition = initialPos.y + Float.random(in: Float(-0.6)...Float(0.0)) // Increased vertical range
        
        return SCNVector3(xPosition, yPosition, zPosition)
    }
    
    private func isPositionTooCloseToExistingObjects(_ position: SCNVector3, minimumDistance: Float = 0.5) -> Bool {
        // Check distance to all normal objects
        for node in garageNodes {
            let distance = calculateDistance(position, node.position)
            if distance < minimumDistance {
                return true
            }
        }
        return false
    }
    
    private func calculateDistance(_ point1: SCNVector3, _ point2: SCNVector3) -> Float {
        let dx = point1.x - point2.x
        let dy = point1.y - point2.y
        let dz = point1.z - point2.z
        return sqrt(dx*dx + dy*dy + dz*dz)
    }
    
    private func loadObjectTemplate(named name: String) -> SCNNode? {
        guard let scene = SCNScene(named: "\(name).usdz") else { return nil }
        let node = scene.rootNode.childNodes.first ?? scene.rootNode
        centerNodeInParent(node)
        
        let scale: Float = {
            switch name {
            case "blender", "helmet", "basketball": return 0.001
            case "stove", "laptop", "camera", "tire", "teapot", "handsoap": return 0.01
            case "plate", "drill": return 0.03
            case "toothbrush", "sink", "bucket", "meds": return 0.001
            case "redbull", "wrench", "pipewrench": return 0.001
            default: return 0.01
            }
        }()
        
        node.scale = SCNVector3(scale, scale, scale)
        return node
    }
    
    private func centerNodeInParent(_ node: SCNNode) {
        let (min, max) = node.boundingBox
        let centerX = (min.x + max.x) / 2
        let centerY = (min.y + max.y) / 2
        let centerZ = (min.z + max.z) / 2
        node.position = SCNVector3(-centerX, -centerY, -centerZ)
    }
    
    // MARK: - Interaction Handling
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard isGameActive else { return }
        
        let tapLocation = gestureRecognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation, options: [:])
        
        if let firstHit = hitTestResults.first {
            let hitNode = firstHit.node
            var currentNode: SCNNode? = hitNode
            var isUnusual = false
            var objectName: String?
            
            while let node = currentNode {
                if let name = node.name {
                    objectName = name
                    if unusualItems.contains(name) {
                        isUnusual = true
                        break
                    }
                    if normalItems.contains(name) {
                        isUnusual = false
                        break
                    }
                }
                currentNode = node.parent
            }
            
            if isUnusual {
                score += 1
                updateScoreLabel()
                triggerHapticFeedback(style: .heavy)
                // Play found sound
                foundSoundPlayer?.currentTime = 0
                foundSoundPlayer?.play()
                showFloatingText(at: tapLocation, text: "+1", color: .green)
                placeGameObjects()
            } else {
                let objectName = hitNode.name ?? "object"
                triggerHapticFeedback(style: .medium)
                // Play wrong sound
                wrongSoundPlayer?.currentTime = 0
                wrongSoundPlayer?.play()
                showAlert(title: "Incorrect", message: "That's a normal garage object!")
            }
        }
    }
    
    // MARK: - Feedback Helpers
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func triggerHapticFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        
        DispatchQueue.main.async {
            generator.impactOccurred()
        }
    }
    
    private func showFloatingText(at position: CGPoint, text: String, color: UIColor) {
        let label = UILabel()
        label.text = text
        label.textColor = color
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.sizeToFit()
        label.center = position
        view.addSubview(label)
        
        UIView.animate(withDuration: 0.8, animations: {
            label.alpha = 0
            label.center.y -= 50
        }) { _ in
            label.removeFromSuperview()
        }
    }
} 
