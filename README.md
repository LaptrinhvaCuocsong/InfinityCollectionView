# InfinityCollectionView

## Installation

InfinityCollectionView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'InfinityCollectionView'
```

## Usage

`InfinityCollectionView` can be instantiated either programatically or via Storyboards.

#### Programatically

Define ViewController

```swift
import UIKit
import InfinityCollectionView

class ViewController: UIViewController {
    @IBOutlet private var carouselView: CarouselView!
    
    private var reuseIdentifier = "CollectionViewCellIdentifier"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set CarouselViewDelegate for VC
        carouselView.delegate = self
        // Set default and focus size for cell
        carouselView.defaultSizeCell = CGSize(width: 80, height: 80)
        carouselView.focusSizeCell = CGSize(width: carouselView.defaultSizeCell.width * 1.2,
                                            height: carouselView.defaultSizeCell.height * 1.2)
        // Set padding horizontal
        carouselView.paddingHorizontal = 40
        // Set spacing horizontal
        carouselView.spacingHorizontal = 12
        // Set main axis aligment
        carouselView.mainAxisAlignment = .start
        // Enable focus center
        carouselView.enableFocusCenter = true
        // Enable infinity
        carouselView.enableInfinity = true
        // Register cell for UICollectionView
        carouselView.collectionView.register(UINib(nibName: "CollectionViewCell", bundle: .main),
                                             forCellWithReuseIdentifier: reuseIdentifier)
        // Set step
        carouselView.step = 1
    }


}

extension ViewController: CarouselViewDelegate {
    func numberOfItems(in view: CarouselView) -> Int {
        return 10
    }
    
    func carouselView(_ view: CarouselView, cellForItem item: Int) -> UICollectionViewCell {
        // Need return sub class of CarouselCell
        let cell = view.collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: IndexPath(item: item, section: 0)) as! CollectionViewCell
        cell.lbl.text = "Cell \(item)"
        return cell
    }
}
```

Define UICollectionViewCell

```swift
import UIKit
import InfinityCollectionView

class CollectionViewCell: CarouselCell {
    @IBOutlet var lbl: UILabel!
    
    override var animationTime: TimeInterval {
        return 0.3
    }
    
    override func resizeLayout(isFocus: Bool) {
        // Resize UI Component
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

```

## Author

hungnm, nguyenmanhhung131298@gmail.com

## License

InfinityCollectionView is available under the MIT license. See the LICENSE file for more info.
