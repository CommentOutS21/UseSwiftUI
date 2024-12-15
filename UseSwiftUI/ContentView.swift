//
//  ContentView.swift
//  UseSwiftUI
//
//  Created by 越智友香 on 2024/12/14.
//

import SwiftUI
import CoreMotion

struct ContentView: View {
    @State private var stage: Int = 0
    @State private var lebel: Int = 30
    // clearしているステージの数
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("三かく関係")
                    .font(.largeTitle)
                
                NavigationLink{
                    ChoosingView(stage: $stage,lebel: $lebel)
                } label :{
                    Text("スタート")
                }
                NavigationLink{
                    TutorialView()
                } label :{
                    Text("チュートリアル")
                }
                NavigationLink{
                    SettinglView(lebel: $lebel)
                } label :{
                    Text("設定")
                }
            }
            .padding()
        }
    }
}

struct TutorialView: View{
    
    @State private var pitch: String = "Pitch: 0.000"
    @State private var roll: String = "Roll: 0.000"
    @State private var yaw: String = "Yaw: 0.000"
    
    @State private var boxX: CGFloat = 650  // "box"の初期x座標
    @State private var boxY: CGFloat = 300  // "box"の初期y座標
    @State private var obj_L: CGFloat = 0.0
    @State private var obj_R: CGFloat = 0.0
    @State private var sight_L: CGFloat = 0.0
    @State private var sight_R: CGFloat = 0.0
    @State private var player: CGFloat = 0.0
    
    private let motionManager = CMMotionManager()
    // チュートリアル画
    @State var start_flag = false
    @State var goal_flag = false
    @State var touch_judge = false
    @State var value = 100.00
    
    
    @Environment(\.dismiss) private var dismiss
    var body: some View{
        ZStack{
            Color.white
                .edgesIgnoringSafeArea(.all)
            if(goal_flag){
                VStack{
                    Text("Clear!!")
                        .foregroundStyle(.yellow)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Button("タイトルに戻る") {
                        dismiss()
                    }
                }
            }
            
            if(!goal_flag){
                
                Group{
                    
                    Image("WatchRange2")
                    GeometryReader { geometry in
                        let frame = geometry.frame(in: .global)
                        // 四つ角の座標を計算
                        let Left = frame.minX
                        let Right = frame.maxX
                        VStack {
//                            Text("range")
//                            Text("Left: \(Left)")
//                            Text("Right: \(Right)")
                            Text("")
                                .onChange(of: Left) {
                                    sight_L = Left
                                    sight_R = Right
                                    print("obj_L : ",obj_L)
                                }
                        }
                        .position(x:0,y:0)
                        .foregroundColor(.black)
                    }                }
                .scaleEffect(x:0.3,y:0.8)
                .position(x:370,y:290)
            Group{
                
                Image("syougaibutsuB")
                GeometryReader { geometry in
                    let frame = geometry.frame(in: .global)
                    
                    let Left = frame.minX
                    let Right = frame.maxX
                    
                    VStack {
//                        Text("obj")
//                        Text("Left: \(Left)")
                        Text("")
                            .onChange(of: Left) {
                                obj_L = Left
                                obj_R = Right
                            }
//                        Text("Right: \(Right)")
                    }
                    .position(x:0,y:0)
                    .foregroundColor(.black)
                }
            }
            .frame(width: 500,height: 500)
            .position(x:boxX,y:boxY)
            .onTapGesture {
                //ココにタップ時の動作
            }
                    Image("enemy")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.27)
                        .position(x:370,y:10)
            }
            
            HStack{
                Rectangle()
                    .frame(height: 3) // 縦線の高さ
                            .rotationEffect(.init(degrees: 90)) // 90度回転
                            .foregroundColor(.black)
            }.position(x:740,y:0)
            Image("ReadtyButton") // ここに画像の名前を指定
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.2)
                    .position(x:680,y:0)
                    .onTapGesture {
                      start_flag = true
                      if(start_flag){
                        startDecreasing()
                      }
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                      // Start motion updates when the view appears
                      startMotionUpdates()
                    }
                    .onDisappear {
                      // Stop motion updates when the view disappears
                      stopMotionUpdates()
                    }
            Group{
                
                Image("player")
                GeometryReader { geometry in
                    let frame = geometry.frame(in: .global)
                    // 四つ角の座標を計算
//                    let left = frame.minX
                    let player_posi = frame.maxX
                    VStack {
                        Text("")
                            .foregroundStyle(.black)
                            .onChange(of: player_posi) {
                                player = player_posi

                            }
                    }
                    .position(x: 0, y: 0)
                }
            }
            .scaleEffect(0.25)
            .position(x: value ,y:290)
            if(touch_judge){
                VStack{
                    Text("Game Over")
                        .foregroundStyle(.red)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Button("タイトルに戻る") {
                        dismiss()
                    }
                }
            }
            
        Text("チュートリアル")
            .position(x:90,y:0)
            .foregroundStyle(.black)
        }
        
    }
    private func startMotionUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1 / 100 // 100Hz
        
        motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
            guard let motion = motion, error == nil else { return }
            
            DispatchQueue.main.async {
                // 傾きの文字列を更新
                self.pitch = String(format: "Pitch: %.3f", motion.attitude.pitch * 180 / .pi)
                self.roll = String(format: "Roll: %.3f", motion.attitude.roll * 180 / .pi)
                self.yaw = String(format: "Yaw: %.3f", motion.attitude.yaw * 180 / .pi)
                
                // ピッチとロールを元に速度を計算
                var speedX = CGFloat(motion.attitude.pitch) * 30
                //var speedY = CGFloat(motion.attitude.roll) * -30
                
                // 制限条件を適用
                if boxX + speedX < 30 || boxX + speedX > 740 {
                    speedX = 0
                }
//                if boxY + speedY < 200 || boxY + speedY > 550 {
//                    speedY = 0
//                }
                
                // 新しい座標を計算
                self.boxX += speedX
//                self.boxY += speedY
            }
        }
    }
    
    private func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
    private func startDecreasing() {
        var gameover_point = 0.0
        stopMotionUpdates()
        // ここでobj_L,obj_R,playerなどの値を比べたい
        if obj_L < 172 && obj_R > 660{
            print("真ん中！！")
        }
        else if obj_L >= 172{
            print("右より")
            gameover_point = 280
        }
        else if obj_R <= 673{
            gameover_point = obj_R
            gameover_point -= 300
        }
//        if 161 < obj_L{
//            //視界の左端座標<障害物の左端座標
//            gameover_point = self.sight_L
//            gameover_point += 20
//        }
//        else if obj_R > 673{
////            sight_R > obj_R
//            gameover_point = 280
//        }
        print("sight_L : ",sight_L)
        print("sight_R : ",sight_R)
        print("obj_L : ",obj_L)
        print("obj_R : ",obj_R)
        
        print("player : ",player)
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) {timer in
            value += 1 // 値を減少
            if gameover_point <= 1.0{
                if value >= 700{
                    timer.invalidate()
                    goal_flag = true
                }
            }
            else{
                if value >= gameover_point{
                    print("value : ",value)
                    timer.invalidate()
                    touch_judge = true
                }
            }
        }
        
    }
    
}
struct ChoosingView:View{
    @Binding var stage: Int
    @Binding  var lebel: Int
    var body: some View{
        HStack(spacing: 100){
            if(stage >= 0){
                
                NavigationLink{
                    firstStageView(stage: $stage,lebel:$lebel)
                } label :{
                    Text("１")
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.blue)
                                .frame(width:100, height: 100)
                        )
                }
            }
            else{
                Text("１")
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.blue)
                            .frame(width:100, height: 100)
                    )
                }
            if(stage >= 1){
                
                NavigationLink{
                    SecondStageView()
                } label :{
                    Text("２")
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(Color.blue)
                                .frame(width:100, height: 100)
                        )
                }
            }
            else{
                Text("２")
                    .foregroundColor(.white)
                    .background(
                        Circle()
                            .fill(Color.gray)
                            .frame(width:100, height: 100)
                    )
            }
            Text("３")
                .foregroundColor(.white)
                .background(
                    Circle()
                        .fill(Color.gray)
                        .frame(width:100, height: 100)
                )
            Text("４")
                .foregroundColor(.white)
                .background(
                    Circle()
                        .fill(Color.gray)
                        .frame(width:100, height: 100)
                )
                .padding(.bottom, 100)
            Text("５")
                .foregroundColor(.white)
                .background(
                    Circle()
                        .fill(Color.gray)
                        .frame(width:100, height: 100)
                )
        }
    }
}

struct firstStageView:View{
    
    @Binding var stage: Int
    @Binding  var lebel: Int
    @State private var pitch: String = "Pitch: 0.000"
    @State private var roll: String = "Roll: 0.000"
    @State private var yaw: String = "Yaw: 0.000"
    
    @State private var fst_boxX: CGFloat = 100  // "box"の初期x座標
    @State private var fst_boxY: CGFloat = 300  // "box"の初期y座標
    @State private var obj_L: CGFloat = 0.0
    @State private var obj_R: CGFloat = 0.0
    @State private var sight_L: CGFloat = 0.0
    @State private var sight_R: CGFloat = 0.0
    @State private var player: CGFloat = 0.0
    
    private let motionManager = CMMotionManager()
    // チュートリアル画
    @State var start_flag = false
    @State var goal_flag = false
    @State var touch_judge = false
    @State var value = 100.00
    
    
    @Environment(\.dismiss) private var dismiss
    var body: some View{
        ZStack{
            Color.white
                .edgesIgnoringSafeArea(.all)
            
            if(goal_flag){
                VStack{
                    Text("Clear!!")
                        .foregroundStyle(.yellow)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .onAppear(){
                            if(stage == 0){
                                stage = 1
                            }
                        }
                    
                    Button("ステージ選択に戻る") {
                        dismiss()
                    }
                }
            }
            
            if(!goal_flag){
                
                Group{
                    
                    Image("WatchRange2")
                    GeometryReader { geometry in
                        let frame = geometry.frame(in: .global)
                        // 四つ角の座標を計算
                        let Left = frame.minX
                        let Right = frame.maxX
                        VStack {
//                            Text("range")
//                            Text("Left: \(Left)")
//                            Text("Right: \(Right)")
                            Text("")
                                .onChange(of: Left) {
                                    sight_L = Left
                                    sight_R = Right
                                    print("obj_L : ",obj_L)
                                }
                        }
                        .position(x:0,y:0)
                        .foregroundColor(.black)
                    }                }
                .scaleEffect(x:0.3,y:0.8)
                .position(x:370,y:290)
            Group{
                
                Image("syougaibutsuB")
                GeometryReader { geometry in
                    let frame = geometry.frame(in: .global)
                    
                    let Left = frame.minX
                    let Right = frame.maxX
                    
                    VStack {
//                        Text("obj")
//                        Text("Left: \(Left)")
                        Text("")
                            .onChange(of: Left) {
                                obj_L = Left
                                obj_R = Right
                            }
//                        Text("obj_R : \(Right)")
                    }
                    .position(x:0,y:0)
                    .foregroundColor(.black)
                }
            }
            .frame(width: 500,height: 500)
            .position(x:fst_boxX,y:fst_boxY)
            .onTapGesture {
                //ココにタップ時の動作
            }
            
                    Image("enemy")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.27)
                        .position(x:370,y:10)
            }
            
            HStack{
                Rectangle()
                    .frame(height: 3) // 縦線の高さ
                            .rotationEffect(.init(degrees: 90)) // 90度回転
                            .foregroundColor(.black)
            }.position(x:740,y:0)
            Image("ReadtyButton") // ここに画像の名前を指定
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.2)
                    .position(x:680,y:0)
                    .onTapGesture {
                      start_flag = true
                      if(start_flag){
                        startDecreasing()
                      }
                    }
                    .buttonStyle(.plain)
                    .onAppear {
                      // Start motion updates when the view appears
                        startMotionUpdates_first()
                    }
                    .onDisappear {
                      // Stop motion updates when the view disappears
                      stopMotionUpdates()
                    }
                    .disabled(start_flag)
            Group{
                
                Image("player")
                GeometryReader { geometry in
                    let frame = geometry.frame(in: .global)
                    // 四つ角の座標を計算
//                    let left = frame.minX
                    let player_posi = frame.maxX
                    VStack {
                        Text("")
                            .foregroundStyle(.black)
                            .onChange(of: player_posi) {
                                player = player_posi

                            }
                    }
                    .position(x: 0, y: 0)
                }
            }
            .scaleEffect(0.25)
            .position(x: value ,y:290)
            if(touch_judge){
                VStack{
                    Text("Game Over")
                        .foregroundStyle(.red)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Button("ステージ選択に戻る") {
                        dismiss()
                    }
                }
            }
            Text("1stStage")
                .position(x:90,y:0)
                .foregroundStyle(.black)
        }
        
    }
    private func startMotionUpdates_first() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1 / 100 // 100Hz
        
        motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
            guard let motion = motion, error == nil else { return }
            
            DispatchQueue.main.async {
                // 傾きの文字列を更新
                self.pitch = String(format: "Pitch: %.3f", motion.attitude.pitch * 180 / .pi)
                self.roll = String(format: "Roll: %.3f", motion.attitude.roll * 180 / .pi)
                self.yaw = String(format: "Yaw: %.3f", motion.attitude.yaw * 180 / .pi)
                
                // ピッチとロールを元に速度を計算
                var speedX = CGFloat(motion.attitude.pitch) * CGFloat(lebel) // + CGFloat(lebel * 100)
                var speedY = CGFloat(motion.attitude.roll) * CGFloat(lebel * -1)  //- CGFloat(lebel * 100)
                
                // 制限条件を適用
                if fst_boxX + speedX < 30 || fst_boxX + speedX > 740 {
                    speedX = 0
                }
                if fst_boxY + speedY < 200 || fst_boxY + speedY > 550 {
                    speedY = 0
                }
                // 新しい座標を計算
                self.fst_boxX += speedX
                self.fst_boxY += speedY
            }
        }
    }
    
    private func stopMotionUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }
    private func startDecreasing() {
        var gameover_point = 0.0
        stopMotionUpdates()
        // ここでobj_L,obj_R,playerなどの値を比べたい
        if obj_L < 172 && obj_R > 660{
            print("真ん中！！")
        }
        else if obj_L >= 172{
            print("右より")
            gameover_point = 280
        }
        else if obj_R <= 673{
            gameover_point = obj_R
            gameover_point -= 300
        }
        print("sight_L : ",sight_L)
        print("sight_R : ",sight_R)
        print("obj_L : ",obj_L)
        print("obj_R : ",obj_R)
        
        print("player : ",player)
        Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) {timer in
            value += 1 // 値を減少
            if gameover_point <= 1.0{
                if value >= 700{
                    timer.invalidate()
                    goal_flag = true
                }
            }
            else{
                if value >= gameover_point{
                    print("value : ",value)
                    timer.invalidate()
                    touch_judge = true
                }
            }
            
        }
        
    }
}

struct SecondStageView:View{
    
    var body: some View{
        Text("未実装です．すみません")
    }
}
struct SettinglView:View{
    @Binding  var lebel: Int
    var body: some View{
        Text("レベル選択")
        Button("鬼"){
            lebel = 300
        }
        Button("ちょいやば"){
            lebel = 100
        }
        Button("普通"){
            lebel = 30
        }
        Button("イライラ"){
            lebel = 2
        }
    }
}
#Preview {
    ContentView()
}
