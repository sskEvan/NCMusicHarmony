import { PagingLayoutMediator, ViewState } from 'lib_common'
import { CollapsibleMediator, ViewStatePagingLayout } from 'lib_common'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { AlbumBean, albumViewModel, CpnAlbumItem } from '../../../../..'

/**
 * 首页-我的-音乐-专辑页面
 */
@Component
export struct AlbumMusicPage {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  mediator: CollapsibleMediator
  scroller: Scroller
  @State pagingLayoutMediator: PagingLayoutMediator = new PagingLayoutMediator({})

  aboutToAppear() {
    this.pagingLayoutMediator = new PagingLayoutMediator({
      enableLoadMore: true,
      enableRefresh: false,
      collapsibleMediator: this.mediator,
      scroller: this.scroller
    })
  }

  @Builder ItemBuilder(item: object) {
    CpnAlbumItem({ albumBean: item as AlbumBean })
  }

  build() {
    ViewStatePagingLayout({
      mediator: $pagingLayoutMediator,
      ItemBuilder: (item: object, _) => {
        this.ItemBuilder(item)
      },
      onLoadData: (viewState: ViewState) => {
        albumViewModel.getAlbumList(viewState, this.pagingLayoutMediator)
      },
    }).backgroundColor(AppTheme.palette(this.themeType).commonBackground)
  }
}


