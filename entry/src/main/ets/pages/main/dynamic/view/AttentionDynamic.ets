import { PagingLayoutMediator, ViewState, ViewStatePagingLayout, } from 'lib_common'
import { AppTheme, THEME_TYPE, ThemeType } from 'lib_theme'
import { DynamicBean, CpnDynamicItem, attentionDynamicViewModel } from '../../../../'

@Component
export struct AttentionDynamicPage {
  @State pagingLayoutMediator: PagingLayoutMediator = new PagingLayoutMediator({})
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT

  @Builder ItemBuilder(item: DynamicBean) {
    CpnDynamicItem({ dynamicBean: item })
  }

  build() {
    ViewStatePagingLayout({
      mediator: $pagingLayoutMediator,
      ItemBuilder: (item: object,  _) => {
        this.ItemBuilder(item as DynamicBean)
      },
      keyGenerator: (item: object, _) => {
        return (item as DynamicBean).threadId
      },
      onLoadData: async (viewState: ViewState) => {
        attentionDynamicViewModel.getDynamicList(viewState, this.pagingLayoutMediator)
      },
    }).backgroundColor(AppTheme.palette(this.themeType).commonBackground)
  }
}