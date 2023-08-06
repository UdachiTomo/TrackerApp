import Foundation
import YandexMobileMetrica

struct AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "6afd36d2-5535-4758-9b72-7e2cd23df2b7") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: Events , params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event.rawValue, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
