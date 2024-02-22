import { SizeConstant, TabItem, TabLayout, TabLayoutPagerMediator, TabPager } from 'lib_common'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { CurrentMusicPlayList, HistoryMusicPlayList } from '../../../..'

/**
 * 音乐播放列表底部弹框
 */
@CustomDialog
export struct MusicPlayListDialog {
  controller: CustomDialogController
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  private tabItems: TabItem[] = [new TabItem(0, "历史播放"), new TabItem(1, "当前播放")]
  @State private tabMediator: TabLayoutPagerMediator = new TabLayoutPagerMediator({
    currentIndex: 1,
    tabItems: this.tabItems,
  })

  @Builder TabPageBuilder(index: number) {
    if (index == 0) {
      HistoryMusicPlayList()
    } else {
      CurrentMusicPlayList()
    }
  }

  build() {
    Column() {
      TabLayout({ mediator: this.tabMediator, }).margin({ top: SizeConstant.SPACE_S, bottom: SizeConstant.SPACE_S })
      TabPager({ mediator: this.tabMediator,
        TabPageBuilder: (index: number) => {
          this.TabPageBuilder(index)
        } }).layoutWeight(1)
    }
    .width("100%")
    .height("70%")
    .backgroundColor(AppTheme.palette(this.themeType).commonBackground)
    .borderRadius(SizeConstant.RADIUS_L)
    .justifyContent(FlexAlign.Start)
  }

}