
import UIKit
import NotificationCenter
import CryptoCurrencyKit

class TodayViewController: CurrencyDataViewController, NCWidgetProviding {

  @IBOutlet weak var vibrancyView: UIVisualEffectView!
  @IBOutlet weak var priceSelectionVibrancyView: UIVisualEffectView!
  var lineWidth: CGFloat = 2.0

  override func viewDidLoad() {
    super.viewDidLoad()
    lineChartView.delegate = self
    lineChartView.dataSource = self

    priceLabel.text = "--"
    priceChangeLabel?.text = "--"
    extensionContext?.widgetLargestAvailableDisplayMode = .expanded
    vibrancyView.effect = UIVibrancyEffect.widgetPrimary()
    priceSelectionVibrancyView.effect = UIVibrancyEffect.widgetSecondary()


  }

  override func lineChartView(_ lineChartView: JBLineChartView!, colorForLineAtLineIndex lineIndex: UInt) -> UIColor! {
    return lineChartView.tintColor
  }

  private func toggleLineChart() {
    let expanded = extensionContext!.widgetActiveDisplayMode == .expanded
    if expanded {
      lineWidth = 4.0
      priceOnDayLabel.isHidden = false
    } else {
      lineWidth = 2.0
      priceOnDayLabel.isHidden = true
    }
    priceOnDayLabel.text = ""
  }

  func lineChartView(_ lineChartView: JBLineChartView!, didSelectLineAtIndex lineIndex: UInt, horizontalIndex: UInt) {
    if let prices = prices {
      let price = prices[Int(horizontalIndex)]
      updatePriceOnDayLabel(price)
    }
  }

  func didUnselectLineInLineChartView(_ lineChartView: JBLineChartView!) {
    priceOnDayLabel.text = ""
  }

  override func lineChartView(_ lineChartView: JBLineChartView!, widthForLineAtLineIndex lineIndex: UInt) -> CGFloat {
    return lineWidth
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    fetchPrices { error in
      if error == nil {
        self.updatePriceLabel()
        self.updatePriceChangeLabel()
        self.updatePriceHistoryLineChart()
      }
    }
  }

  func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
    let expanded = activeDisplayMode == .expanded
    preferredContentSize = expanded ? CGSize(width: maxSize.width, height: 200) : maxSize
    toggleLineChart()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updatePriceHistoryLineChart()
  }

  func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
    fetchPrices { error in
      if error == nil {
        self.updatePriceLabel()
        self.updatePriceChangeLabel()
        self.updatePriceHistoryLineChart()
        completionHandler(.newData)
      } else {
        completionHandler(.failed)
      }
    }
  }

}
