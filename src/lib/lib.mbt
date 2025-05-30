///|
pub(all) enum RouterMode {
  Hash
  History
}

///|
pub let router_mode : Ref[RouterMode] = Ref::new(RouterMode::Hash)

///|
pub(all) struct RespoRoute {
  prefix : String
  params : Array[String]
  next : Array[RespoRoute]?
}

///|
pub(open) trait RespoRouterDefinition: ToJson + @json.FromJson {
  // get_rules() -> Array[RespoRoute]
  route_parse(String) -> Self
  route_serialize(Self) -> String
}

///| split_route into non-empty parts
pub fn split_route(route : String) -> Array[String] {
  route
  .split("/")
  .map(fn(x) { x.to_string() })
  .filter(fn(x) { x != "" })
  .to_array()
}

///|
pub fn listen_route(
  window : @dom_ffi.Window,
  on_route_change : (String) -> Unit
) -> Unit {
  match router_mode.val {
    RouterMode::Hash =>
      window.add_event_listener_with_callback("hashchange", fn(_e) {
        let hash = window.location().hash()
        let route = hash.substring(start=1)
        on_route_change(route)
        false
      })
    RouterMode::History =>
      window.add_event_listener_with_callback("popstate", fn(_e) {
        let path = window.location().pathname()
        on_route_change(path)
        false
      })
  }
}

///|
priv extern type Location

///|
extern "js" fn Location::js_set_hash(hash : String) -> Unit =
  #| (hash) => { window.location.hash = hash }

///|
priv extern type History

///|
extern "js" fn History::push_state(url : String) -> Unit =
  #| (url) => { window.history.pushState({}, "", url) }

///|
pub fn render_url(route : String) -> Unit {
  match router_mode.val {
    RouterMode::Hash => Location::js_set_hash(route)
    RouterMode::History => History::push_state(route)
  }
}
