import { Employee } from './Employee'

export interface Department {
  _id: string
  name: string
  team: string
  employees: Employee[]
}