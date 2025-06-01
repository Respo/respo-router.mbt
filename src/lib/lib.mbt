/// This file defines the structure and behavior of the Respo router.
/// It's a simple router that can handle both hash-based and history-based routing.

///| Respo Router
pub(all) enum RouterMode {
  /// use hash mode, e.g. #/path/to/resource
  Hash
  /// use history mode, e.g. /path/to/resource
  History
}

///|
let router_mode : Ref[RouterMode] = Ref::new(Hash)

///| set the router mode, either Hash or History, default is Hash
pub fn set_router_mode(mode : RouterMode) -> Unit {
  router_mode.val = mode
}

// ///|
// pub struct RespoRoute {
//   prefix : String
//   params : Array[String]
//   next : Array[RespoRoute]?
// }

///| RespoRouterDefinition is a trait for defining routes in Respo applications
pub(open) trait RespoRouterRule: ToJson + @json.FromJson {
  // get_rules() -> Array[RespoRoute]
  parse(String) -> Self
  format(Self) -> String
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
fn strip_leading_prefix(s : String) -> String {
  if s.has_prefix("#") {
    s.substring(start=1)
  } else {
    s
  }
}

///| listen to route changes, and call the callback with the new route
pub fn listen_route(
  window : @dom_ffi.Window,
  on_route_change : (String) -> Unit
) -> Unit {
  match router_mode.val {
    RouterMode::Hash =>
      window.add_event_listener_with_callback("hashchange", fn(_e) {
        let hash = window.location().hash() |> strip_leading_prefix
        on_route_change(hash)
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

///| render_url will change the URL in the browser, either by setting the hash or using the history API
pub fn[T : RespoRouterRule + Eq + Show] render_url(route : T) -> Unit {
  match router_mode.val {
    RouterMode::Hash => {
      let current_hash = @dom_ffi.window().location().hash()
        |> strip_leading_prefix
      let parsed = T::parse(current_hash)
      if parsed != route {
        // println("Setting hash to: \{route} from \{current_hash}")
        Location::js_set_hash(route.format())
      }
    }
    RouterMode::History => {
      let current_path = @dom_ffi.window().location().pathname()
      let parsed = T::parse(current_path)
      if parsed != route {
        // println("Setting path to: \{route} from \{current_path}")
        History::push_state(route.format())
      }
    }
  }
}
