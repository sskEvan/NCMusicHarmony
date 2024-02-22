export class StringUtil {
  static friendlyNumber(number: number, fixed: number = 1): string {
    if (number >= 100000000) {
      return (number / 100000000).toFixed(fixed) + "亿"
    }
    if (number >= 10000) {
      return (number / 10000).toFixed(fixed) + "万"
    }
    return number.toString()
  }


}