import Foundation
import Alamofire
import UIKit



class StreetFitTokenHandler: RequestAdapter, RequestRetrier {
    private typealias RefreshCompletion = (_ succeeded: Bool, _ jwt1: String, _ jwt2: String?) -> ()
    
    private let sessionManager: SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        return SessionManager(configuration: configuration)
        
    } ()
    
    private let lock = NSLock()
    
    private var jwt1: String
    private var jwt2: String
    private var baseURLString: String
    
    private var isRefreshing = false
    private var requestsToRetry: [RequestRetryCompletion] = []
    
    // Initialization
    
    public init(jwt1: String,jwt2:String,baseURLString: String) {
        self.jwt1 = jwt1
        self.jwt2 = jwt2
        self.baseURLString = baseURLString
    }
    
    // Request Adapter
    
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix(baseURLString) {
            var urlRequest = urlRequest
            urlRequest.setValue(jwt1, forHTTPHeaderField: "jwt1")
            return urlRequest
        }
        
        return urlRequest
    }
    
    // RequestRetrier
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 {
            requestsToRetry.append(completion)
            
            if !isRefreshing {
                refreshToken(jwt1: <#T##String#>, completion: <#T##(String) -> Void#>)
            }
        }
    }
    
    func refreshToken (jwt1: String, completion: @escaping RefreshCompletion) {
        
        let urlString = "http://83.217.132.102:3000/auth/refresh"
        guard !isRefreshing else { return }
        
        isRefreshing = true
        
        let parameters: [String: Any] = [
            "jwt1" : jwt1
        ]
        
        let headers: HTTPHeaders = [
            "jwt1" : jwt1
        ]
        
        sessionManager.request(urlString, method: .post,encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            guard let strongSelf = self else { return }
            
            if
                let json = response.result.value as? [String:Any],
                let jwt1 = json["jwt1"] as? String,
                let jwt2 = json["jwt2"] as? String
            {
                completion(true,jwt1,jwt2)
            } else {
                completion(false,nil,nil)
            }
            
            strongSelf.isRefreshing = false
            
        }
    }
    
    
}


class AugmentedLoginVC: UIViewController {

    
    @IBAction func ActionLaunch(_ sender: Any) {
        Launch()
    }
    
    @IBAction func ActionRefresh(_ sender: Any) {
        let jwt1 = UserDefaults.standard.string(forKey: "jwt1")!
        refreshToken(jwt1: jwt1) { response in
            
        }
    }
    
    
    
    override func viewDidLoad() {
        
    }
    
    func Launch() {
        
    let MemJwt2 = UserDefaults.standard.string(forKey: "jwt2")
        
    let sessionManager = SessionManager()
    sessionManager.adapter = JWTAccessTokenAdapter(accessToken: MemJwt2!)
    sessionManager.request("http://83.217.132.102:3000/auth/experlogin/innerjoin")
    }
    
    // RefreshRequest
    func refreshToken (jwt1: String, completion: @escaping (String) -> Void) {
        
        let targetURL = "http://83.217.132.102:3000/auth/refresh"
        let url = URL(string: targetURL)!
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue(jwt1, forHTTPHeaderField: "jwt1")
        
        Alamofire.request(request).responseJSON { response in
            
            do {
                let decoder = JSONDecoder()
                let model = try decoder.decode(MainResStruct.self, from: response.data!)
                completion(model.data!.jwt2!)
                print(model.data!.jwt2!)
                
            } catch {}
            
        }
        
    }
    
    
}
