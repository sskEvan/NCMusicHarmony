const numberArrayCache: Array<Array<number>> = []

export class ArrayUtil {
  static generateNumberArray(count: number): Array<number> {
    if (numberArrayCache[count]) {
      return numberArrayCache[count]
    } else {
      const numberArray: Array<number> = []
      for (let index = 0; index < count; index++) {
        numberArray[index] = index
      }
      numberArrayCache[count] = numberArray
      return numberArrayCache[count]
    }
  }
}
