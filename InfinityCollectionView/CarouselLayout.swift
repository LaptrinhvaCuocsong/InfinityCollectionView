//
//  CarouselLayout.swift
//  DemoInfinityCollectionView
//
//  Created by apple on 23/03/2022.
//

import Foundation
import UIKit

public extension CarouselLayout {
    enum MainAxisAlignment {
        case start
        case center
    }
}

public class CarouselLayoutAttr: UICollectionViewLayoutAttributes {
    public var isFocus: Bool = false
    public var defaultSizeCell: CGSize = CGSize(width: 1, height: 1)
    public var focusSizeCell: CGSize = CGSize(width: 1, height: 1)
    
    public override func isEqual(_ object: Any?) -> Bool {
        return false
    }

    override public func copy(with zone: NSZone? = nil) -> Any {
        let copy = super.copy(with: zone) as! CarouselLayoutAttr
        copy.isFocus = isFocus
        copy.defaultSizeCell = defaultSizeCell
        copy.focusSizeCell = focusSizeCell
        return copy
    }
}

public class CarouselLayout: UICollectionViewLayout {
    // MARK: - Public properties

    public var enableInfinity = false
    public var paddingHorizontal: CGFloat = 0
    public var spacingHorizontal: CGFloat = 0
    public var defaultSizeCell: CGSize = .zero
    public var focusSizeCell: CGSize = .zero
    public var mainAxisAlignment: MainAxisAlignment = .start
    public var enableFocusCenter: Bool = true
    public var step: Int?
    
    // MARK: - Private properties

    private var attrs: [CarouselLayoutAttr] = []
    private var contentWidth: CGFloat = 0
    private var isResetOffset = true
    // Focus item will reset when DidEndDecelerating
    private var focusItem = 0
    private var currentContentOffset: CGPoint = .zero
    private var infinityAttrs: [[CarouselLayoutAttr]] = []
    private var startOffset: CGPoint = .zero
    private var minOffsetX: CGFloat = 50000
    
    private var numberOfItem: Int {
        return collectionView?.numberOfItems(inSection: 0) ?? 0
    }

    override public func prepare() {
        super.prepare()
        // Reset
        attrs.removeAll()
        contentWidth = enableInfinity ? 100000 : 0
        startOffset = enableInfinity ? CGPoint(x: minOffsetX, y: 0) : .zero
        mainAxisAlignment = enableFocusCenter ? .center : mainAxisAlignment
        if isResetOffset {
            focusItem = enableInfinity ? numberOfItem / 3 : 0
            currentContentOffset = startOffset
            collectionView?.setContentOffset(startOffset, animated: false)
        }
        isResetOffset = true
        focusSizeCell = enableFocusCenter ? focusSizeCell : defaultSizeCell
        // Setup
        if enableInfinity {
            setupForInfinity()
        } else {
            let indexPaths = (0 ..< numberOfItem).map({ IndexPath(item: $0, section: 0) })
            let rst = setupNormal(startX: 0, beginItem: 0, numberOfItem: numberOfItem, indexPaths: indexPaths)
            attrs = rst.0
            contentWidth = rst.1
        }
    }

    override public class var layoutAttributesClass: AnyClass {
        return CarouselLayoutAttr.self
    }

    override public func layoutAttributesForElements(in: CGRect) -> [UICollectionViewLayoutAttributes] {
        return attrs
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return attrs[indexPath.item]
    }

    override public var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: collectionView?.frame.height ?? 0)
    }

    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }

    override public func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return .zero }
        if !enableFocusCenter && !enableInfinity {
            return proposedContentOffset
        }
        var proposedContentOffset = proposedContentOffset
        if enableInfinity {
            if let minX = attrs.first?.frame.minX, proposedContentOffset.x <= minX {
                proposedContentOffset.x = minX
            } else if var maxX = attrs.last?.frame.maxX {
                maxX = mainAxisAlignment == .start ? maxX + paddingHorizontal : (maxX + (collectionView.frame.width - focusSizeCell.width) / 2)
                if proposedContentOffset.x + collectionView.frame.width >= maxX {
                    proposedContentOffset.x = maxX - collectionView.frame.width
                }
            }
            if !enableFocusCenter {
                currentContentOffset = proposedContentOffset
                // Invalidate layout
                isResetOffset = false
                invalidateLayout()
                return proposedContentOffset
            }
        }
        var offset = proposedContentOffset
        if var idx = attrs.firstIndex(where: { abs($0.frame.midX - (offset.x + collectionView.frame.width / 2)) <= defaultSizeCell.width }) {
            if idx == focusItem {
                return currentContentOffset
            }
            if let step = step {
                idx = idx < focusItem ? max(0, focusItem - step) : min(numberOfItem - 1, focusItem + step)
            }
            if enableInfinity {
                if idx < focusItem {
                    offset.x = attrs[idx].frame.minX + focusSizeCell.width / 2 - collectionView.frame.width / 2
                } else {
                    let n = numberOfItem / 3
                    offset.x = attrs[idx].frame.minX - focusSizeCell.width / 2 + defaultSizeCell.width - collectionView.frame.width / 2 + ((focusItem + 1) % n == 0 ? (focusSizeCell.width - defaultSizeCell.width) / 2 : 0)
                }
            } else {
                var z = CGFloat(idx) * (defaultSizeCell.width + spacingHorizontal)
                z += idx > 0 ? (collectionView.frame.width - defaultSizeCell.width) / 2 : 0
                z += (focusSizeCell.width - collectionView.frame.width) / 2
                offset.x = z
            }
            focusItem = idx
            currentContentOffset = offset
            // Invalidate layout
            isResetOffset = false
            invalidateLayout()
        }
        return offset
    }

    // MARK: - Private methods
    
    @discardableResult
    private func setupNormal(startX: CGFloat, beginItem: Int, numberOfItem: Int, indexPaths: [IndexPath]) -> ([CarouselLayoutAttr], CGFloat) {
        var attrs: [CarouselLayoutAttr] = []
        guard let collectionView = collectionView, indexPaths.count == numberOfItem else {
            return ([], 0)
        }
        var x = beginItem > 0 ? startX : (mainAxisAlignment == .start ? startX + paddingHorizontal : (startX + (collectionView.frame.width / 2 - (beginItem == focusItem ? focusSizeCell.width : defaultSizeCell.width) / 2)))
        for i in 0 ..< numberOfItem {
            let isFocus = focusItem == (i + beginItem)
            let y = collectionView.frame.height / 2 - defaultSizeCell.height / 2
            let frame = CGRect(x: x + (isFocus ? (focusSizeCell.width - defaultSizeCell.width) / 2 : 0), y: y, width: defaultSizeCell.width, height: defaultSizeCell.height)
            let attr = CarouselLayoutAttr(forCellWith: indexPaths[i])
            attr.isFocus = isFocus && enableFocusCenter
            attr.defaultSizeCell = defaultSizeCell
            attr.focusSizeCell = focusSizeCell
            attr.frame = frame
            attrs.append(attr)
            x += (isFocus ? focusSizeCell.width : defaultSizeCell.width) + (i == numberOfItem - 1 ? (mainAxisAlignment == .start ? paddingHorizontal : (collectionView.frame.width / 2 - (focusItem == beginItem + numberOfItem - 1 ? focusSizeCell.width / 2 : defaultSizeCell.width / 2))) : spacingHorizontal)
        }
        return (attrs, x)
    }

    private func setupForInfinity() {
        guard let collectionView = collectionView else { return }
        if infinityAttrs.isEmpty {
            var x = currentContentOffset.x
            for i in 0 ..< 3 {
                let n = numberOfItem / 3
                let indexPaths = ((i * n) ..< (i * n + n)).map({ IndexPath(item: $0, section: 0) })
                let rst = setupNormal(startX: x, beginItem: i * n, numberOfItem: n, indexPaths: indexPaths)
                infinityAttrs.append(rst.0)
                x = rst.1
            }
            startOffset.x = ((infinityAttrs[1].first?.frame.minX ?? 0) - (focusSizeCell.width - defaultSizeCell.width) / 2) - (mainAxisAlignment == .start ? paddingHorizontal : (collectionView.frame.width / 2 - focusSizeCell.width / 2))
            currentContentOffset = startOffset
            collectionView.setContentOffset(startOffset, animated: false)
        } else {
            let minX = infinityAttrs[0].first?.frame.minX ?? -1
            var maxX = infinityAttrs[2].last?.frame.maxX ?? -1
            maxX = mainAxisAlignment == .start ? maxX + paddingHorizontal : (maxX + (collectionView.frame.width - focusSizeCell.width) / 2)
            
            var startX: CGFloat = 0
            var indexPaths: [[IndexPath]] = infinityAttrs.map({ $0.reduce([], { $0 + [$1.indexPath] }) })
            
            if currentContentOffset.x <= minX {
                let n = numberOfItem / 3
                focusItem = n
                let contentW = (mainAxisAlignment == .start ? paddingHorizontal : (collectionView.frame.width - defaultSizeCell.width) / 2) + CGFloat(n) * defaultSizeCell.width + CGFloat(n - 1) * spacingHorizontal
                startX = currentContentOffset.x - contentW
                indexPaths.insert(indexPaths.remove(at: 2), at: 0)
            } else if currentContentOffset.x + collectionView.frame.width >= maxX {
                focusItem = 2 * numberOfItem / 3 - 1
                startX = (infinityAttrs[1].first?.frame.minX ?? 0) - (mainAxisAlignment == .start ? paddingHorizontal : (collectionView.frame.width - defaultSizeCell.width) / 2)
                indexPaths.insert(indexPaths.remove(at: 0), at: 2)
            } else {
                startX = minOffsetX
            }
            
            infinityAttrs.removeAll()
            minOffsetX = startX
            var x = startX
            for i in 0 ..< 3 {
                let rst = setupNormal(startX: x, beginItem: i * (numberOfItem / 3), numberOfItem: numberOfItem / 3, indexPaths: indexPaths[i])
                infinityAttrs.append(rst.0)
                x = rst.1
            }
        }
        attrs = infinityAttrs.flatMap({ $0 })
    }
}
