import { UserService } from '../services/UserService';
import router from '@ohos.router';
import { Toast } from '../components/Toast';
import { User } from '../model/UserModel';

@Entry
@Component
struct Login {
  @State username: string = '';
  @State password: string = '';
  @State isLoading: boolean = false;
  @State errorMsg: string = '';
  @State usernameError: boolean = false;
  @State passwordError: boolean = false;
  @State showToast: boolean = false;
  @State toastMessage: string = '';
  
  private userService: UserService = new UserService();
  
  aboutToAppear(): void {
    // 获取路由参数
    const params = router.getParams() as Record<string, string>;
    if (params && params.phone) {
      this.username = params.phone;
    }
  }
  
  validateLogin(): boolean {
    let isValid: boolean = true;
    this.usernameError = false;
    this.passwordError = false;
    
    if (!this.username.trim()) {
      this.errorMsg = '用户不存在或密码错误';
      this.usernameError = true;
      isValid = false;
    }
    if (!this.password) {
      this.errorMsg = '用户不存在或密码错误';
      this.passwordError = true;
      isValid = false;
    }
    return isValid;
  }
  
  handleLogin(): void {
    if (!this.validateLogin()) {
      this.toastMessage = this.errorMsg;
      this.showToast = true;
      return;
    }
    
    console.info('开始登录流程...');
    this.isLoading = true;
    this.errorMsg = ''; // 清除之前的错误信息
    this.usernameError = false;
    this.passwordError = false;
    
    this.userService.login(this.username, this.password)
      .then((user: User) => {
        console.info(`登录成功，用户信息: ${JSON.stringify(user)}`);
        this.isLoading = false;
        
        try {
          // 显示登录成功提示
          console.info('显示登录成功提示...');
          this.toastMessage = '登录成功';
          this.showToast = true;
          
          // 直接跳转到首页
          console.info('准备跳转到首页...');
          router.pushUrl({
            url: 'pages/Index'
          });
        } catch (error) {
          console.error('UI操作失败:', error);
          // 如果UI操作失败，至少尝试导航
          router.pushUrl({
            url: 'pages/Index'
          });
        }
      })
      .catch((error: Error) => {
        console.error(`登录失败: ${error.message}`);
        this.isLoading = false;
        
        // 统一显示错误信息
        this.errorMsg = '用户不存在或密码错误';
        this.toastMessage = this.errorMsg;
        this.showToast = true;
        
        // 设置输入框错误状态
        this.usernameError = true;
        this.passwordError = true;
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
        TextInput({ placeholder: '请输入电话号', text: this.username })
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
      
      // 添加 Toast 组件
      if (this.showToast) {
        Toast({
          message: this.toastMessage,
          duration: 2000,
          onClose: () => {
            this.showToast = false;
          }
        })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('transparent')
  }
} 