//
//  ViewController.swift
//  waifu2x-mac-app
//
//  Created by 谢宜 on 2018/1/24.
//  Copyright © 2018年 谢宜. All rights reserved.
//

import Cocoa
import waifu2x_mac

class ViewController: NSViewController {
    
    @IBOutlet weak var outImg: NSImageView!
    @IBOutlet weak var processBtn: NSButton!
    @IBOutlet weak var status: NSTextField!
    @IBOutlet weak var pathInput: NSTextField!
    
    var urls: [URL]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.styleMask.remove(.resizable)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    @IBAction func processImage(_ sender: Any) {
        guard self.pathInput.stringValue.count > 0 else { return }
        let url = URL(fileURLWithPath: self.pathInput.stringValue)
        let fileMan = FileManager.default
        
        guard let tempUrls = try? fileMan.contentsOfDirectory(at: url,
                                                              includingPropertiesForKeys: nil,
                                                              options: FileManager.DirectoryEnumerationOptions.skipsHiddenFiles) else { return }
        self.urls = tempUrls
        
        let background = DispatchQueue(label: "background")
        
        processBtn.isEnabled = false
        for jj in 0..<self.urls!.count {
            let start = DispatchTime.now().uptimeNanoseconds
            background.async {
                let url = self.urls![jj]
                var img = NSImage(contentsOf: url)
                guard let outImage = Waifu2x.run(img, model: Model.anime_noise2_scale2x) else {
                    return
                }
                img = nil
                DispatchQueue.main.async {
                    self.outImg.image = outImage
                    debugPrint("jj = ", jj)
                    debugPrint("size = \(outImage.size)")
                    let end = DispatchTime.now().uptimeNanoseconds
                    self.status.stringValue = "Time elapsed: \(Float(end - start) / 1_000_000_000)"
                    let path = self.urls![jj].appendingPathExtension("_2x.png")
                    debugPrint("path = ", path.absoluteString)
                    debugPrint("write = ", outImage.pngWrite(to: path))
                    
                    if jj == (self.urls!.count - 1) {
                        self.processBtn.isEnabled = true
                    }
                }
            }
        }
    }
}

