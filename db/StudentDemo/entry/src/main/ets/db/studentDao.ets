import { student } from '../model/student';
import { get_rdb } from './db';
import { relationalStore } from '@kit.ArkData';

const TABLE_NAME = "t_student"

export async function studentAll(): Promise<student[]> {
  let store = await get_rdb()
  let query = new relationalStore.RdbPredicates(TABLE_NAME)
  let rs = await store.query(query)
  let students = new Array<student>()
  while (rs.goToNextRow()) {
    let stu: student = {
      id: rs.getLong(rs.getColumnIndex("id")),
      name: rs.getString(rs.getColumnIndex("name")),
      age: rs.getLong(rs.getColumnIndex("age")),
      school: rs.getString(rs.getColumnIndex("school"))
    }

    students.push(stu)
  }
  return students
}

export async function studentUpdate(stu: student): Promise<number> {
  let store = await get_rdb()
  let query = new relationalStore.RdbPredicates(TABLE_NAME)
  query.equalTo("id", stu.id)
  let values: relationalStore.ValuesBucket = {
    "name": stu.name,
    "age": stu.age,
    "school": stu.school,
  }
  return store.update(values, query)
}

export async function studentDelete(id: number): Promise<number> {
  let store = await get_rdb()
  let query = new relationalStore.RdbPredicates(TABLE_NAME)
  query.equalTo("id", id)
  return store.delete(query)
}

export async function studentAdd(stu: student): Promise<number> {
  let store = await get_rdb()
  let values: relationalStore.ValuesBucket = {
    // "id": null,
    "name": stu.name,
    "age": stu.age,
    "school": stu.school,
  }
  return store.insert(TABLE_NAME, values)
}