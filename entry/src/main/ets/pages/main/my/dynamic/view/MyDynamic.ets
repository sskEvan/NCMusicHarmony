import { CollapsibleMediator, PagingLayoutMediator, ViewState, ViewStatePagingLayout } from 'lib_common'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { DynamicBean, UserManager, userDynamicViewModel, CpnDynamicItem} from '../../../../..'

/**
 * 首页-我的-动态页面
 */
@Component
export struct MyDynamicPage {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  mediator: CollapsibleMediator
  scroller: Scroller
  @State pagingLayoutMediator: PagingLayoutMediator = new PagingLayoutMediator({})

  aboutToAppear() {
    this.pagingLayoutMediator = new PagingLayoutMediator({
      enableRefresh: false,
      enableLoadMore: true,
      collapsibleMediator: this.mediator,
      scroller: this.scroller
    })
  }

  @Builder ItemBuilder(item: DynamicBean) {
    CpnDynamicItem({ dynamicBean: item })
  }

  build() {
    ViewStatePagingLayout({
      mediator: $pagingLayoutMediator,
      ItemBuilder: (item: object) => {
        this.ItemBuilder(item as DynamicBean)
      },
      onLoadData: async (viewState: ViewState) => {
        userDynamicViewModel.getUserDynamicList((await UserManager.getUserInfo()).detail.profile.userId, viewState, this.pagingLayoutMediator)
      },
    }).backgroundColor(AppTheme.palette(this.themeType).commonBackground)
  }
}
