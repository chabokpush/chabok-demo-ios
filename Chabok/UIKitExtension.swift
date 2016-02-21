//
//  UIKitExtension.swift
//  Chabok
//
//  Created by Farshad Ghafari on 11/13/1394 AP.
//  Copyright © 1394 Farshad Ghafari. All rights reserved.
//

import UIKit


@IBDesignable class CUButton: UIButton {
    @IBInspectable var bdColor: UIColor = UIColor.fromRGB(0x00325d) {
        didSet {
            setupView()
        }
    }
    private func setupView() {
        self.layer.borderColor = self.bdColor.CGColor
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 3
        
    }
}

@IBDesignable class CUTextField: UITextField {
    @IBInspectable var bdColor: UIColor = UIColor.fromRGB(0x525d7a) {
        didSet {
            setupView()
        }
    }
    private func setupView() {
        self.layer.borderColor = self.bdColor.CGColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 3
        
    }
}

extension UIColor {
    
    class func fromRGB(rgb:UInt32) -> UIColor {
        return UIColor(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
        
    }
    
    
    class func navigationBarTitleTextColor() -> UIColor {
        return UIColor.fromRGB(0xffffff)
    }
    
    class func navigationBarBackgroundColor() -> UIColor {
        return UIColor.fromRGB(0xEA4C89)
    }
    
    class func scrollMenuBackgroundColor() -> UIColor {
        return UIColor.fromRGB(0xFFFFFF)
    }
    
    class func viewBackgroundColor() -> UIColor {
        return UIColor.fromRGB(0x263238)
    }
    
    class func selectionIndicatorColor() -> UIColor {
        return UIColor.fromRGB(0x007fe8)
    }
    
    class func bottomMenuHairlineColor() -> UIColor {
        return UIColor.fromRGB(0x007fe8)
    }
    
    class func selectedMenuItemLabelColor() -> UIColor {
        return UIColor.fromRGB(0x07fe8)
    }
    
    class func unselectedMenuItemLabelColor() -> UIColor {
        return UIColor.fromRGB(0x007fe8)
    }
    
    class func cellLabelColor() -> UIColor {
        return UIColor.fromRGB(0x546E7A)
    }
}

extension UIFont {
    
    enum IRANSansFontFamily: String {
        case Light = "light"
        case Bold = "bold"
        case Medium = "medium"
    }
    
    class func setFamilyFontFromAppFont(family:IRANSansFontFamily = .Medium, size: CGFloat) -> UIFont {
        let familyName = "IRANSans(FaNum)"
        let fontNames = UIFont.fontNamesForFamilyName(familyName) as [String]
        var boldFont: UIFont!
    
        for fontName: NSString in fontNames
        {
            if fontName.rangeOfString(family.rawValue, options: .CaseInsensitiveSearch).location != NSNotFound {
                boldFont = UIFont(name: fontName as String, size: size)
                
            }
            
        }
        
        return boldFont
    }
}

extension String {
    
    var length: Int { return self.characters.count}
    subscript (i: Int) -> Character {return self[self.startIndex.advancedBy(i)]}
    subscript (i: Int) -> String    {return String(self[i] as Character)}
    
    func cellHeightForMessage(message:String) -> CGFloat {
        
        var height:CGFloat = 70
        
        let size = CGSizeMake(304,CGFloat.max)
        let  attributes = [NSFontAttributeName:UIFont.setFamilyFontFromAppFont(size: 14)]
        
        let text = message as NSString
        let rect = text.boundingRectWithSize(size, options:[.UsesLineFragmentOrigin, .UsesFontLeading, .TruncatesLastVisibleLine] , attributes: attributes, context:nil).size.height
        height += max(rect, 30)
        
        return height
    }
    
}


class ChabokTextField: UITextField {
    
    override func awakeFromNib() {
        
        self.font = UIFont.setFamilyFontFromAppFont(size: 15)
        let attributes = [
            NSForegroundColorAttributeName: UIColor.fromRGB(0xccdbe5),
            NSFontAttributeName : UIFont.setFamilyFontFromAppFont(size: 20)
        ]
        
        self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes:attributes)

    }
}


