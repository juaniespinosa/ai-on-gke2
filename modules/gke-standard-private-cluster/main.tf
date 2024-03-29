# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

locals {
  node_pools = concat((var.enable_gpu ? var.gpu_pools : []), (var.enable_tpu ? var.tpu_pools : []), var.cpu_pools)
}

data "google_compute_subnetwork" "subnetwork" {
  name    = var.subnetwork_name
  project = var.project_id
  region  = var.cluster_region
}

module "gke" {
  source                               = "terraform-google-modules/kubernetes-engine/google//modules/private-cluster"
  version                              = "28.0.0"
  project_id                           = var.project_id
  regional                             = var.cluster_regional
  name                                 = var.cluster_name
  kubernetes_version                   = var.kubernetes_version
  region                               = var.cluster_region
  zones                                = var.cluster_zones
  network                              = var.network_name
  subnetwork                           = var.subnetwork_name
  ip_range_pods                        = var.ip_range_pods
  ip_range_services                    = var.ip_range_services
  remove_default_node_pool             = true
  logging_enabled_components           = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  monitoring_enabled_components        = ["SYSTEM_COMPONENTS"]
  monitoring_enable_managed_prometheus = var.monitoring_enable_managed_prometheus

  enable_private_endpoint = true
  enable_private_nodes    = false
  master_authorized_networks = concat([
    {
      cidr_block   = data.google_compute_subnetwork.subnetwork.ip_cidr_range
      display_name = "VPC"
    }],
    var.master_authorized_networks
  )

  node_pools = local.node_pools

  node_pools_oauth_scopes = {
    all = var.all_node_pools_oauth_scopes
  }

  node_pools_labels = {
    all = var.all_node_pools_labels
  }

  node_pools_metadata = {
    all = var.all_node_pools_metadata
  }

  node_pools_tags = {
    all = var.all_node_pools_tags
  }
}


