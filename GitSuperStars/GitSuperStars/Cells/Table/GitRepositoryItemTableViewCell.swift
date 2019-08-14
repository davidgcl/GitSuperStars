import UIKit
import Kingfisher

class GitRepositoryItemTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    private var isConstraintsConfigured = false
    
    // MARK: - Lifecycle
    
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
    
    // MARK: - Public functions
    
    func bind(gitRepositoryItem:GitRepositoryItem) {
        
        // Bind texts
        repositoryTitleText.text = gitRepositoryItem.name.uppercased()
        ownerNameText.text = gitRepositoryItem.owner.name ?? gitRepositoryItem.owner.login
        
        if (gitRepositoryItem.stars > 1) {
            repositoryStarsText.text = "\(Int(gitRepositoryItem.stars)) \(LocalizedString.stars.value)"
        } else {
            repositoryStarsText.text = "\(Int(gitRepositoryItem.stars)) \(LocalizedString.stars.value)"
        }
        
        // Bind image
        if let strUrl = gitRepositoryItem.owner.avatar_url, let imageSize = ownerImage.image?.size {
            let url = URL(string: strUrl)
            let processor = DownsamplingImageProcessor(size: imageSize)
            ownerImage.kf.indicatorType = .activity
            ownerImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "owner_image_placeholder"),
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.25)),
                    .cacheOriginalImage
            ])
        }
    }
    
    // MARK: - Helper functions
    
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
            
            constraintOwnerImage()
            constraintTitleText()
            constraintStarsText()
            constraintNameText()
        }
    }
    
    // MARK: - Instances
    
    private var ownerImage:UIImageView = {
        let imageView:UIImageView = UIImageView(frame: CGRect( x: 0.0, y: 0.0,
            width: Size.repository_owner_image_width.value,
            height: Size.repository_owner_image_height.value))
        imageView.layer.cornerRadius = Size.repository_owner_image_border_radius.value
        imageView.layer.borderWidth = Size.repository_owner_image_border_width.value
        imageView.layer.borderColor = Color.colorGrey.value.cgColor
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = Color.colorWhite.value
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "owner_image_placeholder")
        return imageView
    }()
    
    private let repositoryTitleText:UILabel = {
        let text:UILabel = UILabel(frame: CGRect.zero)
        text.font = Font.roboto_light.value(size: Size.font_header_1.value)
        text.textAlignment = .left
        text.numberOfLines = 1
        text.textColor = Color.colorPrimaryDarker.value
        text.backgroundColor = UIColor.clear
        return text
    }()
    
    private let repositoryStarsText:UILabel = {
        let text:UILabel = UILabel(frame: CGRect.zero)
        text.font = Font.roboto_light.value(size: Size.font_body.value)
        text.textAlignment = .left
        text.numberOfLines = 1
        text.textColor = Color.colorGreyDark.value
        text.backgroundColor = UIColor.clear
        return text
    }()
    
    private let ownerNameText:UILabel = {
        let text:UILabel = UILabel(frame: CGRect.zero)
        text.font = Font.roboto_medium.value(size: Size.font_body.value)
        text.textAlignment = .left
        text.numberOfLines = 1
        text.textColor = Color.colorGreyDark.value
        text.backgroundColor = UIColor.clear
        return text
    }()
    
    // MARK: - Constraints
    
    private func constraintOwnerImage() {
        ownerImage.translatesAutoresizingMaskIntoConstraints = false
        ownerImage.leadingAnchor.constraint(equalTo: extSafeArea.leadingAnchor, constant: Size.repository_view_cell_h_margin.value).isActive = true
        ownerImage.topAnchor.constraint(equalTo: extSafeArea.topAnchor, constant: Size.repository_view_cell_v_margin.value).isActive = true
        ownerImage.bottomAnchor.constraint(equalTo: extSafeArea.bottomAnchor, constant: -Size.repository_view_cell_v_margin.value).isActive = true
        ownerImage.widthAnchor.constraint(equalTo: ownerImage.heightAnchor).isActive = true
    }
    
    private func constraintTitleText() {
        repositoryTitleText.translatesAutoresizingMaskIntoConstraints = false
        repositoryTitleText.leadingAnchor.constraint(equalTo: ownerImage.trailingAnchor, constant: Size.repository_owner_image_to_text_margin.value).isActive = true
        repositoryTitleText.trailingAnchor.constraint(equalTo: extSafeArea.trailingAnchor, constant: -Size.repository_view_cell_h_margin.value).isActive = true
        repositoryTitleText.topAnchor.constraint(equalTo: ownerImage.topAnchor).isActive = true
    }
    
    private func constraintStarsText() {
        repositoryStarsText.translatesAutoresizingMaskIntoConstraints = false
        repositoryStarsText.leadingAnchor.constraint(equalTo: ownerImage.trailingAnchor, constant: Size.repository_owner_image_to_text_margin.value).isActive = true
        repositoryStarsText.topAnchor.constraint(equalTo: repositoryTitleText.bottomAnchor, constant: Size.repository_owner_title_to_text_margin.value).isActive = true
    }
    
    private func constraintNameText() {
        ownerNameText.translatesAutoresizingMaskIntoConstraints = false
        ownerNameText.leadingAnchor.constraint(equalTo: ownerImage.trailingAnchor, constant: Size.repository_owner_image_to_text_margin.value).isActive = true
        ownerNameText.topAnchor.constraint(equalTo: repositoryStarsText.bottomAnchor, constant: Size.repository_owner_text_to_text_margin.value).isActive = true
    }
}
