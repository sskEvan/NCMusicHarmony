import { ViewState, ViewStateType } from '.'
import { CollapsibleMediator, RefreshLayout, RefreshMediator } from '..'
import { ListDataSource } from '../..'
import { ViewStateEmpty } from './ViewStateEmpty'
import { ViewStateError } from './ViewStateError'
import { ViewStateLoading } from './ViewStateLoading'

@Component
export struct ViewStatePagingLayout {
  @State @Watch("viewStateChange") viewState: ViewState = new ViewState(ViewStateType.LOADING)
  @Link mediator: PagingLayoutMediator
  onLoadData: (viewState: ViewState) => void = () => {
  }
  onRefresh: (viewState: ViewState) => void = null
  onLoadMore: (viewState: ViewState) => void = null
  layoutType: PagingLayoutType = PagingLayoutType.LIST
  columnsTemplate: string = "1fr 1fr"
  keyGenerator?: (item: object, index: number) => string

  onRetry() {
    this.onLoadData(this.viewState)
  }

  aboutToAppear() {
    this.onLoadData(this.viewState)
  }

  viewStateChange() {
    if (this.viewState.type == ViewStateType.SUCCESS) {
      this.mediator.refreshMediator.enableRefresh = this.mediator.enableRefresh
      this.mediator.refreshMediator.enableLoadMore = this.mediator.enableLoadMore
    } else {
      this.mediator.refreshMediator.enableRefresh = false
      this.mediator.refreshMediator.enableLoadMore = false
    }
  }

  @BuilderParam ItemBuilder: (item: object, index: number) => void

  @Builder ContentBuilder() {
    if (this.viewState.type == ViewStateType.SUCCESS) {
      // List({ scroller: this.mediator.scroller, space: 0 }) {
      //   LazyForEach(this.mediator.lazyDataSource,
      //     (item, index) => {
      //       ListItem() {
      //         this.ItemBuilder(item, index)
      //       }
      //     },
      //     (item: object) => {
      //       return JSON.stringify(item)
      //     }
      //   )
      // }
      // .height("100%")
      // .width("100%")
      // .edgeEffect(EdgeEffect.None)
      // .onReachEnd(() => {
      //   this.mediator.refreshMediator.scrollerReachEnd()
      // })
      // .onAreaChange((_, newValue: Area) => {
      //   this.mediator.refreshMediator.scrollerAreaChange(newValue)
      // })
      // .onScrollFrameBegin((offset: number, _) => {
      //   if (this.mediator.refreshMediator.isShowNoMoreData() && offset < 0) {
      //     return { offsetRemain: 0 }
      //   } else {
      //     return {
      //       offsetRemain: this.mediator.collapsibleMediator?.getScrollerFrameRemainOffset(offset)
      //       || this.mediator.refreshMediator.getScrollerFrameRemainOffset(offset, this.mediator.collapsibleMediator == null)
      //     }
      //   }
      // })

      if (this.layoutType == PagingLayoutType.GRID) {
        this.GridPagingBuilder(this.columnsTemplate)
      } else if (this.layoutType == PagingLayoutType.WATER_FLOW) {
        this.WaterFlowPagingBuilder(this.columnsTemplate)
      } else {
        this.ListPagingBuilder()
      }
    } else {
      List({ scroller: this.mediator.scroller }) {
        ListItem() {
          if (this.viewState.type === ViewStateType.LOADING) {
            ViewStateLoading({ yPosition: this.mediator.collapsibleMediator ? "20%" : "40%" })
          } else if (this.viewState.type === ViewStateType.EMPTY) {
            ViewStateEmpty({ yPosition: this.mediator.collapsibleMediator ? "20%" : "40%", retryCallback: () => {
              this.onRetry()
            } })
          } else if (this.viewState.type === ViewStateType.ERROR) {
            ViewStateError({
              yPosition: this.mediator.collapsibleMediator ? "20%" : "40%",
              errorCode: this.viewState.errorCode,
              errorMessage: this.viewState.errorMessage,
              retryCallback: () => {
                this.onRetry()
              }
            })
          }
        }
      }
      .edgeEffect(EdgeEffect.None)
      .height("100%")
      .width("100%")
      .cachedCount(2)
      .onScrollFrameBegin((offset: number) => {
        return { offsetRemain: this.mediator.collapsibleMediator?.getScrollerFrameRemainOffset(offset) || 0 }
      })
    }
  }

  @Builder
  ListPagingBuilder() {
    List({ scroller: this.mediator.scroller, space: 0 }) {
      LazyForEach(this.mediator.lazyDataSource,
        (item, index) => {
          ListItem() {
            this.ItemBuilder(item, index)
          }
        },
        // (item: object) => {
        //   return JSON.stringify(item)
        // }
        (item, index) => {
          if (this.keyGenerator) {
            return this.keyGenerator(item, index)
          } else {
            return JSON.stringify(item)
          }
        }
      )
    }
    .height("100%")
    .width("100%")
    .edgeEffect(EdgeEffect.None)
    .onReachEnd(() => {
      this.mediator.refreshMediator.scrollerReachEnd()
    })
    .onAreaChange((_, newValue: Area) => {
      this.mediator.refreshMediator.scrollerAreaChange(newValue)
    })
    .onScrollFrameBegin((offset: number, _) => {
      if (this.mediator.refreshMediator.isShowNoMoreData() && offset < 0) {
        return { offsetRemain: 0 }
      } else {
        return {
          offsetRemain: this.mediator.collapsibleMediator?.getScrollerFrameRemainOffset(offset)
          || this.mediator.refreshMediator.getScrollerFrameRemainOffset(offset, this.mediator.collapsibleMediator == null)
        }
      }
    })
  }

  // api9暂不支持onReachEnd、onScrollFrameBegin等回调
  @Builder
  GridPagingBuilder(columnsTemplate: string) {

  }

  // api9暂不支持onReachEnd、onScrollFrameBegin等回调
  @Builder
  WaterFlowPagingBuilder(columnsTemplate: string) {

  }

  build() {
    RefreshLayout({ refreshMediator: this.mediator.refreshMediator,
      ContentBuilder: () => {
        this.ContentBuilder()
      },
      onRefresh: () => {
        this.mediator.page = 1
        if (this.onRefresh) {
          this.onRefresh(this.viewState)
        } else {
          this.onLoadData(this.viewState)
        }
      },
      onLoadMore: () => {
        this.mediator.page += 1
        if (this.onLoadMore) {
          this.onLoadMore(this.viewState)
        } else {
          this.onLoadData(this.viewState)
        }
      }
    })
  }
}

export enum PagingLayoutType {
  // 普通列表
  LIST,
  // 网格列表
  GRID,
  // 瀑布流列表
  WATER_FLOW
}

interface IPagingLayoutMediator {
  collapsibleMediator?: CollapsibleMediator
  lazyDataSource?: ListDataSource
  scroller?: Scroller
  page?: number
  pageCount?: number
  enableRefresh?: boolean
  enableLoadMore?: boolean
}

export class PagingLayoutMediator {
  collapsibleMediator?: CollapsibleMediator = null
  lazyDataSource: ListDataSource = new ListDataSource()
  scroller: Scroller = this.collapsibleMediator?.getCurrentInnerScroller() || new Scroller()
  refreshMediator: RefreshMediator = new RefreshMediator({
    enableRefresh: false,
    enableLoadMore: false,
    scroller: this.scroller
  })
  page: number = 1
  pageCount: number = 20
  enableRefresh: boolean = true
  enableLoadMore: boolean = true

  constructor(mediator: IPagingLayoutMediator) {
    if (mediator.collapsibleMediator) {
      this.collapsibleMediator = mediator.collapsibleMediator
    }
    if (mediator.lazyDataSource) {
      this.lazyDataSource = mediator.lazyDataSource
    }
    if (mediator.scroller) {
      this.scroller = mediator.scroller
      this.refreshMediator = new RefreshMediator({
        scroller: this.scroller,
        enableRefresh: false,
        enableLoadMore: false
      })
    }
    if (mediator.page != undefined) {
      this.page = mediator.page
    }
    if (mediator.enableRefresh != undefined) {
      this.enableRefresh = mediator.enableRefresh
    }
    if (mediator.enableLoadMore != undefined) {
      this.enableLoadMore = mediator.enableLoadMore
    }
    if (mediator.page) {
      this.page = mediator.page
    }
    if (mediator.pageCount) {
      this.page = mediator.pageCount
    }
  }

  finishRefresh(success: boolean, list?: object[]) {
    if (list) {
      this.lazyDataSource.reloadData(list)
      this.refreshMediator.setNoMoreData(list.length < this.pageCount)
    }

    this.refreshMediator.finishRefresh(success)
  }

  finishLoadMore(success: boolean, list?: object[]) {
    if (list && success) {
      for (let index = 0; index < list.length; index++) {
        this.lazyDataSource.pushData(list[index])
      }
      this.refreshMediator.setNoMoreData(list.length < this.pageCount)
    }
    this.refreshMediator.finishLoadMore(success)
    if (!success) {
      this.page -= 1
    }
  }
}
