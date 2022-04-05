//
//  CarouselView.swift
//  DemoInfinityCollectionView
//
//  Created by apple on 23/03/2022.
//

import Foundation
import UIKit

public protocol CarouselViewDelegate: AnyObject {
    func numberOfItems(in view: CarouselView) -> Int
    func carouselView(_ view: CarouselView, cellForItem item: Int) -> UICollectionViewCell
}

public class CarouselView: UIView {
    public weak var delegate: CarouselViewDelegate?

    public var enableInfinity = false {
        didSet {
            collectionViewLayout.enableInfinity = enableInfinity
        }
    }

    public var paddingHorizontal: CGFloat = 0 {
        didSet {
            collectionViewLayout.paddingHorizontal = paddingHorizontal
        }
    }

    public var spacingHorizontal: CGFloat = 0 {
        didSet {
            collectionViewLayout.spacingHorizontal = spacingHorizontal
        }
    }

    public var defaultSizeCell: CGSize = .zero {
        didSet {
            collectionViewLayout.defaultSizeCell = defaultSizeCell
        }
    }

    public var focusSizeCell: CGSize = .zero {
        didSet {
            collectionViewLayout.focusSizeCell = focusSizeCell
        }
    }

    public var mainAxisAlignment: CarouselLayout.MainAxisAlignment = .start {
        didSet {
            collectionViewLayout.mainAxisAlignment = mainAxisAlignment
        }
    }
    
    public var enableFocusCenter: Bool = true {
        didSet {
            collectionViewLayout.enableFocusCenter = enableFocusCenter
        }
    }
    
    public var step: Int? {
        didSet {
            collectionViewLayout.step = step
        }
    }
    
    public var collectionView: UICollectionView {
        return colView
    }
    
    private lazy var colView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: collectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private lazy var collectionViewLayout: CarouselLayout = {
        let layout = CarouselLayout()
        return layout
    }()
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        addSubview(colView)
        NSLayoutConstraint.activate([
            colView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
            colView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0),
            colView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0),
            colView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0),
        ])
        collectionViewLayout.enableInfinity = enableInfinity
        collectionViewLayout.paddingHorizontal = paddingHorizontal
        collectionViewLayout.spacingHorizontal = spacingHorizontal
        collectionViewLayout.defaultSizeCell = defaultSizeCell
        collectionViewLayout.focusSizeCell = focusSizeCell
        collectionViewLayout.mainAxisAlignment = mainAxisAlignment
    }
}

extension CarouselView: UICollectionViewDelegate, UICollectionViewDataSource {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (delegate?.numberOfItems(in: self) ?? 0) * (enableInfinity ? 3 : 1)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = indexPath.item % (delegate?.numberOfItems(in: self) ?? 1)
        return delegate?.carouselView(self, cellForItem: item) ?? UICollectionViewCell()
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard !decelerate else { return }
    }
}
