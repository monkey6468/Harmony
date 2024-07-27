export const CREATE_TABLE =
  "create table if not exists t_student (id integer primary key autoincrement, name varchar(40) not null, age integer(3) not null, school text not null)"