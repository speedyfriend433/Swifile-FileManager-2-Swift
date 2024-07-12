//
// AudioPlayerView.swift
//
// Created by Speedyfriend67 on 08.07.24
//
 
import SwiftUI
import AVFoundation

struct AudioPlayerView: UIViewControllerRepresentable {
    let fileURL: URL

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
            } else {
                player.play()
                startTimer()
            }
        }

        @objc func updateProgress() {
            guard let player = player else { return }
            parent.progress = player.currentTime / player.duration
        }

        func startTimer() {
            timer?.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(updateProgress), userInfo: nil, repeats: true)
        }

        func stopTimer() {
            timer?.invalidate()
            timer = nil
        }

        func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            stopTimer()
            parent.progress = 0
        }
    }

    @Binding var progress: Double

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
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
                player.delegate = context.coordinator
                player.prepareToPlay()
                DispatchQueue.main.async {
                    context.coordinator.player = player
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
        AudioPlayerView(fileURL: URL(fileURLWithPath: "/path/to/audio.mp3"), progress: .constant(0))
    }
}
