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

  static msToTime(ms: number) {
    const seconds = Math.floor((ms / 1000) % 60);
    const minutes = Math.floor((ms / (1000 * 60)) % 60);
    return  (minutes < 10 ? '0' + minutes : minutes) + ':' + (seconds < 10 ? '0' + seconds : seconds);

  }
}