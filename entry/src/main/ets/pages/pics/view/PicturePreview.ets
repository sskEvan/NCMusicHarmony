import { SizeConstant, TabLayoutPagerMediator, TabPager } from 'lib_common'
import { CommonAppBar } from 'lib_common'
import router from '@ohos.router'

/**
 * 图片预览页面
 */
@Entry
@Component
struct PicturePreviewPage {
  pics: PicturePreviewBean[]
  @State private tabMediator: TabLayoutPagerMediator = new TabLayoutPagerMediator()

  aboutToAppear() {
    const params = (router.getParams() as PicturePreviewRouterParams)
    this.pics = params.pics
    this.tabMediator = new TabLayoutPagerMediator({
      tabItems: this.pics,
      cacheCount: 0, // 动态改变TabPager的cacheCount为0，否则如果有多张图片的时候，打开页面、退出页面做共享动画会出现奇怪的效果
      currentIndex: params.index,
    })
  }

  onBackPress() {
    // 动态改变TabPager的cacheCount为0，否则如果有多张图片的时候，打开页面、退出页面做共享动画会出现奇怪的效果
    this.tabMediator = new TabLayoutPagerMediator({
      tabItems: this.pics,
      cacheCount: 0,
      currentIndex: this.tabMediator.currentIndex,
    })
  }

  build() {
    Column() {
      CommonAppBar({
        bgColor: Color.Black,
        contentColor: Color.White,
        CustomerTitleBuilder: () => {
          this.CustomerTitleBuilder()
        }
      })
      TabPager({ mediator: this.tabMediator,
        TabPageBuilder: (index: number) => {
          this.TabPageBuilder(index)
        } }).layoutWeight(1)
        .onAppear(() => {
          setTimeout(() => {
            // 动态改变TabPager的cacheCount为1，预加载图片
            this.tabMediator = new TabLayoutPagerMediator({
              tabItems: this.pics,
              cacheCount: 1,
              currentIndex: this.tabMediator.currentIndex,
            })
          }, 300)
        })
    }.width("100%")
    .height("100%")
    .backgroundColor(Color.Black)
  }

  @Builder CustomerTitleBuilder() {
    Text(`${Math.round(this.tabMediator.currentIndex) + 1} / ${this.pics.length}`)
      .fontSize(SizeConstant.TEXT_XL)
      .fontWeight(FontWeight.Bold)
      .fontColor(Color.White)
      .maxLines(1)
      .width("100%")
      .textAlign(TextAlign.Center)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .margin({ left: SizeConstant.SPACE_M, right: SizeConstant.SPACE_M })
  }

  @Builder TabPageBuilder(index: number) {
    Stack({ alignContent: Alignment.Center }) {
      Image(this.pics[index].url).width("100%")
        .sharedTransition(`picPreview:${this.pics[index].url}`, {
          duration: 300,
          curve: Curve.Linear
        })
    }.width("100%").height("100%")
  }

  pageTransition() {
    PageTransitionEnter({ duration: 300, curve: Curve.Linear })
      .opacity(0)
    PageTransitionEnter({ type: RouteType.Pop, duration: 300, curve: Curve.Linear })
      .opacity(1)
    PageTransitionExit({ duration: 300, curve: Curve.Linear })
      .opacity(1)
    PageTransitionExit({ type: RouteType.Pop, duration: 300, curve: Curve.Linear })
      .opacity(0)
  }
}


export class PicturePreviewBean {
  url: string

  constructor(url: string) {
    this.url = url
  }
}

export class PicturePreviewRouterParams {
  index: number
  pics: PicturePreviewBean[]

  constructor(index: number, pics: PicturePreviewBean[]) {
    this.index = index
    this.pics = pics
  }
}