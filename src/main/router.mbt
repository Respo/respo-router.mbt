///|
fnalias @respo_router.split_route

///|
traitalias @respo_router.RespoRouterDefinition

///|
enum SubRouteTeam {
  Home
  Room(String)
  Invalid(String)
} derive(Default, ToJson, @json.FromJson)

///|
impl RespoRouterDefinition for SubRouteTeam with get_rules() {
  [{ prefix: "room", params: ["room_id"], next: None }]
}

///|
impl RespoRouterDefinition for SubRouteTeam with route_parse(s : String) {
  let xs = split_route(s)
  match xs {
    [] => Home
    ["room", x] => Room(x)
    _ => Invalid(s)
  }
}

///|
impl RespoRouterDefinition for SubRouteTeam with route_serialize(route) {
  match route {
    Home => ""
    Room(room_id) => "room/" + room_id
    Invalid(route) => route
  }
}

///|
enum RootRoute {
  Home
  Team(String, SubRouteTeam?)
  Room(String)
  Search(String)
  Invalid(String)
} derive(Default, ToJson, @json.FromJson)

///|
impl RespoRouterDefinition for RootRoute with get_rules() {
  [
    {
      prefix: "team",
      params: ["team_id"],
      next: Some(SubRouteTeam::get_rules()),
    },
    { prefix: "room", params: ["room_id"], next: None },
    { prefix: "search", params: ["query"], next: None },
    { prefix: "", params: [], next: None },
  ]
}

///|
impl RespoRouterDefinition for RootRoute with route_parse(s : String) {
  let xs = split_route(s)
  match xs {
    ["team", team_id, rest] =>
      Team(team_id, Some(SubRouteTeam::route_parse(rest)))
    ["room", room_id] => Room(room_id)
    ["search", query] => Search(query)
    [] => Home
    _ => Invalid(s)
  }
}

///|
impl RespoRouterDefinition for RootRoute with route_serialize(route) {
  match route {
    Home => ""
    Team(team_id, sub_route) =>
      if sub_route is Some(sub_route) {
        "team/" + team_id + "/" + SubRouteTeam::route_serialize(sub_route)
      } else {
        "team/" + team_id
      }
    Room(room_id) => "room/" + room_id
    Search(query) => "search/" + query
    Invalid(route) => route
  }
}
