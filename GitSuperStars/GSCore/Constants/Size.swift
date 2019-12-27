import UIKit

public enum Size {
    case fontCaption
    case fontBody
    case fontSubtitle
    case fontHeader1
    case loadingViewCellHeight
    case repositoryViewCellHeight
    case repositoryViewCellMarginH
    case repositoryViewCellMarginV
    case repositoryOwnerImageToTextMargin
    case repositoryOwnerTitleToTextMargin
    case repositoryOwnerTextToTextMargin
    case repositoryOwnerImageWidth
    case repositoryOwnerImageHeight
    case repositoryOwnerImageBorderWidth
    case repositoryOwnerImageBorderRadius
    case navigationLogoHeight
    case navigationLogoWidth
}

public extension Size {
    var value: CGFloat {
        var out: CGFloat = 0
        switch self {
        case .fontCaption: out = 12
        case .fontBody: out = 14
        case .fontSubtitle: out = 16
        case .fontHeader1: out = 20
        case .loadingViewCellHeight: out = 100.0
        case .repositoryViewCellHeight: out = 100.0
        case .repositoryViewCellMarginH: out = 16.0
        case .repositoryViewCellMarginV: out = 8.0
        case .repositoryOwnerImageToTextMargin: out = 8.0
        case .repositoryOwnerTitleToTextMargin: out = 4.0
        case .repositoryOwnerTextToTextMargin: out = 4.0
        case .repositoryOwnerImageWidth: out = 80.0
        case .repositoryOwnerImageHeight: out = 80.0
        case .repositoryOwnerImageBorderWidth: out = 1.0
        case .repositoryOwnerImageBorderRadius: out = 10.0
        case .navigationLogoHeight: out = 40
        case .navigationLogoWidth: out = 80.0
        }
        return out
    }
}
