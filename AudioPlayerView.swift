//
// AudioPlayerView.swift
//
// Created by Speedyfriend67 on 08.07.24
//
 
import SwiftUI
import AVFoundation

struct AudioPlayerView: UIViewControllerRepresentable {
    let fileURL: URL
    @Binding var progress: Double

    class Coordinator: NSObject, AVAudioPlayerDelegate {
        var player: AVAudioPlayer?
        var timer: Timer?
        var parent: AudioPlayerView

        init(parent: AudioPlayerView) {
            self.parent = parent
        }

        @objc func playPauseAudio() {
            guard let player = player else { return }
            if player.isPlaying {
                player.pause()
                timer?.invalidate()
            } else {
                player.play()
                startTimer()
            }
        }

        func startTimer() {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                guard let player = self.player else { return }
                let currentTime = player.currentTime
                let duration = player.duration
                self.parent.progress = currentTime / duration
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let playButton = UIButton(type: .system)
        playButton.setTitle("Play/Pause", for: .normal)
        playButton.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(playButton)

        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(progressView)

        NSLayoutConstraint.activate([
            playButton.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            playButton.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor),
            progressView.topAnchor.constraint(equalTo: playButton.bottomAnchor, constant: 20),
            progressView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: 20)
        ])

        playButton.addTarget(context.coordinator, action: #selector(Coordinator.playPauseAudio), for: .touchUpInside)

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let player = try AVAudioPlayer(contentsOf: self.fileURL)
                player.prepareToPlay()
                player.delegate = context.coordinator
                DispatchQueue.main.async {
                    context.coordinator.player = player
                }
            } catch {
                print("Failed to initialize audio player: \(error.localizedDescription)")
            }
        }

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        if let progressView = uiViewController.view.subviews.compactMap({ $0 as? UIProgressView }).first {
            progressView.progress = Float(progress)
        }
    }
}

struct AudioPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        AudioPlayerView(fileURL: URL(fileURLWithPath: "/path/to/audio.mp3"), progress: .constant(0.5))
    }
}