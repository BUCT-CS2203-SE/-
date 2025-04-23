import { Constants } from '../common/constants/Constants';
import router from '@ohos.router';
import { CategoryItem } from '../common/constants/Constants';
import { Artifact } from '../model/ArtifactModel';
import { ArtifactService } from '../services/ArtifactService';
import prompt from '@ohos.prompt';

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @State searchKeyword: string = '';
  @State searchResults: Artifact[] = [];
  @State isLoading: boolean = false;
  private artifactService: ArtifactService = new ArtifactService();

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
    Stack() {
      // 背景图片
      Image($r('app.media.background2'))
        .width('100%')
        .height('100%')
        .objectFit(ImageFit.Cover)
        .opacity(0.1)

      Column() {
        Text('文物搜索')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .fontColor('#8B0000')  // 深红色
          .margin({ top: 20, bottom: 20 })
        
        // 搜索框
        Row() {
          TextInput({ placeholder: '输入关键词搜索文物' })
            .width('80%')
            .height(40)
            .backgroundColor('#FFFFFF')
            .borderRadius(20)
            .padding({ left: 15, right: 15 })
            .borderColor('#8B0000')
            .borderWidth(1)
            .onChange((value: string) => {
              this.searchKeyword = value;
            })
          
          Image($r('app.media.search'))
            .width(24)
            .height(24)
            .margin({ left: 10 })
            .fillColor('#8B0000')  // 深红色
            .onClick(() => {
              this.performSearch();
            })
        }
        .width('90%')
        .margin({ bottom: 20 })
        
        Divider()
          .width('90%')
          .color('#8B0000')  // 深红色
          .margin({ top: 5, bottom: 5 })
        
        // 图像搜索按钮
        Button('拍照搜索文物', { type: ButtonType.Normal })
          .width('80%')
          .height(50)
          .backgroundColor('#8B0000')  // 深红色
          .fontColor('#FFFFFF')
          .borderRadius(25)
          .margin({ top: 20 })
          .onClick(() => {
            router.pushUrl({
              url: 'pages/ImageSearch'
            });
          })
        
        // 搜索结果区域
        if (this.isLoading) {
          Column() {
            LoadingProgress()
              .width(50)
              .height(50)
              .color('#8B0000')  // 深红色
              .margin({ bottom: 20 })
            
            Text('正在搜索中...')
              .fontSize(18)
              .fontColor('#8B0000')  // 深红色
              .margin({ bottom: 10 })
            
            Text('请稍候，我们正在为您查找相关文物')
              .fontSize(14)
              .fontColor('#666666')
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#FFFFFF')
          .borderRadius(15)
          .shadow({ radius: 3, color: '#8B0000', offsetX: 0, offsetY: 2 })
          .margin({ top: 20 })
        } else if (this.searchResults.length > 0) {
          Text('搜索结果')
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#8B0000')  // 深红色
            .alignSelf(ItemAlign.Start)
            .margin({ left: '5%', top: 20, bottom: 10 })
          
          List({ space: 10 }) {
            ForEach(this.searchResults, (artifact: Artifact) => {
              ListItem() {
                Row() {
                  Image(artifact.imageUrl || $r('app.media.placeholder'))
                    .width(100)
                    .height(100)
                    .borderRadius(10)
                    .objectFit(ImageFit.Cover)
                    .border({ width: 1, color: '#8B0000' })  // 深红色边框
                  
                  Column() {
                    Text(artifact.name)
                      .fontSize(18)
                      .fontWeight(FontWeight.Bold)
                      .fontColor('#8B0000')  // 深红色
                    
                    Text(artifact.era)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 5 })
                    
                    Text(artifact.museum)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ top: 5 })
                  }
                  .alignItems(HorizontalAlign.Start)
                  .margin({ left: 15 })
                  .layoutWeight(1)
                }
                .width('100%')
                .padding(15)
                .backgroundColor('#FFFFFF')
                .borderRadius(15)
                .border({ width: 1, color: '#8B0000' })  // 深红色边框
                .shadow({ radius: 3, color: '#8B0000', offsetX: 0, offsetY: 2 })
                .onClick(() => {
                  router.pushUrl({
                    url: 'pages/ArtifactDetail',
                    params: { artifactId: artifact.id }
                  });
                })
              }
            })
          }
          .width('90%')
          .layoutWeight(1)
        } else if (this.searchKeyword) {
          Column() {
            Image($r('app.media.no_result'))
              .width(100)
              .height(100)
              .margin({ bottom: 16 })
              .fillColor('#8B0000')  // 深红色
              
            Text('抱歉，未找到相关文物')
              .fontSize(18)
              .fontColor('#8B0000')  // 深红色
              .margin({ bottom: 10 })
            
            Text('请尝试使用其他关键词进行搜索')
              .fontSize(14)
              .fontColor('#666666')
          }
          .width('100%')
          .height(200)
          .justifyContent(FlexAlign.Center)
          .backgroundColor('#FFFFFF')
          .borderRadius(15)
          .border({ width: 1, color: '#8B0000' })  // 深红色边框
          .shadow({ radius: 3, color: '#8B0000', offsetX: 0, offsetY: 2 })
          .margin({ top: 20 })
        }
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF5F5')  // 浅红色背景
    .padding({ bottom: 56 })
  }
  
  private performSearch(): void {
    if (!this.searchKeyword.trim()) {
      prompt.showToast({ message: '请输入搜索关键词' });
      return;
    }
    
    this.isLoading = true;
    this.artifactService.searchByKeyword(this.searchKeyword)
      .then((artifacts: Artifact[]) => {
        this.searchResults = artifacts;
        this.isLoading = false;
      })
      .catch((error: Error) => {
        this.isLoading = false;
        prompt.showToast({ message: `搜索失败: ${error.message}` });
      });
  }
  
  @Builder
  buildProfileItem(title: string, icon: string) {
    Row() {
      Row() {
        // 左侧图标
        Image($r(`app.media.${icon}`))
          .width(24)
          .height(24)
          .fillColor('#666666')
        
        // 标题文字
        Text(title)
          .fontSize(16)
          .fontColor('#333333')
          .margin({ left: 12 })
      }
      .layoutWeight(1)
      .alignItems(VerticalAlign.Center)
      
      // 右侧箭头
      Image($r('app.media.arrow_right'))
        .width(20)
        .height(20)
        .fillColor('#999999')
    }
    .width('100%')
    .padding({ top: 16, bottom: 16, left: 8, right: 8 })
    .alignItems(VerticalAlign.Center)
    .onClick(() => {
      if (title === '设置') {
        router.pushUrl({
          url: 'pages/Settings'
        });
      } else if (title === '我的收藏') {
        router.pushUrl({
          url: 'pages/Favorites'
        });
      } else if (title === '浏览历史') {
        router.pushUrl({
          url: 'pages/History'
        });
      } else if (title === '我的评论') {
        router.pushUrl({
          url: 'pages/Comments'
        });
      }
    })
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
            url: 'pages/Login'
          });
        })
        
        // 功能区域
        Column() {
          this.buildProfileItem('我的收藏', 'like')
          Divider().width('100%').height(1).color('#F0F0F0')
          this.buildProfileItem('浏览历史', 'history')
          Divider().width('100%').height(1).color('#F0F0F0')
          this.buildProfileItem('我的评论', 'comment')
          Divider().width('100%').height(1).color('#F0F0F0')
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
}