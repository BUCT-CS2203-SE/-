import router from '@ohos.router';
import { Artifact } from '../model/ArtifactModel';
import { ArtifactService } from '../services/ArtifactService';
import prompt from '@ohos.prompt';

/**
 * 分类文物展示页面参数接口
 */
interface CategoryArtifactsParams {
  categoryId: number;  // 分类ID
  categoryName: string;  // 分类名称
}

@Entry
@Component
struct CategoryArtifacts {
  @State artifacts: Artifact[] = [];
  @State isLoading: boolean = false;
  @State categoryId: number = 0;
  @State categoryName: string = '全部文物';
  @State currentPage: number = 1;
  @State pageSize: number = 10;
  @State hasMoreData: boolean = true;
  
  private artifactService: ArtifactService = new ArtifactService();
  private scroller: Scroller = new Scroller();
  
  aboutToAppear() {
    // 获取路由参数
    const params = router.getParams() as CategoryArtifactsParams;
    if (params && params.categoryId !== undefined) {
      this.categoryId = params.categoryId;
    }
    if (params && params.categoryName) {
      this.categoryName = params.categoryName;
    }
    
    // 加载文物数据
    this.loadArtifacts(true);
  }
  
  /**
   * 加载文物数据
   * @param isRefresh 是否刷新
   */
  private loadArtifacts(isRefresh: boolean = false) {
    if (isRefresh) {
      this.currentPage = 1;
    }
    
    if (!this.hasMoreData && !isRefresh) {
      return;
    }
    
    this.isLoading = true;
    this.artifactService.getArtifactList(this.categoryId, this.currentPage, this.pageSize)
      .then((artifacts: Artifact[]) => {
        if (isRefresh) {
          this.artifacts = artifacts;
        } else {
          this.artifacts = [...this.artifacts, ...artifacts];
        }
        
        this.hasMoreData = artifacts.length === this.pageSize;
        this.currentPage++;
        this.isLoading = false;
      })
      .catch((error: Error) => {
        console.error('加载分类文物失败:', error);
        prompt.showToast({ message: `加载失败: ${error.message}` });
        this.isLoading = false;
      });
  }
  
  build() {
    Column() {
      // 顶部栏
      Row() {
        Image($r('app.media.arrow_back'))
          .width(24)
          .height(24)
          .margin({ right: 16 })
          .onClick(() => {
            router.back();
          })
        
        Text(this.categoryName)
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
      .backgroundColor('#FFFFFF')
      
      // 文物列表
      if (this.isLoading && this.artifacts.length === 0) {
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
        .height('80%')
        .justifyContent(FlexAlign.Center)
      } else if (this.artifacts.length > 0) {
        List({ scroller: this.scroller }) {
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
              .aspectRatio(0.75) // 宽高比
            })
          }
          .columnsTemplate('1fr 1fr') // 两列布局
          .columnsGap(12) // 列间距
          .rowsGap(12) // 行间距
          .width('100%') 
          .padding(16)
          
          // 加载更多提示
          if (this.isLoading) {
            Row() {
              LoadingProgress()
                .width(24)
                .height(24)
                .color('#1698CE')
              
              Text('正在加载更多...')
                .fontSize(14)
                .fontColor('#999999')
                .margin({ left: 8 })
            }
            .width('100%')
            .padding({ top: 16, bottom: 16 })
            .justifyContent(FlexAlign.Center)
          }
          
          // 没有更多数据提示
          if (!this.hasMoreData && this.artifacts.length > 0) {
            Text('已经到底了')
              .fontSize(14)
              .fontColor('#999999')
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding({ top: 16, bottom: 16 })
          }
        }
        .layoutWeight(1)
        .onReachEnd(() => {
          if (!this.isLoading && this.hasMoreData) {
            this.loadArtifacts();
          }
        })
        .onScrollFrameBegin((offset: number) => {
          if (offset <= -100 && !this.isLoading) {
            this.loadArtifacts(true);
          }
          return { offsetRemain: 0 };
        })
      } else {
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
        .height('80%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
} 