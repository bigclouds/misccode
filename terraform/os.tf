provider "openstack" {
  //user_domain_name    = "Default"
  //project_domain_name = "Default"
  tenant_name         = "admin"
  user_name           = "admin"
  password            = "admin"
  auth_url            = "http://173.20.2.1:5000/v3"
  region              = "RegionOne"
}
