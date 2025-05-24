import UIKit
import SceneKit
import ARKit
import AVFoundation
import SwiftUI

/// A view controller that manages the AR tutorial experience for MemoAR.
/// This controller guides users through the game mechanics with interactive steps
/// and includes a practice game session.
class TutorialViewController: UIViewController, ARSCNViewDelegate {
    // MARK: - Properties
    
    /// Callback for navigation to home screen
    var requestSelectThemeHandler: (() -> Void)?
    
    /// The AR scene view that displays the AR content
    var sceneView: ARSCNView!
    
    /// Current step in the tutorial sequence
    private var currentStep = 0
    
    /// Collection of tutorial object nodes
    private var tutorialObjects: [SCNNode] = []
    
    /// Collection of clicked objects in step 5
    private var clickedObjects: Set<String> = []
    
    /// Collection of trial game object nodes
    private var trialNodes: [SCNNode] = []
    
    /// The unusual object node in the current scene
    private var unusualNode: SCNNode?
    
    /// Initial camera position for object placement
    private var initialCameraPosition: SCNVector3?
    
    /// Initial camera forward direction for object placement
    private var initialCameraForward: Float?
    
    /// Predefined sets of positions for object placement
    private var positionSets: [[SCNVector3]] = []
    
    /// Currently selected position set for object placement
    private var currentPositionSet: [SCNVector3] = []
    
    // MARK: - UI Elements
    
    /// Label displaying tutorial messages
    private var messageLabel: UILabel!
    
    /// Button to continue to next tutorial step
    private var continueButton: UIButton!
    
    /// Button to start the trial game
    private var startTrialButton: UIButton!
    
    /// Container view for tutorial UI elements
    private var containerView: UIView!
    
    /// Label displaying current score
    private var scoreLabel: UILabel!
    
    /// Label displaying remaining time
    private var timerLabel: UILabel!
    
    // Colors from HomeScreen
    private let mainColor = UIColor(red: 0.95, green: 0.78, blue: 0.44, alpha: 1.0) // Soft Yellow
    private let secondaryColor = UIColor(red: 0.69, green: 0.25, blue: 0.07, alpha: 1.0) // Dark Brown
    private let backgroundColor = UIColor(red: 0.98, green: 0.97, blue: 0.93, alpha: 1.0) // Light cream
    private let textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0) // Dark text
    
    // MARK: - Game Variables
    
    /// Current score in the trial game
    private var score = 0
    
    /// Timer for the trial game
    private var gameTimer: Timer?
    
    /// Remaining time in the trial game
    private var gameTimeRemaining = 30
    
    /// Flag indicating if the trial game is active
    private var isGameActive = false
    
    // MARK: - Sound Effects
    
    /// Player for background music
    private var timerSoundPlayer: AVAudioPlayer?
    
    /// Player for found object sound
    private var foundSoundPlayer: AVAudioPlayer?
    
    /// Player for wrong object sound
    private var wrongSoundPlayer: AVAudioPlayer?
    
    /// Duration of the timer sound
    private var timerSoundDuration: TimeInterval = 32.0
    
    /// Last time the timer sound was played
    private var lastTimerSoundTime: TimeInterval = 0
    
    // MARK: - Game Content
    
    /// Normal items specific to the kitchen theme
    private let normalItems = ["blender", "stove", "plate", "teapot", "redbull"]
    
    /// Fixed tutorial items in specific order
    private let tutorialItems = ["blender", "stove", "plate", "teapot"]
    
    /// Unusual items that can appear in the game
    private let unusualItems = ["helmet", "laptop", "camera", "tire", "basketball",  
                               "wrench", "pipewrench", "drill", "toothbrush", "sink", "bucket", 
                                "meds"]
    
    /// Mapping of object names to Indonesian translations
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
    
    /// Gets the Indonesian name for an object
    private func getIndonesianName(for objectName: String) -> String {
        return objectNameTranslations[objectName] ?? objectName
    }
    
    /// Tutorial step messages
    private let tutorialSteps = [
        "Selamat datang di MemoAR! Ayo belajar cara berlatih.",
        "Dalam sesi latihan ini, kamu akan menemukan objek yang tidak biasa di sekitar kamu.",
        "Pertama-tama, kamu akan memilih tema dari objek-objek yang muncul.",
        "Untuk tutorial ini, mari gunakan tema Dapur terlebih dahulu",
        "Lihat sekeliling! Kamu akan melihat 4 objek yang umum di dapur.",
        "Klik semua objek tersebut untuk lanjut.",
        "Sekarang, muncul objek yang tidak sesuai tema dapur. Coba cari dan klik objek itu!",
        "Bagus! Kamu berhasil memilih objek yang tepat!",
        "Dalam latihan, kamu perlu mencari objek yang tidak sesuai tema sebanyak mungkin dalam waktu 60 detik.",
        "Mari kita coba sesi latihan singkat selama 30 detik. Siap?",
        "Sesi latihan selesai! Kamu berhasil menemukan %d objek yang tidak biasa!",
        "Sekarang kamu siap untuk bermain! Kembali ke halaman utama untuk mulai latihan."
    ]
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAR()
        setupUI()
        setupSoundEffects()
        startTutorial()
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
    }
    
    // MARK: - Setup Methods
    
    /// Sets up the AR scene view and gesture recognizers
    private func setupAR() {
        sceneView = ARSCNView(frame: view.bounds)
        view.addSubview(sceneView)
        sceneView.delegate = self
        sceneView.showsStatistics = false
        sceneView.autoenablesDefaultLighting = true
        
        let scene = SCNScene()
        sceneView.scene = scene
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    /// Sets up the user interface elements
    private func setupUI() {
        // First create all UI elements
        setupMessageLabel()
        setupContainerView()
        setupContinueButton()
        setupStartTrialButton()
        setupScoreLabel()
        setupTimerLabel()
    }
    
    /// Sets up the container view for tutorial UI
    private func setupContainerView() {
        // Create container for buttons
        containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = .clear  // Make container background transparent
        containerView.layer.cornerRadius = 15
        view.addSubview(containerView)
        
        // Create message box
        let messageBox = UIView()
        messageBox.translatesAutoresizingMaskIntoConstraints = false
        messageBox.backgroundColor = mainColor.withAlphaComponent(0.7)
        messageBox.layer.cornerRadius = 15
        view.addSubview(messageBox)
        
        // Add message label to message box
        messageBox.addSubview(messageLabel)
        
        // Update constraints
        NSLayoutConstraint.activate([
            // Message box constraints - position it below the score/timer labels
            messageBox.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            messageBox.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            messageBox.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            messageBox.heightAnchor.constraint(equalToConstant: 120),
            
            // Message label constraints within message box
            messageLabel.topAnchor.constraint(equalTo: messageBox.topAnchor, constant: 15),
            messageLabel.leadingAnchor.constraint(equalTo: messageBox.leadingAnchor, constant: 15),
            messageLabel.trailingAnchor.constraint(equalTo: messageBox.trailingAnchor, constant: -15),
            messageLabel.bottomAnchor.constraint(equalTo: messageBox.bottomAnchor, constant: -15),
            
            // Container view constraints (for buttons)
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    /// Sets up the message label
    private func setupMessageLabel() {
        messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.textColor = textColor
        messageLabel.font = UIFont(name: "Verdana", size: 20)
        messageLabel.adjustsFontSizeToFitWidth = true
        messageLabel.minimumScaleFactor = 0.8
    }
    
    /// Sets up the continue button
    private func setupContinueButton() {
        continueButton = UIButton(type: .system)
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle("Lanjut", for: .normal)
        continueButton.backgroundColor = mainColor
        continueButton.setTitleColor(secondaryColor, for: .normal)
        continueButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 24)
        continueButton.layer.cornerRadius = 16
        continueButton.layer.borderWidth = 3
        continueButton.layer.borderColor = secondaryColor.withAlphaComponent(0.6).cgColor
        continueButton.addTarget(self, action: #selector(continueTutorial), for: .touchUpInside)
        containerView.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            continueButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            continueButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 250),
            continueButton.heightAnchor.constraint(equalToConstant: 65)
        ])
    }
    
    /// Sets up the start trial button
    private func setupStartTrialButton() {
        startTrialButton = UIButton(type: .system)
        startTrialButton.translatesAutoresizingMaskIntoConstraints = false
        startTrialButton.setTitle("Mulai Latihan", for: .normal)
        startTrialButton.backgroundColor = mainColor
        startTrialButton.setTitleColor(secondaryColor, for: .normal)
        startTrialButton.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 24)
        startTrialButton.layer.cornerRadius = 16
        startTrialButton.layer.borderWidth = 3
        startTrialButton.layer.borderColor = secondaryColor.withAlphaComponent(0.6).cgColor
        startTrialButton.isHidden = true
        startTrialButton.addTarget(self, action: #selector(startTrialGame), for: .touchUpInside)
        containerView.addSubview(startTrialButton)
        
        NSLayoutConstraint.activate([
            startTrialButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            startTrialButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            startTrialButton.widthAnchor.constraint(equalToConstant: 250),
            startTrialButton.heightAnchor.constraint(equalToConstant: 65)
        ])
    }
    
    /// Sets up the score label
    private func setupScoreLabel() {
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.text = "Poin: 0"
        scoreLabel.textColor = textColor
        scoreLabel.backgroundColor = mainColor
        scoreLabel.textAlignment = .center
        scoreLabel.font = UIFont(name: "Verdana", size: 16)
        scoreLabel.layer.cornerRadius = 10
        scoreLabel.layer.masksToBounds = true
        scoreLabel.isHidden = true
        view.addSubview(scoreLabel)
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scoreLabel.widthAnchor.constraint(equalToConstant: 100),
            scoreLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    /// Sets up the timer label
    private func setupTimerLabel() {
        timerLabel = UILabel()
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.text = "Waktu: 30s"
        timerLabel.textColor = textColor
        timerLabel.backgroundColor = mainColor
        timerLabel.textAlignment = .center
        timerLabel.font = UIFont(name: "Verdana", size: 16)
        timerLabel.layer.cornerRadius = 10
        timerLabel.layer.masksToBounds = true
        timerLabel.isHidden = true
        view.addSubview(timerLabel)
        
        NSLayoutConstraint.activate([
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            timerLabel.widthAnchor.constraint(equalToConstant: 100),
            timerLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    /// Sets up the UI constraints
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 50),
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            
            messageLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            
            continueButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            continueButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 150),
            continueButton.heightAnchor.constraint(equalToConstant: 50),
            
            startTrialButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            startTrialButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            startTrialButton.widthAnchor.constraint(equalToConstant: 150),
            startTrialButton.heightAnchor.constraint(equalToConstant: 50),
            startTrialButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            
            scoreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            scoreLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scoreLabel.widthAnchor.constraint(equalToConstant: 100),
            scoreLabel.heightAnchor.constraint(equalToConstant: 40),
            
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            timerLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            timerLabel.widthAnchor.constraint(equalToConstant: 100),
            timerLabel.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    /// Sets up sound effects for the game
    private func setupSoundEffects() {
        setupTimerSound()
        setupFoundSound()
        setupWrongSound()
    }
    
    /// Sets up the timer sound
    private func setupTimerSound() {
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
    }
    
    /// Sets up the found object sound
    private func setupFoundSound() {
        if let foundSoundURL = Bundle.main.url(forResource: "object_found", withExtension: "mp3") {
            do {
                foundSoundPlayer = try AVAudioPlayer(contentsOf: foundSoundURL)
                foundSoundPlayer?.prepareToPlay()
            } catch {
                print("Could not create found sound player: \(error)")
            }
        }
    }
    
    /// Sets up the wrong object sound
    private func setupWrongSound() {
        if let wrongSoundURL = Bundle.main.url(forResource: "wrong_object", withExtension: "mp3") {
            do {
                wrongSoundPlayer = try AVAudioPlayer(contentsOf: wrongSoundURL)
                wrongSoundPlayer?.prepareToPlay()
            } catch {
                print("Could not create wrong sound player: \(error)")
            }
        }
    }
    
    // MARK: - Tutorial Methods
    
    /// Starts the tutorial sequence
    private func startTutorial() {
        showCurrentStep()
    }
    
    /// Shows the current tutorial step
    private func showCurrentStep() {
        guard currentStep < tutorialSteps.count else {
            dismiss(animated: true)
            return
        }
        
        messageLabel.text = tutorialSteps[currentStep]
        
        switch currentStep {
        case 4:
            continueButton.isEnabled = true
            startTrialButton.isHidden = true
            continueButton.isHidden = false
            containerView.isHidden = false
            generateNormalObjects()

        case 5:
            // Reset clicked objects tracking
            continueButton.isEnabled = false
            startTrialButton.isHidden = true
            continueButton.isHidden = true
            containerView.isHidden = false
        case 6:
            generateNormalObjects()
            generateUnusualObject()
            continueButton.isEnabled = false
            startTrialButton.isHidden = true
            continueButton.isHidden = true  // Hide continue button until correct object is tapped
            containerView.isHidden = false
        case 9:
            // Show start trial button instead of continue button
            continueButton.isHidden = true
            startTrialButton.isHidden = false
            containerView.isHidden = false
        case 10:
            startTrialGame()
        case 11:
            // Show final message with continue button
            continueButton.setTitle("Halaman Utama", for: .normal)
            continueButton.isHidden = false
            startTrialButton.isHidden = true
            containerView.isHidden = false
            continueButton.isEnabled = true
        default:
            continueButton.isEnabled = true
            continueButton.isHidden = false
            startTrialButton.isHidden = true
            containerView.isHidden = false
        }
    }
    
    // MARK: - Game Methods
    
    /// Starts the trial game
    @objc private func startTrialGame() {
        // Clear tutorial objects
        tutorialObjects.forEach { $0.removeFromParentNode() }
        tutorialObjects.removeAll()
        unusualNode?.removeFromParentNode()
        unusualNode = nil
        
        score = 0
        gameTimeRemaining = 30
        isGameActive = true
        updateScoreLabel()
        updateTimerLabel()
        
        // Show game UI, hide tutorial UI
        scoreLabel.isHidden = false
        timerLabel.isHidden = false
        containerView.isHidden = true  // Hide the button container
        messageLabel.superview?.isHidden = true  // Hide the message box
        continueButton.isHidden = true
        startTrialButton.isHidden = true
        
        if let cameraTransform = sceneView.session.currentFrame?.camera.transform {
            let cameraMat = SCNMatrix4(cameraTransform)
            initialCameraPosition = SCNVector3(cameraMat.m41, cameraMat.m42, cameraMat.m43)
            
            let forwardX = -cameraMat.m31
            let forwardZ = -cameraMat.m33
            initialCameraForward = atan2(forwardX, forwardZ)
            
            generatePositionSets()
        }
        
        clearAllObjects()
        
        timerSoundPlayer?.currentTime = 0
        timerSoundPlayer?.play()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateGameTimer), userInfo: nil, repeats: true)
        placeGameObjects()
    }
    
    /// Stops the trial game
    private func stopGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        isGameActive = false
        clearAllObjects()
        
        timerSoundPlayer?.stop()
        
        // Hide game UI
        scoreLabel.isHidden = true
        timerLabel.isHidden = true
        
        // Show message container with score
        containerView.isHidden = false
        messageLabel.superview?.isHidden = false  // Show the message box
        messageLabel.text = String(format: tutorialSteps[10], score)
        continueButton.setTitle("Lanjut", for: .normal)
        continueButton.isHidden = false
        continueButton.isEnabled = true
        
        // Set current step to 10 to ensure proper dismissal
        currentStep = 10
    }
    
    /// Updates the game timer
    @objc private func updateGameTimer() {
        gameTimeRemaining -= 1
        updateTimerLabel()
        
        if gameTimeRemaining <= 0 {
            stopGame()
        }
    }
    
    /// Updates the timer label
    private func updateTimerLabel() {
        timerLabel.text = "Waktu: \(gameTimeRemaining)s"
    }
    
    /// Updates the score label
    private func updateScoreLabel() {
        scoreLabel.text = "Poin: \(score)"
    }
    
    // MARK: - Object Management
    
    /// Generates position sets for object placement
    private func generatePositionSets() {
        guard let initialPos = initialCameraPosition,
              let initialForward = initialCameraForward else {
            return
        }
        
        positionSets = []
        let fixedZDistance = Float(2.5)
        let pentagonRadius = Float(1.5)
        
        for setIndex in 0..<3 {
            var positions: [SCNVector3] = []
            let setOffset = Float(setIndex) * (Float.pi / 6)
            
            let centerX = initialPos.x + sin(initialForward) * fixedZDistance
            let centerZ = initialPos.z + cos(initialForward) * fixedZDistance
            let centerY = initialPos.y
            
            for i in 0..<5 {
                let pentagonAngle = (Float.pi * 2 / 5) * Float(i) + setOffset
                
                let xOffset = sin(pentagonAngle) * pentagonRadius
                let yOffset = cos(pentagonAngle) * pentagonRadius
                
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
    
    /// Generates normal objects for the tutorial
    private func generateNormalObjects() {
        // Clear existing objects
        tutorialObjects.forEach { $0.removeFromParentNode() }
        tutorialObjects.removeAll()
        clickedObjects.removeAll()  // Reset clicked objects tracking
        
        // Store initial camera position when objects are generated
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
        
        // Select a random position set
        selectRandomPositionSet()
        
        // Place objects at first 4 positions in fixed order
        for i in 0..<4 {
            let objectType = tutorialItems[i]
            guard let template = loadObjectTemplate(named: objectType)?.clone() else { return }
            
            template.name = objectType
            template.setValue("Normal", forKey: "category")
            template.position = currentPositionSet[i]
            
            // Add rotation animation
            let rotationY = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 10.0)
            let rotationX = SCNAction.rotateBy(x: CGFloat(2 * Double.pi), y: 0, z: 0, duration: 10.0)
            let combinedRotation = SCNAction.group([rotationY, rotationX])
            let repeatRotation = SCNAction.repeatForever(combinedRotation)
            template.runAction(repeatRotation)
            
            sceneView.scene.rootNode.addChildNode(template)
            tutorialObjects.append(template)
        }
    }
    
    /// Generates an unusual object for the tutorial
    private func generateUnusualObject() {
        unusualNode?.removeFromParentNode()
        
        guard let randomType = unusualItems.randomElement() else { return }
        guard let template = loadObjectTemplate(named: randomType)?.clone() else { return }
        
        template.name = randomType
        template.setValue("Unusual", forKey: "category")
        template.position = currentPositionSet[4] // Use the 5th position
        
        // Add rotation animation
        let rotationY = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 10.0)
        let rotationX = SCNAction.rotateBy(x: CGFloat(2 * Double.pi), y: 0, z: 0, duration: 10.0)
        let combinedRotation = SCNAction.group([rotationY, rotationX])
        let repeatRotation = SCNAction.repeatForever(combinedRotation)
        template.runAction(repeatRotation)
        
        sceneView.scene.rootNode.addChildNode(template)
        unusualNode = template
    }
    
    /// Selects a random position set
    private func selectRandomPositionSet() {
        currentPositionSet = positionSets.randomElement() ?? []
    }
    
    /// Places game objects in the scene
    private func placeGameObjects() {
        clearAllObjects()
        
        if positionSets.isEmpty {
            generatePositionSets()
        }
        
        selectRandomPositionSet()
        
        let availablePositions = currentPositionSet
        let unusualObjectIndex = Int.random(in: 0..<5)
        
        for i in 0..<5 {
            if i == unusualObjectIndex {
                placeRandomUnusualObject(at: availablePositions[i])
            } else {
                placeRandomNormalObject(at: availablePositions[i])
            }
        }
    }
    
    /// Clears all objects from the scene
    private func clearAllObjects() {
        for node in trialNodes {
            node.removeAllActions()
            node.removeFromParentNode()
        }
        trialNodes.removeAll()
        
        if let node = unusualNode {
            node.removeAllActions()
            node.removeFromParentNode()
            unusualNode = nil
        }
    }
    
    /// Places a random unusual object at the specified position
    private func placeRandomUnusualObject(at position: SCNVector3) {
        guard let randomType = unusualItems.randomElement() else { return }
        guard let template = loadObjectTemplate(named: randomType)?.clone() else { return }
        
        template.name = randomType
        template.setValue("Unusual", forKey: "category")
        template.position = position
        
        let rotationY = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 10.0)
        let rotationX = SCNAction.rotateBy(x: CGFloat(2 * Double.pi), y: 0, z: 0, duration: 10.0)
        let combinedRotation = SCNAction.group([rotationY, rotationX])
        let repeatRotation = SCNAction.repeatForever(combinedRotation)
        template.runAction(repeatRotation)
        
        sceneView.scene.rootNode.addChildNode(template)
        unusualNode = template
    }
    
    /// Places a random normal object at the specified position
    private func placeRandomNormalObject(at position: SCNVector3) {
        guard let randomType = normalItems.randomElement() else { return }
        guard let template = loadObjectTemplate(named: randomType)?.clone() else { return }
        
        template.name = randomType
        template.setValue("Normal", forKey: "category")
        template.position = position
        
        let rotationY = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 10.0)
        let rotationX = SCNAction.rotateBy(x: CGFloat(2 * Double.pi), y: 0, z: 0, duration: 10.0)
        let combinedRotation = SCNAction.group([rotationY, rotationX])
        let repeatRotation = SCNAction.repeatForever(combinedRotation)
        template.runAction(repeatRotation)
        
        sceneView.scene.rootNode.addChildNode(template)
        trialNodes.append(template)
    }
    
    /// Loads an object template with the specified name
    private func loadObjectTemplate(named name: String) -> SCNNode? {
        guard let scene = SCNScene(named: "\(name).usdz") else { return nil }
        let node = scene.rootNode.childNodes.first ?? scene.rootNode
        
        let (min, max) = node.boundingBox
        let centerX = (min.x + max.x) / 2
        let centerY = (min.y + max.y) / 2
        let centerZ = (min.z + max.z) / 2
        node.position = SCNVector3(-centerX, -centerY, -centerZ)
        
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
        node.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(node: node, options: nil))
        
        return node
    }
    
    // MARK: - Interaction Methods
    
    /// Handles tap gestures on the scene
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(location, options: [:])
        
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
                foundSoundPlayer?.currentTime = 0
                foundSoundPlayer?.play()
                
                if isGameActive {
                    score += 1
                    updateScoreLabel()
                    showCorrectBadge(at: location)
                    placeGameObjects()
                } else {
                    showCorrectBadge(at: location)
                    // Clear all objects after successful identification
                    tutorialObjects.forEach { $0.removeFromParentNode() }
                    tutorialObjects.removeAll()
                    unusualNode?.removeFromParentNode()
                    unusualNode = nil
                    // Show continue button after correct object is tapped
                    continueButton.isHidden = false
                    currentStep += 1
                    showCurrentStep()
                }
            } else {
                if currentStep == 5 {
                    if let name = objectName {
                        // Check if this object hasn't been clicked yet
                        if !clickedObjects.contains(name) {
                            foundSoundPlayer?.currentTime = 0
                            foundSoundPlayer?.play()
                            
                            // Add to clicked objects
                            clickedObjects.insert(name)
                            
                            // Find and remove the clicked object
                            if let index = tutorialObjects.firstIndex(where: { $0.name == name }) {
                                let node = tutorialObjects[index]
                                node.removeFromParentNode()
                                tutorialObjects.remove(at: index)
                            }
                            
                            
                            // Check if all objects have been clicked
                            if tutorialObjects.isEmpty {
                                let indonesianName = getIndonesianName(for: name)
                                let message = "Benar! Ini adalah \(indonesianName), objek normal di dapur. Kamu berhasil klik semua objek!"
                                let attributedMessage = NSMutableAttributedString(string: message)
                                let boldRange = (message as NSString).range(of: "Benar")
                                attributedMessage.addAttribute(.font, value: UIFont(name: "Verdana-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18), range: boldRange)
                                messageLabel.attributedText = attributedMessage

                                continueButton.isEnabled = true
                                continueButton.isHidden = false
                            } else {
                                let indonesianName = getIndonesianName(for: name)
                                let message = "Benar! Ini adalah \(indonesianName), objek normal di dapur. Klik objek lainnya"
                                let attributedMessage = NSMutableAttributedString(string: message)
                                let boldRange = (message as NSString).range(of: "Benar")
                                attributedMessage.addAttribute(.font, value: UIFont(name: "Verdana-Bold", size: 18) ?? UIFont.boldSystemFont(ofSize: 18), range: boldRange)
                                messageLabel.attributedText = attributedMessage

                            }
                        }
                    }
                }else if currentStep == 4 {
                }else if isGameActive {
                    wrongSoundPlayer?.currentTime = 0
                    wrongSoundPlayer?.play()
                    if let name = objectName {
                        let indonesianName = getIndonesianName(for: name)
                        showAlert(title: "Salah", message: "\(indonesianName) adalah objek normal di dapur!")
                    }
                } else {
                    wrongSoundPlayer?.currentTime = 0
                    wrongSoundPlayer?.play()
                    if let name = objectName {
                        let indonesianName = getIndonesianName(for: name)
                        showAlert(title: "Salah", message: "\(indonesianName) adalah objek normal di dapur!")
                    }
                }
            }
        }
    }
    
    /// Continues to the next tutorial step
    @objc private func continueTutorial() {
        if currentStep == 10 {
            // Show final message with home button
            messageLabel.text = tutorialSteps[11]
            continueButton.setTitle("Halaman Utama", for: .normal)
            currentStep = 11
        } else if currentStep == 11 {
            // Use the callback to navigate back to home screen
            requestSelectThemeHandler?()
        } else {
            currentStep += 1
            showCurrentStep()
        }
    }
    
    // MARK: - Feedback Methods
    
    /// Shows a floating text at the specified position
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
    
    /// Shows an alert with the specified title and message
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        // Configure alert appearance with custom font sizes
        let attributedTitle = NSAttributedString(
            string: title + "\n",
            attributes: [
                .font: UIFont(name: "Verdana-Bold", size: 20) ?? UIFont.boldSystemFont(ofSize: 18),
                .foregroundColor: UIColor.red
            ]
        )
        
        let attributedMessage = NSAttributedString(
            string: message,
            attributes: [.font: UIFont(name: "Verdana", size: 18) ?? UIFont.systemFont(ofSize: 18)]
        )
        
        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func showCorrectBadge(at position: CGPoint) {
        guard let badgeImage = UIImage(named: "correct-badge") else {
            print("Error: Could not load correct-badge image.")
            // Fallback to old text behavior or do nothing
            return
        }
        let imageView = UIImageView(image: badgeImage)
        imageView.frame.size = CGSize(width: 153.5, height: 50) // Adjust size as needed
        imageView.center = position
        view.addSubview(imageView)
        
        UIView.animate(withDuration: 0.8, animations: {
            imageView.alpha = 0
            imageView.center.y -= 50
        }) { _ in
            imageView.removeFromSuperview()
        }
    }
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
} 
