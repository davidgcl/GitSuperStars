import UIKit
import Kingfisher
import GSCore

class GitRepositoryItemTableViewCell: UITableViewCell {

    private var isConstraintsConfigured = false

    private var ownerImage: UIImageView = {
        let imageView: UIImageView = UIImageView(frame:
            CGRect( x: 0.0, y: 0.0,
                    width: Size.repositoryOwnerImageWidth.value,
                    height: Size.repositoryOwnerImageHeight.value))
        imageView.layer.cornerRadius = Size.repositoryOwnerImageBorderRadius.value
        imageView.layer.borderWidth = Size.repositoryOwnerImageBorderWidth.value
        imageView.layer.borderColor = Color.colorGrey.value.cgColor
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = Color.colorWhite.value
        imageView.contentMode = .scaleAspectFill
        imageView.image = Image.ownerImagePlaceholder.value
        return imageView
    }()

    private let repositoryTitleText: UILabel = {
        let text: UILabel = UILabel(frame: CGRect.zero)
        text.font = Font.robotoLight.value(size: Size.fontHeader1.value)
        text.textAlignment = .left
        text.numberOfLines = 1
        text.textColor = Color.colorPrimaryDarker.value
        text.backgroundColor = UIColor.clear
        return text
    }()

    private let repositoryStarsText: UILabel = {
        let text: UILabel = UILabel(frame: CGRect.zero)
        text.font = Font.robotoLight.value(size: Size.fontBody.value)
        text.textAlignment = .left
        text.numberOfLines = 1
        text.textColor = Color.colorGreyDark.value
        text.backgroundColor = UIColor.clear
        return text
    }()

    private let ownerNameText: UILabel = {
        let text: UILabel = UILabel(frame: CGRect.zero)
        text.font = Font.robotoMedium.value(size: Size.fontBody.value)
        text.textAlignment = .left
        text.numberOfLines = 1
        text.textColor = Color.colorGreyDark.value
        text.backgroundColor = UIColor.clear
        return text
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        setupConstraints()
        super.layoutSubviews()
    }

    func bind(gitRepositoryItem: GitRepositoryItem) {
        repositoryTitleText.text = gitRepositoryItem.name.uppercased()
        ownerNameText.text = gitRepositoryItem.owner.name ?? gitRepositoryItem.owner.login

        if gitRepositoryItem.stars > 1 {
            repositoryStarsText.text = "\(Int(gitRepositoryItem.stars)) \(LocalizedString.stars.value)"
        } else {
            repositoryStarsText.text = "\(Int(gitRepositoryItem.stars)) \(LocalizedString.stars.value)"
        }

        if let strUrl = gitRepositoryItem.owner.avatarUrl, let imageSize = ownerImage.image?.size {
            let url = URL(string: strUrl)
            let processor = DownsamplingImageProcessor(size: imageSize)
            ownerImage.kf.indicatorType = .activity
            ownerImage.kf.setImage(
                with: url,
                placeholder: Image.ownerImagePlaceholder.value,
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.25)),
                    .cacheOriginalImage
            ])
        }
    }

    private func setupView() {
        self.backgroundColor = Color.colorWhite.value
        self.addSubview(ownerImage)
        self.addSubview(repositoryTitleText)
        self.addSubview(repositoryStarsText)
        self.addSubview(ownerNameText)
    }

    private func setupConstraints() {
        if !isConstraintsConfigured {
            isConstraintsConfigured = true

            ownerImage.translatesAutoresizingMaskIntoConstraints = false
            ownerImage.leadingAnchor.constraint(equalTo: extSafeArea.leadingAnchor, constant: Size.repositoryViewCellMarginH.value).isActive = true
            ownerImage.topAnchor.constraint(equalTo: extSafeArea.topAnchor, constant: Size.repositoryViewCellMarginV.value).isActive = true
            ownerImage.bottomAnchor.constraint(equalTo: extSafeArea.bottomAnchor, constant: -Size.repositoryViewCellMarginV.value).isActive = true
            ownerImage.widthAnchor.constraint(equalTo: ownerImage.heightAnchor).isActive = true

            repositoryTitleText.translatesAutoresizingMaskIntoConstraints = false
            repositoryTitleText.leadingAnchor.constraint(equalTo: ownerImage.trailingAnchor, constant: Size.repositoryOwnerImageToTextMargin.value).isActive = true
            repositoryTitleText.trailingAnchor.constraint(equalTo: extSafeArea.trailingAnchor, constant: -Size.repositoryViewCellMarginH.value).isActive = true
            repositoryTitleText.topAnchor.constraint(equalTo: ownerImage.topAnchor).isActive = true

            repositoryStarsText.translatesAutoresizingMaskIntoConstraints = false
            repositoryStarsText.leadingAnchor.constraint(equalTo: ownerImage.trailingAnchor, constant: Size.repositoryOwnerImageToTextMargin.value).isActive = true
            repositoryStarsText.topAnchor.constraint(equalTo: repositoryTitleText.bottomAnchor, constant: Size.repositoryOwnerTitleToTextMargin.value).isActive = true

            ownerNameText.translatesAutoresizingMaskIntoConstraints = false
            ownerNameText.leadingAnchor.constraint(equalTo: ownerImage.trailingAnchor, constant: Size.repositoryOwnerImageToTextMargin.value).isActive = true
            ownerNameText.topAnchor.constraint(equalTo: repositoryStarsText.bottomAnchor, constant: Size.repositoryOwnerTextToTextMargin.value).isActive = true
        }
    }
}
