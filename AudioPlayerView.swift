//
// AudioPlayerView.swift
//
// Created by Speedyfriend67 on 08.07.24
//
 
import SwiftUI
import AVFoundation

struct AudioPlayerView: UIViewControllerRepresentable {
    let fileURL: URL

    class Coordinator: NSObject {
        var player: AVAudioPlayer?
        var timer: Timer?
        var isPlaying = false

        @objc func playPauseAudio() {
            guard let player = player else { return }
            if player.isPlaying {
                player.pause()
                stopTimer()
                isPlaying = false
            } else {
                player.play()
                startTimer()
                isPlaying = true
            }
        }

        func startTimer() {
            timer?.invalidate()
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                guard let self = self, let player = self.player else { return }
                let currentTime = player.currentTime
                let duration = player.duration
                if duration > 0 {
                    let progress = currentTime / duration
                    DispatchQueue.main.async {
                        // Update progress here
                        print("Progress: \(progress)")
                    }
                }
            }
        }

        func stopTimer() {
            timer?.invalidate()
            timer = nil
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let playButton = UIButton(type: .system)
        playButton.setTitle("Play/Pause", for: .normal)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(playButton)

        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor)
        ])

        playButton.addTarget(context.coordinator, action: #selector(Coordinator.playPauseAudio), for: .touchUpInside)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let player = try AVAudioPlayer(contentsOf: self.fileURL)
                player.prepareToPlay()
                DispatchQueue.main.async {
                    context.coordinator.player = player
                    if context.coordinator.isPlaying {
                        context.coordinator.startTimer()
                    }
                }
            } catch {
                print("Failed to initialize audio player: \(error.localizedDescription)")
            }
        }

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView(fileURL: URL(fileURLWithPath: "/path/to/audio.mp3"))
    }
}