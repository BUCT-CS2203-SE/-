import router from '@ohos.router';

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

  onSearchChange() {
    if (this.searchText.trim() === '') {
      this.filteredFavorites = this.favorites;
    } else {
      this.filteredFavorites = this.favorites.filter(item => 
        item.name.toLowerCase().includes(this.searchText.toLowerCase()) ||
        item.dynasty.toLowerCase().includes(this.searchText.toLowerCase()) ||
        item.museum.toLowerCase().includes(this.searchText.toLowerCase())
      );
    }
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
        
        Blank().width(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')

      // 搜索框
      Row() {
        Image($r('app.media.search'))
          .width(24)
          .height(24)
          .fillColor('#666666')
          .margin({ right: 8 })
        
        TextInput({ placeholder: '搜索收藏的文物', text: this.searchText })
          .width('85%')
          .height(40)
          .backgroundColor('#F5F5F5')
          .placeholderColor('#999999')
          .placeholderFont({ size: 16 })
          .fontSize(16)
          .padding({ left: 12, right: 12 })
          .type(InputType.Normal)
          .inputFilter('^[\u4E00-\u9FA5A-Za-z0-9]+$')
          .onSubmit((enterKey: EnterKeyType) => {
            this.onSearchChange();
          })
          .onChange((value: string) => {
            this.searchText = value;
            this.onSearchChange();
          })
      }
      .width('90%')
      .margin({ top: 12, bottom: 12 })
      .padding({ left: 12, right: 12 })
      .borderRadius(20)
      .backgroundColor('#F5F5F5')

      // 收藏列表
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
              // TODO: 跳转到文物详情页
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
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 