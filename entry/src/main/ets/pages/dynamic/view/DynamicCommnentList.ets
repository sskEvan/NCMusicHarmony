import { CollapsibleMediator, PagingLayoutMediator, ViewState, ViewStatePagingLayout } from 'lib_common'
import { ThemeType, THEME_TYPE } from 'lib_theme'
import { CommentBean, CpnCommentItem, dynamicCommentViewModel } from '../../..'

/**
 * 动态评论页面
 */
@Component
export struct DynamicCommentListPage {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  mediator: CollapsibleMediator
  scroller: Scroller
  @State pagingLayoutMediator: PagingLayoutMediator = new PagingLayoutMediator({})
  commentId: string

  aboutToAppear() {
    this.pagingLayoutMediator = new PagingLayoutMediator({
      enableLoadMore: true,
      enableRefresh: false,
      collapsibleMediator: this.mediator,
      scroller: this.scroller
    })
  }

  @Builder ItemBuilder(item: CommentBean) {
    CpnCommentItem({ bean: item })
  }

  build() {
    ViewStatePagingLayout({
      mediator: $pagingLayoutMediator,
      ItemBuilder: (item: object, _) => {
        this.ItemBuilder(item as CommentBean)
      },
      onLoadData: (viewState: ViewState) => {
        dynamicCommentViewModel.getCommentList(this.commentId, viewState, this.pagingLayoutMediator)
      },
    })
  }
}
