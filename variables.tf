variable "location" {
  type        = string
  description = <<DESCRIPTION
  The Virtual WAN location.
  
  > Note: This is not the location for the Virtual WAN Hubs, these are defined within the `virtual_hubs` variable in their own `location` property of each object.
  DESCRIPTION
  nullable    = false
}

variable "resource_group_name" {
  type        = string
  description = <<DESCRIPTION
  Name of the Resource Group where the Virtual WAN and it's child resources, e.g. Virtual WAN Hubs, Gateways etc., will be created. 

  The Resource Group will be created if the variable `create_resource_group` is set to `true`. If it is set to `false` the resource group must already exist.
  
  > Note: Each Virtual WAN Hub can be configured to deploy into different resource groups, that must already exist or be created outside of this module, by specifying the `resource_group` property in each object in the `virtual_hubs` variable map input. If you do not do this, the same resource group will be used for all Virtual WAN resources as specified in this variable.
  DESCRIPTION

  validation {
    condition     = length(var.resource_group_name) >= 1 && length(var.resource_group_name) <= 90
    error_message = "Resource group name must be specified. It must be between 1 and 90 characters. Underscores, hyphens, periods, parentheses, and letters or digits are allowed."
  }
}

variable "virtual_wan_name" {
  type        = string
  description = "Name of the Virtual WAN resource itself."
  nullable    = false

  validation {
    condition     = length(var.virtual_wan_name) >= 1 && length(var.virtual_wan_name) <= 80
    error_message = "Virtual WAN name must be specified. It must be between 1 and 80 characters. Alphanumerics, underscores, periods, and hyphens are allowed. It must start with alphanumeric and end with alphanumeric or underscore."
  }
}

variable "allow_branch_to_branch_traffic" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
  Boolean toggle to toggle support for VWAN branch to branch traffic. Branches are locations connected over ExpressRoute or Site-to-Site VPNs to a Virtual WAN Hub. Defaults to true.

  For more information review: https://learn.microsoft.com/azure/virtual-wan/virtual-wan-global-transit-network-architecture
  DESCRIPTION
}

variable "create_resource_group" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
  If `true` will create a resource group, otherwise (`false`) will use an existing resource group specified in the variable `resource_group_name`"

  DESCRIPTION
}

variable "disable_vpn_encryption" {
  type        = bool
  default     = false
  description = <<DESCRIPTION
  Boolean toggle to disable VPN encryption. Defaults to `false` (VPN encryption enabled). 

  DESCRIPTION
}

variable "er_circuit_connections" {
  type = map(object({
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
  default     = {}
  description = <<DESCRIPTION
Map of objects for ExpressRoute Circuit connections to connect to the Virtual WAN ExpressRoute Gateways.

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
  
  DESCRIPTION
}

variable "expressroute_gateways" {
  type = map(object({
    name                          = string
    virtual_hub_key               = string
    tags                          = optional(map(string))
    allow_non_virtual_wan_traffic = optional(bool, false)
    scale_units                   = optional(number, 1)
  }))
  default     = {}
  description = <<DESCRIPTION

Map of objects for Express Route Gateways to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

The key is deliberately arbitrary to avoid issues with known after apply values. The value is an object, of which there can be multiple in the map:

- `name`: Name for the ExpressRoute Gateway to deploy in the Virtual WAN Virtual Hub.
- `virtual_hub_key`: The arbitrary key specified in the map of objects variable called `virtual_hubs` for the object specifying the Virtual Hub you wish to deploy this ExpressRoute Gateway into.
- `tags`: Optional tags to apply to the ExpressRoute Gateway resource.
- `allow_non_virtual_wan_traffic`: Optional boolean to configures this gateway to accept traffic from non Virtual WAN networks. Defaults to `false`.
- `scale_units`: Optional number of scale units for the ExpressRoute Gateway. Defaults to `1`. See: https://learn.microsoft.com/azure/virtual-wan/virtual-wan-expressroute-about#expressroute-gateway-performance for more information on scale units.

> Note: There can be multiple objects in this map, one for each ExpressRoute Gateway you wish to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

  DESCRIPTION
}

# Azure Firewall
variable "firewalls" {
  type = map(object({
    virtual_hub_key      = string
    sku_name             = optional(string, "AZFW_Hub")
    sku_tier             = string
    name                 = string
    zones                = optional(list(number), [1, 2, 3])
    firewall_policy_id   = optional(string)
    vhub_public_ip_count = optional(string)
    tags                 = optional(map(string))
  }))
  default     = {}
  description = <<DESCRIPTION

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

  DESCRIPTION
}

variable "office365_local_breakout_category" {
  type        = string
  default     = "None"
  description = <<DESCRIPTION
  Specifies the Office 365 local breakout category. Possible values are:
  
  - `Optimize`
  - `OptimizeAndAllow`
  - `All`
  - `None`
  
  Defaults to `None`.

  DESCRIPTION

  validation {
    condition     = contains(["Optimize", "OptimizeAndAllow", "All", "None"], var.office365_local_breakout_category)
    error_message = "The Office 365 local breakout category must be one of the following: `Optimize`, `OptimizeAndAllow`, `All`, `None`."
  }
}

variable "p2s_gateway_vpn_server_configurations" {
  type = map(object({
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
  default     = {}
  description = <<DESCRIPTION
  Map of objects for Point-to-Site VPN Gateway VPN Server Configurations to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

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

  DESCRIPTION
}

# P2S gateway parameters
variable "p2s_gateways" {
  type = map(object({
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
  default     = {}
  description = <<DESCRIPTION
  Map of objects for Point-to-Site VPN Gateways to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

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

  DESCRIPTION
}

variable "resource_group_tags" {
  type        = map(string)
  default     = {}
  description = <<DESCRIPTION
  (Optional) Resource group tags to assign, if created by module controlled by variable `create_resource_group`.

  DESCRIPTION
}

# Routing intent for virutal hubs
variable "routing_intents" {
  type = map(object({
    name            = string
    virtual_hub_key = string
    routing_policies = list(object({
      name                  = string
      destinations          = list(string)
      next_hop_firewall_key = string
    }))
  }))
  default     = {}
  description = <<DESCRIPTION
  Map of objects for routing intents to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

  The key is deliberately arbitrary to avoid issues with known after apply values. The value is an object, of which there can be multiple in the map:

  - `name`: Name for the routing intent resource.
  - `virtual_hub_key`: The arbitrary key specified in the map of objects variable called `virtual_hubs` for the object specifying the Virtual Hub you wish to deploy this routing intent into.
  - `routing_policies`: List of routing policies for the routing intent, which includes:
    - `name`: Name for the routing policy.
    - `destinations`: List of destinations for the routing policy. Allowed values are: `Internet`, `PrivateTraffic`.
    - `next_hop_firewall_key`: The arbitrary key specified in the map of objects variable called `firewalls` for the object specifying the Azure Firewall you wish to use as the next hop for the routing policy. This is used to get the correct resource ID for the corresponding Azure Firewall.

  DESCRIPTION
  nullable    = false
}

# General tags for all resources in pattern
variable "tags" {
  type        = map(string)
  default     = null
  description = <<DESCRIPTION
  (Optional) Tags to apply to the Resource Group, if created by module controlled by variable `create_resource_group`, and the Virtual WAN resource only.
  
  DESCRIPTION
}

variable "type" {
  type        = string
  default     = "Standard"
  description = <<DESCRIPTION
  Type of the Virtual WAN to create. Possible values include:
  
  - `Basic`
  - `Standard`
  
  Defaults to `Standard` and is recommended.

  DESCRIPTION

  validation {
    condition     = contains(["Basic", "Standard"], var.type)
    error_message = "The Virtual WAN type must be one of the following: `Basic`, `Standard`. `Standard` is the default and recommended."
  }
}

variable "virtual_hub_route_tables" {
  type = map(object({
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
  default     = {}
  description = <<-EOT
 - `name` - (Required) The name which should be used for Virtual Hub Route Table. Changing this forces a new resource to be created.
 - `virtual_hub_key` - (Required) The key of the Virtual Hub within which this route table should be created. Changing this forces a new resource to be created.
 - `labels` - (Optional) List of labels associated with this route table.
 - `routes` - (Optional) A map of routes in the Virtual Hub Route Table. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.
  - `name` - (Required) The name which should be used for this route.
  - `destinations` - (Required) A list of destination addresses for this route.
  - `destinations_type` - (Required) The type of destinations. Possible values are CIDR, ResourceId and Service.
  - `next_hop` - (Optional) The next hop's resource ID. Required if `vnet_connection_key` is not defined.
  - `vnet_connection_key` - (Optional) The next hop vnet connection's key. Required if `next_hop` is not defined.
  - `next_hop_type` - (Optional) The type of next hop. Currently the only possible value is ResourceId. Defaults to ResourceId.
EOT
}

variable "virtual_hubs" {
  type = map(object({
    name                                   = string
    location                               = string
    resource_group                         = optional(string, null)
    address_prefix                         = string
    tags                                   = optional(map(string))
    hub_routing_preference                 = optional(string, "ExpressRoute")
    virtual_router_auto_scale_min_capacity = optional(number, 2)
  }))
  default     = {}
  description = <<DESCRIPTION
  Map of objects for Virtual Hubs to deploy into the Virtual WAN.

  The key is deliberately arbitrary to avoid issues with known after apply values. The value is an object, of which there can be multiple in the map:

  - `name`: Name for the Virtual Hub resource.
  - `location`: Location for the Virtual Hub resource.
  - `resource_group`: Optional resource group name to deploy the Virtual Hub into. If not specified, the Virtual Hub will be deployed into the resource group specified in the variable `resource_group_name`, e.g. the same as the Virtual WAN itself.
  - `address_prefix`: Address prefix for the Virtual Hub. Recommend using a `/23` CIDR block.
  - `tags`: Optional tags to apply to the Virtual Hub resource.
  - `hub_routing_preference`: Optional hub routing preference for the Virtual Hub. Possible values are: `ExpressRoute`, `ASPath`, `VpnGateway`. Defaults to `ExpressRoute`. See https://learn.microsoft.com/azure/virtual-wan/hub-settings#routing-preference for more information.
  - `virtual_router_auto_scale_min_capacity`: Optional minimum capacity for the Virtual Router auto scale. Defaults to `2`. See https://learn.microsoft.com/azure/virtual-wan/hub-settings#capacity for more information.

  > Note: There can be multiple objects in this map, one for each Virtual Hub you wish to deploy into the Virtual WAN. Multiple Virtual Hubs in the same region/location can be deployed into the same Virtual WAN also.

  DESCRIPTION
}

# Azure virtual network connections
variable "virtual_network_connections" {
  type = map(object({
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
  default     = {}
  description = <<DESCRIPTION
  Map of objects for Virtual Network connections to connect Virtual Networks to the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

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

  DESCRIPTION
  nullable    = false
}

variable "virtual_wan_tags" {
  type        = map(string)
  default     = {}
  description = <<DESCRIPTION
  (Optional) Tags to apply to the Virtual WAN resource only.

  DESCRIPTION
}

# VPN Gateway parameters
variable "vpn_gateways" {
  type = map(object({
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
  default     = {}
  description = <<DESCRIPTION
  Map of objects for S2S VPN Gateways to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

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

  DESCRIPTION
}

variable "vpn_site_connections" {
  type = map(object({
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
  default     = {}
  description = <<DESCRIPTION
  Map of objects for VPN Site connections to connect VPN Sites to the Virtual WAN VPN Gateways that have been defined in the variable `vpn_gateways`.

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

  DESCRIPTION
}

variable "vpn_sites" {
  type = map(object({
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
  default     = {}
  description = <<DESCRIPTION
  Map of objects for VPN Sites to deploy into the Virtual WAN Virtual Hubs that have been defined in the variable `virtual_hubs`.

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

  DESCRIPTION
}
