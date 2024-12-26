import Foundation
import DittoSwift

// MARK: - DittoInstance
final class DittoInstance {
    let appConfig: AppConfig
    static var shared = DittoInstance()
    let ditto: Ditto
    
    private init() {
        appConfig = DittoInstance.loadAppConfig()
#if os(tvOS)
        let directory: FileManager.SearchPathDirectory = .cachesDirectory
#else
        let directory: FileManager.SearchPathDirectory = .documentDirectory
#endif
        
        let persistenceDirURL = try? FileManager()
            .url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("ditto-pos-demo")
        
        ditto = Ditto(identity: .onlinePlayground(
            appID: appConfig.appId,
            token: appConfig.token,
            enableDittoCloudSync: true
        ), persistenceDirectory: persistenceDirURL)
    }
    
    private static func loadAppConfig() -> AppConfig {
        guard
            let path = Bundle.main.path(
                forResource:
                    "appConfig", ofType: "plist")
        else {
            fatalError("Could not load appConfig file!")
        }
        let data = NSData(contentsOfFile: path)! as Data
        let dittoPropertyList =
        try! PropertyListSerialization.propertyList(from: data, format: nil) as! [String: Any]
        let endpointUrl = dittoPropertyList["endpointUrl"] as! String
        let token = dittoPropertyList["token"] as! String
        let appId = dittoPropertyList["appId"] as! String
        return AppConfig(
            endpointUrl: endpointUrl, token: token,
            appId: appId)
    }
}
