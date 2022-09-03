//
	

import UIKit

class SceneCell: UITableViewCell {
    
    var scaleFactor: CGFloat = 1.0 {
        didSet {
            guard oldValue != scaleFactor else { return }
            resetCell()
        }
    }
    var sceneData: Scene?
    
    private let iconWidth = CGFloat(60)
    private let iconHeight = CGFloat(60)
    private let topMargin = CGFloat(23)
    private let horizMargin = CGFloat(22)
    
    private var _iconContainer: UIView!
    private var _caption: UILabel!
    private var _timer: UILabel!
    private var _initiator: UILabel!
    private var _onOffButton: UIButton!
    private var _sceneIcon: UIImageView!
    
    private var _heightConstraint: NSLayoutConstraint!
    
    private var allControls: [UIView] {
        return [_caption, _timer, _initiator, _onOffButton, _sceneIcon]
    }
    
    override func prepareForReuse() {
        if _heightConstraint == nil {
            _heightConstraint = contentView.heightAnchor.constraint(equalToConstant: scaled(91))
            _heightConstraint.isActive = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: - configure cell layout
    private func setupCell() {
        _iconContainer = UIView()
        _caption = UILabel()
        _timer = UILabel()
        _initiator = UILabel()
        _onOffButton = UIButton()
        _sceneIcon = UIImageView()
        
        [_iconContainer, _caption, _timer, _initiator, _onOffButton, _sceneIcon]
            .forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        [_iconContainer, _timer, _initiator, _onOffButton].forEach {
            self.contentView.addSubview($0)
        }
        
        _iconContainer.addSubview(_sceneIcon)
        _iconContainer.addSubview(_caption)
        
        _sceneIcon.heightAnchor.constraint(equalToConstant: scaled(iconWidth))
            .isActive = true
        _sceneIcon.widthAnchor.constraint(equalToConstant: scaled(iconHeight))
            .isActive = true
        _sceneIcon.centerXAnchor.constraint(equalTo: _iconContainer.centerXAnchor)
            .isActive = true
        _sceneIcon.topAnchor.constraint(equalTo: _iconContainer.topAnchor)
            .isActive = true
        
        _caption.topAnchor.constraint(equalTo: _sceneIcon.bottomAnchor)
            .isActive = true
        _caption.centerXAnchor.constraint(equalTo: _iconContainer.centerXAnchor)
            .isActive = true
        _iconContainer.widthAnchor.constraint(greaterThanOrEqualTo: _caption.widthAnchor,
                                              multiplier: 1).isActive = true
        
        _iconContainer.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
            .isActive = true
        _iconContainer.topAnchor.constraint(equalTo: contentView.topAnchor)
            .isActive = true
        
        _initiator.leftAnchor.constraint(equalTo: contentView.leftAnchor,
                                         constant: horizMargin).isActive = true
        _initiator.topAnchor.constraint(equalTo: contentView.topAnchor,
                                        constant: scaled(topMargin)).isActive = true
        _onOffButton.rightAnchor.constraint(equalTo: contentView.rightAnchor,
                                            constant: -horizMargin).isActive = true
        _onOffButton.centerYAnchor.constraint(equalTo: _initiator.centerYAnchor)
            .isActive = true
        
        _timer.rightAnchor.constraint(equalTo: _onOffButton.leftAnchor).isActive = true
        _timer.topAnchor.constraint(equalTo: contentView.topAnchor,
                                    constant: scaled(topMargin)).isActive = true
        
        _heightConstraint.constant = scaled(91)
        
        _onOffButton.setBackgroundImage(UIImage(named: "on-off"))
        _timer.text = "--:--:--"
    }
    
    private func resetCell() {
        allControls.forEach {
            $0.removeFromSuperview()
        }
        setupCell()
    }
    
    // MARK: - scaling support
    private enum ScalingLimit {
        case none /// no scale limiting
        case upper(CGFloat) /// upper limit for scaling factor
        case lower(CGFloat) /// lower limit for scaling factor
    }
    
    private func scaled(_ dimension: CGFloat, limit: ScalingLimit = .none) -> CGFloat {
        var sf = scaleFactor
        switch limit {
        case .lower(let val):
            if(scaleFactor < val) { sf = val }
        case .upper(let val):
            if(scaleFactor > val) { sf = val }
        default: break
        }
        return sf * dimension
    }
}
