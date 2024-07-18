export class OilPriceModel {
  code: number = 0
  result: OilPrice[] = []
  msg: string = ""
}

export class OilPrice {
  Region: string = ""
  Gasoline92: string = ""
  Gasoline95: string = ""
  Gasoline98: string = ""
  Diesel0: string = ""
  UpdateTime: string = ""
}