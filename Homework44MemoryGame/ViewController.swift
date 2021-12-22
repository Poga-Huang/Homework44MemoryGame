//
//  ViewController.swift
//  Homework44MemoryGame
//
//  Created by 黃柏嘉 on 2021/12/22.
//

import UIKit

class ViewController: UIViewController {
    //Label
    @IBOutlet weak var preparationTimeLabel: UILabel!
    @IBOutlet weak var gameTimeLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    //button
    @IBOutlet var cardButtons: [UIButton]!
    //emoji
    var emojiArray = ["😂","😂","😊","😊","🤩","🤩","😭","😭","🥳","🥳","🤯","🤯"]
    //儲存按過的Button
    var pressedButton = [UIButton]()
    //紀錄已經幾對
    var pairs:Int = 0{
        didSet{
        if pairs == 6 {
                //遊戲結束
                timer?.invalidate()
                level += 1
                gameTime = 60-(level*10)
                if level < 5{
                    alert(title: "恭喜！！！", message: "時間內完成遊戲，繼續下一關")
                }else if level == 6{
                    alert(title: "恭喜！！！", message: "完成所有關卡")
                    level = 0
                    gameTime = 60-(level*10)
                }
            }
        }
    }
    //等級
    var level:Int = 0{
        didSet{
            levelLabel.text = "Level \(level+1)"
        }
    }
    //預備時間
    var preparationTime:Int = 5{
        didSet{
            preparationTimeLabel.text = "\(preparationTime)"
        }
    }
    //遊戲時間
    var gameTime:Int = 60{
        didSet{
            gameTimeLabel.text = "\(gameTime)"
        }
    }
    //準備時間
    var timer:Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        gameInit()
        
    }
    //遊戲初始化
    func gameInit(){
       view.bringSubviewToFront(preparationTimeLabel)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDownPreparationTime), userInfo: nil, repeats: true)
        emojiArray.shuffle()
        for (i,Button) in cardButtons.enumerated(){
            Button.setTitle(emojiArray[i], for: .normal)
            Button.alpha = 1
        }
        pairs = 0
    }
    
    //可看牌時間
    @objc func countDownPreparationTime(){
        preparationTime -= 1
        if preparationTime == 0{
            preparationTimeLabel.text = "Start"
            timer?.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countDownGameTime), userInfo: nil, repeats: true)
                self.view.sendSubviewToBack(self.preparationTimeLabel)
                self.preparationTime = 5
                self.preparationTimeLabel.text = ""
            }
            //翻牌動畫
            for (i,Button) in cardButtons.enumerated(){
                Button.setTitle("?", for: .normal)
                UIView.transition(with: cardButtons[i], duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
            }
        }
    }
    //遊戲時間
    @objc func countDownGameTime(){
        if gameTime > 0{
            gameTime -= 1
        }else if gameTime == 0{
            timer?.invalidate()
            gameTime = 60
            alert(title:"喔歐...", message: "遊戲時間到")
        }
    }
    //翻牌
    @IBAction func flipCard(_ sender: UIButton) {
        if sender.title(for: .normal) == "?"{
            //改變按鈕畫面
            sender.setTitle(emojiArray[sender.tag], for: .normal)
            UIView.transition(with: sender, duration: 0.5, options: .transitionFlipFromRight, animations: nil, completion: nil)
            //將按過的button加入陣列
            pressedButton.append(sender)
            //若有已經有兩個就檢查
            if pressedButton.count == 2{
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    self.checkCard(buttons: self.pressedButton)
                    self.pressedButton.removeAll()
                }
            }
        }
    }
    //檢查兩張卡片
    func checkCard(buttons:[UIButton]){
        if buttons[0].title(for:.normal) == buttons[1].title(for: .normal){
            for button in buttons {
                UIView.animate(withDuration: 1) {
                    button.alpha = 0
                }
            }
            pairs += 1
        }else{
            for (i,Button) in buttons.enumerated(){
                Button.setTitle("?", for: .normal)
                UIView.transition(with: buttons[i], duration: 0.5, options: .transitionFlipFromLeft, animations: nil, completion: nil)
            }
        }
    }
    //通知使用者
    func alert(title:String,message:String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart", style: .default) { restartAction in
            alert.dismiss(animated: true) {
                self.gameInit()
            }
        }
        alert.addAction(restartAction)
        present(alert, animated: true, completion: nil)
    }
    
}

