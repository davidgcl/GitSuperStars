import UIKit

class LoadingViewCell: UITableViewCell {
    
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
    
    func startAnimating() {
        spinner.startAnimating()
    }
    
    // MARK: - Helper functions
    
    private func setupView() {
        self.backgroundColor = Color.colorGreyLighter.value
        self.addSubview(spinner)
    }
    
    private func setupConstraints() {
        if !isConstraintsConfigured {
            isConstraintsConfigured = true
            
            constraintSpinner()
        }
    }
    
    // MARK: - Instances
    
    private let spinner:UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        return spinner
    }()
    
    // MARK: - Constraints
    
    private func constraintSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.leadingAnchor.constraint(equalTo: extSafeArea.leadingAnchor).isActive = true
        spinner.topAnchor.constraint(equalTo: extSafeArea.topAnchor).isActive = true
        spinner.trailingAnchor.constraint(equalTo: extSafeArea.trailingAnchor).isActive = true
        spinner.bottomAnchor.constraint(equalTo: extSafeArea.bottomAnchor).isActive = true
    }
}
