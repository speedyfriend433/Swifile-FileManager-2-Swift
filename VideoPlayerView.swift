//
// VideoPlayerView.swift
//
// Created by Speedyfriend67 on 08.07.24
//
 
import SwiftUI
import AVKit
import AVFoundation

struct VideoPlayerView: UIViewControllerRepresentable {
    let fileURL: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        let player = AVPlayer(url: fileURL)
        playerViewController.player = player
        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        uiViewController.player?.replaceCurrentItem(with: AVPlayerItem(url: fileURL))
    }
}

struct VideoPlayerView_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayerView(fileURL: URL(fileURLWithPath: "/path/to/your/video.mp4"))
    }
}