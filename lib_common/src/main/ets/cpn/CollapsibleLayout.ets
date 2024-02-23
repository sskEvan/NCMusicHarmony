/**
 * 折叠布局
 * 协调固定标题栏、可滚动头部、粘性头部、可滚动内容布局
 * 可折叠区域高度=可滚动头部高度-粘性头部高度
 */
@Component
export struct CollapsibleLayout {
  // 标题栏
  @BuilderParam private AppBarBuilder: () => void = null
  // 可滚动头部
  @BuilderParam private ScrollableHeaderBuilder: () => void = null
  // 粘性头部
  @BuilderParam private StickyHeaderBuilder: () => void = null
  // 页面内容部分，通常为列表
  @BuilderParam private ContentBuilder: () => void = null
  @ObjectLink private mediator: CollapsibleMediator

  // 标题栏高度
  @State private appBarHeight: number = 0
  // 可滚动头部高度
  @State private scrollableHeaderHeight: number = 0
  // 粘性头部高度
  @State private stickyHeaderHeight: number = 0
  //  组件高度
  @State private totalHeight: number = 0
  private lastProgress = 0


  calculateContentHeight() {
    if (this.totalHeight != 0 && this.stickyHeaderHeight != 0 && this.appBarHeight != 0) {
      return this.totalHeight - this.stickyHeaderHeight - this.appBarHeight
    }
    return 2000
  }

  /**
   * 计算可折叠区域高度、内容区域高度
   */
  calculateCoordinatorScrollableHeight() {
    if (this.appBarHeight != 0 && this.scrollableHeaderHeight != 0 && this.totalHeight != 0 && this.stickyHeaderHeight != 0) {
      this.mediator.coordinatorScrollableHeight = this.scrollableHeaderHeight - this.appBarHeight
    }
  }

  updateCollapsibleScrollProgress() {
    if (this.mediator.collapsibleScrollProgressCallback) {
      const progress = this.mediator.curCoordinatorOffset() / this.mediator.coordinatorScrollableHeight
      if (this.lastProgress != progress && Math.abs(this.lastProgress - progress) >= 0.01 || progress == 1) {
        // if (this.lastProgress != progress) {
        this.mediator.collapsibleScrollProgressCallback(progress)
        this.lastProgress = progress
      }
    }
  }

  @Builder BodyBuilder() {
    // 粘性头部
    Stack() {
      this.StickyHeaderBuilder()
    }.onAreaChange((_, newValue: Area) => {
      this.stickyHeaderHeight = newValue.height as number
      this.calculateCoordinatorScrollableHeight()
    })
    // .zIndex(100)

    Stack() {
      this.ContentBuilder()
    }.height(this.calculateContentHeight())
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Scroll(this.mediator.outScroller) {
        Column() {
          // 可滚动容器
          Stack() {
            this.ScrollableHeaderBuilder()
          }.onAreaChange((_, newValue: Area) => {
            this.scrollableHeaderHeight = newValue.height as number
            this.calculateCoordinatorScrollableHeight()
          })

          this.BodyBuilder()
        }
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .edgeEffect(EdgeEffect.None)
      .height(this.totalHeight != 0 ? this.totalHeight : 10000)
      .onScroll(() => {
        this.updateCollapsibleScrollProgress()
      })
      .onScrollFrameBegin((offset: number, _) => {
        if (offset > 0) { // 向上
          if (this.mediator.isShrink()) { // 可折叠区域完全折叠
            return { offsetRemain: 0 }
          } else {
            return { offsetRemain: offset }
          }
        }
        if (offset < 0) { // 向下
          if (this.mediator.isExpand()) { // 可折叠区域完全张开
            return { offsetRemain: 0 }
          } else {
            return { offsetRemain: offset }
          }
        }
        return { offsetRemain: offset }
      })


      // 固定标题栏
      Stack() {
        this.AppBarBuilder()
      }.width("100%")
      .onAreaChange((_, newValue: Area) => {
        this.appBarHeight = newValue.height as number
        this.calculateCoordinatorScrollableHeight()
      })

    }
    .width("100%")
    .onAreaChange((_, newValue: Area) => {
      this.totalHeight = newValue.height as number
      this.calculateCoordinatorScrollableHeight()
    })
  }
}

@Observed
export class CollapsibleMediator {
  // 内部可滚动容器集合
  innerScrollerArrays: Scroller[] = new Array<Scroller>()

  // 可折叠区域的高度(scrollableHeader-appBarHeight-stickyHeaderHeight)
  coordinatorScrollableHeight: number = 0
  curInnerScrollerIndex = 0


  // 可折叠区域滑动进度回调
  collapsibleScrollProgressCallback?: (progress: number) => void = null
  outScroller = new Scroller()

  constructor(coordinatorScrollProgressCallback: (progress: number) => void = null) {
    this.collapsibleScrollProgressCallback = coordinatorScrollProgressCallback
  }

  getCurrentInnerScroller(index?: number) {
    const curIndex = index ? index : 0
    if (this.innerScrollerArrays[curIndex] == null) {
      this.innerScrollerArrays[curIndex] = new Scroller()
    }
    return this.innerScrollerArrays[curIndex]
  }

  getCurrentInnerScrollerOffset() {
    return this.innerScrollerArrays[this.curInnerScrollerIndex].currentOffset()?.yOffset | 0
  }

  curCoordinatorOffset() {
    return this.outScroller.currentOffset().yOffset
  }

  getScrollerFrameRemainOffset(offset: number): number {
    if (!this.isShrink() && offset > 0) { // 向上
      this.outScroller.scrollBy(0, offset)
      return 0
    }
    if (this.getCurrentInnerScrollerOffset() == 0 && offset < 0) { // 向下
      this.outScroller.scrollBy(0, offset)
      return 0
    }
    return offset
  }

  setCurInnerScrollerIndex(index: number) {
    if (this.curInnerScrollerIndex !== index) {
      this.curInnerScrollerIndex = index
    }
  }

  isExpand() {
    return this.curCoordinatorOffset() === 0
  }

  isShrink() {
    return this.coordinatorScrollableHeight !== 0 && Math.abs(this.curCoordinatorOffset() - this.coordinatorScrollableHeight) <= 0.0001
  }

  expand() {
    this.outScroller.scrollTo({ xOffset: 0, yOffset: 0,
      animation: { duration: 300, curve: Curve.Linear } })
  }

  shrink() {
    this.outScroller.scrollTo({ xOffset: 0, yOffset: this.coordinatorScrollableHeight,
      animation: { duration: 300, curve: Curve.Linear } })
  }
}


