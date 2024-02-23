import { CommonAppBar, TabItem, TabLayout, TabLayoutPagerMediator, TabPager, SizeConstant } from 'lib_common'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'
import { AttentionDynamicPage, SquareDynamicPage, STORAGE_MAIN_DRAWER_TOGGLE} from '../../../..'

/**
 * 首页-动态页面
 */
@Component
export struct DynamicPage {
  @StorageLink(STORAGE_MAIN_DRAWER_TOGGLE) mainDrawerToggle: boolean = false
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT
  private tabItems: TabItem[] = [new TabItem(0, "关注"), new TabItem(1, "广场")]
  @State  private tabMediator: TabLayoutPagerMediator = new TabLayoutPagerMediator({
    tabItems: this.tabItems,
  })

  @Builder CustomerTitleBuilder() {
    TabLayout({
      mediator: this.tabMediator,
    })
  }

  @Builder CustomerRightBuilder() {
    Image($r('app.media.ic_add'))
      .width(SizeConstant.ICON_L + SizeConstant.SPACE_S * 2)
      .height(SizeConstant.ICON_L + SizeConstant.SPACE_S * 2)
      .padding(SizeConstant.SPACE_S)
      .fillColor(AppTheme.palette(this.themeType).primary)
  }

  @Builder TabPageBuilder(index: number) {
    if (index == 0) {
      AttentionDynamicPage()
    } else {
      SquareDynamicPage()
    }
  }

  build() {
    Column() {
      CommonAppBar({ leftIcon: $r('app.media.ic_menu'),
        leftIconClickCallback : () => {
          this.mainDrawerToggle = true
        },
        CustomerTitleBuilder: () => {
          this.CustomerTitleBuilder()
        },
        CustomerRightBuilder: () => {
          this.CustomerRightBuilder()
        } })
      TabPager({ mediator: this.tabMediator,
        TabPageBuilder: (index: number) => {
          this.TabPageBuilder(index)
        } }).layoutWeight(1)

    }
  }
}
