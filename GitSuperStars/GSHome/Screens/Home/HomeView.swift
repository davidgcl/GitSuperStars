import UIKit
import GSCore

public class HomeView: BaseView {

    public let navigationItemLogo: UIImageView = {
        let imageView = UIImageView(frame: CGRect(
            x: 0, y: 0,
            width: Size.navigationLogoWidth.value,
            height: Size.navigationLogoHeight.value))
        imageView.contentMode = .scaleAspectFit
        imageView.image = Image.gitSuperStarsLogo.value
        return imageView
    }()

    public let tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorColor = Color.colorGreyLight.value
        tableView.backgroundColor = Color.colorGreyLighter.value
        return tableView
    }()

    public let refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: LocalizedString.pullToRefresh.value)
        refreshControl.tintColor = Color.colorGreyLight.value
        return refreshControl
    }()

    override public func setupView() {
        backgroundColor = Color.colorGreyLighter.value
        addSubview(tableView)
        tableView.refreshControl = refreshControl
    }

    override public func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: extSafeArea.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: extSafeArea.trailingAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: extSafeArea.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: extSafeArea.bottomAnchor).isActive = true
    }
}
