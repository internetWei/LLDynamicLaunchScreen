//
//  ViewController.swift
//  SwiftDemo
//
//  Created by LL on 2023/5/6.
//

import UIKit

import UniformTypeIdentifiers
import MobileCoreServices

class ViewController: UIViewController {

    var pickerController: UIImagePickerController?
    
    var backgroundImageView: UIImageView?
    
    var selectType: LLLaunchImageType?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.pickerController = UIImagePickerController()
        self.pickerController?.sourceType = .photoLibrary
        self.pickerController?.delegate = self
        if #available(iOS 15.0, *) {
            self.pickerController?.mediaTypes = [UTType.image.identifier]
        } else {
            self.pickerController?.mediaTypes = [String(kUTTypeImage)]
        }
        
        let isDarkMode = {
            var isDark = false
            if #available(iOS 12.0, *) {
                isDark = self.traitCollection.userInterfaceStyle == .dark
            }
            return isDark
        }()
        
        let isPortrait = CGRectGetWidth(self.view.bounds) < CGRectGetHeight(self.view.bounds)
        
        let backgroundImageView = UIImageView()
        self.backgroundImageView = backgroundImageView
        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.backgroundColor = .clear
        self.view.addSubview(backgroundImageView)
        
        if isDarkMode {
            if #available(iOS 13.0, *) {
                if isPortrait {
                    backgroundImageView.image = LLDynamicLaunchScreen.getLaunchImage(with: .verticalDark)
                } else {
                    backgroundImageView.image = LLDynamicLaunchScreen.getLaunchImage(with: .horizontalDark)?.byRotateRight90
                }
            }
        } else {
            if isPortrait {
                backgroundImageView.image = LLDynamicLaunchScreen.getLaunchImage(with: .verticalLight)
            } else {
                backgroundImageView.image = LLDynamicLaunchScreen.getLaunchImage(with: .horizontalLight)?.byRotateRight90
            }
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let contentView = UIView()
        contentView.backgroundColor = .clear
        self.view.addSubview(contentView)
        
        contentView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(30)
            make.centerY.equalToSuperview()
        }
        
        let spacing = 30.0
        
        let functionView1 = createView(title: "修改启动图", tip: "打开相册，选择你喜欢的图片并设置为启动图")
        functionView1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(function1Event)))
        contentView.addSubview(functionView1)
        
        functionView1.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
        
        
        let functionView2 = createView(title: "随机启动图", tip: "从网络上随机获取1张图片设置为启动图")
        functionView2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(function2Event)))
        contentView.addSubview(functionView2)
        
        functionView2.snp.makeConstraints { make in
            make.top.equalTo(functionView1.snp.bottom).offset(spacing)
            make.left.right.equalToSuperview()
            make.height.equalTo(functionView1)
        }
        
        
        let functionView3 = createView(title: "还原启动图", tip: "选择你要还原的启动图类型")
        functionView3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(function3Event)))
        contentView.addSubview(functionView3)
        
        functionView3.snp.makeConstraints { make in
            make.top.equalTo(functionView2.snp.bottom).offset(spacing)
            make.left.right.equalToSuperview()
            make.height.equalTo(functionView1)
        }
        
        
        let functionView4 = createView(title: "获取启动图", tip: "选择你要获取的启动图类型并设置成页面背景")
        functionView4.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(function4Event)))
        contentView.addSubview(functionView4)
        
        functionView4.snp.makeConstraints { make in
            make.top.equalTo(functionView3.snp.bottom).offset(spacing)
            make.left.right.equalToSuperview()
            make.height.equalTo(functionView1)
        }
        
        
        let functionView5 = createView(title: "获取系统启动图", tip: "选择你要获取的启动图类型并设置成页面背景")
        functionView5.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(function5Event)))
        contentView.addSubview(functionView5)
        
        functionView5.snp.makeConstraints { make in
            make.top.equalTo(functionView4.snp.bottom).offset(spacing)
            make.left.right.equalToSuperview()
            make.height.equalTo(functionView1)
            make.bottom.equalToSuperview()
        }
    }


    func createView(title: String, tip: String) -> UIView {
        let contentView = UIView()
        contentView.backgroundColor = UIColor(red: 229.0 / 255.0, green: 125.0 / 255.0, blue: 34.0 / 255.0, alpha: 0.85)
        contentView.layer.cornerRadius = 6.0
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .boldSystemFont(ofSize: 17.0)
        titleLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.87)
        contentView.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.left.equalToSuperview().offset(10)
        }
        
        let tipsLabel = UILabel()
        tipsLabel.text = tip
        tipsLabel.font = .systemFont(ofSize: 14)
        tipsLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        tipsLabel.sizeToFit()
        contentView.addSubview(tipsLabel)
        
        tipsLabel.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        return contentView
    }
    
    
    @objc func function1Event() {
        showAlertView(title: "请选择你要修改的启动图类型") { type in
            self.selectType = type
            self.present(self.pickerController!, animated: true)
        }
    }
    
    
    @objc func function2Event() {
        let width = Int(CGRectGetWidth(self.view.bounds))
        let height = Int(CGRectGetHeight(self.view.bounds))
        
        showAlertView(title: "请选择你要修改的启动图类型") { type in
            let url: String
            let isVertical: Bool
            switch type {
            case .verticalLight, .verticalDark:
                url = "https://picsum.photos/\(width)/\(height)"
                isVertical = true
            case .horizontalLight, .horizontalDark:
                url = "https://picsum.photos/\(height)/\(width)"
                isVertical = false
            @unknown default:
                fatalError()
            }
            
            self.getNetworkImageFrom(url: url) { image in
                LLDynamicLaunchScreen.replaceLaunch(image, type: type) { error in
                    DispatchQueue.main.async {
                        if error == nil {
                            if isVertical {
                                self.backgroundImageView?.image = image
                            } else {
                                self.backgroundImageView?.image = image.byRotateRight90
                            }
                            self.success()
                        } else {
                            self.view.showPrompt(fromText: "图片获取失败，请稍候再试")
                        }
                    }
                }
            }
        }
    }
    
    
    @objc func function3Event() {
        showAlertView(title: "请选择你要还原的启动图类型") { type in
            LLDynamicLaunchScreen.replaceLaunch(nil, type: type) { error in
                DispatchQueue.main.async {
                    if error == nil {
                        self.success()
                    } else {
                        self.view.showPrompt(fromText: "操作失败，请联系作者:internetwei@foxmail.com")
                    }
                }
            }
        }
    }
    
    
    @objc func function4Event() {
        showAlertView(title: "请选择你要获取的启动图类型") { type in
            var image = LLDynamicLaunchScreen.getLaunchImage(with: type)
            switch type {
            case .horizontalLight, .horizontalDark:
                image = image?.byRotateRight90
            default: break
            }
            
            self.backgroundImageView?.image = image
        }
    }
    
    
    @objc func function5Event() {
        showAlertView(title: "请选择你要获取的启动图类型") { type in
            var image = LLDynamicLaunchScreen.getSystemLaunchImage(with: type)
            switch type {
            case .horizontalLight, .horizontalDark:
                image = image?.byRotateRight90
            default: break
            }
            
            self.backgroundImageView?.image = image
        }
    }
    
    
    func getNetworkImageFrom(url: String, handler: @escaping ((UIImage) -> Void)) {
        let hud = self.view.showLoading()
        
        DispatchQueue.global().async {
            let data = try? Data(Data(contentsOf: URL(string: url)!))
            DispatchQueue.main.async {
                hud.hide(animated: true)
                var image: UIImage?
                if data != nil {
                    image = UIImage(data: data!, scale: UIScreen.main.scale)
                }
                
                if image == nil {
                    self.view.showPrompt(fromText: "图片获取失败，请稍候重试")
                } else {
                    handler(image!)
                }
            }
        }
    }
    
    
    func success() {
        var count = 3
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.isUserInteractionEnabled = false
        hud.mode = .text
        hud.label.text = "操作成功，APP将在\(count)秒后退出"
        hud.label.numberOfLines = 0
        hud.label.font = UIFont(name: "Helvetica", size: 15.0)
        hud.show(animated: true)
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            count -= 1
            if (count == 0) { exit(0) }
            
            hud.label.text = "操作成功，APP将在\(count)秒后退出"
        }
        
        RunLoop.current.add(timer, forMode: .common)
    }
    
    
    func showAlertView(title: String, handler: @escaping ((LLLaunchImageType) -> Void)) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "竖屏浅色启动图", style: .default) { _ in
            handler(.verticalLight)
        }
        
        let action2 = UIAlertAction(title: "横屏浅色启动图", style: .default) { _ in
            handler(.horizontalLight)
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        
        if #available(iOS 13.0, *) {
            let action3 = UIAlertAction(title: "竖屏深色启动图", style: .default) { _ in
                handler(.verticalDark)
            }
            
            let action4 = UIAlertAction(title: "横屏深色启动图", style: .default) { _ in
                handler(.horizontalDark)
            }
            
            alert.addAction(action3)
            alert.addAction(action4)
        }
        
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        self.present(alert, animated: true)
    }
}


extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        let image = info[.originalImage] as? UIImage
        
        if (image == nil) {
            self.view.showPrompt(fromText: "这张图片有问题，请换一张")
            return
        }
        
        LLDynamicLaunchScreen.replaceLaunch(image!, type: self.selectType!) { error in
            DispatchQueue.main.async {
                if error == nil {
                    self.success()
                } else {
                    self.view.showPrompt(fromText: "操作失败，请联系作者:internetwei@foxmail.com")
                }
            }
        }
    }
}

