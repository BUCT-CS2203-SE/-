import router from '@ohos.router';
import prompt from '@ohos.prompt';

// 定义收藏项的接口
interface FavoriteItem {
  id: number;
  name: string;
  dynasty: string;
  museum: string;
  imageUrl: Resource;
}

@Entry
@Component
struct Favorites {
  @State searchText: string = '';
  @State favorites: FavoriteItem[] = [
    {
      id: 1,
      name: '青花瓷瓶',
      dynasty: '明朝',
      museum: '故宫博物院',
      imageUrl: $r('app.media.cultural_heritage_logo')
    },
    {
      id: 2,
      name: '金缕玉衣',
      dynasty: '汉朝',
      museum: '南京博物院',
      imageUrl: $r('app.media.cultural_heritage_logo')
    },
    // 可以添加更多收藏项
  ];
  @State filteredFavorites: FavoriteItem[] = this.favorites;
  @State isLoading: boolean = false;
  @State showSearch: boolean = false;
  @State currentTab: number = 1; // 0: 展览, 1: 藏品

  // 执行搜索
  performSearch() {
    if (!this.searchText.trim()) {
      this.filteredFavorites = this.favorites;
      return;
    }

    this.isLoading = true;
    // 模拟API调用
    setTimeout(() => {
      this.filteredFavorites = this.favorites.filter(item => 
        item.name.toLowerCase().includes(this.searchText.toLowerCase()) ||
        item.dynasty.toLowerCase().includes(this.searchText.toLowerCase()) ||
        item.museum.toLowerCase().includes(this.searchText.toLowerCase())
      );
      this.isLoading = false;
    }, 500);
  }

  @Builder
  TabBuilder(index: number, name: string, count: number) {
    Column() {
      Text(name + ` (${count})`)
        .fontSize(16)
        .fontColor(this.currentTab === index ? '#8B1A1A' : '#666666')
        .fontWeight(this.currentTab === index ? FontWeight.Bold : FontWeight.Normal)
      
      if (this.currentTab === index) {
        Row()
          .width(24)
          .height(2)
          .backgroundColor('#8B1A1A')
          .margin({ top: 4 })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.currentTab = index;
      // 切换tab时清空搜索
      this.searchText = '';
      this.showSearch = false;
      this.filteredFavorites = this.favorites;
    })
  }

  @Builder
  EmptyStateBuilder() {
    Column() {
      Image($r('app.media.no_result'))
        .width(120)
        .height(120)
        .margin({ top: 100, bottom: 16 })
      
      Text('暂无记录')
        .fontSize(16)
        .fontColor('#999999')
    }
    .width('100%')
    .layoutWeight(1)
  }

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
        
        Text('我的收藏')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        Image($r('app.media.search'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            this.showSearch = !this.showSearch;
            if (!this.showSearch) {
              this.searchText = '';
              this.filteredFavorites = this.favorites;
            }
          })
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 导航栏
      Row() {
        Row() {
          this.TabBuilder(1, '藏品', this.favorites.length)
        }
        .layoutWeight(1)

        Row() {
          this.TabBuilder(0, '朋友圈', 0)
        }
        .layoutWeight(1)
      }
      .width('100%')
      .height(50)
      .backgroundColor('#FFFFFF')
      .padding({ left: 16, right: 16 })
      .border({ width: { bottom: 0.5 }, color: '#E6E6E6' })

      // 搜索框（条件显示）
      if (this.showSearch) {
        Row() {
          TextInput({ placeholder: '搜索收藏的文物', text: this.searchText })
            .width('75%')
            .height(40)
            .backgroundColor('#FFFFFF')
            .placeholderColor('#999999')
            .placeholderFont({ size: 16 })
            .fontSize(16)
            .padding({ left: 12, right: 12 })
            .type(InputType.Normal)
            .textAlign(TextAlign.Start)
            .caretColor('#8B1A1A')
            .border({ width: 1, color: '#8B1A1A', radius: 20 })
            .onChange((value: string) => {
              this.searchText = value;
            })
          
          Button('搜索', { type: ButtonType.Capsule })
            .width('20%')
            .height(40)
            .backgroundColor('#8B1A1A')
            .fontColor('#FFFFFF')
            .margin({ left: 8 })
            .onClick(() => {
              this.performSearch();
            })
        }
        .width('90%')
        .margin({ top: 12, bottom: 12 })
        .padding({ left: 12, right: 12 })
        .backgroundColor('#F5F5F5')
        .borderRadius(20)
      }

      // 加载指示器
      if (this.isLoading) {
        LoadingProgress()
          .width(50)
          .height(50)
          .color('#8B1A1A')
          .margin({ top: 20 })
      }

      // 内容区域
      if (this.currentTab === 0) {
        // 展览页面
        this.EmptyStateBuilder()
      } else {
        // 藏品页面
        if (this.filteredFavorites.length > 0) {
          List() {
            ForEach(this.filteredFavorites, (item: FavoriteItem) => {
              ListItem() {
                Row() {
                  Image(item.imageUrl)
                    .width(100)
                    .height(100)
                    .objectFit(ImageFit.Cover)
                    .borderRadius(8)
                  
                  Column() {
                    Text(item.name)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#333333')
                    
                    Text(item.dynasty)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 8 })
                    
                    Text(item.museum)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 4 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .layoutWeight(1)
                  .margin({ left: 16 })
                }
                .width('100%')
                .padding(16)
                .backgroundColor('#FFFFFF')
                .borderRadius(12)
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/ArtifactDetail',
                    params: { id: item.id }
                  });
                })
              }
              .margin({ bottom: 12 })
            })
          }
          .width('90%')
          .layoutWeight(1)
        } else {
          this.EmptyStateBuilder()
        }
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 