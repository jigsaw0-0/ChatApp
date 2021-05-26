//
//  FileStorage.swift
//  Messager
//
//  Created by David Kababyan on 21/08/2020.
//

import Foundation
import FirebaseStorage
import ProgressHUD
import Alamofire


struct ImageHeaderData{
    static var PNG: [UInt8] = [0x89]
    static var JPEG: [UInt8] = [0xFF]
    static var GIF: [UInt8] = [0x47]
    static var TIFF_01: [UInt8] = [0x49]
    static var TIFF_02: [UInt8] = [0x4D]
}

enum ImageFormat{
    case Unknown, PNG, JPEG, GIF, TIFF
}



let storage = Storage.storage()

class FileStorage {
    
    //MARK: - Images
    
    class func uploadImageAlamofire(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
        let parameters = ["Content-type": "form-data",
                          "Content-Disposition" : "image/jpeg",
                          "sid":"cXesobua2iDfig+/MgcOokNTAZSuKxE5ByDyQIZn3r4="]
        AF.upload(multipartFormData: { (multipartFormData) in
            
            //https://beta3.justdial.com/uttam/jdchatmuc/index.html?sid=G89M71NVIuIaLrYCm6d0N2nj423JxFQ0%2FT%2BUGvWSOL8%3D&docid=080PXX80.XX80.200625174808.I3W5&ctype=con&prefid=DRK2G2Z7
            let imageData = image.jpegData(compressionQuality: 0.6)
            print("\nKing of image ->\((imageData! as NSData).imageFormat)")
            let someStr = UUID().uuidString
            multipartFormData.append(imageData!, withName: "file", fileName: someStr + ".jpeg", mimeType: "multipart/form-data")
            
            
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
            }
            
        }, to: "https://beta3.justdial.com/uttam/jdchat/upload.php?sid=cXesobua2iDfig+/MgcOokNTAZSuKxE5ByDyQIZn3r4=").uploadProgress { progress in
            
            
            let progress = progress.completedUnitCount / progress.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
            
            //uploadProgressValues.append(progress.fractionCompleted)
        }
        .downloadProgress { progress in
            
            //    downloadProgressValues.append(progress.fractionCompleted)
        }
        .response { response in
            
            print("Upload Complete !!!!")
            ProgressHUD.dismiss()
            if((response.error == nil)){
                do{
                    if let jsonData = response.data{
                        if let parsedData = try JSONSerialization.jsonObject(with: jsonData) as? NSDictionary {
                            print(parsedData)
                            if let arr = parsedData.object(forKey: "image_urls") as? Array<String>, arr.count > 0 {
                                completion(arr[0])
                            }
                            
                        }
                        
                        
                    }else{
                        print("\nResponse data is nil")
                        
                    }
                }catch{
                    print("error message")
                }
            }else{
                print(response.error!.localizedDescription)
            }
            
            
        }
        
        
    }
    
    
    
    
    
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
        
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
        
        let imageData = image.jpegData(compressionQuality: 0.6)
        
        var task: StorageUploadTask!
        
        task = storageRef.putData(imageData!, metadata: nil, completion: { (metadata, error) in
            
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil {
                print("error uploading image \(error!.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { (url, error) in
                
                guard let downloadUrl = url  else {
                    completion(nil)
                    return
                }
                
                completion(downloadUrl.absoluteString)
            }
        })
        
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }
    
    
    class func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
        
        let imageFileName = fileNameFrom(fileUrl: imageUrl)

        if fileExistsAtPath(path: imageFileName) {
            //get it locally
//            print("We have local image")
            
            if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
                
                completion(contentsOfFile)
            } else {
                print("couldnt convert local image")
                completion(UIImage(named: "avatar"))
            }
            
        } else {
            //download from FB
//            print("Lets get from FB")

            if imageUrl != "" {
                
                let documentUrl = URL(string: imageUrl)
                
                let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
                
                downloadQueue.async {
                    
                    let data = NSData(contentsOf: documentUrl!)
                    
                    if data != nil {
                        
                        //Save locally
                        FileStorage.saveFileLocally(fileData: data!, fileName: imageFileName)
                        
                        DispatchQueue.main.async {
                            completion(UIImage(data: data! as Data))
                        }
                        
                    } else {
                        print("no document in database")
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Video
    
    
    //video/mp4
    
    class func uploadVideoAlamofire(_ video: NSData, directory: String, completion: @escaping (_ videoLink: String?) -> Void) {
        let parameters = ["Content-type": "form-data",
                          "Content-Disposition" : "video/mov",
                          "sid":"cXesobua2iDfig+/MgcOokNTAZSuKxE5ByDyQIZn3r4="]
        AF.upload(multipartFormData: { (multipartFormData) in
            
            //https://beta3.justdial.com/uttam/jdchatmuc/index.html?sid=G89M71NVIuIaLrYCm6d0N2nj423JxFQ0%2FT%2BUGvWSOL8%3D&docid=080PXX80.XX80.200625174808.I3W5&ctype=con&prefid=DRK2G2Z7
            let videoData = video
            let someStr = UUID().uuidString
            multipartFormData.append(videoData as Data, withName: "file", fileName: someStr + ".mp4", mimeType: "multipart/form-data")
            
            
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
            }
            
        }, to: "https://beta3.justdial.com/uttam/jdchat/upload.php?sid=cXesobua2iDfig+/MgcOokNTAZSuKxE5ByDyQIZn3r4=").uploadProgress { progress in
            
            
            let progress = progress.completedUnitCount / progress.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
            
            //uploadProgressValues.append(progress.fractionCompleted)
        }
        .downloadProgress { progress in
            
            //    downloadProgressValues.append(progress.fractionCompleted)
        }
        .response { response in
            
            print("Upload Complete Video!!!!")
            
            ProgressHUD.dismiss()
            if((response.error == nil)){
                do{
                    if let jsonData = response.data{
                        if let parsedData = try JSONSerialization.jsonObject(with: jsonData) as? NSDictionary {
                            print(parsedData)
                            if let arr = parsedData.object(forKey: "image_urls") as? Array<String>, arr.count > 0 {
                                completion(arr[0])
                            }
                            
                        }
                        
                        
                    }else{
                        print("\nResponse data is nil")
                        
                    }
                }catch{
                    print("error message")
                }
            }else{
                print(response.error!.localizedDescription)
            }
            
            
        }
        
        
    }
    
    class func uploadVideo(_ video: NSData, directory: String, completion: @escaping (_ videoLink: String?) -> Void) {
        
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
                
        var task: StorageUploadTask!
        
        task = storageRef.putData(video as Data, metadata: nil, completion: { (metadata, error) in
            
            task.removeAllObservers()
            ProgressHUD.dismiss()
            
            if error != nil {
                print("error uploading video \(error!.localizedDescription)")
                return
            }
            
            storageRef.downloadURL { (url, error) in
                
                guard let downloadUrl = url  else {
                    completion(nil)
                    return
                }
                
                completion(downloadUrl.absoluteString)
            }
        })
        
        
        task.observe(StorageTaskStatus.progress) { (snapshot) in
            
            let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
            ProgressHUD.showProgress(CGFloat(progress))
        }
    }

    class func downloadVideo(videoLink: String, completion: @escaping (_ isReadyToPlay: Bool, _ videoFileName: String) -> Void) {
        
        let videoUrl = URL(string: videoLink)
        let videoFileName = fileNameFrom(fileUrl: videoLink) + ".mov"

        if fileExistsAtPath(path: videoFileName) {
                
            completion(true, videoFileName)
            
        } else {

            let downloadQueue = DispatchQueue(label: "VideoDownloadQueue")
            
            downloadQueue.async {
                
                let data = NSData(contentsOf: videoUrl!)
                
                if data != nil {
                    
                    //Save locally
                    FileStorage.saveFileLocally(fileData: data!, fileName: videoFileName)
                    
                    DispatchQueue.main.async {
                        completion(true, videoFileName)
                    }
                    
                } else {
                    print("no document in database")
                }
            }
        }
    }

    
    //MARK: - Audio
    class func uploadAudio(_ audioFileName: String, directory: String, completion: @escaping (_ audioLink: String?) -> Void) {
        
        let fileName = audioFileName + ".m4a"
        
        let storageRef = storage.reference(forURL: kFILEREFERENCE).child(directory)
                
        var task: StorageUploadTask!
        
        if fileExistsAtPath(path: fileName) {
            
            if let audioData = NSData(contentsOfFile: fileInDocumentsDirectory(fileName: fileName)) {
                
                task = storageRef.putData(audioData as Data, metadata: nil, completion: { (metadata, error) in
                    
                    task.removeAllObservers()
                    ProgressHUD.dismiss()
                    
                    if error != nil {
                        print("error uploading audio \(error!.localizedDescription)")
                        return
                    }
                    
                    storageRef.downloadURL { (url, error) in
                        
                        guard let downloadUrl = url  else {
                            completion(nil)
                            return
                        }
                        
                        completion(downloadUrl.absoluteString)
                    }
                })
                
                
                task.observe(StorageTaskStatus.progress) { (snapshot) in
                    
                    let progress = snapshot.progress!.completedUnitCount / snapshot.progress!.totalUnitCount
                    ProgressHUD.showProgress(CGFloat(progress))
                }
            } else {
                print("nothing to upload (audio)")
            }
        }
    }

    class func downloadAudio(audioLink: String, completion: @escaping (_ audioFileName: String) -> Void) {
        
        let audioFileName = fileNameFrom(fileUrl: audioLink) + ".m4a"

        if fileExistsAtPath(path: audioFileName) {
                
            completion(audioFileName)
            
        } else {

            let downloadQueue = DispatchQueue(label: "AudioDownloadQueue")
            
            downloadQueue.async {
                
                let data = NSData(contentsOf: URL(string: audioLink)!)
                
                if data != nil {
                    
                    //Save locally
                    FileStorage.saveFileLocally(fileData: data!, fileName: audioFileName)
                    
                    DispatchQueue.main.async {
                        completion(audioFileName)
                    }
                    
                } else {
                    print("no document in database audio")
                }
            }
        }
    }

    
    //MARK: - Save Locally
    class func saveFileLocally(fileData: NSData, fileName: String) {
        let docUrl = getDocumentsURL().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: docUrl, atomically: true)
    }

    
}

extension NSData{
    var imageFormat: ImageFormat{
        var buffer = [UInt8](repeating: 0, count: 1)
        self.getBytes(&buffer, range: NSRange(location: 0,length: 1))
        if buffer == ImageHeaderData.PNG
        {
            return .PNG
        } else if buffer == ImageHeaderData.JPEG
        {
            return .JPEG
        } else if buffer == ImageHeaderData.GIF
        {
            return .GIF
        } else if buffer == ImageHeaderData.TIFF_01 || buffer == ImageHeaderData.TIFF_02{
            return .TIFF
        } else{
            return .Unknown
        }
    }
}

//Helpers
func fileInDocumentsDirectory(fileName: String) -> String {
    return getDocumentsURL().appendingPathComponent(fileName).path
}

func getDocumentsURL() -> URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
}

func fileExistsAtPath(path: String) -> Bool {
    return FileManager.default.fileExists(atPath: fileInDocumentsDirectory(fileName: path))
}
