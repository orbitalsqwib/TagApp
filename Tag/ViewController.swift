//
//  ViewController.swift
//  Tag
//
//  Created by Eugene L. on 6/1/20.
//  Copyright © 2020 ARandomDeveloper. All rights reserved.
//

import UIKit
import CoreNFC
import Firebase

var receipts = [Receipt]()
let rowHeight = CGFloat(33)
let documentDirectory = FileManager.default.urls(for: FileManager.SearchPathDirectory.cachesDirectory, in: FileManager.SearchPathDomainMask.userDomainMask).first!
let saveFileURL = documentDirectory.appendingPathComponent("receipts.json")

class ViewController: UIViewController {
    
    @IBOutlet weak var NFCButton: UIView!
    @IBOutlet weak var Header: UIView!
    @IBOutlet weak var ReceiptCollectionView: UICollectionView!
    
    @IBAction func clickedScan(_ sender: Any) {
        guard NFCNDEFReaderSession.readingAvailable else {
            let alertController = UIAlertController(
                title: "Scanning Not Supported",
                message: "This device doesn't support tag scanning.",
                preferredStyle: .alert
            )
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session.alertMessage = "Looking for receipt..."
        session.begin()
    }
    
    let ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ReceiptCollectionView.dataSource = self
        ReceiptCollectionView.delegate = self
        
        Header.layer.shadowColor = UIColor.black.cgColor
        Header.layer.shadowOpacity = 0.25
        Header.layer.shadowRadius = 5
        Header.layer.shadowOffset = CGSize(width: 0, height: 1)
        
        NFCButton.layer.cornerRadius = 5
        NFCButton.clipsToBounds = true
        NFCButton.dropShadow(radius: 5)
        
        receipts = loadReceiptData()
        self.ReceiptCollectionView.reloadData()
        
        updateReceiptData(userID: 1)
    }
    
    func updateReceiptData(userID: Int) {
        var newReceipts = [Receipt]()
        
        ref.child("users").child(String(userID)).child("receipts").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get value of receipt
            let receiptArray:NSArray = snapshot.children.allObjects as NSArray
            for receipt in receiptArray {
                let snap = receipt as! DataSnapshot
                let receiptDetails = snap.value as! [String:Any]
                
                var receiptItems = [Receipt.ReceiptItem]()
                
                for (_, value) in receiptDetails["items"] as! NSDictionary {
                    if let itmDict = value as? NSDictionary {
                        let receiptItem = Receipt.ReceiptItem(
                            Name: itmDict["name"] as! String,
                            Qty: itmDict["quantity"] as! Int,
                            SubTotal: itmDict["price"] as! Double)
                        receiptItems.append(receiptItem)
                    }
                }
                
                let r = Receipt(
                    StoreName: receiptDetails["store"] as! String,
                    GrandTotal: receiptDetails["total"] as! Double,
                    Items: receiptItems)
                
                newReceipts.append(r)
            }
            
            receipts = newReceipts
            self.saveReceiptData()
            self.ReceiptCollectionView.reloadData()
            
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func saveReceiptData() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(receipts) {
            do {
                if FileManager.default.fileExists(atPath: saveFileURL.path) {
                    try FileManager.default.removeItem(at: saveFileURL)
                }
                FileManager.default.createFile(atPath: saveFileURL.path, contents: data, attributes: nil)
            } catch {
                fatalError(error.localizedDescription)
            }
        }
    }
    
    func loadReceiptData() -> [Receipt] {
        let decoder = JSONDecoder()
        if let retrieved = try? Data(contentsOf: saveFileURL) {
            do {
                return try decoder.decode([Receipt].self, from: retrieved)
            } catch {
                return [Receipt]()
            }
        }
        return [Receipt]()
    }
    
}

class ReceiptCollectionViewCell: UICollectionViewCell {
    
    var outerIndex = Int()
    @IBOutlet weak var ContainerView: UIView!
    @IBOutlet weak var ReceiptItemTableView: UITableView!
    @IBOutlet weak var StoreNameLabel: UILabel!
    @IBOutlet weak var TotalPriceLabel: UILabel!
    
}

class ReceiptItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ItemNameLabel: UILabel!
    @IBOutlet weak var ItemQtyLabel: UILabel!
    @IBOutlet weak var ItemPriceLabel: UILabel!
    
}

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return receipts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = ReceiptCollectionView.dequeueReusableCell(withReuseIdentifier: "receiptCell", for: indexPath) as! ReceiptCollectionViewCell
        
        cell.ContainerView.layer.cornerRadius = 10
        cell.ContainerView.clipsToBounds = true
        cell.contentView.dropShadow(radius: 5)
        
        cell.StoreNameLabel.text = receipts[indexPath.item].ReceiptStoreName
        cell.TotalPriceLabel.text = "$" + String(receipts[indexPath.item].ReceiptTotal)
        cell.ReceiptItemTableView.delegate = cell
        cell.ReceiptItemTableView.dataSource = cell
        cell.outerIndex = indexPath.item
        cell.ReceiptItemTableView.reloadData()
        
        return cell
    }
    
    
}

extension ViewController: UICollectionViewDelegate {
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (self.view.window?.frame.width ?? UIScreen.main.bounds.width) - 10
        let numberOfItems = CGFloat(receipts[indexPath.item].ReceiptItems.count)
        let height = numberOfItems * (rowHeight) + (86 + 86)
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 80, right: 5)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
}

extension ReceiptCollectionViewCell: UITableViewDelegate {
    
}

extension ReceiptCollectionViewCell: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return receipts[outerIndex].ReceiptItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = ReceiptItemTableView.dequeueReusableCell(withIdentifier: "receiptItemCell", for: indexPath) as! ReceiptItemTableViewCell
        let item = receipts[self.outerIndex].ReceiptItems[indexPath.item]
        
        cell.ItemNameLabel.text = item.ItemName
        cell.ItemQtyLabel.text = String(format: "x%.d", item.ItemQty)
        cell.ItemPriceLabel.text = String(format: "$%.2f", item.ItemSubTotal)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return rowHeight
        
    }
    
}

extension ViewController: NFCNDEFReaderSessionDelegate {
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            // Restart polling in 500 milliseconds.
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag is detected. Please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }
        
        // Connect to the found tag and write an NDEF message to it.
        let tag = tags.first!
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = "Unable to connect to tag."
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                guard error == nil else {
                    session.alertMessage = "Unable to query the NDEF status of tag."
                    session.invalidate()
                    return
                }

                switch ndefStatus {
                case .notSupported:
                    session.alertMessage = "Tag is not NDEF compliant."
                    session.invalidate()
                    
                case .readOnly:
                    session.alertMessage = "Tag is read only."
                    session.invalidate()
                    
                case .readWrite:
                    session.alertMessage = "Reading Reciept..."
                    tag.readNDEF(completionHandler: { (message: NFCNDEFMessage?, error: Error?) in
                        var statusMessage: String
                        if nil != error || nil == message {
                            statusMessage = "Fail to read NDEF from tag"
                        } else {
                            statusMessage = "Found 1 NDEF message"
                            DispatchQueue.main.async {
                                // Process detected NFCNDEFMessage objects.
                                if message != nil {
                                    let records = message!.records
                                    let receiptData = records.first?.payload ?? Data()
                                    
                                    print(receiptData)
                                    
                                    let decoder = JSONDecoder()
                                    if let decodedReceipt = try? decoder.decode(Receipt.self, from: receiptData) {
                                        print(decodedReceipt)
                                    }
                                    
                                    //let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    //let vc = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                                    //vc.modalPresentationStyle = .fullScreen
                                    //self.present(vc, animated: false, completion: nil)
                                    //self.navigationController?.pushViewController(vc, animated: true)
                                    
                                }
                            }
                        }
                        
                        session.alertMessage = statusMessage
                        session.invalidate()
                    })
                @unknown default:
                    session.alertMessage = "Unknown NDEF tag status."
                    session.invalidate()
                }
            })
        })
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Check the invalidation reason from the returned error.
        if let readerError = error as? NFCReaderError {
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                let alertController = UIAlertController(
                    title: "Session Invalidated",
                    message: error.localizedDescription,
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
    }
    
    
}
