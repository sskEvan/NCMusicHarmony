import {
  ListDataSource,
  PagingLayoutMediator,
  ViewState,
  ViewStateType,
  ViewStatePagingLayout,
  CommonNetworkImage,
} from 'lib_common'
import { AppTheme, ThemeType, THEME_TYPE } from 'lib_theme'

@Component
export struct DiscoveryPage {
  lazyDataSource: ListDataSource = new ListDataSource()
  @StorageLink(THEME_TYPE) themeType: ThemeType = ThemeType.DEFAULT

  aboutToAppear() {
    for (let index = 0; index < 100; index++) {
      this.lazyDataSource.pushData({ index })
    }
  }

  @State pagingLayoutMediator: PagingLayoutMediator = new PagingLayoutMediator({})

  @Builder ItemBuilder(item: object, index: number) {
    Row() {
      if ((index + 1) % 5 == 1) {
        Image($r("app.media.ic_test_1")).width(80).height(100)
      } else if ((index + 1) % 5 == 2) {
        Image($r("app.media.ic_test_2")).width(80).height(100)
      } else if ((index + 1) % 5 == 3) {
        Image($r("app.media.ic_test_3")).width(80).height(100)
      } else if ((index + 1) % 5 == 4) {
        Image($r("app.media.ic_test_4")).width(80).height(100)
      } else if ((index + 1) % 5 == 0) {
        Image($r("app.media.ic_test_0")).width(80).height(100)
      }
      Text(`${JSON.stringify(item)}`)
        .textAlign(TextAlign.Center)
        .fontSize(16)
        .margin({ top: 12 })
        .backgroundColor('#efefef')
    }.height(100).onClick(() => {
      this.pagingLayoutMediator.lazyDataSource.notifyDataChange(index)
    })
  }

  testUrl = "https://www.baidu.com/link?url=jyTSJCYjt6pewWjhIhC5M1W9-kZIMIzi1BLPEqXNHPVmr9hWWKGvSFbVBui0Rw-9x_bTi1_G1VvPSyzHtNkq4SiXECSF9YfNLqwLfo4NtBK5uir8lD0_b2q3Tmy_B9IyaXjIOrKVbjQxbeyww7gzZU5tzkwrK91A99NsrQT5X2vR60sTwZsjaNtiIB-bA8sgRgxUbYE6RkSd9z-c2zO1VRUFNZQLlnIWlG3kmsU7N6CT16CPfDwrFaM8ktehlk-VAbewdjQemLveErVB1Mtx0CxyNynvtex2rIIIurFqQJrkilCZpuhwNfPB7V3scUv0tRk0SfPdrkF7I2dy5PYVEigZrZ_2HskaXKW9frDnloSEG-_zMFT22JFkbv_aG6zOlnPhksCGbEsb5t69na1SLng5lfwP-eVpqVoxHsBhDhwQvfefIC6vn4wjSnm2-2ijAu28bz2iDnwgm-cwni6M6GwJHjmiaBNCL-08MVgn5Gr2UEeKDVcQTaKtKM0BDhexrdmbBwNAmrJ1z4KnDcdMo5Ypu3fSyUnrrFPVLRuJxPg_TcxmHUSFkYMKWDNvta6LHW82UtXXnBFl6livfJ3-ZDUplsBuRI-5yivhlS6jvRZoctov_mF-o_uVKIatGIU5u68O883PEcHn6dUhkPcp6N7lHls1R94nrUW0a9mOAuRsGTms6DLia6sGksz9lkUGgBV3-Bh2pDX97UyxOzTr7iAysxbqx9FCVSFn_mEPJpO&wd=&eqid=9e1621870000da3f0000000665c2f910"

  build() {
    Column() {

    }.width("100%").height("100%").backgroundColor(AppTheme.palette(this.themeType).commonBackground)

    // ViewStatePagingLayout({
    //   mediator: $pagingLayoutMediator,
    //   ItemBuilder: (item: object, index: number) => {
    //     this.ItemBuilder(item, index)
    //   },
    //   onLoadData: (viewState: ViewState) => {
    //     viewState.type = ViewStateType.LOADING
    //     setTimeout(() => {
    //       // const newList = [{ value: "1" }, { value: "2" }, { value: "3" }, { value: "4" }, { value: "5" }, {
    //       //   value: "6"
    //       // }, { value: "7" }, { value: "8" }]
    //       const newList = []
    //       for (let index = 0; index < 100; index++) {
    //         newList[index] = { v: index }
    //       }
    //       viewState.type = ViewStateType.SUCCESS
    //       this.pagingLayoutMediator.lazyDataSource.reloadData(newList)
    //     }, 2000)
    //   },
    //   onRefresh: () => {
    //     setTimeout(() => {
    //       this.pagingLayoutMediator.refreshMediator.finishRefresh(true)
    //     }, 2000)
    //   },
    //   onLoadMore: () => {
    //     setTimeout(() => {
    //       const newList = [{ value: "9" }, { value: "10" }]
    //       this.pagingLayoutMediator.finishLoadMore(true, newList)
    //     }, 2000)
    //   }
    // })

  }
}





