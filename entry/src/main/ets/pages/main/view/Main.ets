import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { SizeConstant } from 'lib_common'
import { DiscoveryPage, CpnMusicPlayBar, DynamicPage, MyPage, PodcastPage } from '../'
import { EventIds, MusicPlayController, PlayerStatus } from '../../..'
import emitter from '@ohos.events.emitter'

/**
 * 首页
 */
@Entry
@Component
struct MainPage {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  @State selectedIndex: number = 2
  private tabItems: TabItem[] = [new TabItem(0, "发现", $r('app.media.ic_nav_discovery')),
    new TabItem(1, "播客", $r('app.media.ic_nav_podcast')),
    new TabItem(2, "我的", $r('app.media.ic_nav_my')),
    new TabItem(3, "动态", $r('app.media.ic_nav_dynamic')),]
  // 播放状态
  @State playerStatus: PlayerStatus | undefined = undefined

  aboutToAppear() {
    MusicPlayController.init()
    // 监听播放状态
    emitter.on({ eventId: EventIds.PLAYER_STATUS }, (data) => {
      this.playerStatus = data.data.status
    })
  }


  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Tabs({
        index: this.selectedIndex,
        barPosition: BarPosition.End,
      }) {
        TabContent() {
          DiscoveryPage()
        }.tabBar(this.TabItemBuilder(this.tabItems[0]))
        .margin({ bottom: this.getContentMarginBottom() })

        TabContent() {
          PodcastPage()
        }.tabBar(this.TabItemBuilder(this.tabItems[1]))
        .margin({ bottom: this.getContentMarginBottom() })

        TabContent() {
          MyPage()
        }.tabBar(this.TabItemBuilder(this.tabItems[2]))
        .margin({ bottom: this.getContentMarginBottom() })

        TabContent() {
          DynamicPage()
        }.tabBar(this.TabItemBuilder(this.tabItems[3]))
        .margin({ bottom: this.getContentMarginBottom() })
      }
      .barMode(BarMode.Fixed)
      .barWidth('100%')
      .scrollable(false)
      .barHeight(SizeConstant.NAV_BAR_HEIGHT)
      .onChange((index: number) => {
        this.selectedIndex = index
      })

      if ((this.playerStatus ?? PlayerStatus.NONE) !== PlayerStatus.NONE) {
        CpnMusicPlayBar().margin({ bottom: SizeConstant.NAV_BAR_HEIGHT })
      }
    }
  }

  getContentMarginBottom(): number {
    return (this.playerStatus ?? PlayerStatus.NONE) ? SizeConstant.MUSIC_PLAY_BAR_HEIGHT : 0
  }

  @Builder TabItemBuilder(item: TabItem) {
    Column() {
      Image(item.icon)
        .width(SizeConstant.ICON_L)
        .height(SizeConstant.ICON_L)
        .margin({
          bottom: SizeConstant.SPACE_S
        })
        .fillColor(this.selectedIndex === item.index
          ? AppTheme.palette(this.themeType).primary
          : AppTheme.palette(this.themeType).thirdText)
      Text(item.name)
        .fontSize(SizeConstant.TEXT_S)
        .fontColor(this.selectedIndex === item.index
          ? AppTheme.palette(this.themeType).primary
          : AppTheme.palette(this.themeType).thirdIcon)
        .textAlign(TextAlign.Center)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .height(SizeConstant.NAV_BAR_HEIGHT)
    .width("100%")
    .backgroundColor(AppTheme.palette(this.themeType).navBarBackground)
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

class TabItem {
  index: number
  name: string
  icon: Resource

  constructor(index: number, name: string, icon: Resource) {
    this.index = index
    this.name = name
    this.icon = icon
  }
}