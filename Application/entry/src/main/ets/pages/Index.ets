import { Constants } from '../common/constants/Constants';
import router from '@ohos.router';
import { CategoryItem } from '../common/constants/Constants';
import { Artifact } from '../model/ArtifactModel';
import { ArtifactService } from '../services/ArtifactService';
import prompt from '@ohos.prompt';
import picker from '@ohos.file.picker';
import { UserService } from '../services/UserService';
import { UserInfo } from '../services/UserService';
import { PostService } from '../services/PostService';
import { CommentService } from '../services/CommentService';
import { Post as PostModel, Comment as CommentModel } from '../model/PostModel';
import { CommentData } from '../model/CommentModel';

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

/**
 * 评论数据接口，用于创建评论
 */
interface CommentInputData {
  comment_id: string;
  post_id: string;
  user_id: number;
  nickname: string;
  img_url?: string;
  content: string;
  create_time: string;
  create_timestamp: number;
}

/**
 * 评论响应接口，用于处理服务器返回的评论数据
 */
interface CommentResponse {
  comment_id: string;
  post_id: string;
  user_id: number;
  nickname: string;
  img_url?: string;
  content: string;
  create_time: string;
  create_timestamp: number;
}

@Entry
@Component
struct Index {
  @State currentIndex: number = 0;
  @State searchKeyword: string = '';
  @State searchResults: Artifact[] = [];
  @State isLoading: boolean = false;
  @State posts: Array<Post> = [];
  @State realPosts: Array<PostModel> = []; // 真实的帖子数据
  @State favoritePosts: Set<number> = new Set();
  @State selectedImages: Resource[] = [];
  @State newPostContent: string = '';
  @State artifacts: Artifact[] = [];
  @State isArtifactsLoading: boolean = false;
  @State selectedCategory: CategoryItem = { id: 0, name: '全部' };
  @State userInfo: UserInfo | null = null;
  @State isPostsLoading: boolean = false;
  @State showCommentInput: boolean = false;
  @State currentPostId: string = '';
  @State commentContent: string = '';
  @State currentPage: number = 1;
  @State pageSize: number = 10;
  @State hasMoreData: boolean = true;
  
  private artifactService: ArtifactService = new ArtifactService();
  private userService: UserService = new UserService();
  private scroller: Scroller = new Scroller();

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
          this.buildUserProfilePage()
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
        Text('社区动态')
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
              url: 'pages/Dynamic',
              params: {
                isPostOnly: true // 标记仅用于发表帖子
              }
            });
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 20, bottom: 20 })
      .backgroundColor('#FFFFFF')
      .borderRadius({ bottomLeft: 10, bottomRight: 10 })
      .shadow({ radius: 2, color: '#00000010', offsetX: 0, offsetY: 2 })

      // 下拉刷新提示
      if (this.isPostsLoading && this.realPosts.length === 0) {
        Column() {
          LoadingProgress()
            .width(50)
            .height(50)
            .color('#1698CE')
          
          Text('正在加载动态内容...')
            .fontSize(16)
            .margin({ top: 10 })
        }
        .width('100%')
        .height(300)
        .justifyContent(FlexAlign.Center)
      } 
      // 动态列表
      else if (this.realPosts.length === 0) {
        Column() {
          Image($r('app.media.empty_image'))
            .width(100)
            .height(100)
            .margin({ bottom: 20 })
          
          Text('暂无动态内容')
            .fontSize(16)
            .fontColor('#999999')
            .margin({ bottom: 10 })
          
          Button('去发表第一条动态', { type: ButtonType.Normal })
            .backgroundColor('#1698CE')
            .fontColor('#FFFFFF')
            .borderRadius(20)
            .onClick(() => {
              router.pushUrl({
                url: 'pages/Dynamic',
                params: {
                  isPostOnly: true // 标记仅用于发表帖子
                }
              });
            })
        }
        .width('100%')
        .height(300)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: 10, scroller: this.scroller }) {
          ForEach(this.realPosts, (post: PostModel, index: number) => {
          ListItem() {
              this.RealPostBuilder(post, index)
          }
        })
          
          // 加载中提示
          if (this.isPostsLoading) {
            ListItem() {
              Row() {
                LoadingProgress()
                  .width(24)
                  .height(24)
                  .color('#1698CE')
                Text('加载中...')
                  .fontSize(14)
                  .fontColor('#999999')
                  .margin({ left: 10 })
              }
              .width('100%')
              .justifyContent(FlexAlign.Center)
              .padding(16)
            }
          }
          
          // 没有更多数据提示
          if (!this.hasMoreData && this.realPosts.length > 0) {
            ListItem() {
              Text('已经到底了')
                .fontSize(14)
                .fontColor('#999999')
                .width('100%')
                .textAlign(TextAlign.Center)
                .padding(16)
            }
          }
      }
      .width('100%')
      .layoutWeight(1)
        .onReachEnd(() => {
          if (!this.isPostsLoading && this.hasMoreData) {
            this.loadPosts();
          }
        })
        .onScrollFrameBegin((offset: number) => {
          if (offset <= -100 && !this.isPostsLoading) {
            this.loadPosts(true);
          }
          return { offsetRemain: 0 };
        })
      }
      
      // 评论输入框
      if (this.showCommentInput) {
        Column() {
          Row() {
            TextInput({ placeholder: '说点什么...', text: this.commentContent })
              .width('75%')
              .height(40)
              .backgroundColor('#F5F5F5')
              .borderRadius(20)
              .padding({ left: 12, right: 12 })
              .onChange((value: string) => {
                this.commentContent = value;
              })

            Button('发送', { type: ButtonType.Normal })
              .width('20%')
              .height(40)
              .backgroundColor('#1698CE')
              .fontColor('#FFFFFF')
              .borderRadius(20)
              .onClick(() => {
                this.addComment(this.currentPostId);
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .padding(16)
        }
        .width('100%')
        .backgroundColor('#FFFFFF')
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
    .padding({ bottom: 56 })
  }
  
  @Builder
  RealPostBuilder(post: PostModel, index: number) {
    Column() {
      // 用户信息和发布时间
      Row() {
        // 用户头像
        Image(post.img_url || $r('app.media.icon'))
          .width(40)
          .height(40)
          .borderRadius(20)
          .margin({ right: 10 })
        
        Column() {
          // 用户昵称
          Text(post.nickname)
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
          
          // 发布时间
          Text(post.create_time)
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
      if (post.post_img_url) {
        Image(post.post_img_url)
                .width('100%')
          .height(200)
                .objectFit(ImageFit.Cover)
                .borderRadius(8)
        .margin({ bottom: 10 })
      }

      // 操作栏
      Row() {
        // 点赞按钮
        Row() {
          Text(post.is_favorited === 1 ? '♥' : '♡')
            .fontSize(20)
            .fontColor(post.is_favorited === 1 ? '#FF0000' : '#666666')
          Text(post.likes.toString())
            .fontSize(14)
            .margin({ left: 5 })
        }
        .onClick(() => {
          this.likePost(post, index);
        })
        .margin({ right: 20 })

        // 评论按钮
        Row() {
          Text('💬')
            .fontSize(20)
          Text(post.comments ? post.comments.length.toString() : '0')
            .fontSize(14)
            .margin({ left: 5 })
        }
        .onClick(() => {
          this.currentPostId = post.post_id;
          this.showCommentInput = true;
        })
        .margin({ right: 20 })

        // 收藏按钮
        Row() {
          Text(post.is_favorited === 1 ? '★' : '☆')
            .fontSize(20)
            .fontColor(post.is_favorited === 1 ? '#FFD700' : '#666666')
        }
        .onClick(() => {
          this.toggleFavorite(post, index);
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.Start)
      .margin({ bottom: 10 })

      // 评论列表
      if (post.comments && post.comments.length > 0) {
        Column() {
          ForEach(post.comments, (comment: CommentModel) => {
            Row() {
              Text(comment.nickname || '匿名用户')
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#1698CE')
              Text(comment.content || '')
                    .fontSize(14)
                    .margin({ left: 5 })
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
  
  // 添加点赞方法
  async likePost(post: PostModel, index: number) {
    try {
      if (post.is_favorited === 1) {
        const result = await PostService.unlikePost(post.post_id);
        if (result.code === 0 && result.data) {
          this.realPosts[index].likes = result.data.likes;
          this.realPosts[index].is_favorited = 0;
          this.realPosts = [...this.realPosts]; // 触发UI更新
        }
      } else {
        const result = await PostService.likePost(post.post_id);
        if (result.code === 0 && result.data) {
          this.realPosts[index].likes = result.data.likes;
          this.realPosts[index].is_favorited = 1;
          this.realPosts = [...this.realPosts]; // 触发UI更新
        }
      }
    } catch (error) {
      console.error('更新点赞状态失败:', error);
      prompt.showToast({ message: '操作失败，请稍后重试' });
    }
  }

  // 添加收藏/取消收藏方法
  async toggleFavorite(post: PostModel, index: number) {
    try {
      const newState = post.is_favorited === 0;
      const result = await PostService.updateFavorite(post.post_id, newState);
      if (result.code === 0 && result.data !== undefined) {
        this.realPosts[index].is_favorited = result.data.is_favorited ? 1 : 0;
        this.realPosts = [...this.realPosts]; // 触发UI更新
        prompt.showToast({ message: result.data.is_favorited ? '收藏成功' : '取消收藏成功' });
      }
    } catch (error) {
      console.error('更新收藏状态失败:', error);
      prompt.showToast({ message: '操作失败，请稍后重试' });
    }
  }

  // 添加评论方法
  async addComment(postId: string) {
    if (!this.commentContent.trim()) {
      prompt.showToast({ message: '请输入评论内容' });
      return;
    }

    try {
      const userInfo = await this.userService.getUserInfo();
      if (!userInfo) {
        prompt.showToast({ message: '请先登录' });
        return;
      }

      // 获取用户ID，尝试不同的属性
      const userId = userInfo.user_id || (userInfo.id ? parseInt(userInfo.id) : 0);
      const nickname = userInfo.nickname || '匿名用户';
      
      const now = new Date();
      const commentData: CommentData = {
        comment_id: `comment_${now.getTime()}`,
        post_id: postId,
        user_id: userId,
        nickname: nickname,
        img_url: userInfo.img_url,
        content: this.commentContent,
        create_time: this.formatDate(now, 'YYYY-MM-DD HH:mm:ss'),
        create_timestamp: now.getTime()
      };

      const result = await CommentService.addComment(commentData);
      if (result.code === 0 && result.data) {
        prompt.showToast({ message: '评论成功' });
        this.commentContent = '';
        this.showCommentInput = false;
        
        // 更新本地帖子评论数据
        const postIndex = this.realPosts.findIndex(post => post.post_id === postId);
        if (postIndex !== -1 && this.realPosts[postIndex]) {
          // 确保comments数组已初始化
          if (!this.realPosts[postIndex].comments) {
            this.realPosts[postIndex].comments = [];
          }
          
          // 创建一个明确的CommentModel对象，避免结构类型
          const newComment: CommentModel = {
            comment_id: result.data.comment_id,
            post_id: result.data.post_id,
            user_id: result.data.user_id,
            nickname: result.data.nickname,
            content: result.data.content,
            create_time: result.data.create_time,
            create_timestamp: result.data.create_timestamp
          };
          
          // 可选属性单独处理
          if (result.data.img_url) {
            newComment.img_url = result.data.img_url;
          }
          
          // 直接使用comments数组，因为我们已确保它存在
          this.realPosts[postIndex].comments!.unshift(newComment);
          this.realPosts = [...this.realPosts]; // 触发UI更新
        }
      } else {
        prompt.showToast({ message: result.message || '评论失败' });
      }
    } catch (error) {
      console.error('发布评论失败:', error);
      prompt.showToast({ message: '评论失败，请稍后重试' });
    }
  }

  // 加载帖子方法
  async loadPosts(isRefresh: boolean = false) {
    if (isRefresh) {
      this.currentPage = 1;
    }
    
    if (!this.hasMoreData && !isRefresh) {
      return;
    }

    this.isPostsLoading = true;
    try {
      const response = await PostService.getPosts(this.currentPage, this.pageSize);
      
      if (isRefresh) {
        this.realPosts = response.data;
      } else {
        this.realPosts = [...this.realPosts, ...response.data];
      }
      
      this.hasMoreData = this.realPosts.length < response.total;
      this.currentPage++;
    } catch (error) {
      console.error('获取帖子列表失败:', error);
      prompt.showToast({ message: '获取帖子失败，请稍后重试' });
    } finally {
      this.isPostsLoading = false;
    }
  }

  // 日期格式化方法
  private formatDate(date: Date, format: string): string {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    const hours = String(date.getHours()).padStart(2, '0');
    const minutes = String(date.getMinutes()).padStart(2, '0');
    const seconds = String(date.getSeconds()).padStart(2, '0');
    
    return format
      .replace('YYYY', String(year))
      .replace('MM', month)
      .replace('DD', day)
      .replace('HH', hours)
      .replace('mm', minutes)
      .replace('ss', seconds);
  }

  aboutToAppear() {
    // 获取用户信息
    this.loadUserInfo();
    
    // 加载帖子数据
    this.loadPosts();
    
    // 示例动态数据 - 你可以保留这部分作为备用
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
  
  @Builder
  buildUserProfilePage() {
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
}