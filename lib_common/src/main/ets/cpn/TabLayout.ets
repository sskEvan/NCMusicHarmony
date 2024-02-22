import { SizeConstant } from '../constant/SizeConstant'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import VelocityTracker from '../util/VelocityTracker'
import { LogUtil } from '..'
import animator, { AnimatorOptions, AnimatorResult } from '@ohos.animator'

/**
 * 固定宽度TabLayout
 */
@Component
export struct TabLayout {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  @ObjectLink mediator: TabLayoutPagerMediator
  @State tabItemWidth: number = 0
  @BuilderParam TabItemBuilder: (item: TabItem) => void = null
  @BuilderParam TabIndicatorBuilder: () => void = null
  indexChanged: (item: number) => void = null
  showIndicator: boolean = true

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Row() {
        ForEach(this.mediator.tabItems, (item: TabItem) => {
          Stack({ alignContent: Alignment.Center }) {
            if (this.TabItemBuilder) {
              this.TabItemBuilder(item)
            } else {
              this.DefaultTabItemBuilder(item)
            }
          }.layoutWeight(1)
          .onAreaChange((_, newValue: Area) => {
            this.tabItemWidth = newValue.width as number
          })
          .onClick(() => {
            if (this.indexChanged) {
              this.indexChanged(item.index)
            }
            this.mediator.jumpToIndex(item.index)
          })
        }, item => item.index)
      }

      if (this.showIndicator) {
        Stack({ alignContent: Alignment.Bottom }) {
          if (this.TabIndicatorBuilder) {
            this.TabIndicatorBuilder()
          } else {
            this.DefaultTabIndicatorBuilder()
          }
        }
        .offset({ x: this.mediator.currentIndex * this.tabItemWidth })
        .width(this.tabItemWidth)
      }
    }
  }

  @Builder
  DefaultTabItemBuilder(item: TabItem) {
    Text(item.name)
      .fontSize(SizeConstant.TEXT_L)
      .fontColor(this.mediator.currentIndex === item.index
        ? AppTheme.palette(this.themeType).firstText
        : AppTheme.palette(this.themeType).thirdText)
      .textAlign(TextAlign.Center)
      .fontWeight(FontWeight.Bold)
      .height(SizeConstant.TAB_LAYOUT_HEIGHT)
  }

  @Builder
  DefaultTabIndicatorBuilder() {
    Divider()
      .strokeWidth(SizeConstant.TAB_LAYOUT_INDICATOR_HEIGHT)
      .margin({ bottom: SizeConstant.SPACE_S })
      .color(AppTheme.palette(this.themeType).primary)
      .width(SizeConstant.TAB_LAYOUT_INDICATOR_WIDTH)
      .lineCap(LineCapStyle.Round)
      .align(Alignment.Bottom)
  }
}

/**
 * 可滚动TabLayout
 */
@Component
export struct ScrollableTabLayout {
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  @ObjectLink @Watch("mediatorChange") mediator: TabLayoutPagerMediator
  @State tabItemWidthArray: number[] = []
  @BuilderParam TabItemBuilder: (item: TabItem) => void = null
  @BuilderParam TabIndicatorBuilder: () => void = null
  indexChanged: (item: number) => void = null
  showIndicator: boolean = true
  scroller: Scroller = new Scroller()
  totalWidth = 0
  lastIndex = 0

  mediatorChange() {
    // 让TabLayout自动滚动到屏幕中间
    if (this.lastIndex != this.mediator.recorder.targetIndex) {
      let preOffset = 0
      for (let index = 0; index < this.mediator.recorder.targetIndex; index++) {
        preOffset += this.tabItemWidthArray[index] || 0
      }
      this.scroller.scrollTo({
        xOffset: preOffset - this.totalWidth * 0.35,
        yOffset: 0,
        animation: { duration: 200, curve: Curve.Linear }
      })
    }
    this.lastIndex = this.mediator.recorder.targetIndex
  }

  build() {
    Scroll(this.scroller) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Row() {
          ForEach(this.mediator.tabItems, (item: TabItem, index: number) => {
            Stack({ alignContent: Alignment.Center }) {
              if (this.TabItemBuilder) {
                this.TabItemBuilder(item)
              } else {
                this.DefaultTabItemBuilder(item)
              }
            }
            .onAreaChange((_, newValue: Area) => {
              this.tabItemWidthArray[index] = newValue.width as number
            })
            .onClick(() => {
              if (this.indexChanged) {
                this.indexChanged(item.index)
              }
              this.mediator.jumpToIndex(item.index)
            })
          }, item => item.index)
        }.justifyContent(FlexAlign.Start)

        if (this.showIndicator) {
          Stack({ alignContent: Alignment.Bottom }) {
            if (this.TabIndicatorBuilder) {
              this.TabIndicatorBuilder()
            } else {
              this.DefaultTabIndicatorBuilder()
            }
          }
          .offset({ x: this.getIndicatorOffset() })
          .width(this.tabItemWidthArray[this.mediator.recorder.targetIndex])
        }
      }
    }
    .scrollable(ScrollDirection.Horizontal)
    .align(Alignment.Start)
    .scrollBar(BarState.Off)
    .edgeEffect(EdgeEffect.None)
    .onAreaChange((_, newValue: Area) => {
      this.totalWidth = newValue.width as number
    })

  }

  /**
   * 获取指示器偏移量
   */
  getIndicatorOffset() {
    let preOffset = 0
    for (let index = 0; index < this.lastIndex; index++) {
      preOffset += this.tabItemWidthArray[index] || 0
    }

    let incrementOffset = (this.mediator.currentIndex - this.mediator.recorder.targetIndex) * (this.tabItemWidthArray[this.mediator.recorder.targetIndex] || 0)
    return preOffset + incrementOffset
  }

  @Builder
  DefaultTabItemBuilder(item: TabItem) {
    Text(item.name)
      .fontSize(SizeConstant.TEXT_L)
      .fontColor(this.mediator.currentIndex === item.index
        ? AppTheme.palette(this.themeType).firstText
        : AppTheme.palette(this.themeType).thirdText)
      .textAlign(TextAlign.Center)
      .fontWeight(FontWeight.Bold)
      .height(SizeConstant.TAB_LAYOUT_HEIGHT)
      .margin({ left: SizeConstant.SPACE_L, right: SizeConstant.SPACE_L })
  }

  @Builder
  DefaultTabIndicatorBuilder() {
    Divider()
      .strokeWidth(SizeConstant.TAB_LAYOUT_INDICATOR_HEIGHT)
      .margin({ bottom: SizeConstant.SPACE_S })
      .color(AppTheme.palette(this.themeType).primary)
      .width(SizeConstant.TAB_LAYOUT_INDICATOR_WIDTH)
      .lineCap(LineCapStyle.Round)
      .align(Alignment.Bottom)
  }
}

/**
 * TabPager控件，类似Android中到ViewPager
 */
@Component
export struct TabPager {
  @ObjectLink mediator: TabLayoutPagerMediator
  @BuilderParam TabPageBuilder: (index: number) => void = null
  indexChanged: (item: number) => void = null
  lastTouchX = 0
  lastTouchY = 0
  scroller: Scroller = new Scroller()
  @State pageWidth: number = 0
  @State pageHeight: number = 0
  velocityTracker: VelocityTracker = new VelocityTracker()
  totalOffsetX = 0
  downRealTimeIndex = -1
  keyGenerator?: (index: number) => string

  getPageOffsetX(index: number): number {
    let offset = 0
    const realTimeIndexOffset = index - this.mediator.currentIndex
    if (Math.abs(realTimeIndexOffset) >= 1) {
      offset = realTimeIndexOffset / Math.abs(realTimeIndexOffset) * this.pageWidth
    } else {
      offset = realTimeIndexOffset * this.pageWidth
    }
    return offset
  }

  getMaxOffsetX() {
    return this.pageWidth * (this.mediator.tabItems.length - 1)
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      ForEach(this.mediator.cachePageIndexArray,
        (index, _) => {
          Stack({ alignContent: Alignment.TopStart }) {
            this.TabPageBuilder(index)
          }.offset({ x: this.getPageOffsetX(index), y: 0 })
          .clip(true)
          .onAreaChange((_, newValue: Area) => {
            if (newValue.width as number != 0) {
              this.pageWidth = newValue.width as number
              this.pageHeight = newValue.width as number
            }
          })
        },
        (index, _) => {
          if (this.keyGenerator) {
            return this.keyGenerator(index)
          } else {
            return `${index}`
          }
        }
      )
    }
    .hitTestBehavior(HitTestMode.Transparent)
    .onTouch((event: TouchEvent) => {
      if (!this.mediator.draggable || this.mediator.recorder.isAnim) {
        return
      }
      if (event.type == TouchType.Down) {
        this.velocityTracker.beginTrackXVelocity(event)
        this.downRealTimeIndex = this.mediator.currentIndex
        this.lastTouchX = event.touches[0].x
        this.lastTouchY = event.touches[0].y
        this.totalOffsetX = this.downRealTimeIndex * this.pageWidth
      } else if (event.type == TouchType.Move) {
        if (this.downRealTimeIndex == -1) {
          return
        }
        const curTouchX = event.touches[0].x
        const curTouchY = event.touches[0].y
        const dx = curTouchX - this.lastTouchX
        const dy = curTouchY - this.lastTouchY
        if (Math.abs(dx) >= 0 && Math.abs(dx) >= Math.abs(dy) * 1.3) {
          this.velocityTracker.addXMovement(event)
          this.totalOffsetX = Math.max(0, Math.min(this.getMaxOffsetX(), this.totalOffsetX - dx))
          this.mediator.currentIndex = this.totalOffsetX / this.pageWidth
        }
        this.lastTouchX = curTouchX
        this.lastTouchY = curTouchY
      } else if (event.type == TouchType.Up || event.type == TouchType.Cancel) {
        if (this.downRealTimeIndex == -1) {
          return
        }
        const velocity = this.velocityTracker.computeXVelocity()
        if (Math.abs(velocity) > 100) {
          this.mediator.jumpToIndex(Math.max(0, Math.min(this.downRealTimeIndex + (velocity < 0 ? 1 : -1), this.mediator.tabItems.length - 1)))
        } else {
          if (this.mediator.currentIndex - this.downRealTimeIndex > 0) { // 左滑
            this.mediator.jumpToIndex(Math.max(0, Math.min(this.downRealTimeIndex + (Math.abs(this.mediator.currentIndex - this.downRealTimeIndex) >= 0.5 ? 1 : 0), this.mediator.tabItems.length - 1)))
          } else { // 右滑
            this.mediator.jumpToIndex(Math.max(0, Math.min(this.downRealTimeIndex + (Math.abs(this.mediator.currentIndex - this.downRealTimeIndex) >= 0.5 ? -1 : 0), this.mediator.tabItems.length - 1)))
          }
        }

        this.downRealTimeIndex = -1
      }
    })
  }
}


/**
 * TabLayout、TabPager调解器
 */
@Observed
export class TabLayoutPagerMediator implements ITabLayoutPagerMediator {
  // 当前索引（实际索引，可为小数，例如当TabPager从index从0滑动到1的过程中，如果滑动了一半，那么currentIndex为0.5）
  currentIndex: number = 0
  // TabPager页面缓存数量（同时缓存TabPager左右两边的页面，例如cacheCount为2，当前页面索引为4，那么实际加载的页面2、3、4、5、6）
  cacheCount: number = 1
  // TabPager是否可以左右拖动
  draggable: boolean = true
  // 数据源
  tabItems: object[] = []
  // 当前索引切换回调
  indexChangedCallback?: (index: number) => void
  // 缓存的页面索引集合
  cachePageIndexArray: number[] = []
  /**
   * 记录一些辅助的信息
   * 由于TabLayoutPagerMediator在TabLayout和TabPager中被@ObjectLink修饰，如果把这些辅助信息直接定义成TabLayoutPagerMediator的变量，那么这些变量变化会造成UI不必要的渲染）
   */
  recorder: TabLayoutPagerRecorder = new TabLayoutPagerRecorder()
  private lastIndex: number = 0

  constructor(mediator?: ITabLayoutPagerMediator) {
    if (mediator != null) {
      if (mediator.tabItems != undefined) {
        this.tabItems = mediator.tabItems
      }
      if (mediator.currentIndex != undefined) {
        this.currentIndex = mediator.currentIndex
      }
      if (mediator.indexChangedCallback != undefined) {
        this.indexChangedCallback = mediator.indexChangedCallback
      }
      if (mediator.cacheCount != undefined) {
        this.cacheCount = Math.max(mediator.cacheCount, 0)
      }
      if (mediator.draggable != undefined) {
        this.draggable = mediator.draggable
      }
    }
    this.updateCachePageIndexArray()
  }

  /**
   * 当前索引变化动画，驱动TabPager页面切换偏移和TabLayout指示器偏移
   */
  private doAnimator(startIndex: number, targetIndex: number) {
    if (this.recorder.indexAnimator) {
      this.recorder.indexAnimator.cancel()
    }
    this.recorder.targetIndex = targetIndex
    this.recorder.indexAnimator = animator.create(this.getAnimatorOptions(startIndex, targetIndex))
    this.recorder.indexAnimator.onframe = (progress) => {
      this.currentIndex = progress
    }
    this.recorder.indexAnimator.onfinish = () => {
      if (this.lastIndex != this.currentIndex) {
        if (this.indexChangedCallback) {
          this.indexChangedCallback(this.currentIndex)
        }
        this.updateCachePageIndexArray()
        this.lastIndex = this.currentIndex
      }
      this.recorder.isAnim = false
    }
    this.recorder.indexAnimator.play()
  }

  /**
   * 当前索引变化动画配置
   */
  private getAnimatorOptions(startIndex: number, targetIndex: number): AnimatorOptions {
    return {
      duration: 250,
      easing: "linear",
      delay: 0,
      fill: "forwards",
      direction: "normal",
      iterations: 1,
      begin: startIndex,
      end: targetIndex
    }
  }

  /**
   * 更新缓存页面的索引集合
   */
  updateCachePageIndexArray() {
    const startIndex = Math.max(0, this.currentIndex - this.cacheCount)
    const endIndex = Math.min(this.currentIndex + this.cacheCount, this.tabItems.length - 1)

    const newLazyLoadIndexArray: number[] = []
    for (let index = startIndex; index <= endIndex; index++) {
      newLazyLoadIndexArray.push(index)
    }
    this.cachePageIndexArray = newLazyLoadIndexArray
  }

  /**
   * 跳转到指定索引
   */
  jumpToIndex(index: number) {
    // if (this.realTimeIndex == index) {
    //   return
    // }
    LogUtil.debug("TabLayoutPagerMediator------------------jumpToIndex:" + index + ",currentIndex:" + this.currentIndex)
    this.recorder.isAnim = true
    this.doAnimator(this.currentIndex, index)
  }
}

export class ITabLayoutPagerMediator {
  tabItems?: object[]
  currentIndex?: number
  cacheCount?: number
  draggable?: boolean
  indexChangedCallback?: (index: number) => void
}

class TabLayoutPagerRecorder {
  // 标记是否正在做切换动画
  isAnim: boolean = false
  // 要切换到目标索引
  targetIndex: number = 0
  // 索引动画控制器
  indexAnimator: AnimatorResult | undefined = undefined
}

@Observed
export class TabItem {
  index: number
  name: string
  icon?: string | Resource

  constructor(index: number, name: string, icon?: string | Resource) {
    this.index = index
    this.name = name
    this.icon = icon
  }
}

