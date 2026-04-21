// 卡牌类型定义
interface Card {
  type: string
  name: string
  rarity: string
  image: Resource
  probability: number
}

@Entry
@Component
struct Index {
  // 状态变量
  @State isGachaMode: boolean = false
  @State currentCards: Card[] = []
  @State currentIndex: number = 0
  @State totalPulls: number = 0
  @State goldCount: number = 0
  @State purpleCount: number = 0
  @State blueCount: number = 0

  // 卡池配置 - 按颜色分类
  private colorPool: Card[] = [
    {
      type: 'gold',
      name: '传说卡',
      rarity: '★★★★★',
      image: $r('app.media.card_gold'),
      probability: 0.01
    },
    {
      type: 'purple',
      name: '史诗卡',
      rarity: '★★★★',
      image: $r('app.media.card_purple1'),
      probability: 0.19
    },
    {
      type: 'blue',
      name: '稀有卡',
      rarity: '★★★',
      image: $r('app.media.card_blue1'),
      probability: 0.80
    }
  ]

  // 蓝卡子卡池
  private blueCards: Card[] = [
    {
      type: 'blue',
      name: '稀有卡-蓝1',
      rarity: '★★★',
      image: $r('app.media.card_blue1'),
      probability: 0.5
    },
    {
      type: 'blue',
      name: '稀有卡-蓝2',
      rarity: '★★★',
      image: $r('app.media.card_blue2'),
      probability: 0.5
    }
  ]

  // 紫卡子卡池
  private purpleCards: Card[] = [
    {
      type: 'purple',
      name: '史诗卡-紫1',
      rarity: '★★★★',
      image: $r('app.media.card_purple1'),
      probability: 0.5
    },
    {
      type: 'purple',
      name: '史诗卡-紫2',
      rarity: '★★★★',
      image: $r('app.media.card_purple2'),
      probability: 0.5
    }
  ]

  // 抽卡函数
  private gacha(): Card {
    // 第一步：抽取颜色
    const rand = Math.random()
    let cumulative = 0
    let selectedColor: Card | null = null

    for (const color of this.colorPool) {
      cumulative += color.probability
      if (rand < cumulative) {
        selectedColor = color
        break
      }
    }

    if (!selectedColor) {
      selectedColor = this.colorPool[2] // 默认返回蓝卡
    }

    // 第二步：根据颜色抽取具体卡牌
    if (selectedColor.type === 'blue') {
      // 蓝卡：从蓝卡子卡池中随机选择
      const blueRand = Math.random()
      return blueRand < 0.5 ? this.blueCards[0] : this.blueCards[1]
    } else if (selectedColor.type === 'purple') {
      // 紫卡：从紫卡子卡池中随机选择
      const purpleRand = Math.random()
      return purpleRand < 0.5 ? this.purpleCards[0] : this.purpleCards[1]
    } else {
      // 金卡：直接返回
      return selectedColor
    }
  }

  // 开始抽卡
  private startGacha(count: number) {
    this.currentCards = []
    this.currentIndex = 0

    for (let i = 0; i < count; i++) {
      const card = this.gacha()
      this.currentCards.push(card)
      this.totalPulls++

      if (card.type === 'gold') {
        this.goldCount++
      } else if (card.type === 'purple') {
        this.purpleCount++
      } else {
        this.blueCount++
      }
    }

    this.isGachaMode = true
  }

  // 显示下一张卡牌
  private showNextCard() {
    this.currentIndex++
    if (this.currentIndex >= this.currentCards.length) {
      this.exitGacha()
    }
  }

  // 退出抽卡
  private exitGacha() {
    this.isGachaMode = false
    this.currentCards = []
    this.currentIndex = 0
  }

  // 获取卡牌背景颜色
  private getCardBackgroundColor(type: string): LinearGradient {
    if (type === 'gold') {
      return {
        angle: 135,
        colors: [['#ffd700', 0], ['#ffed4e', 0.5], ['#ffd700', 1]]
      }
    } else if (type === 'purple') {
      return {
        angle: 135,
        colors: [['#9b59b6', 0], ['#8e44ad', 0.5], ['#9b59b6', 1]]
      }
    } else {
      return {
        angle: 135,
        colors: [['#3498db', 0], ['#2980b9', 0.5], ['#3498db', 1]]
      }
    }
  }

  // 获取卡牌边框颜色
  private getCardBorderColor(type: string): string {
    if (type === 'gold') {
      return '#ffaa00'
    } else if (type === 'purple') {
      return '#7d3c98'
    } else {
      return '#1a5276'
    }
  }

  build() {
    Column() {
      if (!this.isGachaMode) {
        // 主界面
        Column() {
          // 标题
          Text('🎰 抽卡系统')
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 40 })

          // 按钮区域
          Row() {
            // 单抽按钮
            Button('单抽')
              .width(150)
              .height(60)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .linearGradient({
                angle: 135,
                colors: [['#667eea', 0], ['#764ba2', 1]]
              })
              .fontColor(Color.White)
              .borderRadius(10)
              .onClick(() => {
                this.startGacha(1)
              })

            Blank().width(20)

            // 十连抽按钮
            Button('十连抽')
              .width(150)
              .height(60)
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .linearGradient({
                angle: 135,
                colors: [['#f093fb', 0], ['#f5576c', 1]]
              })
              .fontColor(Color.White)
              .borderRadius(10)
              .onClick(() => {
                this.startGacha(10)
              })
          }
          .margin({ bottom: 40 })

          // 统计信息
          if (this.totalPulls > 0) {
            Column() {
              Text('📊 抽卡统计')
                .fontSize(24)
                .fontWeight(FontWeight.Bold)
                .fontColor('#333333')
                .margin({ bottom: 20 })

              Row() {
                Text('总抽数：')
                  .fontSize(18)
                Text(this.totalPulls.toString())
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .margin({ bottom: 10 })

              Row() {
                Text('金卡：')
                  .fontSize(18)
                  .fontColor('#ffaa00')
                Text(this.goldCount.toString())
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#ffaa00')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .margin({ bottom: 10 })

              Row() {
                Text('紫卡：')
                  .fontSize(18)
                  .fontColor('#9b59b6')
                Text(this.purpleCount.toString())
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#9b59b6')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
              .margin({ bottom: 10 })

              Row() {
                Text('蓝卡：')
                  .fontSize(18)
                  .fontColor('#3498db')
                Text(this.blueCount.toString())
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#3498db')
              }
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .width('80%')
            .padding(20)
            .backgroundColor('rgba(102, 126, 234, 0.1)')
            .borderRadius(10)
          }
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        // 抽卡展示界面
        Column() {
          // 进度文本
          Text(this.currentCards.length === 1 ? '恭喜获得！' : `第 ${this.currentIndex + 1} 张 / 共 ${this.currentCards.length} 张`)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .margin({ bottom: 30 })

          // 卡牌展示
          if (this.currentIndex < this.currentCards.length) {
            Column() {
              // 卡牌编号
              Text(`${this.currentIndex + 1}/${this.currentCards.length}`)
                .fontSize(18)
                .fontColor(Color.White)
                .backgroundColor('rgba(0, 0, 0, 0.3)')
                .padding({ left: 15, right: 15, top: 8, bottom: 8 })
                .borderRadius(20)
                .position({ x: '75%', y: 20 })

              // 卡牌图片
              Image(this.currentCards[this.currentIndex].image)
                .width(280)
                .height(280)
                .objectFit(ImageFit.Contain)
                .margin({ top: 60, bottom: 20 })

              // 卡牌名称
              Text(this.currentCards[this.currentIndex].name)
                .fontSize(32)
                .fontWeight(FontWeight.Bold)
                .fontColor(Color.White)
                .margin({ bottom: 10 })

              // 卡牌稀有度
              Text(this.currentCards[this.currentIndex].rarity)
                .fontSize(24)
                .fontColor('rgba(255, 255, 255, 0.9)')
            }
            .width(400)
            .height(550)
            .linearGradient(this.getCardBackgroundColor(this.currentCards[this.currentIndex].type))
            .border({ width: 5, color: this.getCardBorderColor(this.currentCards[this.currentIndex].type) })
            .borderRadius(20)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .shadow({ radius: 40, color: 'rgba(0, 0, 0, 0.3)', offsetX: 0, offsetY: 15 })
            .onClick(() => {
              this.showNextCard()
            })
            .margin({ bottom: 30 })
          }

          // 操作按钮
          Row() {
            Button('下一张')
              .width(120)
              .height(50)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .linearGradient({
                angle: 135,
                colors: [['#11998e', 0], ['#38ef7d', 1]]
              })
              .fontColor(Color.White)
              .borderRadius(8)
              .onClick(() => {
                this.showNextCard()
              })

            Blank().width(15)

            Button('退出')
              .width(120)
              .height(50)
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .linearGradient({
                angle: 135,
                colors: [['#eb3349', 0], ['#f45c43', 1]]
              })
              .fontColor(Color.White)
              .borderRadius(8)
              .onClick(() => {
                this.exitGacha()
              })
          }
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
    .linearGradient({
      angle: 135,
      colors: [['#667eea', 0], ['#764ba2', 1]]
    })
  }
}
