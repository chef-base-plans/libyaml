title 'Tests to confirm libyaml library exists'

plan_origin = ENV['HAB_ORIGIN']
plan_name = input('plan_name', value: 'libyaml')

control 'core-plans-libyaml-library-exists' do
  impact 1.0
  title 'Ensure libyaml library exists'
  desc '
  Verify libyaml library by ensuring that
  (1) its installation directory exists;
  (2) the library exists;
  (3) its pkgconfig metadata contains the expected version
  '

  plan_installation_directory = command("hab pkg path #{plan_origin}/#{plan_name}")
  describe plan_installation_directory do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
  end

  library_filename = input('library_filename', value: 'libyaml.so')
  library_full_path = File.join(plan_installation_directory.stdout.strip, 'lib', library_filename)
  describe file(library_full_path) do
    it { should exist }
  end

  plan_pkg_ident = ((plan_installation_directory.stdout.strip).match /(?<=pkgs\/)(.*)/)[1]
  plan_pkg_version = (plan_pkg_ident.match /^#{plan_origin}\/#{plan_name}\/(?<version>.*)\//)[:version]
  # create pkgconfig filename using major.minor portion of the $plan_pkg_version; in other words,
  # 0.1.7 becomes 0.1 and the filename is therefore "yaml-0.1.pc"
  #  "yaml-0.1.pc" is fixed name. So hardcoded the same
  pkgconfig_full_path = File.join(plan_installation_directory.stdout.strip, 'lib', 'pkgconfig',  "yaml-0.1.pc")
  describe command("cat #{pkgconfig_full_path}") do
    its('exit_status') { should eq 0 }
    its('stdout') { should_not be_empty }
    its('stdout') { should match /Version:\s+#{plan_pkg_version}/ }
  end
end
