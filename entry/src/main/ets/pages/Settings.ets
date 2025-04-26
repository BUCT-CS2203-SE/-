import router from '@ohos.router';
import prompt from '@ohos.prompt';

@Entry
@Component
struct Settings {
  build() {
    Column() {
      // 顶部栏
      Row() {
        Image($r('app.media.back'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back();
          })
        
        Text('设置')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Blank().width(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      // 设置选项列表
      Column() {
        // 个人资料设置
        Row() {
          Row() {
            Image($r('app.media.person'))
              .width(24)
              .height(24)
              .fillColor('#666666')
            
            Text('个人资料设置')
              .fontSize(16)
              .fontColor('#333333')
              .margin({ left: 12 })
          }
          .layoutWeight(1)
          
          Image($r('app.media.arrow_right'))
            .width(20)
            .height(20)
            .fillColor('#999999')
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 16 })
        .backgroundColor('#FFFFFF')
        .onClick(() => {
          // TODO: 跳转到个人资料设置页面
          prompt.showToast({ message: '跳转到个人资料设置' })
        })
        
        Divider().color('#F0F0F0').height(1)
        
        // 退出登录
        Button('切换账号/退出', { type: ButtonType.Normal })
          .width('90%')
          .height(50)
          .fontSize(16)
          .fontColor('#FFFFFF')
          .backgroundColor('#8B1A1A')
          .margin({ top: 40 })
          .onClick(() => {
            // TODO: 实现退出登录逻辑
            prompt.showToast({ message: '退出登录成功' });
            router.pushUrl({
              url: 'pages/Login'
            });
          })
      }
      .width('100%')
      .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 