import gleam/erlang/process
import gleam/io
import gleam/list
import gleam/result
import gleam/string
import glearray

import arr2d.{type Arr2d}

const field_width: Int = 20

const field_height: Int = 20

fn init_arr() -> Arr2d(Bool) {
  let inner_arr = glearray.from_list(list.repeat(False, times: field_width))
  let outer_arr =
    glearray.from_list(list.repeat(inner_arr, times: field_height))
    |> arr2d.set_el(2, 2, True)
    |> arr2d.set_el(2, 3, True)
    |> arr2d.set_el(2, 4, True)
  outer_arr
}

fn new_arr(arr: Arr2d(Bool)) -> Arr2d(Bool) {
  let width = field_width
  let height = field_height

  let new_list =
    list.range(0, height - 1)
    |> list.map(fn(y) {
      let row =
        list.range(0, width - 1)
        |> list.map(fn(x) {
          let existing_val = arr2d.get_el(arr, x, y)
          let new_val = case existing_val, count_neighbours(arr, x, y) {
            Ok(True), 2 -> True
            Ok(True), 3 -> True
            Ok(False), 3 -> True
            _, _ -> False
          }
          new_val
        })
      glearray.from_list(row)
    })

  glearray.from_list(new_list)
}

fn print_arr(arr: Arr2d(Bool)) {
  let height = glearray.length(arr)

  let full_str =
    list.range(0, height - 1)
    |> list.map(fn(y) {
      let y_arr =
        glearray.get(arr, at: y)
        |> result.unwrap(glearray.new())

      let width = glearray.length(y_arr)
      let _line =
        list.range(0, width - 1)
        |> list.map(fn(x) {
          glearray.get(y_arr, at: x)
          |> result.unwrap(False)
          |> bool_to_str
        })
        |> string.concat
        <> "\n"
    })
    |> string.concat

  io.println(full_str)
}

fn bool_to_str(b: Bool) -> String {
  case b {
    True -> "■ "
    False -> "□ "
  }
}

fn count_neighbours(arr: Arr2d(Bool), cell_x: Int, cell_y: Int) -> Int {
  let total =
    list.range(-1, 1)
    |> list.fold(0, fn(y_acc, dy) {
      let y = { cell_y + dy + field_height } % field_height
      let inner =
        list.range(-1, 1)
        |> list.fold(0, fn(acc, dx) {
          let i = case dx, dy {
            0, 0 -> 0
            _, _ -> {
              let x = { cell_x + dx + field_width } % field_width
              let inc = case arr2d.get_el(arr, x, y) {
                Ok(True) -> 1
                _ -> 0
              }
              inc
            }
          }
          acc + i
        })
      y_acc + inner
    })

  total
}

fn game_loop(arr: Arr2d(Bool)) {
  io.print("\u{001b}[2J")
  print_arr(arr)
  process.sleep(300)

  let new_arr = new_arr(arr)
  game_loop(new_arr)
}

pub fn main() {
  let arr = init_arr()

  game_loop(arr)
}
