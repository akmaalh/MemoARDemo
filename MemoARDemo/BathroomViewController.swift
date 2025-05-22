//
//  bathroomViewController.swift
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

class BathroomViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate {
    // MARK: - Properties
    var sceneView: ARSCNView!
    var scoreUpdateHandler: ((Int) -> Void)?
    var gameSaveHandler: (() -> Void)?
    var requestSelectThemeHandler: (() -> Void)?
    var requestShowHistoryHandler: (() -> Void)?
    var userName: String = "Pemain"
    var themeDisplayName: String = "Kamar Mandi"
    
    // Game variables
    var score = 0
    var gameTimer: Timer?
    var gameTimeRemaining = 60
    var isGameActive = false
    
    // Initial camera position
    private var initialCameraPosition: SCNVector3?
    private var initialCameraForward: Float?
    
    // Predefined position sets
    private var positionSets: [[SCNVector3]] = []
    private var currentPositionSet: [SCNVector3] = []
    
    // UI elements
    private var scoreLabel: UILabel!
    private var timerLabel: UILabel!
    private var startButton: UIButton!
    
    // Haptic feedback
    private var hapticFeedbackGenerator: UIImpactFeedbackGenerator?
    
    // Object nodes
    private var bathroomNodes: [SCNNode] = []
    private var unusualNode: SCNNode?
    
    // Theme-specific normal items
    private let normalItems = ["toothbrush", "sink", "bucket", "handsoap", "meds"]
    
    // Theme-specific unusual items
    private let unusualItems = ["blender", "stove", "plate", "teapot", "redbull", "wrench", "pipewrench", "drill", "helmet", "tire", "basketball", "laptop", "camera"]
    
    // Debug mode flag
    private let debugMode = false
    private let maxObjects = 4
    
    // Sound effects
    private var timerSoundPlayer: AVAudioPlayer?
    private var foundSoundPlayer: AVAudioPlayer?
    private var wrongSoundPlayer: AVAudioPlayer?
    private var timerSoundDuration: TimeInterval = 32.0
    private var lastTimerSoundTime: TimeInterval = 0
    
    // Colors from HomeScreen
    private let mainColor = UIColor(red: 0.95, green: 0.78, blue: 0.44, alpha: 1.0) // Soft Yellow
    private let secondaryColor = UIColor(red: 0.69, green: 0.25, blue: 0.07, alpha: 1.0) // Dark Brown
    private let backgroundColor = UIColor(red: 0.98, green: 0.97, blue: 0.93, alpha: 1.0) // Light cream
    private let textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) // Dark text
    
    // Add object name translations
    private let objectNameTranslations: [String: String] = [
        "blender": "Blender",
        "stove": "Kompor",
        "plate": "Piring",
        "teapot": "Cerek",
        "helmet": "Helm",
        "laptop": "Laptop",
        "camera": "Kamera",
        "tire": "Ban",
        "basketball": "Bola Basket",
        "redbull": "Minuman Kaleng",
        "wrench": "Kunci Inggris",
        "pipewrench": "Kunci Pipa",
        "drill": "Bor",
        "toothbrush": "Sikat Gigi",
        "sink": "Wastafel",
        "bucket": "Ember",
        "handsoap": "Botol Sabun",
        "meds": "Obat"
    ]
    
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
        scoreLabel.textColor = textColor
        scoreLabel.backgroundColor = mainColor
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont(name: "Verdana", size: 16)
        scoreLabel.layer.cornerRadius = 10
        scoreLabel.layer.masksToBounds = true
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scoreLabel)
        
        // Timer Label
        timerLabel = UILabel()
        timerLabel.text = "Time: 60s"
        timerLabel.textColor = textColor
        timerLabel.backgroundColor = mainColor
        timerLabel.textAlignment = .center
        timerLabel.font = UIFont(name: "Verdana", size: 16)
        timerLabel.layer.cornerRadius = 10
        timerLabel.layer.masksToBounds = true
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(timerLabel)
        
        // Start Button
        startButton = UIButton(type: .system)
        startButton.setTitle("Mulai Latihan", for: .normal)
        startButton.backgroundColor = mainColor
        startButton.setTitleColor(secondaryColor, for: .normal)
        startButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 24)
        startButton.layer.cornerRadius = 16
        startButton.layer.borderWidth = 3
        startButton.layer.borderColor = secondaryColor.withAlphaComponent(0.6).cgColor
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
            startButton.widthAnchor.constraint(equalToConstant: 250),
            startButton.heightAnchor.constraint(equalToConstant: 65)
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
        if let timerSoundURL = Bundle.main.url(forResource: "background_music", withExtension: "mp3") {
            do {
                timerSoundPlayer = try AVAudioPlayer(contentsOf: timerSoundURL)
                timerSoundPlayer?.numberOfLoops = -1
                timerSoundPlayer?.prepareToPlay()
                timerSoundDuration = timerSoundPlayer?.duration ?? 32.0
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
        gameTimeRemaining = 60
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
            
            // Generate new position sets
            generatePositionSets()
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
        for node in bathroomNodes {
            node.removeAllActions() // Stop any running animations
            node.removeFromParentNode()
        }
        bathroomNodes.removeAll()
        
        if let node = unusualNode {
            node.removeAllActions() // Stop any running animations
            node.removeFromParentNode()
            unusualNode = nil
        }
    }
    
    @objc func updateGameTimer() {
        gameTimeRemaining -= 1
        updateTimerLabel()
        
        if gameTimeRemaining <= 0 {
            gameTimer?.invalidate()
            isGameActive = false
            timerSoundPlayer?.stop()
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
    private func generatePositionSets() {
        guard let initialPos = initialCameraPosition,
              let initialForward = initialCameraForward else {
            return
        }
        
        positionSets = []
        let fixedZDistance = Float(2.5) // Fixed distance in Z axis
        let pentagonRadius = Float(1.5) // Radius of the pentagon in X-Y plane
        
        // Generate three sets of positions
        for setIndex in 0..<3 {
            var positions: [SCNVector3] = []
            let setOffset = Float(setIndex) * (Float.pi / 6) // 30-degree offset between sets
            
            // Calculate the center point of the pentagon
            let centerX = initialPos.x + sin(initialForward) * fixedZDistance
            let centerZ = initialPos.z + cos(initialForward) * fixedZDistance
            let centerY = initialPos.y
            
            // Generate 5 positions in a pentagon shape
            for i in 0..<5 {
                // Calculate pentagon angles (72 degrees between each point)
                let pentagonAngle = (Float.pi * 2 / 5) * Float(i) + setOffset
                
                // Calculate X and Y coordinates for the pentagon point
                let xOffset = sin(pentagonAngle) * pentagonRadius
                let yOffset = cos(pentagonAngle) * pentagonRadius
                
                // Create the position
                let position = SCNVector3(
                    centerX + xOffset,
                    centerY + yOffset,
                    centerZ
                )
                
                positions.append(position)
            }
            positionSets.append(positions)
        }
    }
    
    private func selectRandomPositionSet() {
        currentPositionSet = positionSets.randomElement() ?? []
    }
    
    private func placeGameObjects() {
        clearAllObjects()
        
        // Generate new position sets if needed
        if positionSets.isEmpty {
            generatePositionSets()
        }
        
        // Select a random position set
        selectRandomPositionSet()
        
        // Create a copy of positions and shuffle them
        var availablePositions = currentPositionSet
        
        // Randomly select which position will have the unusual object
        let unusualObjectIndex = Int.random(in: 0..<5)
        
        // Place objects
        for i in 0..<5 {
            if i == unusualObjectIndex {
                // Place unusual object at this position
                placeRandomUnusualObject(at: availablePositions[i])
            } else {
                // Place normal object at this position
                placeRandomNormalObject(at: availablePositions[i])
            }
        }
    }
    
    private func placeRandomNormalObject(at position: SCNVector3) {
        guard let randomType = normalItems.randomElement() else { return }
        guard let template = loadObjectTemplate(named: randomType)?.clone() else { return }
        
        template.name = randomType
        template.setValue("Normal", forKey: "category")
        template.position = position
        
        // Add rotation animation
        let rotationY = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 10.0)
        let rotationX = SCNAction.rotateBy(x: CGFloat(2 * Double.pi), y: 0, z: 0, duration: 10.0)
        let combinedRotation = SCNAction.group([rotationY, rotationX])
        let repeatRotation = SCNAction.repeatForever(combinedRotation)
        template.runAction(repeatRotation)
        
        sceneView.scene.rootNode.addChildNode(template)
        bathroomNodes.append(template)
    }
    
    private func placeRandomUnusualObject(at position: SCNVector3) {
        guard let randomType = unusualItems.randomElement() else { return }
        guard let template = loadObjectTemplate(named: randomType)?.clone() else { return }
        
        template.name = randomType
        template.setValue("Unusual", forKey: "category")
        template.position = position
        
        // Add rotation animation
        let rotationY = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 10.0)
        let rotationX = SCNAction.rotateBy(x: CGFloat(2 * Double.pi), y: 0, z: 0, duration: 10.0)
        let combinedRotation = SCNAction.group([rotationY, rotationX])
        let repeatRotation = SCNAction.repeatForever(combinedRotation)
        template.runAction(repeatRotation)

        sceneView.scene.rootNode.addChildNode(template)
        unusualNode = template
    }
    
    private func loadObjectTemplate(named name: String) -> SCNNode? {
        guard let scene = SCNScene(named: "\(name).usdz") else { return nil }
        let node = scene.rootNode.childNodes.first ?? scene.rootNode
        centerNodeInParent(node)
        
        let scale: Float = {
            switch name {
            case "helmet", "basketball": return 0.002
            case "blender": return 0.003
            case "camera": return 0.007
            case "tire"  : return 0.07
            case "sink" : return 0.005
            case "laptop": return 0.05
            case "teapot": return 0.04
            case "handsoap" : return 0.02
            case "drill": return 0.03
            case "plate": return 0.08
            case "toothbrush", "meds": return 0.002
            case "bucket": return 0.002
            case "wrench", "pipewrench": return 0.003
            case "redbull": return 0.002
            default: return 0.02
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
                if let name = objectName {
                    let indonesianName = getIndonesianName(for: name)
                    triggerHapticFeedback(style: .medium)
                    // Play wrong sound
                    wrongSoundPlayer?.currentTime = 0
                    wrongSoundPlayer?.play()
                    showAlert(title: "Salah", message: "\(indonesianName) adalah barang normal di kamar mandi!")
                }
            }
        }
    }
    
    // MARK: - Feedback Helpers
    private func showAlert(title: String, message: String) {
        // Create custom alert view
        let alertView = UIView()
        alertView.backgroundColor = mainColor
        alertView.layer.cornerRadius = 15
        alertView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create title label
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = textColor
        titleLabel.font = UIFont(name: "Verdana-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create message label
        let messageLabel = UILabel()
        messageLabel.text = message
        messageLabel.textColor = textColor
        messageLabel.font = UIFont(name: "Verdana", size: 18) ?? UIFont.systemFont(ofSize: 18)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create OK button
        let okButton = UIButton(type: .system)
        okButton.setTitle("OK", for: .normal)
        okButton.setTitleColor(secondaryColor, for: .normal)
        okButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18)
        okButton.translatesAutoresizingMaskIntoConstraints = false
        okButton.addTarget(self, action: #selector(dismissAlert(_:)), for: .touchUpInside)
        
        // Add subviews
        alertView.addSubview(titleLabel)
        alertView.addSubview(messageLabel)
        alertView.addSubview(okButton)
        view.addSubview(alertView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            alertView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            alertView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            titleLabel.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            messageLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),
            
            okButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            okButton.leadingAnchor.constraint(equalTo: alertView.leadingAnchor),
            okButton.trailingAnchor.constraint(equalTo: alertView.trailingAnchor),
            okButton.bottomAnchor.constraint(equalTo: alertView.bottomAnchor),
            okButton.heightAnchor.constraint(equalToConstant: 44) // Standard touch target height
        ])
        
        // Add animation
        alertView.alpha = 0
        alertView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.3) {
            alertView.alpha = 1
            alertView.transform = .identity
        }
    }
    
    @objc private func dismissAlert(_ sender: UIButton) {
        if let alertView = sender.superview {
            UIView.animate(withDuration: 0.3, animations: {
                alertView.alpha = 0
                alertView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }) { _ in
                alertView.removeFromSuperview()
            }
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
    
    // Add helper function to get Indonesian name
    private func getIndonesianName(for objectName: String) -> String {
        return objectNameTranslations[objectName] ?? objectName
    }
} 
