import { Constants } from '../common/constants/Constants';
import router from '@ohos.router';
import { CategoryItem } from '../common/constants/Constants';
import { Artifact } from '../model/ArtifactModel';
import { ArtifactService } from '../services/ArtifactService';
import prompt from '@ohos.prompt';
import picker from '@ohos.file.picker';
import { UserService } from '../services/UserService';
import { UserInfo } from '../services/UserService';

/**
 * 动态帖子接口
 */
interface Post {
  id: number;
  username: string;
  avatarUrl: string;
  content: string;
  createTime: string;
  likes: number;
  isLiked: boolean;
  images: Resource[];
  comments: Array<Comment>;
}

/**
 * 评论接口
 */
interface Comment {
  username: string;
  content: string;
}

/**
 * Sheet项目接口
 */
interface Sheet {
  title: string;
  action: () => void;
}

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @State searchKeyword: string = '';
  @State searchResults: Artifact[] = [];
  @State isLoading: boolean = false;
  @State posts: Array<Post> = [];
  @State favoritePosts: Set<number> = new Set();
  @State selectedImages: Resource[] = [];
  @State newPostContent: string = '';
  @State artifacts: Artifact[] = [];
  @State isArtifactsLoading: boolean = false;
  @State selectedCategory: CategoryItem = { id: 0, name: '全部' };
  @State userInfo: UserInfo | null = null;
  
  private artifactService: ArtifactService = new ArtifactService();
  private userService: UserService = new UserService();

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
        
        // 动态Tab
        TabContent() {
          this.buildDynamicPage()
        }
        .tabBar(this.TabBuilder(3, '动态', 'icon'))
        
        // 我的Tab
        TabContent() {
          this.buildProfilePage()
        }
        .tabBar(this.TabBuilder(4, '我的', 'person'))
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
      
      // 添加分类选择器
      Row() {
        Text('分类：').fontSize(16).fontColor('#666666')
        
        Row() {
          Text(this.selectedCategory.name)
            .fontSize(16)
            .fontColor('#1698CE')
            .layoutWeight(1)
          
          Image($r('app.media.arrow_right'))
            .width(20)
            .height(20)
            .fillColor('#1698CE')
            .margin({ left: 5 })
        }
        .width('80%')
        .height(40)
        .borderRadius(20)
        .backgroundColor('#F5F5F5')
        .padding({ left: 15, right: 15 })
        .justifyContent(FlexAlign.SpaceBetween)
        .onClick(() => {
          ActionSheet.show({
            title: '选择分类',
            message: '请选择您想要查看的文物分类',
            sheets: Constants.ARTIFACT_CATEGORIES.map((item): Sheet => ({
              title: item.name,
              action: () => {
                this.selectedCategory = item;
                this.loadArtifacts();
              }
            }))
          });
        })
      }
      .width('90%')
      .margin({ bottom: 20 })
      
      // 加载状态
      if (this.isArtifactsLoading) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#1698CE')
          
          Text('正在加载文物数据...')
            .fontSize(16)
            .margin({ top: 10 })
        }
        .width('100%')
        .height(300)
        .justifyContent(FlexAlign.Center)
      } 
      // 文物列表
      else if (this.artifacts.length > 0) {
        Grid() {
          ForEach(this.artifacts, (artifact: Artifact) => {
            GridItem() {
              Column() {
                // 文物图片
                Stack() {
                  Image(artifact.imageUrl || $r('app.media.placeholder'))
                    .width('100%')
                    .height(180)
                    .objectFit(ImageFit.Cover)
                    .borderRadius({ topLeft: 8, topRight: 8 })

                }
                .width('100%')
                
                // 文物信息
                Column() {
                  Text(artifact.name)
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .width('100%')

                  Row() {
                    Text(`${artifact.era}`)
                      .fontSize(14)
                      .fontColor('#666666')
                      .margin({ right: 8 })
                    Text(artifact.museum)
                      .fontSize(14)
                      .fontColor('#666666')
                      .backgroundColor('#00000010')
                      .borderRadius(10)
                      .padding({ left: 8, right: 8, top: 2, bottom: 2 })
                      .margin({ right: 8 })
                  }
                  .width('100%')
                  .margin({ top: 5 })
                }
                .width('100%')
                .padding(10)
              }
              .width('100%')
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
              .onClick(() => {
                router.pushUrl({
                  url: 'pages/ArtifactDetail',
                  params: { artifactId: artifact.id }
                });
              })
            }
            .aspectRatio(0.75)  // 宽高比
          })
        }
        .columnsTemplate('1fr 1fr')  // 两列布局
        .columnsGap(12)  // 列间距（可适当加大）
        .rowsGap(12)  // 行间距（可适当加大）
        .width('100%')  // 这里改成100%
        .layoutWeight(1)
      } 
      // 无数据状态
      else {
        Column() {
          Image($r('app.media.no_result'))
            .width(100)
            .height(100)
            .margin({ bottom: 20 })
          
          Text('暂无文物数据')
            .fontSize(16)
            .fontColor('#999999')
        }
        .width('100%')
        .height(300)
        .justifyContent(FlexAlign.Center)
      }
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
  buildDynamicPage() {
    Column() {
      // 顶部栏
      Row() {
        Text('动态')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // 发表动态按钮
        Button('发表', { type: ButtonType.Normal })
          .width(60)
          .height(30)
          .backgroundColor('#1698CE')
          .fontColor('#FFFFFF')
          .borderRadius(15)
          .onClick(() => {
            router.pushUrl({
              url: 'pages/Dynamic'
            });
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .backgroundColor('#FFFFFF')
      .borderRadius({ bottomLeft: 10, bottomRight: 10 })
      .shadow({ radius: 2, color: '#00000010', offsetX: 0, offsetY: 2 })

      // 动态列表
      List({ space: 10 }) {
        ForEach(this.posts, (post: Post) => {
          ListItem() {
            this.PostBuilder(post)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFF5F5')  // 浅红色背景
    .padding({ bottom: 56 })
  }
  
  @Builder
  PostBuilder(post: Post) {
    Column() {
      // 用户信息和发布时间
      Row() {
        // 用户头像
        Image(post.avatarUrl || $r('app.media.icon'))
          .width(40)
          .height(40)
          .borderRadius(20)
          .margin({ right: 10 })
        
        Column() {
          // 用户名
          Text(post.username)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
          
          // 发布时间
          Text(post.createTime)
            .fontSize(12)
            .fontColor('#999999')
        }
        .alignItems(HorizontalAlign.Start)
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 10 })

      // 动态内容
      Text(post.content)
        .fontSize(16)
        .width('100%')
        .margin({ bottom: 10 })

      // 图片展示
      if (post.images && post.images.length > 0) {
        Grid() {
          ForEach(post.images, (image: Resource) => {
            GridItem() {
              Image($r('app.media.cultural_heritage_logo'))
                .width('100%')
                .height('100%')
                .objectFit(ImageFit.Cover)
                .borderRadius(8)
            }
          })
        }
        .columnsTemplate('1fr')
        .rowsTemplate('1fr')
        .columnsGap(5)
        .rowsGap(5)
        .width('100%')
        .height(300)
        .margin({ bottom: 10 })
      }

      // 操作栏
      Row() {
        // 点赞按钮
        Row() {
          Text(post.isLiked ? '♥' : '♡')
            .fontSize(20)
            .fontColor(post.isLiked ? '#FF0000' : '#666666')
          Text(post.likes.toString())
            .fontSize(14)
            .margin({ left: 5 })
        }
        .onClick(() => {
          post.isLiked = !post.isLiked;
          post.likes += post.isLiked ? 1 : -1;
        })
        .margin({ right: 20 })

        // 评论按钮
        Row() {
          Text('💬')
            .fontSize(20)
          Text(post.comments.length.toString())
            .fontSize(14)
            .margin({ left: 5 })
        }
        .margin({ right: 20 })

        // 收藏按钮
        Row() {
          Text(this.favoritePosts.has(post.id) ? '★' : '☆')
            .fontSize(20)
            .fontColor(this.favoritePosts.has(post.id) ? '#FFD700' : '#666666')
        }
        .onClick(() => {
          if (this.favoritePosts.has(post.id)) {
            this.favoritePosts.delete(post.id);
            prompt.showToast({ message: '已取消收藏' });
          } else {
            this.favoritePosts.add(post.id);
            prompt.showToast({ message: '已收藏' });
          }
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 10 })

      // 评论列表
      if (post.comments.length > 0) {
        Column() {
          ForEach(post.comments, (comment: Comment) => {
            Row() {
              Column() {
                Row() {
                  Text(comment.username)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1698CE')
                  Text(comment.content)
                    .fontSize(14)
                    .margin({ left: 5 })
                }
                .width('100%')
                .justifyContent(FlexAlign.Start)
              }
              .layoutWeight(1)
            }
            .width('100%')
            .justifyContent(FlexAlign.Start)
            .margin({ bottom: 5 })
          })
        }
        .width('100%')
        .padding(10)
        .backgroundColor('#F5F5F5')
        .borderRadius(5)
      }
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(10)
    .margin({ bottom: 10 })
  }
  
  @Builder
  buildProfilePage() {
    Column() {
      Text('个人中心').fontSize(24).fontWeight(FontWeight.Bold).margin({ top: 20, bottom: 20 })
      
      Column() {
        // 用户信息区域
        Row() {
          if (this.userInfo) {
            // 显示用户头像
            Image(this.userInfo.img_url || $r('app.media.icon'))
              .width(80)
              .height(80)
              .borderRadius(40)
              .objectFit(ImageFit.Cover)
            
            Column() {
              Text(this.userInfo.nickname || '未设置昵称')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
              Text(this.userInfo.phone || '未绑定手机号')
                .fontSize(14)
                .margin({ top: 5 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 20 })
          } else {
            // 未登录状态
            Image($r('app.media.icon'))
              .width(80)
              .height(80)
              .borderRadius(40)
            
            Column() {
              Text('未登录')
                .fontSize(18)
                .fontWeight(FontWeight.Bold)
              Text('点击登录')
                .fontSize(14)
                .margin({ top: 5 })
            }
            .alignItems(HorizontalAlign.Start)
            .margin({ left: 20 })
          }
        }
        .width('90%')
        .padding(16)
        .backgroundColor('#FFFFFF')
        .borderRadius(10)
        .margin({ bottom: 20 })
        .onClick(() => {
          if (!this.userInfo) {
            router.pushUrl({
              url: 'pages/Login'
            });
          }
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
          
          // 如果已登录，显示退出登录按钮
          if (this.userInfo) {
            Divider().width('100%').height(1).color('#F0F0F0')
            Button('退出登录', { type: ButtonType.Normal })
              .width('100%')
              .height(50)
              .backgroundColor('#8B1A1A')
              .fontColor('#FFFFFF')
              .margin({ top: 20 })
              .onClick(() => {
                this.userService.logout();
                this.userInfo = null;
                router.replaceUrl({ url: 'pages/Login' });
              })
          }
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

  aboutToAppear() {
    // 获取用户信息
    this.loadUserInfo();
    
    // 添加示例动态数据
    this.posts = [
      {
        id: 1,
        username: '张三',
        avatarUrl: '',
        content: '今天参观了故宫博物院，看到了很多珍贵的文物，特别是青花瓷瓶，真是太美了！',
        createTime: '2024-03-20 15:30',
        likes: 12,
        isLiked: false,
        images: [],
        comments: [
          {
            username: '李四',
            content: '我也去过故宫，确实很震撼！'
          },
          {
            username: '王五',
            content: '推荐去看看故宫的钟表馆，也很精彩！'
          }
        ]
      },
      {
        id: 2,
        username: '李四',
        avatarUrl: '',
        content: '分享一张在南京博物院拍的照片，这个金缕玉衣真是太精美了！',
        createTime: '2024-03-19 10:20',
        likes: 8,
        isLiked: false,
        images: [$r('app.media.cultural_heritage_logo')],
        comments: [
          {
            username: '张三',
            content: '这个玉衣保存得真好！'
          }
        ]
      }
    ];

    // 加载文物数据
    this.loadArtifacts();
  }
  
  private async loadUserInfo() {
    try {
      this.userInfo = await this.userService.getUserInfo();
      console.info('用户信息加载成功:', JSON.stringify(this.userInfo));
    } catch (error) {
      console.error('加载用户信息失败:', error);
      this.userInfo = null;
    }
  }

  // 添加加载文物方法
  private loadArtifacts() {
    this.isArtifactsLoading = true;
    
    const categoryId = this.selectedCategory.id === 0 ? undefined : this.selectedCategory.id;
    this.artifactService.getArtifactList(categoryId, 1, 20)
      .then((artifacts) => {
        this.artifacts = artifacts;
        this.isArtifactsLoading = false;
      })
      .catch((err: Error) => {
        console.error('加载文物失败:', err);
        this.isArtifactsLoading = false;
      });
  }
}