//
//  ViewController.swift
//  SelfSizingCollectionViewTest
//
//  Created by Ric Santos on 9/1/2024.
//

import UIKit

class ViewController: UIViewController {
    var scrollingTabView: ScrollingTabView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let frame = CGRect(x: 16, y: 100, width: self.view.frame.size.width - 32, height: 62)
        self.scrollingTabView = ScrollingTabView(frame: frame)
        self.scrollingTabView.layer.borderColor = UIColor.systemMint.cgColor
        self.scrollingTabView.layer.borderWidth = 1
        self.view.addSubview(self.scrollingTabView)
        
        self.refreshData()
    }
    
    private func refreshData() {
        var items: [ScrollingTabView.Item] = []
        items.append(ScrollingTabView.Item(id: "001", title: "New York"))
        items.append(ScrollingTabView.Item(id: "002", title: "Chicago"))
        items.append(ScrollingTabView.Item(id: "003", title: "Los Angeles"))
        items.append(ScrollingTabView.Item(id: "004", title: "Toronto"))
        items.append(ScrollingTabView.Item(id: "005", title: "Miami"))
        items.append(ScrollingTabView.Item(id: "006", title: "Boston"))
        items.append(ScrollingTabView.Item(id: "007", title: "Golden State"))
        items.append(ScrollingTabView.Item(id: "008", title: "Houston"))
        items.append(ScrollingTabView.Item(id: "009", title: "Philadelphia"))
        items.append(ScrollingTabView.Item(id: "010", title: "Dallas"))
        items.append(ScrollingTabView.Item(id: "011", title: "Denver"))
        items.append(ScrollingTabView.Item(id: "012", title: "Atlanta"))
        items.append(ScrollingTabView.Item(id: "013", title: "Phoenix"))
        items.append(ScrollingTabView.Item(id: "014", title: "Milwaukee"))
        self.scrollingTabView.configure(for: items)
    }
}

protocol ScrollingTabViewDelegate: AnyObject {
    func scrollingTabView(view: ScrollingTabView, didSelect item: ScrollingTabView.Item)
}

class ScrollingTabView: UIView, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    weak var delegate: ScrollingTabViewDelegate?
    
    private var collectionView: UICollectionView!
        
    struct Item: Hashable {
        var id: String
        var title: String
    }
    private var items: [Item] = []

    typealias DataSource = UICollectionViewDiffableDataSource<Int, Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Item>
    var dataSource: DataSource!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
        
        let layout = UICollectionViewFlowLayout()
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.scrollDirection = .horizontal
        
        self.collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 30), collectionViewLayout: layout)
        self.collectionView.register(ScrollingTabCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.delegate = self
        self.collectionView.frame = CGRect(x: 0, y: 16, width: frame.width, height: 30)
        self.addSubview(self.collectionView)
        
        self.dataSource = DataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, item) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? ScrollingTabCell else { fatalError() }
            cell.configure(for: item)
            return cell
        })
        self.collectionView.dataSource = dataSource
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(for items: [Item]) {
        self.items = items
        self.refreshData(animated: false)
    }
    
    func refreshData(animated: Bool) {
        let items = self.items
        
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(items)
        self.dataSource.apply(snapshot, animatingDifferences: animated)
    }
    
    public var selectedItem: ScrollingTabView.Item? {
        get {
            guard let indexPath = self.collectionView.indexPathsForSelectedItems?.first else { return nil }
            return self.dataSource.itemIdentifier(for: indexPath)
        }
        set {
            if let newValue {
                guard let indexPath = self.dataSource.indexPath(for: newValue) else { return }
                self.collectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
            }
        }
    }
    
    public func setSelectedItem(item: ScrollingTabView.Item, animated: Bool) {
        guard let indexPath = self.dataSource.indexPath(for: item) else { return }
        self.collectionView.selectItem(at: indexPath, animated: animated, scrollPosition: .centeredHorizontally)
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = self.dataSource.itemIdentifier(for: indexPath) else { return }
        print("ScrollingTabView: Did select item \(item.id)")
        self.delegate?.scrollingTabView(view: self, didSelect: item)
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = CGFloat(30) //collectionView.height
        let width = UIView.layoutFittingCompressedSize.width
        let size = CGSize(width: width, height: height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
}

class ScrollingTabCell: UICollectionViewCell {
    let springView = UIView()
    private let label = UILabel()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.backgroundColor = UIColor.systemGreen
        self.contentView.addSubview(self.springView)
        self.springView.layer.cornerRadius = 8
        self.springView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            springView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            springView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            springView.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        self.label.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.springView.addSubview(self.label)
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: springView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: springView.trailingAnchor),
            label.centerYAnchor.constraint(equalTo: springView.centerYAnchor),
            label.heightAnchor.constraint(lessThanOrEqualTo: springView.heightAnchor)
        ])

        self.isSelected = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(for item: ScrollingTabView.Item) {
        self.label.text = item.title
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                self.springView.backgroundColor = UIColor.systemPink
                self.label.textColor = UIColor.white
            } else {
                self.springView.backgroundColor = UIColor.lightGray
                self.label.textColor = UIColor.darkGray
            }
        }
    }
}
