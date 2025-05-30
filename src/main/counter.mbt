///|
typealias @respo_node.(RespoEvent, RespoNode, DispatchFn, RespoCommonError)

///|
fnalias @respo_node.text_node

///|
struct MainState {
  counted : Int
} derive(Default, ToJson, @json.FromJson)

///|
fn comp_counter(
  states : @respo.RespoStatesTree,
  global_counted : Int
) -> RespoNode[ActionOp] {
  let cursor = states.path()
  let state = (states.cast_branch() : MainState)
  let counted = state.counted
  let on_inc = fn(
    e : RespoEvent,
    dispatch : DispatchFn[ActionOp]
  ) -> Unit!RespoCommonError {
    @dom_ffi.warn_log("inc click: \{e}")
    if e is Click(original_event~, ..) {
      original_event.prevent_default()
    }
    dispatch.run!(Increment)
    let next_state = MainState::{ counted: state.counted + 1 }
    dispatch.set_state!(cursor, next_state)
  }
  let on_dec = fn(
    e : RespoEvent,
    dispatch : DispatchFn[ActionOp]
  ) -> Unit!RespoCommonError {
    @dom_ffi.warn_log("dec click: \{e}")
    dispatch.run!(Decrement)
    let next_state = MainState::{ counted: state.counted - 1 }
    dispatch.set_state!(cursor, next_state)
  }
  let on_inc_twice = fn(
    e : RespoEvent,
    dispatch : DispatchFn[ActionOp]
  ) -> Unit!RespoCommonError {
    @dom_ffi.warn_log("twice click: \{e}")
    dispatch.run!(IncTwice)
    let next_state = MainState::{ counted: state.counted + 2 }
    dispatch.set_state!(cursor, next_state)
  }
  div([
    div([
      button(
        inner_text="demo inc",
        class_name=ui_button,
        style=respo_style(margin=4 |> Px),
        on_click=on_inc,
      ),
      button(
        inner_text="demo dec",
        class_name=ui_button,
        style=respo_style(margin=4 |> Px),
        on_click=on_dec,
      ),
      button(
        inner_text="demo inc twice",
        class_name=ui_button,
        style=respo_style(margin=4 |> Px),
        on_click=on_inc_twice,
      ),
    ]),
    div([
      span(
        inner_text="value is: \{counted}",
        style=respo_style(
          color=Hsluv(270, 100, 40),
          font_family="Menlo",
          font_size=counted.reinterpret_as_uint() + 10,
        ),
        [],
      ),
    ]),
    div([
      "local state: \{counted}" |> text_node,
      @respo_node.br(),
      "global state: \{global_counted}" |> text_node,
    ]),
  ])
}
