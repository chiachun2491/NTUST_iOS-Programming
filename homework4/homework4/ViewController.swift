//
//  ViewController.swift
//  homework4
//
//  Created by Jeffery Ho on 2020/5/13.
//  Copyright © 2020 Jeffery Ho. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var videoLabel: UILabel!
    @IBOutlet weak var playpauseButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var repeat1Button: UIButton!
    @IBOutlet weak var videoView: UIView!
    
    enum PlayerMode {
        case Repeat
        case Repeat1
        case Shuffle
    }
    
    let player = AVPlayer()
    var playerLayer = AVPlayerLayer()
    var videos = [URL]()
    var counts = 0
    var playStatus:Bool = true
    var playerMode: PlayerMode = .Repeat
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player.actionAtItemEnd = .none
        player.volume = 0.5
        volumeSlider.value = player.volume
        volumeSlider.minimumValueImage = UIImage(systemName: "speaker.fill")
        volumeSlider.maximumValueImage = UIImage(systemName: "speaker.3.fill")
        
        playerLayer = AVPlayerLayer(player: player)
        videoView.layer.addSublayer(playerLayer)
        
        videos.append(Bundle.main.url(forResource: "好樂團 - 他們說我是沒有用的年輕人", withExtension: "mov")!)
        videos.append(Bundle.main.url(forResource: "好樂團 - 我們一樣可惜", withExtension: "mov")!)
        videos.append(Bundle.main.url(forResource: "好樂團 - 車站", withExtension: "mov")!)
        
        changePlayerItem(AVPlayerItem(url: videos[counts]))
        
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: .main, using: { (CMTime) in
            let currentTime = CMTimeGetSeconds(self.player.currentTime())
            self.progressSlider.value = Float(currentTime)
            self.progressLabel.text = self.secondFormat(currentTime)
        })
        player.play()
        
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidReachEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = videoView.bounds
    }
    
    @IBAction func playpause(_ sender: UIButton) {
        if playStatus {
            player.pause()
            sender.setImage(UIImage(systemName: "play.fill"), for: .normal)
        }
        else {
            player.play()
            sender.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        }
        playStatus = !playStatus
    }

    @IBAction func changeVideo(_ sender: UIButton) {
        if playerMode == .Shuffle {
            var newVideo:Int
            repeat {
                newVideo = Int.random(in: 0...videos.count-1)
            } while newVideo == counts
            counts = newVideo
        }
        else {
            switch sender.restorationIdentifier! {
            case "previous":
                counts -= 1
                if counts < 0 {
                    counts = videos.count - 1
                }
            case "next":
                counts += 1
                if counts >= videos.count {
                    counts = 0
                }
            default:
                break
            }
        }
        changePlayerItem(AVPlayerItem(url: videos[counts]))
        
        if playStatus {
            player.play()
        }
    }
    
    @IBAction func changeTime(_ sender: UIButton) {
        var time = progressSlider.value
        
        switch sender.restorationIdentifier! {
        case "backward":
            time -= 5
            if time < progressSlider.minimumValue {
                time = progressSlider.minimumValue
            }
        case "forward":
            time += 5
            if time > progressSlider.maximumValue {
                time = progressSlider.maximumValue
            }
        default:
            break
        }
        player.seek(to: CMTimeMake(value: Int64(time), timescale: 1))
    }

    @IBAction func changeVolume(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    @IBAction func changeCurrentTime(_ sender: UISlider) {
        let targetTime: CMTime = CMTimeMake(value: Int64(sender.value), timescale: 1)
        player.seek(to: targetTime)
    }
    
    @IBAction func changePlayerMode(_ sender: UIButton) {
        switch playerMode {
        case .Repeat:
            repeatButton.tintColor = UIColor.systemYellow
            repeatButton.backgroundColor = UIColor.systemBackground
        case .Shuffle:
            shuffleButton.tintColor = UIColor.systemYellow
            shuffleButton.backgroundColor = UIColor.systemBackground
        case .Repeat1:
            repeat1Button.tintColor = UIColor.systemYellow
            repeat1Button.backgroundColor = UIColor.systemBackground
        }
        switch sender.restorationIdentifier! {
        case "repeat":
            playerMode = .Repeat
        case "repeat1":
            playerMode = .Repeat1
        case "shuffle":
            playerMode = .Shuffle
        default:
            break
        }
         (sender.tintColor, sender.backgroundColor) = (sender.backgroundColor, sender.tintColor)
    }
    
    
    func secondFormat(_ time:Float64) -> String {
        let songLength = Int(time)
        let minutes = Int(songLength / 60)
        let seconds = Int(songLength % 60)
        var time = ""
        
        if minutes < 10 {
            time = "0\(minutes):"
        }
        else {
            time = "\(minutes)"
        }
        if seconds < 10 {
            time += "0\(seconds)"
        }
        else {
            time += "\(seconds)"
        }
        return time
    }
    
    func changePlayerItem(_ playerItem:AVPlayerItem) {
        let songLength = CMTimeGetSeconds(playerItem.asset.duration)
        progressSlider.minimumValue = 0
        progressSlider.maximumValue = Float(songLength)
        progressLabel.text = secondFormat(0)
        totalLabel.text = secondFormat(songLength)
        videoLabel.text = videos[counts].lastPathComponent
        
        player.replaceCurrentItem(with: playerItem)
    }
    
    @objc func playerItemDidReachEnd() {
        switch playerMode {
        case .Repeat:
            counts += 1
            if counts >= videos.count {
                counts = 0
            }
            changePlayerItem(AVPlayerItem(url: videos[counts]))
        case .Repeat1:
            player.seek(to: CMTimeMake(value: 0, timescale: 1))
        case .Shuffle:
            var newVideo:Int
            repeat {
                newVideo = Int.random(in: 0...videos.count-1)
            } while newVideo == counts
            counts = newVideo
            changePlayerItem(AVPlayerItem(url: videos[counts]))
        }
    }
}
