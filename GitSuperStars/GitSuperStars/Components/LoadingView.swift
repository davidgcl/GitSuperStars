import UIKit

class LoadingView: UIView {
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        setupView()
        setupConstraints()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        if self.superview != nil {
            spinner.startAnimating()
        } else {
            spinner.stopAnimating()
        }
    }
    
    // MARK: - Helper
    
    private func setupView() {
        addSubview(spinner)
    }
    
    func setupConstraints() {
        constraintSpinner()
    }
    
    // MARK: - Instances
    
    private let spinner:UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        spinner.hidesWhenStopped = false
        return spinner
    }()
    
    // MARK: - Constraints
    
    private func constraintSpinner() {
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        spinner.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        spinner.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        spinner.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
}
