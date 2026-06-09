import UIKit
import AVFoundation

class ResultViewController: UIViewController {
    var winnerName: String?
    var winnerScore: Int?

    @IBOutlet weak var winnerLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!

    @IBOutlet weak var backButton: UIButton!
    
    var winSoundPlayer: AVAudioPlayer?
    var loseSoundPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if winnerName == "tie" {
            winnerLabel.text = "It's a tie!"
            scoreLabel.text = ""
        } else {
            winnerLabel.text = "Winner: \(winnerName ?? "Unknown")"
            scoreLabel.text = "Score: \(winnerScore ?? 0)"
        }
        
        if let winURL = Bundle.main.url(forResource: "yay_sound", withExtension: "wav"),
           let loseURL = Bundle.main.url(forResource: "group_booing", withExtension: "wav") {
            winSoundPlayer = try? AVAudioPlayer(contentsOf: winURL)
            loseSoundPlayer = try? AVAudioPlayer(contentsOf: loseURL)
        }
        playResultSound()
        if winnerName == UserDefaults.standard.string(forKey: "playerName") {
            showConfetti()
        }
   
    }
    
    func playResultSound() {
        let playerName = UserDefaults.standard.string(forKey: "playerName") ?? "Player"

        if winnerName == playerName {
            winSoundPlayer?.play()
        } else if winnerName == "PC" {
            loseSoundPlayer?.play()
        }
    }
    
    func showConfetti() {
            let emitter = CAEmitterLayer()
            emitter.emitterPosition = CGPoint(x: view.bounds.width / 2, y: -10)
            emitter.emitterShape = .line
            emitter.emitterSize = CGSize(width: view.bounds.width, height: 1)

            var cells: [CAEmitterCell] = []

            for color in [UIColor.systemRed, UIColor.systemBlue, UIColor.systemYellow, UIColor.systemGreen] {
                let cell = CAEmitterCell()
                cell.birthRate = 6
                cell.lifetime = 5.0
                cell.velocity = CGFloat.random(in: 100...200)
                cell.velocityRange = 50
                cell.emissionLongitude = .pi
                cell.emissionRange = .pi / 4
                cell.spin = 3.5
                cell.spinRange = 1.0
                cell.scale = 0.05
                cell.scaleRange = 0.02
                cell.color = color.cgColor
                cell.contents = UIImage(named: "fireworks")?.cgImage
                cells.append(cell)
            }

            emitter.emitterCells = cells
            view.layer.addSublayer(emitter)

            DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
                emitter.birthRate = 0
            }
        }

    func configure(winnerName: String, score: Int) {
        self.winnerName = winnerName
        self.winnerScore = score
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight]
    }

    override var shouldAutorotate: Bool {
        return true
    }
  
    @IBAction func backToMenuTapped(_ sender: UIButton) {
        navigationController?.popToRootViewController(animated: true)
    }
    
}
