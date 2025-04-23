import { UserService } from '../services/UserService';
import prompt from '@ohos.prompt';
import router from '@ohos.router';

@Entry
@Component
struct Login {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMsg: string = '';
  
  private userService: UserService = new UserService();
  
  validateLogin(): boolean {
    if (!this.username.trim()) {
      this.errorMsg = '用户名不能为空';
      return false;
    }
    if (!this.password) {
      this.errorMsg = '密码不能为空';
      return false;
    }
    return true;
  }
  
  handleLogin() {
    if (!this.validateLogin()) {
      prompt.showToast({ message: this.errorMsg });
      return;
    }
    
    this.isLoading = true;
    this.userService.login(this.username, this.password)
      .then((user) => {
        this.isLoading = false;
        prompt.showToast({ message: '登录成功' });
        router.back();
      })
      .catch((err: Error) => {
        this.isLoading = false;
        this.errorMsg = `登录失败: ${err.message}`;
        prompt.showToast({ message: this.errorMsg });
      });
  }
  
  build() {
    Column() {
      // 背景图片
      Stack() {
        Image($r('app.media.login_bg'))
          .width('100%')
          .height('100%')
          .objectFit(ImageFit.Cover)
        
        // 半透明遮罩层
        Column()
          .width('100%')
          .height('100%')
          .backgroundColor('#00000030')
      }
      .width('100%')
      .height('100%')
      .position({ x: 0, y: 0 })
      .zIndex(-1)
      
      // 顶部栏
      Row() {
        Image($r('app.media.back'))
          .width(24)
          .height(24)
          .fillColor('#FFFFFF')
          .onClick(() => {
            router.back();
          })
        
        Text('登录')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Blank().width(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('transparent')
      
      // Logo区域
      Stack() {
        Image($r('app.media.cultural_heritage_logo'))
          .width(150)
          .height(150)
          .objectFit(ImageFit.Contain)
      }
      .width(150)
      .height(150)
      .margin({ top: 40, bottom: 40 })
      .clip(new Circle({ width: 150, height: 150 }))
      
      // 表单区域
      Column() {
        // 用户名输入
        TextInput({ placeholder: '请输入用户名', text: this.username })
          .width('100%')
          .height(50)
          .backgroundColor('#FFFFFF90')
          .borderRadius(25)
          .placeholderColor('#8B1A1A80')
          .fontColor('#8B1A1A')
          .padding({ left: 20, right: 20 })
          .margin({ bottom: 20 })
          .onChange((value) => {
            this.username = value;
          })
        
        // 密码输入
        TextInput({ placeholder: '请输入密码', text: this.password })
          .width('100%')
          .height(50)
          .backgroundColor('#FFFFFF90')
          .borderRadius(25)
          .placeholderColor('#8B1A1A80')
          .fontColor('#8B1A1A')
          .type(InputType.Password)
          .padding({ left: 20, right: 20 })
          .margin({ bottom: 20 })
          .onChange((value) => {
            this.password = value;
          })
        
        // 登录按钮
        Button('登录', { type: ButtonType.Capsule })
          .width('100%')
          .height(50)
          .backgroundColor('#8B1A1A')
          .fontColor('#FFD700')
          .margin({ top: 20 })
          .onClick(() => {
            this.handleLogin();
          })
          
        // 注册入口
        Text('没有账号？立即注册')
          .fontSize(14)
          .fontColor('#FFD700')
          .margin({ top: 16 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Register'
            });
          })
      }
      .width('80%')
      
      // 加载指示器
      if (this.isLoading) {
        LoadingProgress()
          .width(50)
          .height(50)
          .color('#FFD700')
          .margin({ top: 20 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('transparent')
  }
} 