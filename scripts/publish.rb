require 'yaml'

root_dir = "#{File.dirname(__FILE__)}/.."
output_index_path = "#{root_dir}/output/index.yaml"

`mkdir -p #{root_dir}/output`

list = Dir.glob("#{root_dir}/charts/**/*Chart.yaml")

repo_index = if File.exists?(output_index_path) then YAML.load_file(output_index_path) else { 'apiVersion' => 'v1', 'entries' => {}} end

list.each do |filename|
    chart_name = File.basename(File.dirname(filename))
    chart_versions = repo_index['entries'][chart_name] || []
    repo_index['entries'][chart_name] = chart_versions
    version_info = YAML.load_file(filename)
    existing_info = chart_versions.find{ |item| item.version == version_info['version'] }
    if existing_info then
        chart_versions[chart_versions.index(existing_info)] = version_info
    else
        chart_versions.push version_info
    end
    `tar -zcvf #{root_dir}/output/#{chart_name}-#{version_info['version']}.tar.gz #{File.dirname(filename)}`
    File.open(output_index_path, 'w') { |file| file.write(repo_index.to_yaml( :Indent => 4, :UseHeader => true, :UseVersion => true )) }
end
