/**
 * 通用网络图片加载组件
 * 添加placeHolder功能
 */
@Component
export struct CommonNetworkImage {
  url: string | undefined = undefined
  placeHolder: Resource = $r('app.media.ic_default_place_holder')
  @State status: NetworkImageLoadStatus = NetworkImageLoadStatus.LOADING
  @State imageOpacity: number = 0

  build() {
    Stack() {
      if (this.status != NetworkImageLoadStatus.SUCCESS) {
        Image(this.placeHolder)
          .width("100%")
          .height("100%")
          .constraintSize({ maxWidth: 72, maxHeight: 72 })
      }
      // Image(this.placeHolder)
      //   .width("100%")
      //   .height("100%")
      //   .constraintSize({ maxWidth: 72, maxHeight: 72 })
      //   .visibility(this.status != NetworkImageLoadStatus.SUCCESS ? Visibility.Visible : Visibility.Hidden)

      Image(this.url)
        .width("100%")
        .height("100%")
        .onComplete((event: {
          width: number;
          height: number;
          componentWidth: number;
          componentHeight: number;
          loadingStatus: number;
        }) => {
          if (event.loadingStatus == 1) {
            this.status = NetworkImageLoadStatus.SUCCESS
            // animateTo({
            //   duration: 200
            // }, () => {
            //   this.imageOpacity = 1
            // })
          }
        })
        .onError(() => {
          this.status = NetworkImageLoadStatus.ERROR
        })
        .visibility(this.status == NetworkImageLoadStatus.SUCCESS ? Visibility.Visible : Visibility.Hidden)
        // .opacity(this.imageOpacity)
    }
  }
}

enum NetworkImageLoadStatus {
  LOADING,
  SUCCESS,
  ERROR
}