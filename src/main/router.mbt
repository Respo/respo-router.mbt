///|
fnalias @respo_router.split_route

///|
traitalias @respo_router.RespoRouterRule

///|
enum SubRouteTeam {
  Home
  Room(String)
  Invalid(String)
} derive(Default, ToJson, @json.FromJson, Show, Eq)

///|
// impl RespoRouterRule for SubRouteTeam with get_rules() {
//   [{ prefix: "room", params: ["room_id"], next: None }]
// }

///|
impl RespoRouterRule for SubRouteTeam with parse(s : String) {
  let xs = split_route(s)
  match xs {
    [] => Home
    ["room", x] => Room(x)
    _ => Invalid(s)
  }
}

///|
impl RespoRouterRule for SubRouteTeam with format(route) {
  match route {
    Home => "/"
    Room(room_id) => "/room/\{room_id}"
    Invalid(route) => route
  }
}

///|
enum RootRoute {
  Home
  Team(String, SubRouteTeam?)
  Search(String)
  Invalid(String)
} derive(Default, ToJson, @json.FromJson, Show, Eq)

// ///|
// impl RespoRouterRule for RootRoute with get_rules() {
//   [
//     {
//       prefix: "team",
//       params: ["team_id"],
//       next: Some(SubRouteTeam::get_rules()),
//     },
//     { prefix: "room", params: ["room_id"], next: None },
//     { prefix: "search", params: ["query"], next: None },
//     { prefix: "", params: [], next: None },
//   ]
// }

///|
impl RespoRouterRule for RootRoute with parse(s : String) {
  let xs = split_route(s)
  match xs {
    ["team", team_id, .. rest] =>
      Team(
        team_id,
        if rest.length() == 0 {
          None
        } else {
          Some(RespoRouterRule::parse(rest.to_array().join("/")))
        },
      )
    ["search", query] => Search(query)
    [] => Home
    _ => Invalid(s)
  }
}

///|
impl RespoRouterRule for RootRoute with format(self) {
  match self {
    Home => "/"
    Team(team_id, sub_route) => {
      let p = "/team/\{team_id}"
      if sub_route is Some(sub_route) {
        "\{p}" + RespoRouterRule::format(sub_route)
      } else {
        p
      }
    }
    Search(query) => "/search/\{query}"
    Invalid(route) => route
  }
}
