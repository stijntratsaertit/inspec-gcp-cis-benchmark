# encoding: utf-8
# Copyright 2019 The inspec-gcp-cis-benchmark Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

title "Ensure 'Block Project-wide SSH keys' is enabled for VM instances"

gcp_project_id = attribute('gcp_project_id')
cis_version = attribute('cis_version')
cis_url = attribute('cis_url')
control_id = "4.2"
control_abbrev = "vms"

control "cis-gcp-#{control_id}-#{control_abbrev}" do
  impact 1.0

  title "[#{control_abbrev.upcase}] Ensure 'Block Project-wide SSH keys' enabled for VM instances"

  desc "It is recommended to user Instance specific SSH key(s) instead of using common/shared project-wide SSH key(s) to access Instances."
  desc "rationale", "Project-wide SSH keys are stored in Compute/Project-meta-data. Project wide SSH keys can be used to login into all the instances within project. Using project-wide SSH keys eases the SSH key management but if compromised, poses the security risk which can impact all the instances within project. It is recommended to use Instance specific SSH keys which can limit the attack surface if the SSH keys are compromised."

  tag cis_scored: true
  tag cis_level: 1
  tag cis_gcp: "#{control_id}"
  tag cis_version: "#{cis_version}"
  tag project: "#{gcp_project_id}"

  ref "CIS Benchmark", url: "#{cis_url}"
  ref "GCP Docs", url: "https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys"

  google_compute_zones(project: gcp_project_id).zone_names.each do |zone|
    google_compute_instances(project: gcp_project_id, zone: zone).instance_names.each do |instance|
      next if instance =~ /^gke-/
      describe "[#{gcp_project_id}] #{zone}/#{instance}" do
        subject { google_compute_instance(project: gcp_project_id, zone: zone, name: instance) }
        its('block_project_ssh_keys') { should cmp true }
      end
    end
  end

end
