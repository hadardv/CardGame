import Foundation

class Ticker {
    private var timer: Timer?
    private var interval: TimeInterval
    private var delay: TimeInterval
    private var callback: () -> Void

    init(interval: TimeInterval, delay: TimeInterval = 0.0, callback: @escaping () -> Void) {
        self.interval = interval
        self.delay = delay
        self.callback = callback
    }

    func start() {
        stop()

        if delay > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.callback()
                self.startTimer()
            }
        } else {
            callback()
            startTimer()
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            self.callback()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
