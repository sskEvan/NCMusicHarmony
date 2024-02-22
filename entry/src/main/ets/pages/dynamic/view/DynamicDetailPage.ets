import {
  CollapsibleLayout,
  CollapsibleMediator,
  CommonAppBar,
  CommonNetworkImage,
  ScreenUtils,
  SizeConstant,
  TabItem,
  TabLayout,
  TabLayoutPagerMediator,
  TabPager
} from 'lib_common'
import router from '@ohos.router'
import {
  DynamicBean,
  CpnDynamicItem,
  DynamicCommentListPage,
  DynamicLikeListPage,
  DynamicShareListPage
} from '../../..'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'

/**
 * 动态详情页面
 */
@Entry
@Component
struct DynamicDetailPage {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  private tabItems: TabItem[] = [new TabItem(0, "评论"), new TabItem(1, "转发"), new TabItem(2, "赞")]
  @State private collapsibleProgress: number = 0
  @State private collapsibleMediator: CollapsibleMediator = new CollapsibleMediator((progress: number) => {
    this.collapsibleProgress = progress
  })
  initTabPosition: number = -1
  @State private tabMediator: TabLayoutPagerMediator = new TabLayoutPagerMediator({
    tabItems: this.tabItems,
    cacheCount: 2,
    indexChangedCallback: (index: number) => {
      this.collapsibleMediator.setCurInnerScrollerIndex(index)
    }
  })
  @State dynamicBean: Partial<DynamicBean> = {}

  aboutToAppear() {
    const params = router.getParams() as DynamicDetailPageParam
    this.dynamicBean = params.dynamicBean
    this.initTabPosition = params.initTabPosition
    if (this.initTabPosition != -1) {
      this.tabMediator.jumpToIndex(this.initTabPosition)
      setTimeout(() => {
        this.collapsibleMediator.shrink()
      }, 500)
    }
  }

  @Builder AppBarBuilder() {
    CommonAppBar({
      titleCenter: false,
      leftIcon: $r('app.media.ic_back'),
      rightIcons: [$r('app.media.ic_more')],
      CustomerTitleBuilder: () => {
        this.CustomerTitleBuilder()
      }
    })
  }

  @Builder CustomerTitleBuilder() {
    Text("动态")
      .fontSize(SizeConstant.TEXT_XL)
      .fontWeight(FontWeight.Bold)
      .fontColor(AppTheme.palette(this.themeType).firstText)
      .maxLines(1)
      .width("100%")
      .visibility(this.collapsibleProgress <= 0.1 ? Visibility.Visible : Visibility.Hidden)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .margin({ left: SizeConstant.SPACE_M, right: SizeConstant.SPACE_M })
    Row() {
      CommonNetworkImage({ url: this.dynamicBean.user.avatarUrl, placeHolder: $r('app.media.ic_default_avatar') })
        .margin({ left: SizeConstant.SPACE_M, right: SizeConstant.SPACE_S })
        .width(SizeConstant.ICON_L)
        .height(SizeConstant.ICON_L)
        .borderRadius(SizeConstant.ICON_L / 2)
        .clip(true)
      Text(this.dynamicBean.user.nickname)
        .fontSize(SizeConstant.TEXT_L)
        .fontColor(AppTheme.palette(this.themeType).firstText)
        .fontWeight(FontWeight.Medium)
    }
    .visibility(this.collapsibleProgress > 0.1 ? Visibility.Visible : Visibility.Hidden)
  }

  @Builder ScrollableHeaderBuilder() {
    CpnDynamicItem({ isInList: false, dynamicBean: this.dynamicBean as DynamicBean })
      .margin({ top: ScreenUtils.getStatusBarHeight() + SizeConstant.APP_BAR_HEIGHT })
  }

  @Builder StickyHeaderBuilder() {
    TabLayout({ mediator: this.tabMediator })
  }

  @Builder ContentBuilder() {
    TabPager({ mediator: this.tabMediator,
      TabPageBuilder: (index: number) => {
        this.TabPageBuilder(index)
      } })
  }

  @Builder TabPageBuilder(index: number) {
    if (index == 0) {
      DynamicCommentListPage({
        commentId: this.dynamicBean.threadId,
        mediator: this.collapsibleMediator,
        scroller: this.collapsibleMediator.getCurrentInnerScroller(index) })
    } else if (index == 0) {
      DynamicLikeListPage({ mediator: this.collapsibleMediator,
        scroller: this.collapsibleMediator.getCurrentInnerScroller(index) })
    } else {
      DynamicShareListPage({ mediator: this.collapsibleMediator,
        scroller: this.collapsibleMediator.getCurrentInnerScroller(index) })
    }
  }

  build() {
    Stack() {
      CollapsibleLayout({
        AppBarBuilder: () => {
          this.AppBarBuilder()
        },
        ScrollableHeaderBuilder: () => {
          this.ScrollableHeaderBuilder()
        },
        StickyHeaderBuilder: () => {
          this.StickyHeaderBuilder()
        },
        ContentBuilder: () => {
          this.ContentBuilder()
        },
        mediator: this.collapsibleMediator
      })
    }.backgroundColor(AppTheme.palette(this.themeType).commonBackground)
  }

  pageTransition() {
    PageTransitionEnter({ type: RouteType.Push, duration: 300, curve: Curve.Linear })
      .opacity(0)
    PageTransitionEnter({ type: RouteType.Pop, duration: 300, curve: Curve.Linear })
      .opacity(1)
    PageTransitionExit({ type: RouteType.Push, duration: 300, curve: Curve.Linear })
      .opacity(1)
    PageTransitionExit({ type: RouteType.Pop, duration: 300, curve: Curve.Linear })
      .opacity(0)
  }
}

export class DynamicDetailPageParam {
  dynamicBean: DynamicBean
  initTabPosition: number

  constructor(dynamicBean: DynamicBean, initTabPosition: number = -1) {
    this.dynamicBean = dynamicBean
    this.initTabPosition = initTabPosition
  }
}