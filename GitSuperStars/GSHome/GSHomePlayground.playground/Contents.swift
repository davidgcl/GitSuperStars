//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import GSHome
import GSCore

Font.registerFonts()

func buildHomeVC() -> HomeViewController<HomeView, HomeViewModel> {
    let repository = URLSessionRepository()
    let homeVC = HomeViewController(viewModel: HomeViewModel(repository: repository))
    return homeVC
}

let rootViewController = buildHomeVC()
let presenter = UINavigationController(rootViewController: rootViewController)
presenter.isNavigationBarHidden = false

PlaygroundPage.current.liveView = presenter
