<!-- BEGIN_TF_DOCS -->
# Terraform Verified Module for Azure Virtual WAN Hub Networking

[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/Azure/terraform-azurerm-vwan.svg)](http://isitmaintained.com/project/Azure/terraform-azurerm-vwan "Average time to resolve an issue")
[![Percentage of issues still open](http://isitmaintained.com/badge/open/Azure/terraform-azurerm-vwan.svg)](http://isitmaintained.com/project/Azure/terraform-azurerm-vwan "Percentage of issues still open")

This module is designed to simplify the creation of virtual wan based networks in Azure.

## Features

- Virtual WAN:
- Virtual WAN Hub:
  - Virtual WAN Hub.
  - Secured Virtual Hub.
  - Routing intent
- Azure Firewall
  - Secured Virtual Hub
  - AzureFirewallSubnet.
- Site-to-Site Virtual Network Gateway:
  - S2S VPN Gateway.
  - Active-Active or Single.
  - VPN Site
  - VPN Site Connection
  - Deployment of `GatewaySubnet`.
- Point-to-Site Virtual Network Gateway:
  - P2S VPN Gateway.
  - P2S server configuration.
  - Active-Active or Single.
  - Deployment of `GatewaySubnet`.
- ER Gateway:
  - ER Gateway.
  - ER Gateway Connection.
  - Active-Active or Single.
  - Deployment of `GatewaySubnet`.

## Example

```terraform
module "vwan_with_vhub" {
  source                         = "../../"
  resource_group_name            = "tvmVwanRg"
  location                       = "australiaeast"
  virtual_wan_name               = "tvmVwan"
  disable_vpn_encryption         = false
  allow_branch_to_branch_traffic = true
  bgp_community                  = "12076:51010"
  type                           = "Standard"
  virtual_wan_tags = {
    environment = "dev"
    deployment  = "terraform"
  }
  virtual_hubs = {
    aue-vhub = {
      name           = "aue_vhub"
      location       = "australiaeast"
      resource_group = "demo-vwan-rsg"
      address_prefix = "10.0.0.0/24"
      tags = {
        "location" = "AUE"
      }
    }
  }
  vpn_gateways = {
    "aue-vhub-vpn-gw" = {
      name            = "aue-vhub-vpn-gw"
      virtual_hub_key = "aue-vhub"
    }
  }
  vpn_sites = {
    "aue-vhub-vpn-site" = {
      name            = "aue-vhub-vpn-site"
      virtual_hub_key = "aue-vhub"
      links = [{
        name          = "link1"
        provider_name = "Cisco"
        bgp = {
          asn             = 65001
          peering_address = "172.16.1.254"
        }
        ip_address    = "20.28.182.157"
        speed_in_mbps = "20"
      }]
    }
  }
  vpn_site_connections = {
    "onprem1" = {
      name                = "aue-vhub-vpn-conn01"
      vpn_gateway_key     = "aue-vhub-vpn-gw"
      remote_vpn_site_key = "aue-vhub-vpn-site"

      vpn_links = [{
        name                                  = "link1"
        bandwidth_mbps                        = 10
        bgp_enabled                           = true
        local_azure_ip_address_enabled        = false
        policy_based_traffic_selector_enabled = false
        ratelimit_enabled                     = false
        route_weight                          = 1
        shared_key                            = "AzureA1b2C3"
        vpn_site_link_number                  = 0
      }]
    }
  }
}

```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.7)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.108)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.6)

## Resources

The following resources are used by this module:

- [azurerm_express_route_connection.er_connection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_connection) (resource)
- [azurerm_express_route_gateway.express_route_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_gateway) (resource)
- [azurerm_firewall.fw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/firewall) (resource)
- [azurerm_point_to_site_vpn_gateway.p2s_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/point_to_site_vpn_gateway) (resource)
- [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) (resource)
- [azurerm_virtual_hub.virtual_hub](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub) (resource)
- [azurerm_virtual_hub_connection.hub_connection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub_connection) (resource)
- [azurerm_virtual_hub_route_table.virtual_hub_route_table](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub_route_table) (resource)
- [azurerm_virtual_hub_routing_intent.routing_intent](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_hub_routing_intent) (resource)
- [azurerm_virtual_wan.virtual_wan](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_wan) (resource)
- [azurerm_vpn_gateway.vpn_gateway](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/vpn_gateway) (resource)
- [azurerm_vpn_gateway_connection.vpn_site_connection](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/vpn_gateway_connection) (resource)
- [azurerm_vpn_server_configuration.p2s_gateway_vpn_server_configuration](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/vpn_server_configuration) (resource)
- [azurerm_vpn_site.vpn_site](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/vpn_site) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/Azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/Azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description:   The Virtual WAN location.

  > Note: This is not the location for the Virtual WAN Hubs, these are defined within the `virtual_hubs` variable in their own `location` property of each object.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description:   Name of the Resource Group where the Virtual WAN and it's child resources, e.g. Virtual WAN Hubs, Gateways etc., will be created.

  The Resource Group will be created if the variable `create_resource_group` is set to `true`. If it is set to `false` the resource group must already exist.

  > Note: Each Virtual WAN Hub can be configured to deploy into different resource groups, that must already exist or be created outside of this module, by specifying the `resource_group` property in each object in the `virtual_hubs` variable map input. If you do not do this, the same resource group will be used for all Virtual WAN resources as specified in this variable.

Type: `string`

### <a name="input_virtual_wan_name"></a> [virtual\_wan\_name](#input\_virtual\_wan\_name)

Description: Name of the Virtual WAN resource itself.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_allow_branch_to_branch_traffic"></a> [allow\_branch\_to\_branch\_traffic](#input\_allow\_branch\_to\_branch\_traffic)

Description:   Boolean toggle to toggle support for VWAN branch to branch traffic. Branches are locations connected over ExpressRoute or Site-to-Site VPNs to a Virtual WAN Hub. Defaults to true.

  For more information review: https://learn.microsoft.com/azure/virtual-wan/virtual-wan-global-transit-network-architecture

Type: `bool`

Default: `true`

### <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group)

Description:   If `true` will create a resource group, otherwise (`false`) will use an existing resource group specified in the variable `resource_group_name`"

Type: `bool`

Default: `false`

### <a name="input_disable_vpn_encryption"></a> [disable\_vpn\_encryption](#input\_disable\_vpn\_encryption)

Description:   Boolean toggle to disable VPN encryption. Defaults to `false` (VPN encryption enabled).

Type: `bool`

Default: `false`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.  
For more information see https://aka.ms/avm/telemetryinfo.  
If it is set to `false`, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_er_circuit_connections"></a> [er\_circuit\_connections](#input\_er\_circuit\_connections)

Description: Map of objects for ExpressRoute Circuit connections to connect to the Virtual WAN ExpressRoute Gateways.

The key is deliberately arbitrary to avoid issues with known after apply values. The value is an object, of which there can be multiple in the map:

- `name`: Name for the ExpressRoute Circuit connection.
- `express_route_gateway_key`: The arbitrary key specified in the map of objects variable called `expressroute_gateways` for the object specifying the ExpressRoute Gateway you wish to connect this circuit to.
- `express_route_circuit_peering_id`: The Resource ID of the ExpressRoute Circuit Peering to connect to.
- `authorization_key`: Optional authorization key for the connection.
- `enable_internet_security`: Optional boolean to enable internet security for the connection, e.g. allow `0.0.0.0/0` route to be propagated to this connection. See: https://learn.microsoft.com/azure/virtual-wan/virtual-wan-expressroute-portal#to-advertise-default-route-00000-to-endpoints
- `express_route_gateway_bypass_enabled`: Optional boolean to enable bypass for the ExpressRoute Gateway, a.k.a. Fast Path.
- `routing`: Optional routing configuration object for the connection, which includes:
  - `associated_route_table_id`: The resource ID of the Virtual Hub Route Table you wish to associate with this connection.
  - `propagated_route_table`: Optional configuration objection of propagated route table configuration, which includes:
    - `route_table_ids`: Optional list of resource IDs of the Virtual Hub Route Tables you wish to propagate this connection to. ()
    - `labels`: Optional list of labels you wish to propagate this connection to.
  - `inbound_route_map_id`: Optional resource ID of the Virtual Hub inbound route map.
  - `outbound_route_map_id`: Optional resource ID of the Virtual Hub outbound route map.
- `routing_weight`: Optional routing weight for the connection. Values between `0` and `32000` are allowed.

> Note: There can be multiple objects in this map, one for each ExpressRoute Circuit connection to the Virtual WAN ExpressRoute Gateway you wish to connect together.

Type:

```hcl
map(object({
    name                                 = string
    express_route_gateway_key            = string
    express_route_circuit_peering_id     = string
    authorization_key                    = optional(string)
    enable_internet_security             = optional(bool)
    express_route_gateway_bypass_enabled = optional(bool)
    routing = optional(object({
      associated_route_table_id  = optional(string)
      associated_route_table_key = optional(string)
      propagated_route_table = optional(object({
        route_table_ids  = optional(list(string))
        route_table_keys = optional(list(string))
        labels           = optional(list(string))
      }))
      inbound_route_map_id  = optional(string)
      outbound_route_map_id = optional(string)
    }))
    routing_weight = optional(number)
  }))
```

Default: `{}`

### <a name="input_expressroute_gateways"></a> [expressroute\_gateways](#input\_expressroute\_gateways)

Description:   
Map of objects for Express Route Gateways to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

The key is deliberately arbitrary to avoid issues with known after apply values. The value is an object, of which there can be multiple in the map:

- `name`: Name for the ExpressRoute Gateway to deploy in the Virtual WAN Virtual Hub.
- `virtual_hub_key`: The arbitrary key specified in the map of objects variable called `virtual_hubs` for the object specifying the Virtual Hub you wish to deploy this ExpressRoute Gateway into.
- `tags`: Optional tags to apply to the ExpressRoute Gateway resource.
- `allow_non_virtual_wan_traffic`: Optional boolean to configures this gateway to accept traffic from non Virtual WAN networks. Defaults to `false`.
- `scale_units`: Optional number of scale units for the ExpressRoute Gateway. Defaults to `1`. See: https://learn.microsoft.com/azure/virtual-wan/virtual-wan-expressroute-about#expressroute-gateway-performance for more information on scale units.

> Note: There can be multiple objects in this map, one for each ExpressRoute Gateway you wish to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

Type:

```hcl
map(object({
    name                          = string
    virtual_hub_key               = string
    tags                          = optional(map(string))
    allow_non_virtual_wan_traffic = optional(bool, false)
    scale_units                   = optional(number, 1)
  }))
```

Default: `{}`

### <a name="input_firewalls"></a> [firewalls](#input\_firewalls)

Description:   
Map of objects for Azure Firewall resources to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

The key is deliberately arbitrary to avoid issues with known after apply values. The value is an object, of which there can be multiple in the map:

- `virtual_hub_key`: The arbitrary key specified in the map of objects variable called `virtual_hubs` for the object specifying the Virtual Hub you wish to deploy this Azure Firewall into.
- `sku_name`: The SKU name for the Azure Firewall. Possible values are: `AZFW_VNet`, `AZFW_Hub`. Defaults to `AZFW_Hub`.
- `sku_tier`: The SKU tier for the Azure Firewall. Possible values are: `Basic`, `Standard`, `Premium`.
- `name`: The name for the Azure Firewall resource.
- `zones`: Optional list of zones to deploy the Azure Firewall into. Defaults to `[1, 2, 3]`.
- `firewall_policy_id`: Optional Azure Firewall Policy Resource ID to associate with the Azure Firewall.
- `vhub_public_ip_count`: Optional number of public IP addresses to associate with the Azure Firewall.
- `tags`: Optional tags to apply to the Azure Firewall resource.

> Note: There can be multiple objects in this map, one for each Azure Firewall you wish to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

Type:

```hcl
map(object({
    virtual_hub_key      = string
    sku_name             = optional(string, "AZFW_Hub")
    sku_tier             = string
    name                 = string
    zones                = optional(list(number), [1, 2, 3])
    firewall_policy_id   = optional(string)
    vhub_public_ip_count = optional(string)
    tags                 = optional(map(string))
  }))
```

Default: `{}`

### <a name="input_office365_local_breakout_category"></a> [office365\_local\_breakout\_category](#input\_office365\_local\_breakout\_category)

Description:   Specifies the Office 365 local breakout category. Possible values are:

  - `Optimize`
  - `OptimizeAndAllow`
  - `All`
  - `None`  

  Defaults to `None`.

Type: `string`

Default: `"None"`

### <a name="input_p2s_gateway_vpn_server_configurations"></a> [p2s\_gateway\_vpn\_server\_configurations](#input\_p2s\_gateway\_vpn\_server\_configurations)

Description:   Map of objects for Point-to-Site VPN Gateway VPN Server Configurations to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

  > You must use this variable in conjunction with the `p2s_gateways` variable to deploy Point-to-Site VPN Gateways and specify the key of the VPN Server Configuration you wish to use for each Point-to-Site VPN Gateway in the `p2s_gateways` variable, in the `p2s_gateway_vpn_server_configuration_key` property of each object.

  The key is deliberately arbitrary to avoid issues with known after apply values. The value is an object, of which there can be multiple in the map:

  - `name`: Name for the Point-to-Site VPN Gateway VPN Server Configuration.
  - `virtual_hub_key`: The arbitrary key specified in the map of objects variable called `virtual_hubs` for the object specifying the Virtual Hub you wish to deploy this VPN Server Configuration into.
  - `vpn_authentication_types`: List of VPN authentication types to support. Possible values are: `AAD`, `Certificate`, `Radius`.
  - `tags`: Optional tags to apply to the VPN Server Configuration resource.
  - `client_root_certificate`: Optional object for the client root certificate configuration, which includes:
    - `name`: Name for the client root certificate.
    - `public_cert_data`: Public certificate data for the client root certificate.
  - `azure_active_directory_authentication`: Optional object for the Azure Active Directory (Entra ID) authentication configuration, which includes:
    - `audience`: Audience for the Azure Active Directory (Entra ID) authentication.
    - `issuer`: Issuer for the Azure Active Directory (Entra ID) authentication.
    - `tenant`: Tenant for the Azure Active Directory (Entra ID)authentication.

  > Note: There can be multiple objects in this map, one for each Point-to-Site VPN Gateway VPN Server Configuration you wish to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

Type:

```hcl
map(object({
    name                     = string
    virtual_hub_key          = string
    vpn_authentication_types = list(string)
    tags                     = optional(map(string))
    client_root_certificate = optional(object({
      name             = string
      public_cert_data = string
    }))
    azure_active_directory_authentication = optional(object({
      audience = string
      issuer   = string
      tenant   = string
    }))
  }))
```

Default: `{}`

### <a name="input_p2s_gateways"></a> [p2s\_gateways](#input\_p2s\_gateways)

Description:   Map of objects for Point-to-Site VPN Gateways to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

  > You must use this variable in conjunction with the `p2s_gateway_vpn_server_configurations` variable to deploy Point-to-Site VPN Gateway VPN Server Configurations and specify the key of the VPN Server Configuration you wish to use for each Point-to-Site VPN Gateway in the `p2s_gateway_vpn_server_configuration_key` property of each object.

  The key is deliberately arbitrary to avoid issues with known after apply values. The value is an object, of which there can be multiple in the map:

  - `name`: Name for the Point-to-Site VPN Gateway.
  - `virtual_hub_key`: The arbitrary key specified in the map of objects variable called `virtual_hubs` for the object specifying the Virtual Hub you wish to deploy this Point-to-Site VPN Gateway into.
  - `tags`: Optional tags to apply to the Point-to-Site VPN Gateway resource.
  - `p2s_gateway_vpn_server_configuration_key`: The key of the VPN Server Configuration you wish to use for this Point-to-Site VPN Gateway from the `p2s_gateway_vpn_server_configurations` variable.
  - `connection_configuration`: Object for the connection configuration, which includes:
    - `name`: Name for the connection configuration.
    - `vpn_client_address_pool`: Object for the VPN client address pool configuration, which includes:
      - `address_prefixes`: List of address prefixes for the VPN client address pool.
  - `scale_unit`: Number of scale units for the Point-to-Site VPN Gateway. See: https://learn.microsoft.com/azure/virtual-wan/gateway-settings#p2s for more information on scale units.

  > Note: There can be multiple objects in this map, one for each Point-to-Site VPN Gateway you wish to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

Type:

```hcl
map(object({
    name                                     = string
    virtual_hub_key                          = string
    tags                                     = optional(map(string))
    p2s_gateway_vpn_server_configuration_key = string
    connection_configuration = object({
      name = string
      vpn_client_address_pool = object({
        address_prefixes = list(string)
      })
    })
    scale_unit = number
  }))
```

Default: `{}`

### <a name="input_resource_group_tags"></a> [resource\_group\_tags](#input\_resource\_group\_tags)

Description:   (Optional) Resource group tags to assign, if created by module controlled by variable `create_resource_group`.

Type: `map(string)`

Default: `{}`

### <a name="input_routing_intents"></a> [routing\_intents](#input\_routing\_intents)

Description:   Map of objects for routing intents to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

  The key is deliberately arbitrary to avoid issues with known after apply values. The value is an object, of which there can be multiple in the map:

  - `name`: Name for the routing intent resource.
  - `virtual_hub_key`: The arbitrary key specified in the map of objects variable called `virtual_hubs` for the object specifying the Virtual Hub you wish to deploy this routing intent into.
  - `routing_policies`: List of routing policies for the routing intent, which includes:
    - `name`: Name for the routing policy.
    - `destinations`: List of destinations for the routing policy. Allowed values are: `Internet`, `PrivateTraffic`.
    - `next_hop_firewall_key`: The arbitrary key specified in the map of objects variable called `firewalls` for the object specifying the Azure Firewall you wish to use as the next hop for the routing policy. This is used to get the correct resource ID for the corresponding Azure Firewall.

Type:

```hcl
map(object({
    name            = string
    virtual_hub_key = string
    routing_policies = list(object({
      name                  = string
      destinations          = list(string)
      next_hop_firewall_key = string
    }))
  }))
```

Default: `{}`

### <a name="input_tags"></a> [tags](#input\_tags)

Description:   (Optional) Tags to apply to the Resource Group, if created by module controlled by variable `create_resource_group`, and the Virtual WAN resource only.

Type: `map(string)`

Default: `null`

### <a name="input_type"></a> [type](#input\_type)

Description:   Type of the Virtual WAN to create. Possible values include:

  - `Basic`
  - `Standard`  

  Defaults to `Standard` and is recommended.

Type: `string`

Default: `"Standard"`

### <a name="input_virtual_hub_route_tables"></a> [virtual\_hub\_route\_tables](#input\_virtual\_hub\_route\_tables)

Description: - `name` - (Required) The name which should be used for Virtual Hub Route Table. Changing this forces a new resource to be created.
- `virtual_hub_key` - (Required) The key of the Virtual Hub within which this route table should be created. Changing this forces a new resource to be created.
- `labels` - (Optional) List of labels associated with this route table.
- `routes` - (Optional) A map of routes in the Virtual Hub Route Table. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
 - `name` - (Required) The name which should be used for this route.
 - `destinations` - (Required) A list of destination addresses for this route.
 - `destinations_type` - (Required) The type of destinations. Possible values are CIDR, ResourceId and Service.
 - `next_hop` - (Optional) The next hop's resource ID. Required if `vnet_connection_key` is not defined.
 - `vnet_connection_key` - (Optional) The next hop vnet connection's key. Required if `next_hop` is not defined.
 - `next_hop_type` - (Optional) The type of next hop. Currently the only possible value is ResourceId. Defaults to ResourceId.

Type:

```hcl
map(object({
    name            = string
    virtual_hub_key = string
    labels          = optional(list(string))
    routes = optional(map(object({
      name                = string
      destinations        = list(string)
      destinations_type   = string
      next_hop            = optional(string)
      vnet_connection_key = optional(string)
      next_hop_type       = string
    })))
  }))
```

Default: `{}`

### <a name="input_virtual_hubs"></a> [virtual\_hubs](#input\_virtual\_hubs)

Description:   Map of objects for Virtual Hubs to deploy into the Virtual WAN.

  The key is deliberately arbitrary to avoid issues with known after apply values. The value is an object, of which there can be multiple in the map:

  - `name`: Name for the Virtual Hub resource.
  - `location`: Location for the Virtual Hub resource.
  - `resource_group`: Optional resource group name to deploy the Virtual Hub into. If not specified, the Virtual Hub will be deployed into the resource group specified in the variable `resource_group_name`, e.g. the same as the Virtual WAN itself.
  - `address_prefix`: Address prefix for the Virtual Hub. Recommend using a `/23` CIDR block.
  - `tags`: Optional tags to apply to the Virtual Hub resource.
  - `hub_routing_preference`: Optional hub routing preference for the Virtual Hub. Possible values are: `ExpressRoute`, `ASPath`, `VpnGateway`. Defaults to `ExpressRoute`. See https://learn.microsoft.com/azure/virtual-wan/hub-settings#routing-preference for more information.
  - `virtual_router_auto_scale_min_capacity`: Optional minimum capacity for the Virtual Router auto scale. Defaults to `2`. See https://learn.microsoft.com/azure/virtual-wan/hub-settings#capacity for more information.

  > Note: There can be multiple objects in this map, one for each Virtual Hub you wish to deploy into the Virtual WAN. Multiple Virtual Hubs in the same region/location can be deployed into the same Virtual WAN also.

Type:

```hcl
map(object({
    name                                   = string
    location                               = string
    resource_group                         = optional(string, null)
    address_prefix                         = string
    tags                                   = optional(map(string))
    hub_routing_preference                 = optional(string, "ExpressRoute")
    virtual_router_auto_scale_min_capacity = optional(number, 2)
  }))
```

Default: `{}`

### <a name="input_virtual_network_connections"></a> [virtual\_network\_connections](#input\_virtual\_network\_connections)

Description:   Map of objects for Virtual Network connections to connect Virtual Networks to the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

  The key is deliberately arbitrary to avoid issues with known after apply values. The value is an object, of which there can be multiple in the map:

  - `name`: Name for the Virtual Network connection.
  - `virtual_hub_key`: The arbitrary key specified in the map of objects variable called `virtual_hubs` for the object specifying the Virtual Hub you wish to connect this Virtual Network to.
  - `remote_virtual_network_id`: The Resource ID of the Virtual Network you wish to connect to the Virtual Hub.
  - `internet_security_enabled`: Optional boolean to enable internet security for the connection, e.g. allow `0.0.0.0/0` route to be propagated to this connection.
  - `routing`: Optional routing configuration object for the connection, which includes:
    - `associated_route_table_id`: The resource ID of the Virtual Hub Route Table you wish to associate with this connection.
    - `propagated_route_table`: Optional configuration objection of propagated route table configuration, which includes:
      - `route_table_ids`: Optional list of resource IDs of the Virtual Hub Route Tables you wish to propagate this connections routes to.
      - `labels`: Optional list of labels you wish to propagate this connections routes to.
    - `static_vnet_route`: Optional configuration object for static VNet route configuration, which includes:
      - `name`: Optional name for the static VNet route.
      - `address_prefixes`: Optional list of address prefixes for the static VNet route.
      - `next_hop_ip_address`: Optional next hop IP address for the static VNet route.

  > Note: There can be multiple objects in this map, one for each Virtual Network connection you wish to connect to the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

Type:

```hcl
map(object({
    name                      = string
    virtual_hub_key           = string
    remote_virtual_network_id = string
    internet_security_enabled = optional(bool, false)
    routing = optional(object({
      associated_route_table_id = string
      propagated_route_table = optional(object({
        route_table_ids = optional(list(string), [])
        labels          = optional(list(string), [])
      }))
      static_vnet_route = optional(object({
        name                = optional(string)
        address_prefixes    = optional(list(string), [])
        next_hop_ip_address = optional(string)
      }))
    }))
  }))
```

Default: `{}`

### <a name="input_virtual_wan_tags"></a> [virtual\_wan\_tags](#input\_virtual\_wan\_tags)

Description:   (Optional) Tags to apply to the Virtual WAN resource only.

Type: `map(string)`

Default: `{}`

### <a name="input_vpn_gateways"></a> [vpn\_gateways](#input\_vpn\_gateways)

Description:   Map of objects for S2S VPN Gateways to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

  The key is deliberately arbitrary to avoid issues with known after apply values. The value is an object, of which there can be multiple in the map:

  - `name`: Name for the S2S VPN Gateway resource.
  - `virtual_hub_key`: The arbitrary key specified in the map of objects variable called `virtual_hubs` for the object specifying the Virtual Hub you wish to deploy this S2S VPN Gateway into.
  - `tags`: Optional tags to apply to the S2S VPN Gateway resource.
  - `bgp_route_translation_for_nat_enabled`: Optional boolean to enable BGP route translation for NAT.
  - `bgp_settings`: Optional BGP settings object for the S2S VPN Gateway, which includes:
    - `instance_0_bgp_peering_address`: Optional object for the instance 0 BGP peering address, which includes:
      - `custom_ips`: List of custom IPs for the instance 0 BGP peering address.
    - `instance_1_bgp_peering_address`: Optional object for the instance 1 BGP peering address, which includes:
      - `custom_ips`: List of custom IPs for the instance 1 BGP peering address.
    - `peer_weight`: BGP peer weight for the S2S VPN Gateway.
    - `asn`: BGP ASN for the BGP Speaker.
  - `routing_preference`: Optional Azure routing preference lets you to choose how your traffic routes between Azure and the internet. You can choose to route traffic either via the Microsoft network (default value, `Microsoft Network`), or via the ISP network (public internet, set to `Internet`). More context of the configuration can be found in the Microsoft Docs to create a VPN Gateway. Defaults to `Microsoft Network` if not set. Changing this forces a new resource to be created.
  - `scale_unit`: Optional number of scale units for the S2S VPN Gateway. See https://learn.microsoft.com/azure/virtual-wan/gateway-settings#s2s for more information on scale units.

  > Note: There can be multiple objects in this map, one for each S2S VPN Gateway you wish to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

Type:

```hcl
map(object({
    name                                  = string
    virtual_hub_key                       = string
    tags                                  = optional(map(string))
    bgp_route_translation_for_nat_enabled = optional(bool)
    bgp_settings = optional(object({
      instance_0_bgp_peering_address = optional(object({
        custom_ips = list(string)
      }))
      instance_1_bgp_peering_address = optional(object({
        custom_ips = list(string)
      }))
      peer_weight = number
      asn         = number
    }))
    routing_preference = optional(string)
    scale_unit         = optional(number)
  }))
```

Default: `{}`

### <a name="input_vpn_site_connections"></a> [vpn\_site\_connections](#input\_vpn\_site\_connections)

Description:   Map of objects for VPN Site connections to connect VPN Sites to the Virtual WAN VPN Gateways that have been defined in the variable `vpn_gateways`.

  The key is deliberately arbitrary to avoid issues with known after apply values. The value is an object, of which there can be multiple in the map:

  - `name`: Name for the VPN Site connection.
  - `vpn_gateway_key`: The arbitrary key specified in the map of objects variable called `vpn_gateways` for the object specifying the VPN Gateway you wish to connect this VPN Site to.
  - `remote_vpn_site_key`: The arbitrary key specified in the map of objects variable called `vpn_sites` for the object specifying the VPN Site you wish to connect this VPN Site connection to.
  - `vpn_links`: List of VPN links for the VPN Site connection, which includes:
    - `name`: Name for the VPN link.
    - `egress_nat_rule_ids`: Optional list of egress NAT rule IDs.
    - `ingress_nat_rule_ids`: Optional list of ingress NAT rule IDs.
    - `vpn_site_link_number`: Index of the link on the VPN Gateway.
    - `bandwidth_mbps`: Optional bandwidth in Mbps for the VPN link.
    - `bgp_enabled`: Optional boolean to enable BGP for the VPN link.
    - `connection_mode`: Optional connection mode for the VPN link. Allowed values are: `Default`, `InitiatorOnly`, `ResponderOnly`. Defaults to `Default`.
    - `ipsec_policy`: Optional IPsec policy object for the VPN link, which includes:
      - `dh_group`: DH group for the IPsec policy. Allowed values are: `DHGroup1`, `DHGroup2`, `DHGroup14`, `DHGroup24`, `DHGroup2048`, `ECP256`, `ECP384`.
      - `ike_encryption_algorithm`: IKE encryption algorithm for the IPsec policy. Allowed values are: `AES128`, `AES192`, `AES256`, `DES`, `DES3`, `GCMAES128`, `GCMAES256`.
      - `ike_integrity_algorithm`: IKE integrity algorithm for the IPsec policy. Allowed values are: `MD5`, `SHA1`, `SHA256`, `SHA384`, `SHA512`, `GCMAES128`, `GCMAES256`.
      - `encryption_algorithm`: Encryption algorithm for the IPsec policy. Allowed values are: `AES128`, `AES192`, `AES256`, `DES`, `DES3`, `GCMAES128`, `GCMAES192`, `GCMAES256`, `None`.
      - `integrity_algorithm`: Integrity algorithm for the IPsec policy. Allowed values are: `MD5`, `SHA1`, `SHA256`, `GCMAES128`, `GCMAES192`, `GCMAES256`.
      - `pfs_group`: PFS group for the IPsec policy. Allowed values are: `None`, `PFS1`, `PFS2`, `PFS14`, `PFS24`, `PFS2048`, `PFSMM`, `ECP256`, `ECP384`.
      - `sa_data_size_kb`: SA data size in KB for the IPsec policy.
      - `sa_lifetime_sec`: SA lifetime in seconds for the IPsec policy.
    - `protocol`: Optional protocol for the VPN link. Allowed values are: `IKEv2`, `IKEv1`. Defaults to `IKEv2`.
    - `ratelimit_enabled`: Optional boolean to enable rate limiting for the VPN link. Defaults to `false`.
    - `route_weight`: Optional route weight for the VPN link.
    - `shared_key`: Optional shared key for the VPN link.
    - `local_azure_ip_address_enabled`: Optional boolean to enable local Azure IP address for the VPN link.
    - `policy_based_traffic_selector_enabled`: Optional boolean to enable policy based traffic selector for the VPN link.
    - `custom_bgp_address`: Optional list of custom BGP addresses for the VPN link, which includes:
      - `ip_address`: IP address for the custom BGP address.
      - `ip_configuration_id`: IP configuration ID for the custom BGP address.
  - `internet_security_enabled`: Optional boolean to enable internet security for the connection, e.g. allow `0.0.0.0/0` route to be propagated to this connection to a branch/VPN site.
  - `routing`: Optional routing configuration object for the connection, which includes:
    - `associated_route_table`: The resource ID of the Virtual Hub Route Table you wish to associate with this connection.
    - `propagated_route_table`: Optional configuration objection of propagated route table configuration, which includes:
      - `route_table_ids`: Optional list of resource IDs of the Virtual Hub Route Tables you wish to propagate this connections routes to.
      - `labels`: Optional list of labels you wish to propagate this connections routes to.
    - `inbound_route_map_id`: Optional resource ID of the Virtual Hub inbound route map.
    - `outbound_route_map_id`: Optional resource ID of the Virtual Hub outbound route map.
  - `traffic_selector_policy`: Optional traffic selector policy object for the connection, which includes:
    - `local_address_ranges`: Local address ranges (CIDR) for the traffic selector policy.
    - `remote_address_ranges`: Remote address ranges (CIDR) for the traffic selector policy.

  > Note: There can be multiple objects in this map, one for each VPN Site connection you wish to connect to the Virtual WAN VPN Gateways that have been defined in the variable `vpn_gateways`.

Type:

```hcl
map(object({
    name                = string
    vpn_gateway_key     = string
    remote_vpn_site_key = string
    vpn_links = list(object({
      name                 = string
      egress_nat_rule_ids  = optional(list(string))
      ingress_nat_rule_ids = optional(list(string))
      # Index of the link on the vpn gateway
      vpn_site_link_number = number
      bandwidth_mbps       = optional(number)
      bgp_enabled          = optional(bool)
      connection_mode      = optional(string, "Default")

      ipsec_policy = optional(object({
        dh_group                 = string
        ike_encryption_algorithm = string
        ike_integrity_algorithm  = string
        encryption_algorithm     = string
        integrity_algorithm      = string
        pfs_group                = string
        sa_data_size_kb          = string
        sa_lifetime_sec          = string
      }))
      protocol                              = optional(string, "IKEv2")
      ratelimit_enabled                     = optional(bool, false)
      route_weight                          = optional(number)
      shared_key                            = optional(string)
      local_azure_ip_address_enabled        = optional(bool)
      policy_based_traffic_selector_enabled = optional(bool)
      custom_bgp_address = optional(list(object({
        ip_address          = string
        ip_configuration_id = string
      })))
    }))
    internet_security_enabled = optional(bool)
    routing = optional(object({
      associated_route_table = string
      propagated_route_table = optional(object({
        route_table_ids = optional(list(string))
        labels          = optional(list(string))
      }))
      inbound_route_map_id  = optional(string)
      outbound_route_map_id = optional(string)
    }))
    traffic_selector_policy = optional(object({
      local_address_ranges  = string
      remote_address_ranges = string
    }))
  }))
```

Default: `{}`

### <a name="input_vpn_sites"></a> [vpn\_sites](#input\_vpn\_sites)

Description:   Map of objects for VPN Sites to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

  The key is deliberately arbitrary to avoid issues with known after apply values. The value is an object, of which there can be multiple in the map:

  - `name`: Name for the VPN Site resource.
  - `virtual_hub_key`: The arbitrary key specified in the map of objects variable called `virtual_hubs` for the object specifying the Virtual Hub you wish to deploy this VPN Site into.
  - `links`: List of links for the VPN Site, which includes:
    - `name`: Name for the link.
    - `bgp`: Optional BGP object for the link, which includes:
      - `asn`: ASN for the BGP.
      - `peering_address`: Peering address for the BGP.
    - `fqdn`: Optional FQDN for the link.
    - `ip_address`: Optional IP address for the link.
    - `provider_name`: Optional provider name for the link.
    - `speed_in_mbps`: Optional speed in Mbps for the link.
  - `address_cidrs`: Optional list of address CIDRs for the VPN Site. Must be set if `links.bgp` is not set.
  - `device_model`: Optional device model for the VPN Site.
  - `device_vendor`: Optional device vendor for the VPN Site.
  - `o365_policy`: Optional O365 policy object for the VPN Site, which includes:
    - `traffic_category`: Optional traffic category object for the O365 policy, which includes:
      - `allow_endpoint_enabled`: Optional boolean. Is allow endpoint enabled? The `Allow` endpoint is required for connectivity to specific O365 services and features, but are not as sensitive to network performance and latency as other endpoint types.
      - `default_endpoint_enabled`: Optional boolean. Is default endpoint enabled? The `Default` endpoint represents O365 services and dependencies that do not require any optimization, and can be treated by customer networks as normal Internet bound traffic.
      - `optimize_endpoint_enabled`: Optional boolean. Is optimize endpoint enabled? The `Optimize` endpoint is required for connectivity to every O365 service and represents the O365 scenario that is the most sensitive to network performance, latency, and availability.
  - `tags`: Optional tags to apply to the VPN Site resource.

  > Note: There can be multiple objects in this map, one for each VPN Site you wish to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

Type:

```hcl
map(object({
    name = string
    # Name of the virtual hub
    virtual_hub_key = string
    links = list(object({
      name = string
      bgp = optional(object({
        asn             = number
        peering_address = string
      }))
      fqdn          = optional(string)
      ip_address    = optional(string)
      provider_name = optional(string)
      speed_in_mbps = optional(number)
      }
    ))
    address_cidrs = optional(list(string))
    device_model  = optional(string)
    device_vendor = optional(string)
    o365_policy = optional(object({
      traffic_category = object({
        allow_endpoint_enabled    = optional(bool)
        default_endpoint_enabled  = optional(bool)
        optimize_endpoint_enabled = optional(bool)
      })
    }))
    tags = optional(map(string))
  }))
```

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_azure_firewall_resource_ids"></a> [azure\_firewall\_resource\_ids](#output\_azure\_firewall\_resource\_ids)

Description: A map of Azure Firewall resource IDs with the map keys of the `firewalls` variable.

### <a name="output_azure_firewall_resource_names"></a> [azure\_firewall\_resource\_names](#output\_azure\_firewall\_resource\_names)

Description: A map of Azure Firewall resource names with the map keys of the `firewalls` variable.

### <a name="output_er_gw_id"></a> [er\_gw\_id](#output\_er\_gw\_id)

Description: ExpressRoute Gateway ID

### <a name="output_expressroute_gateway_resource_ids"></a> [expressroute\_gateway\_resource\_ids](#output\_expressroute\_gateway\_resource\_ids)

Description: A map of expressRoute Gateway IDs with the map keys of the `expressroute_gateways` variable.

### <a name="output_expressroute_gateway_resource_names"></a> [expressroute\_gateway\_resource\_names](#output\_expressroute\_gateway\_resource\_names)

Description: A map of expressRoute Gateway names with the map keys of the `expressroute_gateways` variable.

### <a name="output_firewall_ip_addresses_by_firewall_key"></a> [firewall\_ip\_addresses\_by\_firewall\_key](#output\_firewall\_ip\_addresses\_by\_firewall\_key)

Description: A map of Azure Firewall IP addresses with the map keys of the firewalls.

### <a name="output_firewall_ip_addresses_by_hub_key"></a> [firewall\_ip\_addresses\_by\_hub\_key](#output\_firewall\_ip\_addresses\_by\_hub\_key)

Description: A map of Azure Firewall IP addresses with the map keys of the hubs.

### <a name="output_fw"></a> [fw](#output\_fw)

Description: Firewall Name

### <a name="output_p2s_vpn_gw_id"></a> [p2s\_vpn\_gw\_id](#output\_p2s\_vpn\_gw\_id)

Description: P2S VPN Gateway ID

### <a name="output_p2s_vpn_gw_resource_ids"></a> [p2s\_vpn\_gw\_resource\_ids](#output\_p2s\_vpn\_gw\_resource\_ids)

Description: A map of point to site VPN gateway names with the map keys of the `p2s_gateways` variable.

### <a name="output_p2s_vpn_gw_resource_names"></a> [p2s\_vpn\_gw\_resource\_names](#output\_p2s\_vpn\_gw\_resource\_names)

Description: A map of point to site VPN gateway names with the map keys of the `p2s_gateways` variable.

### <a name="output_resource"></a> [resource](#output\_resource)

Description: The full resource outputs.

### <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name)

Description: Resource Group Name

### <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id)

Description: Virtual WAN ID

### <a name="output_s2s_vpn_gw"></a> [s2s\_vpn\_gw](#output\_s2s\_vpn\_gw)

Description: S2S VPN Gateway Objects

### <a name="output_s2s_vpn_gw_id"></a> [s2s\_vpn\_gw\_id](#output\_s2s\_vpn\_gw\_id)

Description: S2S VPN Gateway ID

### <a name="output_virtual_hub_id"></a> [virtual\_hub\_id](#output\_virtual\_hub\_id)

Description: Virtual Hub ID

### <a name="output_virtual_hub_resource_ids"></a> [virtual\_hub\_resource\_ids](#output\_virtual\_hub\_resource\_ids)

Description: A map of Azure Virtual Hub resource IDs with the map keys of the `virtual_hubs` variable.

### <a name="output_virtual_hub_resource_names"></a> [virtual\_hub\_resource\_names](#output\_virtual\_hub\_resource\_names)

Description: A map of Azure Virtual Hub resource names with the map keys of the `virtual_hubs` variable.

### <a name="output_virtual_wan_id"></a> [virtual\_wan\_id](#output\_virtual\_wan\_id)

Description: Virtual WAN ID

### <a name="output_vpn_gateway_resource_ids"></a> [vpn\_gateway\_resource\_ids](#output\_vpn\_gateway\_resource\_ids)

Description: A map of Azure VPN Gateway resource IDs with the map keys of the `vpn_gateways` variable.

### <a name="output_vpn_gateway_resource_names"></a> [vpn\_gateway\_resource\_names](#output\_vpn\_gateway\_resource\_names)

Description: A map of Azure VPN Gateway resource names with the map keys of the `vpn_gateways` variable.

## Modules

No modules.

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->