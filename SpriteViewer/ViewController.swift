//
//  ViewController.swift
//  SpriteViewer
//
//  Created by Ezhil Adhavan on 28/06/23.
//

import UIKit

class ViewController: UIViewController {
    var spriteCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private(set) var spriteModelArray: [SpriteModel] = []
    private(set) var spriteImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spriteCollectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(spriteCollectionView)
        NSLayoutConstraint.activate([
            spriteCollectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 80.0),
            spriteCollectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20.0),
            spriteCollectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20.0),
            spriteCollectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0.0)
        ])
        spriteCollectionView.register(SpriteCollectionViewCell.self, forCellWithReuseIdentifier: SpriteCollectionViewCell.identifier)
        spriteCollectionView.dataSource = self
        spriteCollectionView.delegate = self
        
        guard let spriteImageURL = Bundle.main.url(forResource: "sprite_s@2x", withExtension: "png") else { return }
        self.spriteImage = UIImage(contentsOfFile: spriteImageURL.path())
        
        guard let spriteJsonURL = Bundle.main.url(forResource: "sprite_s@2x", withExtension: "json") else { return }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: spriteJsonURL.path()))
            let sModel = try JSONDecoder().decode([String: PositionModel].self, from: data)
            let sortedArray = sModel.sorted { $0.key < $1.key }
            _ = sortedArray.map { name, positionModel in
                var spriteModel = SpriteModel()
                spriteModel.image = cropImage(rect: CGRect(x: positionModel.x ?? 0.0,
                                                           y: positionModel.y ?? 0.0,
                                                           width: positionModel.width ?? 0.0,
                                                           height: positionModel.height ?? 0.0))
                spriteModel.name = name
                spriteModelArray.append(spriteModel)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func cropImage(rect: CGRect) -> UIImage {
        if let sImage = spriteImage {
            let imageRef: CGImage = sImage.cgImage!.cropping(to: rect)!
            let cropped: UIImage = UIImage(cgImage:imageRef)
            return cropped
        }
        return UIImage()
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return spriteModelArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SpriteCollectionViewCell.identifier, for: indexPath) as! SpriteCollectionViewCell
        let sModel = self.spriteModelArray[indexPath.item]
        cell.imageView.image = sModel.image
        cell.label.text = sModel.name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 60, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}

struct SpriteModel {
    var name: String?
    var image: UIImage?
}

struct PositionModel: Codable {
    var width: CGFloat?
    var height: CGFloat?
    var x: CGFloat?
    var y: CGFloat?
}


class SpriteCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "SpriteCollectionViewCell"
    let imageView = UIImageView()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupImageView()
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupImageView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor, constant: 2.0),
            imageView.heightAnchor.constraint(equalToConstant: 30.0),
            imageView.widthAnchor.constraint(equalToConstant: 30.0),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    private func setupLabel() {
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 10.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
