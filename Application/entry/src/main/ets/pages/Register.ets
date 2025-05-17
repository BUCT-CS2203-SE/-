import { UserService } from '../services/UserService';
import router from '@ohos.router';
import { Toast } from '../components/Toast';

@Entry
@Component
struct Register {
  @State username: string = '';
  @State password: string = '';
  @State confirmPassword: string = '';
  @State email: string = '';
  @State isLoading: boolean = false;
  @State errorMsg: string = '';
  @State showToast: boolean = false;
  @State toastMessage: string = '';

  private userService: UserService = new UserService();

  validateRegister(): boolean {
    if (!this.username.trim()) {
      this.errorMsg = '电话号不能为空';
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
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(this.email)) {
      this.errorMsg = '邮箱格式不正确';
      return false;
    }
    return true;
  }

  handleRegister() {
    if (!this.validateRegister()) {
      this.toastMessage = this.errorMsg;
      this.showToast = true;
      return;
    }

    console.info('开始注册流程...');
    this.isLoading = true;
    this.userService.register(this.username, this.password, this.email)
      .then((response) => {
        console.info(`注册成功，响应: ${JSON.stringify(response)}`);
        this.isLoading = false;

        try {
          // 显示注册成功提示
          console.info('显示注册成功提示...');
          this.toastMessage = '注册成功，请登录';
          this.showToast = true;

          // 直接跳转到登录页面
          console.info('准备跳转到登录页面...');
          router.pushUrl({
            url: 'pages/Login',
            params: {
              phone: this.username // 传递手机号到登录页面
            }
          });
        } catch (error) {
          console.error('UI操作失败:', error);
          // 如果UI操作失败，至少尝试导航
          router.pushUrl({
            url: 'pages/Login',
            params: {
              phone: this.username
            }
          });
        }
      })
      .catch((error: Error) => {
        console.error(`注册失败: ${error.message}`);
        this.isLoading = false;
        this.errorMsg = '注册失败，请稍后重试';
        this.toastMessage = this.errorMsg;
        this.showToast = true;
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

        Text('注册')
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

        // 确认密码输入
        TextInput({ placeholder: '请确认密码', text: this.confirmPassword })
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
            this.confirmPassword = value;
          })

        // 邮箱输入
        TextInput({ placeholder: '请输入邮箱', text: this.email })
          .width('100%')
          .height(50)
          .backgroundColor('#FFFFFF90')
          .borderRadius(25)
          .placeholderColor('#8B1A1A80')
          .fontColor('#8B1A1A')
          .padding({ left: 20, right: 20 })
          .margin({ bottom: 20 })
          .onChange((value) => {
            this.email = value;
          })

        // 注册按钮
        Button('注册', { type: ButtonType.Capsule })
          .width('100%')
          .height(50)
          .backgroundColor('#8B1A1A')
          .fontColor('#FFD700')
          .margin({ top: 20 })
          .onClick(() => {
            this.handleRegister();
          })

        // 返回登录
        Text('已有账号？返回登录')
          .fontSize(14)
          .fontColor('#FFD700')
          .margin({ top: 16 })
          .onClick(() => {
            router.back();
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