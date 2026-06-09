import UIKit
import CoreLocation
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
    
    var isInEast: Bool = true
    var playerScore = 0
    var pcScore = 0
    var namesSet = false

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
    var isPaused = false
    
    var backgroundMusicPlayer: AVAudioPlayer?
    var endEffectPlayer: AVAudioPlayer?
    var flipSoundPlayer: AVAudioPlayer?

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !namesSet {
            dealCards()
            setupNames()
            updateScores()
            showBackCards() // Immediate start

            resultButton.isEnabled = false
            resultButton.alpha = 0.5
            
            loadSounds()
            backgroundMusicPlayer?.play()
            
            ticker = Ticker(interval: 1.0) {
                self.tick()
            }
            ticker.start()

            namesSet = true
            
        }
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

    func showBackCards() {
        leftCardImageView.image = UIImage(named: backCardImageName)
        rightCardImageView.image = UIImage(named: backCardImageName)
        countdown = 2
        showingBack = true
        updateCountdownLabel()
    }

    func loadSounds() {

        if let bgURL = Bundle.main.url(forResource: "background_music", withExtension: "mp3"),
           let endURL = Bundle.main.url(forResource: "end_effect", withExtension: "wav"),
           let flipURL = Bundle.main.url(forResource: "flip_card", withExtension: "wav") {

            do {
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
    
    func showFrontCards() {
        guard currentIndex < playerDeck.count && currentIndex < pcDeck.count else {
            ticker.stop()
            countdownLabel.text = ""
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

        let value1 = getCardValue(from: playerCard)
        let value2 = getCardValue(from: pcCard)

        if value1 > value2 {
            playerScore += 1
        } else if value2 > value1 {
            pcScore += 1
        }

        updateScores()
        currentIndex += 1
        roundCounter += 1

        // Check if game should end
        if roundCounter >= maxRounds {
            if playerScore != pcScore {
                endGame()
                return
            }
        }

        if roundCounter > maxRounds {
            if playerScore != pcScore {
                endGame()
                return
            }
        }

        countdown = 3
        showingBack = false
        updateCountdownLabel()
    }

    func tick() {
        guard !gameEnded else { return }
        guard currentIndex < playerDeck.count else {
            ticker.stop()
            countdownLabel.text = ""
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
        countdownLabel.text = countdown > 0 ? "\(countdown)" : "\u{200B}" // Invisible placeholder to prevent layout shift
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

    @IBAction func pauseButtonTapped(_ sender: Any) {
        guard !gameEnded else { return }

            if isPaused {
                ticker.start()
                isPaused = false
                pasueButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
                backgroundMusicPlayer?.play()
                resultButton.isEnabled = false
                resultButton.alpha = 0.5
            } else {
                ticker.stop()
                isPaused = true
                countdownLabel.text = "\u{200B}"
                backgroundMusicPlayer?.pause()
                resultButton.isEnabled = true
                resultButton.alpha = 1.0
                pasueButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            }
        
    }

    @IBAction func resultButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "toResults", sender: self)
    }

    func endGame() {
        gameEnded = true
        ticker.stop()
        countdownLabel.text = ""
        backgroundMusicPlayer?.stop()
        endEffectPlayer?.play()
        resultButton.isEnabled = true
        resultButton.alpha = 1.0
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight]
    }

    override var shouldAutorotate: Bool {
        return true
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
               } else if pcScore > playerScore {
                   winnerName = "PC"
                   winnerScore = pcScore
               } else {
                   winnerName = "It's a tie!"
                   winnerScore = playerScore
               }

               resultVC.configure(winnerName: winnerName, score: winnerScore)
           }
    }
}
