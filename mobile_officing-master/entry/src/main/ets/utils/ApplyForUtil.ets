// 根据申请状态返回申请结果文字
export const applyForStatus = (status: number) => {
  switch (status) {
    case 1:
      return "待审批"
    case 2:
      return "正在审批中"
    case 3:
      return "审批通过"
    case 4:
      return "拒绝"
  }
}

// 根据申请状态返回对应的颜色值
export const applyForStatusColor = (status: number) => {
  switch (status) {
    case 1:
      return '#ff5f35'
    case 2:
      return '#53cbae'
    case 3:
      return '#53cbae'
    case 4:
      return '#ff5f35'
  }
}