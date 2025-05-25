///|
pub(all) struct RespoRoute {
  prefix : String
  params : Array[String]
  next : Array[RespoRoute]?
}

///|
pub(open) trait RespoRouterDefinition: ToJson + @json.FromJson {
  get_rules() -> Array[RespoRoute]
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
