import { SizeConstant } from '../constant/SizeConstant'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import VelocityTracker from '../util/VelocityTracker'

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
        .offset({ x: this.mediator.realTimeIndex * this.tabItemWidth })
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
    if (this.lastIndex != this.mediator.currentIndex) {
      let preOffset = 0
      for (let index = 0; index < Math.floor(this.mediator.currentIndex); index++) {
        preOffset += this.tabItemWidthArray[index] || 0
      }
      this.scroller.scrollTo({
        xOffset: preOffset - this.totalWidth * 0.35,
        yOffset: 0,
        animation: { duration: 200, curve: Curve.Linear }
      })
    }
    this.lastIndex = this.mediator.currentIndex
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
              // this.tabItemWidth = newValue.width as number
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
          .width(this.tabItemWidthArray[this.mediator.currentIndex])
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

  getIndicatorOffset() {
    let preOffset = 0
    for (let index = 0; index < Math.floor(this.mediator.currentIndex); index++) {
      preOffset += this.tabItemWidthArray[index] || 0
    }

    let incrementOffset = (this.mediator.realTimeIndex - this.mediator.currentIndex) * (this.tabItemWidthArray[this.mediator.currentIndex] || 0)
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
    const realTimeIndexOffset = index - this.mediator.realTimeIndex
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
      ForEach(this.mediator.lazyLoadIndexArray,
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
        this.downRealTimeIndex = this.mediator.realTimeIndex
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
          this.mediator.realTimeIndex = this.totalOffsetX / this.pageWidth
        }
        this.lastTouchX = curTouchX
        this.lastTouchY = curTouchY
      } else if (event.type == TouchType.Up || event.type == TouchType.Cancel) {
        if (this.downRealTimeIndex == -1) {
          return
        }
        const velocity = this.velocityTracker.computeXVelocity()
        if (Math.abs(velocity) > 100) {
          this.mediator.jumpToIndex(Math.max(0, Math.min(this.mediator.currentIndex + (velocity < 0 ? 1 : -1), this.mediator.tabItems.length - 1)))
        } else {
          if (this.mediator.realTimeIndex - this.downRealTimeIndex > 0) { // 左滑
            this.mediator.jumpToIndex(Math.max(0, Math.min(this.mediator.currentIndex + (Math.abs(this.mediator.realTimeIndex - this.downRealTimeIndex) >= 0.5 ? 1 : 0), this.mediator.tabItems.length - 1)))
          } else { // 右滑
            this.mediator.jumpToIndex(Math.max(0, Math.min(this.mediator.currentIndex + (Math.abs(this.mediator.realTimeIndex - this.downRealTimeIndex) >= 0.5 ? -1 : 0), this.mediator.tabItems.length - 1)))
          }
        }

        this.downRealTimeIndex = -1
      }
    })
  }
}


export class ITabLayoutPagerMediator {
  tabItems?: object[]
  currentIndex?: number
  cacheCount?: number
  draggable?: boolean
  indexChangedCallback?: (index: number) => void
}


@Observed
export class TabLayoutPagerMediator implements ITabLayoutPagerMediator {
  currentIndex: number = 0
  realTimeIndex: number = 0
  cacheCount: number = 1
  draggable: boolean = true
  tabItems: object[] = []
  indexChangedCallback?: (index: number) => void
  lastIndex: number = 0
  lazyLoadIndexArray: number[] = []
  recorder: TabLayoutPagerRecorder = new TabLayoutPagerRecorder()

  constructor(mediator?: ITabLayoutPagerMediator) {
    if (mediator != null) {
      if (mediator.tabItems != undefined) {
        this.tabItems = mediator.tabItems
      }
      if (mediator.currentIndex != undefined) {
        this.currentIndex = mediator.currentIndex
        this.realTimeIndex = this.currentIndex
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
    this.updateLazyLoadIndexArray()
  }

  updateLazyLoadIndexArray() {
    const startIndex = Math.max(0, this.currentIndex - this.cacheCount)
    const endIndex = Math.min(this.currentIndex + this.cacheCount, this.tabItems.length - 1)

    const newLazyLoadIndexArray: number[] = []
    for (let index = startIndex; index <= endIndex; index++) {
      newLazyLoadIndexArray.push(index)
    }
    this.lazyLoadIndexArray = newLazyLoadIndexArray
  }

  jumpToIndex(index: number) {
    if (this.realTimeIndex == index) {
      return
    }
    this.recorder.isAnim = true
    animateTo({
      duration: 250,
      onFinish: () => {
        this.realTimeIndex = index
        if (this.lastIndex != index) {
          if (this.indexChangedCallback) {
            this.indexChangedCallback(index)
          }
          this.updateLazyLoadIndexArray()
          this.lastIndex = index
        }
        this.recorder.isAnim = false
      }
    }, () => {
      this.currentIndex = index
      this.realTimeIndex = index - 0.0001
    });
  }
}

class TabLayoutPagerRecorder {
  isAnim: boolean = false
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

