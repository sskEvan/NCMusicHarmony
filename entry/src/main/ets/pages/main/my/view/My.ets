import {
  CollapsibleLayout,
  CollapsibleMediator,
  CommonNetworkImage,
  ScreenUtils,
  SizeConstant,
  TabItem,
  TabLayout,
  TabLayoutPagerMediator,
  TabPager
} from 'lib_common'
import {
  IUserInfoBean,
  UserInfoBean,
  CpnMyHeader,
  MyDynamicPage,
  AlbumMusicPage,
  CollectMusicPage,
  CreateMusicPage,
  AllPodcastPage,
  MyPodcastPage,
  VoiceBookPage,
  STORAGE_MAIN_DRAWER_TOGGLE,
  STORAGE_USER_INFO
} from '../../../..'

import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'

/**
 * 首页-我的页面
 */
@Preview
@Component
export struct MyPage {
  @StorageLink(THEME_TYPE) @Watch("themeChange") themeType: ThemeType = ThemeType.DEFAULT
  @StorageLink(STORAGE_USER_INFO) userInfo: UserInfoBean = new UserInfoBean({} as IUserInfoBean)
  @StorageLink(STORAGE_MAIN_DRAWER_TOGGLE) mainDrawerToggle: boolean = false
  private myTabItems: TabItem[] = [new TabItem(0, "音乐"), new TabItem(1, "播客"), new TabItem(2, "动态")]
  private musicTabItems: TabItem[] = [new TabItem(0, "创建"), new TabItem(1, "收藏"), new TabItem(2, "专辑")]
  private podcastTabItems: TabItem[] = [new TabItem(0, "全部"), new TabItem(1, "播客"), new TabItem(2, "有声书")]
  @State private myTabMediator: TabLayoutPagerMediator = new TabLayoutPagerMediator({
    tabItems: this.myTabItems,
    cacheCount: 2,
    indexChangedCallback: (index: number) => {
      if (index == 0) {
        this.collapsibleMediator.setCurInnerScrollerIndex(this.musicTabMediator.currentIndex)
      } else if (index == 1) {
        this.collapsibleMediator.setCurInnerScrollerIndex(this.podcastTabMediator.currentIndex + this.musicTabItems.length)
      } else {
        this.collapsibleMediator.setCurInnerScrollerIndex(this.musicTabItems.length + this.podcastTabItems.length)
      }
    }
  })
  @State private musicTabMediator: TabLayoutPagerMediator = new TabLayoutPagerMediator({
    tabItems: this.musicTabItems,
    cacheCount: 2,
    draggable: false,
    indexChangedCallback: (index: number) => {
      this.collapsibleMediator.setCurInnerScrollerIndex(index)
    }
  })
  @State private podcastTabMediator: TabLayoutPagerMediator = new TabLayoutPagerMediator({
    tabItems: this.podcastTabItems,
    cacheCount: 2,
    draggable: false,
    indexChangedCallback: (index: number) => {
      this.collapsibleMediator.setCurInnerScrollerIndex(this.musicTabItems.length + index)
    }
  })
  @State private collapsibleProgress: number = 0
  @State private collapsibleMediator: CollapsibleMediator = new CollapsibleMediator((progress: number) => {
    this.collapsibleProgress = progress
  })
  @State private overScrollOffset: number = 0
  private maxOverScrollOffset: number = 120
  private lastTouchX = 0
  private lastTouchY = 0
  @State appBarColorBackgroundRgb: number = 255

  themeChange() {
    this.appBarColorBackgroundRgb = this.themeType == ThemeType.DARK ? 0 : 255
  }

  appBarColorContentRgbProgress() {
    return this.themeType == ThemeType.DARK ? this.collapsibleProgress : (1 - this.collapsibleProgress)
  }

  @Builder AppBarBuilder() {
    Column() {
      Stack().width("100%").height(ScreenUtils.getStatusBarHeight())
        .backgroundColor(`rgba(${this.appBarColorBackgroundRgb}, ${this.appBarColorBackgroundRgb}, ${this.appBarColorBackgroundRgb}, ${this.collapsibleProgress})`)

      RelativeContainer() {

        Image($r('app.media.ic_menu'))
          .margin({ left: SizeConstant.SPACE_M })
          .width(SizeConstant.ICON_L + SizeConstant.SPACE_S * 2)
          .height(SizeConstant.ICON_L + SizeConstant.SPACE_S * 2)
          .padding(SizeConstant.SPACE_S)
          .fillColor(`rgba(${255 * this.appBarColorContentRgbProgress()}, ${255 * this.appBarColorContentRgbProgress()}, ${255 * this.appBarColorContentRgbProgress()}, 1)`)
          .alignRules({
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            center: { anchor: '__container__', align: VerticalAlign.Center }
          })
          .id("ivMenu")
          .onClick(() => {
            this.mainDrawerToggle = !this.mainDrawerToggle
          })

        Row() {
          CommonNetworkImage({
            url: this.userInfo.detail.profile.avatarUrl,
            placeHolder: $r('app.media.ic_default_avatar')
          })
            .margin({ right: SizeConstant.SPACE_S })
            .width(SizeConstant.ICON_L)
            .height(SizeConstant.ICON_L)
            .borderRadius(SizeConstant.ICON_L / 2)
            .clip(true)
          Text(this.userInfo.detail.profile.nickname)
            .fontSize(SizeConstant.TEXT_L)
            .fontColor(AppTheme.palette(this.themeType).firstText)
        }
        .opacity((this.collapsibleProgress < 0.5) ? 0 : (this.collapsibleProgress - 0.5) * 2)
        .alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
          center: { anchor: '__container__', align: VerticalAlign.Center }
        })
        .id("rowUserInfo")

        Image($r('app.media.ic_search'))
          .margin({ right: SizeConstant.SPACE_M })
          .width(SizeConstant.ICON_L + SizeConstant.SPACE_S * 2)
          .height(SizeConstant.ICON_L + SizeConstant.SPACE_S * 2)
          .padding(SizeConstant.SPACE_S)
          .fillColor(`rgba(${255 * this.appBarColorContentRgbProgress()}, ${255 * this.appBarColorContentRgbProgress()}, ${255 * this.appBarColorContentRgbProgress()}, 1)`)
          .alignRules({
            right: { anchor: '__container__', align: HorizontalAlign.End },
            center: { anchor: '__container__', align: VerticalAlign.Center }
          })
          .id("ivSearch")
      }
      .width("100%").height(SizeConstant.APP_BAR_HEIGHT)
      .backgroundColor(`rgba(${this.appBarColorBackgroundRgb}, ${this.appBarColorBackgroundRgb}, ${this.appBarColorBackgroundRgb}, ${this.collapsibleProgress})`)
    }.width("100%")
    .height(SizeConstant.APP_BAR_HEIGHT + ScreenUtils.getStatusBarHeight())
  }

  @Builder ScrollableHeaderBuilder() {
    CpnMyHeader({ overScrollOffset: this.overScrollOffset })
  }

  @Builder StickyHeaderBuilder() {
    Stack() {
      Column() {
        TabLayout({
          mediator: this.myTabMediator,
        })
        if (this.myTabMediator.recorder.targetIndex == 0) {
          TabLayout({
            showIndicator: false,
            mediator: this.musicTabMediator,
            TabItemBuilder: (item: TabItem) => {
              this.MusicTabItemBuilder(item)
            }
          }).width(170)
        } else if (this.myTabMediator.recorder.targetIndex == 1) {
          TabLayout({
            showIndicator: false,
            mediator: this.podcastTabMediator,
            TabItemBuilder: (item: TabItem) => {
              this.PodcastTabItemBuilder(item)
            }
          }).width(170)
        } else if (this.myTabMediator.recorder.targetIndex == 2) {
          Stack({ alignContent: Alignment.Start }) {
            Text("我的动态")
              .fontSize(SizeConstant.TEXT_M)
              .fontColor(AppTheme.palette(this.themeType).firstText)
              .textAlign(TextAlign.Center)
              .fontWeight(FontWeight.Bold)
              .margin({ left: SizeConstant.SPACE_XL })
          }.width("100%").height(34)
        }
      }
      .backgroundColor(AppTheme.palette(this.themeType).commonBackground)
      .alignItems(HorizontalAlign.Start)
      .borderRadius({
        topLeft: SizeConstant.RADIUS_L * (1 - this.collapsibleProgress),
        topRight: SizeConstant.RADIUS_L * (1 - this.collapsibleProgress)
      })
    }
  }

  @Builder MusicTabItemBuilder(item: TabItem) {
    Text(item.name)
      .fontSize(SizeConstant.TEXT_M)
      .fontColor(this.musicTabMediator.currentIndex === item.index
        ? AppTheme.palette(this.themeType).firstText
        : AppTheme.palette(this.themeType).thirdText)
      .textAlign(TextAlign.Center)
      .fontWeight(this.musicTabMediator.currentIndex === item.index ? FontWeight.Bold : FontWeight.Normal)
      .height(34)
  }

  @Builder PodcastTabItemBuilder(item: TabItem) {
    Text(item.name)
      .fontSize(SizeConstant.TEXT_M)
      .fontColor(this.podcastTabMediator.currentIndex === item.index
        ? AppTheme.palette(this.themeType).firstText
        : AppTheme.palette(this.themeType).thirdText)
      .textAlign(TextAlign.Center)
      .fontWeight(this.podcastTabMediator.currentIndex === item.index ? FontWeight.Bold : FontWeight.Normal)
      .height(34)
  }

  @Builder ContentBuilder() {
    TabPager({ mediator: this.myTabMediator,
      TabPageBuilder: (index: number) => {
        this.MyTabPageBuilder(index)
      } })
  }

  @Builder MyTabPageBuilder(index: number) {
    if (index === 0) {
      this.MusicPageBuilder()
    } else if (index === 1) {
      this.PodcastPageBuilder()
    } else if (index === 2) {
      MyDynamicPage({
        mediator: this.collapsibleMediator,
        scroller: this.collapsibleMediator.getCurrentInnerScroller(this.musicTabItems.length + this.podcastTabItems.length)
      })
    }
  }

  @Builder MusicPageBuilder() {
    TabPager({ mediator: this.musicTabMediator,
      TabPageBuilder: (index: number) => {
        this.MusicTabPageBuilder(index)
      },
    })
  }

  @Builder MusicTabPageBuilder(index: number) {
    if (index === 0) {
      CreateMusicPage({
        mediator: this.collapsibleMediator,
        scroller: this.collapsibleMediator.getCurrentInnerScroller(index)
      })
    } else if (index === 1) {
      CollectMusicPage({
        mediator: this.collapsibleMediator,
        scroller: this.collapsibleMediator.getCurrentInnerScroller(index)
      })
    } else if (index === 2) {
      AlbumMusicPage({
        mediator: this.collapsibleMediator,
        scroller: this.collapsibleMediator.getCurrentInnerScroller(index)
      })
    }
  }

  @Builder PodcastPageBuilder() {
    TabPager({ mediator: this.podcastTabMediator,
      TabPageBuilder: (index: number) => {
        this.PodcastTabPageBuilder(index)
      },
    })
  }

  @Builder PodcastTabPageBuilder(index: number) {
    if (index === 0) {
      AllPodcastPage({
        mediator: this.collapsibleMediator,
        scroller: this.collapsibleMediator.getCurrentInnerScroller(index + this.musicTabItems.length)
      })
    } else if (index === 1) {
      MyPodcastPage({
        mediator: this.collapsibleMediator,
        scroller: this.collapsibleMediator.getCurrentInnerScroller(index + this.musicTabItems.length)
      })
    } else if (index === 2) {
      VoiceBookPage({
        mediator: this.collapsibleMediator,
        scroller: this.collapsibleMediator.getCurrentInnerScroller(index + this.musicTabItems.length)
      })
    }
  }

  @Builder headerBackgroundBuilder() {
    Image(this.userInfo.detail.profile.backgroundUrl).width('100%')
      .height(this.overScrollOffset + (300 + SizeConstant.RADIUS_L))
      .scale({
        x: ((300 + SizeConstant.RADIUS_L) + this.overScrollOffset) / (300 + SizeConstant.RADIUS_L),
        y: ((300 + SizeConstant.RADIUS_L) + this.overScrollOffset) / (300 + SizeConstant.RADIUS_L),
        centerX: "50%",
        centerY: "50%"
      })
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      this.headerBackgroundBuilder()
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
      }).onTouch((event: TouchEvent) => {
        this.handleOverScroll(event)
      })
    }
  }

  handleOverScroll(event: TouchEvent) {
    if (this.collapsibleProgress == 0) {
      if (event.type == TouchType.Down) {
        this.lastTouchX = event.touches[0].x
        this.lastTouchY = event.touches[0].y
      } else if (event.type == TouchType.Move) {
        const curTouchX = event.touches[0].x
        const curTouchY = event.touches[0].y
        const dx = curTouchX - this.lastTouchX
        const dy = curTouchY - this.lastTouchY
        if (Math.abs(dy) > Math.abs(dx)) {
          if (dy > 0) { // 向下滑动
            this.overScrollOffset = Math.min(this.overScrollOffset + dy, this.maxOverScrollOffset)
          }
        }
        this.lastTouchX = curTouchX
        this.lastTouchY = curTouchY
      } else if (event.type == TouchType.Up || event.type == TouchType.Cancel) {
        animateTo({
          duration: 200
        }, () => {
          this.overScrollOffset = 0
        })
      }
    } else {
      animateTo({
        duration: 200
      }, () => {
        this.overScrollOffset = 0
      })
    }
  }
}
