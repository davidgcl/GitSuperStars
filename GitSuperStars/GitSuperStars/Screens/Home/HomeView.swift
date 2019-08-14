import UIKit

class HomeView: UIView {
    
    // MARK: - Properites
    
    private var wasSetupConstraintsCalledOnce = false
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        setupView()
    }
    
    override func layoutSubviews() {
        if (wasSetupConstraintsCalledOnce == false) {
            wasSetupConstraintsCalledOnce = true
            setupConstraints()
        }
        super.layoutSubviews()
    }
    
    // MARK: - Helper Functions
    
    private func setupView() {
        backgroundColor = Color.colorGreyLighter.value
        
        addSubview(tableView)
        tableView.refreshControl = refreshControl
    }
    
    private func setupConstraints() {
        constraintTableView()
    }
    
    // MARK: - Instances
    
    let navigationItemLogo: UIImageView = {
        let iv = UIImageView(frame: CGRect( x: 0, y: 0, width: Size.navigation_logo_width.value, height: Size.navigation_logo_height.value))
        iv.contentMode = .scaleAspectFit
        iv.image = UIImage(named: "GitSuperStarsLogo")
        return iv
    }()
    
    let tableView: UITableView = {
        let tv = UITableView()
        tv.allowsSelection = false
        tv.separatorColor = Color.colorGreyLight.value
        tv.backgroundColor = Color.colorGreyLighter.value
        return tv
    }()
    
    let refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        rc.attributedTitle = NSAttributedString(string: LocalizedString.pull_to_refresh.value)
        rc.tintColor = Color.colorGreyLight.value
        return rc
    }()
    
    // MARK: - Constraints
    
    private func constraintTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: extSafeArea.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: extSafeArea.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: extSafeArea.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: extSafeArea.bottomAnchor).isActive = true
    }
}
