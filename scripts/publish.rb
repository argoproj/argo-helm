require 'yaml'
require 'pathname'

root_dir = Pathname.new("#{File.dirname(__FILE__)}/..").cleanpath

`mkdir -p #{root_dir}/output`

list = Dir.glob("#{root_dir}/charts/**/*Chart.yaml")

list.each do |filename|
    chart_name = File.basename(File.dirname(filename))
    `tar -cvzf #{root_dir}/output/#{chart_name}-#{version_info['version']}.tgz #{File.dirname(filename)} -C #{File.dirname(filename)} .`
    `helm repo index #{root_dir}/output`
end
