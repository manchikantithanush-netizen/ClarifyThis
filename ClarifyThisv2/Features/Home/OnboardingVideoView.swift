import SwiftUI
import AVKit

struct OnboardingVideoView: View {
    let videoName: String // This will be "mainvideo"
    var onFinished: () -> Void
    
    @State private var player = AVPlayer()
    @State private var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Solid black background for cinematic reveal
            Color.black.ignoresSafeArea()
            
            // The Video Player
            VideoPlayer(player: player)
                .onAppear {
                    // Check for the .mp4 file in the root directory
                    if let url = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
                        player = AVPlayer(url: url)
                        player.play()
                        
                        // Set up the listener for the end of the video
                        NotificationCenter.default.addObserver(
                            forName: .AVPlayerItemDidPlayToEndTime,
                            object: player.currentItem,
                            queue: .main
                        ) { _ in
                            fadeOutAndFinish()
                        }
                    } else {
                        print("🎥 Onboarding Error: \(videoName).mp4 not found in the App Bundle.")
                        onFinished()
                    }
                }
            
            // Minimalist Skip Button
            VStack {
                HStack {
                    Spacer()
                    Button("Skip Intro") {
                        fadeOutAndFinish()
                    }
                    .buttonStyle(.bordered)
                    .tint(.white)
                    .padding(30)
                }
                Spacer()
            }
        }
        .opacity(opacity)
        .background(Color.black)
    }
    
    private func fadeOutAndFinish() {
        // Smooth 1.5 second fade out
        withAnimation(.easeOut(duration: 1.5)) {
            opacity = 0
        }
        
        // Final cleanup after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            player.pause()
            onFinished()
        }
    }
}
