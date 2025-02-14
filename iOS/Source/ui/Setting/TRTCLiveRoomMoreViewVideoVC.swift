//
//  TRTCMeetingMoreViewVideoVC.swift
//  TRTCScenesDemo
//
//  Created by J J on 2020/5/15.
//  Copyright © 2020 xcoderliu. All rights reserved.
//

import TXAppBasic
import UIKit

class TRTCLiveRoomBitrateTable: NSObject {
    var resolutionName: String = ""
    var resolution: Int = 0
    var defaultBitrate: Float = 0
    var minBitrate: Float = 0
    var maxBitrate: Float = 0
    var stepBitrate: Float = 0

    init(resolutionName: String, resolution: Int, defaultBitrate: Float, minBitrate: Float, maxBitrate: Float, stepBitrate: Float) {
        super.init()

        self.resolutionName = resolutionName
        self.resolution = resolution
        self.defaultBitrate = defaultBitrate
        self.minBitrate = minBitrate
        self.maxBitrate = maxBitrate
        self.stepBitrate = stepBitrate
    }
}

class TRTCLiveRoomMoreViewVideoVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let TAG_RESOLUTION = 100
    let TAG_FPS = 200

    var resolutionTextField = UITextField()
    var fpsTextField = UITextField()

    lazy var resolutionLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 30, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = .resolutionText
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()

    lazy var resolutionImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "live_back", in: LiveRoomBundle(), compatibleWith: nil))
        imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        imageView.frame = CGRect(x: ScreenWidth - 20 - 16, y: 30 + (25 - 16) / 2, width: 16, height: 16)
        return imageView
    }()

    lazy var frameLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 80, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = .framerateText
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()

    lazy var frameImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "live_back", in: LiveRoomBundle(), compatibleWith: nil))
        imageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        imageView.frame = CGRect(x: ScreenWidth - 20 - 16, y: 80 + (25 - 16) / 2, width: 16, height: 16)
        return imageView
    }()

    lazy var bitrateLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 130, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = .bitrateText
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()

    lazy var mirrorLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 20, y: 180, width: 100, height: 25))
        label.textAlignment = NSTextAlignment.left
        label.text = .localmirrorText
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()

    // 帧率
    let frameArray = ["15", "20"]

    // 创建码表, resolution 的值详见：TRTCVideoResolution
    let bitrateTable = [TRTCLiveRoomBitrateTable](
        arrayLiteral:
        TRTCLiveRoomBitrateTable(resolutionName: "180 * 320", resolution: TRTCVideoResolution._320_180.rawValue, defaultBitrate: 350, minBitrate: 80, maxBitrate: 350, stepBitrate: 10),
        TRTCLiveRoomBitrateTable(resolutionName: "270 * 480", resolution: TRTCVideoResolution._480_270.rawValue, defaultBitrate: 500, minBitrate: 200, maxBitrate: 1000, stepBitrate: 10),
        TRTCLiveRoomBitrateTable(resolutionName: "360 * 640", resolution: TRTCVideoResolution._640_360.rawValue, defaultBitrate: 600, minBitrate: 200, maxBitrate: 1000, stepBitrate: 10),
        TRTCLiveRoomBitrateTable(resolutionName: "540 * 960", resolution: TRTCVideoResolution._960_540.rawValue, defaultBitrate: 900, minBitrate: 400, maxBitrate: 1600, stepBitrate: 50),
        TRTCLiveRoomBitrateTable(resolutionName: "720 * 1280", resolution: TRTCVideoResolution._1280_720.rawValue, defaultBitrate: 1750, minBitrate: 500, maxBitrate: 2000, stepBitrate: 50)
    )
    var bitrateIndex = 4 // 默认为 360 * 640

    // 码率SliderView
    lazy var bitrateSlider: UISlider = {
        let slider = UISlider(frame: CGRect(x: UIScreen.main.bounds.size.width / 7.0 * 2.5 - 8, y: 126, width: UIScreen.main.bounds.size.width / 2.0 * 0.8, height: 30))

        let item = bitrateTable[bitrateIndex]
        slider.minimumValue = item.minBitrate / item.stepBitrate
        slider.maximumValue = item.maxBitrate / item.stepBitrate
        slider.value = item.defaultBitrate / item.stepBitrate
        slider.addTarget(self, action: #selector(bitrateSliderChanged), for: .valueChanged)
        slider.isContinuous = false

        return slider
    }()

    // 码率显示label
    lazy var bitrateShowLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: UIScreen.main.bounds.size.width / 7.0 * 5.5, y: 130, width: 100, height: 20))
        label.textAlignment = NSTextAlignment.left
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        label.text = String(Int(bitrateTable[bitrateIndex].defaultBitrate)) + "kbps"
        return label
    }()

    // 滑动条拖动函数
    @objc func bitrateSliderChanged(_ slider: UISlider) {
        updateBitrate(bitrate: Int(slider.value * bitrateTable[bitrateIndex].stepBitrate))
    }

    var frameIndex = 0

    @objc func resolutionDidClick() {
        guard let window = UIApplication.shared.windows.first else {
            return
        }
        let alert = TRTCLiveRoomResolutionAlert()
        alert.dataSource = bitrateTable
        alert.selectIndex = bitrateIndex
        window.addSubview(alert)
        alert.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        window.layoutIfNeeded()
        alert.show()
        alert.didSelectItem = { [weak self, weak alert] index in
            guard let `self` = self, let alert = alert else { return }
            self.updateResolution(index: index)
            alert.dismiss()
        }
    }

    @objc func frameDidClick() {
        guard let window = UIApplication.shared.windows.first else {
            return
        }

        let dataSource = [
            TRTCLiveRoomBitrateTable(resolutionName: "15", resolution: TRTCVideoResolution._320_180.rawValue, defaultBitrate: 350, minBitrate: 80, maxBitrate: 350, stepBitrate: 10),
            TRTCLiveRoomBitrateTable(resolutionName: "20", resolution: TRTCVideoResolution._480_270.rawValue, defaultBitrate: 500, minBitrate: 200, maxBitrate: 1000, stepBitrate: 10),
        ]

        let alert = TRTCLiveRoomResolutionAlert()
        alert.titleLabel.text = LiveRoomLocalize("Demo.TRTC.LiveRoom.framerate")
        alert.dataSource = dataSource
        alert.selectIndex = frameIndex
        window.addSubview(alert)
        alert.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        window.layoutIfNeeded()
        alert.show()
        alert.didSelectItem = { [weak self, weak alert] index in
            guard let `self` = self, let alert = alert else { return }
            self.updateFps(index: index)
            alert.dismiss()
        }
    }

    // 创建分辨率和帧率pickView以及textField
    @objc func setPickViewAndTextField() {
        // 分辨率：
        // 创建UITextField
        resolutionTextField = UITextField(frame: CGRect(x: UIScreen.main.bounds.size.width / 3.0, y: 30, width: UIScreen.main.bounds.size.width, height: 25))
        resolutionTextField.width = view.width
        resolutionTextField.backgroundColor = UIColor.red
        resolutionTextField.tintColor = .clear
        // 设置UITextField的tag值
        resolutionTextField.tag = TAG_RESOLUTION

        resolutionTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(resolutionDidClick)))

        // 设置textField预设内容
        resolutionTextField.text = bitrateTable[bitrateIndex].resolutionName

        resolutionTextField.backgroundColor = .clear
        resolutionTextField.textAlignment = .left

        resolutionTextField.textColor = .black

        view.addSubview(resolutionTextField)

        // 增加触控事件
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(tapG:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // 帧率：

        // 创建UITextField
        fpsTextField = UITextField(frame: CGRect(x: UIScreen.main.bounds.size.width / 3.0, y: 80, width: UIScreen.main.bounds.size.width, height: 25))

        fpsTextField.tintColor = .clear
        // 设置UITextField的tag值
        fpsTextField.tag = TAG_FPS

        // 将textField视图转换成pickerView
        fpsTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(frameDidClick)))

        // 设置textField预设内容
        fpsTextField.text = frameArray[0]

        fpsTextField.backgroundColor = .clear
        fpsTextField.textAlignment = .left

        fpsTextField.textColor = .black

        view.addSubview(fpsTextField)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(bitrateShowLabel)
        view.addSubview(resolutionLabel)
        view.addSubview(frameLabel)
        view.addSubview(bitrateLabel)
        view.addSubview(bitrateSlider)
        view.addSubview(resolutionImageView)
        view.addSubview(frameImageView)

        setPickViewAndTextField()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == TAG_RESOLUTION {
            return bitrateTable.count
        } else if pickerView.tag == TAG_FPS {
            return frameArray.count
        }
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == TAG_RESOLUTION {
            return bitrateTable[row].resolutionName
        } else if pickerView.tag == TAG_FPS {
            return frameArray[row]
        }
        return ""
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == TAG_RESOLUTION {
            print(String.resolutionSelectedText)
            updateResolution(index: row)

        } else if pickerView.tag == TAG_FPS {
            print(String.framerateSelectedText)
            updateFps(index: row)
        }
    }

    func updateResolution(index: Int) {
        bitrateIndex = index

        let item = bitrateTable[bitrateIndex]

        // 更新分辨率
        resolutionTextField.text = item.resolutionName
        let resolution = TRTCVideoResolution(rawValue: item.resolution)!
        TRTCLiveRoom.shareInstance().setVideo(resolution: resolution)

        // 设置码率进度条 && 更新码率
        bitrateSlider.minimumValue = item.minBitrate / item.stepBitrate
        bitrateSlider.maximumValue = item.maxBitrate / item.stepBitrate
        bitrateSlider.value = item.defaultBitrate / item.stepBitrate
        updateBitrate(bitrate: Int(item.defaultBitrate))
    }

    func updateFps(index: Int) {
        frameIndex = index
        fpsTextField.text = frameArray[index]
        TRTCLiveRoom.shareInstance().setVideo(fps: Int32(frameArray[index])!)
    }

    func updateBitrate(bitrate: Int) {
        bitrateShowLabel.text = String(bitrate) + "kbps"
        TRTCLiveRoom.shareInstance().setVideo(bitrate: Int32(bitrate))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // 点击空白处隐藏编辑状态
    @objc func hideKeyboard(tapG: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}

// MARK: - internationalization string

fileprivate extension String {
    static let resolutionText = LiveRoomLocalize("Demo.TRTC.LiveRoom.resolution")
    static let framerateText = LiveRoomLocalize("Demo.TRTC.LiveRoom.framerate")
    static let bitrateText = LiveRoomLocalize("Demo.TRTC.LiveRoom.bitrate")
    static let localmirrorText = LiveRoomLocalize("Demo.TRTC.LiveRoom.localmirror")
    static let resolutionSelectedText = LiveRoomLocalize("Demo.TRTC.LiveRoom.resolutionselected")
    static let framerateSelectedText = LiveRoomLocalize("Demo.TRTC.LiveRoom.framerateselected")
}
