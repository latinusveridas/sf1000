import Foundation
import Alamofire
import UIKit



final class JWTAccessTokenAdapter: RequestAdapter {
    typealias JWT = String
    var accessToken: JWT
    
    let MemJwt1 = UserDefaults.standard.string(forKey: "jwt1")
    let MemJwt2 = UserDefaults.standard.string(forKey: "jwt2")
    
    
    init(accessToken: JWT) {
        self.accessToken = accessToken
    }
    
    
    /// Adapter
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var urlRequest = urlRequest
        
        if let urlString = urlRequest.url?.absoluteString, urlString.hasPrefix("http://83.217.132.102:3000/") {
            /// Set the Authorization header value using the access token.
            urlRequest.setValue(MemJwt2, forHTTPHeaderField: "jwt2")
        }
        
        return urlRequest
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
                
            } catch {}
            
        }
        
    }
    
// End of class
}

// RequestRetrier
extension JWTAccessTokenAdapter: RequestRetrier {
    
    
    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {
        
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            completion(false, 0.0)
            print("we are in success RequestRetier")
            return
        }
        
        refreshToken (jwt1: MemJwt1!) { [weak self] accessToken in
            guard let strongSelf = self else { return }
            
            strongSelf.accessToken = accessToken
            print("We are in refresh case RequestRetrier")
            completion(true, 0.0)
        }
    }
}


class AugmentedLoginVC: UIViewController {
    
    @IBAction func ActionLaunch(_ sender: Any) {
        Launch()
    }
    
    
    override func viewDidLoad() {
        
    }
    
    func Launch() {
        
    let MemJwt2 = UserDefaults.standard.string(forKey: "jwt2")
        
    let sessionManager = SessionManager()
    sessionManager.adapter = JWTAccessTokenAdapter(accessToken: MemJwt2!)
    sessionManager.request("http://83.217.132.102:3000/auth/experlogin/innerjoin")
    }
}
