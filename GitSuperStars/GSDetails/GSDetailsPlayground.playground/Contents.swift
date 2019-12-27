//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import GSDetails

let vm = DetailsViewModel()
let vc = DetailsViewController<DetailsView, DetailsViewModel>(viewModel: vm)

PlaygroundPage.current.liveView = vc
