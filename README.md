## Respo Router in MoonBit

Defining router rules is currently a bit verbose in MoonBit since lack of metaprogramming features. You need to implement trait methods manually, namely `parse` and `format`.

```moonbit
///|
enum RootRoute {
  Home
  Team(String, SubRouteTeam?)
  Search(String)
  Invalid(String)
} derive(Default, ToJson, @json.FromJson, Show, Eq)

///|
impl RespoRouterRule for RootRoute with parse(s : String) {
  let xs = @respo_router.split_route(s)
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
```

To config router mode:

```moonbit
@respo_router.set_router_mode(Hash)
```

To render url from:

```moonbit
@respo_router.render_url(app.store.val.router)
```

To parse the current URL and update the store:

```moonbit
@respo_router.listen_route(window, fn(route) {
  app.store.val.update(Route(RootRoute::parse(route)))
  @respo.mark_need_rerender()
})
```

### Develop

```bash
moon build --target js --debug --watch

yarn
yarn vite
```

To build the project, run:

```bash
moon build --target js
yarn
yarn vite build --base ./
```

### License

Apache License 2.0
