///|
typealias @respo_node.RespoNode

///|
fnalias @respo_node.(text_node, a, pre, static_style)

///|
fnalias @respo.(ui_row_middle, ui_row, ui_font_code)

///|
struct ContainerState {
  counted : Int
} derive(Default, ToJson, @json.FromJson)

///|
struct LinkEntry {
  name : String
  route : RootRoute
} derive(ToJson, @json.FromJson, Show)

///|
let entries : Array[LinkEntry] = [
  { name: "Home", route: RootRoute::Home },
  { name: "Team", route: RootRoute::Team("aa", Some(SubRouteTeam::Home)) },
  { name: "Room", route: RootRoute::Team("team-1", Some(Room("room-1"))) },
  { name: "Search", route: RootRoute::Search("query") },
  { name: "Invalid", route: RootRoute::Invalid("invalid-route") },
]

///|
fn comp_container(
  states : @respo.RespoStatesTree,
  router : RootRoute
) -> RespoNode[ActionOp] {
  let ((_state : ContainerState), _cursor) = states.local_pair()
  div([
    div(
      class_name=ui_row_middle,
      ["Entries:" |> text_node] +
      entries.map(fn(entry) {
        let route = entry.route.format()
        let class_name = if false { "active-link" } else { "link" }
        div(
          [
            a(
              inner_text=entry.name,
              class_name~,
              href="#\{route}",
              style=respo_style(margin=Px(4)),
            ),
          ],
          on_click=fn(e, dispatch) {
            if e is Click(original_event~, ..) {
              original_event.prevent_default()
            }
            dispatch.run!(ActionOp::Route(entry.route))
          },
        )
      }),
    ),
    div(class_name=ui_row, [
      "Path:" |> text_node,
      pre(
        class_list=["json-dump", ui_font_code, style_code_block],
        inner_text=router.format(),
      ),
    ]),
    div(class_name=ui_row, [
      "Data:" |> text_node,
      pre(
        class_list=["json-dump", ui_font_code, style_code_block],
        inner_text=router.to_json().stringify(indent=2),
      ),
    ]),
  ])
}

///|
let style_code_block : String = static_style([
  (
    "&",
    respo_style(
      margin=Px(0),
      background_color=RawString("#fafafa"),
      padding=Px(8),
      border_radius=4,
      font_family="monospace",
      border=(1, Solid, RawString("#ddd")),
    ),
  ),
])
