import UIKit
import PKHUD
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let page = Page1()
        self.window!.rootViewController = page
        self.window?.makeKeyAndVisible()
        return true
    }
}
class Page1: UIViewController {
    var count = 0
    var label : UILabel!
    var button1 = UIButton()
    var button2 = UIButton()
    var button3 = UIButton()
    var button4 = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        button1.frame = CGRect(x: 10, y: 100, width: 300, height: 20)
        button1.setTitle("Success",for: .normal)
        button1.addTarget(self, action: #selector(Success(_:)), for: .touchUpInside)
        view.addSubview(button1)
        button2.frame = CGRect(x: 10, y: 130, width: 300, height: 20)
        button2.setTitle("Error",for: .normal)
        button2.addTarget(self, action: #selector(Error(_:)), for: .touchUpInside)
        view.addSubview(button2)
        button3.frame = CGRect(x: 10, y: 160, width: 300, height: 20)
        button3.setTitle("Progress",for: .normal)
        button3.addTarget(self, action: #selector(Progress(_:)), for: .touchUpInside)
        view.addSubview(button3)
        button4.frame = CGRect(x: 10, y: 190, width: 300, height: 20)
        button4.setTitle("Text",for: .normal)
        button4.addTarget(self, action: #selector(Text(_:)), for: .touchUpInside)
        view.addSubview(button4)
    }
    func Success(_ sender: AnyObject) {
        HUD.success("成功了")
        self.present(ScannerViewController(), animated: true)
//        HUD.flash(.labeledSuccess(title: "成功了", subtitle: ""), delay: 1.0)
    }
    func Error(_ sender: AnyObject) {
        HUD.error("出错了", "因此blabla")
    }
    func Progress(_ sender: AnyObject) {
        HUD.show(.progress(title: "装入中..", subtitle: ""))
        delay(1.0) {
            HUD.success("成功了")
        }
    }
    func Text(_ sender: AnyObject) {
        HUD.flash(.label("Requesting Licence…"), delay: 1.0) { _ in
            print("License Obtained.")
        }
    }
    func delay(_ delay: Double, closure:@escaping () -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
}
// for Scan QR code test 
import AVFoundation
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.blue
        captureSession = AVCaptureSession()
        
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed();
            return;
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession);
        previewLayer.frame = view.layer.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        view.layer.addSublayer(previewLayer);
        
        captureSession.startRunning();
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession?.isRunning == false) {
            captureSession.startRunning();
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning();
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject;
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: readableObject.stringValue);
        }
        
        dismiss(animated: true)
    }
    
    func found(code: String) {
        print(code)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
