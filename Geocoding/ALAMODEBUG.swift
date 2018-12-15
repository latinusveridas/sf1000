import Foundation
import Alamofire
import UIKit



class StreetFitTokenHandler: RequestAdapter, RequestRetrier {
    private typealias RefreshCompletion = (_ succeeded: Bool, _ jwt1: String?, _ jwt2: String?) -> ()
    

    let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration)
        
    } ()
    
    private let lock = NSLock()
    
    private var jwt1: String?
    private var jwt2: String?
    private var baseURLString: String
    
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    // Initialization
    
    public init(jwt1: String?,jwt2:String?,baseURLString: String) {
        self.jwt1 = jwt1
        self.jwt2 = jwt2
        self.baseURLString = baseURLString
    }
    
    // Request Adapter
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(baseURLString) {
            var urlRequest = urlRequest
            print("DEBUG ADAPTER JWT1 IS", jwt1!)
            urlRequest.setValue(jwt1, forHTTPHeaderField: "jwt1")
            urlRequest.setValue(jwt2, forHTTPHeaderField: "jwt2")
            return urlRequest
        }
        
        return urlRequest
    }
    
    // RequestRetrier
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                print("Refresh is require, launching of the refreshToken function")
                refreshToken { [weak self] succeeded, jwt1,jwt2 in
                    guard let strongSelf = self else {return}
                    
                    strongSelf.lock.lock() ; defer {strongSelf.lock.unlock()}
                    
                    if let jwt1 = jwt1, let jwt2 = jwt2 {
                        strongSelf.jwt1 = jwt1
                        strongSelf.jwt2 = jwt2
                        
                    }
                    
                    strongSelf.requestsToRetry.forEach { $0(succeeded, 0.0) }
                    strongSelf.requestsToRetry.removeAll()
                    
                }
            }
        } else {
            completion(false,0.0)
        }
    }
    
   private func refreshToken (completion: @escaping RefreshCompletion) {
        
        let urlString = "http://83.217.132.102:3000/auth/refresh"
        guard !isRefreshing else { return }
        
        isRefreshing = true
        
        let headers: HTTPHeaders = [
            "jwt1" : jwt1!
        ]
        
        sessionManager.request(urlString, method: .post,encoding: JSONEncoding.default, headers: headers).responseJSON { [weak self] response in
            guard let strongSelf = self else { return }
            
            let json = response.result.value as! [String:Any]
            let data = json["data"] as! [String:Any]
            let jwt2 = data["JWT2"] as? String
            
            if
                let json = response.result.value as? [String:Any],
                let data = json["data"] as? [String:Any],
                let jwt2 = data["JWT2"] as? String

            {
                UserDefaults.standard.set(jwt2, forKey: "jwt2")
                completion(true,self?.jwt1,jwt2)
            } else {
                completion(false,nil,nil)
            }
            
            strongSelf.isRefreshing = false
            
        }
    }
    
    
}


class AugmentedLoginVC: UIViewController {
    
    override func viewDidLoad() {
    }
    
    @IBAction func ActionLaunch(_ sender: Any) {
        let baseURLString = "http://83.217.132.102:3000/"
        let jwt1 = UserDefaults.standard.string(forKey: "jwt1")
        let jwt2 = UserDefaults.standard.string(forKey: "jwt2")

        
        let SFTokenHandler = StreetFitTokenHandler(jwt1: jwt1, jwt2: jwt2,baseURLString: baseURLString)
        
        let sessionManager = SFTokenHandler.sessionManager
        
        sessionManager.adapter = SFTokenHandler
        sessionManager.retrier = SFTokenHandler
        
        let urlString = "http://83.217.132.102:3000/auth/experlogin/innerjoin"
        
        sessionManager.request(urlString).validate().responseJSON{response in
            
            debugPrint(response)
            
        }
        
    }
    
    @IBAction func ActionRefresh(_ sender: Any) {
 
    }

    
}
