import UIKit
import SceneKit
import ARKit
import CoreHaptics
import SwiftUI

class KitchenViewController: UIViewController, ARSCNViewDelegate, UIGestureRecognizerDelegate {
    // MARK: - Properties
    var sceneView: ARSCNView!
    var scoreUpdateHandler: ((Int) -> Void)?
    var gameSaveHandler: (() -> Void)?
    var requestSelectThemeHandler: (() -> Void)?
    var requestShowHistoryHandler: (() -> Void)?
    var userName: String = "Pemain"
    var themeDisplayName: String = "Dapur"
    
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
    
    // Theme-specific normal items
    private let normalItems = ["blender", "stove", "plate", "teapot"]
    
    // Theme-specific unusual items
    private let unusualItems = ["helmet", "laptop", "camera", "tire", "basketball", "redbull", "wrench", "pipewrench", "drill", "toothbrush", "sink", "bucket", "handsoap", "meds"]
    
    // Debug mode flag
    private let debugMode = false
    private let maxObjects = 5
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAR()
        setupUI()
        setupTapGestureRecognizer()
        setupHaptics()
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
    
    private func setupTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGestureRecognizer.delegate = self
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupHaptics() {
        hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        hapticFeedbackGenerator?.prepare()
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
        gameTimeRemaining = 15
        isGameActive = true
        updateScoreLabel()
        updateTimerLabel()
        
        clearAllObjects()
        startButton.isHidden = true
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateGameTimer), userInfo: nil, repeats: true)
        placeGameObjects()
    }
    
    func stopGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        isGameActive = false
        startButton.isHidden = false
        clearAllObjects()
    }
    
    private func clearAllObjects() {
        for node in kitchenNodes {
            node.removeFromParentNode()
        }
        kitchenNodes.removeAll()
        
        if let node = unusualNode {
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
        
        let randomPosition = generateRandomPosition()
        template.position = randomPosition
        
        sceneView.scene.rootNode.addChildNode(template)
        kitchenNodes.append(template)
    }
    
    private func placeRandomUnusualObject() {
        guard let randomType = unusualItems.randomElement() else { return }
        guard let template = loadObjectTemplate(named: randomType)?.clone() else { return }
        
        template.name = randomType
        template.setValue("Unusual", forKey: "category")
        
        var randomPosition = generateRandomPosition()
        var attempts = 0
        let maxAttempts = 15
        
        while isPositionTooCloseToExistingObjects(randomPosition) && attempts < maxAttempts {
            randomPosition = generateRandomPosition()
            attempts += 1
        }
        
        template.position = randomPosition
        sceneView.scene.rootNode.addChildNode(template)
        unusualNode = template
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
    
    private func generateRandomPosition() -> SCNVector3 {
        guard let cameraTransform = sceneView.session.currentFrame?.camera.transform else {
            return SCNVector3(0, 0, -0.8)
        }
        
        let cameraMat = SCNMatrix4(cameraTransform)
        let cameraPos = SCNVector3(cameraMat.m41, cameraMat.m42, cameraMat.m43)
        
        let randomAngle = Float.random(in: -Float.pi/3...Float.pi/3)
        let distance = Float.random(in: 0.8...1.5)
        
        let forwardX = -cameraMat.m31
        let forwardZ = -cameraMat.m33
        let forwardAngle = atan2(forwardX, forwardZ)
        let finalAngle = forwardAngle + randomAngle
        
        let xPosition = cameraPos.x + sin(finalAngle) * distance
        let zPosition = cameraPos.z + cos(finalAngle) * distance
        let yPosition = cameraPos.y + Float.random(in: -0.4 ... -0.2)
        
        return SCNVector3(xPosition, yPosition, zPosition)
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
                showFloatingText(at: tapLocation, text: "+1", color: .green)
                placeGameObjects()
            } else {
                let objectName = hitNode.name ?? "object"
                triggerHapticFeedback(style: .medium)
                showAlert(title: "Incorrect", message: "That's a normal kitchen object!")
            }
        }
    }
    
    private func isPositionTooCloseToExistingObjects(_ position: SCNVector3, minimumDistance: Float = 0.3) -> Bool {
        for node in kitchenNodes {
            let distance = calculateDistance(position, node.position)
            if distance < minimumDistance {
                return true
            }
        }
        
        if let unusualNode = unusualNode {
            let distance = calculateDistance(position, unusualNode.position)
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