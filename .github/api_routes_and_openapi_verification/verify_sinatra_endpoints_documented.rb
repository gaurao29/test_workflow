require 'set'

def sanitize_route(route_with_verb)
  route_with_verb = route_with_verb&.gsub(/'/, '')
  route_with_verb = route_with_verb&.gsub(/"/, '')
  route_with_verb = route_with_verb&.gsub(/ do/, '|')
  route_with_verb = route_with_verb&.strip
  return route_with_verb if route_with_verb&.length&.positive?

  nil
end

def find_sinatra_routes_v2(diff_file_path, url_prefix)
  # Define the HTTP verbs that correspond to Sinatra routes
  http_verbs = %w[get post put delete patch]
  routes = Set.new
  # get /meta/charts do get /meta/charts/:chart_id/edition do
  # get /meta/charts | get /meta/charts/:chart_id/edition |
  # Read the file line by line and check for HTTP verbs
  File.readlines(diff_file_path).each_with_index do |line, _index|
    line = sanitize_route(line.strip)
    split_routes = line.split('|')
    split_routes.each do |verb_and_path|
      # Check if the line starts with an HTTP verb followed by a space or '('
      next unless http_verbs.any? { |verb| line.strip.start_with?("#{verb} ", "#{verb}(") }
      route_with_verb = sanitize_route(verb_and_path.strip)
      route_verb_split = route_with_verb.split
      verb = route_verb_split[0] if route_with_verb && route_verb_split.length.positive?
      route = route_verb_split[1] if route_with_verb && route_verb_split.length > 1
      routes << "#{verb} #{url_prefix}#{route}" if route[0] == '/'
    end
  end

  routes
end



app_url_prefix_map = {}
app_file_with_url_prefix = ENV.fetch('APP_FILE_PIPE_URL_PREFIX', '')&.split(',')
app_file_with_url_prefix.each do |pair|
  key, value = pair.split('|')
  app_url_prefix_map[key] = value
end

puts "Workspace:#{ENV['GITHUB_WORKSPACE']}"

all_routes = Set.new
Dir.glob("#{ENV['GIT_WORKSPACE']}/diff_*.md").each do |file_path|
  file_name = File.basename(file_path).gsub('diff_', '')
  url_prefix = app_url_prefix_map[file_name]
  all_routes.merge(find_sinatra_routes_v2(file_path, url_prefix))
end

puts "All routes:"
all_routes.each do |route|
  puts route
end
