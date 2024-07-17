//
// AudioPlayerViewController.swift
//
// Created by Speedyfriend67 on 15.07.24
//
 
import UIKit
import AVFoundation

class AudioPlayerViewController: UIViewController {
    var audioPlayer: AVAudioPlayer?
    var audioURL: URL?
    var timer: Timer?

    let playPauseButton = UIButton(type: .system)
    let currentTimeLabel = UILabel()
    let durationLabel = UILabel()
    let progressSlider = UISlider()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupPlayer()
    }

    func setupUI() {
        playPauseButton.setTitle("Play", for: .normal)
        playPauseButton.addTarget(self, action: #selector(playPauseTapped), for: .touchUpInside)

        currentTimeLabel.text = "00:00"
        durationLabel.text = "00:00"
        
        progressSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)

        let stackView = UIStackView(arrangedSubviews: [playPauseButton, currentTimeLabel, progressSlider, durationLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    func setupPlayer() {
        guard let url = audioURL else { return }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self
            durationLabel.text = formatTime(audioPlayer?.duration ?? 0)
            progressSlider.maximumValue = Float(audioPlayer?.duration ?? 0)
        } catch {
            print("Failed to initialize player: \(error)")
        }
    }

    @objc func playPauseTapped() {
        guard let player = audioPlayer else { return }
        if player.isPlaying {
            player.pause()
            playPauseButton.setTitle("Play", for: .normal)
            timer?.invalidate()
        } else {
            player.play()
            playPauseButton.setTitle("Pause", for: .normal)
            startTimer()
        }
    }

    @objc func sliderValueChanged() {
        audioPlayer?.currentTime = TimeInterval(progressSlider.value)
    }

    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.updateUI()
        }
    }

    func updateUI() {
        currentTimeLabel.text = formatTime(audioPlayer?.currentTime ?? 0)
        progressSlider.value = Float(audioPlayer?.currentTime ?? 0)
    }

    func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension AudioPlayerViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playPauseButton.setTitle("Play", for: .normal)
        timer?.invalidate()
    }
}