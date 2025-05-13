@Component
export struct Toast {
  message: string = '';
  duration: number = 2000;
  onClose?: () => void;
  
  @State private isVisible: boolean = false;
  
  aboutToAppear() {
    this.show();
  }
  
  show() {
    this.isVisible = true;
    setTimeout(() => {
      this.hide();
    }, this.duration);
  }
  
  hide() {
    this.isVisible = false;
    setTimeout(() => {
      this.onClose?.();
    }, 300);
  }
  
  build() {
    Column() {
      Text(this.message)
        .fontSize(16)
        .fontColor('#FFD700')
        .backgroundColor('#8B1A1A90')
        .borderRadius(25)
        .padding({ left: 24, right: 24, top: 12, bottom: 12 })
        .borderWidth(1)
        .borderColor('#FFD70040')
        .shadow({
          radius: 10,
          color: '#00000040',
          offsetX: 0,
          offsetY: 4
        })
    }
    .width('100%')
    .position({ x: 0, y: '80%' })
    .opacity(this.isVisible ? 1 : 0)
    .animation({
      duration: 300,
      curve: Curve.EaseInOut
    })
  }
} 