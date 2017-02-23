/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation
import Alamofire
import SwiftyJSON

struct Definition {
  let title: String
  let description: String
  let imageURL: URL?
}

class DuckDuckGo {
  
  enum ResultType: String {
    case Answer = "A"
    case Exclusive = "E"    // Exclusive results include special cases like calculations
    func parseDefinitionFromJSON(json: JSON) -> Definition {
        switch self {
        case .Answer:
            let heading = json["Heading"].stringValue
            let abstract = json["AbstractText"].stringValue
            let imageURL = NSURL(string: json["Image"].stringValue)
            
            return Definition(title: heading, description: abstract, imageURL: imageURL as URL?)
        case .Exclusive:
            let answer = json["Answer"].stringValue
            
            return Definition(title: "Answer", description: answer, imageURL: nil)
        }
    }    
  }
    
    
  func performSearch(_ searchTerm: String, completion: @escaping ((_ definition: Definition?) -> Void)) {
    let parameters: [String:AnyObject] = ["q": searchTerm as AnyObject, "format": "json" as AnyObject, "pretty": 1 as AnyObject,
                                          "no_html": 1 as AnyObject, "skip_disambig": 1 as AnyObject]
    
    // 2
    Alamofire.request("https://api.duckduckgo.com", method: .get, parameters: parameters)
        .validate(statusCode: 200..<300)
//        .validate(contentType: ["application/json"])
        .responseJSON { response in
            
        switch response.result {
        case .success:
            print("Validation Successful response \(response)")
            if let jsonObject: AnyObject = response.data as AnyObject? {
                let json = JSON(jsonObject)
    
                // 5
                if let jsonType = json["Type"].string, let resultType = ResultType(rawValue: jsonType) {
                    // 6
                    let definition = resultType.parseDefinitionFromJSON(json: json)
                    completion(definition)
                }
                else {
                    completion(nil)
                }
            }
            else {
                completion(nil)
            }
        case .failure(let error):
            print(error)
            completion(nil)
        }
    }
    
//    if let imageURL = definition.imageURL {
//        Alamofire.request(imageURL).response { response in
//            self.activityIndicator.stopAnimating()
//            
//            if let data = response.data,
//                let image = UIImage(data: data) {
//                self.imageView.image = image
//            }
//        }
//    }
    
    
//    completion(nil)
  }
}
