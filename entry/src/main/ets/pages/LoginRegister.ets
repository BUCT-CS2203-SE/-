import { UserService } from '../services/UserService';
import prompt from '@ohos.prompt';
import router from '@ohos.router';

@Entry
@Component
struct LoginRegister {
  @State isLogin: boolean = true; // true为登录页面，false为注册页面
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State email: string = '';
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
  
  validateRegister(): boolean {
    if (!this.username.trim()) {
      this.errorMsg = '用户名不能为空';
      return false;
    }
    if (!this.password) {
      this.errorMsg = '密码不能为空';
      return false;
    }
    if (this.password !== this.confirmPassword) {
      this.errorMsg = '两次输入的密码不一致';
      return false;
    }
    if (!this.email.trim()) {
      this.errorMsg = '邮箱不能为空';
      return false;
    }
    // 简单的邮箱格式验证
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(this.email)) {
      this.errorMsg = '邮箱格式不正确';
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
        // 登录成功后跳转到首页
        router.back();
      })
      .catch((err: Error) => {
        this.isLoading = false;
        this.errorMsg = `登录失败: ${err.message}`;
        prompt.showToast({ message: this.errorMsg });
      });
  }
  
  handleRegister() {
    if (!this.validateRegister()) {
      prompt.showToast({ message: this.errorMsg });
      return;
    }
    
    this.isLoading = true;
    this.userService.register(this.username, this.password, this.email)
      .then((success) => {
        this.isLoading = false;
        if (success) {
          prompt.showToast({ message: '注册成功，请登录' });
          this.isLogin = true;
          this.password = '';
          this.confirmPassword = '';
        }
      })
      .catch((err: Error) => {
        this.isLoading = false;
        this.errorMsg = `注册失败: ${err.message}`;
        prompt.showToast({ message: this.errorMsg });
      });
  }
  
  build() {
    Column() {
      // 顶部栏
      Row() {
        Image($r('app.media.back'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })
        
        Text(this.isLogin ? '登录' : '注册')
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
      
      // Logo区域
      Image($r('app.media.logo'))
        .width(120)
        .height(120)
        .margin({ top: 40, bottom: 40 })
      
      // 切换按钮
      Row() {
        Button({ type: ButtonType.Capsule, stateEffect: true }) {
          Text('登录')
            .fontSize(16)
            .fontColor(this.isLogin ? '#FFFFFF' : '#1698CE')
        }
        .backgroundColor(this.isLogin ? '#1698CE' : '#00000000')
        .width('40%')
        .height(40)
        .onClick(() => {
          this.isLogin = true;
        })
        
        Button({ type: ButtonType.Capsule, stateEffect: true }) {
          Text('注册')
            .fontSize(16)
            .fontColor(!this.isLogin ? '#FFFFFF' : '#1698CE')
        }
        .backgroundColor(!this.isLogin ? '#1698CE' : '#00000000')
        .width('40%')
        .height(40)
        .onClick(() => {
          this.isLogin = false;
        })
      }
      .width('80%')
      .margin({ bottom: 40 })
      
      // 表单区域
      Column() {
        // 用户名输入
        TextInput({ placeholder: '请输入用户名', text: this.username })
          .width('100%')
          .height(50)
          .margin({ bottom: 20 })
          .onChange((value) => {
            this.username = value;
          })
        
        // 密码输入
        TextInput({ placeholder: '请输入密码', text: this.password })
          .width('100%')
          .height(50)
          .type(InputType.Password)
          .margin({ bottom: 20 })
          .onChange((value) => {
            this.password = value;
          })
        
        // 注册时的确认密码输入
        if (!this.isLogin) {
          TextInput({ placeholder: '请确认密码', text: this.confirmPassword })
            .width('100%')
            .height(50)
            .type(InputType.Password)
            .margin({ bottom: 20 })
            .onChange((value) => {
              this.confirmPassword = value;
            })
          
          // 邮箱输入
          TextInput({ placeholder: '请输入邮箱', text: this.email })
            .width('100%')
            .height(50)
            .margin({ bottom: 20 })
            .onChange((value) => {
              this.email = value;
            })
        }
        
        // 登录按钮
        Button(this.isLogin ? '登录' : '注册', { type: ButtonType.Capsule })
          .width('100%')
          .height(50)
          .backgroundColor('#1698CE')
          .margin({ top: 20 })
          .onClick(() => {
            if (this.isLogin) {
              this.handleLogin();
            } else {
              this.handleRegister();
            }
          })
      }
      .width('80%')
      
      // 加载指示器
      if (this.isLoading) {
        LoadingProgress()
          .width(50)
          .height(50)
          .color('#1698CE')
          .margin({ top: 20 })
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
  }
} 