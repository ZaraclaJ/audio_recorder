import Flutter
import UIKit
import AVFoundation

public class SwiftAudioRecorderPlugin: NSObject, FlutterPlugin, AVAudioRecorderDelegate {
    var isRecording = false
    var hasPermissions = false
    var mExtension = ""
    var mPath = ""
    var startTime: Date!
    var audioRecorder: AVAudioRecorder!

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "audio_recorder", binaryMessenger: registrar.messenger())
    let instance = SwiftAudioRecorderPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
        case "start":
            print("start")
            let dic = call.arguments as! [String : Any]
            mExtension = dic["extension"] as? String ?? ""
            mPath = dic["path"] as? String ?? ""
            startTime = Date()
            if mPath == "" {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                mPath = documentsPath + "/" + String(Int(startTime.timeIntervalSince1970)) + ".m4a"
                print("path: " + mPath)
            }
            let settings = [
                AVFormatIDKey: getOutputFormatFromString(mExtension),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
                try AVAudioSession.sharedInstance().setActive(true)

                audioRecorder = try AVAudioRecorder(url: URL(string: mPath)!, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
            } catch {
                print("fail")
                result(FlutterError(code: "", message: "Failed to record", details: nil))
            }
            isRecording = true
            result(nil)
        case "stop":
            print("stop")
            audioRecorder.stop()
            audioRecorder = nil
            let duration = Int(Date().timeIntervalSince(startTime as Date) * 1000)
            isRecording = false
            var recordingResult = [String : Any]()
            recordingResult["duration"] = duration
            recordingResult["path"] = mPath
            recordingResult["audioOutputFormat"] = mExtension
            result(recordingResult)
        case "isRecording":
            print("isRecording")
            result(isRecording)
        case "hasPermissions":
            print("hasPermissions")
            switch AVAudioSession.sharedInstance().recordPermission{
            case AVAudioSession.RecordPermission.granted:
                print("granted")
                hasPermissions = true
                break
            case AVAudioSession.RecordPermission.denied:
                print("denied")
                hasPermissions = false
                break
            case AVAudioSession.RecordPermission.undetermined:
                print("undetermined")
                AVAudioSession.sharedInstance().requestRecordPermission() { [unowned self] allowed in
                    DispatchQueue.main.async {
                        if allowed {
                            self.hasPermissions = true
                        } else {
                            self.hasPermissions = false
                        }
                    }
                }
                break
            default:
                break
            }
            result(hasPermissions)
        default:
            result(FlutterMethodNotImplemented)
        }
      }

        func getOutputFormatFromString(_ format : String) -> Int {
            switch format {
            case ".mp4", ".aac", ".m4a":
                return Int(kAudioFormatMPEG4AAC)
            default :
                return Int(kAudioFormatMPEG4AAC)
            }
        }
    }
