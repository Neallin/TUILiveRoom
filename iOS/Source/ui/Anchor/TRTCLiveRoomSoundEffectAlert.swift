//
//  TRTCLiveRoomSoundEffectAlert.swift
//  TXLiteAVDemo
//
//  Created by gg on 2021/3/30.
//  Copyright © 2021 Tencent. All rights reserved.
//

import Foundation
import TXAppBasic
//import AudioEffectSettingKit

public enum LiveRoomAudioEffectType {
    case audition // 试听
    case copyright // 版权
    case musicVolume // 音乐音量
    case vocalVolume // 人声音量
    case vocalRiseFall // 人声升降调
    case voiceChange // 变声
    case reverberation // 混响
}

// MARK: - BGM View
public class TRTCLiveRoomBgmAlert: TRTCLiveRoomAlertContentView {
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        return tableView
    }()
    
    lazy var backBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle(.backText, for: .normal)
        return btn
    }()
    
    var dataSource : [TRTCLiveRoomMusicModel] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    let effectViewModel : TRTCLiveRoomSoundEffectViewModel
    public init(frame: CGRect = .zero, effectViewModel: TRTCLiveRoomSoundEffectViewModel) {
        self.effectViewModel = effectViewModel
        super.init(frame: frame)
        titleLabel.text = .bgmText
        dataSource = effectViewModel.bgmDataSource
    }
    
    override func constructViewHierarchy() {
        super.constructViewHierarchy()
        contentView.addSubview(backBtn)
        contentView.addSubview(tableView)
    }
    
    override func activateConstraints() {
        super.activateConstraints()
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(52*3)
            make.bottom.equalToSuperview().offset(-kDeviceSafeBottomHeight)
        }
        backBtn.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleLabel)
        }
    }
    
    override func bindInteraction() {
        super.bindInteraction()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        backBtn.addTarget(self, action: #selector(backBtnClick), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func backBtnClick() {
        dismiss()
    }
}
extension TRTCLiveRoomBgmAlert : UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear
        let model = dataSource[indexPath.row]
        cell.textLabel?.text = model.musicName
        cell.textLabel?.textColor = .black
        return cell
    }
}
extension TRTCLiveRoomBgmAlert : UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]
        if let action = model.action {
            action(true, model)
        }
        dismiss()
    }
}

// MARK: - Sound Effect
@objcMembers
public class TRTCLiveRoomSoundEffectAlert: TRTCLiveRoomAlertContentView {
    
    public var dataSource : [LiveRoomAudioEffectType] = []
    
    public lazy var helpBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage.init(named: "helpUrl", in: LiveRoomBundle(), compatibleWith: nil), for: .normal)
        btn.isHidden = true
        return btn
    }()
    
    public lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        return tableView
    }()
    
    public var currentBgmAlert: TRTCLiveRoomBgmAlert?
    
    public let effectViewModel : TRTCLiveRoomSoundEffectViewModel
    
    public var totalHeight = 0
    
    public init(effectViewModel: TRTCLiveRoomSoundEffectViewModel) {
        self.effectViewModel = effectViewModel
        super.init(frame: .zero)
        
        titleLabel.text = .effectTitleText
        
        dataSource = [.copyright, .musicVolume, .vocalVolume, .vocalRiseFall, .voiceChange, .reverberation]
        totalHeight = 120 * 2 + 52 * 4
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    public override func constructViewHierarchy() {
        super.constructViewHierarchy()
        contentView.addSubview(helpBtn)
        contentView.addSubview(tableView)
    }
    
    public override func activateConstraints() {
        super.activateConstraints()
        helpBtn.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel.snp.trailing).offset(4)
            make.centerY.equalTo(titleLabel)
        }
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(totalHeight + 40)
        }
    }
    
    public override func bindInteraction() {
        super.bindInteraction()
        
        effectViewModel.viewResponder = self
        
        helpBtn.addTarget(self, action: #selector(helpBtnClick), for: .touchUpInside)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(TRTCLiveRoomSoundEffectCollectionCell.self, forCellReuseIdentifier: "TRTCLiveRoomSoundEffectCollectionCell")
        tableView.register(TRTCLiveRoomSoundEffectSwitchCell.self, forCellReuseIdentifier: "TRTCLiveRoomSoundEffectSwitchCell")
        tableView.register(TRTCLiveRoomSoundEffectDetailCell.self, forCellReuseIdentifier: "TRTCLiveRoomSoundEffectDetailCell")
        tableView.register(TRTCLiveRoomSoundEffectSliderCell.self, forCellReuseIdentifier: "TRTCLiveRoomSoundEffectSliderCell")
        tableView.register(TRTCLiveRoomSoundEffectPlayingCell.self, forCellReuseIdentifier: "TRTCLiveRoomSoundEffectPlayingCell")
    }
    
    @objc public func helpBtnClick() {
        
    }
}
extension TRTCLiveRoomSoundEffectAlert : UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = dataSource[indexPath.row]
        switch type {
        case .copyright:
            if let model = effectViewModel.currentPlayingModel {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TRTCLiveRoomSoundEffectPlayingCell", for: indexPath)
                if let scell = cell as? TRTCLiveRoomSoundEffectPlayingCell {
                    scell.titleLabel.text = model.musicName
                    scell.timeLabel.text = "\(string2Display(second: model.currentTime))/\(string2Display(second: model.totalTime))"
                    scell.playBtn.isSelected = effectViewModel.isPlaying
                    scell.playBtnDidClick = { [weak self] in
                        guard let `self` = self else { return }
                        if self.effectViewModel.isPlaying {
                            self.effectViewModel.pausePlay()
                        }
                        else if self.effectViewModel.isPlayingComplete {
                            self.effectViewModel.playMusic(model)
                        }
                        else {
                            self.effectViewModel.resumePlay()
                        }
                        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                    }
                }
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "TRTCLiveRoomSoundEffectDetailCell", for: indexPath)
                if let scell = cell as? TRTCLiveRoomSoundEffectDetailCell {
                    scell.titleLabel.text = .copyrightText
                    scell.descLabel.text = .selectMusicText
                }
                return cell
            }
        case .musicVolume:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRTCLiveRoomSoundEffectSliderCell", for: indexPath)
            if let scell = cell as? TRTCLiveRoomSoundEffectSliderCell {
                scell.titleLabel.text = .musicVolumeText
                scell.set(100, 0, Float(effectViewModel.currentMusicVolum))
                scell.valueChanged = { [weak self] (current) in
                    guard let `self` = self else { return }
                    self.effectViewModel.setVolume(music: Int(current))
                }
            }
            return cell
        case .vocalVolume:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRTCLiveRoomSoundEffectSliderCell", for: indexPath)
            if let scell = cell as? TRTCLiveRoomSoundEffectSliderCell {
                scell.titleLabel.text = .vocalVolumeText
                scell.set(100, 0, Float(effectViewModel.currentVocalVolume))
                scell.valueChanged = { [weak self] (current) in
                    guard let `self` = self else { return }
                    self.effectViewModel.setVolume(person: Int(current))
                }
            }
            return cell
        case .vocalRiseFall:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRTCLiveRoomSoundEffectSliderCell", for: indexPath)
            if let scell = cell as? TRTCLiveRoomSoundEffectSliderCell {
                scell.titleLabel.text = .vocalRiseFallText
                scell.set(1, -1, Float(effectViewModel.currentPitchVolum))
                scell.valueChanged = { [weak self] (current) in
                    guard let `self` = self else { return }
                    self.effectViewModel.setPitch(person: Double(current))
                }
            }
            return cell
        case .voiceChange:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRTCLiveRoomSoundEffectCollectionCell", for: indexPath)
            if let scell = cell as? TRTCLiveRoomSoundEffectCollectionCell {
                scell.dataSource = effectViewModel.voiceChangeDataSource
                scell.titleLabel.text = .voiceChangeText
            }
            return cell
        case .reverberation:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TRTCLiveRoomSoundEffectCollectionCell", for: indexPath)
            if let scell = cell as? TRTCLiveRoomSoundEffectCollectionCell {
                scell.dataSource = effectViewModel.reverbDataSource
                scell.titleLabel.text = .reverbText
            }
            return cell
        default:
            return UITableViewCell(frame: .zero)
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let type = dataSource[indexPath.row]
        if type == .voiceChange || type == .reverberation {
            return 120
        }
        else {
            return 52
        }
    }
    
    public func string2Display(second: Int) -> String {
        let min = second / 60
        let sec = second % 60
        return "\(string(fromSecond: min)):\(string(fromSecond: sec))"
    }
    
    public func string(fromSecond: Int) -> String {
        if fromSecond > 9 {
            return String(fromSecond)
        }
        else {
            return "0\(fromSecond)"
        }
    }
}
extension TRTCLiveRoomSoundEffectAlert : UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let type = dataSource[indexPath.row]
        if type == .copyright {
            guard let superview = superview else {
                return
            }
            let alert = TRTCLiveRoomBgmAlert(effectViewModel: effectViewModel)
            superview.addSubview(alert)
            alert.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
            alert.willDismiss = { [weak self] in
                guard let `self` = self else { return }
                UIView.animate(withDuration: 0.3) {
                    self.alpha = 1
                }
                self.currentBgmAlert = nil
            }
            alert.layoutIfNeeded()
            alert.show()
            UIView.animate(withDuration: 0.3) {
                self.alpha = 0
            }
            currentBgmAlert = alert
        }
    }
}
extension TRTCLiveRoomSoundEffectAlert : TRTCLiveRoomSoundEffectViewResponder {
    public func bgmOnPrepareToPlay() {
        let rows = [IndexPath(row: 0, section: 0)]
        tableView.reloadRows(at: rows, with: .none)
    }
    
    public func bgmOnPlaying(current: Int, total: Int) {
        if currentBgmAlert == nil {
            if let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 0)) {
                if let scell = cell as? TRTCLiveRoomSoundEffectPlayingCell {
                    if let model = effectViewModel.currentPlayingModel {
                        scell.timeLabel.text = "\(string2Display(second: model.currentTime))/\(string2Display(second: model.totalTime))"
                    }
                }
            }
        }
    }
    
    public func bgmOnCompletePlaying() {
        let rows = [IndexPath(row: 0, section: 0)]
        tableView.reloadRows(at: rows, with: .none)
    }
}

// MARK: - Cells
@objcMembers
public class TRTCLiveRoomSoundEffectBaseCell: UITableViewCell {
    public lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Medium", size: 16)
        label.textColor = UIColor(hex: "666666")
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .white
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady = false
    
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    public func constructViewHierarchy() {
        contentView.addSubview(titleLabel)
    }
    
    public func activateConstraints() {
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(12)
        }
    }
    
    public func bindInteraction() {
        
    }
}

@objcMembers
public class TRTCLiveRoomSoundEffectSwitchCell: TRTCLiveRoomSoundEffectBaseCell {
    
    public var valueChanged: ((_ isOn: Bool)->())?
    
    public lazy var descLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 12)
        label.textColor = UIColor(hex: "999999")
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        return label
    }()
    
    public lazy var onOff: UISwitch = {
        let onoff = UISwitch(frame: .zero)
        onoff.onTintColor = UIColor(hex: "006EFF")
        return onoff
    }()
    
    public override func constructViewHierarchy() {
        super.constructViewHierarchy()
        contentView.addSubview(descLabel)
        contentView.addSubview(onOff)
    }
    
    public override func activateConstraints() {
        super.activateConstraints()
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-12)
        }
        descLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel.snp.trailing).offset(8)
            make.centerY.equalTo(titleLabel)
            make.trailing.lessThanOrEqualTo(onOff.snp.leading)
        }
        onOff.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleLabel)
        }
    }
    
    public override func bindInteraction() {
        super.bindInteraction()
        onOff.addTarget(self, action: #selector(switchValueChanged(sender:)), for: .valueChanged)
    }
    
    @objc public func switchValueChanged(sender: UISwitch) {
        if let action = valueChanged {
            action(sender.isOn)
        }
    }
}

@objcMembers
public class TRTCLiveRoomSoundEffectSlider: UISlider {
    public override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        let edge = CGFloat(4)
        var rect = rect
        rect.origin.x -= edge
        rect.size.width += 2 * edge
        return super.thumbRect(forBounds: bounds, trackRect: rect, value: value).insetBy(dx: edge, dy: edge)
    }
}

@objcMembers
public class TRTCLiveRoomSoundEffectSliderCell: TRTCLiveRoomSoundEffectBaseCell {
    
    public var valueChanged : ((_ value: Float)->())?
    
    public var maxValue : Float = 0 {
        didSet {
            slider.maximumValue = maxValue
        }
    }
    public var minValue : Float = 0 {
        didSet {
            slider.minimumValue = minValue
        }
    }
    public var currentValue : Float = 0 {
        didSet {
            slider.value = currentValue
        }
    }
    
    public func set(_ max: Float, _ min: Float, _ current: Float) {
        maxValue = max
        minValue = min
        currentValue = current
        updateSlider()
    }
    
    lazy var slider: TRTCLiveRoomSoundEffectSlider = {
        let slider = TRTCLiveRoomSoundEffectSlider(frame: .zero)
        slider.setThumbImage(UIImage.init(named: "Slider", in: LiveRoomBundle(), compatibleWith: nil), for: .normal)
        slider.minimumTrackTintColor = UIColor(hex: "006EFF")
        slider.maximumTrackTintColor = UIColor(hex: "F4F5F9")
        return slider
    }()
    
    lazy var valueLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Medium", size: 16)
        label.textColor = UIColor(hex: "333333")
        return label
    }()
    
    public override func constructViewHierarchy() {
        super.constructViewHierarchy()
        contentView.addSubview(slider)
        contentView.addSubview(valueLabel)
    }
    
    public  override func activateConstraints() {
        super.activateConstraints()
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-12)
            make.trailing.lessThanOrEqualTo(slider.snp.leading).offset(-8)
        }
        valueLabel.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleLabel)
            make.width.equalTo(convertPixel(w: 50))
        }
        slider.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(convertPixel(w: 110))
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(valueLabel.snp.leading).offset(-10)
        }
    }
    public override func bindInteraction() {
        super.bindInteraction()
        slider.addTarget(self, action: #selector(sliderValueChanged(sender:)), for: .valueChanged)
    }
    
    @objc public func sliderValueChanged(sender: UISlider) {
        updateSlider()
        if let action = valueChanged {
            action(slider.value)
        }
    }
    
    private func updateSlider() {
        if slider.maximumValue == 1 && slider.minimumValue == -1 {
            valueLabel.text = String(format: "%.2f", slider.value)
        }
        else {
            valueLabel.text = String(Int(slider.value))
        }
    }
}

@objcMembers
public class TRTCLiveRoomSoundEffectPlayingCell: TRTCLiveRoomSoundEffectBaseCell {
    public lazy var timeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        return label
    }()
    
    public lazy var playBtn: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setImage(UIImage.init(named: "bgm_play", in: LiveRoomBundle(), compatibleWith: nil), for: .normal)
        btn.setImage(UIImage.init(named: "bgm_pause", in: LiveRoomBundle(), compatibleWith: nil), for: .selected)
        return btn
    }()
    
    public var playBtnDidClick: (()->())?
    
    public override func constructViewHierarchy() {
        super.constructViewHierarchy()
        contentView.addSubview(playBtn)
        contentView.addSubview(timeLabel)
    }
    
    public override func activateConstraints() {
        super.activateConstraints()
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-12)
        }
        playBtn.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleLabel)
        }
        timeLabel.snp.makeConstraints { (make) in
            make.trailing.equalTo(playBtn.snp.leading).offset(-10)
            make.centerY.equalTo(titleLabel)
        }
    }
    
    public override func bindInteraction() {
        super.bindInteraction()
        playBtn.addTarget(self, action: #selector(playBtnClick), for: .touchUpInside)
    }
    
    @objc public func playBtnClick() {
        if let action = playBtnDidClick {
            action()
        }
    }
}

@objcMembers
public class TRTCLiveRoomSoundEffectDetailCell: TRTCLiveRoomSoundEffectBaseCell {
    public lazy var arrowImageView: UIImageView = {
        let imageV = UIImageView(image: UIImage.init(named: "detail", in: LiveRoomBundle(), compatibleWith: nil))
        return imageV
    }()
    
    public lazy var descLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 16)
        label.textColor = UIColor(hex: "999999")
        return label
    }()
    
    public override func constructViewHierarchy() {
        super.constructViewHierarchy()
        contentView.addSubview(descLabel)
        contentView.addSubview(arrowImageView)
    }
    
    public override func activateConstraints() {
        super.activateConstraints()
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-12)
        }
        arrowImageView.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(titleLabel)
        }
        descLabel.snp.makeConstraints { (make) in
            make.leading.greaterThanOrEqualTo(titleLabel.snp.trailing).offset(8)
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(arrowImageView.snp.leading).offset(-10)
        }
    }
    
    public override func bindInteraction() {
        super.bindInteraction()
        
    }
}

@objcMembers
public class TRTCLiveRoomSoundEffectCollectionCell: TRTCLiveRoomSoundEffectBaseCell {
    
    public var currentSelect: Int = 0
    
    public var dataSource : [TRTCLiveRoomAudioEffectCellModel] = [] {
        didSet {
            for (i, model) in dataSource.enumerated() {
                if model.selected {
                    currentSelect = i
                    break
                }
            }
            collectionView.reloadData()
            collectionView.layoutIfNeeded()
            collectionView.selectItem(at: IndexPath(item: currentSelect, section: 0), animated: true, scrollPosition: .left)
        }
    }
    
    public override func constructViewHierarchy() {
        super.constructViewHierarchy()
        contentView.addSubview(collectionView)
    }
    public override func activateConstraints() {
        super.activateConstraints()
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(75)
        }
    }
    public override func bindInteraction() {
        super.bindInteraction()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(TRTCLiveRoomSoundEffectCellForCollectionCell.self, forCellWithReuseIdentifier: "TRTCLiveRoomSoundEffectCellForCollectionCell")
    }
    
    public lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 75)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        return collectionView
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension TRTCLiveRoomSoundEffectCollectionCell : UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TRTCLiveRoomSoundEffectCellForCollectionCell", for: indexPath)
        if let scell = cell as? TRTCLiveRoomSoundEffectCellForCollectionCell {
            let model = dataSource[indexPath.item]
            scell.model = model
        }
        return cell
    }
}
extension TRTCLiveRoomSoundEffectCollectionCell : UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let model = dataSource[indexPath.item]
        if let action = model.action {
            action()
        }
    }
}

@objcMembers
public class TRTCLiveRoomSoundEffectCellForCollectionCell: UICollectionViewCell {
    
    public var model : TRTCLiveRoomAudioEffectCellModel? {
        didSet {
            guard let model = model else {
                return
            }
            headImageView.image = model.icon
            headImageView.highlightedImage = model.selectIcon
            titleLabel.text = model.title
            isSelected = model.selected
        }
    }
    
    public override var isSelected: Bool {
        didSet {
            guard let model = model else {
                return
            }
            model.selected = isSelected
            headImageView.isHighlighted = isSelected
            titleLabel.isHighlighted = isSelected
        }
    }
    
    public lazy var headImageView: UIImageView = {
        let imageV = UIImageView(frame: .zero)
        imageV.contentMode = .scaleAspectFill
        imageV.clipsToBounds = true
        return imageV
    }()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = UIFont(name: "PingFangSC-Regular", size: 12)
        label.textColor = UIColor(hex: "666666")
        label.highlightedTextColor = UIColor(hex: "006EFF")
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        
        contentView.addSubview(headImageView)
        contentView.addSubview(titleLabel)
        headImageView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(headImageView.snp.width)
        }
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(headImageView.snp.bottom).offset(4)
            make.leading.trailing.centerX.equalToSuperview()
        }
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        headImageView.layer.cornerRadius = headImageView.frame.height * 0.5
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Base View
public class TRTCLiveRoomAlertContentView: UIView {
    public lazy var bgView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .black
        view.alpha = 0.6
        return view
    }()
    public lazy var contentView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .white
        return view
    }()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .black
        label.font = UIFont(name: "PingFangSC-Medium", size: 24)
        return label
    }()
    
    @objc public var willDismiss: (()->())?
    @objc public var didDismiss: (()->())?
    
    public override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        contentView.transform = CGAffineTransform(translationX: 0, y: ScreenHeight)
        alpha = 0
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var isViewReady = false
    public override func didMoveToWindow() {
        super.didMoveToWindow()
        guard !isViewReady else {
            return
        }
        isViewReady = true
        constructViewHierarchy()
        activateConstraints()
        bindInteraction()
    }
    
    @objc public func show() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
            self.contentView.transform = .identity
        }
    }
    
    @objc public func dismiss() {
        if let action = willDismiss {
            action()
        }
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
            self.contentView.transform = CGAffineTransform(translationX: 0, y: ScreenHeight)
        } completion: { (finish) in
            if let action = self.didDismiss {
                action()
            }
            self.removeFromSuperview()
        }
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let point = touches.first?.location(in: self) else {
            return
        }
        if !contentView.frame.contains(point) {
            dismiss()
        }
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        contentView.roundedRect(rect: contentView.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 12, height: 12))
    }
    
    func constructViewHierarchy() {
        addSubview(bgView)
        addSubview(contentView)
        contentView.addSubview(titleLabel)
    }
    func activateConstraints() {
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        contentView.snp.makeConstraints { (make) in
            make.leading.trailing.bottom.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { (make) in
            make.leading.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(32)
        }
    }
    func bindInteraction() {
        
    }
}

/// MARK: - internationalization string
fileprivate extension String {
    static let effectTitleText = LiveRoomLocalize("ASKit.MainMenu.Title")
    static let voiceChangeText = LiveRoomLocalize("ASKit.MainMenu.VoiceChangeTitle")
    static let reverbText = LiveRoomLocalize("ASKit.MainMenu.Reverberation")
    static let auditionText = LiveRoomLocalize("ASKit.MusicSelectMenu.Title")
    static let bringHeadphoneText = LiveRoomLocalize("Demo.TRTC.VoiceRoom.useearphones")
    static let copyrightText = LiveRoomLocalize("Demo.TRTC.VoiceRoom.copyrights")
    static let selectMusicText = LiveRoomLocalize("ASKit.MainMenu.SelectMusic")
    static let musicVolumeText = LiveRoomLocalize("ASKit.MainMenu.MusicVolum")
    static let vocalVolumeText = LiveRoomLocalize("ASKit.MainMenu.PersonVolum")
    static let vocalRiseFallText = LiveRoomLocalize("ASKit.MainMenu.PersonPitch")
    static let backText = LiveRoomLocalize("Demo.TRTC.VoiceRoom.back")
    static let bgmText = LiveRoomLocalize("ASKit.MainMenu.BGM")
}
