//
//  PaymentScannerWidgetView.swift
//  Pods
//
//  Created by Sean Williams on 30/10/2020.
//

import UIKit

class PaymentScannerWidgetView: UIView {
    struct Constants {
        static let cornerRadius: CGFloat = 4
    }

    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet public weak var titleLabel: UILabel!
    @IBOutlet public weak var explainerLabel: UILabel!

//    private var state: WidgetState = .enterManually
    private var timer: Timer?
    public var view: UIView!
    public var stringDataSource: ScanStringsDataSource?
    var reuseableId: String {
        return String(describing: type(of: self))
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
        configure()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
        configure()
    }

    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    private func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: self.reuseableId, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        
        return view
    }
    
//    func unrecognizedBarcode() {
//        error(state: .unrecognizedBarcode)
//    }

//    func timeout() {
//        error(state: .timeout)
//    }

    func addTarget(_ target: Any?, selector: Selector?) {
        addGestureRecognizer(UITapGestureRecognizer(target: target, action: selector))
    }

    private func configure() {
        clipsToBounds = true
        layer.cornerRadius = Constants.cornerRadius

        titleLabel.font = UIFont(name: "NunitoSans-ExtraBold", size: 18.0)
        explainerLabel.font = UIFont(name: "NunitoSans-Light", size: 18.0)
        explainerLabel.numberOfLines = 2
        imageView.image = UIImage(named: "loyalty_scanner_enter_manually")

        if #available(iOS 10.0, *) {
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false, block: { [weak self] _ in
                let animation = CAKeyframeAnimation(keyPath: "transform.scale")
                animation.timingFunction = CAMediaTimingFunction(name: .linear)
                animation.duration = 0.6
                animation.speed = 0.8
                animation.values = [0.9, 1.1, 0.9, 1.1, 0.95, 1.05, 0.98, 1.02, 1.0]
                self?.layer.add(animation, forKey: "shake")
                self?.imageView.image = UIImage(named: "loyalty_scanner_error")
            })
        }
    }

//    private func error(state: WidgetState) {
//        layer.addBinkAnimation(.shake)
//        HapticFeedbackUtil.giveFeedback(forType: .notification(type: .error))
//        setState(state)
//    }

//    private func setState(_ state: WidgetState) {
//        titleLabel.text = stringDataSource?.widgetTitle()
//        explainerLabel.text = stringDataSource?.widgetExplainerText()
//        imageView.image = UIImage(named: "loyalty_scanner_enter_manually")
//        self.state = state
//    }
}

//extension PaymentScannerWidgetView {
//    enum WidgetState {
//        case enterManually
////        case unrecognizedBarcode
//        case timeout
//
//        var title: String {
//            switch self {
//            case .enterManually, .timeout:
////                guard let dataSource = stringDataSource else { return }
//                return ""
////            case .unrecognizedBarcode:
////                return "loyalty_scanner_widget_title_unrecognized_barcode_text"
//            }
//        }
//
//        var explainerText: String {
//            switch self {
//            case .enterManually, .timeout:
//                return "loyalty_scanner_widget_explainer_enter_manually_text"
////            case .unrecognizedBarcode:
////                return "loyalty_scanner_widget_explainer_unrecognized_barcode_text"
//            }
//        }
//
//        var imageName: String {
//            switch self {
//            case .enterManually:
//                return "loyalty_scanner_enter_manually"
//            case .timeout:
//                return "loyalty_scanner_error"
//            }
//        }
//    }
//}

