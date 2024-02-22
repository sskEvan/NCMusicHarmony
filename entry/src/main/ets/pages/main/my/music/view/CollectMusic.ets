import { CollapsibleMediator, PagingLayoutMediator, ViewState, ViewStatePagingLayout } from 'lib_common'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { UserPlaylistBean, UserManager, songSheetViewModel, CpnSongSheetItem } from '../../../../..'

/**
 * 首页-我的-音乐-收藏页面
 */
@Component
export struct CollectMusicPage {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  mediator: CollapsibleMediator
  scroller: Scroller
  @State pagingLayoutMediator: PagingLayoutMediator = new PagingLayoutMediator({})

  aboutToAppear() {
    this.pagingLayoutMediator = new PagingLayoutMediator({
      enableLoadMore: false,
      enableRefresh: false,
      collapsibleMediator: this.mediator,
      scroller: this.scroller
    })
  }

  @Builder ItemBuilder(item: object) {
    CpnSongSheetItem({ playListBean: item as UserPlaylistBean })
  }

  build() {
    ViewStatePagingLayout({
      mediator: $pagingLayoutMediator,
      ItemBuilder: (item: object, _) => {
        this.ItemBuilder(item)
      },
      onLoadData: async (viewState: ViewState) => {
        songSheetViewModel.getUserPlayList((await UserManager.getUserInfo()).detail.profile.userId, false, viewState, this.pagingLayoutMediator)
      },
    }).backgroundColor(AppTheme.palette(this.themeType).commonBackground)
  }
}