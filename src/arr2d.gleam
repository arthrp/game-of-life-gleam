import gleam/list
import gleam/result
import glearray

pub type Arr2d(a) =
  glearray.Array(glearray.Array(a))

pub fn init_default() -> Arr2d(Bool) {
  glearray.from_list([])
}

pub fn get_el(arr: Arr2d(Bool), x: Int, y: Int) -> Result(Bool, Nil) {
  case glearray.get(arr, at: y) {
    Ok(row) -> glearray.get(row, at: x)
    Error(_) -> Error(Nil)
  }
}

//try set element or noop if fail
pub fn set_el(arr: Arr2d(Bool), x: Int, y: Int, v: Bool) -> Arr2d(Bool) {
  case glearray.get(arr, at: y) {
    Ok(row) ->
      case glearray.copy_set(row, at: x, value: v) {
        Ok(new_row) ->
          glearray.copy_set(arr, at: y, value: new_row)
          |> result.unwrap(arr)
        Error(_) -> arr
      }
    Error(_) -> arr
  }
}
