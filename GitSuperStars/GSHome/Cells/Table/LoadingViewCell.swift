import UIKit
import GSCore

class LoadingViewCell: UITableViewCell {

    private var isConstraintsConfigured = false

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.gray)
        return spinner
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

    func startAnimating() {
        spinner.startAnimating()
    }

    private func setupView() {
        self.backgroundColor = Color.colorGreyLighter.value
        self.addSubview(spinner)
    }

    private func setupConstraints() {
        if !isConstraintsConfigured {
            isConstraintsConfigured = true

            spinner.translatesAutoresizingMaskIntoConstraints = false
            spinner.leadingAnchor.constraint(equalTo: extSafeArea.leadingAnchor).isActive = true
            spinner.topAnchor.constraint(equalTo: extSafeArea.topAnchor).isActive = true
            spinner.trailingAnchor.constraint(equalTo: extSafeArea.trailingAnchor).isActive = true
            spinner.bottomAnchor.constraint(equalTo: extSafeArea.bottomAnchor).isActive = true
        }
    }
}
