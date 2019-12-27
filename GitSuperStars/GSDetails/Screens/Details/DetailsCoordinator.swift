//
//  DetailsCoordinator.swift
//  GitSuperStars
//
//  Created by David Lima on 18/12/19.
//  Copyright © 2019 SeuAplicativo.Net. All rights reserved.
//

import UIKit
import GSCore

public class DetailsCoordinator: Coordinator {
    
    override public init(_ presenter: UINavigationController? = nil) {
        super.init(presenter)
    }
    
    override public func start() {
        let viewController = buildDetailsVC()
        rootViewController = viewController
        
        presenter?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Helpers
    private func buildDetailsVC() -> DetailsViewController<DetailsView, DetailsViewModel> {
        let detailsVC = DetailsViewController(viewModel: DetailsViewModel())
        detailsVC.delegate = self
        detailsVC.delegateBase = self
        return detailsVC
    }
}

extension DetailsCoordinator: BaseViewControllerDelegate {
    public func didFinish(viewController: UIViewController) {
        if rootViewController == nil {
            finish()
        }
    }
    
}

extension DetailsCoordinator: DetailsViewControllerDelegate {

}
