import UIKit

enum Size {
    case font_caption
    case font_body
    case font_subtitle
    case font_header_1
    
    case loading_view_cell_height
    
    case repository_view_cell_height
    case repository_view_cell_h_margin
    case repository_view_cell_v_margin
    case repository_owner_image_to_text_margin
    case repository_owner_title_to_text_margin
    case repository_owner_text_to_text_margin
    case repository_owner_image_width
    case repository_owner_image_height
    case repository_owner_image_border_width
    case repository_owner_image_border_radius
    
    case navigation_logo_height
    case navigation_logo_width
    
}

extension Size {
    
    var value: CGFloat {
        var out:CGFloat = 0
        
        switch self {
        case .font_caption: out = 12
        case .font_body: out = 14
        case .font_subtitle: out = 16
        case .font_header_1: out = 20
            
        case .loading_view_cell_height: out = 100.0
            
        case .repository_view_cell_height: out = 100.0
        case .repository_view_cell_h_margin: out = 16.0
        case .repository_view_cell_v_margin: out = 8.0
        case .repository_owner_image_to_text_margin: out = 8.0
        case .repository_owner_title_to_text_margin: out = 4.0
        case .repository_owner_text_to_text_margin: out = 4.0
        case .repository_owner_image_width: out = 80.0
        case .repository_owner_image_height: out = 80.0
        case .repository_owner_image_border_width: out = 1.0
        case .repository_owner_image_border_radius: out = 10.0
            
        case .navigation_logo_height: out = 40
        case .navigation_logo_width: out = 80.0
            
        }
        return out
    }
}
