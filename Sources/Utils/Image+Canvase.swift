//
//  Image+Canvas.swift
//  MZRKit
//
//  Created by scchnxx on 2019/4/4.
//  Copyright © 2019 scchnxx. All rights reserved.
//

#if os(OSX)

extension NSBitmapImageRep {
    
    fileprivate convenience init?(size: CGSize) {
        self.init(bitmapDataPlanes: nil,
                  pixelsWide: Int(size.width), pixelsHigh: Int(size.height),
                  bitsPerSample: 8, samplesPerPixel: 4,
                  hasAlpha: true, isPlanar: false,
                  colorSpaceName: .calibratedRGB,
                  bytesPerRow: 0, bitsPerPixel: 0)
    }
    
}

extension NSImage {
    
    static func canvas(size: CGSize, _ block: (() -> Void)?) -> NSImage? {
        guard let imageRep = NSBitmapImageRep(size: size) else { return nil }
        
        let newImage = NSImage(size: size)
        
        newImage.addRepresentation(imageRep)
        newImage.lockFocus()
        block?()
        newImage.unlockFocus()
        return newImage
    }
    
}

#else

extension UIImage {
    
    static func canvas(size: CGSize, _ block: (() -> Void)?) -> UIImage? {
        let image: UIImage?
        
        UIGraphicsBeginImageContext(size)
        block?()
        image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

#endif
