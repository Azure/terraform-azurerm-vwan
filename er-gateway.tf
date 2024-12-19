resource "azurerm_express_route_gateway" "express_route_gateway" {
  for_each = local.expressroute_gateways != null && length(local.expressroute_gateways) > 0 ? local.expressroute_gateways : {}

  location                      = azurerm_virtual_hub.virtual_hub[each.value.virtual_hub_key].location
  name                          = each.value.name
  resource_group_name           = azurerm_virtual_hub.virtual_hub[each.value.virtual_hub_key].resource_group_name
  scale_units                   = each.value.scale_units
  virtual_hub_id                = azurerm_virtual_hub.virtual_hub[each.value.virtual_hub_key].id
  allow_non_virtual_wan_traffic = each.value.allow_non_virtual_wan_traffic
  tags                          = try(each.value.tags, {})
}


# Create the Express Route Connection
resource "azurerm_express_route_connection" "er_connection" {
  for_each = local.er_circuit_connections != null && length(local.er_circuit_connections) > 0 ? local.er_circuit_connections : {}

  express_route_circuit_peering_id = each.value.express_route_circuit_peering_id
  express_route_gateway_id         = azurerm_express_route_gateway.express_route_gateway[each.value.express_route_gateway_key].id
  name                             = each.value.name
  authorization_key                = try(each.value.authorization_key, null)
  enable_internet_security         = try(each.value.enable_internet_security, null)
  routing_weight                   = try(each.value.routing_weight, null)

  dynamic "routing" {
    for_each = each.value.routing != null ? [each.value.routing] : []

    content {
      associated_route_table_id = try(azurerm_virtual_hub_route_table.virtual_hub_route_table[each.value.associated_route_table_key].id, routing.value.associated_route_table_id)
      inbound_route_map_id      = try(routing.value.inbound_route_map_id, null)
      outbound_route_map_id     = try(routing.value.outbound_route_map_id, null)

      dynamic "propagated_route_table" {
        for_each = routing.value.propagated_route_table != null ? [routing.value.propagated_route_table] : []

        content {
          labels = try(propagated_route_table.value.labels, [])
          route_table_ids = coalesce(
            compact(flatten([
              for route_table_key in try(propagated_route_table.value.route_table_keys, []) :
              azurerm_virtual_hub_route_table.virtual_hub_route_table[route_table_key].id
            ])),
            try(propagated_route_table.value.route_table_ids, [])
          )
        }
      }
    }
  }
}
