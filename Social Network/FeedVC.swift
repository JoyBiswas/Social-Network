//
//  FeedVC.swift
//  Social Network
//
//  Created by JOY BISWAS on 3/6/18.
//  Copyright © 2018 MacBook Air. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView:UITableView!
    
    @IBOutlet weak var captionField: FancyField!
    
    var imageSelected = false
    
    var posts = [Post]()
     @IBOutlet weak var imageAdd: CircleView!
    
    @IBOutlet weak var feedImg: CircleView!
    
    
    var imagePicker:UIImagePickerController!
    static var imageCache:NSCache<NSString, UIImage> = NSCache()
    
    
    


    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        
            DataService.ds.REF_POSTS.childByAutoId().queryEqual(toValue:"joy ho", childKey: "caption").observe(.childAdded, with: { (snapshot) in
                
                print(snapshot.value!)
                
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        print("SNAP: \(snap)")
                        if let postDict = snap.value as? Dictionary<String, AnyObject> {
                            let key = snap.key
                            let post = Post(postKey: key, postData: postDict)
                            self.posts.append(post)
                        }
                        
                    }
                }
                self.tableView.reloadData()
                
            })

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                
                print(post.imageUrl)
                cell.configureCell(post: post, img: img)
            } else {
                cell.configureCell(post: post, img: nil)
            }
            return cell
        } else {
            return PostCell()
        }

    }
    
    
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            feedImg.image = image
            imageSelected = true
            
        } else {
            print("JESS: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addImageTapped(_ sender: AnyObject) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    @IBAction func postBtnTapped(_ sender: AnyObject) {
        guard let caption = captionField.text, caption != "" else {
            print("JESS: Caption must be entered")
            return
        }
        guard let img = imageAdd.image, imageSelected == true else {
            print("JESS: An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).putData(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("JESS: Unable to upload image to Firebasee torage")
                } else {
                    print("JESS: Successfully uploaded image to Firebase storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.postToFirebase(imgUrl: url)
                    }
                }
            }
        }
    }
    
    func postToFirebase(imgUrl: String) {
        let post: Dictionary<String, AnyObject> = [
            "caption": captionField.text! as AnyObject,
            "imageUrl": imgUrl as AnyObject,
            "likes": 0 as AnyObject 
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")
        
        tableView.reloadData()
    }

    
    @IBAction func signOutTapped(_ sender: AnyObject) {
        let keychainResult=KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("JESS: ID removed from keychain \(keychainResult)")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
    
}
