import promptAction from '@ohos.promptAction'
import { ClickEffectLayout, CommonNetworkImage, SizeConstant, TabItem } from 'lib_common'
import { IUserInfoBean, STORAGE_USER_INFO, UserInfoBean } from '../../../..'


/**
 * 我的页面滚动头部组件
 */
@Component
export struct CpnMyHeader {
  @StorageLink(STORAGE_USER_INFO) userInfo: UserInfoBean = new UserInfoBean({} as IUserInfoBean)
  @Prop private overScrollOffset: number
  private functionTabs: Array<TabItem> = [
    new TabItem(0, "最近", $r('app.media.ic_recent')),
    new TabItem(1, "本地", $r('app.media.ic_local_file')),
    new TabItem(3, "云盘", $r('app.media.ic_cloud')),
    new TabItem(4, "已购", $r('app.media.ic_buy'))
  ]

  build() {
    Column() {
      this.MyInfoBuilder()
      this.TabsBuilder()
    }.width('100%').height(this.overScrollOffset + 300)
  }

  // 假数据
  @Builder MyInfoBuilder() {
    Column() {
      CommonNetworkImage({url: this.userInfo.detail.profile.avatarUrl, placeHolder: $r('app.media.ic_default_avatar')})
        .width(66)
        .height(66)
        .border({ width: "2lpx", color: Color.White, radius: 33 })
        .clip(true)
      Text(this.userInfo.detail.profile.nickname)
        .fontSize(SizeConstant.TEXT_L)
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .margin({ top: SizeConstant.SPACE_XL })
      Row() {
        // Text("珊曼妮乐迷")
        //   .fontSize(SizeConstant.TEXT_S)
        //   .fontColor("#FFDDDDDD")
        // Text("  ·  ")
        //   .fontSize(SizeConstant.TEXT_S)
        //   .fontColor("#FFDDDDDD")
        //   .fontWeight(FontWeight.Bold)
        // Text("广东-广州")
        //   .fontSize(SizeConstant.TEXT_S)
        //   .fontColor("#FFDDDDDD")
        // Text("  ·  ")
        //   .fontSize(SizeConstant.TEXT_S)
        //   .fontColor("#FFDDDDDD")
        //   .fontWeight(FontWeight.Bold)
        Text(`村龄${Math.ceil(this.userInfo.detail.createDays / 356.0)}年`)
          .fontSize(SizeConstant.TEXT_S)
          .fontColor("#FFDDDDDD")
      }.justifyContent(FlexAlign.Center).margin({ top: SizeConstant.SPACE_M })

      Row() {
        this.SpanTextBuilder(this.userInfo.detail.profile.follows.toString(), "关注")
        this.SpanTextBuilder(this.userInfo.detail.profile.followeds.toString(), "粉丝")
        this.SpanTextBuilder(`Lv.${this.userInfo.detail.level}`, "等级", 0)
        // this.SpanTextBuilder("5780时", "听歌", 0)
      }.justifyContent(FlexAlign.Center).margin({ top: SizeConstant.SPACE_M })
    }
    .width("100%")
    .alignItems(HorizontalAlign.Center)
    .margin({ top: 96 + this.overScrollOffset })
  }

  @Builder SpanTextBuilder(value: string, text: string, marginRight: number = SizeConstant.SPACE_L) {
    Text() {
      Span(value).fontSize(SizeConstant.TEXT_M)
        .fontColor(Color.White).fontWeight(FontWeight.Medium)
      Span(" " + text).fontSize(SizeConstant.TEXT_S)
        .fontColor("#FFDDDDDD")
    }.margin({ right: marginRight })
  }

  @Builder TabsBuilder() {
    Row() {
      ForEach(this.functionTabs,
        (item: TabItem, _) => {
          this.TabItemBuilder(item)
        },
      )
      ClickEffectLayout({ click: (() => {
        promptAction.showToast({ message: "TODO:更多" })
      }) }) {
        Row() {
          Image($r('app.media.ic_more_item'))
            .width(SizeConstant.ICON_M)
            .width(SizeConstant.ICON_M)
            .fillColor("#FFDDDDDD")
        }
        .width(25)
        .height(25)
        .alignItems(VerticalAlign.Center)
        .justifyContent(FlexAlign.Center)
        .backgroundColor("#99000000")
        .borderRadius(SizeConstant.RADIUS_S)
      }
    }
    .padding({ top: SizeConstant.SPACE_L, left: SizeConstant.SPACE_L, right: SizeConstant.SPACE_L })
    .width("100%")
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder TabItemBuilder(item: TabItem) {
    ClickEffectLayout({ click: (() => {
      promptAction.showToast({ message: `TODO:${item.name}` })
    }) }) {
      Row() {
        Image(item.icon)
          .width(SizeConstant.ICON_S)
          .width(SizeConstant.ICON_S)
          .margin({ right: SizeConstant.SPACE_S })
          .fillColor("#FFDDDDDD")
        Text(item.name)
          .fontSize(SizeConstant.TEXT_S)
          .fontColor("#FFDDDDDD")
      }
      .width(60)
      .height(25)
      .alignItems(VerticalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .backgroundColor("#99000000")
      .borderRadius(SizeConstant.RADIUS_S)
    }
  }
}
