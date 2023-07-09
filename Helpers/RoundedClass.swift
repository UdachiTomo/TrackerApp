import UIKit

final class RoundedButton: UIButton {
    public var toggled: Bool = false {
        didSet {
            if toggled {
                let image = UIImage(systemName: "checkmark")
                UIView.animate(withDuration: 0.3) {
                    self.backgroundColor = self.backgroundColor?.withAlphaComponent(0.3)
                }
                setImage(image, for: .normal)
            } else {
                let image = UIImage(systemName: "plus")
                UIView.animate(withDuration: 0.3) {
                    self.backgroundColor = self.backgroundColor?.withAlphaComponent(1.0)
                }
                setImage(image, for: .normal)
            }
        }
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        super.touchesBegan(touches, with: event)
        UIView.animate(withDuration: 0.3) {
            self.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

        super.touchesEnded(touches, with: event)
        UIView.animate(withDuration: 0.3, animations:  {
            self.transform = .identity
        }, completion: { _ in
            self.toggled.toggle()
        })
    }
    
}
