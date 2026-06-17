import UIKit
import AVFoundation

class GameController: UIViewController {

    @IBOutlet weak var leftCardImageView: UIImageView!
    @IBOutlet weak var rightCardImageView: UIImageView!

    @IBOutlet weak var leftNameLabel: UILabel!
    @IBOutlet weak var rightNameLabel: UILabel!

    @IBOutlet weak var leftScoreLabel: UILabel!
    @IBOutlet weak var rightScoreLabel: UILabel!

    @IBOutlet weak var pasueButton: UIButton!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var resultButton: UIButton!

    var isInEast = true
    var playerScore = 0
    var pcScore = 0

    var playerDeck: [String] = []
    var pcDeck: [String] = []
    let backCardImageName = "card_back"
    var currentIndex = 0
    var ticker: Ticker!
    var countdown = 0
    var showingBack = true

    var roundCounter = 0
    let maxRounds = 10
    var gameEnded = false
    private var pausedByInterruption = false

    var backgroundMusicPlayer: AVAudioPlayer?
    var endEffectPlayer: AVAudioPlayer?
    var flipSoundPlayer: AVAudioPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()

        pasueButton.isHidden = true
        resultButton.isHidden = true

        dealCards()
        setupNames()
        updateScores()
        loadSounds()
        applyLabelColors()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillResignActive),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard ticker == nil, !gameEnded else { return }

        showBackCards()
        backgroundMusicPlayer?.play()

        ticker = Ticker(interval: 1.0) { [weak self] in
            self?.tick()
        }
        ticker.start()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if isMovingFromParent || isBeingDismissed {
            stopGameResources()
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            applyLabelColors()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// Pauses the round timer and background music when the app leaves the foreground.
    @objc private func appWillResignActive() {
        guard !gameEnded, ticker != nil else { return }

        pausedByInterruption = true
        ticker.stop()
        backgroundMusicPlayer?.pause()
        countdownLabel.text = "\u{200B}"
    }

    /// Resumes the round timer and music when the app returns to the foreground.
    @objc private func appDidBecomeActive() {
        guard pausedByInterruption, !gameEnded else { return }

        pausedByInterruption = false
        ticker.resume()
        backgroundMusicPlayer?.play()
        updateCountdownLabel()
    }

    func setupNames() {
        let playerName = UserDefaults.standard.string(forKey: "playerName") ?? "Player"

        if isInEast {
            leftNameLabel.text = "PC"
            rightNameLabel.text = playerName
        } else {
            leftNameLabel.text = playerName
            rightNameLabel.text = "PC"
        }
    }

    /// Shows card backs for 2 seconds before the next flip.
    func showBackCards() {
        leftCardImageView.image = UIImage(named: backCardImageName)
        rightCardImageView.image = UIImage(named: backCardImageName)
        flipSoundPlayer?.play()

        countdown = 2
        showingBack = true
        updateCountdownLabel()
    }

    func loadSounds() {
        if let bgURL = Bundle.main.url(forResource: "background_music", withExtension: "mp3"),
           let endURL = Bundle.main.url(forResource: "end_effect", withExtension: "wav"),
           let flipURL = Bundle.main.url(forResource: "flip_card", withExtension: "wav") {

            do {
                try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)

                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: bgURL)
                backgroundMusicPlayer?.numberOfLoops = -1
                backgroundMusicPlayer?.volume = 0.2

                endEffectPlayer = try AVAudioPlayer(contentsOf: endURL)
                endEffectPlayer?.volume = 1.0

                flipSoundPlayer = try AVAudioPlayer(contentsOf: flipURL)
                flipSoundPlayer?.volume = 1.0
            } catch {
                print("Error loading sounds: \(error)")
            }
        }
    }

    /// Reveals the current cards, updates scores, and starts the 3-second display window.
    func showFrontCards() {
        guard currentIndex < playerDeck.count && currentIndex < pcDeck.count else {
            endGame()
            return
        }

        flipSoundPlayer?.play()

        let playerCard = playerDeck[currentIndex]
        let pcCard = pcDeck[currentIndex]

        if isInEast {
            leftCardImageView.image = UIImage(named: pcCard)
            rightCardImageView.image = UIImage(named: playerCard)
        } else {
            leftCardImageView.image = UIImage(named: playerCard)
            rightCardImageView.image = UIImage(named: pcCard)
        }

        let playerValue = getCardValue(from: playerCard)
        let pcValue = getCardValue(from: pcCard)

        if playerValue > pcValue {
            playerScore += 1
        } else if pcValue > playerValue {
            pcScore += 1
        }

        updateScores()
        currentIndex += 1
        roundCounter += 1

        if roundCounter >= maxRounds {
            endGame()
            return
        }

        countdown = 3
        showingBack = false
        updateCountdownLabel()
    }

    /// Drives the 5-second flip cycle: 2 seconds on the back, 3 seconds on the front.
    func tick() {
        guard !gameEnded else { return }
        guard currentIndex < playerDeck.count else {
            endGame()
            return
        }

        countdown -= 1
        updateCountdownLabel()

        if countdown <= 0 {
            if showingBack {
                showFrontCards()
            } else {
                showBackCards()
            }
        }
    }

    func updateCountdownLabel() {
        countdownLabel.text = countdown > 0 ? "\(countdown)" : "\u{200B}"
    }

    func getCardValue(from cardName: String) -> Int {
        let valuePart = String(cardName.dropLast())
        return Int(valuePart) ?? 0
    }

    func updateScores() {
        leftScoreLabel.text = isInEast ? "\(pcScore)" : "\(playerScore)"
        rightScoreLabel.text = isInEast ? "\(playerScore)" : "\(pcScore)"
    }

    func dealCards() {
        let suits = ["C", "D", "H", "S"]
        let values = Array(2...14)
        var allCards: [String] = []

        for value in values {
            for suit in suits {
                allCards.append("\(value)\(suit)")
            }
        }

        allCards.shuffle()
        playerDeck = Array(allCards.prefix(26))
        pcDeck = Array(allCards.suffix(26))
    }

    /// Stops timers and audio when the game screen is dismissed.
    private func stopGameResources() {
        ticker?.stop()
        backgroundMusicPlayer?.stop()
    }

    /// Ends the game after 10 rounds and navigates to the result screen.
    func endGame() {
        guard !gameEnded else { return }

        gameEnded = true
        pausedByInterruption = false
        ticker?.stop()
        countdownLabel.text = ""
        backgroundMusicPlayer?.stop()
        endEffectPlayer?.play()

        performSegue(withIdentifier: "toResultVC", sender: self)
    }

    private func applyLabelColors() {
        let color = UIColor.label
        [leftNameLabel, rightNameLabel, leftScoreLabel, rightScoreLabel, countdownLabel].forEach {
            $0?.textColor = color
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        [.portrait, .landscapeLeft, .landscapeRight]
    }

    override var shouldAutorotate: Bool {
        true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toResultVC",
           let resultVC = segue.destination as? ResultViewController {

            let playerName = UserDefaults.standard.string(forKey: "playerName") ?? "Player"

            let winnerName: String
            let winnerScore: Int

            if playerScore > pcScore {
                winnerName = playerName
                winnerScore = playerScore
            } else {
                winnerName = "PC"
                winnerScore = pcScore
            }

            resultVC.configure(winnerName: winnerName, score: winnerScore)
        }
    }
}
