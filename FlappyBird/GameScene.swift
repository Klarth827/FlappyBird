//
//  GameScene.swift
//  FlappyBird
//
//  Created by yuji on 2018/02/16.
//  Copyright © 2018年 yuji. All rights reserved.
//

import Foundation
import SpriteKit
import AVFoundation //課題追加

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    var scrollNode:SKNode!
    var wallNode:SKNode! //追加
    var bird:SKSpriteNode! //追加
    var itemNode:SKNode! //課題追加
    
    //衝突判定カテゴリー
    let birdCategory: UInt32 = 1 << 0 //0...00001
    let groundCategory: UInt32 = 1 << 1 // 0...00010
    let wallCategory: UInt32 = 1 << 2 //0...00100
    let scoreCategory: UInt32 = 1 << 3 //0...01000
    let itemCategory: UInt32 = 1 << 4 //課題追加
    
    //効果音
    let itemSe = SKAction.playSoundFileNamed("shot1.mp3",waitForCompletion: false)

    
    //スコア用
    var score = 0
    var itemScore = 0 //課題追加
    
    let userDefaults: UserDefaults = UserDefaults.standard
    
    var scoreLabelNode:SKLabelNode!
    
    var bestScoreLabelNode:SKLabelNode!
    
    var itemScoreLabelNode:SKLabelNode! //課題追加
    
    //SKView上にシーンが表示された時に呼ばれるメソッド
    override func didMove (to view: SKView){
        
        //重力を設定
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -4.0) //
        physicsWorld.contactDelegate = self
        
        //背景色を設定
        backgroundColor = UIColor(colorLiteralRed: 0.15,green: 0.75, blue:0.90,alpha:1)
        
        //スクロールするスプライトの親ノード
        
        scrollNode = SKNode()
        addChild(scrollNode)
        
        //壁用のノード
        wallNode = SKNode()
        scrollNode.addChild(wallNode)
        
        //itemのノード
        itemNode = SKNode()
        scrollNode.addChild(itemNode)
        
        //各種スプライトを生成する処理をメソッドに分割
        setupGround()
        setupCloud()
        setupWall()
        setupBird()
        setupItem() //課題追加
        
        setupScoreLabel()
        
    }
    
    
    func setupGround(){
        
        //地面の画像を読み込む
        let groundTexture = SKTexture(imageNamed:"ground")
        groundTexture.filteringMode = SKTextureFilteringMode.nearest
        
        //必要な枚数を計算
        let needNumber = 2.0 + (frame.size.width / groundTexture.size().width)
        
        //スクロールするアクションを作成
        //左方向に画像一枚文スクロールさせるアクション
        let moveGround = SKAction.moveBy(x: -groundTexture.size().width , y: 0, duration: 5.0)
        
        //元の位置に戻すアクション
        let resetGround = SKAction.moveBy(x: groundTexture.size().width, y:0, duration:0.0)
        
        //左にスクロールー>元の位置ー＞左にスクロールと無限に繰り返すアクション
        let repeatScrollGround = SKAction.repeatForever(SKAction.sequence([moveGround, resetGround]))
        
        //Groundのスプライトを配置する forEach要確認
        stride(from: 0.0, to: needNumber, by:1.0).forEach{ i in
            let sprite = SKSpriteNode(texture: groundTexture)
            
            //テクスチャを指定してスプライトを作成する->メソッド分割時に消えた
            //let groundSprite = SKSpriteNode(texture:groundTexture)
            
            
            //スプライトの表示する位置を指定する->メソッド分割時　groundSprite.がspriteに変更された
            
            sprite.position = CGPoint(x: i * size.width / 2, y: groundTexture.size().height / 2)
            
            //スプライトにアクションを設定する
            sprite.run(repeatScrollGround)
            
            //スプライトに物理演算を設定する
            sprite.physicsBody = SKPhysicsBody(rectangleOf: groundTexture.size())
            
            //衝突のカテゴリー実装
            sprite.physicsBody?.categoryBitMask = groundCategory
            
            //衝突の時に動かないようにする
            sprite.physicsBody?.isDynamic = false //
            
            //スプライトを追加する　->Viewにはっつけ
            scrollNode.addChild(sprite)
        }
        
    }
    
    func setupCloud(){
        
        //雲の画像を読み込む
        let cloudTexture = SKTexture(imageNamed:"cloud")
        cloudTexture.filteringMode = SKTextureFilteringMode.nearest
        
        //必要な枚数を計算
        let needCloudNumber = 2.0 + (frame.size.width / cloudTexture.size().width)
        
        //スクロールするアクションを作成
        //左方向に画像一枚文スクロールさせるアクション
        let moveCloud = SKAction.moveBy(x: -cloudTexture.size().width , y: 0, duration: 20.0)
        
        //元の位置に戻すアクション
        let resetCloud = SKAction.moveBy(x: cloudTexture.size().width, y:0, duration:0.0)
        
        //左にスクロールー>元の位置ー＞左にスクロールと無限に繰り返すアクション
        let repeatScrollCloud = SKAction.repeatForever(SKAction.sequence([moveCloud, resetCloud]))
        
        //Cloudスプライトを配置する
        stride(from: 0.0, to: needCloudNumber, by:1.0).forEach{ i in
            let sprite = SKSpriteNode(texture: cloudTexture)
            //一番後ろになるようにする
            sprite.zPosition = -100
            
            //スプライトの表示する位置を指定する(特にクラス指定がなければView.size?)
            sprite.position = CGPoint(x: i * sprite.size.width , y: size.height - cloudTexture.size().height / 2)
            
            //スプライトにアクションを設定する
            sprite.run(repeatScrollCloud)
            
            //スプライトを追加する　->Viewにはっつけ
            scrollNode.addChild(sprite)
        }
        
    }
    
    func setupWall(){
        
        //壁の画像を読み込む
        let wallTexture = SKTexture(imageNamed: "wall")
        wallTexture.filteringMode = SKTextureFilteringMode.linear
        
        //移動する距離を計算 self指定している意味.Pointはクラス指定なんで？
        let movingDistance = CGFloat(self.frame.size.width + wallTexture.size().width)
        
        //画面外まで移動するアクションを追加
        let moveWall = SKAction.moveBy(x: -movingDistance, y:0, duration:4.0)
        
        //自身を取り除くアクションを追加
        let removeWall = SKAction.removeFromParent()
        
        //２つのアニメショーンを順に実行するアクションを作成
        let wallAnimation = SKAction.sequence([moveWall, removeWall])
        
        //壁を生成するアクションを作成
        let createWallAnimation = SKAction.run({
            
            //壁関連のノードを乗せるノードを作成
            let wall = SKNode()
            wall.position = CGPoint(x: self.frame.size.width + wallTexture.size().width / 2, y: 0.0)
            
            wall.zPosition = -50.0 // 雲より手前、地面より奥
            
            //画面のY軸の中央値
            let center_y = self.frame.size.height / 2
            
            //壁のY座標を上下ランダムにさせる時の最大値
            let random_y_range = self.frame.size.height / 4
            
            //下の壁のY軸の下限
            let under_wall_lowest_y = UInt32( center_y - wallTexture.size().height / 2 - random_y_range / 2)
            
            //１〜random_y_rangeまでのランダムな整数を生成
            let random_y = arc4random_uniform( UInt32(random_y_range) )
            
            //Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_wall_y = CGFloat(under_wall_lowest_y + random_y)
            
            //キャラが通り抜ける時の隙間の長さ
            let slit_length = self.frame.size.height / 6
            
            //下側の壁を作成
            let under = SKSpriteNode(texture :wallTexture)
            under.position = CGPoint(x: 0.0, y: under_wall_y)
            wall.addChild(under)
            
            //下の壁に物理演算を設定する
            under.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            under.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突時に動かないように設定する
            under.physicsBody?.isDynamic = false
            
            //上側の壁を作成
            let upper = SKSpriteNode(texture: wallTexture)
            upper.position = CGPoint(x: 0.0, y: under_wall_y + wallTexture.size().height + slit_length)
            
            //上の壁に物理演算を設定する
            upper.physicsBody = SKPhysicsBody(rectangleOf: wallTexture.size())
            upper.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突時に動かないように設定する
            upper.physicsBody?.isDynamic = false
            
            //ここからスコアアップ用の見えない壁作成
            let scoreNode = SKNode()
            scoreNode.position = CGPoint(x: upper.size.width + self.bird.size.width / 2, y: self.frame.height / 2.0)
            
            scoreNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: upper.size.width, height: self.frame.size.height))
            
            scoreNode.physicsBody?.isDynamic = false
            scoreNode.physicsBody?.categoryBitMask = self.scoreCategory
            scoreNode.physicsBody?.contactTestBitMask = self.birdCategory
            
            wall.addChild(scoreNode)
            //ここまでスコアアップ用の見えない壁
            
            wall.addChild(upper)
            
            wall.run(wallAnimation)
            
            self.wallNode.addChild(wall)
        })
        
        //次の壁作成までの待ち時間アクションを作成
        let waitAnimation = SKAction.wait(forDuration: 2)
        
        //壁を作成->待ち時間->壁を作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createWallAnimation, waitAnimation]))
        
        wallNode.run(repeatForeverAnimation)
        
    }
    
    func setupBird(){
        //鳥の二つの画像を読み込む
        let birdTextureA = SKTexture(imageNamed: "bird_a")
        birdTextureA.filteringMode = SKTextureFilteringMode.linear
        
        let birdTextureB = SKTexture(imageNamed: "bird_b")
        birdTextureB.filteringMode = SKTextureFilteringMode.linear
        
        //2種類のテクスチャを交互に変更するアニメーションを作成
        let texturesAnimation = SKAction.animate(with: [birdTextureA, birdTextureB], timePerFrame: 0.2)
        
        let flap = SKAction.repeatForever(texturesAnimation)
        
        //スプライトを作成
        
        bird = SKSpriteNode(texture: birdTextureA)
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        
        //物理演算を設定
        bird.physicsBody = SKPhysicsBody(circleOfRadius: bird.size.height / 2.0)
        
        //衝突した時に回転させない
        bird.physicsBody?.allowsRotation = false
        
        //衝突カテゴリーの設定
        bird.physicsBody?.categoryBitMask = birdCategory
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.physicsBody?.contactTestBitMask = groundCategory | wallCategory
        
        
        //アニメーションを設定
        bird.run(flap)
        
        //スプライトを追加する
        addChild(bird)
        
    }
    
    func setupItem(){
        
        //itemの画像を読み込む
        let itemTexture = SKTexture(imageNamed: "item_a")
        itemTexture.filteringMode = SKTextureFilteringMode.linear
        
        //移動する距離を計算
        let movingDistance = CGFloat(self.frame.size.width + itemTexture.size().width)
        
        //画面外まで移動するアクションを追加
        let moveItem = SKAction.moveBy(x: -movingDistance, y:0, duration:4.0)
        
        //自身を取り除くアクションを追加
        let removeItem = SKAction.removeFromParent()
        
        //２つのアニメショーンを順に実行するアクションを作成
        let itemAnimation = SKAction.sequence([moveItem, removeItem])
        
        //生成するアクションを作成
        let createItemAnimation = SKAction.run({
            
            //関連のノードを乗せるノードを作成
            let itemOn = SKNode()
            itemOn.position = CGPoint(x: self.frame.size.width + itemTexture.size().width / 2, y: 0.0)
            
            itemOn.zPosition = -51.0 // 雲より手前、地面より奥
            
            //画面のY軸の中央値
            let center_y = self.frame.size.height
            
            //Y座標を上下ランダムにさせる時の最大値
            let random_y_range = self.frame.size.height
            
            //下のY軸の下限
            let under_item_lowest_y = UInt32( center_y - itemTexture.size().height / 2 - random_y_range / 2)
            
            //１〜random_y_rangeまでのランダムな整数を生成
            let random_y = arc4random_uniform( UInt32(random_y_range) )
            
            //Y軸の下限にランダムな値を足して、下の壁のY座標を決定
            let under_item_y = CGFloat(under_item_lowest_y + random_y)
            
            //作成
            let item01 = SKSpriteNode(texture :itemTexture)
            item01.position = CGPoint(x: 0.0, y: under_item_y)
            
            //物理演算を設定する
            item01.physicsBody = SKPhysicsBody(circleOfRadius: item01.size.height / 2 )
            item01.physicsBody?.categoryBitMask = self.wallCategory
            
            //衝突時に動かないように設定する
            item01.physicsBody?.isDynamic = false
            item01.physicsBody?.categoryBitMask = self.itemCategory
            item01.physicsBody?.contactTestBitMask = self.birdCategory
            
            itemOn.addChild(item01)
            
            itemOn.run(itemAnimation)
            
            self.itemNode.addChild(itemOn)
            self.itemNode.isHidden = false
        })
        
        //次の作成までの待ち時間アクションを作成
        let waitAnimation = SKAction.wait(forDuration: 5)
        
        //作成->待ち時間->作成を無限に繰り返すアクションを作成
        let repeatForeverAnimation = SKAction.repeatForever(SKAction.sequence([createItemAnimation, waitAnimation]))
        
        itemNode.run(repeatForeverAnimation)
        
        
    }
    
    
    //画面をタップした時に呼ばれる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        
        if scrollNode.speed > 0 {
            
            
            //鳥の速度を０にする
            bird.physicsBody?.velocity = CGVector.zero
            
            //鳥に縦方向の力を与える
            bird.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 15))
            
        }else if bird.speed == 0 {
            restart()
        }
    }
    
    
    //SKPhysicsContactDelegateのメソッド。衝突時に呼ばれる
    func didBegin(_ contact: SKPhysicsContact){
        //ゲームオーバーの時には何もしない
        if scrollNode.speed <= 0{
            return
        }
        
        if( contact.bodyA.categoryBitMask & scoreCategory) == scoreCategory || (contact.bodyB.categoryBitMask & scoreCategory) == scoreCategory {
            //スコア用の物体と衝突した
            print("ScoreUp")
            score += 1
            scoreLabelNode.text = "Score:\(score)"
            
            //ベストスコア更新か確認する
            var bestScore = userDefaults.integer(forKey: "BEST" )
            if score > bestScore {
                bestScore = score
                
                bestScoreLabelNode.text = "BestScore:\(bestScore)"
                
                userDefaults.set(bestScore, forKey: "BEST" )
                userDefaults.synchronize()
            }
            
        }else {
            if( contact.bodyA.categoryBitMask & itemCategory) == itemCategory || (contact.bodyB.categoryBitMask & itemCategory) == itemCategory {
                //item用の物体と衝突した
                print("itemScoreUp")
                itemScore += 1
                itemScoreLabelNode.text = "itemScore:\(itemScore)"
                self.run(itemSe)
                self.itemNode.isHidden = true
                
            }else {
                
                //壁か地面と衝突した
                
                print("GameOver")
                
                //スクロールを停止させる
                scrollNode.speed = 0
                
                bird.physicsBody?.collisionBitMask = groundCategory
                
                let roll = SKAction.rotate(byAngle: CGFloat(Double.pi) * CGFloat(bird.position.y) * 0.01, duration:1)
                
                bird.run(roll, completion:{
                    self.bird.speed = 0
                })
            }
        }
    }
    
    //リスタート処理
    func restart(){
        score = 0
        scoreLabelNode.text = String("score:\(score)")
        
        itemScore = 0 //課題追加
        itemScoreLabelNode.text = String("itemscore:\(itemScore)") //課題追加
        
        bird.position = CGPoint(x: self.frame.size.width * 0.2, y:self.frame.size.height * 0.7)
        bird.physicsBody?.velocity = CGVector.zero
        bird.physicsBody?.collisionBitMask = groundCategory | wallCategory
        bird.zRotation = 0.0
        
        wallNode.removeAllChildren()
        
        bird.speed = 1
        
        scrollNode.speed = 1
    }
    
    func setupScoreLabel(){
        
        score = 0
        scoreLabelNode = SKLabelNode()
        scoreLabelNode.fontColor = UIColor.black
        scoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 30)
        scoreLabelNode.zPosition = 100 //一番手前
        scoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabelNode.text = "Score:\(score)"
        self.addChild(scoreLabelNode)
        
        
        bestScoreLabelNode = SKLabelNode()
        bestScoreLabelNode.fontColor = UIColor.black
        bestScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 60)
        bestScoreLabelNode.zPosition = 100 //一番手前
        bestScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        
        let bestScore = userDefaults.integer(forKey: "BEST")
        bestScoreLabelNode.text = "Best Score:\(bestScore)"
        self.addChild(bestScoreLabelNode)
        
        //課題追加
        itemScoreLabelNode = SKLabelNode()
        itemScoreLabelNode.fontColor = UIColor.black
        itemScoreLabelNode.position = CGPoint(x: 10, y: self.frame.size.height - 90)
        itemScoreLabelNode.zPosition = 100 //一番手前
        itemScoreLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        itemScoreLabelNode.text = "Score:\(itemScore)"
        self.addChild(itemScoreLabelNode)
        //課題追加
        
    }
}
