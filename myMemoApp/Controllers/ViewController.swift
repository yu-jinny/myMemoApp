import UIKit

class ViewController: UIViewController {
    
    // 이미지를 표시할 UIImageView 선언
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 이미지 뷰를 뷰 계층에 추가
        view.addSubview(imageView)
        
        // 이미지 뷰의 제약 조건 설정
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 60),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        // 이미지 다운로드 및 표시 함수 호출
        loadImageFromURL()
    }
    
    func loadImageFromURL() {
        // 이미지를 다운로드할 URL
        let imageURL = URL(string: "https://spartacodingclub.kr/css/images/scc-og.jpg")
        
        // 이미지 다운로드를 위한 비동기 큐 생성
        DispatchQueue.global().async {
            do {
                // 데이터를 다운로드
                let imageData = try Data(contentsOf: imageURL!)
                
                // 다운로드한 데이터를 사용하여 UIImage 생성 (Main Thread에서 업데이트해야 하므로 DispatchQueue.main.async 사용)
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: imageData)
                }
            } catch {
                // 에러 처리
                print("이미지 다운로드 에러: \(error.localizedDescription)")
            }
        }
    }
}
