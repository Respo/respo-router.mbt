///|
fnalias @respo.(ui_global, ui_button)

///|
fnalias @respo_node.(div, span, button, respo_style)

///|
let app_store_key : String = "mbt-workflow"

///|
fn view(
  store : Store
) -> @respo_node.RespoNode[ActionOp]!@respo_node.RespoCommonError {
  if false {
    raise @respo_node.RespoCommonError("TODO")
  }
  // @dom_ffi.log("Store to render: " + store.to_json().stringify(indent=2))
  let states = store.get_states()
  div(class_name=ui_global, style=respo_style(padding=Px(12)), [
    comp_counter(states.pick("counter"), store.counted),
  ])
}

///|
fn main {
  let window = @dom_ffi.window()
  let mount_target = window
    .document()
    .query_selector(".app")
    .reinterpret_as_node()
  let app : @respo.RespoApp[Store] = {
    store: Ref::new(@respo.try_load_storage(app_store_key)),
    mount_target,
    storage_key: app_store_key,
  }
  app.backup_model_beforeunload()
  // @dom_ffi.log("store: " + app.store.val.to_json().stringify(indent=2))
  app.render_loop(
    fn() {
      @respo_router.render_url(app.store.val.router.route_serialize())
      view!(app.store.val)
    },
    fn(op) {
      @dom_ffi.log("Action: " + op.to_string())
      app.store.val.update(op)
    },
  )
  @respo_router.listen_route(window, fn(route) {
    @dom_ffi.log("route changed: " + route)
    let parsed = RootRoute::route_parse(route)
    app.store.val.update(ActionOp::Route(parsed))
  })
  let dev_mode = @dom_ffi.new_url_search_params(window.location().search()).get(
    "mode",
  )
  @dom_ffi.log("dev mode: " + dev_mode.to_string())
  @dom_ffi.log(
    "app: " +
    RootRoute::Team("aa", Some(SubRouteTeam::Invalid("11")))
    .to_json()
    .to_string(),
  )
}
