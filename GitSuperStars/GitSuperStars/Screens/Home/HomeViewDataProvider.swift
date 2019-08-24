import UIKit

class HomeViewDataProvider: NSObject {

    private weak var viewModel: HomeViewModel?
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
    }
}

extension HomeViewDataProvider: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return viewModel?.currentCount ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if let viewModel = viewModel {
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: GitRepositoryItemTableViewCell.self), for: indexPath) as! GitRepositoryItemTableViewCell
                if let model = viewModel.gitRepositoryItem(at: indexPath.row) {
                    cell.bind(gitRepositoryItem: model)
                }
                return cell
            } else {
                fatalError("Invalid state reached.")
            }
        } else {
            fatalError("Invalid state reached.")
        }
    }
}
