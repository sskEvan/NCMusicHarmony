import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { SizeConstant } from '../constant/SizeConstant'
import { CpnLoading } from './CpnLoading'

/**
 * 下拉刷新、上拉加载更多布局
 */
@Component
export struct RefreshLayout {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  @ObjectLink @Watch("refreshMediatorChanged") refreshMediator: RefreshMediator
  @State private refreshIndicatorHeight: number = 0
  @State private contentHeight: number = 0
  @State private defaultRefreshIndicatorArrowAngle: number = 180
  @BuilderParam ContentBuilder: () => void
  @BuilderParam RefreshIndicatorBuilder: () => void = null
  @BuilderParam LoadMoreIndicatorBuilder: () => void = null
  private lastTouchX = 0
  private lastTouchY = 0
  onRefresh: () => void = null
  onLoadMore: () => void = null

  refreshMediatorChanged() {
    if (this.refreshMediator.refreshStatus == RefreshStatusType.REFRESH_SUCCESS ||
    this.refreshMediator.refreshStatus == RefreshStatusType.REFRESH_FAIL) {
      this.defaultRefreshIndicatorArrowAngle = 180
      animateTo({
        duration: 300,
        onFinish: () => {
          this.refreshMediator.refreshStatus = RefreshStatusType.IDLE
        }
      }, () => {
        this.refreshMediator.indicatorOffset = 0
      })
    } else if (this.refreshMediator.loadMoreStatus == LoadMoreStatusType.LOAD_MORE_SUCCESS ||
    this.refreshMediator.loadMoreStatus == LoadMoreStatusType.LOAD_MORE_FAIL) {
      this.refreshMediator.scroller.scrollBy(0, this.refreshMediator.loadMoreIndicatorHeight)
      this.defaultRefreshIndicatorArrowAngle = 0
      animateTo({
        duration: 300,
        onFinish: () => {
          this.refreshMediator.loadMoreStatus = LoadMoreStatusType.IDLE
        }
      }, () => {
        this.refreshMediator.indicatorOffset = 0
      })
    }
    if (!this.RefreshIndicatorBuilder) {
      if (this.refreshMediator.indicatorOffset > 0) {
        if (this.refreshMediator.refreshStatus === RefreshStatusType.PULL_TO_REFRESH) {
          animateTo({
            duration: 300,
          }, () => {
            this.defaultRefreshIndicatorArrowAngle = 180
          })
        } else if (this.refreshMediator.refreshStatus === RefreshStatusType.RELEASE_TO_REFRESH) {
          animateTo({
            duration: 300,
          }, () => {
            this.defaultRefreshIndicatorArrowAngle = 0
          })
        }
      }
    }
  }

  aboutToAppear() {
    this.refreshMediator.onLoadMore = this.onLoadMore
  }

  build() {
    RelativeContainer() {
      Stack({ alignContent: Alignment.Top }) {
        this.ContentBuilder()
      }
      .alignRules({
        left: { anchor: '__container__', align: HorizontalAlign.Start },
        top: { anchor: '__container__', align: VerticalAlign.Top },
      })
      .id("body")
      .onAreaChange((_, newValue: Area) => {
        this.contentHeight = newValue.height as number
      })
      .height("100%")
      .offset({ x: 0, y: this.refreshMediator.indicatorOffset })


      if (this.refreshMediator.enableRefresh) {
        Stack() {
          if (this.RefreshIndicatorBuilder) {
            this.RefreshIndicatorBuilder()
          } else {
            this.DefaultRefreshIndicatorBuilder()
          }
        }
        .alignRules({
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          top: { anchor: '__container__', align: VerticalAlign.Top },
        })
        .id("refreshIndicator")
        .offset({ x: 0, y: -this.refreshIndicatorHeight + this.refreshMediator.indicatorOffset })
        .onAreaChange((_, newValue: Area) => {
          this.refreshIndicatorHeight = newValue.height as number
        })
      }

      if (this.refreshMediator.enableLoadMore) {
        Stack() {
          if (this.LoadMoreIndicatorBuilder) {
            this.LoadMoreIndicatorBuilder()
          } else {
            this.DefaultLoadMoreIndicatorBuilder()
          }
        }
        .alignRules({
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
        })
        .id("loadMoreIndicator")
        .offset({
          x: 0,
          y: this.refreshMediator.loadMoreIndicatorHeight + this.refreshMediator.indicatorOffset
        })
        .onAreaChange((_, newValue: Area) => {
          this.refreshMediator.loadMoreIndicatorHeight = newValue.height as number
        })
      }
    }.width("100%")
    .height("100%")
    .onTouch((event: TouchEvent) => {
      this.handleTouch(event)
    })
    .clip(true)

  }

  @Builder DefaultRefreshIndicatorBuilder() {
    Stack({ alignContent: Alignment.Start }) {
      Text(this.getRefreshTipText())
        .width("100%")
        .textAlign(TextAlign.Center)
        .fontSize(SizeConstant.TEXT_M)
        .fontColor(AppTheme.palette(this.themeType).firstText)
      if (this.refreshMediator.refreshStatus !== RefreshStatusType.REFRESH_SUCCESS
      && this.refreshMediator.refreshStatus !== RefreshStatusType.REFRESH_FAIL) {
        if (this.refreshMediator.refreshStatus === RefreshStatusType.REFRESHING) {
          CpnLoading({ loadingWidth: 14, loadingHeight: 12 }).margin({ left: 120 })
        } else {
          Image($r('app.media.ic_arrow_up'))
            .fillColor(AppTheme.palette(this.themeType).firstText)
            .width(SizeConstant.ICON_M)
            .height(SizeConstant.ICON_M)
            .margin({ left: 120 })
            .rotate({
              centerX: "50%",
              centerY: "50%",
              angle: this.defaultRefreshIndicatorArrowAngle
            })
        }
      }

    }.width("100%").height(50)
  }

  getRefreshTipText() {
    if (this.refreshMediator.refreshStatus == RefreshStatusType.RELEASE_TO_REFRESH) {
      return "释放刷新"
    } else if (this.refreshMediator.refreshStatus == RefreshStatusType.REFRESHING) {
      return "正在刷新..."
    } else if (this.refreshMediator.refreshStatus == RefreshStatusType.REFRESH_SUCCESS) {
      return "刷新成功"
    } else if (this.refreshMediator.refreshStatus == RefreshStatusType.REFRESH_FAIL) {
      return "刷新失败"
    } else {
      return "下拉刷新"
    }
  }

  @Builder DefaultLoadMoreIndicatorBuilder() {
    Stack({ alignContent: Alignment.Start }) {
      Text(this.getLoadMoreTipText())
        .width("100%")
        .textAlign(TextAlign.Center)
        .fontSize(SizeConstant.TEXT_M)
        .fontColor(AppTheme.palette(this.themeType).firstText)
      if (!this.refreshMediator.noMoreData) {
        if (this.refreshMediator.loadMoreStatus === LoadMoreStatusType.LOAD_MORE_ING
        // || this.refreshMediator.loadMoreStatus === LoadMoreStatusType.IDLE
        ) {
          CpnLoading({ loadingWidth: 14, loadingHeight: 12 }).margin({ left: 120 })
        }
      }

    }.width("100%").height(50)
  }

  getLoadMoreTipText() {
    if (this.refreshMediator.noMoreData) {
      return "-- 没有更多数据了 --"
    } else {
      if (this.refreshMediator.loadMoreStatus == LoadMoreStatusType.LOAD_MORE_SUCCESS) {
        return "加载更多成功"
      } else if (this.refreshMediator.loadMoreStatus == LoadMoreStatusType.LOAD_MORE_FAIL) {
        return "加载更多失败"
      } else {
        return "加载更多..."
      }
    }
  }

  private handleTouch(event: TouchEvent) {
    if (this.refreshMediator.isReachTopAndBottom(this.contentHeight)) { // 需要同时处理下拉刷新和加载更多
      if (this.refreshMediator.isAllowHandleRefresh() || this.refreshMediator.isAllowHandleLoadMore()) {
        this.handleRefreshAndLoadMore(event)
      }
    } else {
      if (this.refreshMediator.isReachTop()) {
        if (this.refreshMediator.isAllowHandleRefresh()) { // 处理下拉刷新
          this.handleRefresh(event)
        }
      }
      else if (this.refreshMediator.isReachBottom() || this.refreshMediator.isShowNoMoreData()) {
        if (this.refreshMediator.isAllowHandleLoadMore()) { // 处理上拉加载更多
          this.handleLoadMore(event)
        }
      }
    }
  }

  private handleRefresh(event: TouchEvent) {
    if (event.type == TouchType.Down) {
      this.lastTouchX = event.touches[0].x
      this.lastTouchY = event.touches[0].y
    } else if (event.type == TouchType.Move) {
      const curTouchX = event.touches[0].x
      const curTouchY = event.touches[0].y
      const dx = curTouchX - this.lastTouchX
      const dy = curTouchY - this.lastTouchY
      if (Math.abs(dy) > Math.abs(dx)) {
        this.handleRefreshTouchMove(dy)
      }
      this.lastTouchX = curTouchX
      this.lastTouchY = curTouchY
    } else if (event.type == TouchType.Up || event.type == TouchType.Cancel) {
      this.handleRefreshTouchUp()
    }
  }

  private handleRefreshTouchMove(dy: number) {
    this.refreshMediator.indicatorOffset = Math.max(0, Math.min(this.refreshMediator.indicatorOffset + dy, this.refreshIndicatorHeight * 1.5))
    if (this.refreshMediator.indicatorOffset < this.refreshIndicatorHeight) {
      this.refreshMediator.refreshStatus = RefreshStatusType.PULL_TO_REFRESH
    } else if (this.refreshMediator.indicatorOffset >= this.refreshIndicatorHeight) {
      this.refreshMediator.refreshStatus = RefreshStatusType.RELEASE_TO_REFRESH
    }
  }

  private handleRefreshTouchUp() {
    if (this.refreshMediator.refreshStatus === RefreshStatusType.PULL_TO_REFRESH) {
      animateTo({
        duration: 300,
        onFinish: () => {
          this.refreshMediator.refreshStatus = RefreshStatusType.IDLE
        }
      }, () => {
        this.refreshMediator.indicatorOffset = 0
      })
    } else if (this.refreshMediator.refreshStatus === RefreshStatusType.RELEASE_TO_REFRESH) {
      animateTo({
        duration: 300,
        onFinish: () => {
          this.refreshMediator.refreshStatus = RefreshStatusType.REFRESHING
          if (this.onRefresh) {
            this.onRefresh()
          }
        }
      }, () => {
        this.refreshMediator.indicatorOffset = this.refreshIndicatorHeight
      })
    }
  }

  private handleLoadMore(event: TouchEvent) {
    if (event.type == TouchType.Down) {
      this.lastTouchX = event.touches[0].x
      this.lastTouchY = event.touches[0].y
    } else if (event.type == TouchType.Move) {
      const curTouchX = event.touches[0].x
      const curTouchY = event.touches[0].y
      const dx = curTouchX - this.lastTouchX
      const dy = curTouchY - this.lastTouchY
      if (Math.abs(dy) > Math.abs(dx)) {
        this.handleLoadMoreTouchMove(dy)
      }
      this.lastTouchX = curTouchX
      this.lastTouchY = curTouchY
    } else if (event.type == TouchType.Up || event.type == TouchType.Cancel) {
      this.handleLoadMoreTouchUp()
    }
  }

  private handleLoadMoreTouchMove(dy: number) {
    this.refreshMediator.indicatorOffset = Math.min(0, Math.max(this.refreshMediator.indicatorOffset + dy, -this.refreshMediator.loadMoreIndicatorHeight))
  }

  private handleLoadMoreTouchUp() {
    this.refreshMediator.loadMore()
  }

  private handleRefreshAndLoadMore(event: TouchEvent) {
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
          this.handleRefreshTouchMove(dy)
        } else if (dy < 0) { // 向上滑动
          this.handleLoadMoreTouchMove(dy)
        }
      }
      this.lastTouchX = curTouchX
      this.lastTouchY = curTouchY
    } else if (event.type == TouchType.Up || event.type == TouchType.Cancel) {
      if (this.refreshMediator.indicatorOffset > 0) {
        this.handleRefreshTouchUp()
      } else if (this.refreshMediator.indicatorOffset < 0) {
        this.handleLoadMoreTouchUp()
      }
    }
  }
}

/**
 * 下拉刷新状态
 */
export enum RefreshStatusType {
  // 空闲状态
  IDLE,
  // 下拉刷新
  PULL_TO_REFRESH,
  // 释放刷新
  RELEASE_TO_REFRESH,
  // 刷新中
  REFRESHING,
  // 刷新成功
  REFRESH_SUCCESS,
  // 刷新失败
  REFRESH_FAIL,
}

/**
 * 上拉加载更多状态
 */
export enum LoadMoreStatusType {
  // 空闲状态
  IDLE,
  // 加载更多中
  LOAD_MORE_ING,
  // 加载更多成功
  LOAD_MORE_SUCCESS,
  // 加载更多失败
  LOAD_MORE_FAIL,
}

interface IRefreshMediator {
  enableRefresh?: boolean
  enableLoadMore?: boolean
  scroller?: Scroller
}

@Observed
export class RefreshMediator {
  enableRefresh: boolean = true
  enableLoadMore: boolean = true
  refreshStatus: RefreshStatusType = RefreshStatusType.IDLE
  loadMoreStatus: LoadMoreStatusType = LoadMoreStatusType.IDLE
  indicatorOffset: number = 0
  scroller: Scroller = new Scroller()
  maxScrollerOffset: number = 0
  listHeight: number = 0
  noMoreData: boolean = false
  onLoadMore: () => void = null
  loadMoreIndicatorHeight: number = 0

  constructor(mediator?: IRefreshMediator) {
    if (mediator != null && mediator.enableRefresh !== undefined) {
      this.enableRefresh = mediator.enableRefresh
    }
    if (mediator != null && mediator.enableLoadMore !== undefined) {
      this.enableLoadMore = mediator.enableLoadMore
    }
    if (mediator != null && mediator.scroller != undefined) {
      this.scroller = mediator.scroller
    }
  }

  scrollerReachEnd() {
    this.maxScrollerOffset = (this.scroller.currentOffset()?.yOffset || 0)
    if (this.scroller.currentOffset()?.yOffset || 0 != 0) {
      this.loadMore()
    }
  }

  scrollerAreaChange(newValue: Area) {
    this.listHeight = newValue.height as number
  }

  getScrollerFrameRemainOffset(offset: number, remain: Boolean = true): number {
    let offsetRemain = ((this.indicatorOffset != 0
    && this.refreshStatus != RefreshStatusType.REFRESHING
    && this.loadMoreStatus != LoadMoreStatusType.LOAD_MORE_ING)
    || this.isShowNoMoreData()) ? 0 : offset
    if (!remain) {
      offsetRemain = 0
    }
    return offsetRemain
  }

  finishRefresh(success: boolean) {
    if (this.refreshStatus == RefreshStatusType.REFRESHING) {
      this.refreshStatus = success ? RefreshStatusType.REFRESH_SUCCESS : RefreshStatusType.REFRESH_FAIL
    }
  }

  finishLoadMore(success: boolean) {
    this.loadMoreStatus = success ? LoadMoreStatusType.LOAD_MORE_SUCCESS : LoadMoreStatusType.LOAD_MORE_FAIL
  }

  setNoMoreData(noMoreData: boolean) {
    this.noMoreData = noMoreData
  }

  isReachTop(): boolean {
    return (this.scroller.currentOffset()?.yOffset || 0) <= 0.1
  }

  isReachBottom(): boolean {
    if (this.maxScrollerOffset === 0) {
      return false
    } else {
      return Math.abs((this.scroller.currentOffset()?.yOffset || 0) - this.maxScrollerOffset) <= 0.001
    }
  }

  isAllowHandleRefresh(): boolean {
    return this.enableRefresh &&
    this.refreshStatus != RefreshStatusType.REFRESHING &&
    this.loadMoreStatus != LoadMoreStatusType.LOAD_MORE_ING
  }

  isAllowHandleLoadMore(): boolean {
    return this.enableLoadMore &&
    this.refreshStatus != RefreshStatusType.REFRESHING &&
    this.loadMoreStatus != LoadMoreStatusType.LOAD_MORE_ING
  }

  isReachTopAndBottom(contentHeight) {
    return contentHeight > this.listHeight
  }

  loadMore() {
    if (this.enableLoadMore) {
      if (this.loadMoreStatus === LoadMoreStatusType.IDLE) {
        animateTo({
          duration: 300,
          onFinish: () => {
            if (!this.noMoreData && this.onLoadMore && this.enableLoadMore) {
              this.loadMoreStatus = LoadMoreStatusType.LOAD_MORE_ING
              this.onLoadMore()
            }
          }
        }, () => {
          this.indicatorOffset = -this.loadMoreIndicatorHeight
        })
      }
    }
  }

  isShowNoMoreData() {
    return this.noMoreData && this.indicatorOffset < 0
  }
}



