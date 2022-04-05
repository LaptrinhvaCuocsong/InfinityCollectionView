//
//  CarouselCell.swift
//  DemoInfinityCollectionView
//
//  Created by apple on 28/03/2022.
//

import Foundation
import UIKit

open class CarouselCell: UICollectionViewCell {
    open var animationTime: TimeInterval {
        return 0.3
    }
    
    open func resizeLayout(isFocus: Bool) {
    }

    override open func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        guard let attr = layoutAttributes as? CarouselLayoutAttr else {
            return
        }
        let isFocus = attr.isFocus
        let defaultSizeCell = attr.defaultSizeCell
        let focusSizeCell = attr.focusSizeCell
        let origin = CGPoint(x: isFocus ? attr.frame.minX - (focusSizeCell.width - defaultSizeCell.width) / 2 : attr.frame.minX, y: isFocus ? attr.frame.minY - (focusSizeCell.height - defaultSizeCell.height) / 2 : attr.frame.minY)
        let size = isFocus ? focusSizeCell : defaultSizeCell
        UIView.animate(withDuration: animationTime) { [unowned self] in
            frame = CGRect(origin: origin, size: size)
            resizeLayout(isFocus: isFocus)
        }
    }
}
