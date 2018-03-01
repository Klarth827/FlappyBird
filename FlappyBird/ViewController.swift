//
//  ViewController.swift
//  FlappyBird
//
//  Created by yuji on 2018/02/16.
//  Copyright © 2018年 yuji. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //SKViewにViewの型を変更する
        let skView = self.view as! SKView
        
        //FPS表示
        skView.showsFPS = true
        
        //nodeの数を表示する
        skView.showsNodeCount = true
        
        //ViewSizeに合わせてシーンを作成する
        let scene = GameScene(size:skView.frame.size)
        
        //ViewにSceneを表示する
        skView.presentScene(scene)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //ステータスバーを消す
    override var prefersStatusBarHidden: Bool{
        get{
            return true
            
        }
        
        //ここまでステータスバーの消去
    }
    
}
