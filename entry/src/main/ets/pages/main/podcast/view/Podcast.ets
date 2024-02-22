import promptAction from '@ohos.promptAction'
import {
  CommonAppBar,
  CpnLoading,
  ListDataSource,
  ScrollableTabLayout,
  SizeConstant,
  TabItem,
  TabLayout,
  TabLayoutPagerMediator,
  TabPager,
} from 'lib_common'

import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { CpnLyric } from '../../..'

/**
 * 首页-播客页面
 */
@Component
export struct PodcastPage {

  @StorageLink(THEME_TYPE) themeType: number = ThemeType.DEFAULT
  @State message: string = 'PodcastPage'
  outerList: TabItem[] = [new TabItem(0, "outer 1"), new TabItem(1, "outer 2"), new TabItem(2, "outer 3"), new TabItem(3, "outer 4"), new TabItem(4, "outer 5"),
    new TabItem(5, "outer 6"), new TabItem(6, "outer 7"), new TabItem(7, "outer 8"), new TabItem(9, "outer 9"), new TabItem(9, "outer 10"),
    new TabItem(10, "outer 11"), new TabItem(11, "outer 12"), new TabItem(12, "outer 13"), new TabItem(13, "outer 14"), new TabItem(14, "outer 15"),
    new TabItem(15, "outer 16"), new TabItem(16, "outer 17"), new TabItem(17, "outer 18"), new TabItem(18, "outer 19"), new TabItem(19, "outer 20")]
  innerList: TabItem[] = [new TabItem(0, "innerA 1"), new TabItem(1, "innerA 2"), new TabItem(2, "innerA 3"), new TabItem(3, "innerA 4")]
  innerList2: TabItem[] = [new TabItem(0, "innerB 1"), new TabItem(1, "innerB 2"), new TabItem(2, "innerB 3")]
  // @State outerMediator: TabLayoutPagerMediator3 = new TabLayoutPagerMediator3(this.outerList)
  // @State innerMediator: TabLayoutPagerMediator3 = new TabLayoutPagerMediator3(this.innerList, 0, this.outerMediator)
  // @State innerMediator2: TabLayoutPagerMediator3 = new TabLayoutPagerMediator3(this.innerList2, 0, this.outerMediator)
  @State outerMediator: TabLayoutPagerMediator = new TabLayoutPagerMediator({
    tabItems: this.outerList,
    indexChangedCallback: (index: number) => {
      promptAction.showToast({ message: "outer index change:" + index })
    }
  })
  @State innerMediator: TabLayoutPagerMediator = new TabLayoutPagerMediator({
    tabItems: this.innerList,
    currentIndex: 1,
  })
  @State innerMediator2: TabLayoutPagerMediator = new TabLayoutPagerMediator({
    tabItems: this.innerList2,
    currentIndex: 1,
  })

  @Builder OuterTabPageBuilder(index: number) {
    Text(this.outerList[index].name)
      .width("100%")
      .height("500lpx")
      .textAlign(TextAlign.Center)
      .backgroundColor(Color.Blue)
    // if (index == 0) {
    //   Text(this.outerList[index].name)
    //     .width("100%")
    //     .height("500lpx")
    //     .textAlign(TextAlign.Center)
    //     .backgroundColor(Color.Blue)
    //   // Column() {
    //   //   TabLayout({ mediator: this.innerMediator })
    //   //   TabPager3({ mediator: this.innerMediator, TabPageBuilder: (index) => {
    //   //     this.InnerTabPageBuilder(index)
    //   //   } })
    //   // }
    // } else if (index == 1) {
    //   // Column() {
    //   //   TabLayout({ mediator: this.innerMediator2 })
    //   //   TabPager({ mediator: this.innerMediator2, TabPageBuilder: (index) => {
    //   //     this.InnerTabPageBuilder2(index)
    //   //   } })
    //   // }
    //
    //   Text(this.outerList[index].name)
    //     .width("100%")
    //     .height("500lpx")
    //     .textAlign(TextAlign.Center)
    //     .backgroundColor(Color.Red)
    // } else if (index == 2) {
    //   Text(this.outerList[index].name)
    //     .width("100%")
    //     .height("500lpx")
    //     .textAlign(TextAlign.Center)
    //     .backgroundColor(Color.Green)
    // }
  }

  @Builder InnerTabPageBuilder(index: number) {
    if (index == 0) {
      Text(this.innerList[index].name)
        .width("100%")
        .height("500lpx")
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Orange)
    }
    else if (index == 1) {
      Text(this.innerList[index].name)
        .width("100%")
        .height("500lpx")
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Pink)
    } else if (index == 2) {
      Text(this.innerList[index].name)
        .width("100%")
        .height("500lpx")
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Yellow)
    } else if (index == 3) {
      Text(this.innerList[index].name)
        .width("100%")
        .height("500lpx")
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Blue)
    } else if (index == 4) {
      Text(this.innerList[index].name)
        .width("100%")
        .height("500lpx")
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Pink)
    }
  }

  @Builder InnerTabPageBuilder2(index: number) {
    if (index == 0) {
      Text(this.innerList2[index].name)
        .width("100%")
        .height("500lpx")
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Orange)
    }
    else if (index == 1) {
      Text(this.innerList2[index].name)
        .width("100%")
        .height("500lpx")
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Pink)
    } else if (index == 2) {
      Text(this.innerList2[index].name)
        .width("100%")
        .height("500lpx")
        .textAlign(TextAlign.Center)
        .backgroundColor(Color.Yellow)
    }
  }

  build() {
    Stack() {
      Column({ space: 20 }) {

        CommonAppBar({
          title: "测试标题",
          leftIcon: $r('app.media.ic_menu'),
          rightIcons: [$r('app.media.ic_share'), $r('app.media.ic_menu')],
          titleCenter: false,
          leftIconClickCallback: () => {
            // this.appTheme.themeType = ThemeType.DARK
            this.themeType = ThemeType.DEFAULT
          },
          rightIconsClickCallback: (_) => {
            // this.appTheme.themeType = ThemeType.DEFAULT
            this.themeType = ThemeType.DARK
          },
          // bgColor: Color.Red,
          // contentColor: Color.White
        })
        CpnLyric()
        // ScrollableTabLayout({ mediator: this.outerMediator })
        // TabPager({ mediator: this.outerMediator,
        //   TabPageBuilder: (index: number) => {
        //     this.OuterTabPageBuilder(index)
        //   } })
      }
    }
  }

  @Builder TitleBuilder() {
    Text("Test title Test title Test title Test title")
  }
}