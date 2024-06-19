export interface Process {
  _id: string
  approve_number: string // 审批编号
  department: string // 所在部门
  type_id: string // 类型 1：人事管理 2：行政事务 3：财务类 4：业务相关
  type: string // 请假类型
  reason: string // 请假事由/加班原因
  begin_date: string // 请假/加班开始日期
  end_date: string // 请假/加班结束日期
  begin_time: string // 请假/加班开始时间
  end_time: string // 请假/加班结束时间
  days: string // 请假/加班天数
  hours: string // 请假/加班小时
  initiator: string // 发起人
  department_leader: string // 部门领导
  personnel_department: string // 人事部
  cc_persons: string[] // 抄送人
  approve_status: number // 审批状态 1：待审批 2、正在审批中 3、审批通过  4：拒绝
  status: number // 状态 1：启动 0：禁用
  created_at: string
  updated_at: string
}