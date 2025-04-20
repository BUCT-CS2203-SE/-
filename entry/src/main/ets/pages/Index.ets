import { Constants } from '../common/constants/Constants';
import router from '@ohos.router';
import { CategoryItem } from '../common/constants/Constants';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;

  build() {
    Column() {
      // 主体内容区域
      Tabs({
        barPosition: BarPosition.End,
        controller: new TabsController()
      }) {
        // 首页Tab
        TabContent() {
          this.buildHomePage()
        }
        .tabBar(this.TabBuilder(0, '首页', 'home'))
        
        // 文物展示Tab
        TabContent() {
          this.buildArtifactsPage()
        }
        .tabBar(this.TabBuilder(1, '文物', 'list'))
        
        // 搜索Tab
        TabContent() {
          this.buildSearchPage()
        }
        .tabBar(this.TabBuilder(2, '搜索', 'search'))
        
        // 我的Tab
        TabContent() {
          this.buildProfilePage()
        }
        .tabBar(this.TabBuilder(3, '我的', 'person'))
      }
      .width('100%')
      .height('100%')
      .barHeight(56)
      .onChange((index) => {
        this.currentIndex = index
      })
    }
    .width('100%')
    .height('100%')
  }
  
  @Builder
  TabBuilder(index: number, title: string, icon: string) {
    Column() {
      Image($r(`app.media.${icon}`))
        .width(24)
        .height(24)
        .fillColor(this.currentIndex === index ? '#1698CE' : '#666666')
      Text(title)
        .fontSize(12)
        .fontColor(this.currentIndex === index ? '#1698CE' : '#666666')
        .margin({ top: 4 })
    }
    .width(56)
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
  
  @Builder
  buildHomePage() {
    Scroll() {
      Column() {
        Text('掌上博物馆')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20, bottom: 20 })
        
        // 轮播图
        Swiper() {
          // 这里可以添加实际的轮播图内容
          Text('轮播图1').width('100%').height(200).backgroundColor('#66CCFF')
          Text('轮播图2').width('100%').height(200).backgroundColor('#6699FF')
          Text('轮播图3').width('100%').height(200).backgroundColor('#66CCCC')
        }
        .autoPlay(true)
        .interval(3000)
        .width('90%')
        .height(200)
        .borderRadius(10)
        .margin({ bottom: 20 })
        
        // 分类区域
        Text('文物分类').fontSize(20).fontWeight(FontWeight.Bold).alignSelf(ItemAlign.Start).margin({ left: 16, top: 10, bottom: 10 })
        Flex({ wrap: FlexWrap.Wrap, justifyContent: FlexAlign.SpaceAround }) {
          ForEach(Constants.ARTIFACT_CATEGORIES, (category: CategoryItem) => {
            Column() {
              // 这里应加入实际的图标
              Image($r('app.media.icon'))
                .width(50)
                .height(50)
                .margin({ bottom: 5 })
              Text(category.name)
                .fontSize(14)
            }
            .width('30%')
            .aspectRatio(1)
            .margin(5)
            .borderRadius(8)
            .backgroundColor('#F5F5F5')
            .justifyContent(FlexAlign.Center)
          })
        }
        .padding(10)
        
        // 推荐文物
        Text('推荐文物').fontSize(20).fontWeight(FontWeight.Bold).alignSelf(ItemAlign.Start).margin({ left: 16, top: 16, bottom: 10 })
        List({ space: 10 }) {
          // 这里应加入实际的文物数据
          ListItem() {
            Row() {
              Image($r('app.media.icon'))
                .width(80)
                .height(80)
                .borderRadius(5)
              Column() {
                Text('青花瓷瓶').fontSize(16).fontWeight(FontWeight.Bold)
                Text('明朝').fontSize(14).margin({ top: 5 })
                Text('大英博物馆').fontSize(14).margin({ top: 5 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 10 })
              .layoutWeight(1)
            }
            .width('100%')
            .padding(10)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
          }
          
          ListItem() {
            Row() {
              Image($r('app.media.icon'))
                .width(80)
                .height(80)
                .borderRadius(5)
              Column() {
                Text('玉器摆件').fontSize(16).fontWeight(FontWeight.Bold)
                Text('清朝').fontSize(14).margin({ top: 5 })
                Text('大都会博物馆').fontSize(14).margin({ top: 5 })
              }
              .alignItems(HorizontalAlign.Start)
              .margin({ left: 10 })
              .layoutWeight(1)
            }
            .width('100%')
            .padding(10)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
          }
        }
        .width('90%')
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F0F0F0')
      .padding({ bottom: 56 })
    }
    .scrollBar(BarState.Off)
    .width('100%')
    .height('100%')
  }
  
  @Builder
  buildArtifactsPage() {
    Column() {
      Text('文物展示').fontSize(24).fontWeight(FontWeight.Bold).margin({ top: 20, bottom: 20 })
      // 这里实现文物展示页面
      Text('文物展示页面内容').fontSize(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
    .padding({ bottom: 56 })
  }
  
  @Builder
  buildSearchPage() {
    Column() {
      Text('文物搜索').fontSize(24).fontWeight(FontWeight.Bold).margin({ top: 20, bottom: 20 })
      // 这里实现搜索页面
      Row() {
        TextInput({ placeholder: '输入关键词搜索文物' })
          .width('80%')
          .height(40)
          .backgroundColor('#FFFFFF')
          .borderRadius(20)
          .padding({ left: 15, right: 15 })
        
        Image($r('app.media.search'))
          .width(24)
          .height(24)
          .margin({ left: 10 })
      }
      .width('90%')
      .margin({ bottom: 20 })
      
      Divider().width('90%').margin({ top: 5, bottom: 5 })
      
      // 图像搜索按钮
      Button('拍照搜索文物', { type: ButtonType.Normal })
        .width('80%')
        .height(50)
        .backgroundColor('#1698CE')
        .margin({ top: 20 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/ImageSearch'
          });
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
    .padding({ bottom: 56 })
  }
  
  @Builder
  buildProfilePage() {
    Column() {
      Text('个人中心').fontSize(24).fontWeight(FontWeight.Bold).margin({ top: 20, bottom: 20 })
      // 这里实现个人中心页面
      Column() {
        // 用户信息区域
        Row() {
          Image($r('app.media.icon'))
            .width(80)
            .height(80)
            .borderRadius(40)
          
          Column() {
            Text('用户名').fontSize(18).fontWeight(FontWeight.Bold)
            Text('点击登录').fontSize(14).margin({ top: 5 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 20 })
        }
        .width('90%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(10)
        .margin({ bottom: 20 })
        .onClick(() => {
          router.pushUrl({
            url: 'pages/LoginRegister'
          });
        })
        
        // 功能区域
        Column() {
          this.buildProfileItem('我的收藏', 'favorite')
          Divider().width('100%').height(1)
          this.buildProfileItem('浏览历史', 'history')
          Divider().width('100%').height(1)
          this.buildProfileItem('我的评论', 'comment')
          Divider().width('100%').height(1)
          this.buildProfileItem('设置', 'settings')
        }
        .width('90%')
        .backgroundColor('#FFFFFF')
        .borderRadius(10)
        .padding(16)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F0F0')
    .padding({ bottom: 56 })
  }
  
  @Builder
  buildProfileItem(title: string, icon: string) {
    Row() {
      Image($r(`app.media.${icon}`))
        .width(24)
        .height(24)
      
      Text(title)
        .fontSize(16)
        .margin({ left: 10 })
        .layoutWeight(1)
      
      Image($r('app.media.arrow_right'))
        .width(24)
        .height(24)
    }
    .width('100%')
    .padding({ top: 12, bottom: 12 })
  }
}